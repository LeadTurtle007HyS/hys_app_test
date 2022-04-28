package com.sparrowrms.hyspro.ui.activity

import android.content.*
import android.content.pm.PackageManager
import android.media.projection.MediaProjectionManager
import android.os.*
import android.util.DisplayMetrics
import android.util.Log
import android.view.SurfaceView
import android.view.WindowManager
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.databinding.DataBindingUtil
import androidx.lifecycle.ViewModelProviders
import com.sparrowrms.hyspro.Constants.*
import com.sparrowrms.hyspro.R
import com.sparrowrms.hyspro.data.repository.FirebaseDataRepository
import com.sparrowrms.hyspro.dataSource.remote.FirebaseDataSource
import com.sparrowrms.hyspro.dataSource.remote.FirebaseRealtimeDatabaseSource
import com.sparrowrms.hyspro.databinding.ActivityCallBinding
import com.sparrowrms.hyspro.model.dataclasses.CallingUserNotificationDetails
import com.sparrowrms.hyspro.model.datasourcemodel.UserDetailsModel
import com.sparrowrms.hyspro.network.ApiHelper
import com.sparrowrms.hyspro.network.RetrofitClient
import com.sparrowrms.hyspro.screensharemodule.externvideosource.ExternalVideoInputManager
import com.sparrowrms.hyspro.screensharemodule.externvideosource.IExternalVideoInputService
import com.sparrowrms.hyspro.services.CallService
import com.sparrowrms.hyspro.ui.fragment.*
import com.sparrowrms.hyspro.util.*
import com.sparrowrms.hyspro.viewmodels.AudioCallViewModel
import com.sparrowrms.hyspro.viewmodels.DataViewModelFactory
import io.agora.rtc.video.VideoEncoderConfiguration
import io.agora.rtc.video.WatermarkOptions
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers
import java.lang.IllegalStateException
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.ArrayList
import com.sparrowrms.hyspro.model.dataclasses.SendNotificationModel
import com.sparrowrms.hyspro.network.FirebaseNetworking
import com.sparrowrms.hyspro.network.HYSNetworking
import com.squareup.okhttp.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


private const val INCOME_CALL_FRAGMENT = "income_call_fragment"

class CallActivity : BaseActivity(), ConversationFragmentCallback,
    IncomeCallFragmentCallbackListener {

    companion object {

        private const val PROJECTION_REQ_CODE = 5001
        private const val DEFAULT_SHARE_FRAME_RATE = 15

        fun start(
            context: Context,
            isIncomingCall: Boolean,
            userDetailsModel: UserDetailsModel,
            isVideo: Boolean,
            notificationDetails: CallingUserNotificationDetails
        ) {
            val intent = Intent(context, CallActivity::class.java)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.putExtra(EXTRA_IS_INCOMING_CALL, isIncomingCall)
            intent.putExtra(EXTRA_IS_VIDEO_CALL, isVideo)
            intent.putExtra(userDetailsKey, userDetailsModel)
            intent.putExtra(EXTRA_CALLING_NOTIFICATION_DETAILS, notificationDetails)
            SharedPrefsHelper.save(EXTRA_IS_INCOMING_CALL, isIncomingCall)
            context.startActivity(intent)
            CallService.start(
                context,
                isVideoCall = isVideo,
                isIncomingCall,
                userDetailsModel = userDetailsModel
            )
        }
    }

    private var TAG = CallActivity::class.java.simpleName
    private val currentCallStateCallbackList = ArrayList<CurrentCallStateCallback>()
    private lateinit var showIncomingCallWindowTaskHandler: Handler
    private lateinit var callServiceConnection: ServiceConnection
    private lateinit var showIncomingCallWindowTask: Runnable
    private lateinit var callService: CallService

    private var isInComingCall: Boolean = false
    private var isVideoCall: Boolean = false

    private val PERMISSION_REQUEST_CODE = 101
    lateinit var callActivityBinding: ActivityCallBinding
    lateinit var userDetailsModel: UserDetailsModel
    lateinit var notificationDetails: CallingUserNotificationDetails
    lateinit var loggedInUserDetailsModel: UserDetailsModel
    lateinit var audioCallViewModel: AudioCallViewModel
    lateinit var notiificationToken: String
    lateinit var channelID: String
    private val disposable = CompositeDisposable()
    private var isInitScreen: Boolean = false

    private var isBrodcastRegistered: Boolean = false

    private var callActivity: CallActivity? = null

    private var mService: IExternalVideoInputService? = null
    private val mServiceConnection: VideoInputServiceConnection? = null

    private var PERMISSIONS = arrayOf(
        android.Manifest.permission.WRITE_EXTERNAL_STORAGE,
        android.Manifest.permission.CAMERA,
        android.Manifest.permission.RECORD_AUDIO
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        callActivity = this
        callActivityBinding = DataBindingUtil.setContentView(this, R.layout.activity_call)

        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )

        callActivityBinding.lifecycleOwner = this
        userDetailsModel = intent.getParcelableExtra(userDetailsKey)!!
        audioCallViewModel = ViewModelProviders.of(
            this, DataViewModelFactory(
                FirebaseDataRepository(FirebaseDataSource()),
                ApiHelper(RetrofitClient.agoraTokenAPIRequest)
            )
        ).get(AudioCallViewModel::class.java)
        isInComingCall = intent?.extras?.getBoolean(EXTRA_IS_INCOMING_CALL) ?: true
        if (!isInComingCall) {
            observeAllCallDetails()
            audioCallViewModel.getUserCallStatusAndToken(userDetailsModel.userid)
            loggedInUserDetailsModel = SharedPrefsHelper.getQbUser()
        } else {
            notificationDetails =
                intent?.extras?.getParcelable(EXTRA_CALLING_NOTIFICATION_DETAILS)!!
            channelID = notificationDetails.channelid!!
            audioCallViewModel.observeSYMCallDataUpdate(channelID)
        }

        observeHYSSMCallData()

    }

    override fun onBackPressed() {
        moveTaskToBack(false)
    }


    private fun bindCallService() {
        callServiceConnection = CallServiceConnection()
        Intent(this, CallService::class.java).also { intent ->
            bindService(intent, callServiceConnection, Context.BIND_AUTO_CREATE)
        }
    }

    override fun onResume() {
        super.onResume()
        bindCallService()
    }


    override fun onPause() {
        super.onPause()
        unbindService(callServiceConnection)
        if (::callService.isInitialized) {
            removeListeners()
        }
    }

    override fun onStart() {
        super.onStart()
        registerNotificationActionListener()
    }

    override fun onDestroy() {
        if (isBrodcastRegistered) {
            try {
                unregisterReceiver(broadcastReceiver)
            } catch (e: IllegalStateException) {
                e.printStackTrace()
            }
        }
        super.onDestroy()
    }

    private fun addListeners() {

    }

    private fun removeListeners() {
        callService.removeCallTimerCallback()
        callService.removeNotificationButtonActionCallBack()
    }


    private fun initScreen() {
        isInitScreen = true
        callService.setNotificationButtonActionCallback(NotificationButtonActionCallback())
        isVideoCall = callService.isVideoCall()
        if (callService.isCallMode()) {
            if (callService.isSharingScreenState()) {
                // startScreenSharing(null)
                return
            }
            addConversationFragment(isInComingCall)
        } else {
            isInComingCall = if (intent != null && intent.extras != null) {
                intent?.extras?.getBoolean(EXTRA_IS_INCOMING_CALL) ?: true
            } else {
                SharedPrefsHelper[EXTRA_IS_INCOMING_CALL, false]
            }

            if (!isInComingCall) {
                callService.playRingtone()
            } else {
                //  callService.loggedInUser = loggedInUserDetailsModel
                callService.agoraChannelID = channelID
            }
            startSuitableFragment(isInComingCall)
        }
    }

    private inner class CallTimerCallback : CallService.CallTimerListener {
        override fun onCallTimeUpdate(time: String) {
            runOnUiThread {
                notifyCallStateListenersCallTime(time)
            }
        }

        override fun onConnectedToUser() {
            runOnUiThread {
                notifyCallStateListenersCallStarted()
            }
        }

        override fun onUserOffline(reason: Int) {
            if (reason == 0) {
                onHangUpCurrentSession()
            }
        }

        override fun onLocalUserJoin(userId: Int) {
            runOnUiThread {
                notifyCallStateListenersLocalUserJoin(userId)
            }
        }

        override fun onRemoteUserJoin(userId: Int) {
            runOnUiThread {
                notifyCallStateListenersRemoteUserJoin(userId)
            }
        }

        override fun onVideoSizeChanged(uid: Int, width: Int, height: Int, rotation: Int) {
            runOnUiThread {
                notifyVideoSizeChangedListeners(uid, width, height, rotation)
            }
        }

        override fun onRemoteUserStartedScreenShare(type: Boolean) {
            runOnUiThread {
                notifyCallStateRemoteUserScreenShare(type)
            }
        }


    }

    private inner class NotificationButtonActionCallback : CallService.NotificationButtonActionListener {
        override fun onSessionAcceptAction() {

        }

        override fun onSessionDeclineAction() {

        }

        override fun onSessionHangupAction() {
            runOnUiThread {
                finish()
            }
        }

        override fun onNotAnsweredByReceiver() {
            runOnUiThread {
                showToast("Not answered ")
                finish()
            }
        }

    }

    private fun notifyCallStateListenersCallTime(callTime: String) {
        for (callback in currentCallStateCallbackList) {
            callback.onCallTimeUpdate(callTime)
        }
    }


    private fun notifyCallStateListenersCallStarted() {
        for (callback in currentCallStateCallbackList) {
            callback.onCallStarted()
        }
    }

    private fun notifyCallStateListenersCallStopped() {
        for (callback in currentCallStateCallbackList) {
            callback.onCallStopped()
        }
    }

    private fun notifyCallStateListenersLocalUserJoin(userId: Int) {
        for (callback in currentCallStateCallbackList) {
            callback.onLocalUserJoined(userId)
        }
    }

    private fun notifyCallStateListenersRemoteUserJoin(userId: Int) {
        for (callback in currentCallStateCallbackList) {
            callback.onRemoteUserJoined(userId)
        }
    }

    private fun notifyVideoSizeChangedListeners(uid: Int, width: Int, height: Int, rotation: Int) {
        for (callback in currentCallStateCallbackList) {
            callback.onVideoSizeChanged(uid, width, height, rotation)
        }
    }

    private fun notifyCallStateRemoteUserScreenShare(type: Boolean) {
        for (callback in currentCallStateCallbackList) {
            callback.remoteUserStartedScreenShare(type)
        }
    }


    private fun startSuitableFragment(isInComingCall: Boolean) {
        if (isInComingCall) {
            initIncomingCallTask()
            addIncomeCallFragment()
            // checkPermission()
        } else {
            addConversationFragment(isInComingCall)
            intent.removeExtra(EXTRA_IS_INCOMING_CALL)
            SharedPrefsHelper.save(EXTRA_IS_INCOMING_CALL, false)
        }
    }

    private fun addConversationFragment(isIncomingCall: Boolean) {
        val baseConversationFragment: BaseConversationFragment = if (isVideoCall) {
            VideoConversationFragment()
        } else {
            AudioConversationFragment()
        }
        val conversationFragment = BaseConversationFragment.newInstance(
            baseConversationFragment,
            isIncomingCall,
            userDetailsModel
        )
        addFragment(
            supportFragmentManager,
            R.id.fragment_container,
            conversationFragment,
            conversationFragment.javaClass.simpleName
        )
    }


    private fun initIncomingCallTask() {
        showIncomingCallWindowTaskHandler = Handler(Looper.myLooper()!!)
        showIncomingCallWindowTask = Runnable {
            if (callService.currentSessionExist()) {
                callService.clearCallState()
                callService.clearButtonsState()
                CallService.stop(this@CallActivity)
                finish()
            }
        }
    }

    private fun addIncomeCallFragment() {
        if (callService.currentSessionExist()) {
            val fragment =
                IncomeCallFragment.newInstance(IncomeCallFragment(), isVideoCall, userDetailsModel)
            if (supportFragmentManager.findFragmentByTag(INCOME_CALL_FRAGMENT) == null) {
                addFragment(
                    supportFragmentManager,
                    R.id.fragment_container,
                    fragment,
                    INCOME_CALL_FRAGMENT
                )
            }
        } else {
            Log.d(TAG, "SKIP addIncomeCallFragment method")
        }
    }

    private inner class CallServiceConnection : ServiceConnection {
        override fun onServiceDisconnected(name: ComponentName?) {

        }

        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            val binder = service as CallService.CallServiceBinder
            callService = binder.getService()
            callService.setCallTimerCallback(CallTimerCallback())
            if (!isInitScreen)
                initScreen()
        }
    }

    private fun observeAllCallDetails() {
        audioCallViewModel.observeCallingDetails().observe(this, {
            if (it != null) {
                when (it.status) {
                    Status.LOADING -> {

                    }
                    Status.SUCCESS -> {
                        if (it.data != null) {
                            notiificationToken = it.data.userNotificationToken
                            channelID = it.data.roomToken
                            if (::callService.isInitialized) {
                                callService.addAgoraChannelID(channelID)
                                callService.loggedInUserDetailsModel = loggedInUserDetailsModel
                                callService.notificationToken = notiificationToken
                                if (!isInitScreen)
                                    initScreen()
                            }
                            if (!it.data.userCallStatus) {
                                initCalling()
                            } else {
                                showToast(userDetailsModel.firstname + " " + userDetailsModel.lastname + " is on other call.")
                                userBusyRejectSession()
                            }
                        }
                    }
                    Status.ERROR -> {
                        showToast(it.message!!)
                        userBusyRejectSession()
                    }
                }
            }

        })
    }

    private fun initCalling() {
        if (this::loggedInUserDetailsModel.isInitialized) {
            val sdf = SimpleDateFormat("yyyyMMddkkmm")
            val comparedate = sdf.format(Date())
            val sdf2 = SimpleDateFormat("yyyyMMddkkmm", Locale.US)
            val currentDate = sdf2.format(Date())
            val message =
                "${loggedInUserDetailsModel.firstname} ${loggedInUserDetailsModel.lastname} Calling you"
            val callingUserNotificationDetails = CallingUserNotificationDetails(
                if (isVideoCall) "2" else "1",
                channelID,
                comparedate,
                message,
                "SocailFeedCall",
                currentDate,
                "q&a",
                "123456",
                userDetailsModel.userid,
                userDetailsModel.firstname,
                loggedInUserDetailsModel.userid,
                loggedInUserDetailsModel.firstname,
                notiificationToken
            )
            updateHYSCallData(channelID)
            sendNotification(notiificationToken,callingUserNotificationDetails)

//            disposable.add(
//                FirebaseDataSource().incomingCallNotificationToSuperUser(callingUserNotificationDetails)
//                    .subscribeOn(
//                        Schedulers.io()
//                    ).observeOn(AndroidSchedulers.mainThread()).subscribe({
//                        updateHYSCallData(channelID)
//                    }, {
//                        showToast(it.localizedMessage)
//                    })
//            )
        }


    }

    private fun showToast(error: String) {
        Toast.makeText(this, error, Toast.LENGTH_LONG).show()
    }

    private fun updateHYSSMCallData(
        channelID: String,
        iscallreceivedbyReceiver: Boolean,
        iscallcancelledbycaller: Boolean,
        iscallrejected: Boolean,
        iscallcancelledafterReceived: Boolean,
        message: String
    ) {
        val map = HashMap<String, Any>()
        map["iscallreceivedbyReceiver"] = iscallreceivedbyReceiver
        map["iscallcancelledbycaller"] = iscallcancelledbycaller
        map["iscallrejected"] = iscallrejected
        map["iscallcancelledafterReceived"] = iscallcancelledafterReceived
        map["message"] = message
        FirebaseRealtimeDatabaseSource().updateHYSCallData(channelID, map).subscribe()
    }

    private fun updateHYSCallData(channelID: String) {
        audioCallViewModel.observeSYMCallDataUpdate(channelID)
        val map = HashMap<String, Any>()
        map["iscallreceivedbyReceiver"] = false
        map["iscallcancelledbycaller"] = false
        map["iscallrejected"] = false
        map["iscallcancelledafterReceived"] = false
        map["message"] = "NO"
        FirebaseRealtimeDatabaseSource().updateHYSCallData(channelID, map).subscribe()
        joinChannel()
    }

    private fun joinChannel() {
        if (hasPermissions(this, *PERMISSIONS)) {
            callService.joinChannel(channelID)
        } else {
            ActivityCompat.requestPermissions(
                this,
                PERMISSIONS,
                PERMISSION_REQUEST_CODE
            )
        }
    }

    private fun registerNotificationActionListener() {
        registerReceiver(broadcastReceiver, IntentFilter(EXTRA_NOTIFICATION_BUTTON_ACTION))
        isBrodcastRegistered = true
    }


    private val broadcastReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.extras!!.getString(EXTRA_NOTIFICATION_BUTTON_ACTION_DATA)!!) {
                CreateNotification.ACTION_HANGUP_SESSION -> {
                    if (this@CallActivity.callActivity != null) {
                        callActivity!!.finishAndRemoveTask()
                    }
                }

                CreateNotification.ACTION_ACCEPT_CALL -> {
                    addConversationFragment(true)

                }
                CreateNotification.ACTION_DECLINE_CALL -> {

                    callService.rejectCurrentSession()
                    finishAndRemoveTask()
                }
                CreateNotification.ACTION_CLOSE_NOTIFICATION -> {

                }
            }
        }
    }


    private fun observeHYSSMCallData() {
        audioCallViewModel.observeHYSSMCallData().observe(this, {
            if (it != null) {
                when (it.status) {
                    Status.LOADING -> {

                    }
                    Status.SUCCESS -> {
                        if (it.data != null) {
                            handleUpdateChanges(it.data as HashMap<String, Any>)
                        }
                    }
                    Status.ERROR -> {
                        showToast(it.message!!)
                    }
                }
            }

        })
    }

    private fun handleUpdateChanges(map: HashMap<String, Any>) {
        when {
            map["iscallrejected"] == true -> {
                callDeclinedByReciever()
            }
            map["iscallcancelledafterReceived"] == true -> {
                CallService.stop(this)
                finishAndRemoveTask()
            }
            map["iscallcancelledbycaller"] == true -> {
                CallService.stop(this)
                finishAndRemoveTask()
            }
        }
//        else if (map["isScreenSharingStarted"] == true) {
//            if (!callService.isSharingScreenState()) {
//                callService.sharingScreenState = true
//                runOnUiThread {
//                    notifyCallStateRemoteUserScreenShare(true)
//                }
//            }
//        } else if (map["isScreenSharingStarted"] == false) {
//            if (callService.isSharingScreenState()) {
//                callService.sharingScreenState = false
//                runOnUiThread {
//                    notifyCallStateRemoteUserScreenShare(false)
//                }
//            }
//        }
    }

    private fun callDeclinedByReciever() {
        showToast("User Busy")
        CallService.stop(this)
        finishAndRemoveTask()
    }

    private fun userBusyRejectSession() {
        if (::callService.isInitialized) {
            callService.userBusyRejectSession()
            finishAndRemoveTask()
        }
    }


    private fun hasPermissions(context: Context, vararg permissions: String): Boolean =
        permissions.all {
            ActivityCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED
        }


    interface CurrentCallStateCallback {
        fun onCallStarted()
        fun onCallStopped()
        fun onCallTimeUpdate(time: String)
        fun onLocalUserJoined(localUserId: Int)
        fun onRemoteUserJoined(remoteUserId: Int)
        fun onVideoSizeChanged(uid: Int, width: Int, height: Int, rotation: Int)
        fun remoteUserStartedScreenShare(isScreenShareStarted: Boolean)
    }

    override fun onSetAudioEnabled(isAudioEnabled: Boolean) {
        callService.setAudioEnabled(isAudioEnabled)
    }

    override fun onSetVideoEnabled(isNeedEnableCam: Boolean) {
        callService.enableLocalVideo(isNeedEnableCam)
    }

    override fun onSwitchAudio() {
        callService.switchAudio()
    }

    override fun onSwitchCamera() {
        callService.switchCamera()
    }

    override fun onHangUpCurrentSession() {
        callService.hangupCurrentSession()
        finishAndRemoveTask()
    }

    override fun onStartScreenSharing(isScreenShare: Boolean) {

        if(this::notiificationToken.isInitialized){
            val callingUserNotificationDetails = CallingUserNotificationDetails()
            callingUserNotificationDetails.notificationtype="screen_share"
            callingUserNotificationDetails.isScreenShareStarted= if(isScreenShare) "1" else "0"
            callingUserNotificationDetails.token=callService.notificationToken
            sendNotification(callService.notificationToken,callingUserNotificationDetails)
        }else{
          disposable.add( audioCallViewModel.getUserNotificationToken(callService.userDetailsModel.userid).subscribeOn(Schedulers.io())
              .observeOn(AndroidSchedulers.mainThread()).subscribe(
                  {
                      callService.notificationToken=it
                      val callingUserNotificationDetails = CallingUserNotificationDetails()
                      callingUserNotificationDetails.notificationtype="screen_share"
                      callingUserNotificationDetails.isScreenShareStarted= if(isScreenShare) "1" else "0"
                      callingUserNotificationDetails.token=it
                      sendNotification(it,callingUserNotificationDetails)
                  }, {
                      showToast("Something went wrong")
                  })

          )
        }
        callService.startScreenSharing(isScreenShare)
        if (isScreenShare) {
            val mpm = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
            val intent = mpm.createScreenCaptureIntent()
            startActivityForResult(
                intent,
                PROJECTION_REQ_CODE
            )
        }

    }

    override fun acceptCall(userInfo: Map<String, String>) {
        callService.stopRingtone()
        callService.acceptCall(channelID)
        joinChannel()
    }

    override fun startCall(userInfo: Map<String, String>) {
        callService.startCall()
    }

    override fun currentSessionExist(): Boolean {
        return true
    }

    override fun getOpponents(): List<Int>? {
        return null
    }

    override fun getCallerId(): Int {
        return callService.localUserId
    }

    override fun addCurrentCallStateListener(currentCallStateCallback: CurrentCallStateCallback?) {
        currentCallStateCallback?.let {
            currentCallStateCallbackList.add(it)
        }
    }

    override fun removeCurrentCallStateListener(currentCallStateCallback: CurrentCallStateCallback?) {
        currentCallStateCallbackList.remove(currentCallStateCallback)
    }

    override fun isMediaStreamManagerExist(): Boolean {
        return true
    }

    override fun isCallState(): Boolean {
        return callService.isCallMode()
    }

    override fun setupLocalVideo(surfaceView: SurfaceView) {
        callService.setUPLocalSurfaceViewVideo(surfaceView)
    }

    override fun setupRemoteVideo(surfaceView: SurfaceView?) {
        callService.setUPRemoteSurfaceViewVideo(surfaceView)
    }

    override fun enableVideo() {
        callService.enableVideo()
    }

    override fun disableVideo() {
        callService.disableVideo()
    }

    override fun setVideoEncoderConfiguration(videoEncoderConfiguration: VideoEncoderConfiguration) {
        callService.setVideoEncoderConfiguration(videoEncoderConfiguration)
    }

    override fun setDefaultAudioRoutetoSpeakerphone() {
        callService.setAudioRouteToMicrophone()
    }

    override fun setVideoWaterMark(watermarkOptions: WatermarkOptions) {
        callService.setUpWaterMarkOption(watermarkOptions)
    }

    override fun openWhiteBoard() {

        val intent = Intent(this, WhiteboardScreen::class.java)
        intent.putExtra("ROOM_ID", channelID)
        startActivity(intent)
    }

    override fun onAcceptCurrentSession() {
        callService.stopRingtone()
        callService.acceptCurrentSession()
        addConversationFragment(true)
    }

    override fun onRejectCurrentSession() {
        callService.rejectCurrentSession()
        finishAndRemoveTask()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        when (requestCode) {
            PERMISSION_REQUEST_CODE -> {

                var deniedCount = 0
                for (d in grantResults) {
                    if (d == PackageManager.PERMISSION_DENIED)
                        deniedCount++
                }
                // If request is cancelled, the result arrays are empty.
                if (deniedCount == 0) {
                    joinChannel()
                } else {
                    showToast(" ")
                }
                return
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == PROJECTION_REQ_CODE && resultCode == RESULT_OK) {
            try {
                val metrics = DisplayMetrics()
                windowManager.defaultDisplay.getMetrics(metrics)
                data!!.putExtra(
                    ExternalVideoInputManager.FLAG_SCREEN_WIDTH,
                    metrics.widthPixels
                )
                data.putExtra(
                    ExternalVideoInputManager.FLAG_SCREEN_HEIGHT,
                    metrics.heightPixels
                )
                data.putExtra(
                    ExternalVideoInputManager.FLAG_SCREEN_DPI,
                    metrics.density.toInt()
                )
                data.putExtra(
                    ExternalVideoInputManager.FLAG_FRAME_RATE,
                    DEFAULT_SHARE_FRAME_RATE
                )
                callService.setVideoConfig(
                    ExternalVideoInputManager.TYPE_SCREEN_SHARE,
                    metrics.widthPixels,
                    metrics.heightPixels
                )
                callService.setExternalVideoInput(
                    ExternalVideoInputManager.TYPE_SCREEN_SHARE,
                    data
                )

            } catch (e: RemoteException) {
                e.printStackTrace()
            }
        }
    }

    private inner class VideoInputServiceConnection : ServiceConnection {
        override fun onServiceConnected(componentName: ComponentName, iBinder: IBinder) {
            mService = iBinder as IExternalVideoInputService
        }

        override fun onServiceDisconnected(componentName: ComponentName) {
            mService = null
        }
    }


    private fun sendNotification(token:String,data:CallingUserNotificationDetails) {
        val sendNotificationModel = SendNotificationModel(token, data)
        val responseBodyCall: Call<ResponseBody?>? = FirebaseNetworking.agoraTokenAPIRequest.sendChatNotification(sendNotificationModel)

        responseBodyCall!!.enqueue(object : Callback<ResponseBody?> {
            override fun onResponse(call: Call<ResponseBody?>, response: Response<ResponseBody?>) {

            }

            override fun onFailure(call: Call<ResponseBody?>, t: Throwable) {
               val error=t.localizedMessage
                showToast("Something went wrong")
                userBusyRejectSession()
            }
        })

    }

}


