package com.sparrowrms.hyspro.ui.fragment

import android.content.Context
import android.os.Bundle
import android.os.SystemClock
import android.view.*
import android.widget.*
import androidx.core.content.ContextCompat
import com.bumptech.glide.Glide
import com.sparrowrms.hyspro.R
import com.sparrowrms.hyspro.util.SharedPrefsHelper
import io.agora.rtc.RtcEngine


const val SPEAKER_ENABLED = "is_speaker_enabled"
private const val FULL_SCREEN_CLICK_DELAY: Long = 1000


class AudioConversationFragment : BaseConversationFragment() {

    private lateinit var audioSwitchToggleButton: ToggleButton
    private lateinit var alsoOnCallText: TextView
    private lateinit var firstOpponentNameTextView: TextView
    private lateinit var otherOpponentsTextView: TextView
    private lateinit var localViewOnClickListener: LocalViewOnClickListener
    private var remoteFullScreenVideoView: FrameLayout? = null
    private var connectionEstablished: Boolean = false
    private lateinit var actionVideoButtonsLayout: LinearLayout
    private lateinit var layoutInfoAboutCall:LinearLayout
    private var optionsMenu: Menu? = null
    private var isScreenShare: Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setHasOptionsMenu(true)
    }

    override fun onCreateOptionsMenu(menu: Menu, inflater: MenuInflater) {
        inflater.inflate(R.menu.conversation_fragment, menu)
        super.onCreateOptionsMenu(menu, inflater)
        optionsMenu = menu
        optionsMenu?.findItem(R.id.camera_switch)?.isVisible = false
        optionsMenu?.findItem(R.id.screen_share)?.isVisible = false
        optionsMenu?.findItem(R.id.whiteBoard)?.isVisible = false
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.screen_share -> {
                screenShare(item)
                true
            }
            R.id.whiteBoard -> {
                conversationFragmentCallback!!.openWhiteBoard()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun screenShare(item: MenuItem?) {
        isScreenShare = !isScreenShare
        if (isScreenShare) {
            conversationFragmentCallback?.enableVideo()
        } else {
            conversationFragmentCallback?.disableVideo()
        }
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

    override fun configureOutgoingScreen() {
        val context: Context = activity as Context
        outgoingOpponentsRelativeLayout.setBackgroundColor(
            ContextCompat.getColor(
                context,
                R.color.white
            )
        )

    }

    override fun configureToolbar() {
        val context: Context = activity as Context
        toolbar.visibility = View.VISIBLE
        toolbar.setBackgroundColor(ContextCompat.getColor(context, R.color.transparent_black))

    }

    override fun configureActionBar() {
        actionBar.hide()
    }

    override fun initFields() {
        super.initFields()

        localViewOnClickListener = LocalViewOnClickListener()
    }

    override fun initViews(view: View?) {
        super.initViews(view)
        if (view == null) {
            return
        }
        timerCallText = view.findViewById(R.id.timer_call)
        layoutInfoAboutCall=view.findViewById(R.id.layout_info_about_call)
        remoteFullScreenVideoView = view.findViewById(R.id.remote_video_view)
        remoteFullScreenVideoView?.setOnClickListener(localViewOnClickListener)

        val firstOpponentAvatarImageView = view.findViewById<ImageView>(R.id.image_caller_avatar)
        alsoOnCallText = view.findViewById(R.id.text_also_on_call)
        setVisibilityAlsoOnCallTextView()

        Glide.with(firstOpponentAvatarImageView).load(opponents.profilepic)
            .into(firstOpponentAvatarImageView)

        firstOpponentNameTextView = view.findViewById(R.id.text_caller_name)
        firstOpponentNameTextView.text = opponents.firstname + " " + opponents.lastname

        otherOpponentsTextView = view.findViewById(R.id.text_other_inc_users)
        // otherOpponentsTextView.text = getOtherOpponentsNames()

        audioSwitchToggleButton = view.findViewById(R.id.toggle_speaker)
        audioSwitchToggleButton.visibility = View.VISIBLE
        audioSwitchToggleButton.isChecked = SharedPrefsHelper[SPEAKER_ENABLED, true]
        actionButtonsEnabled(false)

        if (conversationFragmentCallback?.isCallState() == true) {
            onCallStarted()
        }

        actionVideoButtonsLayout = view.findViewById(R.id.element_set_video_buttons)
    }

    private fun setVisibilityAlsoOnCallTextView() {

    }


    override fun initButtonsListener() {
        super.initButtonsListener()
        audioSwitchToggleButton.setOnCheckedChangeListener { _, isChecked ->
            SharedPrefsHelper.save(SPEAKER_ENABLED, isChecked)
            conversationFragmentCallback?.onSwitchAudio()
        }
    }

    override fun actionButtonsEnabled(inability: Boolean) {
        super.actionButtonsEnabled(inability)
        audioSwitchToggleButton.isActivated = inability
    }

    override fun getFragmentLayout(): Int {
        return R.layout.fragment_audio_conversation
    }


    override fun onCallTimeUpdate(time: String) {
        timerCallText.text = time
    }

    override fun onLocalUserJoined(localUserId: Int) {

    }

    override fun onRemoteUserJoined(remoteUserId: Int) {
        connectionEstablished = true
        showHideMenuItem(true)
    }

    override fun onVideoSizeChanged(uid: Int, width: Int, height: Int, rotation: Int) {
        initCorrectSizeForRemoteView(width,height)
    }

    override fun remoteUserStartedScreenShare(isScreenShareStarted: Boolean) {
        if (isScreenShareStarted) {
            screenShareShow()
        } else {
            screenShareHide()
        }
    }



    private fun screenShareHide() {
        conversationFragmentCallback!!.disableVideo()
        removeRemoteVideoView()
        remoteFullScreenVideoView!!.visibility = View.GONE
        if(::layoutInfoAboutCall.isInitialized){
            layoutInfoAboutCall.visibility=View.VISIBLE
        }
    }

    private fun initCorrectSizeForRemoteView(width:Int,height: Int) {

        val params: RelativeLayout.LayoutParams = RelativeLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT
        )
        params.addRule(RelativeLayout.CENTER_IN_PARENT, RelativeLayout.TRUE)

        params.width = width+50
        params.height = height+50
        if(remoteFullScreenVideoView!=null)
            remoteFullScreenVideoView!!.layoutParams = params
    }

    private fun screenShareShow() {
        conversationFragmentCallback!!.enableVideo()
        addRemoteVideoView()
        remoteFullScreenVideoView!!.visibility = View.VISIBLE
        if(::layoutInfoAboutCall.isInitialized){
            layoutInfoAboutCall.visibility=View.GONE
        }
    }
    private fun showHideMenuItem(isShow:Boolean){
        if(isShow){
            actionBar.show()
            optionsMenu?.findItem(R.id.screen_share)?.isVisible = true
            optionsMenu?.findItem(R.id.whiteBoard)?.isVisible = true
        }else{
            actionBar.hide()
            optionsMenu?.findItem(R.id.screen_share)?.isVisible = false
            optionsMenu?.findItem(R.id.whiteBoard)?.isVisible = false
        }

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
            actionVideoButtonsLayout.visibility = View.GONE
        }

        private fun showToolBarAndButtons() {
            actionBar.show()
            //    localVideoView.visibility = View.VISIBLE
            actionVideoButtonsLayout.visibility = View.VISIBLE

        }

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
            //  initCorrectSizeForRemoteView()
        }
    }
    private fun removeRemoteVideoView() {
       conversationFragmentCallback!!.setupRemoteVideo(null)
    }

}