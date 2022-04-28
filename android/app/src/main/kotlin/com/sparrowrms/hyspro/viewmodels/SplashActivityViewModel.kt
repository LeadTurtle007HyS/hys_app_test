package com.sparrowrms.hyspro.viewmodels

import androidx.lifecycle.LiveData
import androidx.lifecycle.MediatorLiveData
import androidx.lifecycle.ViewModel
import com.sparrowrms.hyspro.data.repository.AuthRepository
import com.sparrowrms.hyspro.dataSource.remote.FirebaseDataSource
import com.sparrowrms.hyspro.model.datasourcemodel.UserDetailsModel
import com.sparrowrms.hyspro.util.Resource
import io.reactivex.CompletableObserver
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers

class SplashActivityViewModel(private val authRepository: AuthRepository) : ViewModel() {

    private val TAG = "LoginViewModel"
    private val onLogin: MediatorLiveData<Resource<Boolean>> = MediatorLiveData<Resource<Boolean>>()
    private val userDetails: MediatorLiveData<Resource<UserDetailsModel>> = MediatorLiveData<Resource<UserDetailsModel>>()
    private val disposable = CompositeDisposable()



    fun login(email: String?, password: String?) {
        authRepository.login(email, password)
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(object : CompletableObserver {
                override fun onSubscribe(d: Disposable) {
                    disposable.add(d)
                    onLogin.setValue(Resource.loading(false))
                }

                override fun onComplete() {
                    onLogin.setValue(Resource.success(true))
                }

                override fun onError(e: Throwable) {
                    onLogin.setValue(Resource.error(e.message.toString(),false))
                }
            })
    }

    fun getUserDetails(){
        disposable.add(FirebaseDataSource().loggedInUserDetails.subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe(
                { it ->
                    userDetails.postValue(Resource.success(it))
                }, {
                    userDetails.postValue(Resource.error(it.localizedMessage,null))
                }))


    }



    fun observeLogin(): LiveData<Resource<Boolean>?> {
        return onLogin
    }
    fun getLoggedInUserDetails():LiveData<Resource<UserDetailsModel>>{
        return userDetails;
    }

    override fun onCleared() {
        super.onCleared()
        disposable.clear()
    }

}