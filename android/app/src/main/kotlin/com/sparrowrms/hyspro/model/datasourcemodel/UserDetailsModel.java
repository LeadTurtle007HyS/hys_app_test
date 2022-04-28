package com.sparrowrms.hyspro.model.datasourcemodel;

import android.os.Parcel;
import android.os.Parcelable;

public class UserDetailsModel implements Parcelable {

    public static final Creator<UserDetailsModel> CREATOR = new Creator<UserDetailsModel>() {
        @Override
        public UserDetailsModel createFromParcel(Parcel in) {
            return new UserDetailsModel(in);
        }

        @Override
        public UserDetailsModel[] newArray(int size) {
            return new UserDetailsModel[size];
        }
    };
    private String email;
    private String firstname;
    private String lastname;
    private String gender;
    private String mobile;
    private String novelsread;
    private String placesvisited;
    private String profilepic;
    private String state;
    private String street;
    private String userid;
    private String address;

    public UserDetailsModel() {
    }

    public UserDetailsModel(String email, String firstname, String lastname, String gender, String mobile, String novelsread, String placesvisited, String profilepic, String state, String street, String userid, String address) {
        this.email = email;
        this.firstname = firstname;
        this.lastname = lastname;
        this.gender = gender;
        this.mobile = mobile;
        this.novelsread = novelsread;
        this.placesvisited = placesvisited;
        this.profilepic = profilepic;
        this.state = state;
        this.street = street;
        this.userid = userid;
        this.address = address;
    }

    protected UserDetailsModel(Parcel in) {
        email = in.readString();
        firstname = in.readString();
        lastname = in.readString();
        gender = in.readString();
        mobile = in.readString();
        novelsread = in.readString();
        placesvisited = in.readString();
        profilepic = in.readString();
        state = in.readString();
        street = in.readString();
        userid = in.readString();
        address = in.readString();
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFirstname() {
        return firstname;
    }

    public void setFirstname(String firstname) {
        this.firstname = firstname;
    }

    public String getLastname() {
        return lastname;
    }

    public void setLastname(String lastname) {
        this.lastname = lastname;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getMobile() {
        return mobile;
    }

    public void setMobile(String mobile) {
        this.mobile = mobile;
    }

    public String getNovelsread() {
        return novelsread;
    }

    public void setNovelsread(String novelsread) {
        this.novelsread = novelsread;
    }

    public String getPlacesvisited() {
        return placesvisited;
    }

    public void setPlacesvisited(String placesvisited) {
        this.placesvisited = placesvisited;
    }

    public String getProfilepic() {
        return profilepic;
    }

    public void setProfilepic(String profilepic) {
        this.profilepic = profilepic;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getStreet() {
        return street;
    }

    public void setStreet(String street) {
        this.street = street;
    }

    public String getUserid() {
        return userid;
    }

    public void setUserid(String userid) {
        this.userid = userid;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel parcel, int i) {
        parcel.writeString(email);
        parcel.writeString(firstname);
        parcel.writeString(lastname);
        parcel.writeString(gender);
        parcel.writeString(mobile);
        parcel.writeString(novelsread);
        parcel.writeString(placesvisited);
        parcel.writeString(profilepic);
        parcel.writeString(state);
        parcel.writeString(street);
        parcel.writeString(userid);
        parcel.writeString(address);
    }
}
