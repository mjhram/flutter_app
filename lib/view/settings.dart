import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsState();
  }
}

Future<bool> saveData(String theClass) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return (await preferences.setString("Class", theClass));
}

Future<String> loadData() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String tmp = preferences.getString("Class")??"4A";
  return tmp;
}

//var selectedClass = '4A';

class SettingsState extends State<Settings> {
  static var classes = ['4A', '4B', '4C'];
  static var selectedClass = '4A';
  static var selectedClassId=51;
  final double  _minimumPadding = 5.0;


  static void setSelectedClass(String tmp){
    selectedClass = tmp;
    selectedClassId = 51+classes.indexOf(selectedClass);
  }

  @override
  void initState() {
    super.initState();
    loadData().then((tmp){
      setState(() {
        selectedClass = tmp;
        selectedClassId = 51+classes.indexOf(selectedClass);
        debugPrint("classid=$selectedClassId");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return /*Scaffold(
//			resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: */Container(
          alignment: Alignment.topLeft,
          child: ListView(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: _minimumPadding, bottom: _minimumPadding),
                    child: Row(

                      children: <Widget>[

                        Expanded(child: Text(
                          "Class",
                          textDirection: TextDirection.ltr,

                        )),

                        Container(width: _minimumPadding * 5,),

                        Expanded(child: DropdownButton<String>(
                          items: classes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),

                          value: selectedClass,

                          onChanged: (String newValueSelected) {
                            setState(() {
                              selectedClass = newValueSelected;
                              selectedClassId = 51+classes.indexOf(selectedClass);
                              debugPrint("classid=$selectedClassId");
                              saveData(selectedClass);
                            });

                          },

                        ))


                      ],
                    )),
              ]
          ),
        );//,
    //);
  }
}