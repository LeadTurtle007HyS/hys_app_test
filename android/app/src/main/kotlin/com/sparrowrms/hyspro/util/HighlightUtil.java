package com.sparrowrms.hyspro.util;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import com.sparrowrms.hyspro.model.HighLight;
import com.sparrowrms.hyspro.model.HighlightImpl;
import com.sparrowrms.hyspro.model.sqlite.HighLightTable;
import com.sparrowrms.hyspro.model.sqlite.ToughnessLevelTable;
import com.sparrowrms.hyspro.model.sqlite.ExamLikeHoodTable;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.List;

/**
 * Created by priyank on 5/12/16.
 */
public class HighlightUtil {

    private static final String TAG = "HighlightUtil";

    public static String createHighlightRangy(Context context,
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

            HighlightImpl highlightImpl = new HighlightImpl();
            highlightImpl.setContent(textContent);
            highlightImpl.setType(color);
            highlightImpl.setPageNumber(pageNo);
            highlightImpl.setBookId(bookId);
            highlightImpl.setPageId(pageId);
            highlightImpl.setRangy(rangyHighlightElement);
            highlightImpl.setDate(Calendar.getInstance().getTime());
            // save highlight to database
            long id = HighLightTable.insertHighlight(highlightImpl);
            if (id != -1) {
                highlightImpl.setId((int) id);
                sendHighlightBroadcastEvent(context, highlightImpl, HighLight.HighLightAction.NEW);
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
        List<String> rangyList = HighLightTable.getHighlightsForPageId(pageId);
        List<String> rangyList2=ToughnessLevelTable.getToughNessForPageId(pageId);
        List<String> rangyList3=ExamLikeHoodTable.getExamLikeHoodForPageId(pageId);
        rangyList.addAll(rangyList2);
        rangyList.addAll(rangyList3);
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
                                                   HighlightImpl highlightImpl,
                                                   HighLight.HighLightAction action) {
        LocalBroadcastManager.getInstance(context).sendBroadcast(
                getHighlightBroadcastIntent(highlightImpl, action));
    }

    public static Intent getHighlightBroadcastIntent(HighlightImpl highlightImpl,
                                                     HighLight.HighLightAction modify) {
        Bundle bundle = new Bundle();
        bundle.putParcelable(HighlightImpl.INTENT, highlightImpl);
        bundle.putSerializable(HighLight.HighLightAction.class.getName(), modify);
        return new Intent(HighlightImpl.BROADCAST_EVENT).putExtras(bundle);
    }
}
