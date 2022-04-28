package com.sparrowrms.hyspro.viewmodels;

import androidx.annotation.NonNull;
import androidx.lifecycle.MediatorLiveData;
import androidx.lifecycle.ViewModel;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.sparrowrms.hyspro.data.repository.FirebaseDataRepository;
import com.sparrowrms.hyspro.model.datasourcemodel.UserDetailsModel;
import com.sparrowrms.hyspro.util.Resource;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import javax.inject.Inject;
import io.reactivex.Observer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;

public class UserListViewModel extends ViewModel {

    private static final String TAG = "UserListViewModel";
    private final FirebaseDataRepository databaseRepository;
    private final CompositeDisposable disposable = new CompositeDisposable();
    private final MediatorLiveData<Resource<List<UserDetailsModel>>> getAllMessage = new MediatorLiveData<>();

    private int counter = 0;
    private final List<UserDetailsModel> messageList = new ArrayList<>();

    @Inject
    public UserListViewModel(FirebaseDataRepository databaseRepository) {
        this.databaseRepository = databaseRepository;
        loadUserList();
    }


    private void loadUserList() {
        getAllMessage.setValue(Resource.Companion.loading(messageList));
        databaseRepository.getMessageList()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .toObservable()
                .subscribe(new Observer<QuerySnapshot>() {
                    @Override
                    public void onSubscribe(Disposable d) {
                        disposable.add(d);
                    }

                    @Override
                    public void onNext(QuerySnapshot queryDocumentSnapshots) {
                        if (queryDocumentSnapshots != null) {
                            for (DocumentSnapshot dc : queryDocumentSnapshots.getDocuments()) {
                                UserDetailsModel message = dc.toObject(UserDetailsModel.class);
                                messageList.add(message);
                            }

                            if(counter==0){
                                getAllMessage.setValue(Resource.Companion.success(messageList));
                                counter=counter+1;
                            }
                        }

                    }


                    @Override
                    public void onError(@NonNull Throwable e) {
                        getAllMessage.setValue(Resource.Companion.error(Objects.requireNonNull(e.getLocalizedMessage()),messageList));
                    }

                    @Override
                    public void onComplete() {

                    }
                });
    }


    @Override
    protected void onCleared() {
        super.onCleared();
        disposable.dispose();
    }

    public MediatorLiveData<Resource<List<UserDetailsModel>>> getAllUserList() {
        return getAllMessage;
    }

}
