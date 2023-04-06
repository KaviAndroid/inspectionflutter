import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/OtherWorkOnline.dart';
import 'package:inspection_flutter_app/Activity/RDPR_Offline.dart';
import 'package:inspection_flutter_app/Activity/RDPR_Online.dart';
import 'package:inspection_flutter_app/Layout/DrawerApp.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../DataBase/DbHelper.dart';
import '../Utils/utils.dart';

class Home extends StatefulWidget {
  final isLogin;
  Home({this.isLogin});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  int flag = 0;
  String area_type="",name="",designation="",level="",level_head="",level_value="",profile_image="";
  String satisfied_count="",un_satisfied_count="",need_improvement_count="",total_rdpr="",fin_year="";
  String satisfied_count_other="",un_satisfied_count_other="",need_improvement_count_other="",total_other="";
  bool atrFlag=false;
  bool syncFlag=false;
  String isLogin='';

  @override
  void initState() {
    super.initState();
    isLogin=widget.isLogin;
    initialize();
  }

  Future<void> initialize() async {

    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;

    if (prefs.getString(s.area_type) != null && prefs.getString(s.area_type) != "" ) {
      area_type=prefs.getString(s.area_type)!;
    } else {
      area_type="";
    }
    if (prefs.getString(s.key_name) != null && prefs.getString(s.key_name) != "" ) {
      name=prefs.getString(s.key_name)!;
    } else {
      name="";
    }
    if (prefs.getString(s.key_desig_name) != null && prefs.getString(s.key_desig_name) != "" ) {
      designation=prefs.getString(s.key_desig_name)!;
    } else {
      designation="";
    }
    if (prefs.getString(s.key_level) != null && prefs.getString(s.key_level) != "" ) {
      level=prefs.getString(s.key_level)!;
    } else {
      level="";
    }
    if (prefs.getString(s.key_profile_image) != null && prefs.getString(s.key_profile_image) != "" ) {
      profile_image=prefs.getString(s.key_profile_image)!;
    } else {
      profile_image="";
    }

    if(level=="S"){
      atrFlag=false;
      level_head="State : ";
      if (prefs.getString(s.key_stateName) != null && prefs.getString(s.key_stateName) != "" ) {
        level_value=prefs.getString(s.key_stateName)!;
      } else {
        level_value="";
      }
    }else if(level=="D"){
      atrFlag=false;
      level_head="District : ";
      if (prefs.getString(s.key_dname) != null && prefs.getString(s.key_dname) != "" ) {
        level_value=prefs.getString(s.key_dname)!;
      } else {
        level_value="";
      }

    }else if(level=="B"){

      if (prefs.getString(s.key_role_code) != null && prefs.getString(s.key_role_code) != ""
          && prefs.getString(s.key_role_code) == "9052" || prefs.getString(s.key_role_code) == "9042" ) {
        atrFlag=true;
      } else {
        atrFlag=false;
      }
      level_head="Block : ";
      if (prefs.getString(s.key_bname) != null && prefs.getString(s.key_bname) != "" ) {
        level_value=prefs.getString(s.key_bname)!;
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
      prefs.setString(s.area_type, "R");
    }
    if (await utils.isOnline()) {
      getDashboardData();
    } else {
      utils.showAlert(context, s.no_internet);
    }
    if (isLogin == "Login") {
      if (await utils.isOnline()) {
        callApis();
      } else {
        utils.showAlert(context, s.no_internet);
      }
    } else {}

       satisfied_count = prefs.getString(s.satisfied_count)!;
       un_satisfied_count = prefs.getString(s.un_satisfied_count)!;
       need_improvement_count = prefs.getString(s.need_improvement_count)!;
       satisfied_count_other = prefs.getString(s.satisfied_count_other)!;
       un_satisfied_count_other = prefs.getString(s.un_satisfied_count_other)!;
       need_improvement_count_other = prefs.getString(s.need_improvement_count_other)!;
       total_rdpr = prefs.getString(s.total_rdpr)!;
       total_other = prefs.getString(s.total_other)!;
       fin_year = prefs.getString(s.financial_year)!;

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
        backgroundColor: c.colorPrimary,
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
                  color: c.white,
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
                onTap: logout(),
              ),)
            ],
          ),
        ),
      ),
      drawer: DrawerApp(),
      body: Container(
        color: c.white,
        child:Column(
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
                        color: c.colorAccentveryverylight,
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
                                color: c.grey_8,
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
                                color: c.grey_8,
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
                                color: c.grey_8,
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
                                        color: c.grey_10,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                                  child: Text(fin_year,
                                      style: TextStyle(
                                          color: c.primary_text_color,
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
                                          color: c.grey_10,
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
                                            color: c.grey_10,
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
                                            color: c.grey_10,
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
                                          color: c.grey_10,
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
                                    child: Text(total_rdpr,
                                        style: TextStyle(
                                            color: c.primary_text_color,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12)),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                                    child: Text(total_other,
                                        style: TextStyle(
                                            color: c.primary_text_color,
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
                                      color: c.account_status_green_color,
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
                                            color: c.grey_10,
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
                                            color: c.grey_10,
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
                                            color: c.grey_10,
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
                                      color: c.unsatisfied2,
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
                                            color: c.grey_10,
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
                                            color: c.grey_10,
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
                                            color: c.grey_10,
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
                                      color: c.need_improvement,
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
                                            color: c.grey_10,
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
                                            color: c.grey_10,
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
                                            color: c.grey_10,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12)),
                                  ),
                                  flex: 1,
                                ),
                              ],
                            ),
                            Visibility(
                              visible: true,
                              child: Container(
                              margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          flag = 1;
                                          prefs.setString(s.area_type, "R");
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
                                                      ? c.primary_text_color2
                                                      : c.white,
                                                  border: Border.all(
                                                      color:
                                                          c.primary_text_color2,
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
                                                        ? c.white
                                                        : c.primary_text_color2,
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
                                          prefs.setString(s.area_type, "U");
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
                                                      ? c.primary_text_color2
                                                      : c.white,
                                                  border: Border.all(
                                                      color:
                                                      c.primary_text_color2,
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
                                                        ? c.white
                                                        : c.primary_text_color2,
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
                                        color: c.colorAccent,
                                        border: Border.all(
                                            color: c.colorAccent, width: 2),
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
                                          color: c.white),
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
                                              prefs.setString(s.onOffType, "online");
                                              prefs.setString(s.workType, "rdpr");
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) => RDPR_Online(),
                                              ))
                                                  .then((value) {
                                                    isLogin="RDPR";
                                                    initialize();
                                                // you can do what you need here
                                                // setState etc.
                                              });
                                             /* Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => RDPR_Online()));*/

                                            },
                                            child: Text(
                                              s.go_online,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: c.darkblue),
                                            ),
                                          ),
                                          Divider(color: c.grey_6),
                                          InkWell(
                                            onTap: () {
                                              prefs.setString(
                                                  s.onOffType, "offline");
                                              prefs.setString(s.workType, "rdpr");
                                              Navigator.pushReplacement(context,MaterialPageRoute(builder:(context) =>  RDPR_Offline()));
                                            },
                                            child: Text(
                                              s.go_offline,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: c.darkblue),
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
                                        color: c.colorAccent,
                                        border: Border.all(
                                            color: c.colorAccent, width: 2),
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(10),
                                          topRight: const Radius.circular(10),
                                          bottomLeft: const Radius.circular(10),
                                          bottomRight:
                                              const Radius.circular(10),
                                        )),
                                    child: InkWell(
                                      onTap: () {
                                        prefs.setString(s.onOffType, "online");
                                        prefs.setString(s.workType, "other");
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) => OtherWorkOnline(),
                                        ))
                                            .then((value) {
                                          isLogin="OTHER";
                                          initialize();
                                          // you can do what you need here
                                          // setState etc.
                                        });
                                        /* Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => RDPR_Online()));*/

                                      },
                                      child: Text(
                                        s.other_works,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: c.white),
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
                                                color: c.darkblue),
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
                Visibility(
                  visible:atrFlag ,
                  child: Container(
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
                                        color: c.colorAccent,
                                        border: Border.all(
                                            color: c.colorAccent, width: 2),
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
                                          color: c.white),
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
                                              prefs.setString(
                                                  s.onOffType, "online");
                                            },
                                            child: Text(
                                              s.go_online,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: c.darkblue),
                                            ),
                                          ),
                                          Divider(color: c.grey_6),
                                          InkWell(
                                            onTap: () {
                                              prefs.setString(
                                                  s.onOffType, "offline");
                                            },
                                            child: Text(
                                              s.go_offline,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: c.darkblue),
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
                    )),),
              ],
            )),
          ),
          Visibility(
            visible: syncFlag,
            child: InkWell(
            onTap: () {
              openPendingScreen();
            },
            child: Container(
                padding: EdgeInsets.all(15),
                alignment: AlignmentDirectional.bottomCenter,
                decoration: new BoxDecoration(
                    color: c.colorAccent,
                    border: Border.all(color: c.colorAccent, width: 2),
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
                          color: c.white),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Image.asset(
                      imagePath.upload_img,
                      fit: BoxFit.contain,
                      color: c.white,
                      height: 18,
                      width: 18,
                    ),
                  ],
                )),
          ),)
        ],
      ),),
    );
  }

  logout() {}

  void openPendingScreen() {}

  Future<void> callApis() async {
    getProfileData();
    getPhotoCount();
    getFinYearList();
    getInspection_statusList();
    getCategoryList();
    if(prefs.getString(s.key_level) != "S"){
      getTownList();
      getMunicipalityList();
      getCorporationList();
    }
    List<Map> list = await dbClient.rawQuery('SELECT * FROM '+s.table_WorkStages);
    print("table_WorkStages >>" + list.toString());
    print("table_WorkStages_size >>" + list.length.toString());
    if(list.length == 0){
      getAll_Stage();
    }
  }

  Future<void> getDashboardData() async {
    late Map json_request;
    json_request = {
      s.key_service_id: s.service_key_current_finyear_wise_status_count
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
      utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context:await utils.globalContext);
    _client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service, body: json.encode(encrpted_request));
    print("DashboardData_url>>" + url.main_service.toString());
    print("DashboardData_request_json>>" + json_request.toString());
    print("DashboardData_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("DashboardData_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        if (res_jsonArray.length > 0) {

          for (int i = 0; i < res_jsonArray.length; i++) {
            String satisfied_count = res_jsonArray[i][s.key_satisfied].toString();
            String un_satisfied_count = res_jsonArray[i][s.key_unsatisfied].toString();
            String need_improvement_count = res_jsonArray[i][s.key_need_improvement].toString();
            String fin_year = res_jsonArray[i][s.key_fin_year];
            String inspection_type = res_jsonArray[i][s.key_inspection_type];
            if(satisfied_count==("")){
              satisfied_count="0";
            } if(un_satisfied_count==("")){
              un_satisfied_count="0";
            } if(need_improvement_count==("")){
              need_improvement_count="0";
            }
            int total_inspection_count = int.parse(satisfied_count)+int.parse(un_satisfied_count)+int.parse(need_improvement_count);

            if(inspection_type == ("rdpr")){
              prefs.setString(s.satisfied_count, satisfied_count);
              prefs.setString(s.un_satisfied_count, un_satisfied_count);
              prefs.setString(s.need_improvement_count, need_improvement_count);
              prefs.setString(s.total_rdpr, total_inspection_count.toString());
              prefs.setString(s.financial_year, fin_year);

            }else {
              prefs.setString(s.satisfied_count_other, satisfied_count);
              prefs.setString(s.un_satisfied_count_other, un_satisfied_count);
              prefs.setString(s.need_improvement_count_other, need_improvement_count);
              prefs.setString(s.total_other, total_inspection_count.toString());
              prefs.setString(s.financial_year, fin_year);
            }
          }

        }
        setState(() {
        });
      }
    }
  }

  Future<void> getProfileData() async {
    late Map json_request;

    json_request = {
      s.key_service_id: s.service_key_work_inspection_profile_list,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
      utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context:await utils.globalContext);
    _client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service, body: json.encode(encrpted_request));
    print("ProfileData_url>>" + url.main_service.toString());
    print("ProfileData_request_json>>" + json_request.toString());
    print("ProfileData_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("ProfileData_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        if (res_jsonArray.length > 0) {
          for (int i = 0; i < res_jsonArray.length; i++) {
            String name = res_jsonArray[i][s.key_name];
            String mobile = res_jsonArray[i][s.key_mobile];
            String gender = res_jsonArray[i][s.key_gender];
            String level = res_jsonArray[i][s.key_level];
            String desig_code = res_jsonArray[i][s.key_desig_code].toString();
            String desig_name = res_jsonArray[i][s.key_desig_name];
            String dcode = res_jsonArray[i][s.key_dcode].toString();
            String bcode = res_jsonArray[i][s.key_bcode].toString();
            String office_address = res_jsonArray[i][s.key_office_address];
            String email = res_jsonArray[i][s.key_email];
            String profile_image = res_jsonArray[i][s.key_profile_image];
            String role_code = res_jsonArray[i][s.key_role_code].toString();

            if (!(profile_image == ("null") || profile_image == (""))) {
              Uint8List bytes = Base64Codec().decode(profile_image);
              prefs.setString(s.key_profile_image, profile_image);
            } else {
              prefs.setString(s.key_profile_image, "");
            }

            prefs.setString(s.key_desig_name, desig_name);
            prefs.setString(s.key_desig_code, desig_code);
            prefs.setString(s.key_name, name);
            prefs.setString(s.key_role_code, role_code);
            prefs.setString(s.key_level, level);
            prefs.setString(s.key_dcode, dcode);
            prefs.setString(s.key_bcode, bcode);

          }
        }
      }
    }
  }

  Future<void> getPhotoCount() async {
    late Map json_request;

    json_request = {
      s.key_service_id: s.service_key_photo_count,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
      utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context:await utils.globalContext);
    _client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service, body: json.encode(encrpted_request));
    print("photo_count_url>>" + url.main_service.toString());
    print("photo_count_request_json>>" + json_request.toString());
    print("photo_count_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("photo_count_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        prefs.setString(s.service_key_photo_count,userData[s.key_COUNT].toString());
      }
    }
  }

  Future<void> getFinYearList() async {
    late Map json_request;

    json_request = {
      s.key_service_id: s.service_key_fin_year,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
      utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context:await utils.globalContext);
    _client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service, body: json.encode(encrpted_request));
    print("fin_year_url>>" + url.main_service.toString());
    print("fin_year_request_json>>" + json_request.toString());
    print("fin_year_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("fin_year_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        if (res_jsonArray.length > 0) {
          dbHelper.delete_table_FinancialYear();
          for (int i = 0; i < res_jsonArray.length; i++) {
            await dbClient.rawInsert(
                'INSERT INTO '+s.table_FinancialYear+' (fin_year) VALUES(' +"'"+
                    res_jsonArray[i][s.service_key_fin_year] +
                    "')");
          }
          List<Map> list = await dbClient.rawQuery('SELECT * FROM '+s.table_FinancialYear);
          print("table_FinancialYear >>" + list.toString());
        }
      }
    }
  }

  Future<void> getInspection_statusList() async {
    late Map json_request;

    json_request = {
      s.key_service_id: s.service_key_inspection_status,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
      utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context:await utils.globalContext);
    _client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.master_service, body: json.encode(encrpted_request));
    print("inspection_status_url>>" + url.master_service.toString());
    print("inspection_status_request_json>>" + json_request.toString());
    print("inspection_status_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("inspection_status_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        if (res_jsonArray.length > 0) {
          dbHelper.delete_table_Status();
          for (int i = 0; i < res_jsonArray.length; i++) {
            await dbClient.rawInsert(
                'INSERT INTO '+s.table_Status+' (status_id  , status) VALUES(' +
                    res_jsonArray[i][s.key_status_id] +
                    ",'"+
                    res_jsonArray[i][s.key_status_name] +
                    "')");
          }
          List<Map> list = await dbClient.rawQuery('SELECT * FROM '+s.table_Status);
          print("table_Status >>" + list.toString());
        }
      }
    }
  }

  Future<void> getCategoryList() async {
    late Map json_request;

    json_request = {
      s.key_service_id: s.service_key_other_work_category_list,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
      utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context:await utils.globalContext);
    _client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service, body: json.encode(encrpted_request));
    print("other_work_category_list_url>>" + url.main_service.toString());
    print("other_work_category_list_request_json>>" + json_request.toString());
    print("other_work_category_list_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("other_work_category_list_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        if (res_jsonArray.length > 0) {
          dbHelper.delete_table_OtherCategory();
          for (int i = 0; i < res_jsonArray.length; i++) {
            await dbClient.rawInsert(
                'INSERT INTO '+s.table_OtherCategory+' (other_work_category_id  , other_work_category_name) VALUES(' +
                    "'"+
                    res_jsonArray[i][s.key_other_work_category_id].toString() +
                    "' , '"+
                    res_jsonArray[i][s.key_other_work_category_name] +
                    "')");
          }
          List<Map> list = await dbClient.rawQuery('SELECT * FROM '+s.table_OtherCategory);
          print("table_OtherCategory >>" + list.toString());
        }
      }
    }
  }

  Future<void> getTownList() async {
     Map json_request = {
      s.key_service_id: s.service_key_townpanchayat_list_district_wise,
      s.key_dcode: prefs.getString(s.key_dcode),
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
      utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context:await utils.globalContext);
    _client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.master_service, body: json.encode(encrpted_request));
    print("TownList_url>>" + url.master_service.toString());
    print("TownList_request_json>>" + json_request.toString());
    print("TownList_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("TownList_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        if (res_jsonArray.length > 0) {
          dbHelper.delete_table_TownList();
          for (int i = 0; i < res_jsonArray.length; i++) {
            await dbClient.rawInsert(
                'INSERT INTO '+s.table_TownList+' (dcode  , townpanchayat_id , townpanchayat_name) VALUES(' +
                    "'"+
                    res_jsonArray[i][s.key_dcode].toString() +
                    "' , '"+
                    res_jsonArray[i][s.key_townpanchayat_id] +
                    "' , '"+
                    res_jsonArray[i][s.key_townpanchayat_name] +
                    "')");
          }
          List<Map> list = await dbClient.rawQuery('SELECT * FROM '+s.table_TownList);
          print("table_TownList >>" + list.toString());
        }
      }
    }
  }

  Future<void> getMunicipalityList() async {
    Map json_request = {
      s.key_service_id: s.service_key_municipality_list_district_wise,
      s.key_dcode: prefs.getString(s.key_dcode),
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
      utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context:await utils.globalContext);
    _client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.master_service, body: json.encode(encrpted_request));
    print("MunicipalityList_url>>" + url.master_service.toString());
    print("MunicipalityList_request_json>>" + json_request.toString());
    print("MunicipalityList_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("MunicipalityList_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        if (res_jsonArray.length > 0) {
          dbHelper.delete_table_Municipality();
          for (int i = 0; i < res_jsonArray.length; i++) {
            await dbClient.rawInsert(
                'INSERT INTO '+s.table_Municipality+' (dcode  , municipality_id , municipality_name) VALUES(' +
                    "'"+
                    res_jsonArray[i][s.key_dcode].toString() +
                    "' , '"+
                    res_jsonArray[i][s.key_municipality_id] +
                    "' , '"+
                    res_jsonArray[i][s.key_municipality_name] +
                    "')");
          }
          List<Map> list = await dbClient.rawQuery('SELECT * FROM '+s.table_Municipality);
          print("table_Municipality >>" + list.toString());
        }
      }
    }
  }

  Future<void> getCorporationList() async {
     Map json_request = {
      s.key_service_id: s.service_key_corporation_list_district_wise,
      s.key_dcode: prefs.getString(s.key_dcode),
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
      utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context:await utils.globalContext);
    _client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.master_service, body: json.encode(encrpted_request));
    print("CorporationList_url>>" + url.master_service.toString());
    print("CorporationList_request_json>>" + json_request.toString());
    print("CorporationList_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("CorporationList_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        if (res_jsonArray.length > 0) {
          dbHelper.delete_table_Corporation();
          for (int i = 0; i < res_jsonArray.length; i++) {
            await dbClient.rawInsert(
                'INSERT INTO '+s.table_Corporation+' (dcode  , corporation_id , corporation_name) VALUES(' +
                    "'"+
                    res_jsonArray[i][s.key_dcode].toString() +
                    "' , '"+
                    res_jsonArray[i][s.key_corporation_id] +
                    "' , '"+
                    res_jsonArray[i][s.key_corporation_name] +
                    "')");
          }
          List<Map> list = await dbClient.rawQuery('SELECT * FROM '+s.table_Corporation);
          print("table_Corporation >>" + list.toString());
        }
      }
    }
  }

  Future<void> getAll_Stage() async {
    late Map json_request;

    json_request = {
      s.key_service_id: s.service_key_work_type_stage_link,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
      utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context:await utils.globalContext);
    _client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service, body: json.encode(encrpted_request));
    print("WorkStages_url>>" + url.main_service.toString());
    print("WorkStages_request_json>>" + json_request.toString());
    print("WorkStages_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("WorkStages_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        if (res_jsonArray.length > 0) {
          dbHelper.delete_table_WorkStages();
          for (int i = 0; i < res_jsonArray.length; i++) {
            await dbClient.rawInsert(
                'INSERT INTO '+s.table_WorkStages+' (work_group_id , work_type_id , work_stage_order , work_stage_code , work_stage_name) VALUES(' +
                    res_jsonArray[i][s.key_work_group_id].toString() +
                    ','+
                    res_jsonArray[i][s.key_work_type_id].toString() +
                    ','+
                    res_jsonArray[i][s.key_work_stage_order].toString()  +
                    ','+
                    res_jsonArray[i][s.key_work_stage_code] .toString() +
                    ",'"+
                    res_jsonArray[i][s.key_work_stage_name] +
                    "')");

          }
          List<Map> list = await dbClient.rawQuery('SELECT * FROM '+s.table_WorkStages);
          print("table_WorkStages >>" + list.toString());
        }
      }
    }
  }



}
