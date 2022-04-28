package com.sparrowrms.hyspro.model;

import android.os.Parcel;
import android.os.Parcelable;

public class EbookModel implements Parcelable {

    private int id;
    private String bookId;
    private String bookUrl;
    private String bookName;

    public EbookModel() {
    }

    public EbookModel(int id, String bookId, String bookUrl, String bookName) {
        this.id = id;
        this.bookId = bookId;
        this.bookUrl = bookUrl;
        this.bookName = bookName;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getBookId() {
        return bookId;
    }

    public void setBookId(String bookId) {
        this.bookId = bookId;
    }

    public String getBookUrl() {
        return bookUrl;
    }

    public void setBookUrl(String bookUrl) {
        this.bookUrl = bookUrl;
    }

    public String getBookName() {
        return bookName;
    }

    public void setBookName(String bookName) {
        this.bookName = bookName;
    }

    public static Creator<EbookModel> getCREATOR() {
        return CREATOR;
    }

    protected EbookModel(Parcel in) {
        id = in.readInt();
        bookId = in.readString();
        bookUrl = in.readString();
        bookName = in.readString();
    }

    public static final Creator<EbookModel> CREATOR = new Creator<EbookModel>() {
        @Override
        public EbookModel createFromParcel(Parcel in) {
            return new EbookModel(in);
        }

        @Override
        public EbookModel[] newArray(int size) {
            return new EbookModel[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel parcel, int i) {
        parcel.writeInt(id);
        parcel.writeString(bookId);
        parcel.writeString(bookUrl);
        parcel.writeString(bookName);
    }
}
