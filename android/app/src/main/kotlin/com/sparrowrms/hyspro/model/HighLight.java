package com.sparrowrms.hyspro.model;

import java.util.Date;


public interface HighLight {

    String getBookId();

    String getContent();

    Date getDate();

    String getType();

    int getPageNumber();

    String getPageId();

    String getRangy();

    String getUUID();

    String getNote();

    enum HighLightAction {
        NEW, DELETE, MODIFY
    }
}
