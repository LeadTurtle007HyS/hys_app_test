package com.sparrowrms.hyspro.ui.activity;

import android.graphics.Rect;
import com.sparrowrms.hyspro.Config;
import com.sparrowrms.hyspro.model.DisplayUnit;
import com.sparrowrms.hyspro.model.locators.ReadLocator;

import java.lang.ref.WeakReference;

public interface FolioActivityCallback {

    int getCurrentChapterIndex();

    ReadLocator getEntryReadLocator();

    boolean goToChapter(String href);

    Config.Direction getDirection();

    void onDirectionChange(Config.Direction newDirection);

    void storeLastReadLocator(ReadLocator lastReadLocator);

    void toggleSystemUI();

    void setDayMode();

    void setNightMode();

    int getTopDistraction(final DisplayUnit unit);

    int getBottomDistraction(final DisplayUnit unit);

    Rect getViewportRect(final DisplayUnit unit);

    WeakReference<FolioActivity> getActivity();

    String getStreamerUrl();

    void gotoHighRatedBooks(String query);

    void goToRelatedQuestion(String query);

    void predictChapterCallback(String query);

}
