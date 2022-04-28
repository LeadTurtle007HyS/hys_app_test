package com.sparrowrms.hyspro.viewmodels


import androidx.lifecycle.LiveData
import androidx.lifecycle.MediatorLiveData
import androidx.lifecycle.ViewModel
import com.sparrowrms.hyspro.data.repository.FirebaseDataRepository
import com.sparrowrms.hyspro.util.Resource
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers


class IncomingCallViewModel(private val firebaseDataRepository: FirebaseDataRepository) : ViewModel() {

    public var isSpeakerSelected: Boolean = false
    public var isMuteSelected: Boolean =false

    private val hysSMCallData: MediatorLiveData<Resource<Any>> =
        MediatorLiveData<Resource<Any>>()
    private val disposable = CompositeDisposable()


    fun observeSYMCallDataUpdate(notificationID: String) {

        disposable.add(
            firebaseDataRepository.observeHYS_CAllDataChanges(notificationID)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                    { it ->
                        hysSMCallData.postValue(Resource.success(it.value))
                    }, {
                        hysSMCallData.postValue(Resource.error("Something went wrong",null))
                    })
        )

    }


    fun observeHYSSMCallData(): LiveData<Resource<Any>> {
        return hysSMCallData
    }



}