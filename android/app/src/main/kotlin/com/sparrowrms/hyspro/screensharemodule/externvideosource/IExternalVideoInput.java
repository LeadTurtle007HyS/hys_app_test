package com.sparrowrms.hyspro.screensharemodule.externvideosource;

import android.util.Size;
import android.view.Surface;

public interface IExternalVideoInput {

    void onVideoInitialized(Surface target);


    void onVideoStopped(GLThreadContext context);


    boolean isRunning();


    void onFrameAvailable(GLThreadContext context, int textureId, float[] transform);


    Size onGetFrameSize();


    int timeToWait();
}
