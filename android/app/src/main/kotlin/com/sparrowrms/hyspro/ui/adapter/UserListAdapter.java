package com.sparrowrms.hyspro.ui.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.sparrowrms.hyspro.R;
import com.sparrowrms.hyspro.model.datasourcemodel.UserDetailsModel;

import java.util.ArrayList;
import java.util.List;

import de.hdodenhof.circleimageview.CircleImageView;

public class UserListAdapter extends RecyclerView.Adapter<UserListAdapter.MessageViewHolder> {

    private List<UserDetailsModel> userList = new ArrayList<>();
    private UserItemCallButtonClickedListner userItemCallButtonClickedListner;

    public UserListAdapter() {
    }




    public void setMessageList(List<UserDetailsModel> userList){
        this.userList = userList;
    }

    public void setUserItemCallButtonClickedListner(UserItemCallButtonClickedListner userItemCallButtonClickedListner){
        this.userItemCallButtonClickedListner=userItemCallButtonClickedListner;
    }



    @NonNull
    @Override
    public MessageViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        View view;

            view = inflater.inflate(R.layout.user_view_item,parent,false);
            return new MessageViewHolder(view);

    }

    @Override
    public void onBindViewHolder(@NonNull MessageViewHolder holder, int position) {

        UserDetailsModel model=userList.get(position);
        holder.display_name.setText(model.getFirstname());
        if(model.getAddress()!=null){
            holder.display_city.setText(model.getAddress());
        }
        Glide.with(holder.profile_image).load(model.getProfilepic()).into(holder.profile_image);
        holder.audioCall.setOnClickListener(view -> {
            if(userItemCallButtonClickedListner!=null){
                userItemCallButtonClickedListner.onButtonClicked(model,1);
            }
        });
        holder.videoCall.setOnClickListener(view -> {
            userItemCallButtonClickedListner.onButtonClicked(model,2);
        });


    }

    @Override
    public int getItemCount() {
        return userList.size();
    }

    public class MessageViewHolder extends RecyclerView.ViewHolder {

        TextView display_name,display_city;
        ImageButton audioCall,videoCall;
        CircleImageView profile_image;

        public MessageViewHolder(@NonNull View itemView) {
            super(itemView);

            display_name = itemView.findViewById(R.id.display_name);
            profile_image = itemView.findViewById(R.id.profile_image);
            audioCall=itemView.findViewById(R.id.audioCall);
            videoCall=itemView.findViewById(R.id.videoCall);
            display_city=itemView.findViewById(R.id.display_city);

        }
    }

    public interface UserItemCallButtonClickedListner{
        // type 1 -  audio , 2- video
        void onButtonClicked(UserDetailsModel userDetailsModel,int type);
    }

}




