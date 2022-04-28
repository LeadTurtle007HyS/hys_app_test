package com.sparrowrms.hyspro.ui.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.TextView;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.sparrowrms.hyspro.Constants;
import com.sparrowrms.hyspro.FolioReader;
import com.sparrowrms.hyspro.R;
import com.sparrowrms.hyspro.model.dataclasses.HighlyRatedBookRequestBody;
import com.sparrowrms.hyspro.model.dataclasses.RelatedQuestionModel;
import com.sparrowrms.hyspro.network.ApiHelper;
import com.sparrowrms.hyspro.network.HYSAPIHelper;
import com.sparrowrms.hyspro.network.HYSNetworking;
import com.sparrowrms.hyspro.network.RetrofitNetworking;
import com.sparrowrms.hyspro.ui.adapter.RelatedQuestionAdapter;
import com.sparrowrms.hyspro.util.AppUtil;
import org.readium.r2.shared.Publication;
import com.sparrowrms.hyspro.Config;
import com.sparrowrms.hyspro.util.Status;
import com.sparrowrms.hyspro.viewmodels.ApiHelperViewModelFactory;
import com.sparrowrms.hyspro.viewmodels.HighlyRelatedBooksViewModel;
import java.util.Objects;
import static com.sparrowrms.hyspro.Constants.*;



public class RelatedQuestionScreen  extends AppCompatActivity implements RelatedQuestionAdapter.RelatedQuestionAdapterCallback{
    private RelatedQuestionAdapter highlyRelatedBooksAdapter;
    private RecyclerView mRelatedBookRecyclerView;
    private ProgressBar progressBarLoader;
    private HighlyRelatedBooksViewModel highlyRelatedBooksViewModel;
    private TextView errorView,highlyRatedBookTitle;
    private Config mConfig;
    private String selectedText;
    private Publication publication;

    private HighlyRatedBookRequestBody highlyRatedBookRequestBody;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.fragment_contents);
        if (getSupportActionBar() != null) {
            // getSupportActionBar().hide();
        }
        mConfig = AppUtil.getSavedConfig(this);
        selectedText=getIntent().getStringExtra(SELECTED_WORD);
        highlyRatedBookRequestBody= (HighlyRatedBookRequestBody) getIntent().getSerializableExtra(FolioReader.HIGHLY_RATED_BOOK_REQ);
        highlyRatedBookRequestBody.setQuery(selectedText);
        initView();
    }

    private void initView(){
        mRelatedBookRecyclerView = findViewById(R.id.recycler_view_menu);
        progressBarLoader=findViewById(R.id.progressBarLoader);
        highlyRatedBookTitle=findViewById(R.id.highlyRatedBookTitle);
        highlyRatedBookTitle.setText("Related Question");
        errorView =findViewById(R.id.tv_error);
        configRecyclerViews();
        highlyRelatedBooksViewModel = new ViewModelProvider(this, new ApiHelperViewModelFactory(new ApiHelper(RetrofitNetworking.INSTANCE.getAgoraTokenAPIRequest()),new HYSAPIHelper(HYSNetworking.INSTANCE.getAgoraTokenAPIRequest()))).get(HighlyRelatedBooksViewModel.class);
        observeListData();
        highlyRelatedBooksViewModel.getPredictQuestionPaper(highlyRatedBookRequestBody.getSubject(),highlyRatedBookRequestBody.getGrade(),selectedText);
    }


    public void configRecyclerViews() {
        mRelatedBookRecyclerView.setHasFixedSize(true);
        mRelatedBookRecyclerView.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false));
        mRelatedBookRecyclerView.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.VERTICAL));
    }


    private void observeListData() {
        highlyRelatedBooksViewModel.observerQuestionList().observe(this, listResource -> {
            if (listResource.getStatus().equals(Status.ERROR)) {
                progressBarLoader.setVisibility(View.GONE);
                errorView.setVisibility(View.VISIBLE);
                errorView.setText("No Data Found");

            } else if (listResource.getStatus().equals(Status.LOADING)) {

                progressBarLoader.setVisibility(View.VISIBLE);

            } else if (listResource.getStatus().equals(Status.SUCCESS)) {
                progressBarLoader.setVisibility(View.GONE);
                if(Objects.requireNonNull(listResource.getData()).size()>0){

                    highlyRelatedBooksAdapter = new RelatedQuestionAdapter(listResource.getData(), this,this);
                    mRelatedBookRecyclerView.setAdapter(highlyRelatedBooksAdapter);
                }else{
                    errorView.setVisibility(View.VISIBLE);
                    errorView.setText("No Data Found");
                }

            }

        });
    }


    @Override
    public void onItemClick(RelatedQuestionModel highlightImpl) {

        String selectedWord=highlightImpl.getQuestion_related().trim();
        Intent intent = new Intent();
        intent.putExtra(Constants.SELECTED_WORD, selectedWord);
        intent.putExtra(SELECTED_HIGH_RATED_BOOK,highlightImpl);
        intent.putExtra(Constants.SELECTED_YEAR,highlightImpl.getYear());
        intent.putExtra(Constants.TYPE, Constants.HIGHLY_RELATED_BOOK_SELECTED);
        setResult(Activity.RESULT_OK, intent);
        finish();
    }
}
