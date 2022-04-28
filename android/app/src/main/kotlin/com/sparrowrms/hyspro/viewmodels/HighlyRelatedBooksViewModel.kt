package com.sparrowrms.hyspro.viewmodels


import androidx.lifecycle.LiveData
import androidx.lifecycle.MediatorLiveData
import androidx.lifecycle.ViewModel
import com.sparrowrms.hyspro.model.dataclasses.HighlyRatedBookRequestBody
import com.sparrowrms.hyspro.model.dataclasses.HighlyRelatedBooksModel
import com.sparrowrms.hyspro.model.dataclasses.PredictRelatedBooksReqBody
import com.sparrowrms.hyspro.model.dataclasses.RelatedQuestionModel
import com.sparrowrms.hyspro.network.ApiHelper
import com.sparrowrms.hyspro.network.HYSAPIHelper
import com.sparrowrms.hyspro.util.Resource
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers

class HighlyRelatedBooksViewModel(private val apiHelper: ApiHelper,private val hysApiHelper: HYSAPIHelper) : ViewModel() {
    private val disposable = CompositeDisposable()
    private val booksList: MediatorLiveData<Resource<List<HighlyRelatedBooksModel>>> =
        MediatorLiveData<Resource<List<HighlyRelatedBooksModel>>>()
    private val questionList: MediatorLiveData<Resource<List<RelatedQuestionModel>>> =
        MediatorLiveData<Resource<List<RelatedQuestionModel>>>()


    fun getHighlyRelatedBooks(body: HighlyRatedBookRequestBody) {

        booksList.postValue(Resource.loading(null))
        disposable.add(
            apiHelper.predictRelatedBook(body)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread()).subscribe(
                    {
                        booksList.postValue(Resource.success(it))
                    }, {
                        booksList.postValue(Resource.error(it.localizedMessage, null))
                    })
        )

    }


    fun getPredictQuestionPaper(subject:String,grade:String,selectedText:String){
        questionList.postValue(Resource.loading(null))
        disposable.add( hysApiHelper.getLiveBookQuestionPapers(subject,grade)
            .subscribeOn(Schedulers.io())
            .flatMap { response ->
                val predictionQuestionBody = PredictRelatedBooksReqBody(selectedText,response.dictionary_id )
                return@flatMap apiHelper.relatedQuestion(predictionQuestionBody)
            }
            .subscribeOn(Schedulers.io())
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe (
                { response ->
                    questionList.postValue(Resource.success(response))
                },
                { err ->

                    questionList.postValue(Resource.error(err.localizedMessage!!, null))
                },
                {

                }
            )
        )
    }



    fun observeRelatedBooks(): LiveData<Resource<List<HighlyRelatedBooksModel>>> {
        return booksList
    }

    fun observerQuestionList():LiveData<Resource<List<RelatedQuestionModel>>>{
      return  questionList;
    }

}