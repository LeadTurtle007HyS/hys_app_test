package com.sparrowrms.hyspro.ui.fragment

import android.app.Activity
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.TextView
import android.widget.ToggleButton
import com.bumptech.glide.Glide
import com.sparrowrms.hyspro.Constants.*
import com.sparrowrms.hyspro.R
import com.sparrowrms.hyspro.model.datasourcemodel.UserDetailsModel
import com.sparrowrms.hyspro.services.CallService
import com.sparrowrms.hyspro.ui.activity.CallActivity
import com.sparrowrms.hyspro.util.SharedPrefsHelper

abstract  class BaseConversationFragment : BaseToolBarFragment(),
    CallActivity.CurrentCallStateCallback {

    private var isIncomingCall: Boolean = false
    protected lateinit var timerCallText: TextView
    protected var conversationFragmentCallback: ConversationFragmentCallback? = null
    protected lateinit var currentUser: UserDetailsModel
    protected lateinit var opponents: UserDetailsModel
    private var isStarted: Boolean = false

    private lateinit var micToggleVideoCall: ToggleButton
    private lateinit var handUpVideoCall: ImageButton
    protected lateinit var outgoingOpponentsRelativeLayout: View
    protected lateinit var allOpponentsTextView: TextView
    protected lateinit var ringingTextView: TextView
    private lateinit var image_calling_avatar:ImageView

    protected var handler: Handler? = null

    companion object {
        fun newInstance(baseConversationFragment: BaseConversationFragment, isIncomingCall: Boolean,userDetailsModel: UserDetailsModel): BaseConversationFragment {
            val args = Bundle()
            args.putBoolean(EXTRA_IS_INCOMING_CALL, isIncomingCall)
            args.putParcelable(userDetailsKey,userDetailsModel)
            baseConversationFragment.arguments = args
            return baseConversationFragment
        }
    }

    override fun onAttach(activity: Activity) {
        super.onAttach(activity)
        try {
            conversationFragmentCallback = context as ConversationFragmentCallback
        } catch (e: ClassCastException) {
            throw ClassCastException("$activity must implement ConversationFragmentCallback")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        conversationFragmentCallback?.addCurrentCallStateListener(this)
        handler=Handler(Looper.getMainLooper())
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val view = super.onCreateView(inflater, container, savedInstanceState)

        initFields()
        initViews(view)
        initActionBar()
        initButtonsListener()
        prepareAndShowOutgoingScreen()

        return view
    }

    private fun initActionBar() {
        configureToolbar()
        configureActionBar()
    }

    protected abstract fun configureActionBar()

    protected abstract fun configureToolbar()

    private fun prepareAndShowOutgoingScreen() {
        configureOutgoingScreen()
        Glide.with(this).load(opponents.profilepic)
            .into(image_calling_avatar)
        allOpponentsTextView.text = opponents.firstname+" "+opponents.lastname

    }




    protected abstract fun configureOutgoingScreen()

    protected open fun initFields() {


        arguments?.let {
            isIncomingCall = it.getBoolean(EXTRA_IS_INCOMING_CALL, false)
            opponents=it.getParcelable(userDetailsKey)!!
        }
        initOpponentsList()
    }

    override fun onStart() {
        super.onStart()
        if (isIncomingCall) {
            conversationFragmentCallback?.acceptCall(HashMap())
        } else {
            conversationFragmentCallback?.startCall(HashMap())
        }
    }

    override fun onDestroy() {
        conversationFragmentCallback?.removeCurrentCallStateListener(this)
        super.onDestroy()
    }

    protected open fun initViews(view: View?) {
        micToggleVideoCall = view?.findViewById<View>(R.id.toggle_mic) as ToggleButton
        micToggleVideoCall.isChecked = SharedPrefsHelper.get(MIC_ENABLED, true)
        handUpVideoCall = view.findViewById<View>(R.id.button_hangup_call) as ImageButton
        outgoingOpponentsRelativeLayout = view.findViewById(R.id.layout_background_outgoing_screen)
        allOpponentsTextView = view.findViewById<View>(R.id.text_outgoing_opponents_names) as TextView
        ringingTextView = view.findViewById<View>(R.id.text_ringing) as TextView
        image_calling_avatar=view.findViewById(R.id.image_calling_avatar) as ImageView

        if (isIncomingCall) {
            hideOutgoingScreen()
        }
    }

    protected open fun initButtonsListener() {
        micToggleVideoCall.setOnCheckedChangeListener { buttonView, isChecked ->
            SharedPrefsHelper.save(MIC_ENABLED, isChecked)
            conversationFragmentCallback?.onSetAudioEnabled(isChecked)
        }

        handUpVideoCall.setOnClickListener {
            actionButtonsEnabled(false)
            handUpVideoCall.isEnabled = false
            handUpVideoCall.isActivated = false
            CallService.stop(activity as Activity)
            conversationFragmentCallback?.onHangUpCurrentSession()

        }
    }

    private fun clearButtonsState() {
        SharedPrefsHelper.delete(MIC_ENABLED)
        SharedPrefsHelper.delete(SPEAKER_ENABLED)
        SharedPrefsHelper.delete(CAMERA_ENABLED)
    }

    protected open fun actionButtonsEnabled(inability: Boolean) {
        micToggleVideoCall.isEnabled = inability
        micToggleVideoCall.isActivated = inability
    }



    private fun startTimer() {
        if (!isStarted) {
            timerCallText.visibility = View.VISIBLE
            isStarted = true
        }
    }

    private fun hideOutgoingScreen() {
        outgoingOpponentsRelativeLayout.visibility = View.GONE
    }

    override fun onCallStarted() {
        hideOutgoingScreen()
        startTimer()
        actionButtonsEnabled(true)
    }

    override fun onCallStopped() {
        CallService.stop(activity as Activity)
        isStarted = false
        clearButtonsState()
        actionButtonsEnabled(false)
    }



    private fun initOpponentsList() {

    }






}