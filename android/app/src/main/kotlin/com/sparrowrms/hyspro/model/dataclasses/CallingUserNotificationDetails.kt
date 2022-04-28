package com.sparrowrms.hyspro.model.dataclasses

import android.os.Parcelable
import kotlinx.android.parcel.Parcelize

@Parcelize
data class CallingUserNotificationDetails   (
    val answerpreference: String? = null,
    val channelid: String? = null,
    val comparedate: String? = null,
    val message: String? = null,
    val notificationid: String? = null,
    val createdate: String? = null,
    var notificationtype: String? = null,
    val questionid: String? = null,
    val receiverid: String? = null,
    val receivername: String? = null,
    val senderid: String? = null,
    val sendername: String? = null,
    var token: String? = null,
    var isScreenShareStarted:String?=null

    ) : Parcelable