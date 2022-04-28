package com.sparrowrms.hyspro.util;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.sparrowrms.hyspro.model.Toughness;
import com.sparrowrms.hyspro.model.ToughnessImpl;
import com.sparrowrms.hyspro.model.sqlite.ToughnessLevelTable;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.List;

public class ToughnessUtil {

    private static final String TAG = "HighlightUtil";

    public static String createToughnessRangy(Context context,
                                              String content,
                                              String bookId,
                                              String pageId,
                                              int pageNo,
                                              String oldRangy) {
        try {
            JSONObject jObject = new JSONObject(content);

            String rangy = jObject.getString("rangy");
            String textContent = jObject.getString("content");
            String color = jObject.getString("color");
            String rangyHighlightElement = getRangyString(rangy, oldRangy);
            ToughnessImpl toughnessImpl = new ToughnessImpl();
            toughnessImpl.setContent(textContent);
            toughnessImpl.setType(color);
            toughnessImpl.setPageNumber(pageNo);
            toughnessImpl.setBookId(bookId);
            toughnessImpl.setPageId(pageId);
            toughnessImpl.setRangy(rangyHighlightElement);
            toughnessImpl.setDate(Calendar.getInstance().getTime());
            // save highlight to database
            long id = ToughnessLevelTable.insertToughNess(toughnessImpl);
            if (id != -1) {
                toughnessImpl.setId((int) id);
                sendToughNessBroadcastEvent(context, toughnessImpl, Toughness.ToughnessAction.NEW);
            }
            return rangy;
        } catch (JSONException e) {
            Log.e(TAG, "createHighlightRangy failed", e);
        }
        return "";
    }

    private static String getRangyString(String rangy, String oldRangy) {
        List<String> rangyList = getRangyArray(rangy);
        for (String firs : getRangyArray(oldRangy)) {
            if (rangyList.contains(firs)) {
                rangyList.remove(firs);
            }
        }
        if (rangyList.size() >= 1) {
            return rangyList.get(0);
        } else {
            return "";
        }
    }


    private static List<String> getRangyArray(String rangy) {
        List<String> rangyElementList = new ArrayList<>();
        rangyElementList.addAll(Arrays.asList(rangy.split("\\|")));
        if (rangyElementList.contains("type:textContent")) {
            rangyElementList.remove("type:textContent");
        } else if (rangyElementList.contains("")) {
            return new ArrayList<>();
        }
        return rangyElementList;
    }

    public static String generateRangyString(String pageId) {
        List<String> rangyList = ToughnessLevelTable.getToughNessForPageId(pageId);
        StringBuilder builder = new StringBuilder();
        if (!rangyList.isEmpty()) {
            builder.append("type:textContent");
            for (String rangy : rangyList) {
                builder.append('|');
                builder.append(rangy);
            }
        }
        return builder.toString();
    }

    public static void sendToughNessBroadcastEvent(Context context,
                                                   ToughnessImpl highlightImpl,
                                                   Toughness.ToughnessAction action) {
        LocalBroadcastManager.getInstance(context).sendBroadcast(
                getHighlightBroadcastIntent(highlightImpl, action));
    }

    public static Intent getHighlightBroadcastIntent(ToughnessImpl highlightImpl,
                                                     Toughness.ToughnessAction modify) {
        Bundle bundle = new Bundle();
        bundle.putParcelable(ToughnessImpl.INTENT, highlightImpl);
        bundle.putSerializable(Toughness.ToughnessAction.class.getName(), modify);
        return new Intent(ToughnessImpl.BROADCAST_EVENT).putExtras(bundle);
    }
}
