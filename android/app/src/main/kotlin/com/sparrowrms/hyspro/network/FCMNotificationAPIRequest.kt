package com.sparrowrms.hyspro.network

import com.sparrowrms.hyspro.model.dataclasses.CallingUserNotificationDetails
import com.sparrowrms.hyspro.model.dataclasses.SendNotificationModel
import com.squareup.okhttp.ResponseBody
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.Headers

import retrofit2.http.POST




interface FCMNotificationAPIRequest {


    @Headers(
            "Authorization: key=AAAAqaWaBPY:APA91bHQAvw_ld3ulPKtYDICkrOL0bwB0cs3wqak5zfj0n558nYM_qUvA4P_L4dZqAz3Wk2oxnWVnQjmyisYMAz2t9oDmoo_xj0ocMAg8_gzamFlNHf2OffzMuFrW_RhffxKTiAYgjyy",
            "Content-Type:application/json"
    )
    @POST("fcm/send")
    fun sendChatNotification(@Body requestNotification: SendNotificationModel?): Call<ResponseBody?>?

}