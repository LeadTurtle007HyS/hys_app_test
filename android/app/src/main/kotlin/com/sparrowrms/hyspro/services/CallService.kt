package com.sparrowrms.hyspro.services

import android.app.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.BitmapFactory
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.text.TextUtils
import android.util.Log
import android.view.SurfaceView
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.sparrowrms.hyspro.Constants.*
import com.sparrowrms.hyspro.R
import com.sparrowrms.hyspro.data.repository.FirebaseDataRepository
import com.sparrowrms.hyspro.dataSource.remote.FirebaseDataSource
import com.sparrowrms.hyspro.dataSource.remote.FirebaseRealtimeDatabaseSource
import com.sparrowrms.hyspro.model.datasourcemodel.UserDetailsModel
import com.sparrowrms.hyspro.screensharemodule.externvideosource.ExternalVideoInputManager
import com.sparrowrms.hyspro.ui.activity.CallActivity
import com.sparrowrms.hyspro.util.*
import io.agora.rtc.Constants
import io.agora.rtc.IRtcEngineEventHandler
import io.agora.rtc.IRtcEngineEventHandler.*
import io.agora.rtc.RtcEngine
import io.agora.rtc.mediaio.CameraSource
import io.agora.rtc.models.ChannelMediaOptions
import io.agora.rtc.video.VideoCanvas
import io.agora.rtc.video.VideoEncoderConfiguration
import io.agora.rtc.video.WatermarkOptions
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers
import java.lang.Exception
import java.lang.IllegalStateException
import java.util.*
import kotlin.concurrent.timerTask

const val SERVICE_ID = 787
const val CHANNEL_ID = "HYS channel"
const val CHANNEL_NAME = "HYS background service"

class CallService : Service() {
    private var TAG = CallService::class.java.simpleName
    private val callServiceBinder: CallServiceBinder = CallServiceBinder()
    private var expirationReconnectionTime: Long = 0
    var sharingScreenState: Boolean = false
    private var isCallState: Boolean = false

    private var ringtonePlayer: RingtonePlayer? = null
    private val callTimerTask: CallTimerTask = CallTimerTask()
    private var callTime: Long? = null
    private val callTimer = Timer()

    private val APP_ID = "f426c0acff024b4bb17794003d069683"
    private var mRtcEngine: RtcEngine? = null

    private var callTimerListener: CallTimerListener? = null

    private var notificationActionButtonListener: NotificationButtonActionListener? = null

    private var firebaseDataRepository: FirebaseDataRepository? = null
    private var isVideoCall: Boolean? = false
    private var isIncomingCall: Boolean? = false
    private var currentSession: Boolean = false

    lateinit var userDetailsModel: UserDetailsModel
    lateinit var loggedInUserDetailsModel: UserDetailsModel
    private val disposable = CompositeDisposable()
    lateinit var loggedInUser: UserDetailsModel
    lateinit var agoraChannelID: String
    lateinit var notificationToken: String

    var remoteUserID: Int = 0
    var localUserId: Int = 0
    private var isBrodcastRegistered = false
    private var mSourceManager: ExternalVideoInputManager? = null

    companion object {
        fun start(
            context: Context,
            isVideoCall: Boolean,
            isIncomingCall: Boolean,
            userDetailsModel: UserDetailsModel
        ) {
            val intent = Intent(context, CallService::class.java)
            intent.putExtra(EXTRA_IS_VIDEO_CALL, isVideoCall)
            intent.putExtra(userDetailsKey, userDetailsModel)
            intent.putExtra(EXTRA_IS_INCOMING_CALL, isIncomingCall)
            context.startService(intent)
        }

        fun stop(context: Context) {
            val intent = Intent(context, CallService::class.java)
            context.stopService(intent)
        }
    }

    override fun onCreate() {
        super.onCreate()
        initListeners()
        initRtcEngine()
        ringtonePlayer = RingtonePlayer(this, R.raw.beep)
        firebaseDataRepository = FirebaseDataRepository(FirebaseDataSource())
        mSourceManager = ExternalVideoInputManager(this.applicationContext)
        waitForAcceptCall()

    }

    private fun waitForAcceptCall(){
        Timer().schedule(timerTask {
           if(remoteUserID==0){
               notificationActionButtonListener?.onNotAnsweredByReceiver()
               hangupCurrentSession()
           }

        }, 60000)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        isVideoCall = intent?.getBooleanExtra(EXTRA_IS_VIDEO_CALL, false)
        userDetailsModel = intent?.getParcelableExtra(userDetailsKey)!!
        if (intent != null) {
            isIncomingCall = intent.getBooleanExtra(EXTRA_IS_INCOMING_CALL, false)
        }
        val channelId: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel(CHANNEL_ID, CHANNEL_NAME)
        } else {
            getString(R.string.app_name)
        }

        val notification = CreateNotification.createCallNotification(
            this,
            userDetailsModel,
            isIncomingCall!!,
            isVideoCall!!,
            isCallState,
            channelId,
            getCallTime()
        )
        startForeground(SERVICE_ID, notification)
        currentSession = true
        registerNotificationActionListener()
        return super.onStartCommand(intent, flags, startId)
    }

    override fun onUnbind(intent: Intent?): Boolean {
        return super.onUnbind(intent)

    }

    private fun startSourceManager() {
        mSourceManager!!.start()
    }

    private fun stopSourceManager() {
        if (mSourceManager != null) {
            mSourceManager!!.stop()
        }
    }


    fun notifyCallNotification() {
        val channelId: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel(CHANNEL_ID, CHANNEL_NAME)
        } else {
            getString(R.string.app_name)
        }

        val callTime = getCallTime()
        val notification = CreateNotification.createCallNotification(
            this,
            userDetailsModel,
            isIncomingCall!!,
            isVideoCall!!,
            true,
            channelId,
            callTime
        )

        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(SERVICE_ID, notification)
    }


    override fun onDestroy() {
        super.onDestroy()
        destroyRtcEngine()
        stopRingtone()
        stopCallTimer()
        clearButtonsState()
        clearCallState()
        stopForeground(true)
        if (isBrodcastRegistered) {
            try {
                unregisterReceiver(broadcastReceiver)
                unregisterReceiver(screenShareReceiver)
            } catch (e: IllegalStateException) {
                e.printStackTrace()
            }

        }
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancelAll()
    }

    override fun onBind(p0: Intent?): IBinder {
        return callServiceBinder
    }

    private fun initRtcEngine() {
        try {
            mRtcEngine = RtcEngine.create(baseContext, APP_ID, iRtcEngineEventHandler)
            ENGINE = RtcEngine.create(baseContext, APP_ID, iRtcEngineEventHandler)

        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun setLoggedInUserDetails(userDetailsModel: UserDetailsModel) {
        loggedInUserDetailsModel = userDetailsModel
    }

    fun addAgoraChannelID(channelId: String) {
        agoraChannelID = channelId
        observeSYMCallDataUpdate(agoraChannelID)
    }

    fun setReceiverNotificationToken(notificationTokenID: String) {
        notificationToken = notificationTokenID
    }


    private val iRtcEngineEventHandler: IRtcEngineEventHandler = object : IRtcEngineEventHandler() {
        override fun onWarning(warn: Int) {

        }

        override fun onError(err: Int) {


        }


        override fun onLeaveChannel(stats: RtcStats) {
            super.onLeaveChannel(stats)
            isCallState = false
            currentSession = false
            ringtonePlayer?.stop()

        }

        override fun onJoinChannelSuccess(channel: String, uid: Int, elapsed: Int) {
            currentSession = true
            localUserId = uid
            callTimerListener?.onLocalUserJoin(localUserId)

        }

        override fun onRemoteAudioStateChanged(uid: Int, state: Int, reason: Int, elapsed: Int) {
            super.onRemoteAudioStateChanged(uid, state, reason, elapsed)
        }


        override fun onUserJoined(uid: Int, elapsed: Int) {
            super.onUserJoined(uid, elapsed)
            isCallState = true
            ringtonePlayer?.stop()
            startCallTimer()
            callTimerListener?.onConnectedToUser()
            remoteUserID = uid
            callTimerListener?.onRemoteUserJoin(remoteUserID)


        }


        override fun onUserOffline(uid: Int, reason: Int) {
            ringtonePlayer?.stop()
            isCallState = false
        }

        override fun onRemoteAudioStats(remoteAudioStats: RemoteAudioStats?) {

        }

        override fun onLocalAudioStats(localAudioStats: LocalAudioStats?) {

        }

        override fun onRemoteVideoStats(remoteVideoStats: RemoteVideoStats?) {

        }

        override fun onLocalVideoStats(localVideoStats: LocalVideoStats?) {

        }

        override fun onRtcStats(rtcStats: RtcStats?) {

        }

        override fun onVideoSizeChanged(uid: Int, width: Int, height: Int, rotation: Int) {
            super.onVideoSizeChanged(uid, width, height, rotation)
            if (remoteUserID != 0 && remoteUserID == uid && isSharingScreenState())
                callTimerListener?.onVideoSizeChanged(uid, width, height, rotation)

        }


        override fun onConnectionStateChanged(state: Int, reason: Int) {
            super.onConnectionStateChanged(state, reason)
        }

        override fun onConnectionLost() {
            super.onConnectionLost()
        }

        override fun onFirstLocalVideoFramePublished(elapsed: Int) {
            super.onFirstLocalVideoFramePublished(elapsed)
        }

        override fun onFirstRemoteVideoFrame(uid: Int, width: Int, height: Int, elapsed: Int) {
            super.onFirstRemoteVideoFrame(uid, width, height, elapsed)
        }

        override fun onNetworkQuality(uid: Int, txQuality: Int, rxQuality: Int) {
            super.onNetworkQuality(uid, txQuality, rxQuality)
        }

        override fun onUserMuteVideo(uid: Int, muted: Boolean) {
            super.onUserMuteVideo(uid, muted)
        }

        override fun onRemoteVideoStateChanged(uid: Int, state: Int, reason: Int, elapsed: Int) {
            super.onRemoteVideoStateChanged(uid, state, reason, elapsed)
        }


    }


    fun currentSessionExist(): Boolean {
        return currentSession
    }

    // Set audio route to microPhone
    fun setAudioRouteToMicrophone() {
        if (mRtcEngine != null)
            mRtcEngine!!.setDefaultAudioRoutetoSpeakerphone(false)

        if (ENGINE != null)
            ENGINE!!.setDefaultAudioRoutetoSpeakerphone(false)
    }

    // Enable video module
    fun enableVideo() {
        if (mRtcEngine != null)
            mRtcEngine!!.enableVideo()
        if (ENGINE != null)
            ENGINE!!.enableVideo()
    }

    fun disableVideo() {
        if (mRtcEngine != null)
            mRtcEngine!!.disableVideo()

    }


    // Setup video encoding configs
    fun setVideoEncoderConfiguration(videoEncoderConfiguration: VideoEncoderConfiguration) {
        if (mRtcEngine != null)
            mRtcEngine!!.setVideoEncoderConfiguration(
                videoEncoderConfiguration
            )


    }

    fun setVideoConfig(sourceType: Int, width: Int, height: Int) {
        val videoOrientationMode: VideoEncoderConfiguration.ORIENTATION_MODE = when (sourceType) {
            ExternalVideoInputManager.TYPE_SCREEN_SHARE -> {
                VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_FIXED_PORTRAIT
            }
            else -> {
                VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_ADAPTIVE
            }
        }

        if (mRtcEngine != null) {
            mRtcEngine!!.setVideoEncoderConfiguration(
                VideoEncoderConfiguration(
                    VideoEncoderConfiguration.VideoDimensions(width, height),
                    VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_15,
                    VideoEncoderConfiguration.STANDARD_BITRATE,
                    videoOrientationMode
                )
            )
        }


    }


    // enable local video
    fun enableLocalVideo(isNeedEnableCam: Boolean) {
        if (mRtcEngine != null) {
            mRtcEngine!!.enableLocalVideo(isNeedEnableCam)
        }
        if (ENGINE != null) {
            ENGINE!!.enableLocalVideo(isNeedEnableCam)
        }
    }


// Setup watermark options

    fun setUpWaterMarkOption(watermarkOptions: WatermarkOptions) {
        //   mRtcEngine!!.addVideoWatermark(Constant.WATER_MARK_FILE_PATH, watermarkOptions)
    }

    //   Setup Local Video
    fun setUPLocalSurfaceViewVideo(surfaceView: SurfaceView) {
        if (mRtcEngine != null)
            mRtcEngine!!.setupLocalVideo(
                VideoCanvas(
                    surfaceView,
                    VideoCanvas.RENDER_MODE_FIT,
                    localUserId
                )
            )
    }

    //   Setup Remote Video
    fun setUPRemoteSurfaceViewVideo(surfaceView: SurfaceView?) {
      //  if (mRtcEngine != null)
            mRtcEngine!!.setupRemoteVideo(
                VideoCanvas(
                    surfaceView,
                    VideoCanvas.RENDER_MODE_HIDDEN,
                    remoteUserID
                )
            )
    }



    @RequiresApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel(channelId: String, channelName: String): String {
        val channel =
            NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_LOW)
        channel.lightColor = getColor(R.color.colorPrimary)
        channel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
        val service = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        service.createNotificationChannel(channel)
        return channelId
    }

    private fun getCallTime(): String {
        var time = ""
        callTime?.let {
            val format = String.format("%%0%dd", 2)
            val elapsedTime = it / 1000
            val seconds = String.format(format, elapsedTime % 60)
            val minutes = String.format(format, elapsedTime % 3600 / 60)
            val hours = String.format(format, elapsedTime / 3600)
            time = "$minutes:$seconds"
            if (!TextUtils.isEmpty(hours) && hours != "00") {
                time = "$hours:$minutes:$seconds"
            }
        }
        return time
    }

    fun playRingtone() {
        ringtonePlayer?.play(true)
    }

    fun stopRingtone() {
        ringtonePlayer?.stop()
    }


    fun acceptCall(channelId: String) {
        updateHYSSMCallData(
            channelId,
            iscallreceivedbyReceiver = true,
            iscallcancelledbycaller = false,
            iscallrejected = false,
            iscallcancelledafterReceived = false,
            false,
            message = "NO"
        )
    }

    fun startCall() {

    }

    fun acceptCurrentSession() {

    }


    private fun destroyRtcEngine() {
        if (mRtcEngine != null) {
            if (currentSession) {
                mRtcEngine!!.leaveChannel()
            }
            RtcEngine.destroy()
            mRtcEngine = null

        }
    }

    fun hangupCurrentSession() {
        if (::agoraChannelID.isInitialized) {
            if (isCallState) {
                updateHYSSMCallData(agoraChannelID,
                    iscallreceivedbyReceiver = false,
                    iscallcancelledbycaller = false,
                    iscallrejected = false,
                    iscallcancelledafterReceived = true,
                    isScreenSharingStarted = false,
                    message = "No"
                )

            } else {
                updateHYSSMCallData(agoraChannelID,
                    iscallreceivedbyReceiver = false,
                    iscallcancelledbycaller = true,
                    iscallrejected = false,
                    iscallcancelledafterReceived = false,
                    isScreenSharingStarted = false,
                    message = "No"
                )
            }
        }

        destroyRtcEngine()
        stopSelf()
    }

    fun userBusyRejectSession() {
        destroyRtcEngine()
        stopSelf()
    }


    fun rejectCurrentSession() {
        notificationActionButtonListener?.onSessionHangupAction()
        updateHYSSMCallData(agoraChannelID,
            iscallreceivedbyReceiver = false,
            iscallcancelledbycaller = false,
            iscallrejected = true,
            iscallcancelledafterReceived = false,
            isScreenSharingStarted = false,
            message = "No"
        )
        destroyRtcEngine()
        stopSelf()
    }


    fun joinChannel(channelId: String) {
        mRtcEngine!!.setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING)
        mRtcEngine!!.setClientRole(ClientRole.CLIENT_ROLE_BROADCASTER)
        mRtcEngine!!.enableAudioVolumeIndication(1000, 3, true)
        val option = ChannelMediaOptions()
        option.autoSubscribeAudio = true
        option.autoSubscribeVideo = true
        val res: Int =
            mRtcEngine!!.joinChannel("", channelId, "Extra Optional Data", 0, option)
        val res2: Int =
            ENGINE!!.joinChannel("", channelId, "Extra Optional Data", 0, option)

        if (res != 0) {
            Log.e("FragmentActivity.TAG", RtcEngine.getErrorDescription(Math.abs(res)))
            return
        }
    }


    fun startScreenSharing(isScreenShare: Boolean) {
        // ENGINE=mRtcEngine
        if (isScreenShare) {
            sharingScreenState = true
         //   updateHYSSMCallData(channelID = agoraChannelID, false, false, false, false, true, "No")
            startSourceManager()
            mRtcEngine?.setVideoSource(mSourceManager)
        } else {
         //   updateHYSSMCallData(channelID = agoraChannelID, false, false, false, false, false, "No")
            sharingScreenState = false
            mRtcEngine?.enableLocalVideo(true)
            stopSourceManager()
        }

    }

    fun setExternalVideoInput(type: Int, intent: Intent?) {
        mSourceManager?.setExternalVideoInput(type, intent)

    }


    private fun initListeners() {

    }


    fun switchCamera() {
        if (mRtcEngine != null)
            mRtcEngine!!.switchCamera()
    }

    fun switchAudio() {
        if (mRtcEngine!!.isSpeakerphoneEnabled) {
            mRtcEngine!!.setEnableSpeakerphone(false)
        } else {
            mRtcEngine!!.setEnableSpeakerphone(true)
        }
    }

    fun setAudioEnabled(enabled: Boolean) {
        mRtcEngine!!.muteLocalAudioStream(enabled)
    }


    fun isSharingScreenState(): Boolean {
        return sharingScreenState
    }

    fun isCallMode(): Boolean {
        return isCallState
    }

    fun isVideoCall(): Boolean {
        return isVideoCall!!
    }


    fun setCallTimerCallback(callback: CallTimerListener) {
        callTimerListener = callback
    }

    fun setNotificationButtonActionCallback(callback: NotificationButtonActionListener) {
        notificationActionButtonListener = callback
    }

    fun removeCallTimerCallback() {
        callTimerListener = null
    }

    fun removeNotificationButtonActionCallBack() {
        notificationActionButtonListener = null
    }


    private fun startCallTimer() {
        if (callTime == null) {
            callTime = 1000
        }
        if (!callTimerTask.isRunning) {
            callTimer.scheduleAtFixedRate(callTimerTask, 0, 1000)
        }
    }

    private fun stopCallTimer() {

        callTimer.cancel()
        callTimer.purge()
    }


    private inner class CallTimerTask : TimerTask() {
        var isRunning: Boolean = false

        override fun run() {
            isRunning = true

            callTime = callTime?.plus(1000L)
            notifyCallNotification()
            callTimerListener?.let {
                val callTime = getCallTime()
                if (!TextUtils.isEmpty(callTime)) {
                    it.onCallTimeUpdate(callTime)
                }
            }
        }
    }

    fun clearButtonsState() {
        SharedPrefsHelper.delete(MIC_ENABLED)
        SharedPrefsHelper.delete(SPEAKER_ENABLED)
        SharedPrefsHelper.delete(CAMERA_ENABLED)
        SharedPrefsHelper.delete(IS_CURRENT_CAMERA_FRONT)
    }

    fun clearCallState() {
        SharedPrefsHelper.delete(EXTRA_IS_INCOMING_CALL)
    }

    inner class CallServiceBinder : Binder() {
        fun getService(): CallService = this@CallService
    }


    private inner class NetworkConnectionListener :
        NetworkConnectionChecker.OnConnectivityChangedListener {
        override fun connectivityChanged(availableNow: Boolean) {

        }
    }

    //  isScreenSharingStarted  value 1 for started , 2 for closed , 0 default
    private fun updateHYSSMCallData(
        channelID: String,
        iscallreceivedbyReceiver: Boolean,
        iscallcancelledbycaller: Boolean,
        iscallrejected: Boolean,
        iscallcancelledafterReceived: Boolean,
        isScreenSharingStarted: Boolean,
        message: String,
    ) {
        val map = HashMap<String, Any>()
        map["iscallreceivedbyReceiver"] = iscallreceivedbyReceiver
        map["iscallcancelledbycaller"] = iscallcancelledbycaller
        map["iscallrejected"] = iscallrejected
        map["iscallcancelledafterReceived"] = iscallcancelledafterReceived
        map["isScreenSharingStarted"] = isScreenSharingStarted
        map["message"] = message
        FirebaseRealtimeDatabaseSource().updateHYSCallData(channelID, map).subscribe()
    }


    private fun observeSYMCallDataUpdate(channelID: String) {

        firebaseDataRepository?.observeHYS_CAllDataChanges(channelID)
            ?.subscribeOn(Schedulers.newThread())
            ?.observeOn(AndroidSchedulers.mainThread())?.subscribe(
                { it ->
                    if (it != null) {
                        handleUpdateChanges(it.value as HashMap<String, Any>)
                    }
                }, {

                })?.let { it1 ->
                disposable.add(
                    it1
                )
            }

    }

    private fun handleUpdateChanges(map: HashMap<String, Any>) {
        when {
            map["iscallrejected"] == true -> {
                destroyRtcEngine()
                stopSelf()
            }
            map["iscallcancelledafterReceived"] == true -> {
                destroyRtcEngine()
                stopSelf()
            }
            map["iscallcancelledbycaller"] == true -> {
                destroyRtcEngine()
                stopSelf()
            }
            map["isScreenSharingStarted"] == true -> {
    //            if (!isSharingScreenState()) {
    //                sharingScreenState = true
    //                callTimerListener?.onRemoteUserStartedScreenShare(true)
    //            }
            }
            map["isScreenSharingStarted"] == false -> {
    //            if (isSharingScreenState()) {
    //                sharingScreenState = false
    //                callTimerListener?.onRemoteUserStartedScreenShare(false)
    //            }
            }
        }

    }


    interface CallTimerListener {
        fun onCallTimeUpdate(time: String)
        fun onConnectedToUser()
        fun onUserOffline(reason: Int)
        fun onLocalUserJoin(userId: Int)
        fun onRemoteUserJoin(userId: Int)
        fun onVideoSizeChanged(uid: Int, width: Int, height: Int, rotation: Int)
        fun onRemoteUserStartedScreenShare(type: Boolean)

    }

    interface NotificationButtonActionListener {
        fun onSessionAcceptAction()
        fun onSessionDeclineAction()
        fun onSessionHangupAction()
        fun onNotAnsweredByReceiver()
    }


    private fun registerNotificationActionListener() {
        registerReceiver(broadcastReceiver, IntentFilter(EXTRA_NOTIFICATION_BUTTON_ACTION))
        registerReceiver(screenShareReceiver,IntentFilter(EXTRA_NOTIFICATION_SCREEN_SHARE_ACTION))
        isBrodcastRegistered = true
    }


    private val broadcastReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.extras!!.getString(EXTRA_NOTIFICATION_BUTTON_ACTION_DATA)!!) {
                CreateNotification.ACTION_HANGUP_SESSION -> {
                    notificationActionButtonListener?.onSessionHangupAction()
                    hangupCurrentSession()
                }

                CreateNotification.ACTION_ACCEPT_CALL -> {
                    stopRingtone()
                    acceptCurrentSession()
                    notifyCallNotification()

                }
                CreateNotification.ACTION_DECLINE_CALL -> {
                    rejectCurrentSession()

                }
                CreateNotification.ACTION_CLOSE_NOTIFICATION -> {

                }
            }
        }
    }

    private val screenShareReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.extras!!.getString(EXTRA_NOTIFICATION_BUTTON_ACTION_DATA)!!) {
                "1" -> {
                    if (!isSharingScreenState()) {
                        sharingScreenState = true
                        callTimerListener?.onRemoteUserStartedScreenShare(true)
                    }
                }

                "0" -> {
                    if (isSharingScreenState()) {
                        sharingScreenState = false
                        callTimerListener?.onRemoteUserStartedScreenShare(false)
                    }

                }

            }
        }
    }
}