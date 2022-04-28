package com.sparrowrms.hyspro.util;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.sparrowrms.hyspro.model.ExamLikeHood;
import com.sparrowrms.hyspro.model.ExamLikeHoodImpl;
import com.sparrowrms.hyspro.model.sqlite.ExamLikeHoodTable;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.List;

public class ExamLikeHoodUtil {

    private static final String TAG = "ExamlikehoodUtil";

    public static String createExamLikeHoodRangy(Context context,
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

            ExamLikeHoodImpl highlightImpl = new ExamLikeHoodImpl();
            highlightImpl.setContent(textContent);
            highlightImpl.setType(color);
            highlightImpl.setPageNumber(pageNo);
            highlightImpl.setBookId(bookId);
            highlightImpl.setPageId(pageId);
            highlightImpl.setRangy(rangyHighlightElement);
            highlightImpl.setDate(Calendar.getInstance().getTime());
            // save highlight to database
            long id = ExamLikeHoodTable.insertExamLikeHood(highlightImpl);
            if (id != -1) {
                highlightImpl.setId((int) id);
                sendHighlightBroadcastEvent(context, highlightImpl, ExamLikeHood.ExamLikeHoodAction.NEW);
            }
            return rangy;
        } catch (JSONException e) {
            Log.e(TAG, "createHighlightRangy failed", e);
        }
        return "";
    }

    /**
     * function extracts rangy element corresponding to latest highlight.
     *
     * @param rangy    new rangy string generated after adding new highlight.
     * @param oldRangy rangy string before new highlight.
     * @return rangy element corresponding to latest element.
     */
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

    /**
     * function converts Rangy text into each individual element
     * splitting with '|'.
     *
     * @param rangy rangy test with format: type:textContent|start$end$id$class$containerId
     * @return ArrayList of each rangy element corresponding to each highlight
     */
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
        List<String> rangyList = ExamLikeHoodTable.getExamLikeHoodForPageId(pageId);
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

    public static void sendHighlightBroadcastEvent(Context context,
                                                   ExamLikeHoodImpl highlightImpl,
                                                   ExamLikeHood.ExamLikeHoodAction action) {
        LocalBroadcastManager.getInstance(context).sendBroadcast(
                getHighlightBroadcastIntent(highlightImpl, action));
    }

    public static Intent getHighlightBroadcastIntent(ExamLikeHoodImpl highlightImpl,
                                                     ExamLikeHood.ExamLikeHoodAction  modify) {
        Bundle bundle = new Bundle();
        bundle.putParcelable(ExamLikeHoodImpl.INTENT, highlightImpl);
        bundle.putSerializable(ExamLikeHood.ExamLikeHoodAction.class.getName(), modify);
        return new Intent(ExamLikeHoodImpl.BROADCAST_EVENT).putExtras(bundle);
    }
}
