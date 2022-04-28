

package com.sparrowrms.hyspro.screensharemodule.gles;


import com.sparrowrms.hyspro.screensharemodule.gles.core.Drawable2d;

/**
 * Base class for stuff we like to draw.
 */
public class Drawable2dFull extends Drawable2d {


    private static final float FULL_RECTANGLE_COORDS[] = {
            -1.0f, -1.0f,   // 0 bottom left
            1.0f, -1.0f,   // 1 bottom right
            -1.0f, 1.0f,   // 2 top left
            1.0f, 1.0f,   // 3 top right
    };
    private static final float FULL_RECTANGLE_TEX_COORDS[] = {
            0.0f, 0.0f,     // 0 bottom left
            1.0f, 0.0f,     // 1 bottom right
            0.0f, 1.0f,     // 2 top left
            1.0f, 1.0f      // 3 top right
    };

    public Drawable2dFull() {
        super(FULL_RECTANGLE_COORDS, FULL_RECTANGLE_TEX_COORDS);
    }
}
