import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/RdprOnlineWorkListFromFilter.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../DataBase/DbHelper.dart';
import '../Utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Home.dart';
import 'RdprOnlineWorkListFromGeoLocation.dart';
class ViewSavedRDPR extends StatefulWidget {
  @override
  State<ViewSavedRDPR> createState() => _ViewSavedRDPRState();
}
class _ChartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
class _ViewSavedRDPRState extends State<ViewSavedRDPR> {
  TextEditingController dateController = TextEditingController();
  @override
  void initState() {
    super.initState();
    initialize();
  }
  Future<void> initialize() async {
    setState(() {
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: c.colorPrimary,
          centerTitle: true,
          elevation: 2,
          automaticallyImplyLeading: false,
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.only(top: 4,),
                child:  IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Home()));
                  },
                ),),
                Align(
                  alignment: AlignmentDirectional.center,
                  child:Container(
                    transform: Matrix4.translationValues(80, 2,15),
                    alignment: Alignment.center,
                    child: Text(
                      s.work_list,
                      style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Padding(padding: EdgeInsets.only(top: 8),
            child:   IconButton(
              icon: Icon(Icons.search,color: c.black,size: 25,),
              onPressed: () {
              },
            ),)
    ],
    ),
        body: Container(
              color: c.ca2,
              child: Column(
                  children: <Widget>[
                    Container(
                      child: Padding(padding: EdgeInsets.only(top: 20,left: 15,right: 15,bottom: 25),
                        child: TextField(
                            controller: dateController,
                            decoration: InputDecoration(
                              suffixIconConstraints: BoxConstraints(
                                  minHeight: 30,
                                  minWidth: 20
                              ),
                              contentPadding: EdgeInsets.only(left: 25,right: 5),
                              filled: true,
                              fillColor: c.grey_2,
                                suffixIcon: Padding(
                                  padding:EdgeInsets.all(10),
                                  // child: Image.asset(imagePath.date_picker_icon,height: 30,width: 30,),
                                ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(width: 0.1, color: c.grey_2),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                            ),
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101)
                              );
                              if (pickedDate != null) {
                                print(pickedDate);
                                setState(() {
                                });
                              } else {
                                print("Date is not selected");
                              }
                            }
                        ),),
                    ),
                    Text("(OR)"),
                    Container(
                      child: Padding(padding: EdgeInsets.all(15),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Enter Work id",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            filled: true,
                            fillColor: c.grey_2,
                            suffixIcon: Material(
                              elevation: 5.0,
                              // color: c.dot_dark_screen5,
                              // shadowColor: c.dot_dark_screen5,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              child: Icon(Icons.arrow_forward_ios, color: c.white,size: 22,),
                             ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 0.1, color: c.grey_2),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10))
                            ),
                          ),
                        ),),
                    ),
                  ]
              ),
          ),
    );
  }
}




