package com.sparrowrms.hyspro.model.sqlite;

import android.content.ContentValues;
import android.database.Cursor;
import android.text.TextUtils;
import android.util.Log;
import com.sparrowrms.hyspro.Constants;
import com.sparrowrms.hyspro.model.Toughness;
import com.sparrowrms.hyspro.model.ToughnessImpl;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

public class ToughnessLevelTable  {
    public static final String TABLE_NAME = "toughness_table";

    public static final String ID = "_id";
    public static final String COL_BOOK_ID = "bookId";
    private static final String COL_CONTENT = "content";
    private static final String COL_DATE = "date";
    private static final String COL_TYPE = "type";
    private static final String COL_PAGE_NUMBER = "page_number";
    private static final String COL_PAGE_ID = "pageId";
    private static final String COL_RANGY = "rangy";
    private static final String COL_NOTE = "note";
    private static final String COL_UUID = "uuid";

    public static final String SQL_CREATE = "CREATE TABLE IF NOT EXISTS " + TABLE_NAME + " ( " + ID
            + " INTEGER PRIMARY KEY AUTOINCREMENT" + ","
            + COL_BOOK_ID + " TEXT" + ","
            + COL_CONTENT + " TEXT" + ","
            + COL_DATE + " TEXT" + ","
            + COL_TYPE + " TEXT" + ","
            + COL_PAGE_NUMBER + " INTEGER" + ","
            + COL_PAGE_ID + " TEXT" + ","
            + COL_RANGY + " TEXT" + ","
            + COL_UUID + " TEXT" + ","
            + COL_NOTE + " TEXT" + ")";

    public static final String SQL_DROP = "DROP TABLE IF EXISTS " + TABLE_NAME;

    public static final String TAG = HighLightTable.class.getSimpleName();

    public static ContentValues getToughNessContentValues(Toughness highLight) {
        ContentValues contentValues = new ContentValues();
        contentValues.put(COL_BOOK_ID, highLight.getBookId());
        contentValues.put(COL_CONTENT, highLight.getContent());
        contentValues.put(COL_DATE, getDateTimeString(highLight.getDate()));
        contentValues.put(COL_TYPE, highLight.getType());
        contentValues.put(COL_PAGE_NUMBER, highLight.getPageNumber());
        contentValues.put(COL_PAGE_ID, highLight.getPageId());
        contentValues.put(COL_RANGY, highLight.getRangy());
        contentValues.put(COL_NOTE, highLight.getNote());
        contentValues.put(COL_UUID, highLight.getUUID());
        return contentValues;
    }


    public static ArrayList<ToughnessImpl> getAllToughNess(String bookId) {
        ArrayList<ToughnessImpl> highlights = new ArrayList<>();
        Cursor highlightCursor = DbAdapter.getToughNessForBookId(bookId);
        while (highlightCursor.moveToNext()) {
            highlights.add(new ToughnessImpl(highlightCursor.getInt(highlightCursor.getColumnIndex(ID)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_BOOK_ID)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_CONTENT)),
                    getDateTime(highlightCursor.getString(highlightCursor.getColumnIndex(COL_DATE))),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_TYPE)),
                    highlightCursor.getInt(highlightCursor.getColumnIndex(COL_PAGE_NUMBER)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_PAGE_ID)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_RANGY)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_NOTE)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_UUID))));
        }
        return highlights;
    }

    public static ArrayList<ToughnessImpl> getAllToughNessWithType(String bookId,String type) {
        ArrayList<ToughnessImpl> highlights = new ArrayList<>();
        Cursor highlightCursor = DbAdapter.getToughNessForBookId(bookId);
        while (highlightCursor.moveToNext()) {
            if( highlightCursor.getString(highlightCursor.getColumnIndex(COL_TYPE)).equalsIgnoreCase(type)){
                highlights.add(new ToughnessImpl(highlightCursor.getInt(highlightCursor.getColumnIndex(ID)),
                        highlightCursor.getString(highlightCursor.getColumnIndex(COL_BOOK_ID)),
                        highlightCursor.getString(highlightCursor.getColumnIndex(COL_CONTENT)),
                        getDateTime(highlightCursor.getString(highlightCursor.getColumnIndex(COL_DATE))),
                        highlightCursor.getString(highlightCursor.getColumnIndex(COL_TYPE)),
                        highlightCursor.getInt(highlightCursor.getColumnIndex(COL_PAGE_NUMBER)),
                        highlightCursor.getString(highlightCursor.getColumnIndex(COL_PAGE_ID)),
                        highlightCursor.getString(highlightCursor.getColumnIndex(COL_RANGY)),
                        highlightCursor.getString(highlightCursor.getColumnIndex(COL_NOTE)),
                        highlightCursor.getString(highlightCursor.getColumnIndex(COL_UUID))));   
            }
           
        }
        return highlights;
    }

    public static ToughnessImpl getToughNessId(int id) {
        Cursor highlightCursor = DbAdapter.getToughnessForId(id);
        ToughnessImpl highlightImpl = new ToughnessImpl();
        while (highlightCursor.moveToNext()) {
            highlightImpl = new ToughnessImpl(highlightCursor.getInt(highlightCursor.getColumnIndex(ID)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_BOOK_ID)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_CONTENT)),
                    getDateTime(highlightCursor.getString(highlightCursor.getColumnIndex(COL_DATE))),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_TYPE)),
                    highlightCursor.getInt(highlightCursor.getColumnIndex(COL_PAGE_NUMBER)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_PAGE_ID)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_RANGY)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_NOTE)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_UUID)));

        }
        return highlightImpl;
    }

    public static long insertToughNess(ToughnessImpl highlightImpl) {
        highlightImpl.setUUID(UUID.randomUUID().toString());
        return DbAdapter.saveToughness(getToughNessContentValues(highlightImpl));
    }

    public static boolean deleteToughNess(String rangy) {
        String query = "SELECT " + ID + " FROM " + TABLE_NAME + " WHERE " + COL_RANGY + " = \"" + rangy + "\"";
        int id = DbAdapter.getIdForQuery(query);
        return id != -1 && deleteToughNess(id);
    }

    public static boolean deleteToughNess(int highlightId) {
        return DbAdapter.deleteById(TABLE_NAME, ID, String.valueOf(highlightId));
    }

    public static List<String> getToughNessForPageId(String pageId) {
        String query = "SELECT " + COL_RANGY + " FROM " + TABLE_NAME + " WHERE " + COL_PAGE_ID + " = \"" + pageId + "\"";
        Cursor c = DbAdapter.getHighlightsForPageId(query, pageId);
        List<String> rangyList = new ArrayList<>();
        while (c.moveToNext()) {
            rangyList.add(c.getString(c.getColumnIndex(COL_RANGY)));
        }
        c.close();
        return rangyList;
    }

    public static boolean updateToughNess(ToughnessImpl highlightImpl) {
        return DbAdapter.updateToughness(getToughNessContentValues(highlightImpl), String.valueOf(highlightImpl.getId()));
    }

    public static String getDateTimeString(Date date) {
        SimpleDateFormat dateFormat = new SimpleDateFormat(
                Constants.DATE_FORMAT, Locale.getDefault());
        return dateFormat.format(date);
    }

    public static Date getDateTime(String date) {
        SimpleDateFormat dateFormat = new SimpleDateFormat(
                Constants.DATE_FORMAT, Locale.getDefault());
        Date date1 = new Date();
        try {
            date1 = dateFormat.parse(date);
        } catch (ParseException e) {
            Log.e(TAG, "Date parsing failed", e);
        }
        return date1;
    }

    public static ToughnessImpl updateToughNessStyle(String rangy, String style) {
        String query = "SELECT " + ID + " FROM " + TABLE_NAME + " WHERE " + COL_RANGY + " = \"" + rangy + "\"";
        int id = DbAdapter.getIdForQuery(query);
        if (id != -1 && update(id, updateRangy(rangy, style), style.replace("highlight_", ""))) {
            return getToughNessId(id);
        }
        return null;
    }

    public static ToughnessImpl getToughNessForRangy(String rangy) {
        String query = "SELECT " + ID + " FROM " + TABLE_NAME + " WHERE " + COL_RANGY + " = \"" + rangy + "\"";
        return getToughNessId(DbAdapter.getIdForQuery(query));
    }

    private static String updateRangy(String rangy, String style) {
        /*Pattern p = Pattern.compile("\\highlight_\\w+");
        Matcher m = p.matcher(rangy);
        return m.replaceAll(style);*/
        String[] s = rangy.split("\\$");
        StringBuilder builder = new StringBuilder();
        for (String p : s) {
            if (TextUtils.isDigitsOnly(p)) {
                builder.append(p);
                builder.append('$');
            } else {
                builder.append(style);
                builder.append('$');
            }
        }
        return builder.toString();
    }

    private static boolean update(int id, String s, String color) {
        ToughnessImpl highlightImpl = getToughNessId(id);
        highlightImpl.setRangy(s);
        highlightImpl.setType(color);
        return DbAdapter.updateToughness(getToughNessContentValues(highlightImpl), String.valueOf(id));
    }

    public static void saveToughNessIfNotExists(Toughness highLight) {
        String query = "SELECT " + ID + " FROM " + TABLE_NAME + " WHERE " + COL_UUID + " = \"" + highLight.getUUID() + "\"";
        int id = DbAdapter.getIdForQuery(query);
        if (id == -1) {
            DbAdapter.saveToughness(getToughNessContentValues(highLight));
        }
    }
}



