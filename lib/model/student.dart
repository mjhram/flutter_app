class Student {
  String studentId;
  int classId;
  String date;

  //Student(this.studentId, this.classId, this.date);
  Student() {
    studentId = "180360";
    classId = 51;
    date = "2018-12-18";
  }
  /*User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'];
  */
  Map<String, dynamic> toJson() =>
      {
        'student_id': studentId,
        'class_id': classId,
        'date': date,
      };
}