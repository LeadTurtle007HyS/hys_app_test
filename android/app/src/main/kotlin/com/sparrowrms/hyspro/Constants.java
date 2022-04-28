package com.sparrowrms.hyspro;

import android.Manifest;
import android.view.TextureView;

import io.agora.rtc.RtcEngine;


public class Constants {
    public static final String PUBLICATION = "PUBLICATION";
    public static final String SELECTED_CHAPTER_POSITION = "selected_chapter_position";
    public static final String TYPE = "type";
    public static final String CHAPTER_SELECTED = "chapter_selected";
    public static final String HIGHLIGHT_SELECTED = "highlight_selected";
    public static final String HIGHLY_RELATED_BOOK_SELECTED = "highly_related_book_selected";
    public static final String DIFFICULTY_LEVEL_SELECTED="difficulty_level_selected";
    public static final String EXAM_LIKE_HOOD_SELECTED="exam_like_hood_selected";
    public static final String BOOK_TITLE = "book_title";

    public static final String LOCALHOST = "http://127.0.0.1";
    public static final int DEFAULT_PORT_NUMBER = 8080;
    public static final String STREAMER_URL_TEMPLATE = "%s:%d/%s/";
    public static final String DEFAULT_STREAMER_URL = LOCALHOST + ":" + DEFAULT_PORT_NUMBER + "/";

    public static final String SELECTED_WORD = "selected_word";
    public static final String SELECTED_YEAR="selected_question_paper_year";

    public static final String SELECTED_HIGH_RATED_BOOK = "selected_high_rated_book";

    public static final String DICTIONARY_BASE_URL = "https://api.pearson.com/v2/dictionaries/entries?headword=";
    public static final String WIKIPEDIA_API_URL = "https://en.wikipedia.org/w/api.php?action=opensearch&namespace=0&format=json&search=";
    public static final int FONT_ANDADA = 1;
    public static final int FONT_LATO = 2;
    public static final int FONT_LORA = 3;
    public static final int FONT_RALEWAY = 4;
    public static final String DATE_FORMAT = "MMM dd, yyyy | HH:mm";
    public static final String ASSET = "file:///android_asset/";
    public static final int WRITE_EXTERNAL_STORAGE_REQUEST = 102;
    public static final String CHAPTER_ID = "id";
    public static final String HREF = "href";

    public static String[] getWriteExternalStoragePerms() {
        return new String[]{
                Manifest.permission.WRITE_EXTERNAL_STORAGE
        };
    }


    //  Firebase Constant

    public static final String USERS_NODE = "userpersonaldata";
    public static final String USER_NOTIFICATIO_TOKEN_NODE = "notificationtokendata";
    public static final String FRIEND_REQUEST_NODE = "friend_request";
    public static final String FRIEND_REQUEST_TYPE = "request_type";
    public static final String REQUEST_NODE = "request";
    public static final String IMAGE_TYPE = "image";
    public static final String TEXT_TYPE = "text";
    public static final String MESSAGE_NODE = "messages";

    public static final String HYS_CALL_DATA_NODE="hys_calling_data";
    public static final String HYS_USER_CALL_STATUS_NODE="usercallstatus";

    public static final String HYS_CALL_NOTIFY_TO_USER_NODE="callingresponsetosuperuserquestionadded";



    //  Hardware Constant

    public static final String CAMERA_ENABLED = "is_camera_enabled";
    public static final String  IS_CURRENT_CAMERA_FRONT = "is_camera_front";
    public static final String  SPEAKER_ENABLED = "is_speaker_enabled";
    public static final String MIC_ENABLED = "is_microphone_enabled";

    public static final String  EXTRA_IS_INCOMING_CALL = "conversation_reason";

    public static final String  EXTRA_IS_VIDEO_CALL = "conversation_type_video";


    // calling details

    public static final String userDetailsKey="Calling_User_Details";
    public static final String EXTRA_CALLING_NOTIFICATION_DETAILS="calling_notification_details";



    // Notification Constants

    public static final String EXTRA_NOTIFICATION_BUTTON_ACTION="notification_button_action";
    public static final String EXTRA_NOTIFICATION_BUTTON_ACTION_DATA="notification_button_action_data";

    public static final String EXTRA_NOTIFICATION_SCREEN_SHARE_ACTION="notification_screen_share_action";



    public static final String WATER_MARK_FILE_PATH = "/assets/agora-logo.png";

    public static TextureView TEXTUREVIEW;

    public static RtcEngine ENGINE;

    public static String TIPS = "tips";

    public static String DATA = "data";

    public static final String MIX_FILE_PATH = "/assets/music_1.m4a";

    public static final String EFFECT_FILE_PATH = "/assets/effectA.wav";



    //  Agora whiteboard Token

    public static final String AGORA_WHITEBOARD_SDK_TOKEN="NETLESSSDK_YWs9aGlJUFh6cWszU1hfNDhBbiZub25jZT03NTJlY2FkMC01Njg2LTExZWMtODg5NC1mNzI5MTE5NDBkNWEmcm9sZT0wJnNpZz00NzZjZDM1MGQ4ZGY3Mjg2MWY2NmY5ZmJjMDBhYjg5Mjk0MDk2YjBmMzU0OWZjNjU2Mzc1ZTFjNGRlZDI1MDFi";
    public static final String REGION="in-mum";



}
