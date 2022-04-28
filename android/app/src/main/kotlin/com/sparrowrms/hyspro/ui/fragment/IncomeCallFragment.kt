package com.sparrowrms.hyspro.ui.fragment

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.os.SystemClock
import android.os.Vibrator
import android.text.TextUtils
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.TextView
import androidx.fragment.app.Fragment
import com.bumptech.glide.Glide
import com.sparrowrms.hyspro.Constants
import com.sparrowrms.hyspro.R
import com.sparrowrms.hyspro.model.datasourcemodel.UserDetailsModel
import com.sparrowrms.hyspro.util.RingtonePlayer
import java.io.Serializable
import java.util.concurrent.TimeUnit

private const val PER_PAGE_SIZE_100 = 100
private const val ORDER_RULE = "order"
private const val ORDER_DESC_UPDATED = "desc string updated_at"

class IncomeCallFragment : Fragment(), Serializable, View.OnClickListener {
    private val TAG = IncomeCallFragment::class.java.simpleName
    private val CLICK_DELAY = TimeUnit.SECONDS.toMillis(2)

    //Views
    private lateinit var callTypeTextView: TextView
    private lateinit var rejectButton: ImageButton
    private lateinit var takeButton: ImageButton
    private lateinit var alsoOnCallText: TextView
    private lateinit var progressUserName: ProgressBar
    private lateinit var callerNameTextView: TextView

    private var opponentsIds: List<Int>? = null
    private var vibrator: Vibrator? = null
    private var lastClickTime = 0L
    private lateinit var ringtonePlayer: RingtonePlayer
    private lateinit var incomeCallFragmentCallbackListener: IncomeCallFragmentCallbackListener


    private lateinit var opponentUserDetailsModel: UserDetailsModel
    private var isVideoCall: Boolean = false


    companion object {
        fun newInstance(
            incomeCallFragment: IncomeCallFragment,
            isVideo: Boolean,
            opponentUserDetailsModel: UserDetailsModel
        ): IncomeCallFragment {
            val args = Bundle()
            args.putBoolean(Constants.EXTRA_IS_VIDEO_CALL, isVideo)
            args.putParcelable(Constants.userDetailsKey, opponentUserDetailsModel)
            incomeCallFragment.arguments = args
            return incomeCallFragment
        }
    }

    override fun onAttach(activity: Activity) {
        super.onAttach(activity)
        try {
            incomeCallFragmentCallbackListener = activity as IncomeCallFragmentCallbackListener
        } catch (e: ClassCastException) {
            throw ClassCastException(activity.toString() + " must implement OnCallEventsController")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        retainInstance = true

        Log.d(TAG, "onCreate() from IncomeCallFragment")
        super.onCreate(savedInstanceState)
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.fragment_income_call, container, false)

        initFields()
        hideToolBar()
        initUI(view)
        setDisplayedTypeCall(isVideoCall)
        initButtonsListener()
        val context = activity as Context
        ringtonePlayer = RingtonePlayer(context)
        return view
    }

    private fun initFields() {

        arguments?.let {
            isVideoCall = it.getBoolean(Constants.EXTRA_IS_VIDEO_CALL, false)
            opponentUserDetailsModel = it.getParcelable(Constants.userDetailsKey)!!
        }

    }

    private fun hideToolBar() {
        val toolbar = activity?.findViewById<View>(R.id.toolbar_call)
        toolbar?.visibility = View.GONE
    }

    override fun onStart() {
        super.onStart()
        startCallNotification()
    }

    private fun initButtonsListener() {
        rejectButton.setOnClickListener(this)
        takeButton.setOnClickListener(this)
    }

    private fun initUI(view: View) {
        callTypeTextView = view.findViewById(R.id.call_type)
        val callerAvatarImageView = view.findViewById<ImageView>(R.id.image_caller_avatar)
        callerNameTextView = view.findViewById(R.id.text_caller_name)
        val otherIncUsersTextView = view.findViewById<TextView>(R.id.text_other_inc_users)
        progressUserName = view.findViewById(R.id.progress_bar_opponent_name)
        alsoOnCallText = view.findViewById(R.id.text_also_on_call)
        rejectButton = view.findViewById(R.id.image_button_reject_call)
        takeButton = view.findViewById(R.id.image_button_accept_call)


        Glide.with(callerAvatarImageView).load(opponentUserDetailsModel.profilepic)
            .into(callerAvatarImageView)

        if (!TextUtils.isEmpty(opponentUserDetailsModel.firstname+" "+opponentUserDetailsModel.lastname)) {
            callerNameTextView.text = opponentUserDetailsModel.firstname+" "+opponentUserDetailsModel.lastname
        }



        setVisibilityAlsoOnCallTextView()
    }


    private fun setVisibilityAlsoOnCallTextView() {
        opponentsIds?.let {
            if (it.size < 2) {
                alsoOnCallText.visibility = View.INVISIBLE
            }
        }
    }

//    private fun getBackgroundForCallerAvatar(callerId: Int): Drawable {
//       // return getColorCircleDrawable(callerId)
//    }

    private fun startCallNotification() {
        Log.d(TAG, "startCallNotification()")
        ringtonePlayer.play(false)
        vibrator = activity?.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator?
        val vibrationCycle = longArrayOf(0, 1000, 1000)
        vibrator?.hasVibrator()?.let {
            vibrator?.vibrate(vibrationCycle, 1)
        }
    }

    private fun stopCallNotification() {
        Log.d(TAG, "stopCallNotification()")

        ringtonePlayer.stop()
        vibrator?.cancel()
    }


    private fun setDisplayedTypeCall(isVideoCall: Boolean) {


        val callType = if (isVideoCall) {
            "Incoming Video Call"
        } else {
            "Incoming audio call"
        }
        callTypeTextView.text = callType

        val imageResource = if (isVideoCall) {
            R.drawable.ic_video_white
        } else {
            R.drawable.ic_call
        }
        takeButton.setImageResource(imageResource)
    }

    override fun onStop() {
        stopCallNotification()
        super.onStop()
    }

    override fun onClick(v: View) {
        if (SystemClock.uptimeMillis() - lastClickTime < CLICK_DELAY) {
            return
        }
        lastClickTime = SystemClock.uptimeMillis()

        when (v.id) {
            R.id.image_button_reject_call -> reject()
            R.id.image_button_accept_call -> accept()
            else -> {
            }
        }
    }

    private fun accept() {
        enableButtons(false)
        stopCallNotification()
        incomeCallFragmentCallbackListener.onAcceptCurrentSession()

    }

    private fun reject() {
        enableButtons(false)
        stopCallNotification()
        incomeCallFragmentCallbackListener.onRejectCurrentSession()
    }

    private fun enableButtons(enable: Boolean) {
        takeButton.isEnabled = enable
        rejectButton.isEnabled = enable
    }
}