package com.sparrowrms.hyspro.model.dataclasses

import java.io.Serializable

data class RelatedQuestionModel(val Query:String,val Question_Paper:String,val question_related:String,val year:String,val download_link:String) : Serializable
