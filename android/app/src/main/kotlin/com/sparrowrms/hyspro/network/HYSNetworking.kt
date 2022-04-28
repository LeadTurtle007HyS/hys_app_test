package com.sparrowrms.hyspro.network

import com.jakewharton.retrofit2.adapter.rxjava2.RxJava2CallAdapterFactory
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

object HYSNetworking {

    private const val BASE_URL = "https://hys-api.herokuapp.com/"
    private fun getRetrofit(): Retrofit {
        val client: OkHttpClient = OkHttpClient().newBuilder()
            .retryOnConnectionFailure(true)
            .connectTimeout(1, TimeUnit.MINUTES)
            .readTimeout(1, TimeUnit.MINUTES)
            .writeTimeout(1, TimeUnit.MINUTES)
            .build()
        return Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
            .client(client)
            .build()
    }

    val agoraTokenAPIRequest:AgoraTokenAPIRequest= getRetrofit().create(AgoraTokenAPIRequest::class.java)

}