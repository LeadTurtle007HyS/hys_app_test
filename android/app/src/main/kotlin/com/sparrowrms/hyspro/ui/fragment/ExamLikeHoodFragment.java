package com.sparrowrms.hyspro.ui.fragment;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import com.sparrowrms.hyspro.R;
import com.sparrowrms.hyspro.ui.adapter.ExamLikeHoodAdapter;
import com.sparrowrms.hyspro.util.AppUtil;
import com.sparrowrms.hyspro.Config;
import com.sparrowrms.hyspro.Constants;
import com.sparrowrms.hyspro.FolioReader;
import com.sparrowrms.hyspro.model.ExamLikeHoodImpl;
import com.sparrowrms.hyspro.model.event.UpdateExamLikeHoodEvent;
import com.sparrowrms.hyspro.model.sqlite.ExamLikeHoodTable;

import org.greenrobot.eventbus.EventBus;


public class ExamLikeHoodFragment extends Fragment implements ExamLikeHoodAdapter.ExamLikeHoodAdapterCallback {
    private static final String TOUGHNESS_ITEM = "highlight_item";
    private View mRootView;
    private ExamLikeHoodAdapter adapter;
    private String mBookId;
    private TextView btn_All,btn_high,btn_Medium,btn_Low;
    private RecyclerView highlightsView;
    private Config config;
  

    public ExamLikeHoodFragment() {
        // Required empty public constructor
    }

 
    // TODO: Rename and change types and number of parameters
    public static ExamLikeHoodFragment newInstance(String bookId, String epubTitle) {
        ExamLikeHoodFragment fragment = new ExamLikeHoodFragment();
        Bundle args = new Bundle();
        args.putString(FolioReader.EXTRA_BOOK_ID, bookId);
        args.putString(Constants.BOOK_TITLE, epubTitle);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
        
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        mRootView= inflater.inflate(R.layout.fragment_exam_like_hood, container, false);

        return mRootView;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        highlightsView =  mRootView.findViewById(R.id.rv_highlights);
        config = AppUtil.getSavedConfig(getActivity());
        mBookId = getArguments().getString(FolioReader.EXTRA_BOOK_ID);
        btn_All=mRootView.findViewById(R.id.btn_All);
        btn_high=mRootView.findViewById(R.id.btn_high);
        btn_Medium=mRootView.findViewById(R.id.btn_Medium);
        btn_Low=mRootView.findViewById(R.id.btn_Low);

        if (config.isNightMode()) {
            mRootView.findViewById(R.id.rv_highlights).
                    setBackgroundColor(ContextCompat.getColor(getActivity(),
                            R.color.black));
        }
        highlightsView.setLayoutManager(new LinearLayoutManager(getActivity()));
        highlightsView.addItemDecoration(new DividerItemDecoration(getActivity(), DividerItemDecoration.VERTICAL));

        adapter = new ExamLikeHoodAdapter(getActivity(), ExamLikeHoodTable.getAllExamLikeHood(mBookId), this, config);
        highlightsView.setAdapter(adapter);

        setSelectedTextColor(btn_All);
        btn_All.setOnClickListener(view1 -> {
            setSelectedTextColor(btn_All);
            unSelectedTextColor(btn_high);
            unSelectedTextColor(btn_Low);
            unSelectedTextColor(btn_Medium);
            adapter = new ExamLikeHoodAdapter(getActivity(), ExamLikeHoodTable.getAllExamLikeHood(mBookId), this, config);
            highlightsView.setAdapter(adapter);
        });

        btn_high.setOnClickListener(view12 ->{
            setSelectedTextColor(btn_high);
            unSelectedTextColor(btn_Medium);
            unSelectedTextColor(btn_Low);
            unSelectedTextColor(btn_All);
            difficultyLevel(ExamLikeHoodImpl.ExamLikeHoodType.classForStyle(ExamLikeHoodImpl.ExamLikeHoodType.High));
        } );
        btn_Medium.setOnClickListener(view12 ->{
            setSelectedTextColor(btn_Medium);
            unSelectedTextColor(btn_high);
            unSelectedTextColor(btn_Low);
            unSelectedTextColor(btn_All);
            difficultyLevel(ExamLikeHoodImpl.ExamLikeHoodType.classForStyle(ExamLikeHoodImpl.ExamLikeHoodType.Medium));
        } );
        btn_Low.setOnClickListener(view12 ->{
            setSelectedTextColor(btn_Low);
            unSelectedTextColor(btn_high);
            unSelectedTextColor(btn_Medium);
            unSelectedTextColor(btn_All);
            difficultyLevel(ExamLikeHoodImpl.ExamLikeHoodType.classForStyle(ExamLikeHoodImpl.ExamLikeHoodType.Low));
        } );
    }

    private void difficultyLevel(String type) {
        adapter = new ExamLikeHoodAdapter(getActivity(), ExamLikeHoodTable.getAllExamLikeHoodWithType(mBookId,type), this, config);
        highlightsView.setAdapter(adapter);
    }

    private void setSelectedTextColor(TextView textView){
        textView.setTextColor(getResources().getColor(R.color.red));
    }
    private void unSelectedTextColor(TextView textView){
        textView.setTextColor(getResources().getColor(R.color.white));
    }


    @Override
    public void onItemClick(ExamLikeHoodImpl toughnessImpl) {
        Intent intent = new Intent();
        intent.putExtra(TOUGHNESS_ITEM, toughnessImpl);
        intent.putExtra(Constants.TYPE, Constants.EXAM_LIKE_HOOD_SELECTED);
        getActivity().setResult(Activity.RESULT_OK, intent);
        getActivity().finish();
    }

    @Override
    public void deleteHighlight(int id) {
        if (ExamLikeHoodTable.deleteExamLikeHood(id)) {
            EventBus.getDefault().post(new UpdateExamLikeHoodEvent());
        }
    }

    @Override
    public void editNote(ExamLikeHoodImpl highlightImpl, int position) {

    }

}