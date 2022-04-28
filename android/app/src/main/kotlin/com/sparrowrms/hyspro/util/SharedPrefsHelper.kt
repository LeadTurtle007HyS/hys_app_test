package com.sparrowrms.hyspro.util

import android.content.Context
import android.content.SharedPreferences
import com.sparrowrms.hyspro.Application
import com.sparrowrms.hyspro.model.datasourcemodel.UserDetailsModel

private const val SHARED_PREFS_NAME = "HYS_SHARED_PREF"
private const val LOGGED_IN_USER_ID = "qb_user_id"
private const val LOGGED_IN_USER_FName = "qb_user_login"
private const val LOGGED_IN_USER_LName = "qb_user_password"
private const val LOGGED_IN_USER_PROFILE = "qb_user_full_name"
private const val OPEN_BOOK_TYPE="open_book_type"


object SharedPrefsHelper {
    private var sharedPreferences: SharedPreferences = Application.getInstance().getSharedPreferences(SHARED_PREFS_NAME, Context.MODE_PRIVATE)



    fun delete(key: String) {
        if (sharedPreferences.contains(key)) {
            sharedPreferences.edit().remove(key).apply()
        }
    }

    fun save(key: String, value: Any?) {
        val editor = sharedPreferences.edit()
        when {
            value is Boolean -> editor.putBoolean(key, (value))
            value is Int -> editor.putInt(key, (value))
            value is Float -> editor.putFloat(key, (value))
            value is Long -> editor.putLong(key, (value))
            value is String -> editor.putString(key, value)
            value is Enum<*> -> editor.putString(key, value.toString())
            value != null -> throw RuntimeException("Attempting to save non-supported preference")
        }
        editor.apply()
    }


    fun saveLoggedInUser(qbUser: UserDetailsModel) {
        save(LOGGED_IN_USER_ID, qbUser.userid)
        save(LOGGED_IN_USER_FName, qbUser.firstname)
        save(LOGGED_IN_USER_LName, qbUser.lastname)
        save(LOGGED_IN_USER_PROFILE, qbUser.profilepic)
    }

    fun saveOpenedBookType(type: String) {
        save(OPEN_BOOK_TYPE, type)
    }



    fun getQbUser(): UserDetailsModel {
        val id = get<String>(LOGGED_IN_USER_ID)
        val fName = get<String>(LOGGED_IN_USER_FName)
        val lName = get<String>(LOGGED_IN_USER_LName)
        val profile = get<String>(LOGGED_IN_USER_PROFILE)
        val user = UserDetailsModel()
        user.userid = id
        user.firstname = fName
        user.lastname = lName
        user.profilepic=profile
        return user
    }

    fun getOpenBookType(): String {
        return get(OPEN_BOOK_TYPE);
    }

    fun clearAllData() {
        sharedPreferences.edit().clear().apply()
    }



    @Suppress("UNCHECKED_CAST")
    operator fun <T> get(key: String): T {
        return sharedPreferences.all[key] as T
    }

    @Suppress("UNCHECKED_CAST")
    operator fun <T> get(key: String, defValue: T): T {
        val returnValue = sharedPreferences.all[key] as T
        return returnValue ?: defValue
    }

    private fun has(key: String): Boolean {
        return sharedPreferences.contains(key)
    }



}