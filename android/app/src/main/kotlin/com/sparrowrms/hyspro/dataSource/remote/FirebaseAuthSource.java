package com.sparrowrms.hyspro.dataSource.remote;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.Timestamp;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.FirebaseFirestore;
import com.sparrowrms.hyspro.Constants;

import java.util.Date;
import java.util.HashMap;
import java.util.Objects;

import javax.inject.Inject;

import io.reactivex.Completable;
import io.reactivex.CompletableEmitter;
import io.reactivex.CompletableOnSubscribe;

public class FirebaseAuthSource {

    private static final String TAG = "FirebaseAuthSource";

    FirebaseAuth firebaseAuth;
    FirebaseFirestore firebaseFirestore;

    @Inject
    public FirebaseAuthSource() {
        this.firebaseAuth = FirebaseAuth.getInstance();
        //  this.firebaseFirestore = firebaseFirestore;
        this.firebaseFirestore = FirebaseFirestore.getInstance();
    }

    //get current user uid
    public String getCurrentUid() {
        return Objects.requireNonNull(firebaseAuth.getCurrentUser()).getUid();
    }

    //get current user
    public FirebaseUser getCurrentUser() {
        return firebaseAuth.getCurrentUser();
    }

    //create new account
    public Completable register(final String email, final String password, final String name) {
        return Completable.create(emitter -> firebaseAuth.createUserWithEmailAndPassword(email, password)
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        emitter.onError(e);
                    }
                })
                .addOnCompleteListener(task -> {
                    //create new user
                    HashMap<String, Object> map = new HashMap<>();
                    map.put("email", email);
                    map.put("displayName", name);
                    map.put("image", "default");
                    map.put("status", "default");
                    map.put("online", true);

                    firebaseFirestore.collection("User")
                            .document(getCurrentUid()).set(map)
                            .addOnFailureListener(e -> emitter.onError(e))
                            .addOnSuccessListener(aVoid -> emitter.onComplete());
                }));
    }

    //login
    public Completable login(final String email, final String password) {
        return Completable.create(new CompletableOnSubscribe() {
            @Override
            public void subscribe(final CompletableEmitter emitter) throws Exception {
                firebaseAuth.signInWithEmailAndPassword(email, password)
                        .addOnFailureListener(emitter::onError)
                        .addOnSuccessListener(authResult -> emitter.onComplete());
            }
        });
    }

    //logout
    public void logout() {
        firebaseAuth.signOut();
    }


    public Completable updateUserTokenData(final String userId, final String token) {
        return Completable.create(emitter -> {

            Date date = new Date();
            Timestamp ts = new Timestamp(date);
            HashMap<String, Object> map = new HashMap<>();
            map.put("token", token);
            map.put("userid", userId);
            map.put("createdat", "default");
            map.put("createdate", ts);

            firebaseFirestore.collection(Constants.USER_NOTIFICATIO_TOKEN_NODE)
                    .document(userId).set(map)
                    .addOnFailureListener(emitter::onError)
                    .addOnSuccessListener(aVoid -> emitter.onComplete());
        });
    }



}
