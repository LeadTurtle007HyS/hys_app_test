package com.sparrowrms.hyspro.dataSource.remote;

import androidx.annotation.NonNull;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.sparrowrms.hyspro.Constants;
import java.util.HashMap;
import io.reactivex.Completable;
import io.reactivex.Observable;
import io.reactivex.Single;


public class FirebaseRealtimeDatabaseSource {

    private static final String TAG = "FirebaseDataSource";
    private final FirebaseDatabase firebaseDatabase;
    private String currentUid;

    public FirebaseRealtimeDatabaseSource() {
        this.firebaseDatabase = FirebaseDatabase.getInstance();
    }


    public Single<Boolean> getUserCallStatus(String userId) {
        return Single.create(emitter -> {
            DatabaseReference firebaseDatabaseReference = firebaseDatabase.getReference().child(Constants.HYS_CALL_DATA_NODE).child(Constants.HYS_USER_CALL_STATUS_NODE).child(userId).child("callstatus");
            firebaseDatabaseReference.get().addOnSuccessListener(dataSnapshot -> {
                if (dataSnapshot.getValue() != null)
                    emitter.onSuccess((Boolean) dataSnapshot.getValue());
                else
                    emitter.onSuccess(false);

            }).addOnFailureListener(e -> {
                emitter.onError(e);
            });
        });
    }

    public Single<String> getUserNotificationToken(String userId) {
        return Single.create(emitter -> {
            DatabaseReference firebaseDatabaseReference = firebaseDatabase.getReference().child("hysweb").child("usertoken").child(userId).child("tokenid");
            firebaseDatabaseReference.get().addOnSuccessListener(dataSnapshot -> {
                if (dataSnapshot.exists() && dataSnapshot.getValue()!=null)
                    emitter.onSuccess((String) dataSnapshot.getValue());
                else
                    emitter.onSuccess("");

            }).addOnFailureListener(e -> {
                emitter.onError(e);
            });
        });
    }


    public Completable updateHYSCallData(String notificationID, HashMap<String, Object> map) {

        DatabaseReference databaseReference = firebaseDatabase.getReference().child(Constants.HYS_CALL_DATA_NODE).child("sm_calls").child(notificationID);
        return Completable.create(emitter -> databaseReference
                .setValue(map)
                .addOnFailureListener(e -> emitter.onError(e)).addOnSuccessListener(unused -> emitter.onComplete()));
    }

    public Observable<DataSnapshot>  observeHYS_SMCallDataUpdate(String notificationID){
        DatabaseReference databaseReference = firebaseDatabase.getReference().child(Constants.HYS_CALL_DATA_NODE).child("sm_calls").child(notificationID);

        return Observable.create(emitter -> databaseReference.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                emitter.onNext(snapshot);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {

            }
        }) );

    }


}
