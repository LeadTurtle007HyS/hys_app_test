package com.sparrowrms.hyspro.viewmodels

import androidx.lifecycle.LiveData
import androidx.lifecycle.MediatorLiveData
import androidx.lifecycle.ViewModel
import com.sparrowrms.hyspro.model.dataclasses.*
import com.sparrowrms.hyspro.network.ApiHelper
import com.sparrowrms.hyspro.util.Resource
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers

class PredictChapterViewModel(private val apiHelper: ApiHelper) : ViewModel() {
    private val disposable = CompositeDisposable()
    private val booksList: MediatorLiveData<Resource<List<HighlyRelatedBooksModel>>> =
        MediatorLiveData<Resource<List<HighlyRelatedBooksModel>>>()

    fun getPredictChapter(body: PredictConceptReqBody) {

        booksList.postValue(Resource.loading(null))
        disposable.add(
            apiHelper.predictConcept(body)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread()).subscribe(
                    {
                        booksList.postValue(Resource.success(it))
                    }, {
                        booksList.postValue(Resource.error(it.localizedMessage, null))
                    })
        )

    }





    fun observeRelatedBooks(): LiveData<Resource<List<HighlyRelatedBooksModel>>> {
        return booksList
    }



}