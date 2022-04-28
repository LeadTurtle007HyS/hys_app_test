package com.sparrowrms.hyspro.util;

import android.app.Notification;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import com.sparrowrms.hyspro.R;
import com.sparrowrms.hyspro.model.datasourcemodel.UserDetailsModel;
import com.sparrowrms.hyspro.services.NotificationActionService;
import com.sparrowrms.hyspro.ui.activity.CallActivity;



public class CreateNotification {


    public static final String ACTION_ACCEPT_CALL = "action_accept_call";
    public static final String ACTION_DECLINE_CALL= "action_decline_call";
    public static final String ACTION_HANGUP_SESSION = "action_hangup_current_session";
    public static final String ACTION_CLOSE_NOTIFICATION = "close_notification";

    public static Notification createCallNotification(Context context, UserDetailsModel userDetailsModel, boolean isIncoming, boolean isVideo, boolean callState, String channel,String callTime){
        PendingIntent pendingIntentAcceptSession;
        Intent openActivityIntent = new Intent(context, CallActivity.class);
        PendingIntent conPendingIntent = PendingIntent.getActivity(context,0,openActivityIntent,PendingIntent.FLAG_UPDATE_CURRENT);

        Intent intentAcceptSession = new Intent(context, NotificationActionService.class)
                .setAction(ACTION_ACCEPT_CALL);
        pendingIntentAcceptSession = PendingIntent.getBroadcast(context, 0,
                intentAcceptSession, PendingIntent.FLAG_UPDATE_CURRENT);

        Intent intentDeclineSession = new Intent(context, NotificationActionService.class)
                .setAction(ACTION_DECLINE_CALL);
        PendingIntent pendingIntentDeclineSession = PendingIntent.getBroadcast(context, 0,
                intentDeclineSession, PendingIntent.FLAG_UPDATE_CURRENT);


        Intent hangupSessionIntent = new Intent(context, NotificationActionService.class)
                .setAction(ACTION_HANGUP_SESSION);
        PendingIntent pendingIntentClose = PendingIntent.getBroadcast(context, 0,
                hangupSessionIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        String notificationText;
       if(!callState && isIncoming) {
           notificationText=isVideo?"Incoming video call":"Incoming voice call";
       }else if(callState && isIncoming){
           notificationText=isVideo?"Ongoing video call":"Ongoing voice call";
       }else if(callState){
           notificationText=isVideo?"Ongoing video call":"Ongoing voice call";
       }else{
           notificationText="Calling";
       }


       StringBuilder title=new StringBuilder(userDetailsModel.getFirstname()+" "+userDetailsModel.getLastname());
        if (!TextUtils.isEmpty(callTime)) {
            title = title.append("       ").append(callTime);
        }

        NotificationCompat.BigTextStyle bigTextStyle = new NotificationCompat.BigTextStyle();
        bigTextStyle.setBigContentTitle(title);
        bigTextStyle.bigText(notificationText);

        // Create a new Notification
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(context,channel)
                .setShowWhen(true)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setStyle(bigTextStyle)
                .setColor(context.getResources().getColor(R.color.colorPrimary))
                .setSmallIcon(android.R.drawable.ic_menu_call)
                // Set Notification content information
                .setContentText(notificationText)
                .setContentTitle(title)
                .setContentInfo(notificationText)
                .setOngoing(true)
                .setContentIntent(conPendingIntent)
                .setPriority(Notification.PRIORITY_HIGH)
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setFullScreenIntent(conPendingIntent, true)
                .setOngoing(true)
                .setWhen(System.currentTimeMillis());
        // Add playback actions
        if(callState){
            notificationBuilder.addAction(0,"Hangup",pendingIntentClose);
        }else if(isIncoming){
            notificationBuilder.addAction(0,"Accept",pendingIntentAcceptSession);
            notificationBuilder.addAction(0,"Decline",pendingIntentDeclineSession);
        }else{
            notificationBuilder.addAction(0,"Hangup",pendingIntentClose);
        }

//        NotificationManagerCompat notificationManagerCompat = NotificationManagerCompat.from(context);
//        notificationManagerCompat.notify(1, notificationBuilder.build());

        return notificationBuilder.build();
    }

    public static void cancelNotifications(Context context) {
        NotificationManagerCompat notificationManagerCompat = NotificationManagerCompat.from(context);
        notificationManagerCompat.cancelAll();
    }

}
