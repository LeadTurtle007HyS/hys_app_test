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
import com.sparrowrms.hyspro.model.dataclasses.HighlyRelatedBooksModel;

import java.util.List;

public class PredictConceptAdapter extends RecyclerView.Adapter<PredictConceptAdapter.HighlightedBookListHolder> {


    private final List<HighlyRelatedBooksModel> highlightedBookList;
    private final HighlyRelatedBooksAdapterCallback highlyRelatedBooksAdapterCallback;

    public PredictConceptAdapter(List<HighlyRelatedBooksModel> highlightedBookList,HighlyRelatedBooksAdapterCallback highlyRelatedBooksAdapterCallback) {
        this.highlightedBookList = highlightedBookList;
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

        HighlyRelatedBooksModel highlyRelatedBooksModel=highlightedBookList.get(position);
        holder.bookName.setText(String.format("Chapter %s", highlyRelatedBooksModel.getChapter()));
        holder.paragraph.setText(highlyRelatedBooksModel.getParagraph_related());
        holder.publicationName.setText(highlyRelatedBooksModel.getPublication());
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
        private final TextView publicationName;
        private final RelativeLayout list_item_container;

        public HighlightedBookListHolder(@NonNull View itemView) {
            super(itemView);

            bookName=itemView.findViewById(R.id.bookName);
            paragraph=itemView.findViewById(R.id.paragraph);
            publicationName=itemView.findViewById(R.id.publicationName);
            list_item_container=itemView.findViewById(R.id.list_item_container);
        }
    }

    public interface HighlyRelatedBooksAdapterCallback {
        void onItemClick(HighlyRelatedBooksModel highlightImpl);
    }
}
