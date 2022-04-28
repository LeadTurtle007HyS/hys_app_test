import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hys/SocialPart/database/SocialFeedCauseDB.dart';
import 'package:hys/database/questionSection/crud.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay,
      this.recurrenceRule, this.meetingid);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String meetingid;
  String recurrenceRule;
}

List<Meeting> meetings = <Meeting>[];

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }

  String getRecurrenceRule(int index) {
    return appointments[index].recurrenceRule;
  }

  String getMeetingID(int index) {
    return appointments[index].meetingid;
  }
}

MeetingDataSource _getDataSource(
    eventName1, date1, fromtime1, totime1, meetingid) {
  TimeOfDay _startTime = TimeOfDay(
      hour: int.parse(fromtime1.split(":")[0]),
      minute: int.parse(fromtime1.split(":")[1]));

  final DateTime startdate = DateTime.parse(date1);

  final DateTime startdate1 = DateTime(startdate.year, startdate.month,
      startdate.day, _startTime.hour, _startTime.minute, 0);

  TimeOfDay _endTime = TimeOfDay(
      hour: int.parse(totime1.split(":")[0]),
      minute: int.parse(totime1.split(":")[1]));

  int diff = _endTime.hour - _startTime.hour;

  final DateTime endDate1 = startdate1.add(Duration(hours: diff));

  meetings.add(Meeting(eventName1, startdate1, endDate1,
      const Color(0xFF0F8644), false, "", meetingid));
}

class CalendarEvent extends StatefulWidget {
  String date1;
  String fromtime1;
  String totime1;

  String freq1;
  String eventName1;
  String meetingid;
  CalendarEvent(this.eventName1, this.date1, this.fromtime1, this.totime1,
      this.freq1, this.meetingid);
  @override
  _CalendarEventState createState() => _CalendarEventState(this.eventName1,
      this.date1, this.fromtime1, this.totime1, this.freq1, this.meetingid);
}

CalendarController _calendarController = CalendarController();
//String frequency = freq1.toUpperCase();

class _CalendarEventState extends State<CalendarEvent> {
  String date1;
  String fromtime1;
  String totime1;
  List<List<String>> data = [];
  String freq1;
  String eventName1;
  String meetingid;
  _CalendarEventState(this.eventName1, this.date1, this.fromtime1, this.totime1,
      this.freq1, this.meetingid);

  SocialFeedCreateCause socialobj = SocialFeedCreateCause();
  QuerySnapshot userCalendar;
  QuerySnapshot personaldata;
  var firebaseUser = auth.FirebaseAuth.instance.currentUser.uid;
  String current_date = DateTime.now().toString();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CrudMethods crudobj = CrudMethods();

  @override
  void initState() {
    meetings = <Meeting>[];
    crudobj.getUserData().then((value) {
      setState(() {
        personaldata = value;
      });
    });
    socialobj.getUserCalendarWhere(firebaseUser).then((value) {
      setState(() {
        userCalendar = value;
        if (userCalendar != null) {
          for (int i = 0; i < userCalendar.docs.length; i++) {
            print(userCalendar.docs[i].get('to'));
            _getDataSource(
                userCalendar.docs[i].get('eventname'),
                userCalendar.docs[i].get('date'),
                userCalendar.docs[i].get('from'),
                userCalendar.docs[i].get('to'),
                userCalendar.docs[i].get('meetingid'));
          }
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(key: _scaffoldKey, body: _body(context)));
  }

  _body(BuildContext context) {
    if (userCalendar != null && personaldata != null) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: SfCalendar(
            showNavigationArrow: true,
            onTap: (CalendarTapDetails details) {
              data.clear();
              for (int j = 0; j < userCalendar.docs.length; j++) {
                if (userCalendar.docs[j].get("date") ==
                    details.date.toString()) {
                  List<String> initData = [];
                  initData.add(userCalendar.docs[j].get("eventname"));
                  initData.add(userCalendar.docs[j].get("eventtype"));
                  initData.add(userCalendar.docs[j].get("feedid"));
                  initData.add(userCalendar.docs[j].get("meetingid"));
                  initData.add(userCalendar.docs[j].get("date"));
                  initData.add(userCalendar.docs[j].get("from"));
                  initData.add(userCalendar.docs[j].get("to"));
                  data.add(initData);
                }
              }

              if (data.length != 0) {
                todaysMeetingDetails(data, context);
              } else {}
            },
            view: CalendarView.month,
            showDatePickerButton: true,
            minDate: DateTime(2021, 01, 01, 0, 0, 0),
            resourceViewSettings: ResourceViewSettings(),
            monthViewSettings: MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                showAgenda: true,
                agendaViewHeight: 280,
                dayFormat: 'EEE',
                monthCellStyle: MonthCellStyle(
                    backgroundColor: Color(0xFF293462),
                    trailingDatesBackgroundColor: Color(0xff216583),
                    leadingDatesBackgroundColor: Color(0xff216583),
                    todayBackgroundColor: Color(0xFFf7be16),
                    textStyle: TextStyle(fontSize: 12, fontFamily: 'Arial'),
                    trailingDatesTextStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        fontFamily: 'Arial'),
                    leadingDatesTextStyle: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        fontFamily: 'Arial'))),
            dataSource: MeetingDataSource(meetings)),
      );
    }
    return _loading();
  }

  YYDialog todaysMeetingDetails(List<List<String>> data, BuildContext context) {
    return YYDialog().build(context)
      ..gravity = Gravity.bottom
      ..gravityAnimationEnable = true
      ..barrierDismissible = false
      ..backgroundColor = Colors.transparent
      ..widget(Container(
        height: MediaQuery.of(context).size.height - 50,
        margin: EdgeInsets.only(left: 2, right: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          color: Color(0xBEFFFFFF),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              print(data[i][0]);
              return i == 0 ? if_i_zero() : _joinMeeting(i);
            },
          ),
        ),
      ))
      ..show();
  }

  _joinMeeting(int i) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        shadowColor: Color(0xFFE9E9E9),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Color(0xFFA2ECFF),
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(data[i][0].toString(),
                      style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF242424),
                        fontWeight: FontWeight.w700,
                      )))
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RichText(
                      text: TextSpan(
                          text: "From: ",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF242424),
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                        TextSpan(
                            text: data[i][5].toString(),
                            style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF242424),
                              fontWeight: FontWeight.w700,
                            )))
                      ])),
                  RichText(
                      text: TextSpan(
                          text: "To: ",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF242424),
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                        TextSpan(
                            text: data[i][6].toString(),
                            style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF242424),
                              fontWeight: FontWeight.w700,
                            )))
                      ])),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              data[i][1].toString() == "offline"
                  ? SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                            text: TextSpan(
                                text: "Meeting ID: ",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF242424),
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                              TextSpan(
                                  text: data[i][3].toString(),
                                  style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF242424),
                                    fontWeight: FontWeight.w700,
                                  )))
                            ])),
                      ],
                    ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: MediaQuery.of(context).size.width / 8.9,
                width: MediaQuery.of(context).size.width / 3.21,
                child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    color: data[i][4].toString().substring(0, 10) !=
                            current_date.substring(0, 10)
                        ? Color(0xFFDADADA)
                        : Color(0xFF08C1E2),
                    splashColor: Color(0xFF0FA099),
                    child: Center(
                        child: Text('JOIN',
                            style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF242424),
                              fontWeight: FontWeight.w800,
                            )))),
                    onPressed: () {
                      if (data[i][4].toString().substring(0, 10) ==
                          current_date.substring(0, 10)) {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => JoinMeetingScreen(
                        //             data[i][0].toString(),
                        //             data[i][3].toString(),
                        //             personaldata.docs[0].get("firstname") +
                        //                 " " +
                        //                 personaldata.docs[0].get("lastname"),
                        //             current_date.substring(0, 10),
                        //             data[i][5].toString(),
                        //             data[i][6].toString())));
                      } else {
                        print(data[i][4].toString());
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  if_i_zero() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                data.clear();
                Navigator.of(context).pop();
              },
              child: Text("Cancel",
                  style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF242424),
                    fontWeight: FontWeight.w500,
                  ))),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        _joinMeeting(0)
      ],
    );
  }

  _loading() {
    return Center(
      child: Container(
          height: 50.0,
          margin: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0962ff)),
          ))),
    );
  }
}
