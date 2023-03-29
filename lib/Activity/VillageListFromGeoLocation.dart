import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../DataBase/DbHelper.dart';
import '../Utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class VillageListFromGeoLocation extends StatefulWidget {
  final villageList;
  VillageListFromGeoLocation({this.villageList});
  @override
  State<VillageListFromGeoLocation> createState() => _VillageListFromGeoLocationState();
}

class _VillageListFromGeoLocationState extends State<VillageListFromGeoLocation> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;

  @override
  void initState(){
    initialize();
  }
  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context, rootNavigator: true).pop(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child:Scaffold(
          appBar: AppBar(
            backgroundColor: c.colorPrimary,
            centerTitle: true,
            elevation: 2,
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.center,
                    child:Container(
                      transform: Matrix4.translationValues(-30.0, 0.0, 0.0),
                      alignment: Alignment.center,
                      child: Text(
                        s.village_list,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Stack(
              children: [
            ListView.builder(
    itemCount: widget.villageList == null ? 0 : widget.villageList.length,
    itemBuilder: (BuildContext context, int index){
    return new Card(
    child: Row(children: [
      Container(width: 10,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    c.colorPrimary,
                    c.colorAccentverylight,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight
              )
          )      ),
      Text(
        widget.villageList[index][s.pvname],
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: c.grey_10),
      ),
    ],),
    );
    },
    ),
                Align(
                  alignment: AlignmentDirectional.center,
                  child:Container(
                    alignment: Alignment.center,
                    child: Text(
                      s.village_list,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                )
              ]),));

  }
}
