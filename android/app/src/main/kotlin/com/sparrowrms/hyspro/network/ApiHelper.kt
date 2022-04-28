package com.sparrowrms.hyspro.network

import com.sparrowrms.hyspro.model.dataclasses.*

class ApiHelper(private val agoraTokenAPIRequest: AgoraTokenAPIRequest) {

    fun createRoom(token: String, region: String,body: CreateRomePostBody) =
        agoraTokenAPIRequest.createWhiteboardRoom(token,region,body)!!

    fun createRoomToken(token: String, region: String, uID: String, createRoomBody: CreateRoomBody) =
        agoraTokenAPIRequest.createWhiteboardRoomToken(token,region,uID,createRoomBody)!!

    fun predictRelatedBook(body:HighlyRatedBookRequestBody)= agoraTokenAPIRequest.predictsRelatedBooks(body)!!

    fun relatedQuestion(body:PredictRelatedBooksReqBody)= agoraTokenAPIRequest.predictsRelatedQuestion(body)!!

    fun predictConcept(body: PredictConceptReqBody)=agoraTokenAPIRequest.predictConcept(body)


}