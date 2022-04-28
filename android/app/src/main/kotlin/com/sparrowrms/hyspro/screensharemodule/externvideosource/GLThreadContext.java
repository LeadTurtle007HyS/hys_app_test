package com.sparrowrms.hyspro.screensharemodule.externvideosource;

import android.opengl.EGLContext;

import com.sparrowrms.hyspro.screensharemodule.gles.ProgramTextureOES;
import com.sparrowrms.hyspro.screensharemodule.gles.core.EglCore;


public class GLThreadContext {
    public EglCore eglCore;
    public EGLContext context;
    public ProgramTextureOES program;
}
