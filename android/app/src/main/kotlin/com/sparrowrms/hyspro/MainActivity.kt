package com.sparrowrms.hyspro

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import com.yalantis.ucrop.UCrop
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import android.net.Uri
import com.sparrowrms.hyspro.model.dataclasses.CallingUserNotificationDetails
import com.sparrowrms.hyspro.model.dataclasses.HighlyRatedBookRequestBody
import com.sparrowrms.hyspro.model.datasourcemodel.UserDetailsModel
import com.sparrowrms.hyspro.ui.activity.CallActivity
import com.sparrowrms.hyspro.util.SharedPreferenceUtil
import com.sparrowrms.hyspro.util.SharedPrefsHelper


class MainActivity : FlutterActivity(), PluginRegistry.PluginRegistrantCallback, MethodCallHandler,
    ActivityAware {

    var messenger: BinaryMessenger? = null

    //    private val delegate: ImageCropperDelegate? = null
    private val activityPluginBinding: ActivityPluginBinding? = null
    private var pendingResult: Result? = null
    private var reader: Reader? = null
    private var config: ReaderConfig? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(FlutterEngine(this))

    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        messenger = flutterEngine.dartExecutor.binaryMessenger
        val channel: MethodChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "epub_viewer")
        channel.setMethodCallHandler(this)
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method.equals("cropImage", ignoreCase = true)) {
            val delegate = ImageCropperDelegate(this)
            delegate.startCrop(call, result)
            this.pendingResult = result
            activityPluginBinding?.addActivityResultListener(delegate)
        } else if ((call.method == "setConfig")) {
            val arguments: MutableMap<String, Any> = call.arguments as MutableMap<String, Any>
            val identifier: String = arguments["identifier"].toString()
            val themeColor: String = arguments["themeColor"].toString()
            val scrollDirection: String = arguments["scrollDirection"].toString()
            val nightMode: Boolean =
                java.lang.Boolean.parseBoolean(arguments["nightMode"].toString())
            val allowSharing: Boolean =
                java.lang.Boolean.parseBoolean(arguments["allowSharing"].toString())
            val enableTts: Boolean =
                java.lang.Boolean.parseBoolean(arguments["enableTts"].toString())
            config = ReaderConfig(
                applicationContext, identifier, themeColor,
                scrollDirection, allowSharing, enableTts, nightMode
            )
        } else if ((call.method == "open")) {
            val arguments: MutableMap<String, Any> =
                call.arguments as MutableMap<String, Any>
            val bookPath: String = arguments["bookPath"].toString()
            val lastLocation: String = arguments["lastLocation"].toString()
            val dictionaryID:String= arguments["dictionary_id"].toString()
            val grade:String =arguments["grade"].toString()
            val subject:String =arguments["subject"].toString()
            val publication:String =arguments["publication"].toString()
            val publicationEdition:String =arguments["publication_edition"].toString()
            val chapter:String =arguments["chapter"].toString()
            val part:String =arguments["part"].toString()
            val openBookType=arguments["open_book_type"].toString()
            SharedPrefsHelper.saveOpenedBookType(openBookType)
            val loggedInUserID: String = arguments["LOGGED_IN_USER_ID"].toString()
            val loggedInUserName: String = arguments["LOGGED_IN_userName"].toString()
            val loggedInUserProfilePic: String = arguments["LOGGED_IN_profilePic"].toString()
            val lastname:String = arguments["LOGGED_IN_USER_lNAME"].toString()
            val loggedInUserDetailsModel=UserDetailsModel()
            loggedInUserDetailsModel.userid=loggedInUserID
            loggedInUserDetailsModel.firstname=loggedInUserName
            loggedInUserDetailsModel.profilepic=loggedInUserProfilePic
            loggedInUserDetailsModel.lastname=lastname
            SharedPrefsHelper.saveLoggedInUser(loggedInUserDetailsModel)
           val highlyRatedBookRequestBody= HighlyRatedBookRequestBody(grade,subject,publication,publicationEdition,chapter,part,"")
            reader = Reader(applicationContext, messenger, config)
            reader!!.open(bookPath, lastLocation,dictionaryID,highlyRatedBookRequestBody)
        } else if ((call.method == "outgoing_calling")) {
            val arguments: MutableMap<String, Any> =
                call.arguments as MutableMap<String, Any>
            val isVideo: Boolean =
                java.lang.Boolean.parseBoolean(arguments["IS_VIDEO"].toString())
            val userID: String = arguments["USER_ID"].toString()
            val userName: String = arguments["userName"].toString()
            val profilePic: String = arguments["profilePic"].toString()
            val loggedInUserID: String = arguments["LOGGED_IN_USER_ID"].toString()
            val loggedInUserName: String = arguments["LOGGED_IN_userName"].toString()
            val loggedInUserProfilePic: String = arguments["LOGGED_IN_profilePic"].toString()
            val userDetailsModel = UserDetailsModel()
            userDetailsModel.userid = userID
            userDetailsModel.firstname = userName
            userDetailsModel.lastname=" "
            userDetailsModel.profilepic = profilePic
            val loggedInUserDetailsModel=UserDetailsModel()
            loggedInUserDetailsModel.userid=loggedInUserID
            loggedInUserDetailsModel.firstname=loggedInUserName
            loggedInUserDetailsModel.profilepic=loggedInUserProfilePic
            loggedInUserDetailsModel.lastname=" "
            SharedPrefsHelper.saveLoggedInUser(loggedInUserDetailsModel)
            CallActivity.start(
                this,
                false,
                userDetailsModel,
                isVideo,
                notificationDetails = CallingUserNotificationDetails()
            )

        } else {
            result.notImplemented()
        }
    }


    fun onAttachedToEngine(binding: FlutterPluginBinding) {
        //    EpubViewerPlugin.registerWith(binding.binaryMessenger,binding.applicationContext)


    }

    fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        // TODO: your plugin is no longer attached to a Flutter experience.
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        var b = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }

    override fun onDetachedFromActivity() {

    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {

        if (requestCode == UCrop.REQUEST_CROP) {
            when {
                resultCode == RESULT_OK -> {
                    val resultUri: Uri = UCrop.getOutput(data!!)!!
                    val fileUtils = FileUtils()
                    finishWithSuccess(fileUtils.getPathFromUri(activity, resultUri))

                }
                resultCode == UCrop.RESULT_ERROR -> {
                    val cropError: Throwable = UCrop.getError(data!!)!!
                    finishWithError("crop_error", cropError.localizedMessage, cropError)

                }
                pendingResult != null -> {
                    pendingResult!!.success(null)
                    clearMethodCallAndResult()

                }
            }
        }

        super.onActivityResult(requestCode, resultCode, data)
    }


    private fun finishWithSuccess(imagePath: String) {
        if (pendingResult != null) {
            pendingResult!!.success(imagePath)
            clearMethodCallAndResult()
        }
    }

    private fun clearMethodCallAndResult() {
        pendingResult = null
    }

    private fun finishWithError(errorCode: String, errorMessage: String, throwable: Throwable) {
        if (pendingResult != null) {
            pendingResult!!.error(errorCode, errorMessage, throwable)
            clearMethodCallAndResult()
        }
    }

    override fun registerWith(registry: PluginRegistry?) {
        val a = registry
    }
}


