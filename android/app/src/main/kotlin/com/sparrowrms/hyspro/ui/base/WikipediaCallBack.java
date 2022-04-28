package com.sparrowrms.hyspro.ui.base;

import com.sparrowrms.hyspro.model.dictionary.Wikipedia;

/**
 * @author gautam chibde on 4/7/17.
 */

public interface WikipediaCallBack extends BaseMvpView {

    void onWikipediaDataReceived(Wikipedia wikipedia);

    //TODO
    void playMedia(String url);
}
