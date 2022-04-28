package com.sparrowrms.hyspro.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.sparrowrms.hyspro.data.repository.AuthRepository
import com.sparrowrms.hyspro.data.repository.FirebaseDataRepository
import com.sparrowrms.hyspro.network.ApiHelper

class DataViewModelFactory (private val firebaseDataRepository:  FirebaseDataRepository,private val apiHelper: ApiHelper) :
    ViewModelProvider.Factory {

    override fun <T : ViewModel?> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(UserListViewModel::class.java)) {
            return UserListViewModel(firebaseDataRepository) as T
        }else if(modelClass.isAssignableFrom(AudioCallViewModel::class.java)){
            return AudioCallViewModel(firebaseDataRepository,apiHelper) as T
        }else if(modelClass.isAssignableFrom(IncomingCallViewModel::class.java)){
            return IncomingCallViewModel(firebaseDataRepository) as T
        }

        throw IllegalArgumentException("Unknown class name")
    }

}