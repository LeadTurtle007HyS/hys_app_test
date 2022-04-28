package com.sparrowrms.hyspro.model.dataclasses

import java.io.Serializable

data class SendNotificationModel(var to:String, val data:CallingUserNotificationDetails) : Serializable
