package com.sparrowrms.hyspro.util

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ClipData
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.sparrowrms.hyspro.MainActivity
import com.sparrowrms.hyspro.R


object Utility {

    // Notification ID.
    private const val NOTIFICATION_ID = 0

    fun NotificationManager.sendNotification(messageBody: String, applicationContext: Context) {

        val contentIntent = Intent(applicationContext, MainActivity::class.java)

        val contentPendingIntent = PendingIntent.getActivity(
            applicationContext,
            NOTIFICATION_ID,
            contentIntent,
            PendingIntent.FLAG_UPDATE_CURRENT
        )

        val builder = NotificationCompat.Builder(
            applicationContext,
            "HYS_NOTIFICATION_CHANNEL"
        )
            // TODO: Step 1.3 set title, text and icon to builder
            .setSmallIcon(R.drawable.phone_call)
            .setContentTitle("Call")
            .setContentText(messageBody)
            .setContentIntent(contentPendingIntent)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
        notify(NOTIFICATION_ID, builder.build())
    }

    fun NotificationManager.cancelNotifications() {
        cancelAll()
    }

}