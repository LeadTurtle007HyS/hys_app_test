package com.sparrowrms.hyspro.model.sqlite;

import android.content.ContentValues;
import android.database.Cursor;

import com.sparrowrms.hyspro.model.EbookModel;

import java.util.ArrayList;


public class EBookTable {

    public static final String TABLE_NAME = "e_book_table";

    public static final String ID = "_id";
    public static final String COL_BOOK_ID = "bookID";
    private static final String COL_BOOK_URL = "bookURL";
    private static final String COL_BOOK_NAME = "bookName";


    public static final String SQL_CREATE = "CREATE TABLE IF NOT EXISTS " + TABLE_NAME + " ( " + ID
            + " INTEGER PRIMARY KEY AUTOINCREMENT" + ","
            + COL_BOOK_ID + " TEXT" + ","
            + COL_BOOK_URL + " TEXT" + ","
            + COL_BOOK_NAME + " TEXT" + ")";

    public static final String SQL_DROP = "DROP TABLE IF EXISTS " + TABLE_NAME;

    public static final String TAG = EBookTable.class.getSimpleName();

    public static ContentValues getEBookContentValues(EbookModel ebookModel) {
        ContentValues contentValues = new ContentValues();
        contentValues.put(COL_BOOK_ID, ebookModel.getBookId());
        contentValues.put(COL_BOOK_NAME, ebookModel.getBookName());
        contentValues.put(COL_BOOK_URL, ebookModel.getBookUrl());
        return contentValues;
    }


    public static ArrayList<EbookModel> getAllHighlights(String bookId) {
        ArrayList<EbookModel> ebookModels = new ArrayList<>();
        Cursor highlightCursor = DbAdapter.getEBook(bookId);
        while (highlightCursor.moveToNext()) {
            ebookModels.add(new EbookModel(highlightCursor.getInt(highlightCursor.getColumnIndex(ID)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_BOOK_ID)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_BOOK_NAME)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_BOOK_URL))));
        }
        return ebookModels;
    }

    public static EbookModel getEBookForId(String id) {
        Cursor highlightCursor = DbAdapter.getEBook(id);
        EbookModel ebookModel = new EbookModel();
        while (highlightCursor.moveToNext()) {
            ebookModel = new EbookModel(highlightCursor.getInt(highlightCursor.getColumnIndex(ID)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_BOOK_ID)),
                    highlightCursor.getString(highlightCursor.getColumnIndex(COL_BOOK_NAME)),
                   highlightCursor.getString(highlightCursor.getColumnIndex(COL_BOOK_URL)));

        }
        return ebookModel;
    }

    public static long insertEbook(EbookModel ebookModel) {
        EbookModel ebookModel2 =   getEBookForId(ebookModel.getBookId());
        if(ebookModel2!=null && ebookModel2.getBookId()==null)
        return DbAdapter.saveEBook(getEBookContentValues(ebookModel));
        else
            return -1;
    }



    public static long saveEBookIfNotExists(EbookModel ebookModel) {
        String query = "SELECT " + ID + " FROM " + TABLE_NAME + " WHERE " + COL_BOOK_ID + " = \"" + ebookModel.getBookId() + "\"";
        int id = DbAdapter.getIdForQuery(query);
        if (id == -1) {
         return    DbAdapter.saveEBook(getEBookContentValues(ebookModel));
        }
        return -1;
    }
}

