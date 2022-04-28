package com.sparrowrms.hyspro

import io.flutter.app.FlutterApplication



class Application : FlutterApplication() {

    private var globalSettings: GlobalSettings? = null

    companion object {
        private lateinit var instance: Application

        @Synchronized
        fun getInstance(): Application = instance
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
      //  GeneratedPluginRegistrant.registerWith(FlutterEngine(this))
       // FlutterFirebaseMessagingService.setPluginRegistrant(this);
    }




    fun getGlobalSettings(): GlobalSettings? {
        if (globalSettings == null) {
            globalSettings = GlobalSettings()
        }
        return globalSettings
    }
}
