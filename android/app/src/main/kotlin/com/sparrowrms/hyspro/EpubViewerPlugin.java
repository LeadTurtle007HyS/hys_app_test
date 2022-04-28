package com.sparrowrms.hyspro;

import android.app.Activity;
import android.content.Context;
import java.util.Map;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

import androidx.annotation.NonNull;

import com.sparrowrms.hyspro.model.dataclasses.HighlyRatedBookRequestBody;


/**
 * EpubReaderPlugin
 */
public class EpubViewerPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {

    static BinaryMessenger messenger;
    static private Activity activity;
    static private Context context;
    private Reader reader;
    private ReaderConfig config;


    private ActivityPluginBinding activityPluginBinding;
    private Result pendingResult;

    /**
     * Plugin registration.
     */
    public static void registerWith(BinaryMessenger registrar, Context ctx, Activity activity1) {

        messenger = registrar;
        context = ctx;
        activity = activity1;

        final MethodChannel channel = new MethodChannel(registrar, "epub_viewer");
        channel.setMethodCallHandler(new EpubViewerPlugin());


    }


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        context = binding.getApplicationContext();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        // TODO: your plugin is no longer attached to a Flutter experience.
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {

        if (call.method.equals("setConfig")) {
            Map<String, Object> arguments = (Map<String, Object>) call.arguments;
            String identifier = arguments.get("identifier").toString();
            String themeColor = arguments.get("themeColor").toString();
            String scrollDirection = arguments.get("scrollDirection").toString();
            boolean nightMode = Boolean.parseBoolean(arguments.get("nightMode").toString());
            boolean allowSharing = Boolean.parseBoolean(arguments.get("allowSharing").toString());
            boolean enableTts = Boolean.parseBoolean(arguments.get("enableTts").toString());
            config = new ReaderConfig(activity.getApplicationContext(), identifier, themeColor,
                    scrollDirection, allowSharing, enableTts, nightMode);

        } else if (call.method.equals("open")) {

            Map<String, Object> arguments = (Map<String, Object>) call.arguments;
            String bookPath = arguments.get("bookPath").toString();
            String lastLocation = arguments.get("lastLocation").toString();
            String dictionaryId = arguments.get("dictionary_id").toString();
            String grade =arguments.get("grade").toString();
            String subject =arguments.get("subject").toString();
            String publication  =arguments.get("publication").toString();
            String publicationEdition  =arguments.get("publication_edition").toString();
            String chapter  =arguments.get("chapter").toString();
            String part =arguments.get("part").toString();
            HighlyRatedBookRequestBody highlyRatedBookRequestBody= new HighlyRatedBookRequestBody(grade,subject,publication,publicationEdition,chapter,part,"");
            reader = new Reader(context, messenger, config);
            reader.open(bookPath, lastLocation,dictionaryId,highlyRatedBookRequestBody);

        } else if (call.method.equals("close")) {
            reader.close();
        } else if (call.method.equalsIgnoreCase("cropImage")) {
//            ImageCropperDelegate delegate = new ImageCropperDelegate(activity, this);
//            delegate.startCrop(call, result);
//            this.pendingResult = result;


         //   activityPluginBinding.addActivityResultListener(delegate);
        } else {
            result.notImplemented();
        }
    }


//    public ImageCropperDelegate setupActivity(Activity activity) {
//        delegate = new ImageCropperDelegate(activity, this);
//        return delegate;
//    }


    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {

        this.activityPluginBinding = binding;
      //  activityPluginBinding.addActivityResultListener(delegate);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }




}
