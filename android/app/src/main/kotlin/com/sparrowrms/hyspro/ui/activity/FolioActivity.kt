package com.sparrowrms.hyspro.ui.activity
import android.Manifest
import android.app.Activity
import android.app.ActivityManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.graphics.Rect
import android.graphics.drawable.ColorDrawable
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.text.TextUtils
import android.util.DisplayMetrics
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.ActionBar
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDelegate
import androidx.appcompat.widget.Toolbar
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.sparrowrms.hyspro.Constants
import com.sparrowrms.hyspro.Constants.*
import com.sparrowrms.hyspro.R
import com.sparrowrms.hyspro.model.*
import com.sparrowrms.hyspro.model.event.MediaOverlayPlayPauseEvent
import com.sparrowrms.hyspro.model.locators.ReadLocator
import com.sparrowrms.hyspro.model.locators.SearchLocator
import com.sparrowrms.hyspro.model.sqlite.EBookTable
import com.sparrowrms.hyspro.ui.adapter.FolioPageFragmentAdapter
import com.sparrowrms.hyspro.ui.adapter.SearchAdapter
import com.sparrowrms.hyspro.ui.fragment.FolioPageFragment
import com.sparrowrms.hyspro.ui.fragment.MediaControllerFragment
import com.sparrowrms.hyspro.ui.view.ConfigBottomSheetDialogFragment
import com.sparrowrms.hyspro.ui.view.DirectionalViewpager
import com.sparrowrms.hyspro.ui.view.FolioAppBarLayout
import com.sparrowrms.hyspro.ui.view.MediaControllerCallback
import org.greenrobot.eventbus.EventBus
import org.readium.r2.shared.Link
import org.readium.r2.shared.Publication
import org.readium.r2.streamer.parser.CbzParser
import org.readium.r2.streamer.parser.EpubParser
import org.readium.r2.streamer.parser.PubBox
import org.readium.r2.streamer.server.Server
import java.lang.ref.WeakReference
import com.sparrowrms.hyspro.Config
import com.sparrowrms.hyspro.FolioReader
import com.sparrowrms.hyspro.ReaderConfig
import io.reactivex.BackpressureStrategy
import io.reactivex.android.schedulers.AndroidSchedulers.*
import io.reactivex.disposables.Disposables
import io.reactivex.schedulers.Schedulers
import okhttp3.*
import java.io.File
import java.util.concurrent.TimeUnit
import android.os.Environment
import com.sparrowrms.hyspro.FolioReader.HIGHLY_RATED_BOOK_REQ
import com.sparrowrms.hyspro.model.dataclasses.HighlyRatedBookRequestBody
import com.sparrowrms.hyspro.model.dataclasses.HighlyRelatedBooksModel
import com.sparrowrms.hyspro.model.dataclasses.RelatedQuestionModel
import com.sparrowrms.hyspro.util.AppUtil
import com.sparrowrms.hyspro.ui.fragment.HighlyRelatedBooksFragment
import com.sparrowrms.hyspro.ui.view.LoadingView
import com.sparrowrms.hyspro.util.*
import java.util.*
import android.R.attr.direction
import android.provider.Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION


class FolioActivity : AppCompatActivity(), FolioActivityCallback, MediaControllerCallback,
    View.OnSystemUiVisibilityChangeListener {

    private var bookFileName: String? = null

    private var mFolioPageViewPager: DirectionalViewpager? = null
    private var actionBar: ActionBar? = null
    private var appBarLayout: FolioAppBarLayout? = null
    private var toolbar: Toolbar? = null
    private var distractionFreeMode: Boolean = false
    private var handler: Handler? = null

    private var currentChapterIndex: Int = 0
    private var mFolioPageFragmentAdapter: FolioPageFragmentAdapter? = null
    private var entryReadLocator: ReadLocator? = null
    private var lastReadLocator: ReadLocator? = null
    private var outState: Bundle? = null
    private var savedInstanceState: Bundle? = null

    private var r2StreamerServer: Server? = null
    private var pubBox: PubBox? = null
    private var spine: List<Link>? = null

    private var mBookId: String? = null
    private var dictionaryID:String?=null

    private var highlyRatedBookRequestBody:HighlyRatedBookRequestBody?=null

    private var mEpubFilePath: String? = null
    private var mEpubSourceType: EpubSourceType? = null
    private var mEpubRawId = 0
    private var mediaControllerFragment: MediaControllerFragment? = null
    private var direction: Config.Direction = Config.Direction.VERTICAL
    private var portNumber: Int = DEFAULT_PORT_NUMBER
    private var streamerUri: Uri? = null

    private var searchUri: Uri? = null
    private var searchAdapterDataBundle: Bundle? = null
    private var searchQuery: CharSequence? = null
    private var searchLocator: SearchLocator? = null

    private var displayMetrics: DisplayMetrics? = null
    private var density: Float = 0.toFloat()
    private var topActivity: Boolean? = null
    private var taskImportance: Int = 0

    private var disposable = Disposables.disposed()
    private var loadingView: LoadingView? = null
    private var isScrollToRangy = false
    private var isScrollToParagraph = false
    private var isFolioActivityCopyInstance=false
    private var selectedHighlightedImpl: HighlightImpl = HighlightImpl()
    private val fileDownloader by lazy {
        FileDownloader(
            OkHttpClient.Builder().build()
        )
    }

    companion object {

        @JvmField
        val LOG_TAG: String = FolioActivity::class.java.simpleName
        const val INTENT_EPUB_SOURCE_PATH = "com.sparrowrms.hyspro.epub_asset_path"
        const val INTENT_EPUB_SOURCE_TYPE = "epub_source_type"
        const val EXTRA_READ_LOCATOR = "com.sparrowrms.hyspro.extra.READ_LOCATOR"
        private const val BUNDLE_READ_LOCATOR_CONFIG_CHANGE = "BUNDLE_READ_LOCATOR_CONFIG_CHANGE"
        private const val BUNDLE_DISTRACTION_FREE_MODE = "BUNDLE_DISTRACTION_FREE_MODE"
        const val EXTRA_SEARCH_ITEM = "EXTRA_SEARCH_ITEM"
        const val ACTION_SEARCH_CLEAR = "ACTION_SEARCH_CLEAR"
        private const val HIGHLIGHT_ITEM = "highlight_item"
         const val IS_FOLIO_ACTIVITY_COPY_INSTANCE="is_folio_activity_copy_instance"
    }

    private val closeBroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {

            val action = intent.action
            if (action != null && action == FolioReader.ACTION_CLOSE_FOLIOREADER) {

                try {
                    val activityManager =
                        context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                    val tasks = activityManager.runningAppProcesses
                    taskImportance = tasks[0].importance
                } catch (e: Exception) {
                    Log.e(LOG_TAG, "-> ", e)
                }

                val closeIntent = Intent(applicationContext, FolioActivity::class.java)
                closeIntent.flags =
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                closeIntent.action = FolioReader.ACTION_CLOSE_FOLIOREADER
                this@FolioActivity.startActivity(closeIntent)
            }
        }
    }

    private val statusBarHeight: Int
        get() {
            var result = 0
            val resourceId = resources.getIdentifier("status_bar_height", "dimen", "android")
            if (resourceId > 0)
                result = resources.getDimensionPixelSize(resourceId)
            return result
        }

    private val searchReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            Log.v(LOG_TAG, "-> searchReceiver -> onReceive -> " + intent.action!!)

            val action = intent.action ?: return
            when (action) {
                ACTION_SEARCH_CLEAR -> clearSearchLocator()
            }
        }
    }

    private val currentFragment: FolioPageFragment?
        get() = if (mFolioPageFragmentAdapter != null && mFolioPageViewPager != null) {
            mFolioPageFragmentAdapter!!.getItem(mFolioPageViewPager!!.currentItem) as FolioPageFragment
        } else {
            null
        }

    enum class EpubSourceType {
        RAW,
        ASSETS,
        SD_CARD
    }

    private enum class RequestCode(val value: Int) {
        CONTENT_HIGHLIGHT(77),
        SEARCH(101),
        HIGHRATED_BOOKS(111),
        RELATED_QUESTION(121)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        Log.v(LOG_TAG, "-> onNewIntent")

        val action = getIntent().action
        if (action != null && action == FolioReader.ACTION_CLOSE_FOLIOREADER) {

            if (topActivity == null || topActivity == false) {
                // FolioActivity was already left, so no need to broadcast ReadLocator again.
                // Finish activity without going through onPause() and onStop()
                finish()

                // To determine if app in background or foreground
                var appInBackground = false
                if (Build.VERSION.SDK_INT < 26) {
                    if (ActivityManager.RunningAppProcessInfo.IMPORTANCE_BACKGROUND == taskImportance)
                        appInBackground = true
                } else {
                    if (ActivityManager.RunningAppProcessInfo.IMPORTANCE_CACHED == taskImportance)
                        appInBackground = true
                }
                if (appInBackground)
                    moveTaskToBack(true)
            }
        }
    }

    override fun onResume() {
        super.onResume()
        topActivity = true
        if(!isFolioActivityCopyInstance && bookFileName!=null){
            FolioReader.initRetrofit(streamerUrl)
        }

        val action = intent.action
        if (action != null && action == FolioReader.ACTION_CLOSE_FOLIOREADER) {
            finish()
        }
    }

    override fun onStop() {
        super.onStop()

        topActivity = false
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Need to add when vector drawables support library is used.
        AppCompatDelegate.setCompatVectorFromResourcesEnabled(true)

        handler = Handler()
        val display = windowManager.defaultDisplay
        displayMetrics = resources.displayMetrics
        display.getRealMetrics(displayMetrics)
        density = displayMetrics!!.density
        LocalBroadcastManager.getInstance(this).registerReceiver(
            closeBroadcastReceiver,
            IntentFilter(FolioReader.ACTION_CLOSE_FOLIOREADER)
        )


        setConfig(savedInstanceState)
        initDistractionFreeMode(savedInstanceState)

        setContentView(R.layout.folio_activity)
        this.savedInstanceState = savedInstanceState

        if (savedInstanceState != null) {
            searchAdapterDataBundle = savedInstanceState.getBundle(SearchAdapter.DATA_BUNDLE)
            searchQuery =
                savedInstanceState.getCharSequence(SearchActivity.BUNDLE_SAVE_SEARCH_QUERY)
        }

        mBookId = intent.getStringExtra(FolioReader.EXTRA_BOOK_ID)
        dictionaryID=intent.getStringExtra(FolioReader.DICTIONARY_ID)
        highlyRatedBookRequestBody=intent.getSerializableExtra(HIGHLY_RATED_BOOK_REQ) as HighlyRatedBookRequestBody
        if (intent.getParcelableExtra<HighlightImpl>(FolioReader.EXTRA_HIGHLIGHT_IMPL_ID) != null) {
            selectedHighlightedImpl =
                intent.getParcelableExtra(FolioReader.EXTRA_HIGHLIGHT_IMPL_ID)!!
        }
        isScrollToRangy =
            intent.getBooleanExtra(FolioReader.EXTRA_IS_SCROLL_TO_RANGY, isScrollToRangy)
        isScrollToParagraph =
            intent.getBooleanExtra(FolioReader.EXTRA_IS_SEARCH_PARAGRAPH, isScrollToParagraph)

        isFolioActivityCopyInstance=intent.getBooleanExtra(IS_FOLIO_ACTIVITY_COPY_INSTANCE,false)
        mEpubSourceType = intent.extras!!.getSerializable(INTENT_EPUB_SOURCE_TYPE) as EpubSourceType
        if (mEpubSourceType == EpubSourceType.RAW) {
            mEpubRawId = intent.extras!!.getInt(INTENT_EPUB_SOURCE_PATH)
        } else {
            mEpubFilePath = intent.extras!!
                .getString(INTENT_EPUB_SOURCE_PATH)
        }
        loadingView = findViewById(R.id.loadingView)
        initActionBar()
        initMediaController()

        if (ContextCompat.checkSelfPermission(
                this@FolioActivity,
                Manifest.permission.WRITE_EXTERNAL_STORAGE
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this@FolioActivity,
                Constants.getWriteExternalStoragePerms(),
                Constants.WRITE_EXTERNAL_STORAGE_REQUEST
            )
        } else {
            setupBook()
        }

        askForPermissions()
    }

    private fun initActionBar() {

        appBarLayout = findViewById(R.id.appBarLayout)
        toolbar = findViewById(R.id.toolbar)
        setSupportActionBar(toolbar)
        actionBar = supportActionBar

        val config = AppUtil.getSavedConfig(applicationContext)!!

        val drawable = ContextCompat.getDrawable(this, R.drawable.ic_drawer)
        UiUtil.setColorIntToDrawable(config.themeColor, drawable!!)
        toolbar!!.navigationIcon = drawable

        if (config.isNightMode) {
            setNightMode()
        } else {
            setDayMode()
        }

        val color: Int = if (config.isNightMode) {
            ContextCompat.getColor(this, R.color.black)
        } else {
            val attrs = intArrayOf(android.R.attr.navigationBarColor)
            val typedArray = theme.obtainStyledAttributes(attrs)
            typedArray.getColor(0, ContextCompat.getColor(this, R.color.white))
        }
        window.navigationBarColor = color

    }

    override fun setDayMode() {

        actionBar!!.setBackgroundDrawable(
            ColorDrawable(ContextCompat.getColor(this, R.color.white))
        )
        toolbar!!.setTitleTextColor(ContextCompat.getColor(this, R.color.black))
    }

    override fun setNightMode() {
        Log.v(LOG_TAG, "-> setNightMode")

        actionBar!!.setBackgroundDrawable(
            ColorDrawable(ContextCompat.getColor(this, R.color.black))
        )
        toolbar!!.setTitleTextColor(ContextCompat.getColor(this, R.color.night_title_text_color))
    }

    private fun initMediaController() {
        Log.v(LOG_TAG, "-> initMediaController")

        mediaControllerFragment = MediaControllerFragment.getInstance(supportFragmentManager, this)
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.menu_main, menu)

        val config = AppUtil.getSavedConfig(applicationContext)!!
        UiUtil.setColorIntToDrawable(config.themeColor, menu.findItem(R.id.itemSearch).icon)
        UiUtil.setColorIntToDrawable(config.themeColor, menu.findItem(R.id.itemConfig).icon)
        UiUtil.setColorIntToDrawable(config.themeColor, menu.findItem(R.id.itemTts).icon)

        if (!config.isShowTts)
            menu.findItem(R.id.itemTts).isVisible = false

        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        //Log.d(LOG_TAG, "-> onOptionsItemSelected -> " + item.getItemId());

        when (item.itemId) {
            android.R.id.home -> {
                startContentHighlightActivity()
                return true

            }
            R.id.itemSearch -> {
                if (searchUri == null)
                    return true
                val intent = Intent(this, SearchActivity::class.java)
                intent.putExtra(SearchActivity.BUNDLE_SPINE_SIZE, spine?.size ?: 0)
                intent.putExtra(SearchActivity.BUNDLE_SEARCH_URI, searchUri)
                intent.putExtra(SearchAdapter.DATA_BUNDLE, searchAdapterDataBundle)
                intent.putExtra(SearchActivity.BUNDLE_SAVE_SEARCH_QUERY, searchQuery)
                intent.putExtra(SearchActivity.BUNDLE_IS_SEARCH_SUBMIT,false)
                startActivityForResult(intent, RequestCode.SEARCH.value)
                return true

            }
            R.id.itemConfig -> {
                showConfigBottomSheetDialogFragment()
                return true

            }
            R.id.itemTts -> {

                showMediaController()
                return true
            }
            else -> return super.onOptionsItemSelected(item)
        }

    }

    private fun startContentHighlightActivity() {

        val intent = Intent(this@FolioActivity, ContentHighlightActivity::class.java)
        intent.putExtra(PUBLICATION, pubBox!!.publication)
        try {
            intent.putExtra(CHAPTER_SELECTED, spine!![currentChapterIndex].href)
        } catch (e: NullPointerException) {
            Log.w(LOG_TAG, "-> ", e)
            intent.putExtra(CHAPTER_SELECTED, "")
        } catch (e: IndexOutOfBoundsException) {
            Log.w(LOG_TAG, "-> ", e)
            intent.putExtra(CHAPTER_SELECTED, "")
        }

        intent.putExtra(FolioReader.EXTRA_BOOK_ID, mBookId)
        intent.putExtra(FolioReader.DICTIONARY_ID,dictionaryID)
        intent.putExtra(BOOK_TITLE, bookFileName)
        startActivityForResult(intent, RequestCode.CONTENT_HIGHLIGHT.value)
        overridePendingTransition(R.anim.slide_in_up, R.anim.slide_out_up)
    }

    private fun showConfigBottomSheetDialogFragment() {
        ConfigBottomSheetDialogFragment().show(
            supportFragmentManager,
            ConfigBottomSheetDialogFragment.LOG_TAG
        )
    }

    private fun showMediaController() {
        mediaControllerFragment!!.show(supportFragmentManager)
    }

    private fun setupBook() {
        Log.v(LOG_TAG, "-> setupBook")
        try {
            initBook()
            onBookInitSuccess()
        } catch (e: Exception) {
            Log.e(LOG_TAG, "-> Failed to initialize book", e)
            onBookInitFailure()
        }

    }

    @Throws(Exception::class)
    private fun initBook() {
        bookFileName = FileUtil.getEpubFilename(this, mEpubSourceType!!, mEpubFilePath, mEpubRawId)
        val path = FileUtil.saveEpubFileAndLoadLazyBook(
            this, mEpubSourceType, mEpubFilePath,
            mEpubRawId, bookFileName
        )
        val extension: Publication.EXTENSION
        var extensionString: String? = null
        try {
            extensionString = FileUtil.getExtensionUppercase(path)
            extension = Publication.EXTENSION.valueOf(extensionString)
        } catch (e: IllegalArgumentException) {
            throw Exception("-> Unknown book file extension `$extensionString`", e)
        }

        pubBox = when (extension) {
            Publication.EXTENSION.EPUB -> {
                val epubParser = EpubParser()
                epubParser.parse(path!!, "")
            }
            Publication.EXTENSION.CBZ -> {
                val cbzParser = CbzParser()
                cbzParser.parse(path!!, "")
            }
            else -> {
                null
            }
        }

        portNumber =
            intent.getIntExtra(FolioReader.EXTRA_PORT_NUMBER, DEFAULT_PORT_NUMBER)
        portNumber = AppUtil.getAvailablePortNumber(portNumber)

        r2StreamerServer = Server(portNumber)
        r2StreamerServer!!.addEpub(
            pubBox!!.publication, pubBox!!.container,
            "/" + bookFileName!!, null
        )

        r2StreamerServer!!.start()

        FolioReader.initRetrofit(streamerUrl)
    }

    private fun onBookInitFailure() {

    }

    private fun onBookInitSuccess() {

        val publication = pubBox!!.publication
        spine = publication.readingOrder
        title = publication.metadata.title

        if (mBookId == null) {
            mBookId = if (publication.metadata.identifier.isNotEmpty()) {
                publication.metadata.identifier
            } else {
                if (publication.metadata.title.isNotEmpty()) {
                    publication.metadata.title.hashCode().toString()
                } else {
                    bookFileName!!.hashCode().toString()
                }
            }
        }


        for (link in publication.links) {
            if (link.rel.contains("search")) {
                searchUri = Uri.parse("http://" + link.href!!)
                break
            }
        }
        if (searchUri == null)
            searchUri = Uri.parse(streamerUrl + "search")

        val eBookModel = EbookModel()
        eBookModel.bookId = mBookId
        eBookModel.bookName = bookFileName
        val id = EBookTable.saveEBookIfNotExists(eBookModel)

        if (id != -1L) {
            eBookModel.id = id.toInt()
        }

        configFolio()
    }

    override fun getStreamerUrl(): String {

        if (streamerUri == null) {
            streamerUri =
                Uri.parse(String.format(STREAMER_URL_TEMPLATE, LOCALHOST, portNumber, bookFileName))
        }
        return streamerUri.toString()
    }

    override fun gotoHighRatedBooks(query: String?) {

        val intent = Intent(
            this@FolioActivity,
            HighlyRelatedBooksFragment::class.java
        )
        intent.putExtra(SELECTED_WORD, query)
        intent.putExtra(PUBLICATION, pubBox!!.publication)
        try {
            intent.putExtra(CHAPTER_SELECTED, spine!![currentChapterIndex].href)
            intent.putExtra(HIGHLY_RATED_BOOK_REQ,highlyRatedBookRequestBody)
        } catch (e: NullPointerException) {
            Log.w(LOG_TAG, "-> ", e)
            intent.putExtra(CHAPTER_SELECTED, "")
        } catch (e: IndexOutOfBoundsException) {
            Log.w(LOG_TAG, "-> ", e)
            intent.putExtra(CHAPTER_SELECTED, "")
        }

        intent.putExtra(FolioReader.EXTRA_BOOK_ID, mBookId)
        intent.putExtra(BOOK_TITLE, bookFileName)
        intent.putExtra(FolioReader.DICTIONARY_ID,dictionaryID)
        startActivityForResult(intent, RequestCode.HIGHRATED_BOOKS.value)
        overridePendingTransition(R.anim.slide_in_up, R.anim.slide_out_up)
    }

    override fun goToRelatedQuestion(query: String?) {
        val intent = Intent(
            this@FolioActivity,
            RelatedQuestionScreen::class.java
        )
        intent.putExtra(SELECTED_WORD, query)
        intent.putExtra(FolioReader.DICTIONARY_ID,dictionaryID)
        intent.putExtra(PUBLICATION, pubBox!!.publication)
        try {
            intent.putExtra(CHAPTER_SELECTED, spine!![currentChapterIndex].href)
            intent.putExtra(HIGHLY_RATED_BOOK_REQ,highlyRatedBookRequestBody)
        } catch (e: NullPointerException) {
            Log.w(LOG_TAG, "-> ", e)
            intent.putExtra(CHAPTER_SELECTED, "")
        } catch (e: IndexOutOfBoundsException) {
            Log.w(LOG_TAG, "-> ", e)
            intent.putExtra(CHAPTER_SELECTED, "")
        }

        intent.putExtra(FolioReader.EXTRA_BOOK_ID, mBookId)
        intent.putExtra(BOOK_TITLE, bookFileName)
        startActivityForResult(intent, RequestCode.RELATED_QUESTION.value)
        overridePendingTransition(R.anim.slide_in_up, R.anim.slide_out_up)
    }

    override fun predictChapterCallback(query: String?) {
        val intent = Intent(
            this@FolioActivity,
            PredictConceptScreen::class.java
        )
        intent.putExtra(SELECTED_WORD, query)
        intent.putExtra(PUBLICATION, pubBox!!.publication)
        try {
            intent.putExtra(CHAPTER_SELECTED, spine!![currentChapterIndex].href)
            intent.putExtra(HIGHLY_RATED_BOOK_REQ,highlyRatedBookRequestBody)
        } catch (e: NullPointerException) {
            Log.w(LOG_TAG, "-> ", e)
            intent.putExtra(CHAPTER_SELECTED, "")
        } catch (e: IndexOutOfBoundsException) {
            Log.w(LOG_TAG, "-> ", e)
            intent.putExtra(CHAPTER_SELECTED, "")
        }

        intent.putExtra(FolioReader.EXTRA_BOOK_ID, mBookId)
        intent.putExtra(BOOK_TITLE, bookFileName)
        intent.putExtra(FolioReader.DICTIONARY_ID,dictionaryID)
        startActivityForResult(intent, RequestCode.HIGHRATED_BOOKS.value)
        overridePendingTransition(R.anim.slide_in_up, R.anim.slide_out_up)
    }

    override fun onDirectionChange(newDirection: Config.Direction) {
        Log.v(LOG_TAG, "-> onDirectionChange")

        var folioPageFragment: FolioPageFragment? = currentFragment ?: return
        entryReadLocator = folioPageFragment!!.getLastReadLocator()
        val searchLocatorVisible = folioPageFragment.searchLocatorVisible

        direction = newDirection

        mFolioPageViewPager!!.setDirection(newDirection)
        mFolioPageFragmentAdapter = FolioPageFragmentAdapter(
            supportFragmentManager,
            spine, bookFileName, mBookId
        )
        mFolioPageViewPager!!.adapter = mFolioPageFragmentAdapter
        mFolioPageViewPager!!.currentItem = currentChapterIndex

        folioPageFragment = currentFragment ?: return
        searchLocatorVisible?.let {
            folioPageFragment.highlightSearchLocator(searchLocatorVisible)
        }
    }

    private fun initDistractionFreeMode(savedInstanceState: Bundle?) {
        Log.v(LOG_TAG, "-> initDistractionFreeMode")

        window.decorView.setOnSystemUiVisibilityChangeListener(this)

        // Deliberately Hidden and shown to make activity contents lay out behind SystemUI
        hideSystemUI()
        showSystemUI()

        distractionFreeMode =
            savedInstanceState != null && savedInstanceState.getBoolean(BUNDLE_DISTRACTION_FREE_MODE)
    }

    override fun onPostCreate(savedInstanceState: Bundle?) {
        super.onPostCreate(savedInstanceState)
        Log.v(LOG_TAG, "-> onPostCreate")

        if (distractionFreeMode) {
            handler!!.post { hideSystemUI() }
        }
    }


    override fun getTopDistraction(unit: DisplayUnit): Int {

        var topDistraction = 0
        if (!distractionFreeMode) {
            topDistraction = statusBarHeight
            if (actionBar != null)
                topDistraction += actionBar!!.height
        }

        when (unit) {
            DisplayUnit.PX -> return topDistraction

            DisplayUnit.DP -> {
                topDistraction /= density.toInt()
                return topDistraction
            }

            else -> throw IllegalArgumentException("-> Illegal argument -> unit = $unit")
        }
    }


    override fun getBottomDistraction(unit: DisplayUnit): Int {

        var bottomDistraction = 0
        if (!distractionFreeMode)
            bottomDistraction = appBarLayout!!.navigationBarHeight

        when (unit) {
            DisplayUnit.PX -> return bottomDistraction

            DisplayUnit.DP -> {
                bottomDistraction /= density.toInt()
                return bottomDistraction
            }

            else -> throw IllegalArgumentException("-> Illegal argument -> unit = $unit")
        }
    }

    private fun computeViewportRect(): Rect {
        val viewportRect = Rect(appBarLayout!!.insets)
        if (distractionFreeMode)
            viewportRect.left = 0
        viewportRect.top = getTopDistraction(DisplayUnit.PX)
        if (distractionFreeMode) {
            viewportRect.right = displayMetrics!!.widthPixels
        } else {
            viewportRect.right = displayMetrics!!.widthPixels - viewportRect.right
        }
        viewportRect.bottom = displayMetrics!!.heightPixels - getBottomDistraction(DisplayUnit.PX)

        return viewportRect
    }

    override fun getViewportRect(unit: DisplayUnit): Rect {

        val viewportRect = computeViewportRect()
        when (unit) {
            DisplayUnit.PX -> return viewportRect

            DisplayUnit.DP -> {
                viewportRect.left /= density.toInt()
                viewportRect.top /= density.toInt()
                viewportRect.right /= density.toInt()
                viewportRect.bottom /= density.toInt()
                return viewportRect
            }

            DisplayUnit.CSS_PX -> {
                viewportRect.left = Math.ceil((viewportRect.left / density).toDouble()).toInt()
                viewportRect.top = Math.ceil((viewportRect.top / density).toDouble()).toInt()
                viewportRect.right = Math.ceil((viewportRect.right / density).toDouble()).toInt()
                viewportRect.bottom = Math.ceil((viewportRect.bottom / density).toDouble()).toInt()
                return viewportRect
            }

            else -> throw IllegalArgumentException("-> Illegal argument -> unit = $unit")
        }
    }

    override fun getActivity(): WeakReference<FolioActivity> {
        return WeakReference(this)
    }

    override fun onSystemUiVisibilityChange(visibility: Int) {
        Log.v(LOG_TAG, "-> onSystemUiVisibilityChange -> visibility = $visibility")

        distractionFreeMode = visibility != View.SYSTEM_UI_FLAG_VISIBLE
        Log.v(LOG_TAG, "-> distractionFreeMode = $distractionFreeMode")

        if (actionBar != null) {
            if (distractionFreeMode) {
                actionBar!!.hide()
            } else {
                actionBar!!.show()
            }
        }
    }

    override fun toggleSystemUI() {

        if (distractionFreeMode) {
            showSystemUI()
        } else {
            hideSystemUI()
        }
    }


    private fun showSystemUI() {

        val decorView = window.decorView
        decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN)
    }

    private fun hideSystemUI() {
        val decorView = window.decorView
        decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_IMMERSIVE
                // Set the content to appear under the system bars so that the
                // content doesn't resize when the system bars hide and show.
                or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                // Hide the nav bar and status bar
                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_FULLSCREEN)
    }

    override fun getEntryReadLocator(): ReadLocator? {
        if (entryReadLocator != null) {
            val tempReadLocator = entryReadLocator
            entryReadLocator = null
            return tempReadLocator
        }
        return null
    }


    override fun goToChapter(href: String): Boolean {

        for (link in spine!!) {
            if (href.contains(link.href!!)) {
                currentChapterIndex = spine!!.indexOf(link)
                mFolioPageViewPager!!.currentItem = currentChapterIndex
                val folioPageFragment = currentFragment
                folioPageFragment!!.scrollToFirst()
                folioPageFragment.scrollToAnchorId(href)
                return true
            }
        }
        return false
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == RequestCode.SEARCH.value) {
            Log.v(LOG_TAG, "-> onActivityResult -> " + RequestCode.SEARCH)

            if (resultCode == Activity.RESULT_CANCELED)
                return

            searchAdapterDataBundle = data!!.getBundleExtra(SearchAdapter.DATA_BUNDLE)
            searchQuery = data.getCharSequenceExtra(SearchActivity.BUNDLE_SAVE_SEARCH_QUERY)

            if (resultCode == SearchActivity.ResultCode.ITEM_SELECTED.value) {

                searchLocator = data.getParcelableExtra(EXTRA_SEARCH_ITEM)
                // In case if SearchActivity is recreated due to screen rotation then FolioActivity
                // will also be recreated, so mFolioPageViewPager might be null.
                if (mFolioPageViewPager == null) return
                currentChapterIndex = getChapterIndex(HREF, searchLocator!!.href)
                mFolioPageViewPager!!.currentItem = currentChapterIndex
                val folioPageFragment = currentFragment ?: return
                folioPageFragment.highlightSearchLocator(searchLocator!!)
                searchLocator = null
            }

        } else if (requestCode == RequestCode.CONTENT_HIGHLIGHT.value && resultCode == Activity.RESULT_OK && data!!.hasExtra(TYPE)) {

            val type = data.getStringExtra(TYPE)

            if (type == CHAPTER_SELECTED) {
                goToChapter(data.getStringExtra(SELECTED_CHAPTER_POSITION)!!)

            } else if (type == HIGHLIGHT_SELECTED) {
                val highlightImpl = data.getParcelableExtra<HighlightImpl>(HIGHLIGHT_ITEM)
                if (mBookId == highlightImpl!!.bookId) {
                    currentChapterIndex = highlightImpl.pageNumber
                    mFolioPageViewPager!!.currentItem = currentChapterIndex
                    val folioPageFragment = currentFragment ?: return
                    folioPageFragment.scrollToHighlightId(highlightImpl.rangy)
                } else {
                    loadingView!!.show()
                    this.selectedHighlightedImpl = highlightImpl
                    downloadEpubFile("https://www.gutenberg.org/ebooks/66521.epub.images?session_id=d7faf6922df488c8785369563a0f5f2929fddd31","")
                }


            } else if (type == DIFFICULTY_LEVEL_SELECTED) {
                val toughNessImpl = data.getParcelableExtra<ToughnessImpl>(HIGHLIGHT_ITEM)
                currentChapterIndex = toughNessImpl!!.pageNumber
                mFolioPageViewPager!!.currentItem = currentChapterIndex
                val folioPageFragment = currentFragment ?: return
                folioPageFragment.scrollToHighlightId(toughNessImpl.rangy)
            } else if (type == EXAM_LIKE_HOOD_SELECTED) {
                val examLikeHoodImpl = data.getParcelableExtra<ExamLikeHoodImpl>(HIGHLIGHT_ITEM)
                currentChapterIndex = examLikeHoodImpl!!.pageNumber
                mFolioPageViewPager!!.currentItem = currentChapterIndex
                val folioPageFragment = currentFragment ?: return
                folioPageFragment.scrollToHighlightId(examLikeHoodImpl.rangy)
            }
        } else if (requestCode == RequestCode.HIGHRATED_BOOKS.value && resultCode == Activity.RESULT_OK && data!!.hasExtra(TYPE)) {

            val type = data.getStringExtra(TYPE)
            val redirectString = data.getStringExtra(SELECTED_WORD)
            val highlyRelatedBooksModel=data.getSerializableExtra(SELECTED_HIGH_RATED_BOOK) as HighlyRelatedBooksModel
            if (type == HIGHLY_RELATED_BOOK_SELECTED) {
                loadingView!!.show()
                downloadEpubFile(highlyRelatedBooksModel.EPUB_link,redirectString!!)
            }
        } else if (requestCode == RequestCode.RELATED_QUESTION.value && resultCode == Activity.RESULT_OK && data!!.hasExtra(TYPE)) {
            val type = data.getStringExtra(TYPE)
            val redirectString = data.getStringExtra(SELECTED_WORD)
            val highlyRelatedBooksModel=data.getSerializableExtra(SELECTED_HIGH_RATED_BOOK) as RelatedQuestionModel
            if (type == HIGHLY_RELATED_BOOK_SELECTED) {
                loadingView!!.show()
                downloadEpubFile(highlyRelatedBooksModel.download_link,redirectString!!)

            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (outState != null)
            outState!!.putSerializable(BUNDLE_READ_LOCATOR_CONFIG_CHANGE, lastReadLocator)
        val localBroadcastManager = LocalBroadcastManager.getInstance(this)
        localBroadcastManager.unregisterReceiver(searchReceiver)
        localBroadcastManager.unregisterReceiver(closeBroadcastReceiver)
        if(!isFolioActivityCopyInstance){
              if (r2StreamerServer != null)
               r2StreamerServer!!.stop()

        if (isFinishing) {
            localBroadcastManager.sendBroadcast(Intent(FolioReader.ACTION_FOLIOREADER_CLOSED))
            FolioReader.get().retrofit = null
            FolioReader.get().r2StreamerApi = null
        }
        }
    }

    override fun getCurrentChapterIndex(): Int {
        return currentChapterIndex
    }

    private fun configFolio() {

        mFolioPageViewPager = findViewById(R.id.folioPageViewPager)
        // Replacing with addOnPageChangeListener(), onPageSelected() is not invoked
        mFolioPageViewPager!!.setOnPageChangeListener(object :
            DirectionalViewpager.OnPageChangeListener {
            override fun onPageScrolled(
                position: Int,
                positionOffset: Float,
                positionOffsetPixels: Int
            ) {

            }

            override fun onPageSelected(position: Int) {
                Log.v(LOG_TAG, "-> onPageSelected -> DirectionalViewpager -> position = $position")

                EventBus.getDefault().post(
                    MediaOverlayPlayPauseEvent(
                        spine!![currentChapterIndex].href, false, true
                    )
                )
                mediaControllerFragment!!.setPlayButtonDrawable()
                currentChapterIndex = position
            }

            override fun onPageScrollStateChanged(state: Int) {

                if (state == DirectionalViewpager.SCROLL_STATE_IDLE) {
                    val position = mFolioPageViewPager!!.currentItem
                    Log.v(
                        LOG_TAG, "-> onPageScrollStateChanged -> DirectionalViewpager -> " +
                                "position = " + position
                    )

                    var folioPageFragment =
                        mFolioPageFragmentAdapter!!.getItem(position - 1) as FolioPageFragment?
                    if (folioPageFragment != null) {
                        folioPageFragment.scrollToLast()
                        if (folioPageFragment.mWebview != null)
                            folioPageFragment.mWebview!!.dismissPopupWindow()
                    }

                    folioPageFragment =
                        mFolioPageFragmentAdapter!!.getItem(position + 1) as FolioPageFragment?
                    if (folioPageFragment != null) {
                        folioPageFragment.scrollToFirst()
                        if (folioPageFragment.mWebview != null)
                            folioPageFragment.mWebview!!.dismissPopupWindow()
                    }
                }
            }
        })

        mFolioPageViewPager!!.setDirection(direction)
        mFolioPageFragmentAdapter = FolioPageFragmentAdapter(
            supportFragmentManager,
            spine, bookFileName, mBookId
        )
        mFolioPageViewPager!!.adapter = mFolioPageFragmentAdapter

        // In case if SearchActivity is recreated due to screen rotation then FolioActivity
        // will also be recreated, so searchLocator is checked here.
        if (searchLocator != null) {

            currentChapterIndex = getChapterIndex(HREF, searchLocator!!.href)
            mFolioPageViewPager!!.currentItem = currentChapterIndex
            val folioPageFragment = currentFragment ?: return
            folioPageFragment.highlightSearchLocator(searchLocator!!)
            searchLocator = null

        } else {

            val readLocator: ReadLocator?
            if (savedInstanceState == null) {
                readLocator = intent.getParcelableExtra(EXTRA_READ_LOCATOR)
                entryReadLocator = readLocator
            } else {
                readLocator = savedInstanceState!!.getParcelable(BUNDLE_READ_LOCATOR_CONFIG_CHANGE)
                lastReadLocator = readLocator
            }
            currentChapterIndex = getChapterIndex(readLocator)
            mFolioPageViewPager!!.currentItem = currentChapterIndex
        }

        LocalBroadcastManager.getInstance(this).registerReceiver(
            searchReceiver,
            IntentFilter(ACTION_SEARCH_CLEAR)
        )


        if (isScrollToRangy && (selectedHighlightedImpl.rangy != null)) {

            currentChapterIndex = selectedHighlightedImpl.pageNumber
            mFolioPageViewPager!!.currentItem = currentChapterIndex
            val folioPageFragment = currentFragment ?: return
            folioPageFragment.scrollToHighlightId(selectedHighlightedImpl.rangy)
            isScrollToRangy = false
        } else if (isScrollToParagraph) {
            val searchableParagraph = intent.getStringExtra(FolioReader.EXTRA__SEARCH_PARAGRAPH_QUERY)
            if (searchUri != null) {
                val handler = Handler()
                handler.postDelayed({
                    val intent = Intent(this, SearchActivity::class.java)
                    intent.putExtra(SearchActivity.BUNDLE_SPINE_SIZE, spine?.size ?: 0)
                    intent.putExtra(SearchActivity.BUNDLE_SEARCH_URI, searchUri)
                    intent.putExtra(SearchAdapter.DATA_BUNDLE, searchAdapterDataBundle)
                    intent.putExtra(SearchActivity.BUNDLE_SAVE_SEARCH_QUERY, searchableParagraph)
                    intent.putExtra(SearchActivity.BUNDLE_IS_SEARCH_SUBMIT,true)
                    startActivityForResult(intent, RequestCode.SEARCH.value)
                }, 5000)

            }
        }

    }

    private fun getChapterIndex(readLocator: ReadLocator?): Int {

        if (readLocator == null) {
            return 0
        } else if (!TextUtils.isEmpty(readLocator.href)) {
            return getChapterIndex(HREF, readLocator.href)
        }

        return 0
    }

    private fun getChapterIndex(caseString: String, value: String): Int {
        for (i in spine!!.indices) {
            when (caseString) {
                HREF -> if (spine!![i].href == value)
                    return i
            }
        }
        return 0
    }


    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        Log.v(LOG_TAG, "-> onSaveInstanceState")
        this.outState = outState

        outState.putBoolean(BUNDLE_DISTRACTION_FREE_MODE, distractionFreeMode)
        outState.putBundle(SearchAdapter.DATA_BUNDLE, searchAdapterDataBundle)
        outState.putCharSequence(SearchActivity.BUNDLE_SAVE_SEARCH_QUERY, searchQuery)
    }

    override fun storeLastReadLocator(lastReadLocator: ReadLocator) {
        Log.v(LOG_TAG, "-> storeLastReadLocator")
        this.lastReadLocator = lastReadLocator
    }

    private fun setConfig(savedInstanceState: Bundle?) {

        var config: Config?
        val intentConfig = intent.getParcelableExtra<Config>(Config.INTENT_CONFIG)
        val overrideConfig = intent.getBooleanExtra(Config.EXTRA_OVERRIDE_CONFIG, false)
        val savedConfig = AppUtil.getSavedConfig(this)

        if (savedInstanceState != null) {
            config = savedConfig

        } else if (savedConfig == null) {
            if (intentConfig == null) {
                config = Config()
            } else {
                config = intentConfig
            }

        } else {
            if (intentConfig != null && overrideConfig) {
                config = intentConfig
            } else {
                config = savedConfig
            }
        }

        // Code would never enter this if, just added for any unexpected error
        // and to avoid lint warning
        if (config == null)
            config = Config()

        config.isNightMode=false

        AppUtil.saveConfig(this, config)
        direction = config.direction
    }

    override fun play() {
        EventBus.getDefault().post(
            MediaOverlayPlayPauseEvent(
                spine!![currentChapterIndex].href, true, false
            )
        )
    }

    override fun pause() {
        EventBus.getDefault().post(
            MediaOverlayPlayPauseEvent(
                spine!![currentChapterIndex].href, false, false
            )
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        when (requestCode) {
            Constants.WRITE_EXTERNAL_STORAGE_REQUEST -> if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                setupBook()
            } else {
                Toast.makeText(
                    this,
                    getString(R.string.cannot_access_epub_message),
                    Toast.LENGTH_LONG
                ).show()
                finish()
            }
        }
    }

    override fun getDirection(): Config.Direction {
        return direction
    }

    private fun clearSearchLocator() {
        Log.v(LOG_TAG, "-> clearSearchLocator")

        val fragments = mFolioPageFragmentAdapter!!.fragments
        for (i in fragments.indices) {
            val folioPageFragment = fragments[i] as FolioPageFragment?
            folioPageFragment?.clearSearchLocator()
        }

        val savedStateList = mFolioPageFragmentAdapter!!.savedStateList
        if (savedStateList != null) {
            for (i in savedStateList.indices) {
                val savedState = savedStateList[i]
                val bundle = FolioPageFragmentAdapter.getBundleFromSavedState(savedState)
                bundle?.putParcelable(FolioPageFragment.BUNDLE_SEARCH_LOCATOR, null)
            }
        }
    }


    private fun askForPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            if (!Environment.isExternalStorageManager()) {
                val intent: Intent = Intent(ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)
                startActivity(intent)
                return
            }
        }
    }



    private fun downloadEpubFile(url: String,selectedPara:String) {
        val baseDir = Environment.getExternalStorageDirectory().absolutePath
        val fileName = "sway.epub"
        val targetFile = File(baseDir + File.separator + fileName)


        if (targetFile.exists()) {
            targetFile.delete()
            targetFile.createNewFile()
        } else {
            targetFile.createNewFile()
        }
        disposable = fileDownloader.download(url, targetFile)
            .throttleFirst(2, TimeUnit.SECONDS)
            .toFlowable(BackpressureStrategy.LATEST)
            .subscribeOn(Schedulers.io())
            .observeOn(mainThread())
            .subscribe({
            }, {
                loadingView!!.hide()
                Toast.makeText(this, it.localizedMessage, Toast.LENGTH_SHORT).show()
            }, {
                loadingView!!.hide()
                val lastLocation = """{
                    "bookId" : "2239",
                    "href": "/OEBPS/ch06.xhtml",
                    "created": 1539934158390,
                    "locations": {
                    "cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"
                }}"""

                openEPubFile(targetFile.absolutePath, lastLocation,selectedPara)
            })

    }

    private fun openEPubFile(bookPath: String?, lastLocation: String,selectedPara: String) {

        val folioReader = FolioReader.get()
        val readerConfig = ReaderConfig(
            applicationContext,
            "iosBook",
            "#2196f3",
            "ALLDIRECTIONS",
            true,
            true,
            true
        )
        val path: String? = bookPath
        val location: String = lastLocation

        Thread {
            try {
                if (!location.isEmpty()) {
                    val readLocator: ReadLocator? = ReadLocator.fromJson(location)
                    folioReader.setReadLocator(readLocator)
                }
                folioReader.setConfig(readerConfig.config, true)
                    .openBook(path, true, selectedPara,highlyRatedBookRequestBody!!)
            } catch (e: java.lang.Exception) {
                e.printStackTrace()
            }
        }.start()

    }

    private fun openEPubFileFromAssets(
        bookPath: String?,
        lastLocation: String,
        paragraphQuery: String
    ) {

        val folioReader = FolioReader.get()
        val readerConfig = ReaderConfig(
            applicationContext,
            "iosBook",
            "#2196f3",
            "ALLDIRECTIONS",
            true,
            true,
            true
        )
        val path: String? = bookPath
        val location: String = lastLocation

        Thread {
            try {
                if (!location.isEmpty()) {
                    val readLocator: ReadLocator? = ReadLocator.fromJson(location)
                    folioReader.setReadLocator(readLocator)
                }
                folioReader.setConfig(readerConfig.config, true)
                    .openBook(path, true, paragraphQuery,highlyRatedBookRequestBody)
            } catch (e: java.lang.Exception) {
                e.printStackTrace()
            }
        }.start()

    }


    private fun fileFromAsset(name: String): File =
        File("$cacheDir/$name").apply { writeBytes(assets.open(name).readBytes()) }


}