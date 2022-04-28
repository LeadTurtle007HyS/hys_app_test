package com.sparrowrms.hyspro.network


class HYSAPIHelper(private val agoraTokenAPIRequest: AgoraTokenAPIRequest) {

    fun getLiveBookQuestionPapers(subject: String, grade: String,)= agoraTokenAPIRequest.getLiveBookQuestionPapers(subject,grade)!!

}