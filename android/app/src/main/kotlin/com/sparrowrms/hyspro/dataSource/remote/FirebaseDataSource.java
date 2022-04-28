package com.sparrowrms.hyspro.dataSource.remote;

import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.ListenerRegistration;
import com.google.firebase.firestore.Query;
import com.google.firebase.firestore.QuerySnapshot;
import com.sparrowrms.hyspro.Constants;
import com.sparrowrms.hyspro.model.dataclasses.CallingUserNotificationDetails;
import com.sparrowrms.hyspro.model.datasourcemodel.UserDetailsModel;
import javax.inject.Inject;
import io.reactivex.BackpressureStrategy;
import io.reactivex.Completable;
import io.reactivex.Flowable;
import io.reactivex.FlowableEmitter;
import io.reactivex.FlowableOnSubscribe;
import io.reactivex.Single;
import io.reactivex.functions.Cancellable;

public class FirebaseDataSource {

    private static final String TAG = "FirebaseDataSource";

    private final FirebaseFirestore firebaseFirestore;
    private final String currentUid;

    @Inject
    public FirebaseDataSource() {
        FirebaseAuthSource firebaseAuthSource = new FirebaseAuthSource();
        this.firebaseFirestore = FirebaseFirestore.getInstance();
        currentUid = firebaseAuthSource.getCurrentUid();
    }


    public Single<UserDetailsModel> getLoggedInUserDetails(){

        return Single.create(emitter -> {
        firebaseFirestore.collection(Constants.USERS_NODE).document(currentUid).get().addOnSuccessListener(new OnSuccessListener<DocumentSnapshot>() {
            @Override
            public void onSuccess(DocumentSnapshot documentSnapshot) {
                UserDetailsModel userDetailsModel=documentSnapshot.toObject(UserDetailsModel.class);
                assert userDetailsModel != null;
                emitter.onSuccess(userDetailsModel);
            }
        }).addOnFailureListener(emitter::onError);
        });
    }

    public Single<UserDetailsModel> getUserUsingID(String userID){

        return Single.create(emitter -> {
            firebaseFirestore.collection(Constants.USERS_NODE).document(userID).get().addOnSuccessListener(documentSnapshot -> {
                UserDetailsModel userDetailsModel=documentSnapshot.toObject(UserDetailsModel.class);
                assert userDetailsModel != null;
                emitter.onSuccess(userDetailsModel);
            }).addOnFailureListener(emitter::onError);
        });
    }

    //fireStore users list
    private Query getUsersQuery() {
        return firebaseFirestore.collection(Constants.USERS_NODE);
    }


    //fireStore request list
    private Query getRequestQuery(){
        return firebaseFirestore.collection(Constants.FRIEND_REQUEST_NODE)
                .document(currentUid)
                .collection(Constants.REQUEST_NODE)
                .whereEqualTo("requestType","received");
    }




    //fireStore friend list
    private Query getFriendQuery(){
        return firebaseFirestore.collection(Constants.FRIEND_REQUEST_NODE)
                .document(currentUid)
                .collection(Constants.REQUEST_NODE)
                .whereEqualTo("requestType","friend");
    }


    //get chat list
    private Query getChatListQuery(String uid){
        return firebaseFirestore.collection(Constants.MESSAGE_NODE).document(currentUid).collection(uid);
    }

    //get user information
    public Flowable<DocumentSnapshot> getUserInfo(final String uid) {
        return Flowable.create(emitter -> {
            DocumentReference reference = firebaseFirestore.collection(Constants.USERS_NODE).document(uid);
            final ListenerRegistration registration = reference.addSnapshotListener(new EventListener<DocumentSnapshot>() {
                @Override
                public void onEvent(@Nullable DocumentSnapshot documentSnapshot, @Nullable FirebaseFirestoreException e) {
                    if (e != null) {
                        emitter.onError(e);
                    }
                    if (documentSnapshot != null) {
                        emitter.onNext(documentSnapshot);
                    }
                }
            });

            emitter.setCancellable(registration::remove);
        }, BackpressureStrategy.BUFFER);
    }



    //get message
    public Flowable<QuerySnapshot> getMessageList(){
        return Flowable.create(emitter -> {
            CollectionReference reference = firebaseFirestore.collection(Constants.USERS_NODE);
            final ListenerRegistration registration = reference.addSnapshotListener(new EventListener<QuerySnapshot>() {
                @Override
                public void onEvent(@Nullable QuerySnapshot queryDocumentSnapshots, @Nullable FirebaseFirestoreException e) {
                    if(e!=null){
                        emitter.onError(e);
                    }

                    if (queryDocumentSnapshots!=null){
                        emitter.onNext(queryDocumentSnapshots);
                    }
                }
            });

            emitter.setCancellable(registration::remove);
        },BackpressureStrategy.BUFFER);
    }


    public Single<String> getUserNotificationID(String userId){
        return Single.create(emitter -> {
            DocumentReference firebaseDatabaseReference=  firebaseFirestore.collection(Constants.USER_NOTIFICATIO_TOKEN_NODE).document(userId);
            firebaseDatabaseReference.get().addOnSuccessListener(dataSnapshot -> {

                if(dataSnapshot!=null && dataSnapshot.getData()!=null){
                    emitter.onSuccess(String.valueOf(dataSnapshot.getData().get("token")));
                }


            }).addOnFailureListener(emitter::onError);
        });
    }


    public Completable incomingCallNotificationToSuperUser(CallingUserNotificationDetails callingUserNotificationDetails) {
        return Completable.create(emitter -> firebaseFirestore.collection(Constants.HYS_CALL_NOTIFY_TO_USER_NODE)
                .add(callingUserNotificationDetails)
                .addOnFailureListener(emitter::onError)
                .addOnSuccessListener(documentReference -> emitter.onComplete()));
    }

}
