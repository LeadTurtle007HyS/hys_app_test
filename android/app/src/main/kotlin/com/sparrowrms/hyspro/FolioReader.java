package com.sparrowrms.hyspro;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Parcelable;
import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.sparrowrms.hyspro.model.HighLight;
import com.sparrowrms.hyspro.model.HighlightImpl;
import com.sparrowrms.hyspro.model.Toughness;
import com.sparrowrms.hyspro.model.ToughnessImpl;
import com.sparrowrms.hyspro.model.dataclasses.HighlyRatedBookRequestBody;
import com.sparrowrms.hyspro.model.locators.ReadLocator;
import com.sparrowrms.hyspro.model.sqlite.DbAdapter;
import com.sparrowrms.hyspro.network.QualifiedTypeConverterFactory;
import com.sparrowrms.hyspro.network.R2StreamerApi;
import com.sparrowrms.hyspro.ui.activity.FolioActivity;
import com.sparrowrms.hyspro.ui.base.OnSaveHighlight;
import com.sparrowrms.hyspro.ui.base.SaveReceivedHighlightTask;
import com.sparrowrms.hyspro.util.OnHighlightListener;
import com.sparrowrms.hyspro.util.ReadLocatorListener;
import okhttp3.OkHttpClient;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.converter.jackson.JacksonConverterFactory;

import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * Created by avez raj on 9/13/2017.
 */

public class FolioReader {

    @SuppressLint("StaticFieldLeak")
    private static FolioReader singleton = null;

    public static final String EXTRA_BOOK_ID = "com.sparrowrms.hyspro.extra.BOOK_ID";
    public static final String EXTRA_HIGHLIGHT_IMPL_ID = "com.sparrowrms.hyspro.extra.HIGHLIGHT_IMPL_ID";
    public static final String EXTRA_IS_SCROLL_TO_RANGY = "com.sparrowrms.hyspro.extra.IS_SCROLL_TO_RANGY";
    public static final String EXTRA_IS_SEARCH_PARAGRAPH = "com.sparrowrms.hyspro.extra.IS_SEARCH_PARAGRAPH";
    public static final String EXTRA__SEARCH_PARAGRAPH_QUERY = "com.sparrowrms.hyspro.extra.SEARCH_PARAGRAPH_QUERY";
    public static final String EXTRA_READ_LOCATOR = "com.sparrowrms.hyspro.extra.READ_LOCATOR";
    public static final String EXTRA_PORT_NUMBER = "com.sparrowrms.hyspro.extra.PORT_NUMBER";
    public static final String ACTION_SAVE_READ_LOCATOR = "com.sparrowrms.hyspro.action.SAVE_READ_LOCATOR";
    public static final String ACTION_CLOSE_FOLIOREADER = "com.sparrowrms.hyspro.action.CLOSE_FOLIOREADER";
    public static final String ACTION_FOLIOREADER_CLOSED = "com.sparrowrms.hyspro.action.FOLIOREADER_CLOSED";

    public static final String DICTIONARY_ID = "com.sparrowrms.hyspro.extra.dictionary_id";

    public static final String HIGHLY_RATED_BOOK_REQ = "com.sparrowrms.hyspro.extra.highly_rated_req_body";

    private Context context;
    private Config config;
    private boolean overrideConfig;
    private int portNumber = Constants.DEFAULT_PORT_NUMBER;
    private OnHighlightListener onHighlightListener;
    private ReadLocatorListener readLocatorListener;
    private OnClosedListener onClosedListener;
    private ReadLocator readLocator;

    @Nullable
    public Retrofit retrofit;
    @Nullable
    public R2StreamerApi r2StreamerApi;

    public interface OnClosedListener {
        void onFolioReaderClosed();
    }

    private BroadcastReceiver highlightReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            HighlightImpl highlightImpl = intent.getParcelableExtra(HighlightImpl.INTENT);
            HighLight.HighLightAction action = (HighLight.HighLightAction)
                    intent.getSerializableExtra(HighLight.HighLightAction.class.getName());
            if (onHighlightListener != null && highlightImpl != null && action != null) {
                onHighlightListener.onHighlight(highlightImpl, action);
            }
        }
    };

    private BroadcastReceiver toughNessSelectionReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            ToughnessImpl highlightImpl = intent.getParcelableExtra(ToughnessImpl.INTENT);
            Toughness.ToughnessAction action = (Toughness.ToughnessAction)
                    intent.getSerializableExtra(Toughness.ToughnessAction.class.getName());
//            if (onHighlightListener != null && highlightImpl != null && action != null) {
//                onHighlightListener.onHighlight(highlightImpl, action);
//            }
        }
    };

    private BroadcastReceiver readLocatorReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {

            ReadLocator readLocator =
                    (ReadLocator) intent.getSerializableExtra(FolioReader.EXTRA_READ_LOCATOR);
            if (readLocatorListener != null)
                readLocatorListener.saveReadLocator(readLocator);
        }
    };

    private BroadcastReceiver closedReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (onClosedListener != null)
                onClosedListener.onFolioReaderClosed();
        }
    };

    public static FolioReader get() {

        if (singleton == null) {
            synchronized (FolioReader.class) {
                if (singleton == null) {
                    if (AppContext.get() == null) {
                        throw new IllegalStateException("-> context == null");
                    }
                    singleton = new FolioReader(AppContext.get());
                }
            }
        }
        return singleton;
    }

    private FolioReader() {
    }

    private FolioReader(Context context) {
        this.context = context;
        DbAdapter.initialize(context);
        LocalBroadcastManager localBroadcastManager = LocalBroadcastManager.getInstance(context);
        localBroadcastManager.registerReceiver(highlightReceiver,
                new IntentFilter(HighlightImpl.BROADCAST_EVENT));
        localBroadcastManager.registerReceiver(toughNessSelectionReceiver,
                new IntentFilter(ToughnessImpl.BROADCAST_EVENT));
        localBroadcastManager.registerReceiver(readLocatorReceiver,
                new IntentFilter(ACTION_SAVE_READ_LOCATOR));
        localBroadcastManager.registerReceiver(closedReceiver,
                new IntentFilter(ACTION_FOLIOREADER_CLOSED));
    }

    public FolioReader openBook(String assetOrSdcardPath, String dictionaryID, boolean isDictionaryID, HighlyRatedBookRequestBody highlyRatedBookRequestBody) {
        Intent intent = getIntentFromUrl(assetOrSdcardPath, 0);
        intent.putExtra(DICTIONARY_ID,dictionaryID);
        intent.putExtra(HIGHLY_RATED_BOOK_REQ,highlyRatedBookRequestBody);
        context.startActivity(intent);
        return singleton;
    }
    public FolioReader openBook(String assetOrSdcardPath,boolean isScrollToPara,String paragraphQuery,HighlyRatedBookRequestBody highlyRatedBookRequestBody) {
        Intent intent = getIntentFromUrl(assetOrSdcardPath, 0);
        intent.putExtra(EXTRA_IS_SEARCH_PARAGRAPH,isScrollToPara);
        intent.putExtra(EXTRA__SEARCH_PARAGRAPH_QUERY,paragraphQuery);
        intent.putExtra(EXTRA_IS_SCROLL_TO_RANGY,true);
        intent.putExtra(HIGHLY_RATED_BOOK_REQ,highlyRatedBookRequestBody);
        intent.putExtra(FolioActivity.IS_FOLIO_ACTIVITY_COPY_INSTANCE,true);
        context.startActivity(intent);
        return singleton;
    }
    public FolioReader openBook(String assetOrSdcardPath,HighlightImpl highlightImpl) {
        Intent intent = getIntentFromUrl(assetOrSdcardPath, 0);
        intent.putExtra(EXTRA_HIGHLIGHT_IMPL_ID,highlightImpl);
        intent.putExtra(EXTRA_IS_SCROLL_TO_RANGY,true);
        context.startActivity(intent);
        return singleton;
    }

    public FolioReader openBook(int rawId) {
        Intent intent = getIntentFromUrl(null, rawId);
        context.startActivity(intent);
        return singleton;
    }

    public FolioReader openBook(String assetOrSdcardPath, String bookId) {
        Intent intent = getIntentFromUrl(assetOrSdcardPath, 0);
        intent.putExtra(EXTRA_BOOK_ID, bookId);
        context.startActivity(intent);
        return singleton;
    }

    public FolioReader openBook(int rawId, String bookId) {
        Intent intent = getIntentFromUrl(null, rawId);
        intent.putExtra(EXTRA_BOOK_ID, bookId);
        context.startActivity(intent);
        return singleton;
    }

    private Intent getIntentFromUrl(String assetOrSdcardPath, int rawId) {

        Intent intent = new Intent(context, FolioActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(Config.INTENT_CONFIG, config);
        intent.putExtra(Config.EXTRA_OVERRIDE_CONFIG, overrideConfig);
        intent.putExtra(EXTRA_PORT_NUMBER, portNumber);
        intent.putExtra(FolioActivity.EXTRA_READ_LOCATOR, (Parcelable) readLocator);

        if (rawId != 0) {
            intent.putExtra(FolioActivity.INTENT_EPUB_SOURCE_PATH, rawId);
            intent.putExtra(FolioActivity.INTENT_EPUB_SOURCE_TYPE,
                    FolioActivity.EpubSourceType.RAW);
        } else if (assetOrSdcardPath.contains(Constants.ASSET)) {
            intent.putExtra(FolioActivity.INTENT_EPUB_SOURCE_PATH, assetOrSdcardPath);
            intent.putExtra(FolioActivity.INTENT_EPUB_SOURCE_TYPE,
                    FolioActivity.EpubSourceType.ASSETS);
        } else {
            intent.putExtra(FolioActivity.INTENT_EPUB_SOURCE_PATH, assetOrSdcardPath);
            intent.putExtra(FolioActivity.INTENT_EPUB_SOURCE_TYPE,
                    FolioActivity.EpubSourceType.SD_CARD);
        }

        return intent;
    }


    public FolioReader setConfig(Config config, boolean overrideConfig) {
        this.config = config;
        this.overrideConfig = overrideConfig;
        return singleton;
    }

    public FolioReader setPortNumber(int portNumber) {
        this.portNumber = portNumber;
        return singleton;
    }

    public static void initRetrofit(String streamerUrl) {

        if (singleton == null )
            return;

        OkHttpClient client = new OkHttpClient.Builder()
                .connectTimeout(1, TimeUnit.MINUTES)
                .readTimeout(1, TimeUnit.MINUTES)
                .writeTimeout(1, TimeUnit.MINUTES)
                .build();

        singleton.retrofit = new Retrofit.Builder()
                .baseUrl(streamerUrl)
                .addConverterFactory(new QualifiedTypeConverterFactory(
                        JacksonConverterFactory.create(),
                        GsonConverterFactory.create()))
                .client(client)
                .build();

        singleton.r2StreamerApi = singleton.retrofit.create(R2StreamerApi.class);
    }

    public FolioReader setOnHighlightListener(OnHighlightListener onHighlightListener) {
        this.onHighlightListener = onHighlightListener;
        return singleton;
    }

    public FolioReader setReadLocatorListener(ReadLocatorListener readLocatorListener) {
        this.readLocatorListener = readLocatorListener;
        return singleton;
    }

    public FolioReader setOnClosedListener(OnClosedListener onClosedListener) {
        this.onClosedListener = onClosedListener;
        return singleton;
    }

    public FolioReader setReadLocator(ReadLocator readLocator) {
        this.readLocator = readLocator;
        return singleton;
    }

    public void saveReceivedHighLights(List<HighLight> highlights,
                                       OnSaveHighlight onSaveHighlight) {
        new SaveReceivedHighlightTask(onSaveHighlight, highlights).execute();
    }

    /**
     * Closes all the activities related to FolioReader.
     * After closing all the activities of FolioReader, callback can be received in
     * {@link OnClosedListener#onFolioReaderClosed()} if implemented.
     * Developer is still bound to call {@link #clear()} or {@link #stop()}
     * for clean up if required.
     */
    public void close() {
        Intent intent = new Intent(FolioReader.ACTION_CLOSE_FOLIOREADER);
        LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
    }

    /**
     * Nullifies readLocator and listeners.
     * This method ideally should be used in onDestroy() of Activity or Fragment.
     * Use this method if you want to use FolioReader singleton instance again in the application,
     * else use {@link #stop()} which destruct the FolioReader singleton instance.
     */
    public static synchronized void clear() {

        if (singleton != null) {
            singleton.readLocator = null;
            singleton.onHighlightListener = null;
            singleton.readLocatorListener = null;
            singleton.onClosedListener = null;
        }
    }

    /**
     * Destructs the FolioReader singleton instance.
     * Use this method only if you are sure that you won't need to use
     * FolioReader singleton instance again in application, else use {@link #clear()}.
     */
    public static synchronized void stop() {

        if (singleton != null) {
            DbAdapter.terminate();
            singleton.unregisterListeners();
            singleton = null;
        }
    }

    private void unregisterListeners() {
        LocalBroadcastManager localBroadcastManager = LocalBroadcastManager.getInstance(context);
        localBroadcastManager.unregisterReceiver(highlightReceiver);
        localBroadcastManager.unregisterReceiver(readLocatorReceiver);
        localBroadcastManager.unregisterReceiver(closedReceiver);
    }
}
