import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inspection_flutter_app/Layout/DrawerApp.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../DataBase/DbHelper.dart';
import '../Resources/ColorsValue.dart';
import '../Utils/utils.dart';

class Home extends StatefulWidget {
  final isLogin;
  Home({this.isLogin});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Utils utils = Utils();
  SharedPreferences? prefs;
  var dbHelper = DbHelper();
  var dbClient;
  int flag = 0;
  String area_type="",name="",designation="",level="",level_head="",level_value="",profile_image="";
  String satisfied_count="",un_satisfied_count="",need_improvement_count="",total_rdpr="",fin_year="";
  String satisfied_count_other="",un_satisfied_count_other="",need_improvement_count_other="",total_other="";
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {

    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;

    if (prefs?.getString(s.area_type) != null && prefs?.getString(s.area_type) != "" ) {
      area_type=prefs!.getString(s.area_type)!;
    } else {
      area_type="";
    }
    if (prefs?.getString(s.name) != null && prefs?.getString(s.name) != "" ) {
      name=prefs!.getString(s.name)!;
    } else {
      name="";
    }
    if (prefs?.getString(s.desig_name) != null && prefs?.getString(s.desig_name) != "" ) {
      designation=prefs!.getString(s.desig_name)!;
    } else {
      designation="";
    }
    if (prefs?.getString(s.level) != null && prefs?.getString(s.level) != "" ) {
      level=prefs!.getString(s.level)!;
    } else {
      level="";
    }
    if (prefs?.getString(s.profile_image) != null && prefs?.getString(s.profile_image) != "" ) {
      profile_image=prefs!.getString(s.profile_image)!;
    } else {
      profile_image="";
    }

    if(level=="S"){
      level_head="State : ";
      if (prefs?.getString(s.stateName) != null && prefs?.getString(s.stateName) != "" ) {
        level_value=prefs!.getString(s.stateName)!;
      } else {
        level_value="";
      }
    }else if(level=="D"){
      level_head="District : ";
      if (prefs?.getString(s.dname) != null && prefs?.getString(s.dname) != "" ) {
        level_value=prefs!.getString(s.dname)!;
      } else {
        level_value="";
      }

    }else if(level=="B"){
      level_head="Block : ";
      if (prefs?.getString(s.bname) != null && prefs?.getString(s.bname) != "" ) {
        level_value=prefs!.getString(s.bname)!;
      } else {
        level_value="";
      }

    }
    if (area_type == "R") {
      flag = 1;
    } else if (area_type == "U") {
      flag = 2;
    } else {
      flag = 1;
      prefs?.setString(s.area_type, "R");
    }
    if (widget.isLogin == "Login") {
      if (await utils.isOnline()) {
        callApis();
      } else {
        utils.showAlert(context, s.no_internet);
      }
    } else {}
    if(!await utils.isOnline()){
       satisfied_count = prefs!.getString(s.satisfied)!;
       un_satisfied_count = prefs!.getString(s.un_satisfied)!;
       need_improvement_count = prefs!.getString(s.need_improvement)!;
       satisfied_count_other = prefs!.getString(s.satisfied_count_other)!;
       un_satisfied_count_other = prefs!.getString(s.un_satisfied_count_other)!;
       need_improvement_count_other = prefs!.getString(s.need_improvement_count_other)!;
       total_rdpr = prefs!.getString(s.total_rdpr)!;
       total_other = prefs!.getString(s.total_other)!;
       fin_year = prefs!.getString(s.financial_year)!;
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorPrimary,
        centerTitle: true,
        elevation: 2,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
             /* InkWell(
                child: Image.asset(
                  imagePath.menu_icon,
                  fit: BoxFit.contain,
                  color: white,
                  height: 25,
                  width: 25,
                ),
                onTap: backPress(),
              ),*/
              Expanded(
          child:Container(
            transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
          alignment: Alignment.center,
                child: Text(
                  s.appName,
                  style: TextStyle(fontSize: 15),
                ),
                ),
              ),
          Container(
            alignment: Alignment.centerRight,
            child:InkWell(
                child: Image.asset(
                  imagePath.log_out,
                  fit: BoxFit.contain,
                  height: 25,
                  width: 25,
                ),
                onTap: backPress(),
              ),)
            ],
          ),
        ),
      ),
      drawer: DrawerApp(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
                child: Column(
              children: [
                Container(
                  height: 100,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      Image.asset(
                        imagePath.bg_curve,
                        fit: BoxFit.fill,
                        color: colorAccentveryverylight,
                        height: 120,
                        width: MediaQuery.of(context).size.width,
                      ),
                      Column(children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: grey_8,
                                fontSize: 15),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            designation,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: grey_8,
                                fontSize: 13),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            level_head+level_value,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: grey_8,
                                fontSize: 13),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ]),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 15, 0),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Align(
                            alignment: AlignmentDirectional.topEnd,
                            child:ClipOval(
                                  child:profile_image != null && profile_image != "" ?
                                  InkWell(
                                    onTap: () => showDialog(
                                        builder: (BuildContext context) => AlertDialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding: EdgeInsets.all(2),
                                          title: Container(
                                            decoration: BoxDecoration(),
                                            width: MediaQuery.of(context).size.width,
                                            child: Expanded(
                                              child: Image.memory(
                                                base64.decode(profile_image),
                                                fit: BoxFit.fitWidth,
                                              ),
                                            ),
                                          ),
                                        ),
                                        context: context),
                                    child: Image.memory(
                              base64.decode(profile_image),
                              height: 50,
                            ),):SvgPicture.asset(
                              imagePath.user,
                              height: 50,
                            )
                          ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    // clipBehavior is necessary because, without it, the InkWell's animation
                    // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                    // This comes with a small performance cost, and you should not set [clipBehavior]
                    // unless you need it.
                    clipBehavior: Clip.hardEdge,
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                                  child: Text(
                                    s.financial_year,
                                    style: TextStyle(
                                        color: grey_10,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                                  child: Text(fin_year!,
                                      style: TextStyle(
                                          color: primary_text_color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                    child: Text(
                                      s.inspection_status,
                                      style: TextStyle(
                                          color: grey_10,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                  ),
                                  flex: 2,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                    child: Text("RDPR",
                                        style: TextStyle(
                                            color: grey_10,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                    child: Text("OTHER",
                                        style: TextStyle(
                                            color: grey_10,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                  ),
                                  flex: 1,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                    child: Text(
                                      s.total_inspection_done_by_you,
                                      style: TextStyle(
                                          color: grey_10,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12),
                                    ),
                                  ),
                                  flex: 2,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                    child: Text(total_rdpr!,
                                        style: TextStyle(
                                            color: primary_text_color,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12)),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                    child: Text(total_other!,
                                        style: TextStyle(
                                            color: primary_text_color,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12)),
                                  ),
                                  flex: 1,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(children: [
                                    Container(
                                      height: 12,
                                      width: 12,
                                      color: account_status_green_color,
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.fromLTRB(0, 10, 4, 0),
                                      child: Text(""),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          EdgeInsets.fromLTRB(0, 10, 10, 0),
                                      child: Text(
                                        s.satisfied,
                                        style: TextStyle(
                                            color: grey_10,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ]),
                                  flex: 2,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                    child: Text(satisfied_count,
                                        style: TextStyle(
                                            color: grey_10,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12)),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                    child: Text(satisfied_count_other,
                                        style: TextStyle(
                                            color: grey_10,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12)),
                                  ),
                                  flex: 1,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(children: [
                                    Container(
                                      height: 12,
                                      width: 12,
                                      color: unsatisfied2,
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.fromLTRB(0, 10, 4, 0),
                                      child: Text(""),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          EdgeInsets.fromLTRB(0, 10, 10, 0),
                                      child: Text(
                                        s.un_satisfied,
                                        style: TextStyle(
                                            color: grey_10,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ]),
                                  flex: 2,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                    child: Text(un_satisfied_count,
                                        style: TextStyle(
                                            color: grey_10,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12)),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                    child: Text(un_satisfied_count_other,
                                        style: TextStyle(
                                            color: grey_10,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12)),
                                  ),
                                  flex: 1,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(children: [
                                    Container(
                                      height: 12,
                                      width: 12,
                                      color: need_improvement,
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.fromLTRB(0, 10, 4, 0),
                                      child: Text(""),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          EdgeInsets.fromLTRB(0, 10, 10, 0),
                                      child: Text(
                                        s.need_improvement,
                                        style: TextStyle(
                                            color: grey_10,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ]),
                                  flex: 2,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                    child: Text(need_improvement_count,
                                        style: TextStyle(
                                            color: grey_10,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12)),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                    child: Text(need_improvement_count_other,
                                        style: TextStyle(
                                            color: grey_10,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12)),
                                  ),
                                  flex: 1,
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          flag = 1;
                                          prefs?.setString(s.area_type, "R");
                                        });
                                      },
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Align(
                                              alignment: Alignment
                                                  .centerLeft, // Align however you like (i.e .centerRight, centerLeft)
                                              child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 5, 0),
                                                alignment:
                                                    AlignmentDirectional.center,
                                                child: Image.asset(
                                                  imagePath.rural,
                                                  height: 35,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              alignment: AlignmentDirectional
                                                  .centerStart,
                                              decoration: new BoxDecoration(
                                                  color: flag == 1
                                                      ? primary_text_color2
                                                      : white,
                                                  border: Border.all(
                                                      color:
                                                          primary_text_color2,
                                                      width: 2),
                                                  borderRadius:
                                                      new BorderRadius.only(
                                                    topLeft:
                                                        const Radius.circular(
                                                            10),
                                                    topRight:
                                                        const Radius.circular(
                                                            10),
                                                    bottomLeft:
                                                        const Radius.circular(
                                                            10),
                                                    bottomRight:
                                                        const Radius.circular(
                                                            10),
                                                  )),
                                              padding: EdgeInsets.fromLTRB(
                                                  10, 5, 10, 5),
                                              child: Text(
                                                s.rural_area,
                                                style: TextStyle(
                                                    color: flag == 1
                                                        ? white
                                                        : primary_text_color2,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          flag = 2;
                                          prefs?.setString(s.area_type, "U");
                                        });
                                      },
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Align(
                                              alignment: Alignment
                                                  .centerLeft, // Align however you like (i.e .centerRight, centerLeft)
                                              child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 0, 5, 0),
                                                alignment:
                                                    AlignmentDirectional.center,
                                                child: Image.asset(
                                                  imagePath.urban,
                                                  height: 35,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              alignment: AlignmentDirectional
                                                  .centerStart,
                                              decoration: new BoxDecoration(
                                                  color: flag == 2
                                                      ? primary_text_color2
                                                      : white,
                                                  border: Border.all(
                                                      color:
                                                          primary_text_color2,
                                                      width: 2),
                                                  borderRadius:
                                                      new BorderRadius.only(
                                                    topLeft:
                                                        const Radius.circular(
                                                            10),
                                                    topRight:
                                                        const Radius.circular(
                                                            10),
                                                    bottomLeft:
                                                        const Radius.circular(
                                                            10),
                                                    bottomRight:
                                                        const Radius.circular(
                                                            10),
                                                  )),
                                              padding: EdgeInsets.fromLTRB(
                                                  10, 5, 10, 5),
                                              child: Text(
                                                s.urban_area,
                                                style: TextStyle(
                                                    color: flag == 2
                                                        ? white
                                                        : primary_text_color2,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.all(10),
                            height: 120,
                            child: Stack(
                              children: [
                                Positioned(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    height: 80,
                                    width: MediaQuery.of(context).size.width,
                                    alignment: AlignmentDirectional.topCenter,
                                    decoration: new BoxDecoration(
                                        color: colorAccent,
                                        border: Border.all(
                                            color: colorAccent, width: 2),
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(10),
                                          topRight: const Radius.circular(10),
                                          bottomLeft: const Radius.circular(10),
                                          bottomRight:
                                              const Radius.circular(10),
                                        )),
                                    child: Text(
                                      s.rdpr_works,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: white),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional.bottomCenter,
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    // clipBehavior is necessary because, without it, the InkWell's animation
                                    // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                                    // This comes with a small performance cost, and you should not set [clipBehavior]
                                    // unless you need it.
                                    clipBehavior: Clip.hardEdge,
                                    child: Container(
                                      height: 70,
                                      width: 80,
                                      alignment: Alignment.bottomCenter,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              prefs?.setString(
                                                  s.onOffType, "online");
                                            },
                                            child: Text(
                                              s.go_online,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: darkblue),
                                            ),
                                          ),
                                          Divider(color: grey_6),
                                          InkWell(
                                            onTap: () {
                                              prefs?.setString(
                                                  s.onOffType, "offline");
                                            },
                                            child: Text(
                                              s.go_offline,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: darkblue),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.all(10),
                            height: 120,
                            child: Stack(
                              children: [
                                Positioned(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    height: 80,
                                    width: MediaQuery.of(context).size.width,
                                    alignment: AlignmentDirectional.topCenter,
                                    decoration: new BoxDecoration(
                                        color: colorAccent,
                                        border: Border.all(
                                            color: colorAccent, width: 2),
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(10),
                                          topRight: const Radius.circular(10),
                                          bottomLeft: const Radius.circular(10),
                                          bottomRight:
                                              const Radius.circular(10),
                                        )),
                                    child: InkWell(
                                      onTap: () {
                                        prefs?.setString(s.onOffType, "online");
                                      },
                                      child: Text(
                                        s.other_works,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: white),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional.bottomCenter,
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    // clipBehavior is necessary because, without it, the InkWell's animation
                                    // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                                    // This comes with a small performance cost, and you should not set [clipBehavior]
                                    // unless you need it.
                                    clipBehavior: Clip.hardEdge,
                                    child: Container(
                                      height: 70,
                                      width: 80,
                                      alignment: Alignment.bottomCenter,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            s.go_online,
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: darkblue),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )),
                Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            alignment: Alignment.topCenter,
                            height: 120,
                            width: MediaQuery.of(context).size.width,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: AlignmentDirectional.topCenter,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    height: 80,
                                    width: 200,
                                    alignment: AlignmentDirectional.topCenter,
                                    decoration: new BoxDecoration(
                                        color: colorAccent,
                                        border: Border.all(
                                            color: colorAccent, width: 2),
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(10),
                                          topRight: const Radius.circular(10),
                                          bottomLeft: const Radius.circular(10),
                                          bottomRight:
                                              const Radius.circular(10),
                                        )),
                                    child: Text(
                                      s.action_taken_report,
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: white),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional.bottomCenter,
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    // clipBehavior is necessary because, without it, the InkWell's animation
                                    // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                                    // This comes with a small performance cost, and you should not set [clipBehavior]
                                    // unless you need it.
                                    clipBehavior: Clip.hardEdge,
                                    child: Container(
                                      height: 75,
                                      width: 100,
                                      alignment: Alignment.bottomCenter,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              prefs?.setString(
                                                  s.onOffType, "online");
                                            },
                                            child: Text(
                                              s.go_online,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: darkblue),
                                            ),
                                          ),
                                          Divider(color: grey_6),
                                          InkWell(
                                            onTap: () {
                                              prefs?.setString(
                                                  s.onOffType, "offline");
                                            },
                                            child: Text(
                                              s.go_offline,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: darkblue),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
              ],
            )),
          ),
          InkWell(
            onTap: () {
              openPendingScreen();
            },
            child: Container(
                padding: EdgeInsets.all(15),
                alignment: AlignmentDirectional.bottomCenter,
                decoration: new BoxDecoration(
                    color: colorAccent,
                    border: Border.all(color: colorAccent, width: 2),
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(30),
                      topRight: const Radius.circular(30),
                      bottomLeft: const Radius.circular(0),
                      bottomRight: const Radius.circular(0),
                    )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.sync_data_to_server,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: white),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Image.asset(
                      imagePath.upload_img,
                      fit: BoxFit.contain,
                      color: white,
                      height: 18,
                      width: 18,
                    ),
                  ],
                )),
          )
        ],
      ),
    );
  }

  backPress() {}

  void openPendingScreen() {}

  void callApis() {}
}
