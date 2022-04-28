package com.sparrowrms.hyspro.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.sparrowrms.hyspro.data.repository.AuthRepository


class ViewModelFactory(private val apiHelper: AuthRepository) : ViewModelProvider.Factory {

    override fun <T : ViewModel?> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(SplashActivityViewModel::class.java)) {
            return SplashActivityViewModel(apiHelper) as T
        }

        throw IllegalArgumentException("Unknown class name")
    }

}