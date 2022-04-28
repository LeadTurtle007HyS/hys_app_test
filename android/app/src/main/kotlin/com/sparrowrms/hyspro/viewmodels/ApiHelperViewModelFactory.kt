package com.sparrowrms.hyspro.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.sparrowrms.hyspro.network.ApiHelper
import com.sparrowrms.hyspro.network.HYSAPIHelper

class ApiHelperViewModelFactory(private val apiHelper: ApiHelper,private val hysApiHelper: HYSAPIHelper) : ViewModelProvider.Factory {


    override fun <T : ViewModel?> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(HighlyRelatedBooksViewModel::class.java)) {
            return HighlyRelatedBooksViewModel(apiHelper,hysApiHelper) as T
        }else if(modelClass.isAssignableFrom(PredictChapterViewModel::class.java)){
            return PredictChapterViewModel(apiHelper) as T
        }

        throw IllegalArgumentException("Unknown class name")
    }
}