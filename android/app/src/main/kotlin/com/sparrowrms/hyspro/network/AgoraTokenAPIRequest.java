package com.sparrowrms.hyspro.network;


import com.sparrowrms.hyspro.model.dataclasses.CreateRomePostBody;
import com.sparrowrms.hyspro.model.dataclasses.CreateRoomBody;
import com.sparrowrms.hyspro.model.dataclasses.HighlyRatedBookRequestBody;
import com.sparrowrms.hyspro.model.dataclasses.HighlyRelatedBooksModel;
import com.sparrowrms.hyspro.model.dataclasses.LivebookQuestionPaper;
import com.sparrowrms.hyspro.model.dataclasses.PredictConceptReqBody;
import com.sparrowrms.hyspro.model.dataclasses.PredictRelatedBooksReqBody;
import com.sparrowrms.hyspro.model.dataclasses.RelatedQuestionModel;
import com.sparrowrms.hyspro.model.dataclasses.RoomResponseModel;
import java.util.List;

import io.reactivex.Observable;
import io.reactivex.Single;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.Header;
import retrofit2.http.Headers;
import retrofit2.http.POST;
import retrofit2.http.Path;

public interface AgoraTokenAPIRequest {

    @Headers({"Content-Type: application/json"})
    @POST("tokens/rooms/{uID}")
    Single<String> createWhiteboardRoomToken(@Header("token") String token, @Header("region") String region, @Path("uID") String uID, @Body CreateRoomBody createRoomBody);

    @Headers({"Content-Type: application/json"})
    @POST("rooms")
    Single<RoomResponseModel>createWhiteboardRoom(@Header("token") String token, @Header("region") String region, @Body CreateRomePostBody body);

    @POST("predict")
    Single<List<HighlyRelatedBooksModel>>predictsRelatedBooks(@Body HighlyRatedBookRequestBody body);

    @POST("question")
    Observable<List<RelatedQuestionModel>>predictsRelatedQuestion(@Body PredictRelatedBooksReqBody body);

    @GET("get_live_book_question_papers/{subject}/{grade}")
    Observable<LivebookQuestionPaper> getLiveBookQuestionPapers(@Path("subject") String subject, @Path("grade") String grade);


    @POST("predict_concept")
    Single<List<HighlyRelatedBooksModel>>predictConcept(@Body PredictConceptReqBody body);


}
