package com.sparrowrms.hyspro.data.repository;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.sparrowrms.hyspro.dataSource.remote.FirebaseDataSource;
import com.sparrowrms.hyspro.dataSource.remote.FirebaseRealtimeDatabaseSource;
import com.sparrowrms.hyspro.model.datasourcemodel.UserDetailsModel;
import javax.inject.Inject;
import io.reactivex.Flowable;
import io.reactivex.Observable;
import io.reactivex.Single;

public class FirebaseDataRepository {
    FirebaseDataSource firebaseDataSource;
    FirebaseRealtimeDatabaseSource firebaseRealtimeDatabaseSource;

    @Inject
    public FirebaseDataRepository(FirebaseDataSource firebaseDataSource) {
        this.firebaseDataSource = firebaseDataSource;
        this.firebaseRealtimeDatabaseSource=new FirebaseRealtimeDatabaseSource();
    }

    public Single<UserDetailsModel> getLoggedInUser(){
        return this.firebaseDataSource.getLoggedInUserDetails();
    }

    public Flowable<QuerySnapshot> getMessageList(){
        return this.firebaseDataSource.getMessageList();
    }

    public Single<String> getUserNotificationID(String uid){
        return this.firebaseRealtimeDatabaseSource.getUserNotificationToken(uid);
    }
    public Single<Boolean> getUserCallStatus(String uid){
        return this.firebaseRealtimeDatabaseSource.getUserCallStatus(uid);
    }

    public Observable<DataSnapshot> observeHYS_CAllDataChanges(String notificationID){

        return this.firebaseRealtimeDatabaseSource.observeHYS_SMCallDataUpdate(notificationID);
    }

}
