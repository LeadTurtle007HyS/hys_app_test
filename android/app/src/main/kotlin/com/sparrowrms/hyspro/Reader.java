package com.sparrowrms.hyspro;

import android.content.Context;
import android.util.Log;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sparrowrms.hyspro.model.HighLight;
import com.sparrowrms.hyspro.model.dataclasses.HighlyRatedBookRequestBody;
import com.sparrowrms.hyspro.model.locators.ReadLocator;
import com.sparrowrms.hyspro.ui.base.OnSaveHighlight;
import com.sparrowrms.hyspro.util.OnHighlightListener;
import com.sparrowrms.hyspro.util.ReadLocatorListener;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class Reader implements OnHighlightListener, ReadLocatorListener, FolioReader.OnClosedListener{

    private ReaderConfig readerConfig;
    public FolioReader folioReader;
    private Context context;
    public MethodChannel.Result result;
    private EventChannel.EventSink pageEventSink;
    private BinaryMessenger messenger;
    private ReadLocator  read_locator;
    private static final String PAGE_CHANNEL = "page";

    Reader(Context context, BinaryMessenger messenger,ReaderConfig config){
        this.context = context;
        readerConfig = config;
        getHighlightsAndSave();
        folioReader = FolioReader.get()
                .setOnHighlightListener(this)
                .setReadLocatorListener(this)
                .setOnClosedListener(this);

     
        setPageHandler(messenger);
    }

    public void open(String bookPath, String lastLocation, final  String dictionaryID, final HighlyRatedBookRequestBody highlyRatedBookRequestBody){
        final String path = bookPath;
        final String location = lastLocation;
        new Thread(() -> {
           try {
               if(location != null && !location.isEmpty()){
                   ReadLocator readLocator = ReadLocator.fromJson(location);
                   folioReader.setReadLocator(readLocator);
               }
               folioReader.setConfig(readerConfig.config, true)
                       .openBook(path,dictionaryID,true,highlyRatedBookRequestBody);
           } catch (Exception e) {
               e.printStackTrace();
           }
        }).start();
       
    }

    public void close(){
        folioReader.close();
    }

    private void setPageHandler(BinaryMessenger messenger){
//        final MethodChannel channel = new MethodChannel(registrar.messenger(), "page");
//        channel.setMethodCallHandler(new EpubKittyPlugin());
        new EventChannel(messenger,PAGE_CHANNEL).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink eventSink) {
                pageEventSink = eventSink;
            }

            @Override
            public void onCancel(Object o) {

            }
        });
    }

    private void getHighlightsAndSave() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                ArrayList<HighLight> highlightList = null;
                ObjectMapper objectMapper = new ObjectMapper();
                try {
                    highlightList = objectMapper.readValue(
                            loadAssetTextAsString("highlights/highlights_data.json"),
                            new TypeReference<List<HighlightData>>() {
                            });
                } catch (IOException e) {
                    e.printStackTrace();
                }

                if (highlightList == null) {
                    folioReader.saveReceivedHighLights(highlightList, new OnSaveHighlight() {
                        @Override
                        public void onFinished() {
                            //You can do anything on successful saving highlight list
                        }
                    });
                }
            }
        }).start();
    }


    private String loadAssetTextAsString(String name) {
        BufferedReader in = null;
        try {
            StringBuilder buf = new StringBuilder();
            InputStream is = context.getAssets().open(name);
            in = new BufferedReader(new InputStreamReader(is));

            String str;
            boolean isFirst = true;
            while ((str = in.readLine()) != null) {
                if (isFirst)
                    isFirst = false;
                else
                    buf.append('\n');
                buf.append(str);
            }
            return buf.toString();
        } catch (IOException e) {
            Log.e("Reader", "Error opening asset " + name);
        } finally {
            if (in != null) {
                try {
                    in.close();
                } catch (IOException e) {
                    Log.e("Reader", "Error closing asset " + name);
                }
            }
        }
        return null;
    }

    @Override
    public void onFolioReaderClosed() {

        if (pageEventSink != null){
            pageEventSink.success(read_locator.toJson());
        }
    }

    @Override
    public void onHighlight(HighLight highlight, HighLight.HighLightAction type) {

    }

    @Override
    public void saveReadLocator(ReadLocator readLocator) {
        read_locator = readLocator;
    }


}
