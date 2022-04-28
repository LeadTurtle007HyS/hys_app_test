class StrengthModel{

 String createdate;
 int grade;
 String subject;
 String  topic ;
 String userID;

StrengthModel({this.createdate, this.grade, this.subject, this.topic,
    this.userID});


StrengthModel.fromJson(Map<String, dynamic> json) {
  this.createdate = json['createdate'];
  grade = json['grade'];
  subject = json['subject'];
  topic=json['topic'];
  userID=json['user_id'];
}

Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['createdate'] = createdate;
  data['grade'] = grade;
  data['subject'] = subject;
  data['topic'] = topic;
  data['user_id'] = userID;

  return data;
}

}

