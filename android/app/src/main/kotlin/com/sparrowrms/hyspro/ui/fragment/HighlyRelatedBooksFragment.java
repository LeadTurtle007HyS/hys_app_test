package com.sparrowrms.hyspro.ui.fragment;

import android.app.Activity;
import android.content.Context;
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
import com.sparrowrms.hyspro.model.dataclasses.HighlyRelatedBooksModel;
import com.sparrowrms.hyspro.model.dataclasses.PredictRelatedBooksReqBody;
import com.sparrowrms.hyspro.network.ApiHelper;
import com.sparrowrms.hyspro.network.HYSAPIHelper;
import com.sparrowrms.hyspro.network.HYSNetworking;
import com.sparrowrms.hyspro.network.RetrofitNetworking;
import com.sparrowrms.hyspro.ui.adapter.HighlyRelatedBooksAdapter;
import com.sparrowrms.hyspro.util.AppUtil;
import org.readium.r2.shared.Publication;
import com.sparrowrms.hyspro.Config;
import com.sparrowrms.hyspro.util.Status;
import com.sparrowrms.hyspro.viewmodels.ApiHelperViewModelFactory;
import com.sparrowrms.hyspro.viewmodels.HighlyRelatedBooksViewModel;
import static com.sparrowrms.hyspro.Constants.*;

public class HighlyRelatedBooksFragment extends AppCompatActivity implements HighlyRelatedBooksAdapter.HighlyRelatedBooksAdapterCallback{
    private HighlyRelatedBooksAdapter highlyRelatedBooksAdapter;
    private RecyclerView mRelatedBookRecyclerView;
    private ProgressBar progressBarLoader;
    private HighlyRelatedBooksViewModel highlyRelatedBooksViewModel;
    private TextView errorView;
    private Config mConfig;
    private String selectedText;
    private Publication publication;
    private String dictionaryID=null;
    private HighlyRatedBookRequestBody  highlyRatedBookRequestBody;
    public static void newInstance(Context context , String selectedWord) {



    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.fragment_contents);
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
        highlyRelatedBooksViewModel = new ViewModelProvider(this, new ApiHelperViewModelFactory(new ApiHelper(RetrofitNetworking.INSTANCE.getAgoraTokenAPIRequest()),new HYSAPIHelper(HYSNetworking.INSTANCE.getAgoraTokenAPIRequest()))).get(HighlyRelatedBooksViewModel.class);
        observeListData();
        highlyRelatedBooksViewModel.getHighlyRelatedBooks(highlyRatedBookRequestBody);

    }

    public void configRecyclerViews() {
        mRelatedBookRecyclerView.setHasFixedSize(true);
        mRelatedBookRecyclerView.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false));
        mRelatedBookRecyclerView.addItemDecoration(new DividerItemDecoration(this, DividerItemDecoration.VERTICAL));
    }


    private void observeListData() {
        highlyRelatedBooksViewModel.observeRelatedBooks().observe(this, listResource -> {
            if (listResource.getStatus().equals(Status.ERROR)) {
                progressBarLoader.setVisibility(View.GONE);
                errorView.setVisibility(View.VISIBLE);
                errorView.setText("No Data Found");

            } else if (listResource.getStatus().equals(Status.LOADING)) {

                progressBarLoader.setVisibility(View.VISIBLE);

            } else if (listResource.getStatus().equals(Status.SUCCESS)) {
                progressBarLoader.setVisibility(View.GONE);
                highlyRelatedBooksAdapter = new HighlyRelatedBooksAdapter(listResource.getData(), this,this);
                mRelatedBookRecyclerView.setAdapter(highlyRelatedBooksAdapter);
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
