package com.sparrowrms.hyspro.services;

import static com.sparrowrms.hyspro.Constants.EXTRA_NOTIFICATION_BUTTON_ACTION;
import static com.sparrowrms.hyspro.Constants.EXTRA_NOTIFICATION_BUTTON_ACTION_DATA;


import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class NotificationActionService extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        context.sendBroadcast(new Intent(EXTRA_NOTIFICATION_BUTTON_ACTION)
                .putExtra(EXTRA_NOTIFICATION_BUTTON_ACTION_DATA, intent.getAction()));
    }
}

