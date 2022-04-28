class Questions {
  int answer_count;
  final int answer_credit;
  final List answer_list;
  final String answer_preference;
  final String audio_reference;
  final String call_date;
  final String call_end_time;
  final String call_now;
  final String call_preferred_lang;
  final String call_start_time;
  final String city;
  final String compare_date;
  int examlikelyhood_count;
  final String first_name;
  final int grade;
  int impression_count;
  final String is_identity_visible;
  final String last_name;
  int like_count;
  final String note_reference;
  final String ocr_image;
  final String profilepic;
  final String question;
  final int question_credit;
  final String question_id;
  final String question_type;
  final String school_name;
  final String subject;
  final List tag_list;
  final String text_reference;
  final String topic;
  int toughness_count;
  final String user_id;
  final String video_reference;
  int view_count;
  String like_type;
  String examlikelyhood_type;
  String toughness_type;
  String is_save;
  String is_bookmark;

  Questions(
      {this.answer_count,
      this.answer_credit,
      this.answer_list,
      this.answer_preference,
      this.audio_reference,
      this.call_date,
      this.call_end_time,
      this.call_now,
      this.call_preferred_lang,
      this.call_start_time,
      this.city,
      this.compare_date,
      this.examlikelyhood_count,
      this.first_name,
      this.grade,
      this.impression_count,
      this.is_identity_visible,
      this.last_name,
      this.like_count,
      this.note_reference,
      this.ocr_image,
      this.profilepic,
      this.question,
      this.question_credit,
      this.question_id,
      this.question_type,
      this.school_name,
      this.subject,
      this.tag_list,
      this.text_reference,
      this.topic,
      this.toughness_count,
      this.user_id,
      this.video_reference,
      this.view_count,
      this.like_type,
      this.examlikelyhood_type,
      this.toughness_type,
      this.is_save,
      this.is_bookmark});

  factory Questions.fromJson(Map<String, dynamic> json) {
    return Questions(
        answer_count: json['answer_count'],
        answer_credit: json['answer_credit'],
        answer_list: json['answer_list'],
        answer_preference: json['answer_preference'],
        audio_reference: json['audio_reference'],
        call_date: json['call_date'],
        call_end_time: json['call_end_time'],
        call_now: json['call_now'],
        call_preferred_lang: json['call_preferred_lang'],
        call_start_time: json['call_start_time'],
        city: json['city'],
        compare_date: json['compare_date'],
        examlikelyhood_count: json['examlikelyhood_count'],
        first_name: json['first_name'],
        grade: json['grade'],
        impression_count: json['impression_count'],
        is_identity_visible: json['is_identity_visible'],
        last_name: json['last_name'],
        like_count: json['like_count'],
        note_reference: json['note_reference'],
        ocr_image: json['ocr_image'],
        profilepic: json['profilepic'],
        question: json['question'],
        question_credit: json['question_credit'],
        question_id: json['question_id'],
        question_type: json['question_type'],
        school_name: json['school_name'],
        subject: json['subject'],
        tag_list: json['tag_list'],
        text_reference: json['text_reference'],
        topic: json['topic'],
        toughness_count: json['toughness_count'],
        user_id: json['user_id'],
        video_reference: json['video_reference'],
        view_count: json['view_count'],
        like_type: json['like_type'] == null ? "" : json['like_type'],
        examlikelyhood_type: json['examlikelyhood_level'] == null
            ? ""
            : json['examlikelyhood_level'],
        toughness_type:
            json['toughness_level'] == null ? "" : json['toughness_level'],
        is_save: json['is_save'] == null ? "" : json['is_save'],
        is_bookmark: json['is_bookmark'] == null ? "" : json['is_bookmark']);
  }
}
