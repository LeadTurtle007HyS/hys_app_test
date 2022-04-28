package com.sparrowrms.hyspro.ui.fragment

import android.view.SurfaceView
import com.sparrowrms.hyspro.ui.activity.CallActivity
import io.agora.rtc.video.VideoEncoderConfiguration
import io.agora.rtc.video.WatermarkOptions

interface ConversationFragmentCallback {


    fun onSetAudioEnabled(isAudioEnabled: Boolean)

    fun onSetVideoEnabled(isNeedEnableCam: Boolean)

    fun onSwitchAudio()

    fun onSwitchCamera()

    fun onHangUpCurrentSession()

    fun onStartScreenSharing(isScreenShare:Boolean)

    fun acceptCall(userInfo: Map<String, String>)

    fun startCall(userInfo: Map<String, String>)

    fun currentSessionExist(): Boolean

    fun getOpponents(): List<Int>?

    fun getCallerId(): Int?

    fun addCurrentCallStateListener(currentCallStateCallback: CallActivity.CurrentCallStateCallback?)

    fun removeCurrentCallStateListener(currentCallStateCallback: CallActivity.CurrentCallStateCallback?)

    fun isMediaStreamManagerExist(): Boolean

    fun isCallState(): Boolean

    fun setupLocalVideo(surfaceView: SurfaceView)

    fun setupRemoteVideo(surfaceView: SurfaceView?)

    fun enableVideo()

    fun disableVideo()

    fun setVideoEncoderConfiguration(videoEncoderConfiguration: VideoEncoderConfiguration)

    fun setDefaultAudioRoutetoSpeakerphone()

    fun setVideoWaterMark(watermarkOptions: WatermarkOptions)

    fun openWhiteBoard()


}