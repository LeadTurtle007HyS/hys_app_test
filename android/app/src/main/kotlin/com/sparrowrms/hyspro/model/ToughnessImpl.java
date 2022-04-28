package com.sparrowrms.hyspro.model;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.Date;

public class ToughnessImpl  implements Parcelable, Toughness {

    public static final String INTENT = ToughnessImpl.class.getName();
    public static final String BROADCAST_EVENT = "toughness_broadcast_event";

    private int id;

    private String bookId;
    private String content;
    private Date date;
    private String type;
    private int pageNumber;
    private String pageId;
    private String rangy;
    private String uuid;
    private String note;
   

    public enum ToughNessType {
        High,
        Medium,
        Low;

        public static String classForStyle(ToughNessType style) {
            switch (style) {
                case High:
                    return "toughness_high";
                case Medium:
                    return "toughness_medium";
                case Low:
                    return "toughness_low";
                default:
                    return "toughness_all";

            }
        }
    }


    

    public ToughnessImpl(int id, String bookId, String content, Date date, String type,
                         int pageNumber, String pageId,
                         String rangy, String note, String uuid) {
        this.id = id;
        this.bookId = bookId;
        this.content = content;
        this.date = date;
        this.type = type;
        this.pageNumber = pageNumber;
        this.pageId = pageId;
        this.rangy = rangy;
        this.note = note;
        this.uuid = uuid;
    }

    public ToughnessImpl() {
    }

    protected ToughnessImpl(Parcel in) {
        readFromParcel(in);
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

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public String getType() {
        return type;
    }

    public String getPageId() {
        return pageId;
    }

    public void setPageId(String pageId) {
        this.pageId = pageId;
    }

    public String getRangy() {
        return rangy;
    }

    public void setRangy(String rangy) {
        this.rangy = rangy;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getPageNumber() {
        return pageNumber;
    }

    public void setPageNumber(int pageNumber) {
        this.pageNumber = pageNumber;
    }

    public String getNote() {
        return note;
    }

    public String getUUID() {
        return uuid;
    }

    public void setUUID(String uuid) {
        this.uuid = uuid;
    }

    public void setNote(String note) {
        this.note = note;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        ToughnessImpl toughnessImpl = (ToughnessImpl) o;

        return id == toughnessImpl.id
                && (bookId != null ? bookId.equals(toughnessImpl.bookId) : toughnessImpl.bookId == null
                && (content != null ? content.equals(toughnessImpl.content) : toughnessImpl.content == null
                && (date != null ? date.equals(toughnessImpl.date) : toughnessImpl.date == null
                && (type != null ? type.equals(toughnessImpl.type) : toughnessImpl.type == null))));
    }

    @Override
    public int hashCode() {
        int result = id;
        result = 31 * result + (bookId != null ? bookId.hashCode() : 0);
        result = 31 * result + (content != null ? content.hashCode() : 0);
        result = 31 * result + (date != null ? date.hashCode() : 0);
        result = 31 * result + (type != null ? type.hashCode() : 0);
        return result;
    }

    @Override
    public String toString() {
        return "ToughnessImpl{" +
                "id=" + id +
                ", bookId='" + bookId + '\'' +
                ", content='" + content + '\'' +
                ", date=" + date +
                ", type='" + type + '\'' +
                ", pageNumber=" + pageNumber +
                ", pageId='" + pageId + '\'' +
                ", rangy='" + rangy + '\'' +
                ", note='" + note + '\'' +
                ", uuid='" + uuid + '\'' +
                '}';
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(id);
        dest.writeString(bookId);
        dest.writeString(pageId);
        dest.writeString(rangy);
        dest.writeString(content);
        dest.writeSerializable(date);
        dest.writeString(type);
        dest.writeInt(pageNumber);
        dest.writeString(note);
        dest.writeString(uuid);
    }

    private void readFromParcel(Parcel in) {
        id = in.readInt();
        bookId = in.readString();
        pageId = in.readString();
        rangy = in.readString();
        content = in.readString();
        date = (Date) in.readSerializable();
        type = in.readString();
        pageNumber = in.readInt();
        note = in.readString();
        uuid = in.readString();
    }

    public static final Creator<ToughnessImpl> CREATOR = new Creator<ToughnessImpl>() {
        @Override
        public ToughnessImpl createFromParcel(Parcel in) {
            return new ToughnessImpl(in);
        }

        @Override
        public ToughnessImpl[] newArray(int size) {
            return new ToughnessImpl[size];
        }
    };
}
