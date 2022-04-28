
package com.sparrowrms.hyspro.ui.activity

import android.annotation.SuppressLint
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.widget.ProgressBar
import android.widget.Toast
import androidx.appcompat.widget.Toolbar
import androidx.lifecycle.ViewModelProvider
import androidx.recyclerview.widget.DefaultItemAnimator
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.sparrowrms.hyspro.R
import com.sparrowrms.hyspro.data.repository.FirebaseDataRepository
import com.sparrowrms.hyspro.dataSource.remote.FirebaseDataSource
import com.sparrowrms.hyspro.model.dataclasses.CallingUserNotificationDetails
import com.sparrowrms.hyspro.model.dataclasses.CreateRoomBody
import com.sparrowrms.hyspro.model.datasourcemodel.UserDetailsModel
import com.sparrowrms.hyspro.network.ApiHelper
import com.sparrowrms.hyspro.network.RetrofitClient
import com.sparrowrms.hyspro.ui.adapter.UserListAdapter
import com.sparrowrms.hyspro.util.Status
import com.sparrowrms.hyspro.viewmodels.DataViewModelFactory
import com.sparrowrms.hyspro.viewmodels.UserListViewModel



class UserListActivity : AppCompatActivity(), UserListAdapter.UserItemCallButtonClickedListner {

    private val messageRecyclerAdapter: UserListAdapter = UserListAdapter()
    lateinit var userListViewModel:UserListViewModel
    private lateinit var recyclerView: RecyclerView
    private lateinit var splashProgressBar:ProgressBar

    companion object{
        val userDetailsKey="Calling_User_Details";
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_user_list)
        userListViewModel= ViewModelProvider(this,DataViewModelFactory(FirebaseDataRepository(FirebaseDataSource()),ApiHelper(RetrofitClient.agoraTokenAPIRequest)),).get(UserListViewModel::class.java)

        intToolbar()
        intView()
        observeMessageList()
        messageRecyclerAdapter.setUserItemCallButtonClickedListner(this)

        genrateRoomToken()


    }

    private fun observeMessageList() {

        userListViewModel.allUserList.observe(this) { stateResource ->
            when (stateResource.status) {
                Status.LOADING -> {
                    splashProgressBar.visibility = View.VISIBLE

                }
                Status.SUCCESS -> {
                    splashProgressBar.visibility = View.GONE
                    messageRecyclerAdapter.setMessageList(stateResource.data)
                    recyclerView.adapter = messageRecyclerAdapter

                }
                Status.ERROR -> {
                    splashProgressBar.visibility = View.GONE
                    showSnackBar(stateResource.message)
                }
            }

        }
    }

    private fun intView() {
        recyclerView = findViewById(R.id.recyclerView)
        recyclerView.setHasFixedSize(true)
        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.itemAnimator = DefaultItemAnimator()
        splashProgressBar=findViewById(R.id.splashProgressBar);
    }

    private fun intToolbar() {
        val toolbar = findViewById<Toolbar>(R.id.toolbar)
//        toolbar.setTitleTextAppearance(this, R.style.ToolbarTextAppearance)
//        toolbar.setSubtitleTextAppearance(this, R.style.ToolbarSubtitleTextAppearance)
        setSupportActionBar(toolbar)
        this.supportActionBar?.title = "User List"
        supportActionBar!!.setDisplayHomeAsUpEnabled(true)
    }

    override fun onButtonClicked(userDetailsModel: UserDetailsModel?, type: Int) {

        if(type==1){
//            val intent= Intent(this, CallActivity::class.java)
//            intent.putExtra(Constants.userDetailsKey,userDetailsModel)
//            intent.putExtra(Constants.EXTRA_IS_INCOMING_CALL,false)
//            intent.putExtra(Constants.EXTRA_IS_VIDEO_CALL,false)
//            startActivity(intent)

            CallActivity.start(this,false,userDetailsModel!!,false,notificationDetails = CallingUserNotificationDetails())
        }else{
            CallActivity.start(this,false,userDetailsModel!!,true,notificationDetails = CallingUserNotificationDetails())
        }

    }

    private fun showSnackBar(message: String?) {

        Toast.makeText(this,message,Toast.LENGTH_LONG).show()

    }

    @SuppressLint("CheckResult")
    private fun genrateRoomToken(){

        val token ="NETLESSSDK_YWs9aGlJUFh6cWszU1hfNDhBbiZub25jZT03NTJlY2FkMC01Njg2LTExZWMtODg5NC1mNzI5MTE5NDBkNWEmcm9sZT0wJnNpZz00NzZjZDM1MGQ4ZGY3Mjg2MWY2NmY5ZmJjMDBhYjg5Mjk0MDk2YjBmMzU0OWZjNjU2Mzc1ZTFjNGRlZDI1MDFi"
        val region="us-sv"
        val createRoomBody=CreateRoomBody(3600000,"writer")

     val apiRequest=RetrofitClient.agoraTokenAPIRequest.createWhiteboardRoomToken(token,region,"wdejfrvgtkjrledmn1324rt5",createRoomBody)



    }


}