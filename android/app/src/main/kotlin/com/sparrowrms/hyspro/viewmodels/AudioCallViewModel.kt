package com.sparrowrms.hyspro.viewmodels

import androidx.lifecycle.LiveData
import androidx.lifecycle.MediatorLiveData
import androidx.lifecycle.ViewModel
import com.sparrowrms.hyspro.Constants
import com.sparrowrms.hyspro.data.repository.FirebaseDataRepository
import com.sparrowrms.hyspro.model.dataclasses.AudioDataClass
import com.sparrowrms.hyspro.model.dataclasses.CreateRomePostBody
import com.sparrowrms.hyspro.network.ApiHelper
import com.sparrowrms.hyspro.util.Resource
import io.reactivex.Single
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers



class AudioCallViewModel(private val firebaseDataRepository: FirebaseDataRepository,private val apiHelper: ApiHelper) : ViewModel() {

    private val disposable = CompositeDisposable()
    private val mergedAllCallDetails: MediatorLiveData<Resource<AudioDataClass>> = MediatorLiveData<Resource<AudioDataClass>>()
    private val hysSMCallData: MediatorLiveData<Resource<Any>> = MediatorLiveData<Resource<Any>>()
    var isSpeakerSelected: Boolean = false
    var isMuteSelected: Boolean = false


    fun getUserCallStatusAndToken(userId: String) {
        val createRomePostBody=CreateRomePostBody(false,5)
        disposable.add(
            Single.zip(firebaseDataRepository.getUserNotificationID(userId),
                firebaseDataRepository.getUserCallStatus(userId),
                apiHelper.createRoom(Constants.AGORA_WHITEBOARD_SDK_TOKEN,Constants.REGION,createRomePostBody),
                { t1, t2, t3 ->
                    AudioDataClass(t3.uuid, t2, t1)

                }).subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread()).subscribe({ dataClass ->
                    mergedAllCallDetails.postValue(Resource.success(dataClass))
                }, {
                    mergedAllCallDetails.postValue(Resource.error("Something Went Wrong", null))
                })
        )

    }

    fun getUserNotificationToken(userId: String) : Single<String>{
        return  firebaseDataRepository.getUserNotificationID(userId)
    }

    fun observeSYMCallDataUpdate(notificationID: String) {
        disposable.add(
            firebaseDataRepository.observeHYS_CAllDataChanges(notificationID)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread()).subscribe(
                    {
                        hysSMCallData.postValue(Resource.success(it.value))
                    }, {
                        hysSMCallData.postValue(Resource.error(it.localizedMessage,null))
                    })
        )

    }


    fun observeCallingDetails(): LiveData<Resource<AudioDataClass>> {
        return mergedAllCallDetails
    }

    fun observeHYSSMCallData(): LiveData<Resource<Any>> {
        return hysSMCallData
    }

    override fun onCleared() {
        super.onCleared()
        disposable.clear()
    }

}


