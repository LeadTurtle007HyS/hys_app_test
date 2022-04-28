package com.sparrowrms.hyspro.model;

import java.util.Date;

public interface Toughness {

    String getBookId();

    String getContent();

    Date getDate();

    String getType();

    int getPageNumber();

    String getPageId();

    String getRangy();

    String getUUID();

    String getNote();

    enum ToughnessAction {
        NEW, DELETE, MODIFY
    }
}
