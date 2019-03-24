import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app/model/Agenda.dart';
import 'package:flutter_app/model/student.dart';
import 'package:flutter_app/view/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgendaWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AgendaState();
  }
}
/*
List<String> getListElements() {
  var items = List<String>.generate(5, (counter)=> "item $counter");
  return items;
}*/

Widget _buildProgressIndicator(bool isLoading) {
  return new Padding(
    padding: const EdgeInsets.all(8.0),
    child: new Center(
      child: new Opacity(
        opacity: isLoading ? 1.0 : 0.0,
        child: new CircularProgressIndicator(),
      ),
    ),
  );
}

List<Widget> getLessonText(Agenda a) {
  List<Widget> textList = new List<Widget>();
  Widget w;
  if (a.courseName != null) {
    w = Text(a.courseName,
        textDirection: TextDirection.rtl,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.deepPurple));
    textList.add(w);
  }
  if (a.note != null) {
    w = Text(a.note,
        textDirection: TextDirection.rtl,
        style: TextStyle(fontSize: 22, color: Colors.black));
    textList.add(w);
  }
  if (a.homeNote != null) {
    w = Text(a.homeNote,
        textDirection: TextDirection.rtl,
        style: TextStyle(fontSize: 16, color: Colors.deepPurple));
    textList.add(w);
  }
  if (a.date != null) {
    w = Align(
        alignment: FractionalOffset.centerLeft,
        child: Text(a.date,
            textDirection: TextDirection.ltr,
            style: TextStyle(color: Colors.deepPurple)));
    textList.add(w);
  }
  return textList;
}

Widget getListView(
    List<Agenda> theList, ScrollController acontroller, bool isLoading) {
  //var items = getListElements();
  var listView = ListView.builder(
    controller: acontroller,
    itemBuilder: (context, index) {
      if (index == theList.length) {
        return _buildProgressIndicator(isLoading);
      } else {
        return Card(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: getLessonText(theList.elementAt(index))),
        );
      }
    },
    itemCount: theList.length + 1,
  );
  return listView;
}

class _AgendaState extends State<AgendaWidget> with AutomaticKeepAliveClientMixin{
  @override bool get wantKeepAlive => true;
  DateTime currentDate;
  //var isLoading = false;
  List<Agenda> list = List();
  ScrollController _controller = ScrollController();
  bool isPerformingRequest = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _fetchData() async {
    if (isPerformingRequest) return;
    setState(() {
      isPerformingRequest = true;
    });

    var st = new Student();
    st.classId = SettingsState.selectedClassId;
    st.date = getDateString(currentDate);

    final abody = json.encode(st);
    final aheader = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Host": "www.sptechtest.com",
      "User-Agent":
          "Dalvik/2.1.0 (Linux; U; Android 8.0.0; SM-G950F Build/R16NW)",
      "Connection": "Keep-Alive"
    };
    final response = await http.post(
      "http://www.sptechtest.com/BackEndHamasat/mobile/agenda_report.php",
      headers: aheader,
      body: abody,
    );
    isPerformingRequest = false;
    if (response.statusCode == 200) {
      List aList = (json.decode(response.body) as List)
          .map((data) => new Agenda.fromJson(data))
          .toList();
      updateList(aList);
    } else {
      throw Exception('Failed to load agenda');
    }
  }

  void updateList(List<Agenda> alist) {
    if (alist.length == 0) {
      Agenda a = new Agenda();
      a.date = getDateString(currentDate);
      alist.add(a);
    }
    setState(() {
      list.addAll(alist);
    });
    //_controller.animateTo(_controller.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return /*Scaffold(
//			resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Agenda'),
      ),
      body: */Container(
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: dateButtonPressed,
                      iconSize: 48.0,
                      color: const Color(0xFF000000),
                    ),
                    new Text(
                      getDateString(currentDate),
                      style: new TextStyle(
                          fontSize: 22.0,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w200,
                          fontFamily: "Roboto"),
                    )
                  ]),
              new Expanded(
                  child: getListView(list, _controller, isPerformingRequest)),
              Align(
                child: IconButton(
                  icon: const Icon(Icons.arrow_drop_down),
                  onPressed: scrollButtonPressed,
                  iconSize: 48.0,
                  color: const Color(0xFF000000),
                ),
              )
            ]),
        padding: const EdgeInsets.all(0.0),
        alignment: Alignment.center,
      );//,
    //);
  }

  static bool firstTime = true;

  @override
  void initState() {
    super.initState();
    if (firstTime) {
      setDateToNow();
      firstTime = false;
      _fetchData();
    }
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        currentDate = currentDate.subtract(Duration(days: 1));
        _fetchData();
      }
    });
  }

  static String getDateString(DateTime theDate) {
    String tmp = intl.DateFormat('yyyy-MM-dd').format(theDate);
    return tmp;
  }

  void setDateToNow() {
    currentDate = DateTime.now();
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
    });
  }

  Future<Null> _selectDate() async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    //String newDate = intl.DateFormat('yyyy-M-dd').format(picked);
    if (picked != null && picked != currentDate) {
      setState(() {
        list.clear();
        currentDate = picked;
      });
      _fetchData();
    }
  }

  void dateButtonPressed() {
    _selectDate();
  }

  void scrollButtonPressed() {
    currentDate = currentDate.subtract(Duration(days: 1));
    _fetchData();
  }
}
