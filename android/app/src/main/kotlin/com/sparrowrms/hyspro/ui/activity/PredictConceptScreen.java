package com.sparrowrms.hyspro.ui.activity;


import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.TextView;
import com.sparrowrms.hyspro.Constants;
import com.sparrowrms.hyspro.FolioReader;
import com.sparrowrms.hyspro.R;
import com.sparrowrms.hyspro.model.dataclasses.HighlyRatedBookRequestBody;
import com.sparrowrms.hyspro.model.dataclasses.HighlyRelatedBooksModel;
import com.sparrowrms.hyspro.model.dataclasses.PredictConceptReqBody;
import com.sparrowrms.hyspro.network.ApiHelper;
import com.sparrowrms.hyspro.network.HYSAPIHelper;
import com.sparrowrms.hyspro.network.HYSNetworking;
import com.sparrowrms.hyspro.network.RetrofitNetworking;
import com.sparrowrms.hyspro.ui.adapter.PredictConceptAdapter;
import com.sparrowrms.hyspro.util.AppUtil;
import com.sparrowrms.hyspro.util.Status;
import com.sparrowrms.hyspro.viewmodels.ApiHelperViewModelFactory;
import com.sparrowrms.hyspro.viewmodels.HighlyRelatedBooksViewModel;
import com.sparrowrms.hyspro.viewmodels.PredictChapterViewModel;
import org.readium.r2.shared.Publication;
import com.sparrowrms.hyspro.Config;
import static com.sparrowrms.hyspro.Constants.*;

public class PredictConceptScreen extends AppCompatActivity implements PredictConceptAdapter.HighlyRelatedBooksAdapterCallback{
    private PredictConceptAdapter predictConceptAdapter;
    private RecyclerView mRelatedBookRecyclerView;
    private ProgressBar progressBarLoader;
    private PredictChapterViewModel predictChapterViewModel;
    private HighlyRatedBookRequestBody highlyRatedBookRequestBody;
    private TextView errorView;
    private Config mConfig;
    private String selectedText;
    private Publication publication;
    private String dictionaryID=null;


    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_predict_concept_screen2);
        if (getSupportActionBar() != null) {
            // getSupportActionBar().hide();
        }
        mConfig = AppUtil.getSavedConfig(this);
        selectedText=getIntent().getStringExtra(SELECTED_WORD);
        dictionaryID=getIntent().getStringExtra(FolioReader.DICTIONARY_ID);
        highlyRatedBookRequestBody= (HighlyRatedBookRequestBody) getIntent().getSerializableExtra(FolioReader.HIGHLY_RATED_BOOK_REQ);
        highlyRatedBookRequestBody.setQuery(selectedText);
        initView();
    }

    private void initView(){
        mRelatedBookRecyclerView = findViewById(R.id.recycler_view_menu);
        progressBarLoader=findViewById(R.id.progressBarLoader);
        errorView =findViewById(R.id.tv_error);
        configRecyclerViews();
        predictChapterViewModel = new ViewModelProvider(this, new ApiHelperViewModelFactory(new ApiHelper(RetrofitNetworking.INSTANCE.getAgoraTokenAPIRequest()),new HYSAPIHelper(HYSNetworking.INSTANCE.getAgoraTokenAPIRequest()))).get(PredictChapterViewModel.class);
        observeListData();
        PredictConceptReqBody predictConceptReqBody=new PredictConceptReqBody(highlyRatedBookRequestBody.getQuery(), highlyRatedBookRequestBody.getGrade(), highlyRatedBookRequestBody.getSubject());
        predictChapterViewModel.getPredictChapter(predictConceptReqBody);

    }

    public void configRecyclerViews() {
        mRelatedBookRecyclerView.setHasFixedSize(true);
        mRelatedBookRecyclerView.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false));
        mRelatedBookRecyclerView.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.VERTICAL));
    }


    private void observeListData() {
        predictChapterViewModel.observeRelatedBooks().observe(this, listResource -> {
            if (listResource.getStatus().equals(Status.ERROR)) {
                progressBarLoader.setVisibility(View.GONE);
                errorView.setVisibility(View.VISIBLE);
                errorView.setText("No Data Found");

            } else if (listResource.getStatus().equals(Status.LOADING)) {

                progressBarLoader.setVisibility(View.VISIBLE);

            } else if (listResource.getStatus().equals(Status.SUCCESS)) {
                progressBarLoader.setVisibility(View.GONE);
                predictConceptAdapter = new PredictConceptAdapter(listResource.getData(), this);
                mRelatedBookRecyclerView.setAdapter(predictConceptAdapter);
            }

        });
    }


    @Override
    public void onItemClick(HighlyRelatedBooksModel highlightImpl) {
        Intent intent = new Intent();
        intent.putExtra(Constants.SELECTED_WORD, highlightImpl.getParagraph_related());
        intent.putExtra(Constants.SELECTED_HIGH_RATED_BOOK,highlightImpl);
        intent.putExtra(Constants.TYPE, Constants.HIGHLY_RELATED_BOOK_SELECTED);
        setResult(Activity.RESULT_OK, intent);
        finish();

    }
}
