package com.sparrowrms.hyspro.model.dataclasses

import java.io.Serializable

data class HighlyRelatedBooksModel(val Chapter :String,val EPUB_link:String,val Paragraph_related:String,val Publication:String) : Serializable
