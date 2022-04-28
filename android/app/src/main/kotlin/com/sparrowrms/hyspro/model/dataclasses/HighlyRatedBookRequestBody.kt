package com.sparrowrms.hyspro.model.dataclasses

import java.io.Serializable

data class HighlyRatedBookRequestBody(val grade:String,val subject:String,val publication:String,val publication_edition:String,val chapter :String,val part:String,var query:String):Serializable




