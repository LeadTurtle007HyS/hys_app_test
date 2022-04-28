package com.sparrowrms.hyspro.ui.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.sparrowrms.hyspro.R;
import com.sparrowrms.hyspro.model.dataclasses.RelatedQuestionModel;

import java.util.List;

public class RelatedQuestionAdapter  extends RecyclerView.Adapter<RelatedQuestionAdapter.HighlightedBookListHolder> {


    private List<RelatedQuestionModel> highlightedBookList;
    private Context context;
    private RelatedQuestionAdapterCallback highlyRelatedBooksAdapterCallback;

    public RelatedQuestionAdapter(List<RelatedQuestionModel> highlightedBookList, Context context,RelatedQuestionAdapterCallback highlyRelatedBooksAdapterCallback) {
        this.highlightedBookList = highlightedBookList;
        this.context = context;
        this.highlyRelatedBooksAdapterCallback=highlyRelatedBooksAdapterCallback;
    }

    @NonNull
    @Override
    public HighlightedBookListHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new HighlightedBookListHolder(LayoutInflater.from(parent.getContext())
                .inflate(R.layout.highly_related_book_list_item_view, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull HighlightedBookListHolder holder, int position) {

        RelatedQuestionModel highlyRelatedBooksModel=highlightedBookList.get(position);
        holder.bookName.setText(String.format("%s %s", highlyRelatedBooksModel.getQuestion_Paper(), highlyRelatedBooksModel.getYear()));
        holder.paragraph.setText(highlyRelatedBooksModel.getQuestion_related());
        holder.list_item_container.setOnClickListener(view -> {
            if(highlyRelatedBooksAdapterCallback!=null){
                highlyRelatedBooksAdapterCallback.onItemClick(highlyRelatedBooksModel);
            }
        });
    }

    @Override
    public int getItemCount() {
        return highlightedBookList.size();
    }

    static class HighlightedBookListHolder extends RecyclerView.ViewHolder {

        private final TextView bookName;
        private final TextView paragraph;
        private final RelativeLayout list_item_container;

        public HighlightedBookListHolder(@NonNull View itemView) {
            super(itemView);

            bookName=itemView.findViewById(R.id.bookName);
            paragraph=itemView.findViewById(R.id.paragraph);
            list_item_container=itemView.findViewById(R.id.list_item_container);
        }
    }

    public interface RelatedQuestionAdapterCallback {
        void onItemClick(RelatedQuestionModel highlightImpl);
    }
}

