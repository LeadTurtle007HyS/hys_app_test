package com.sparrowrms.hyspro.services

import android.annotation.SuppressLint
import android.content.Intent
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.sparrowrms.hyspro.Constants.EXTRA_NOTIFICATION_BUTTON_ACTION_DATA
import com.sparrowrms.hyspro.Constants.EXTRA_NOTIFICATION_SCREEN_SHARE_ACTION
import com.sparrowrms.hyspro.dataSource.remote.FirebaseAuthSource
import com.sparrowrms.hyspro.dataSource.remote.FirebaseDataSource
import com.sparrowrms.hyspro.model.dataclasses.CallingUserNotificationDetails
import com.sparrowrms.hyspro.ui.activity.CallActivity
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers


class FirebaseCloudMessagingService : FirebaseMessagingService() {
    override fun onNewToken(token: String) {
        val firebaseAuthSource = FirebaseAuthSource()
        if (firebaseAuthSource.currentUser != null) {
            val currentUserID = firebaseAuthSource.currentUid
            if (currentUserID != null) {
                firebaseAuthSource.updateUserTokenData(currentUserID, token)
            }
        }

    }

    companion object {
        private const val TAG = "MyFirebaseMsgService"
    }


    override fun onMessageReceived(remoteMessage: RemoteMessage) {

        super.onMessageReceived(remoteMessage)

        remoteMessage.data.let {
            val myObject = remoteMessage.data

            val notificationtype = myObject["notificationtype"]

            if(notificationtype=="screen_share"){
                val isScreenShareStarted=myObject["isScreenShareStarted"]
                sendBroadcast( Intent(EXTRA_NOTIFICATION_SCREEN_SHARE_ACTION)
                    .putExtra(EXTRA_NOTIFICATION_BUTTON_ACTION_DATA, isScreenShareStarted));

            }else{
                val answerpreference = myObject["answerpreference"]
                val channelid = myObject["channelid"]
                val comparedate = myObject["comparedate"]
                val message = myObject["message"]
                val notificationid = myObject["notificationid"]
                val createdate = myObject["createdate"]
                val questionid = myObject["questionid"]
                val receiverid = myObject["receiverid"]
                val receivername = myObject["receivername"]
                val senderid = myObject["senderid"]
                val sendername = myObject["sendername"]
                val token = myObject["token"]
                val callingUserNotificationDetails = CallingUserNotificationDetails(
                    answerpreference,
                    channelid,
                    comparedate,
                    message,
                    notificationid,
                    createdate,
                    notificationtype,
                    questionid,
                    receiverid,
                    receivername,
                    senderid,
                    sendername,
                    token
                )
                if(senderid!="null" && channelid!=null){
                    getUserDetails(senderid!!,callingUserNotificationDetails)
                }
            }


            
        }

    }




    private fun sendRegistrationToServer(token: String?) {


    }


    @SuppressLint("CheckResult")
    private fun getUserDetails(id: String,callingUserNotificationDetails:CallingUserNotificationDetails) {
        FirebaseDataSource().getUserUsingID(id).subscribeOn(Schedulers.io()).observeOn(
            AndroidSchedulers.mainThread()
        ).subscribe({
            if(callingUserNotificationDetails.answerpreference!! == "2")
               CallActivity.start(applicationContext,true,it,true,callingUserNotificationDetails)
            else
                CallActivity.start(applicationContext,true,it,false,callingUserNotificationDetails)

        }, {
           var error=it.localizedMessage

        })

    }



}