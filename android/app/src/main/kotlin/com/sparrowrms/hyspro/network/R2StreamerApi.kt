package com.sparrowrms.hyspro.network

import okhttp3.ResponseBody
import org.readium.r2.shared.Locator
import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Query
import retrofit2.http.Url


interface R2StreamerApi {

    @GET("search") @Gson
    fun search(@Query("spineIndex") spineIndex: Int, @Query("query") query: String): Call<List<Locator>>

    @GET
    fun downloadFileWithDynamicUrl(@Url fileUrl: String?): Call<ResponseBody?>?
}