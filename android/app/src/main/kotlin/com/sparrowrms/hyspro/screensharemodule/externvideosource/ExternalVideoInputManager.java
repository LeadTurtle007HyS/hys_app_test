package com.sparrowrms.hyspro.screensharemodule.externvideosource;


import static com.sparrowrms.hyspro.Constants.ENGINE;
import static com.sparrowrms.hyspro.Constants.TEXTUREVIEW;
import static io.agora.rtc.mediaio.MediaIO.BufferType.TEXTURE;
import static io.agora.rtc.mediaio.MediaIO.PixelFormat.TEXTURE_OES;

import android.content.Context;
import android.content.Intent;
import android.graphics.SurfaceTexture;
import android.opengl.EGLSurface;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.os.Build;
import android.util.Log;
import android.util.Size;
import android.view.Surface;

import androidx.annotation.RequiresApi;

import com.sparrowrms.hyspro.screensharemodule.externvideosource.localvideo.LocalVideoInput;
import com.sparrowrms.hyspro.screensharemodule.externvideosource.screenshare.ScreenShareInput;
import com.sparrowrms.hyspro.screensharemodule.gles.ProgramTextureOES;
import com.sparrowrms.hyspro.screensharemodule.gles.core.EglCore;
import com.sparrowrms.hyspro.screensharemodule.gles.core.GlUtil;

import io.agora.rtc.gl.TextureTransformer;
import io.agora.rtc.mediaio.IVideoFrameConsumer;
import io.agora.rtc.mediaio.IVideoSource;
import io.agora.rtc.mediaio.MediaIO;


public class ExternalVideoInputManager implements IVideoSource {
    private static final String TAG = ExternalVideoInputManager.class.getSimpleName();

    public static final int TYPE_LOCAL_VIDEO = 1;
    public static final int TYPE_SCREEN_SHARE = 2;
    public static final int TYPE_AR_CORE = 3;

    public static final String FLAG_VIDEO_PATH = "flag-local-video";
    public static final String FLAG_SCREEN_WIDTH = "screen-width";
    public static final String FLAG_SCREEN_HEIGHT = "screen-height";
    public static final String FLAG_SCREEN_DPI = "screen-dpi";
    public static final String FLAG_FRAME_RATE = "screen-frame-rate";

    private static final int DEFAULT_SCREEN_WIDTH = 640;
    private static final int DEFAULT_SCREEN_HEIGHT = 480;
    private static final int DEFAULT_SCREEN_DPI = 3;
    private static final int DEFAULT_FRAME_RATE = 15;

    private ExternalVideoInputThread mThread;
    private int mCurInputType;
    private volatile IExternalVideoInput mCurVideoInput;
    private volatile IExternalVideoInput mNewVideoInput;

    // RTC video interface to send video
    private volatile IVideoFrameConsumer mConsumer;

    private Context context;
    private TextureTransformer textureTransformer;
    private static final int MAX_TEXTURE_COPY = 1;

    public ExternalVideoInputManager(Context context) {
        this.context = context;
    }

    public void start() {
        mThread = new ExternalVideoInputThread();
        mThread.start();
    }

   public boolean setExternalVideoInput(int type, Intent intent) {
        // Do not reset current input if the target type is
        // the same as the current which is still running.
        if (mCurInputType == type && mCurVideoInput != null
                && mCurVideoInput.isRunning()) {
            return false;
        }

        type = TYPE_SCREEN_SHARE;
        IExternalVideoInput input;
        switch (type) {
            case TYPE_LOCAL_VIDEO:
                input = new LocalVideoInput(intent.getStringExtra(FLAG_VIDEO_PATH));
                if (TEXTUREVIEW != null) {
                    TEXTUREVIEW.setSurfaceTextureListener((LocalVideoInput) input);
                }
                break;
            case TYPE_SCREEN_SHARE:
                int width = intent.getIntExtra(FLAG_SCREEN_WIDTH, DEFAULT_SCREEN_WIDTH);
                int height = intent.getIntExtra(FLAG_SCREEN_HEIGHT, DEFAULT_SCREEN_HEIGHT);
                int dpi = intent.getIntExtra(FLAG_SCREEN_DPI, DEFAULT_SCREEN_DPI);
                int fps = intent.getIntExtra(FLAG_FRAME_RATE, DEFAULT_FRAME_RATE);
                Log.i(TAG, "ScreenShare:" + width + "|" + height + "|" + dpi + "|" + fps);
                input = new ScreenShareInput(context, width, height, dpi, fps, intent);
                break;
            default:
                input = null;
        }

        setExternalVideoInput(input);
        mCurInputType = type;
        return true;
    }

    private void setExternalVideoInput(IExternalVideoInput source) {
        if (mThread != null && mThread.isAlive()) {
            mThread.pauseThread();
        }
        mNewVideoInput = source;
    }

    public  void stop() {
        mThread.setThreadStopped();
    }


    @Override
    public boolean onInitialize(IVideoFrameConsumer consumer) {
        mConsumer = consumer;
        return true;
    }


    @Override
    public boolean onStart() {
        return true;
    }


    @Override
    public void onStop() {

    }


    @Override
    public void onDispose() {
        Log.e(TAG, "SwitchExternalVideo-onDispose");
        mConsumer = null;
    }

    @Override
    public int getBufferType() {
        return TEXTURE.intValue();
    }

    @Override
    public int getCaptureType() {
        return MediaIO.CaptureType.CAMERA.intValue();

    }

    @Override
    public int getContentHint() {
        return MediaIO.ContentHint.NONE.intValue();
    }

    private class ExternalVideoInputThread extends Thread
    {
        private final String TAG = ExternalVideoInputThread.class.getSimpleName();
        private final int DEFAULT_WAIT_TIME = 1;

        private EglCore mEglCore;
        private EGLSurface mEglSurface;
        private int mTextureId;
        private SurfaceTexture mSurfaceTexture;
        private Surface mSurface;
        private float[] mTransform = new float[16];
        private GLThreadContext mThreadContext;
        int mVideoWidth;
        int mVideoHeight;
        private volatile boolean mStopped;
        private volatile boolean mPaused;

        private void prepare() {
            mEglCore = new EglCore();
            mEglSurface = mEglCore.createOffscreenSurface(1, 1);
            mEglCore.makeCurrent(mEglSurface);
            mTextureId = GlUtil.createTextureObject(GLES11Ext.GL_TEXTURE_EXTERNAL_OES);
            mSurfaceTexture = new SurfaceTexture(mTextureId);
            mSurface = new Surface(mSurfaceTexture);
            mThreadContext = new GLThreadContext();
            mThreadContext.eglCore = mEglCore;
            mThreadContext.context = mEglCore.getEGLContext();
            mThreadContext.program = new ProgramTextureOES();
            textureTransformer = new TextureTransformer(MAX_TEXTURE_COPY);
         //  ENGINE.setVideoSource(ExternalVideoInputManager.this);
        }

        private void release() {
            if (ENGINE == null) {
                return;
            }
            /**release external video source*/
            textureTransformer.release();
            ENGINE.setVideoSource(null);
            mSurface.release();
            mEglCore.makeNothingCurrent();
            mEglCore.releaseSurface(mEglSurface);
            mSurfaceTexture.release();
            GlUtil.deleteTextureObject(mTextureId);
            mTextureId = 0;
            mEglCore.release();
        }

        @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
        @Override
        public void run() {
            prepare();

            while (!mStopped) {
                if (mCurVideoInput != mNewVideoInput) {

                    if (mCurVideoInput != null) {
                        mCurVideoInput.onVideoStopped(mThreadContext);
                        Log.i(TAG, "recycle stopped input");
                    }

                    mCurVideoInput = mNewVideoInput;
                    if (mCurVideoInput != null) {
                        mCurVideoInput.onVideoInitialized(mSurface);
                        Log.i(TAG, "initialize new input");
                    }

                    if (mCurVideoInput == null) {
                        continue;
                    }

                    Size size = mCurVideoInput.onGetFrameSize();
                    mVideoWidth = size.getWidth();
                    mVideoHeight = size.getHeight();
                    mSurfaceTexture.setDefaultBufferSize(mVideoWidth, mVideoHeight);

                    if (mPaused) {
                        // If current thread is in pause state, it must be paused
                        // because of switching external video sources.
                        mPaused = false;
                    }
                } else if (mCurVideoInput != null && !mCurVideoInput.isRunning()) {

                    Log.i(TAG, "current video input is not running");
                    mCurVideoInput.onVideoStopped(mThreadContext);
                    mCurVideoInput = null;
                    mNewVideoInput = null;
                }

                if (mPaused || mCurVideoInput == null) {
                    waitForTime(DEFAULT_WAIT_TIME);
                    continue;
                }

                try {
                    mSurfaceTexture.updateTexImage();
                    mSurfaceTexture.getTransformMatrix(mTransform);
                }
                catch (Exception e) {
                    e.printStackTrace();
                }

                if (mCurVideoInput != null) {
                    mCurVideoInput.onFrameAvailable(mThreadContext, mTextureId, mTransform);
                }

                mEglCore.makeCurrent(mEglSurface);
                GLES20.glViewport(0, 0, mVideoWidth, mVideoHeight);

                if (mConsumer != null) {
                    Log.e(TAG, "publish stream with ->width:" + mVideoWidth + ",height:" + mVideoHeight);

                    textureTransformer.copy(mTextureId, TEXTURE_OES.intValue(), mVideoWidth, mVideoHeight);
                    mConsumer.consumeTextureFrame(mTextureId,
                            TEXTURE_OES.intValue(),
                            mVideoWidth, mVideoHeight, 0,
                            System.currentTimeMillis(), mTransform);
                }

                // The pace at which the output Surface is sampled
                // for video frames is controlled by the waiting
                // time returned from the external video source.
                waitForNextFrame();
            }

            if (mCurVideoInput != null) {
                // The manager will cause the current
                // video source to be stopped.
                mCurVideoInput.onVideoStopped(mThreadContext);
            }
            release();
        }

        void pauseThread() {
            mPaused = true;
        }

        void setThreadStopped() {
            mStopped = true;
        }

        private void waitForNextFrame() {
            int wait = mCurVideoInput != null
                    ? mCurVideoInput.timeToWait()
                    : DEFAULT_WAIT_TIME;
            waitForTime(wait);
        }

        private void waitForTime(int time) {
            try {
                Thread.sleep(time);
            }
            catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
