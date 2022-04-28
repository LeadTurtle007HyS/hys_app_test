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

import com.sparrowrms.hyspro.model.event.UpdateToughnessLevelEvent;
import com.sparrowrms.hyspro.ui.adapter.ToughnessLevelAdapter;
import com.sparrowrms.hyspro.util.AppUtil;
import com.sparrowrms.hyspro.Config;
import com.sparrowrms.hyspro.Constants;
import com.sparrowrms.hyspro.FolioReader;
import com.sparrowrms.hyspro.R;
import com.sparrowrms.hyspro.model.ToughnessImpl;
import com.sparrowrms.hyspro.model.sqlite.ToughnessLevelTable;

import org.greenrobot.eventbus.EventBus;


public class ToughnessLevalFragment extends Fragment implements ToughnessLevelAdapter.ToughnessLevelAdapterCallback {
    private static final String TOUGHNESS_ITEM = "highlight_item";
    private View mRootView;
    private ToughnessLevelAdapter adapter;
    private String mBookId;
    private TextView btn_All,btn_high,btn_Medium,btn_Low;
    private RecyclerView highlightsView;
    private Config config;

    public ToughnessLevalFragment() {
        // Required empty public constructor
    }

    public static ToughnessLevalFragment newInstance(String bookId, String epubTitle) {
        ToughnessLevalFragment fragment = new ToughnessLevalFragment();
        Bundle args = new Bundle();
        args.putString(FolioReader.EXTRA_BOOK_ID, bookId);
        args.putString(Constants.BOOK_TITLE, epubTitle);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        mRootView= inflater.inflate(R.layout.fragment_toughness_leval, container, false);
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

        adapter = new ToughnessLevelAdapter(getActivity(), ToughnessLevelTable.getAllToughNess(mBookId), this, config);
        highlightsView.setAdapter(adapter);

        setSelectedTextColor(btn_All);
        btn_All.setOnClickListener(view1 -> {
            setSelectedTextColor(btn_All);
            unSelectedTextColor(btn_high);
            unSelectedTextColor(btn_Low);
            unSelectedTextColor(btn_Medium);
            adapter = new ToughnessLevelAdapter(getActivity(), ToughnessLevelTable.getAllToughNess(mBookId), this, config);
            highlightsView.setAdapter(adapter);
        });

        btn_high.setOnClickListener(view12 ->{
            setSelectedTextColor(btn_high);
            unSelectedTextColor(btn_Medium);
            unSelectedTextColor(btn_Low);
            unSelectedTextColor(btn_All);
            difficultyLevel(ToughnessImpl.ToughNessType.classForStyle(ToughnessImpl.ToughNessType.High));
        } );
        btn_Medium.setOnClickListener(view12 ->{
            setSelectedTextColor(btn_Medium);
            unSelectedTextColor(btn_high);
            unSelectedTextColor(btn_Low);
            unSelectedTextColor(btn_All);
            difficultyLevel(ToughnessImpl.ToughNessType.classForStyle(ToughnessImpl.ToughNessType.Medium));
        } );
        btn_Low.setOnClickListener(view12 ->{
            setSelectedTextColor(btn_Low);
            unSelectedTextColor(btn_high);
            unSelectedTextColor(btn_Medium);
            unSelectedTextColor(btn_All);
            difficultyLevel(ToughnessImpl.ToughNessType.classForStyle(ToughnessImpl.ToughNessType.Low));
        } );
    }

    private void difficultyLevel(String type) {
        adapter = new ToughnessLevelAdapter(getActivity(), ToughnessLevelTable.getAllToughNessWithType(mBookId,type), this, config);
        highlightsView.setAdapter(adapter);
    }

    private void setSelectedTextColor(TextView textView){
        textView.setTextColor(getResources().getColor(R.color.red));
    }
    private void unSelectedTextColor(TextView textView){
       textView.setTextColor(getResources().getColor(R.color.white));
    }

    @Override
    public void onItemClick(ToughnessImpl toughnessImpl) {
        Intent intent = new Intent();
        intent.putExtra(TOUGHNESS_ITEM, toughnessImpl);
        intent.putExtra(Constants.TYPE, Constants.DIFFICULTY_LEVEL_SELECTED);
        getActivity().setResult(Activity.RESULT_OK, intent);
        getActivity().finish();
    }

    @Override
    public void deleteHighlight(int id) {
        if (ToughnessLevelTable.deleteToughNess(id)) {
            EventBus.getDefault().post(new UpdateToughnessLevelEvent());
        }
    }

    @Override
    public void editNote(ToughnessImpl highlightImpl, int position) {

    }
}