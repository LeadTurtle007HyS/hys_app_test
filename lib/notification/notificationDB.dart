import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());

class NotificationDB {
  Future<void> createNotification(post_id, receiver_id, token, message, title,
      notify_section, notify_function, process) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection('new_notification');
    // if (process == "+") {
    //   await reference.add({
    //     "post_id": post_id,
    //     "sender_id": firebaseUser,
    //     "receiver_id": receiver_id,
    //     "token": token,
    //     "message": message,
    //     "tittle": title,
    //     "notify_section": notify_section,
    //     "notify_function": notify_function,
    //     "comparedate": comparedate
    //   });
    // }
    addNotificationData([
      'ntf$post_id$firebaseUser$comparedate',
      notify_function,
      notify_section,
      firebaseUser,
      receiver_id,
      token,
      title,
      message,
      post_id,
      '',
      comparedate,
      process == '-' ? "delete" : "add"
    ]);
  }

  Future<bool> addNotificationData(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/add_notification_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "notify_id": data[0],
        "notify_type": data[1],
        "section": data[2],
        "sender_id": data[3],
        "receiver_id": data[4],
        "token": data[5],
        "title": data[6],
        "message": data[7],
        "post_id": data[8],
        "post_type": data[9],
        "is_clicked": "false",
        "compare_date": data[10],
        "addordelete": data[11]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> sendNotification(List data) async {
    print(data);

    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/add_notification_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "notify_id": data[0],
        "notify_type": data[1],
        "section": data[2],
        "sender_id": data[3],
        "receiver_id": data[4],
        "token": data[5],
        "title": data[6],
        "message": data[7],
        "post_id": data[8],
        "post_type": data[9],
        "is_clicked": data[10],
        "compare_date": data[11],
        "addordelete": data[12]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      if (data[12] == 'add') {
        final http.Response notification_response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            "Access-Control_Allow_Origin": "*",
            'Authorization':
                'key=AAAAqaWaBPY:APA91bHQAvw_ld3ulPKtYDICkrOL0bwB0cs3wqak5zfj0n558nYM_qUvA4P_L4dZqAz3Wk2oxnWVnQjmyisYMAz2t9oDmoo_xj0ocMAg8_gzamFlNHf2OffzMuFrW_RhffxKTiAYgjyy'
          },
          body: json.encode({
            'to': data[5],
            'message': {
              'token': data[5],
            },
            "notification": {"title": data[6], "body": data[7]}
          }),
        );
      }
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateNotificationDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/update_notification_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{"notify_id": data[0]}),
    );
    print(response.statusCode);
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteNotificationDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/delete_notification_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{"notify_id": data[0]}),
    );
    print(response.statusCode);
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }
}
//////////////////////////////notification//////////////////////////////////////
// notificationDB.createNotification(
//allCausePostData[i]["post_id"],
//allCausePostData[i]["user_id"],
//tokenData
//   .child(
//     "usertoken/${allCausePostData[i]["user_id"]}/tokenid")
//     .value,
//"${userDataDB.get('first_name')} ${userDataDB.get('last_name')} reacted on your post.",
//"You got a reaction",
//"socialpost",
//"reaction",
//"+");
///////////////////////////////////////////////////////////////////////////////