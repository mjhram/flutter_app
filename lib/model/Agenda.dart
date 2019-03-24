class Agenda {
    String className;
    String courseName;
    String note;
    String homeNote;
    String date;

    Agenda._({this.className, this.courseName, this.note, this.homeNote, this.date});
    Agenda();

    factory Agenda.fromJson(Map<String, dynamic> json) {
      return new Agenda._(
        className: json['class_name'],
        courseName: json['course_name'],
        note: json['note'],
        homeNote: json['home_note'],
        date: json['date'],
      );
    }
}
