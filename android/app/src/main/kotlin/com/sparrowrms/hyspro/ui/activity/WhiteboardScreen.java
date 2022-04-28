package com.sparrowrms.hyspro.ui.activity;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.Toast;

import com.herewhite.sdk.Room;
import com.herewhite.sdk.RoomParams;
import com.herewhite.sdk.WhiteSdk;
import com.herewhite.sdk.WhiteSdkConfiguration;
import com.herewhite.sdk.WhiteboardView;
import com.herewhite.sdk.domain.Appliance;
import com.herewhite.sdk.domain.CameraConfig;
import com.herewhite.sdk.domain.MemberState;
import com.herewhite.sdk.domain.Promise;
import com.herewhite.sdk.domain.Region;
import com.herewhite.sdk.domain.SDKError;
import com.sparrowrms.hyspro.Constants;
import com.sparrowrms.hyspro.R;
import com.sparrowrms.hyspro.model.dataclasses.CreateRoomBody;
import com.sparrowrms.hyspro.network.RetrofitClient;
import io.reactivex.SingleObserver;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;

public class WhiteboardScreen extends AppCompatActivity {

    final String appId = "z7WYMCArEeyZuIMA9eMmPA/tYE0ES4_83AYxw";

    final String ROOM_INFO = "room info";
    final String ROOM_ACTION = "room action";

    WhiteboardView whiteboardView;
    WhiteSdkConfiguration sdkConfiguration = new WhiteSdkConfiguration(appId, true);

    private String uuID;

    CompositeDisposable compositeDisposable=new CompositeDisposable();

    private Room room;
    private ProgressBar whiteBoardProgressBar;
    private ImageButton pencil,selector,textArea,eraser;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_whiteboard_screen);
        initView();
        uuID = getIntent().getStringExtra("ROOM_ID");
        sdkConfiguration.setRegion(Region.in_mum);
        fetchRoomToken();

    }

    private void initView() {
        whiteboardView = findViewById(R.id.white);
        whiteBoardProgressBar=findViewById(R.id.whiteBoardProgressBar);
        eraser=findViewById(R.id.eraser);
        selector=findViewById(R.id.selector);
        textArea=findViewById(R.id.textArea);
        pencil=findViewById(R.id.pencil);
    }


    @SuppressLint("CheckResult")
    private void fetchRoomToken() {
        whiteBoardProgressBar.setVisibility(View.VISIBLE);
        CreateRoomBody createRoomBody = new CreateRoomBody(3600000, "writer");
        RetrofitClient.INSTANCE.getAgoraTokenAPIRequest().createWhiteboardRoomToken(Constants.AGORA_WHITEBOARD_SDK_TOKEN, Constants.REGION, uuID, createRoomBody)
                .subscribeOn(Schedulers.io())
                .subscribeOn(AndroidSchedulers.mainThread())
                .subscribe(new SingleObserver<String>() {
                    @Override
                    public void onSubscribe(@NonNull Disposable d) {
                        compositeDisposable.add(d);
                    }

                    @Override
                    public void onSuccess(@NonNull String token) {
                        joinWhiteboardRoom(token);
                    }

                    @Override
                    public void onError(@NonNull Throwable e) {
                        System.out.println(String.format("User with name %s successfully created: ", e.getLocalizedMessage()));
                        whiteBoardProgressBar.setVisibility(View.GONE);
                    }
                });



    }

    private void joinWhiteboardRoom(String token){
        RoomParams roomParams = new RoomParams(uuID, token);
        WhiteSdk whiteSdk = new WhiteSdk(whiteboardView, WhiteboardScreen.this, sdkConfiguration);
        // Join a room
        whiteSdk.joinRoom(roomParams, new Promise<Room>() {
            @Override
            public void then(Room wRoom) {
                room=wRoom;
                MemberState memberState = new MemberState();
                // Set the tool to pencil
                memberState.setCurrentApplianceName("pencil");
                // Set the color tor red
                memberState.setStrokeColor(new int[]{255, 0, 0});
                // Assign the set-up tool to the current user
                wRoom.setMemberState(memberState);
                pencil.setImageResource(R.drawable.pencil_selected);
                whiteBoardProgressBar.setVisibility(View.GONE);
            }

            @Override
            public void catchEx(SDKError t) {
                whiteBoardProgressBar.setVisibility(View.GONE);
                Object o = t.getMessage();
                Toast.makeText(WhiteboardScreen.this, o.toString(), Toast.LENGTH_SHORT).show();
            }
        });
    }


    public void disableOperation(MenuItem item) {
        logAction();
        room.disableOperations(true);
    }

    public void cancelDisableOperation(MenuItem item) {
        logAction();
        room.disableOperations(false);
    }

    public void textArea(View v) {
        if(room!=null){
            logAction();
            unselectAllTool();
            textArea.setImageResource(R.drawable.text_selected);
            MemberState memberState = new MemberState();
            memberState.setStrokeColor(new int[]{99, 99, 99});
            memberState.setCurrentApplianceName(Appliance.TEXT);
            memberState.setStrokeWidth(10);
            memberState.setTextSize(10);
            room.setMemberState(memberState);
        }

    }

    public void selector(View v) {
        if(room!=null){
            logAction();
            unselectAllTool();
            selector.setImageResource(R.drawable.selector_selected);
            MemberState memberState = new MemberState();
            memberState.setCurrentApplianceName(Appliance.SELECTOR);
            room.setMemberState(memberState);
        }

    }

    public void eraser(View v) {
        if(room!=null){
            logAction();
            unselectAllTool();
            eraser.setImageResource(R.drawable.eraser_selected);
            MemberState memberState = new MemberState();
            memberState.setCurrentApplianceName(Appliance.ERASER);
            memberState.setStrokeWidth(10);
            room.setMemberState(memberState);
        }

    }

    public void pencil(View v) {
        if(room!=null){
            logAction();
            unselectAllTool();
            pencil.setImageResource(R.drawable.pencil_selected);
            MemberState memberState = new MemberState();
            memberState.setStrokeColor(new int[]{99, 99, 99});
            memberState.setCurrentApplianceName(Appliance.PENCIL);
            memberState.setStrokeWidth(10);
            memberState.setTextSize(10);
            room.setMemberState(memberState);
        }

    }

    public void rectangle(View v) {
        if(room!=null){
            logAction();
            MemberState memberState = new MemberState();
            memberState.setStrokeColor(new int[]{99, 99, 99});
            memberState.setCurrentApplianceName(Appliance.RECTANGLE);
            memberState.setStrokeWidth(10);
            memberState.setTextSize(10);
            room.setMemberState(memberState);
        }

    }

    public void color(View v) {
        if(room!=null){
            logAction();
            MemberState memberState = new MemberState();
            memberState.setStrokeColor(new int[]{200, 200, 200});
            memberState.setCurrentApplianceName(Appliance.PENCIL);
            memberState.setStrokeWidth(4);
            memberState.setTextSize(10);
            room.setMemberState(memberState);
        }

    }

    private void unselectAllTool(){
        if(room!=null){
            pencil.setImageResource(R.drawable.pencil);
            selector.setImageResource(R.drawable.selector);
            textArea.setImageResource(R.drawable.text);
            eraser.setImageResource(R.drawable.eraser);
        }


    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if(room!=null)
            room.disconnect();
    }

    public void externalEvent(MenuItem item) {
        logAction();
    }

    public void zoomChange(MenuItem item) {
        CameraConfig cameraConfig = new CameraConfig();
        if (room.getZoomScale() != 1) {
            cameraConfig.setScale(1d);
        } else {
            cameraConfig.setScale(5d);
        }
        room.moveCamera(cameraConfig);
    }

    //endregion

    //region log
    void logRoomInfo(String str) {
        Log.i(ROOM_INFO, Thread.currentThread().getStackTrace()[3].getMethodName() + " " + str);
    }

    void logAction(String str) {
        Log.i(ROOM_ACTION, Thread.currentThread().getStackTrace()[3].getMethodName() + " " + str);
    }

    void logAction() {
        Log.i(ROOM_ACTION, Thread.currentThread().getStackTrace()[3].getMethodName());
    }

    void showToast(Object o) {
        Log.i("showToast", o.toString());
        Toast.makeText(this, o.toString(), Toast.LENGTH_SHORT).show();
    }


}