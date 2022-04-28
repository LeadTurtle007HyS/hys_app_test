package com.sparrowrms.hyspro.ui.fragment

import android.annotation.SuppressLint
import android.app.Activity
import android.os.Bundle
import android.os.SystemClock
import android.util.Log
import android.view.*
import android.widget.*
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.sparrowrms.hyspro.Application
import com.sparrowrms.hyspro.R
import com.sparrowrms.hyspro.services.CallService
import com.sparrowrms.hyspro.util.SharedPrefsHelper
import io.agora.rtc.RtcEngine
import io.agora.rtc.video.VideoEncoderConfiguration
import java.io.Serializable

const val CAMERA_ENABLED = "is_camera_enabled"
const val IS_CURRENT_CAMERA_FRONT = "is_camera_front"
const val IS_SCREEN_SHARE = "is_screen_share"
private const val RECYCLE_VIEW_PADDING = 2
private const val FULL_SCREEN_CLICK_DELAY: Long = 1000

class VideoConversationFragment : BaseConversationFragment(), Serializable {
    private val TAG = VideoConversationFragment::class.java.simpleName

    //Views
    private lateinit var cameraToggle: ToggleButton
    private lateinit var audioSwitchToggleButton: ToggleButton
    private var parentView: View? = null
    private lateinit var actionVideoButtonsLayout: LinearLayout
    private lateinit var connectionStatusLocal: TextView
    private lateinit var recyclerView: RecyclerView
    private lateinit var localVideoView: FrameLayout
    private var remoteFullScreenVideoView: FrameLayout? = null

    private lateinit var localViewOnClickListener: LocalViewOnClickListener
    private var isPeerToPeerCall: Boolean = false
    private var optionsMenu: Menu? = null
    private var isRemoteShown: Boolean = false
    private var connectionEstablished: Boolean = false
    private var allCallbacksInit: Boolean = false
    private var isCurrentCameraFront: Boolean = false
    private var isScreenShare: Boolean = false
    private var isLocalVideoFullScreen: Boolean = false
    private var videoViewContainer: RelativeLayout? = null

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        parentView = super.onCreateView(inflater, container, savedInstanceState)
        return parentView
    }

    override fun configureOutgoingScreen() {
        val context = activity
        outgoingOpponentsRelativeLayout.setBackgroundColor(
            ContextCompat.getColor(
                context!!,
                R.color.grey_transparent_50
            )
        )
        allOpponentsTextView.setTextColor(ContextCompat.getColor(context, R.color.white))
        ringingTextView.setTextColor(ContextCompat.getColor(context, R.color.white))
    }

    override fun configureActionBar() {
        actionBar.setDisplayShowTitleEnabled(false)
        actionBar.hide()
    }

    override fun configureToolbar() {
        val context = activity
        toolbar.visibility = View.VISIBLE
        toolbar.setBackgroundColor(ContextCompat.getColor(context!!, R.color.transparent_black))
        toolbar.setTitleTextColor(ContextCompat.getColor(context, R.color.white))
        toolbar.setSubtitleTextColor(ContextCompat.getColor(context, R.color.white))
    }

    override fun getFragmentLayout(): Int {
        return R.layout.fragment_video_conversation
    }

    override fun initFields() {
        super.initFields()
        localViewOnClickListener = LocalViewOnClickListener()
        timerCallText = (activity as Activity).findViewById(R.id.timer_call)
        isPeerToPeerCall = true
    }

    private fun setDuringCallActionBar() {
        actionBar.setDisplayShowTitleEnabled(true)
        //  actionBar.title = currentUser.firstname
        if (isPeerToPeerCall) {
            //  actionBar.subtitle = getString(R.string.opponent, opponents[0].fullName)
        }

        actionButtonsEnabled(true)
    }

    private fun addListeners() {
        //    conversationFragmentCallback?.addSessionStateListener(this)
        //    conversationFragmentCallback?.addSessionEventsListener(this)
        //  conversationFragmentCallback?.addVideoTrackListener(this)
    }

    private fun removeListeners() {
        //  conversationFragmentCallback?.removeSessionStateListener(this)
        //  conversationFragmentCallback?.removeSessionEventsListener(this)
        //  conversationFragmentCallback?.removeVideoTrackListener(this)
    }

    override fun actionButtonsEnabled(inability: Boolean) {
        super.actionButtonsEnabled(inability)
        cameraToggle.isEnabled = inability
        // inactivate toggle buttons
        cameraToggle.isActivated = inability
    }

    override fun onStart() {
        super.onStart()
        if (!allCallbacksInit) {
            addListeners()
            allCallbacksInit = true
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setHasOptionsMenu(true)
    }

    @SuppressLint("ClickableViewAccessibility")
    override fun initViews(view: View?) {
        super.initViews(view)
        if (view == null) {
            return
        }
        isRemoteShown = false
        isCurrentCameraFront = true
        videoViewContainer = view.findViewById(R.id.fragmentOpponents)
        localVideoView = view.findViewById(R.id.local_video_view)
        remoteFullScreenVideoView = view.findViewById(R.id.remote_video_view)
        remoteFullScreenVideoView?.setOnClickListener(localViewOnClickListener)
        localVideoView.setOnTouchListener(mOnTouchListener)
        audioSwitchToggleButton = view.findViewById(R.id.toggle_speaker)
        audioSwitchToggleButton.visibility = View.VISIBLE
        audioSwitchToggleButton.isChecked = SharedPrefsHelper[SPEAKER_ENABLED, true]
        connectionStatusLocal = view.findViewById(R.id.connection_status_local)
        cameraToggle = view.findViewById(R.id.toggle_camera)
        cameraToggle.visibility = View.VISIBLE
        cameraToggle.isChecked = SharedPrefsHelper[CAMERA_ENABLED, true]
        toggleCamera(cameraToggle.isChecked)
        actionVideoButtonsLayout = view.findViewById(R.id.element_set_video_buttons)

        if (!SharedPrefsHelper[IS_CURRENT_CAMERA_FRONT, true]) {
            switchCamera(null)
        }

        actionButtonsEnabled(false)
        restoreSession()
    }

    private fun restoreSession() {
        if (context == null)
            return
        if (conversationFragmentCallback?.isCallState() == true && conversationFragmentCallback != null) {
            onCallStarted()
        }


        // Enable video module
        conversationFragmentCallback?.enableVideo()
        // Setup video encoding configs
        conversationFragmentCallback?.setVideoEncoderConfiguration(
            VideoEncoderConfiguration(
                ((activity as Activity).application as Application).getGlobalSettings()
                !!.videoEncodingDimensionObject,
                VideoEncoderConfiguration.FRAME_RATE.valueOf(
                    ((activity as Activity).application as Application).getGlobalSettings()
                    !!.videoEncodingFrameRate
                ),
                VideoEncoderConfiguration.STANDARD_BITRATE,
                VideoEncoderConfiguration.ORIENTATION_MODE.valueOf(
                    ((activity as Activity).application as Application).getGlobalSettings()
                    !!.videoEncodingOrientation
                )
            )
        )
        if (localVideoView.childCount == 0) {
            addLocalVideoView()
        }
//        if (remoteFullScreenVideoView!!.childCount == 0) {
//            addRemoteVideoView()
//        }
    }

    private fun addRemoteVideoView() {
        if (remoteFullScreenVideoView != null) {
            var surfaceView: SurfaceView? = null
            surfaceView = RtcEngine.CreateRendererView(context)
            surfaceView.setZOrderMediaOverlay(false)
            remoteFullScreenVideoView!!.addView(
                surfaceView
            )
            conversationFragmentCallback!!.setupRemoteVideo(surfaceView)
            initCorrectSizeForLocalView()
          //  initCorrectSizeForRemoteView()
        }
    }

    private fun addLocalVideoView() {
        val surfaceView = RtcEngine.CreateRendererView(context)
        if (localVideoView.childCount > 0) {
            localVideoView.removeAllViews()
        }
        surfaceView.setZOrderMediaOverlay(true)
        localVideoView.addView(
            surfaceView,
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        )
        conversationFragmentCallback?.setupLocalVideo(surfaceView)

    }

    private fun initCorrectSizeForLocalView() {

        val params: RelativeLayout.LayoutParams = RelativeLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT
        )
        params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, RelativeLayout.TRUE)
        params.addRule(RelativeLayout.ALIGN_PARENT_RIGHT, RelativeLayout.TRUE)
        params.setMargins(0,0,resources.getDimension(R.dimen.margin_common).toInt(),resources.getDimension(R.dimen.margin_common).toInt())

        val displaymetrics = resources.displayMetrics

        val screenWidthPx = displaymetrics.widthPixels
        val width = (screenWidthPx * 0.3).toInt()
        val height = width / 2 * 3
        params.width = width
        params.height = height
        localVideoView.layoutParams = params

    }

    private fun initCorrectSizeForRemoteView(width:Int,height: Int) {

        val params: RelativeLayout.LayoutParams = RelativeLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT
        )
         params.addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE)

          params.width = width
          params.height = height
        if(remoteFullScreenVideoView!=null)
        remoteFullScreenVideoView!!.layoutParams = params
    }


    private fun defineSize(measuredWidth: Int, columnsCount: Int, padding: Float): Int {
        return measuredWidth / columnsCount - (padding * 2).toInt() - RECYCLE_VIEW_PADDING
    }

    private fun defineColumnsCount(): Int {
        return 1
    }

    override fun onPause() {
        //   toggleCamera(false)
        if (connectionEstablished) {
            allCallbacksInit = false
        } else {
            Log.d(TAG, "We are in dialing process yet!")
        }
        removeListeners()
 //       releaseViews()

        super.onPause()
    }

    override fun onDetach() {
        super.onDetach()
        Log.d(TAG, "onDetach")
    }


    private fun releaseViews() {
        localVideoView
        remoteFullScreenVideoView
        remoteFullScreenVideoView = null
    }

    override fun onCallStopped() {
        super.onCallStopped()
        CallService.stop(activity as Activity)
        Log.i(TAG, "onCallStopped")
    }


    override fun initButtonsListener() {
        super.initButtonsListener()

        cameraToggle.setOnCheckedChangeListener { _, isChecked ->
            SharedPrefsHelper.save(CAMERA_ENABLED, isChecked)
            toggleCamera(isChecked)
        }
        audioSwitchToggleButton.setOnCheckedChangeListener { _, isChecked ->
            SharedPrefsHelper.save(SPEAKER_ENABLED, isChecked)
            conversationFragmentCallback?.onSwitchAudio()
        }
    }

    private fun switchCamera(item: MenuItem?) {
        conversationFragmentCallback?.onSwitchCamera()
        isCurrentCameraFront = !isCurrentCameraFront
        SharedPrefsHelper.save(IS_CURRENT_CAMERA_FRONT, isCurrentCameraFront)
        if (item != null) {
            updateSwitchCameraIcon(item)
        } else {
            optionsMenu?.findItem(R.id.camera_switch)?.setIcon(R.drawable.ic_camera_rear)
        }

    }

    private fun screenShare(item: MenuItem?) {
        isScreenShare = !isScreenShare
        SharedPrefsHelper.save(IS_SCREEN_SHARE, isScreenShare)
        conversationFragmentCallback?.onStartScreenSharing(isScreenShare)
        if (item != null) {
            updateScreenShareIcon(item)
        } else {
            optionsMenu?.findItem(R.id.screen_share)?.setIcon(R.drawable.ic_screen_share)
        }

    }

    private fun updateScreenShareIcon(item: MenuItem) {
        if (isScreenShare) {
            item.setIcon(R.drawable.ic_stop_screenshare)
        } else {
            item.setIcon(R.drawable.ic_screen_share)
        }
    }

    private fun updateSwitchCameraIcon(item: MenuItem) {
        if (isCurrentCameraFront) {
            item.setIcon(R.drawable.ic_camera_front)
        } else {
            item.setIcon(R.drawable.ic_camera_rear)
        }
    }



    private fun toggleCamera(isNeedEnableCam: Boolean) {
        if (conversationFragmentCallback?.isMediaStreamManagerExist() == true) {
            conversationFragmentCallback?.onSetVideoEnabled(isNeedEnableCam)
        }
    }


    override fun onCreateOptionsMenu(menu: Menu, inflater: MenuInflater) {
        inflater.inflate(R.menu.conversation_fragment, menu)
        super.onCreateOptionsMenu(menu, inflater)
        optionsMenu = menu
        optionsMenu?.findItem(R.id.camera_switch)?.isVisible = true
        showHideMenuItem(false)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.camera_switch -> {
                switchCamera(item)
                true
            }
            R.id.screen_share -> {
                screenShare(item)
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun showHideMenuItem(isShow:Boolean){
        if(isShow){
            optionsMenu?.findItem(R.id.screen_share)?.isVisible = true
            optionsMenu?.findItem(R.id.whiteBoard)?.isVisible = true
        }else{
            optionsMenu?.findItem(R.id.screen_share)?.isVisible = false
            optionsMenu?.findItem(R.id.whiteBoard)?.isVisible = false
        }

    }


    override fun onCallTimeUpdate(time: String) {
        timerCallText.text = time
    }

    override fun onLocalUserJoined(localUserId: Int) {
        addLocalVideoView()
    }

    override fun onRemoteUserJoined(remoteUserId: Int) {
        addRemoteVideoView()
        connectionEstablished = true
        showHideMenuItem(true)
    }

    override fun onVideoSizeChanged(uid: Int, width: Int, height: Int, rotation: Int) {
        initCorrectSizeForRemoteView(width,height)
    }

    override fun remoteUserStartedScreenShare(isScreenShareStarted: Boolean) {

    }


    internal inner class LocalViewOnClickListener : View.OnClickListener {
        private var lastFullScreenClickTime = 0L

        override fun onClick(v: View) {
            if (SystemClock.uptimeMillis() - lastFullScreenClickTime < FULL_SCREEN_CLICK_DELAY) {
                return
            }
            lastFullScreenClickTime = SystemClock.uptimeMillis()

            if (connectionEstablished) {
                setFullScreenOnOff()
            }
        }

        private fun setFullScreenOnOff() {
            if (actionBar.isShowing) {
                hideToolBarAndButtons()
            } else {
                showToolBarAndButtons()
            }
        }

        private fun hideToolBarAndButtons() {
            actionBar.hide()
          //  localVideoView.visibility = View.INVISIBLE
            actionVideoButtonsLayout.visibility = View.GONE
            if (!isPeerToPeerCall) {
                shiftBottomListOpponents()
            }
        }

        private fun showToolBarAndButtons() {
            actionBar.show()
        //    localVideoView.visibility = View.VISIBLE
            actionVideoButtonsLayout.visibility = View.VISIBLE
            if (!isPeerToPeerCall) {
                shiftMarginListOpponents()
            }
        }

        private fun shiftBottomListOpponents() {
            val params = recyclerView.layoutParams as RelativeLayout.LayoutParams
            params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM)
            params.setMargins(0, 0, 0, 0)

            recyclerView.layoutParams = params
        }

        private fun shiftMarginListOpponents() {
            val params = recyclerView.layoutParams as RelativeLayout.LayoutParams
            params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, 0)
            params.setMargins(0, 0, 0, resources.getDimension(R.dimen.margin_common).toInt())

            recyclerView.layoutParams = params
        }
    }


    var pressedX :Int=0
    var pressedY:Int=0
    @SuppressLint("ClickableViewAccessibility")
    val mOnTouchListener: View.OnTouchListener = View.OnTouchListener { v, event ->
        val relativeLayoutParams = v.layoutParams as RelativeLayout.LayoutParams

        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                // Where the user started the drag
                pressedX = event.rawX.toInt()
                pressedY = event.rawY.toInt()
            }
            MotionEvent.ACTION_MOVE -> {
                // Where the user's finger is during the drag
                val x = event.rawX.toInt()
                val y = event.rawY.toInt()

                // Calculate change in x and change in y
                val dx: Int = x - pressedX
                val dy: Int = y - pressedY

                // Update the margins
                relativeLayoutParams.leftMargin += dx
                relativeLayoutParams.topMargin += dy
                v.layoutParams = relativeLayoutParams

                // Save where the user's finger was for the next ACTION_MOVE
                pressedX = x
                pressedY = y
            }
            MotionEvent.ACTION_UP -> Log.d("TAG", "@@@@ TV1 ACTION_UP")
        }
        true
    }


}