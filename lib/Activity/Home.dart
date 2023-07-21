// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, prefer_interpolation_to_compose_strings, use_build_context_synchronously, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:InspectionAppNew/Activity/OtherWorkUrban.dart';
import 'package:InspectionAppNew/Activity/OtherWorkRural.dart';
import 'package:InspectionAppNew/Activity/Pending_Screen.dart';
import 'package:InspectionAppNew/Activity/RDPRUrbanWorks.dart';
import 'package:InspectionAppNew/Activity/RDPR_Offline.dart';
import 'package:InspectionAppNew/Activity/RDPR_Online.dart';
import 'package:InspectionAppNew/Activity/Splash.dart';
import 'package:InspectionAppNew/Layout/DrawerApp.dart';
import 'package:InspectionAppNew/Resources/Strings.dart' as s;
import 'package:InspectionAppNew/Resources/ColorsValue.dart' as c;
import 'package:InspectionAppNew/Resources/url.dart' as url;
import 'package:InspectionAppNew/Resources/ImagePath.dart' as imagePath;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../DataBase/DbHelper.dart';
import '../Resources/global.dart';
import '../Utils/utils.dart';
import 'package:InspectionAppNew/Activity/ATR_Offline.dart';
import 'package:InspectionAppNew/Activity/ATR_Online.dart';

import 'Login.dart';

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
  String area_type = "",
      name = "",
      designation = "",
      level = "",
      level_head = "",
      level_value = "",
      profile_image = "";
  String satisfied_count = "",
      un_satisfied_count = "",
      need_improvement_count = "",
      total_rdpr = "",
      fin_year = "";
  String satisfied_count_other = "",
      un_satisfied_count_other = "",
      need_improvement_count_other = "",
      total_other = "";
  bool atrFlag = false;
  bool syncFlag = false;
  String isLogin = '';
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    isLogin = widget.isLogin;
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;

    await checkLocalData();
    if (await utils.isOnline()) {
      await getDashboardData();
    } /*else {
      utils.showAlert(context, s.no_internet);
    }*/
    if (isLogin == "Login") {
      if (await utils.isOnline()) {
        print(">>>>enter");
        try {
          utils.showProgress(context, 1);
          await callApis();
          utils.hideProgress(context);
        } on Exception catch (_) {
          print('never reached');
          utils.hideProgress(context);
        }
      } /*else {
        utils.showAlert(context, s.no_internet);
      }*/
    }

    satisfied_count = prefs.getString(s.satisfied_count)!;
    un_satisfied_count = prefs.getString(s.un_satisfied_count)!;
    need_improvement_count = prefs.getString(s.need_improvement_count)!;
    satisfied_count_other = prefs.getString(s.satisfied_count_other)!;
    un_satisfied_count_other = prefs.getString(s.un_satisfied_count_other)!;
    need_improvement_count_other =
        prefs.getString(s.need_improvement_count_other)!;
    total_rdpr = prefs.getString(s.total_rdpr)!;
    total_other = prefs.getString(s.total_other)!;
    fin_year = prefs.getString(s.financial_year)!;

    if (prefs.getString(s.key_rural_urban) != null &&
        prefs.getString(s.key_rural_urban) != "") {
      area_type = prefs.getString(s.key_rural_urban)!;
    } else {
      area_type = "";
    }
    if (prefs.getString(s.key_name) != null &&
        prefs.getString(s.key_name) != "") {
      name = prefs.getString(s.key_name)!;
    } else {
      name = "";
    }
    if (prefs.getString(s.key_desig_name) != null &&
        prefs.getString(s.key_desig_name) != "") {
      designation = prefs.getString(s.key_desig_name)!;
    } else {
      designation = "";
    }
    if (prefs.getString(s.key_level) != null &&
        prefs.getString(s.key_level) != "") {
      level = prefs.getString(s.key_level)!;
    } else {
      level = "";
    }
    if (prefs.getString(s.key_profile_image) != null &&
        prefs.getString(s.key_profile_image) != "") {
      profile_image = prefs.getString(s.key_profile_image)!;
      // profile_image = prefs.getString("UIMG")!;
    } else {
      profile_image = "";
    }

    if (level == "S") {
      atrFlag = false;
      level_head = "State : ";
      if (prefs.getString(s.key_stateName) != null &&
          prefs.getString(s.key_stateName) != "") {
        level_value = prefs.getString(s.key_stateName)!;
      } else {
        level_value = "";
      }
    } else if (level == "D") {
      atrFlag = false;
      level_head = "District : ";
      if (prefs.getString(s.key_dname) != null &&
          prefs.getString(s.key_dname) != "") {
        level_value = prefs.getString(s.key_dname)!;
      } else {
        level_value = "";
      }
    } else if (level == "B") {
      if (prefs.getString(s.key_role_code) != null &&
              prefs.getString(s.key_role_code) != "" &&
              prefs.getString(s.key_role_code) == "9052" ||
          prefs.getString(s.key_role_code) == "9042") {
        atrFlag = true;
      } else {
        atrFlag = false;
      }
      level_head = "Block : ";
      if (prefs.getString(s.key_bname) != null &&
          prefs.getString(s.key_bname) != "") {
        level_value = prefs.getString(s.key_bname)!;
      } else {
        level_value = "";
      }
    }
    if (area_type == "R") {
      flag = 1;
    } else if (area_type == "U") {
      flag = 2;
    } else {
      flag = 1;
      prefs.setString(s.key_rural_urban, "R");
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    setState(() {});
  }

  _text_widget(
      String title1, String title2, String title3, int index, Color boxColor) {
    return Row(
      children: [
        index < 2
            ? Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
                  child: Text(
                    title1,
                    style: TextStyle(
                        color: c.grey_10,
                        fontWeight:
                            index == 0 ? FontWeight.bold : FontWeight.normal,
                        fontSize: index == 0 ? 13 : 12),
                  ),
                ),
              )
            : Expanded(
                flex: 2,
                child: Row(children: [
                  Container(
                    height: 12,
                    width: 12,
                    color: boxColor,
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text(""),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.fromLTRB(2, 10, 10, 0),
                    child: Text(
                      title1,
                      style: TextStyle(
                          color: c.grey_10,
                          fontWeight: FontWeight.normal,
                          fontSize: 12),
                    ),
                  ),
                ]),
              ),
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
            child: Text(title2,
                style: TextStyle(
                    color: index == 1 ? c.primary_text_color : c.grey_10,
                    fontWeight:
                        index == 0 ? FontWeight.bold : FontWeight.normal,
                    fontSize: index == 0 ? 13 : 12)),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
            child: Text(title3,
                style: TextStyle(
                    color: index == 1 ? c.primary_text_color : c.grey_10,
                    fontWeight:
                        index == 0 ? FontWeight.bold : FontWeight.normal,
                    fontSize: index == 0 ? 13 : 12)),
          ),
        ),
      ],
    );
  }

  _rural_urban_selection_Widget(String title, String img_path, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          flag = index;
          prefs.setString(s.key_rural_urban, title.substring(0, 1));
        });
      },
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(
          child: Image.asset(
            img_path,
            height: 35,
          ),
        ),
        SizedBox(width: 5),
        Container(
          height: 30,
          width: MediaQuery.of(context).size.width / 4,
          decoration: BoxDecoration(
              color: flag == index ? c.primary_text_color2 : c.white,
              border: Border.all(color: c.primary_text_color2, width: 2),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
                bottomLeft: const Radius.circular(10),
                bottomRight: const Radius.circular(10),
              )),
          child: Center(
              child: Text(
            title,
            style: TextStyle(
                color: flag == index ? c.white : c.primary_text_color2,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          )),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> showExitPopup() async {
      if (_scaffoldKey.currentState!.isDrawerOpen) {
        Navigator.of(context).pop();
        return false;
      } else {
        return await showDialog(
              //show confirm dialogue
              //the return value will be from "Yes" or "No" options
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Exit App'),
                content: Text('Do you want to exit an App?'),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    //return false when click on "NO"
                    child: Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Splash()),
                          (route) => false);
                      if (Platform.isIOS) {
                        try {
                          exit(0);
                        } catch (e) {
                          SystemNavigator
                              .pop(); // for IOS, not true this, you can make comment this :)
                        }
                      } else {
                        try {
                          SystemNavigator.pop(); // sometimes it cant exit app
                        } catch (e) {
                          exit(0); // so i am giving crash to app ... sad :(
                        }
                      }
                    },
                    //return true when click on "Yes"
                    child: Text('Yes'),
                  ),
                ],
              ),
            ) ??
            false;
      }
      //if showDialouge had returned null, then return false
    }

    return WillPopScope(
      onWillPop: showExitPopup, //call function on back button press
      child: Scaffold(
        key: _scaffoldKey,
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
                  child: Container(
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
                  child: GestureDetector(
                      child: Image.asset(
                        imagePath.log_out,
                        fit: BoxFit.contain,
                        height: 25,
                        width: 25,
                      ),
                      onTap: () async {
                        logout();
                        // dbHelper.deleteAll();// here you can also use async-await
                      }),
                )
              ],
            ),
          ),
        ),
        drawer: DrawerApp(),
        body: Container(
          color: c.white,
          child: Column(
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
                              margin: EdgeInsets.fromLTRB(10, 10, 60, 0),
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: c.white,
                                    fontSize: 15),
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
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
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                level_head + level_value,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: c.grey_8,
                                    fontSize: 13),
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ]),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 15, 0),
                            child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Align(
                                    alignment: AlignmentDirectional.topEnd,
                                    child: profile_image != null &&
                                            profile_image != ""
                                        ? InkWell(
                                            onTap: () => showDialog(
                                                builder: (BuildContext
                                                        context) =>
                                                    AlertDialog(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      insetPadding:
                                                          EdgeInsets.all(5),
                                                      title: Container(
                                                        decoration:
                                                            BoxDecoration(),
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Image.memory(
                                                          base64.decode(
                                                              profile_image
                                                                  .replaceAll(
                                                                      RegExp(
                                                                          r'\s+'),
                                                                      '')),
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                context: context),
                                            child: CircleAvatar(
                                                backgroundImage: MemoryImage(
                                                  base64.decode(
                                                      profile_image.replaceAll(
                                                          RegExp(r'\s+'), '')),
                                                ),
                                                radius: 30.0))
                                        : CircleAvatar(
                                            backgroundImage: AssetImage(
                                              imagePath.user,
                                            ),
                                            radius: 30.0))),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                        margin: EdgeInsets.all(10),
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                _text_widget(s.inspection_status, "RDPR",
                                    "OTHER", 0, Colors.transparent),
                                _text_widget(
                                    s.total_inspection_done_by_you,
                                    total_rdpr,
                                    total_other,
                                    1,
                                    Colors.transparent),
                                _text_widget(
                                    s.satisfied,
                                    satisfied_count,
                                    satisfied_count_other,
                                    2,
                                    c.account_status_green_color),
                                _text_widget(
                                    s.un_satisfied,
                                    un_satisfied_count,
                                    un_satisfied_count_other,
                                    3,
                                    c.unsatisfied2),
                                _text_widget(
                                    s.need_improvement,
                                    need_improvement_count,
                                    need_improvement_count_other,
                                    4,
                                    c.need_improvement),
                                SizedBox(height: 10),
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _rural_urban_selection_Widget(
                                          s.rural_area, imagePath.rural, 1),
                                      _rural_urban_selection_Widget(
                                          s.urban_area, imagePath.urban, 2),
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
                                        width:
                                            MediaQuery.of(context).size.width,
                                        alignment:
                                            AlignmentDirectional.topCenter,
                                        decoration: new BoxDecoration(
                                            color: c.colorAccent,
                                            border: Border.all(
                                                color: c.colorAccent, width: 2),
                                            borderRadius: new BorderRadius.only(
                                              topLeft:
                                                  const Radius.circular(10),
                                              topRight:
                                                  const Radius.circular(10),
                                              bottomLeft:
                                                  const Radius.circular(10),
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
                                      alignment:
                                          AlignmentDirectional.bottomCenter,
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
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
                                                  prefs.setString(
                                                      s.onOffType, "online");
                                                  prefs.setString(
                                                      s.workType, "rdpr");
                                                  if (prefs.getString(
                                                          s.key_rural_urban) ==
                                                      'R') {
                                                    Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                      builder: (context) =>
                                                          RDPR_Online(),
                                                    ))
                                                        .then((value) {
                                                      isLogin = "RDPR";
                                                      initialize();
                                                      // you can do what you need here
                                                      // setState etc.
                                                    });
                                                  } else {
                                                    Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                      builder: (context) =>
                                                          RDPRUrbanWorks(),
                                                    ))
                                                        .then((value) {
                                                      isLogin = "RDPR";
                                                      initialize();
                                                      // you can do what you need here
                                                      // setState etc.
                                                    });
                                                  }

                                                  /* Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => RDPR_Online()));*/
                                                },
                                                child: Text(
                                                  s.go_online,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: c.darkblue),
                                                ),
                                              ),
                                              Divider(color: c.grey_6),
                                              InkWell(
                                                onTap: () {
                                                  prefs.setString(
                                                      s.onOffType, "offline");
                                                  prefs.setString(
                                                      s.workType, "rdpr");
                                                  if (prefs.getString(
                                                          s.key_rural_urban) ==
                                                      'R') {
                                                    Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                      builder: (context) =>
                                                          RDPR_Offline(),
                                                    ))
                                                        .then((value) {
                                                      isLogin = "RDPR";
                                                      initialize();
                                                      // you can do what you need here
                                                      // setState etc.
                                                    });
                                                  } else {
                                                    Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                      builder: (context) =>
                                                          RDPRUrbanWorks(),
                                                    ))
                                                        .then((value) {
                                                      isLogin = "RDPR";
                                                      initialize();
                                                      // you can do what you need here
                                                      // setState etc.
                                                    });
                                                  }
                                                },
                                                child: Text(
                                                  s.go_offline,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                        width:
                                            MediaQuery.of(context).size.width,
                                        alignment:
                                            AlignmentDirectional.topCenter,
                                        decoration: BoxDecoration(
                                            color: c.colorAccent,
                                            border: Border.all(
                                                color: c.colorAccent, width: 2),
                                            borderRadius: BorderRadius.only(
                                              topLeft:
                                                  const Radius.circular(10),
                                              topRight:
                                                  const Radius.circular(10),
                                              bottomLeft:
                                                  const Radius.circular(10),
                                              bottomRight:
                                                  const Radius.circular(10),
                                            )),
                                        child: InkWell(
                                          onTap: () {
                                            callOtherWorkEntryScreen();
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
                                      alignment:
                                          AlignmentDirectional.bottomCenter,
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        // clipBehavior is necessary because, without it, the InkWell's animation
                                        // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                                        // This comes with a small performance cost, and you should not set [clipBehavior]
                                        // unless you need it.
                                        clipBehavior: Clip.hardEdge,
                                        child: InkWell(
                                          onTap: () {
                                            callOtherWorkEntryScreen();
                                          },
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: c.darkblue),
                                                ),
                                              ],
                                            ),
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
                      visible: atrFlag,
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
                                        alignment:
                                            AlignmentDirectional.topCenter,
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          height: 80,
                                          width: 200,
                                          alignment:
                                              AlignmentDirectional.topCenter,
                                          decoration: new BoxDecoration(
                                              color: c.colorAccent,
                                              border: Border.all(
                                                  color: c.colorAccent,
                                                  width: 2),
                                              borderRadius:
                                                  new BorderRadius.only(
                                                topLeft:
                                                    const Radius.circular(10),
                                                topRight:
                                                    const Radius.circular(10),
                                                bottomLeft:
                                                    const Radius.circular(10),
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
                                        alignment:
                                            AlignmentDirectional.bottomCenter,
                                        child: Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
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
                                                    prefs.setString(
                                                        s.workType, "atr");
                                                    String? area_type =
                                                        prefs.getString(
                                                            s.key_rural_urban);
                                                    Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                      builder: (context) =>
                                                          ATR_Worklist(
                                                        Flag: area_type,
                                                      ),
                                                    ))
                                                        .then((value) {
                                                      isLogin = "ATR";
                                                      initialize();
                                                      // you can do what you need here
                                                      // setState etc.
                                                    });
                                                  },
                                                  child: Text(
                                                    s.go_online,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: c.darkblue),
                                                  ),
                                                ),
                                                Divider(color: c.grey_6),
                                                InkWell(
                                                  onTap: () {
                                                    prefs.setString(
                                                        s.onOffType, "offline");
                                                    prefs.setString(
                                                        s.workType, "atr");
                                                    String? area_type =
                                                        prefs.getString(
                                                            s.key_rural_urban);
                                                    Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                      builder: (context) =>
                                                          ATR_Offline_worklist(
                                                        Flag: area_type,
                                                      ),
                                                    ))
                                                        .then((value) {
                                                      isLogin = "ATR";
                                                      initialize();
                                                      // you can do what you need here
                                                      // setState etc.
                                                    });
                                                  },
                                                  child: Text(
                                                    s.go_offline,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                          )),
                    ),
                  ],
                )),
              ),
              Visibility(
                visible: syncFlag,
                child: GestureDetector(
                  onTap: () {
                    __openPendingScreen();
                  },
                  onVerticalDragStart: (details) => __openPendingScreen(),
                  child: Container(
                      padding: EdgeInsets.all(15),
                      alignment: AlignmentDirectional.bottomCenter,
                      decoration: BoxDecoration(
                          color: c.colorAccent,
                          border: Border.all(color: c.colorAccent, width: 2),
                          borderRadius: BorderRadius.only(
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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  logout() async {
    if (await checkLocalData()) {
      utils.customAlertWidet(context, "Error", s.logout_message);
    } else {
      if (await utils.isOnline()) {
        utils.customAlertWidet(context, "Logout", s.logout);
      } else {
        utils.customAlertWidet(context, "Warning", s.logout_msg);
      }
    }
  }

  // *************************** PENDING SCREEN  *************************** //

  __openPendingScreen() {
    Navigator.of(context)
        .push(CupertinoPageRoute(
          fullscreenDialog: true,
          builder: (context) => PendingScreen(),
        ))
        .then((value) => checkLocalData());
  }

  // *************************** CHECK LOCAL DATA *************************** //

  Future<bool> checkLocalData() async {
    var isExists = await dbClient
        .rawQuery("SELECT count(1) as cnt FROM ${s.table_save_work_details} ");

    // print(isExists);

    isExists[0]['cnt'] > 0 ? syncFlag = true : syncFlag = false;
    setState(() {});

    return syncFlag;
  }

  Future<void> callApis() async {
    // getProfileData();
    await getPhotoCount();
    await getFinYearList();
    await getInspection_statusList();
    await getCategoryList();
    if (prefs.getString(s.key_level) != "S") {
      await getTownList();
      await getMunicipalityList();
      await getCorporationList();
    }
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM ' + s.table_WorkStages);
    print("table_WorkStages >>" + list.toString());
    print("table_WorkStages_size >>" + list.length.toString());
    if (list.length == 0) {
      await getAll_Stage();
    }
    setState(() {});
  }

  Future<void> getDashboardData() async {
    utils.showProgress(context, 1);
    late Map json_request;

    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);

    json_request = {
      s.key_service_id: s.service_key_current_finyear_wise_status_count
    };

    Map encrypted_request = {
      s.key_user_name: userName,
      s.key_data_content: json_request,
    };

    String jsonString = jsonEncode(encrypted_request);

    String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

    String header_token = utils.jwt_Encode(key, userName!, headerSignature);

    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $header_token"
    };

    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = IOClient(_client);

    var response = await _ioClient.post(url.main_service_jwt,
        body: jsonEncode(encrypted_request), headers: header);

    print("DashboardData_url>>" + url.main_service_jwt.toString());
    print("DashboardData_request_encrpt>>" + encrypted_request.toString());
    utils.hideProgress(context);

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;

      print("DashboardData_response>>" + data);

      print("DashboardData_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("DashboardData Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("DashboardData responceSignature -  $responceSignature");

      print("DashboardData responceData -  $responceData");

      if (responceSignature == responceData) {
        print("DashboardData responceSignature - Token Verified");

        var userData = jsonDecode(data);
        var status = userData[s.key_status];
        var response_value = userData[s.key_response];
        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          if (res_jsonArray.length > 0) {
            for (int i = 0; i < res_jsonArray.length; i++) {
              String satisfied_count =
                  res_jsonArray[i][s.key_satisfied].toString();
              String un_satisfied_count =
                  res_jsonArray[i][s.key_unsatisfied].toString();
              String need_improvement_count =
                  res_jsonArray[i][s.key_need_improvement].toString();
              String fin_year = res_jsonArray[i][s.key_fin_year];
              String inspection_type = res_jsonArray[i][s.key_inspection_type];
              if (satisfied_count == ("")) {
                satisfied_count = "0";
              }
              if (un_satisfied_count == ("")) {
                un_satisfied_count = "0";
              }
              if (need_improvement_count == ("")) {
                need_improvement_count = "0";
              }
              int total_inspection_count = int.parse(satisfied_count) +
                  int.parse(un_satisfied_count) +
                  int.parse(need_improvement_count);

              if (inspection_type == ("rdpr")) {
                prefs.setString(s.satisfied_count, satisfied_count);
                prefs.setString(s.un_satisfied_count, un_satisfied_count);
                prefs.setString(
                    s.need_improvement_count, need_improvement_count);
                prefs.setString(
                    s.total_rdpr, total_inspection_count.toString());
                prefs.setString(s.financial_year, fin_year);
              } else {
                prefs.setString(s.satisfied_count_other, satisfied_count);
                prefs.setString(s.un_satisfied_count_other, un_satisfied_count);
                prefs.setString(
                    s.need_improvement_count_other, need_improvement_count);
                prefs.setString(
                    s.total_other, total_inspection_count.toString());
                prefs.setString(s.financial_year, fin_year);
              }
            }
          }
          setState(() {
            satisfied_count = prefs.getString(s.satisfied_count)!;
            un_satisfied_count = prefs.getString(s.un_satisfied_count)!;
            need_improvement_count = prefs.getString(s.need_improvement_count)!;
            satisfied_count_other = prefs.getString(s.satisfied_count_other)!;
            un_satisfied_count_other =
                prefs.getString(s.un_satisfied_count_other)!;
            need_improvement_count_other =
                prefs.getString(s.need_improvement_count_other)!;
            total_rdpr = prefs.getString(s.total_rdpr)!;
            total_other = prefs.getString(s.total_other)!;
            fin_year = prefs.getString(s.financial_year)!;
          });
        }
      } else {
        utils.customAlertWidet(context, "Error", s.jsonError);
        print("DashboardData responceSignature - Token Not Verified");
      }
    }
  }

  Future<void> getProfileData() async {
    utils.showProgress(context, 1);
    late Map json_request;

    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);

    json_request = {
      s.key_service_id: s.service_key_work_inspection_profile_list,
    };

    Map encrypted_request = {
      s.key_user_name: userName,
      s.key_data_content: json_request,
    };

    String jsonString = jsonEncode(encrypted_request);

    String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

    String header_token = utils.jwt_Encode(key, userName!, headerSignature);

    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $header_token"
    };

    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = IOClient(_client);

    var response = await _ioClient.post(url.main_service_jwt,
        body: jsonEncode(encrypted_request), headers: header);

    print("ProfileData_url>>" + url.main_service_jwt.toString());
    print("ProfileData_request_encrpt>>" + encrypted_request.toString());
    utils.hideProgress(context);

    if (response.statusCode == 200) {
      utils.showProgress(context, 1);

      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;

      print("ProfileData_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("ProfileData Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("ProfileData responceSignature -  $responceSignature");

      print("ProfileData responceData -  $responceData");

      utils.hideProgress(context);

      if (responceSignature == responceData) {
        print("ProfileData responceSignature - Token Verified");
        utils.showProgress(context, 1);

        var userData = jsonDecode(data);

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
        utils.hideProgress(context);
      } else {
        utils.customAlertWidet(context, "Error",
            s.jsonError) /* .then((value) async => await getProfileData())*/;
        print("ProfileData responceSignature - Token Not Verified");
      }
    }
  }

  Future<void> getPhotoCount() async {
    // utils.showProgress(context, 1);
    late Map json_request;

    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);

    json_request = {
      s.key_service_id: s.service_key_photo_count,
    };

    Map encrypted_request = {
      s.key_user_name: userName,
      s.key_data_content: json_request,
    };

    String jsonString = jsonEncode(encrypted_request);

    String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

    String header_token = utils.jwt_Encode(key, userName!, headerSignature);

    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $header_token"
    };

    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = IOClient(_client);

    var response = await _ioClient.post(url.main_service_jwt,
        body: jsonEncode(encrypted_request), headers: header);

    print("photo_count_url>>" + url.main_service_jwt.toString());
    print("photo_count_request_encrpt>>" + encrypted_request.toString());
    // utils.hideProgress(context);

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("photo_count_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("photo_count Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("photo_count responceSignature -  $responceSignature");

      print("photo_count responceData -  $responceData");

      if (responceSignature == responceData) {
        print("photo_count responceSignature - Token Verified");

        var userData = jsonDecode(data);

        var status = userData[s.key_status];
        var response_value = userData[s.key_response];
        if (status == s.key_ok && response_value == s.key_ok) {
          prefs.setString(
              s.service_key_photo_count, userData[s.key_COUNT].toString());
        }
      } else {
        utils
            .customAlertWidet(context, "Error", s.jsonError)
            .then((value) async => await getPhotoCount());
        print("photo_count responceSignature - Token Not Verified");
      }
    }
  }

  Future<void> getFinYearList() async {
    // utils.showProgress(context, 1);
    late Map json_request;

    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);

    json_request = {
      s.key_service_id: s.service_key_fin_year,
    };

    Map encrypted_request = {
      s.key_user_name: userName,
      s.key_data_content: json_request,
    };

    String jsonString = jsonEncode(encrypted_request);

    String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

    String header_token = utils.jwt_Encode(key, userName!, headerSignature);

    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $header_token"
    };

    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = IOClient(_client);

    var response = await _ioClient.post(url.main_service_jwt,
        body: jsonEncode(encrypted_request), headers: header);

    print("fin_year_url>>" + url.main_service_jwt.toString());
    print("fin_year_request_encrpt>>" + encrypted_request.toString());
    // utils.hideProgress(context);

    if (response.statusCode == 200) {
      String data = response.body;
      print("fin_year_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("FinancialYear Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("FinancialYear responceSignature -  $responceSignature");

      print("FinancialYear responceData -  $responceData");

      if (responceSignature == responceData) {
        print("FinancialYear responceSignature - Token Verified");

        var userData = jsonDecode(data);

        var status = userData[s.key_status];
        var response_value = userData[s.key_response];
        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          if (res_jsonArray.isNotEmpty) {
            dbHelper.delete_table_FinancialYear();

            String sql =
                'INSERT INTO ${s.table_FinancialYear} (fin_year) VALUES ';

            List<String> valueSets = [];

            for (var row in res_jsonArray) {
              String values = " ('${row[s.service_key_fin_year]}')";
              valueSets.add(values);
            }

            sql += valueSets.join(', ');

            await dbHelper.myDb?.execute(sql);

            /* for (int i = 0; i < res_jsonArray.length; i++) {
              await dbClient.rawInsert('INSERT INTO ' +
                  s.table_FinancialYear +
                  ' (fin_year) VALUES(' +
                  "'" +
                  res_jsonArray[i][s.service_key_fin_year] +
                  "')");
            } */

            List<Map> list = await dbClient
                .rawQuery('SELECT * FROM ' + s.table_FinancialYear);
            print("table_FinancialYear >>" + list.toString());
          }
        }
      } else {
        utils
            .customAlertWidet(context, "Error", s.jsonError)
            .then((value) async => await getFinYearList());
        print("FinancialYear responceSignature - Token Not Verified");
      }
    }
  }

  Future<void> getInspection_statusList() async {
    // utils.showProgress(context, 1);
    late Map json_request;

    json_request = {
      s.key_service_id: s.service_key_inspection_status,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: utils.encryption(
          jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.master_service,
        body: json.encode(encrpted_request));
    print("inspection_status_url>>" + url.master_service.toString());
    print("inspection_status_request_json>>" + json_request.toString());
    print("inspection_status_request_encrpt>>" + encrpted_request.toString());
    // utils.hideProgress(context);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("inspection_status_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data =
          utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        if (res_jsonArray.length > 0) {
          dbHelper.delete_table_Status();
          for (int i = 0; i < res_jsonArray.length; i++) {
            await dbClient.rawInsert('INSERT INTO ' +
                s.table_Status +
                ' (status_id  , status) VALUES(' +
                res_jsonArray[i][s.key_status_id] +
                ",'" +
                res_jsonArray[i][s.key_status_name] +
                "')");
          }
          List<Map> list =
              await dbClient.rawQuery('SELECT * FROM ' + s.table_Status);
          print("table_Status >>" + list.toString());
        }
      }
    }
  }

  Future<void> getCategoryList() async {
    // utils.showProgress(context, 1);
    late Map json_request;

    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);

    json_request = {
      s.key_service_id: s.service_key_other_work_category_list,
    };

    Map encrypted_request = {
      s.key_user_name: userName,
      s.key_data_content: json_request,
    };

    String jsonString = jsonEncode(encrypted_request);

    String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

    String header_token = utils.jwt_Encode(key, userName!, headerSignature);

    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $header_token"
    };

    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = IOClient(_client);

    var response = await _ioClient.post(url.main_service_jwt,
        body: jsonEncode(encrypted_request), headers: header);

    print("other_work_category_list_url>>" + url.main_service_jwt.toString());
    print("other_work_category_list_request_encrpt>>" +
        encrypted_request.toString());
    // utils.hideProgress(context);

    if (response.statusCode == 200) {
      String data = response.body;
      print("other_work_category_list_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("other_work_category_list Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("other_work_category_list responceSignature -  $responceSignature");

      print("other_work_category_list responceData -  $responceData");

      if (responceSignature == responceData) {
        print("other_work_category_list responceSignature - Token Verified");

        var userData = jsonDecode(data);

        var status = userData[s.key_status];
        var response_value = userData[s.key_response];
        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];

          for (var item in res_jsonArray) {
            item[s.key_other_work_category_name] =
                item[s.key_other_work_category_name].toString().replaceAll("'", "\'");
          }
          res_jsonArray.sort((a, b) {
            return a[s.key_other_work_category_name]
                .toLowerCase()
                .compareTo(b[s.key_other_work_category_name].toLowerCase());
          });
          if (res_jsonArray.isNotEmpty) {
            dbHelper.delete_table_OtherCategory();

            String sql =
                'INSERT INTO ${s.table_OtherCategory} (other_work_category_id  , other_work_category_name) VALUES ';

            List<String> valueSets = [];

            for (var row in res_jsonArray) {
              String values =
                  " ('${row[s.key_other_work_category_id]}', '${row[s.key_other_work_category_name]}')";
              valueSets.add(values);
            }

            sql += valueSets.join(', ');

            await dbHelper.myDb?.execute(sql);

            /* for (int i = 0; i < res_jsonArray.length; i++) {
              await dbClient.rawInsert('INSERT INTO ' +
                  s.table_OtherCategory +
                  ' (other_work_category_id  , other_work_category_name) VALUES(' +
                  "'" +
                  res_jsonArray[i][s.key_other_work_category_id].toString() +
                  "' , '" +
                  res_jsonArray[i][s.key_other_work_category_name] +
                  "')");
            } */

            List<Map> list = await dbClient
                .rawQuery('SELECT * FROM ' + s.table_OtherCategory);
            print("table_OtherCategory >>" + list.toString());
          }
        }
      } else {
        utils
            .customAlertWidet(context, "Error", s.jsonError)
            .then((value) async => await getCategoryList());
        print(
            "other_work_category_list responceSignature - Token Not Verified");
      }
    }
  }

  Future<void> getTownList() async {
    // utils.showProgress(context, 1);
    Map json_request = {
      s.key_service_id: s.service_key_townpanchayat_list_district_wise,
      s.key_dcode: prefs.getString(s.key_dcode),
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: utils.encryption(
          jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.master_service,
        body: json.encode(encrpted_request), headers: header);
    print("TownList_url>>" + url.master_service.toString());
    print("TownList_request_json>>" + json_request.toString());
    print("TownList_request_encrpt>>" + encrpted_request.toString());
    // utils.hideProgress(context);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("TownList_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data =
          utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        res_jsonArray.sort((a, b) {
          return a[s.key_townpanchayat_name]
              .toLowerCase()
              .compareTo(b[s.key_townpanchayat_name].toLowerCase());
        });
        if (res_jsonArray.isNotEmpty) {
          for (var item in res_jsonArray) {
            item[s.key_townpanchayat_name] =
                item[s.key_townpanchayat_name].toString().replaceAll("'", "\'");
          }
          dbHelper.delete_table_TownList();

          String sql =
              'INSERT INTO ${s.table_TownList} (dcode  , townpanchayat_id , townpanchayat_name) VALUES ';

          List<String> valueSets = [];

          for (var row in res_jsonArray) {
            String values =
                " ('${row[s.key_dcode]}', '${row[s.key_townpanchayat_id]}','${row[s.key_townpanchayat_name]}')";
            valueSets.add(values);
          }

          sql += valueSets.join(', ');

          await dbHelper.myDb?.execute(sql);

          /*for (int i = 0; i < res_jsonArray.length; i++) {
            await dbClient.rawInsert('INSERT INTO ' +
                s.table_TownList +
                ' (dcode  , townpanchayat_id , townpanchayat_name) VALUES(' +
                "'" +
                res_jsonArray[i][s.key_dcode].toString() +
                "' , '" +
                res_jsonArray[i][s.key_townpanchayat_id] +
                "' , '" +
                res_jsonArray[i][s.key_townpanchayat_name] +
                "')");
          } */

          List<Map> list =
              await dbClient.rawQuery('SELECT * FROM ' + s.table_TownList);
          print("table_TownList >>" + list.toString());
        }
      }
    }
  }

  Future<void> getMunicipalityList() async {
    // utils.showProgress(context, 1);
    Map json_request = {
      s.key_service_id: s.service_key_municipality_list_district_wise,
      s.key_dcode: prefs.getString(s.key_dcode),
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: utils.encryption(
          jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.master_service,
        body: json.encode(encrpted_request));
    print("MunicipalityList_url>>" + url.master_service.toString());
    print("MunicipalityList_request_json>>" + json_request.toString());
    print("MunicipalityList_request_encrpt>>" + encrpted_request.toString());
    // utils.hideProgress(context);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("MunicipalityList_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data =
          utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        for (var item in res_jsonArray) {
          item[s.key_municipality_name] =
              item[s.key_municipality_name].toString().replaceAll("'", "\'");
        }
        res_jsonArray.sort((a, b) {
          return a[s.key_municipality_name]
              .toLowerCase()
              .compareTo(b[s.key_municipality_name].toLowerCase());
        });
        if (res_jsonArray.length > 0) {
          dbHelper.delete_table_Municipality();

          String sql =
              'INSERT INTO ${s.table_Municipality} (dcode  , municipality_id , municipality_name) VALUES ';

          List<String> valueSets = [];

          for (var row in res_jsonArray) {
            String values =
                " ('${row[s.key_dcode]}', '${row[s.key_municipality_id]}','${row[s.key_municipality_name]}')";
            valueSets.add(values);
          }

          sql += valueSets.join(', ');

          await dbHelper.myDb?.execute(sql);

          /* for (int i = 0; i < res_jsonArray.length; i++) {
            await dbClient.rawInsert('INSERT INTO ' +
                s.table_Municipality +
                ' (dcode  , municipality_id , municipality_name) VALUES(' +
                "'" +
                res_jsonArray[i][s.key_dcode].toString() +
                "' , '" +
                res_jsonArray[i][s.key_municipality_id] +
                "' , '" +
                res_jsonArray[i][s.key_municipality_name] +
                "')");
          } */

          List<Map> list =
              await dbClient.rawQuery('SELECT * FROM ' + s.table_Municipality);
          print("table_Municipality >>" + list.toString());
        }
      }
    }
  }

  Future<void> getCorporationList() async {
    // utils.showProgress(context, 1);
    Map json_request = {
      s.key_service_id: s.service_key_corporation_list_district_wise,
      s.key_dcode: prefs.getString(s.key_dcode),
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: utils.encryption(
          jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.master_service,
        body: json.encode(encrpted_request));
    print("CorporationList_url>>" + url.master_service.toString());
    print("CorporationList_request_json>>" + json_request.toString());
    print("CorporationList_request_encrpt>>" + encrpted_request.toString());
    // utils.hideProgress(context);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("CorporationList_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data =
          utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        for (var item in res_jsonArray) {
          item[s.key_corporation_name] =
              item[s.key_corporation_name].toString().replaceAll("'", "\'");
        }
        res_jsonArray.sort((a, b) {
          return a[s.key_corporation_name]
              .toLowerCase()
              .compareTo(b[s.key_corporation_name].toLowerCase());
        });
        if (res_jsonArray.length > 0) {
          dbHelper.delete_table_Corporation();

          String sql =
              'INSERT INTO ${s.table_Corporation} (dcode  , corporation_id , corporation_name) VALUES ';

          List<String> valueSets = [];

          for (var row in res_jsonArray) {
            String values =
                " ('${row[s.key_dcode]}', '${row[s.key_corporation_id]}','${row[s.key_corporation_name]}')";
            valueSets.add(values);
          }

          sql += valueSets.join(', ');

          await dbHelper.myDb?.execute(sql);

          /* for (int i = 0; i < res_jsonArray.length; i++) {
            await dbClient.rawInsert('INSERT INTO ' +
                s.table_Corporation +
                ' (dcode  , corporation_id , corporation_name) VALUES(' +
                "'" +
                res_jsonArray[i][s.key_dcode].toString() +
                "' , '" +
                res_jsonArray[i][s.key_corporation_id] +
                "' , '" +
                res_jsonArray[i][s.key_corporation_name] +
                "')");
          } */
          List<Map> list =
              await dbClient.rawQuery('SELECT * FROM ' + s.table_Corporation);
          print("table_Corporation >>" + list.toString());
        }
      }
    }
  }

  Future<void> getAll_Stage() async {
    // utils.showProgress(context, 1);
    late Map json_request;

    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);

    json_request = {
      s.key_service_id: s.service_key_work_type_stage_link,
    };

    Map encrypted_request = {
      s.key_user_name: userName,
      s.key_data_content: json_request,
    };

    String jsonString = jsonEncode(encrypted_request);

    String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

    String header_token = utils.jwt_Encode(key, userName!, headerSignature);

    Map<String, String> header = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $header_token"
    };

    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);

    var response = await _ioClient.post(url.main_service_jwt,
        body: jsonEncode(encrypted_request), headers: header);

    print("WorkStages_url>>" + url.main_service_jwt.toString());
    print("WorkStages_request_encrpt>>" + encrypted_request.toString());
    // utils.hideProgress(context);

    if (response.statusCode == 200) {
      // utils.showProgress(context, 1);

      String data = response.body;
      print("WorkStages_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("WorkStages Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("WorkStages responceSignature -  $responceSignature");

      print("WorkStages responceData -  $responceData");

      // utils.hideProgress(context);

      if (responceSignature == responceData) {
        // utils.showProgress(context, 1);

        print("WorkStages responceSignature - Token Verified");

        var userData = jsonDecode(data);
        var status = userData[s.key_status];
        var response_value = userData[s.key_response];
        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          res_jsonArray.sort((a, b) {
            return a[s.key_work_stage_code].compareTo(b[s.key_work_stage_code]);
          });
          if (res_jsonArray.length > 0) {
            dbHelper.delete_table_WorkStages();

            String sql =
                'INSERT INTO ${s.table_WorkStages} (work_group_id, work_type_id, work_stage_order, work_stage_code, work_stage_name) VALUES ';

            List<String> valueSets = [];

            for (var row in res_jsonArray) {
              String values =
                  " ('${row[s.key_work_group_id]}', '${row[s.key_work_type_id]}', '${row[s.key_work_stage_order]}', '${row[s.key_work_stage_code]}', '${row[s.key_work_stage_name]}')";
              valueSets.add(values);
            }

            sql += valueSets.join(', ');

            await dbHelper.myDb?.execute(sql);

            // for (int i = 0; i < res_jsonArray.length; i++) {
            //   await dbClient.rawInsert('INSERT INTO ' +
            //       s.table_WorkStages +
            //       ' (work_group_id , work_type_id , work_stage_order , work_stage_code , work_stage_name) VALUES(' +
            //       res_jsonArray[i][s.key_work_group_id].toString() +
            //       ',' +
            //       res_jsonArray[i][s.key_work_type_id].toString() +
            //       ',' +
            //       res_jsonArray[i][s.key_work_stage_order].toString() +
            //       ',' +
            //       res_jsonArray[i][s.key_work_stage_code].toString() +
            //       ",'" +
            //       res_jsonArray[i][s.key_work_stage_name] +
            //       "')");
            // }

            List<Map> list =
                await dbClient.rawQuery('SELECT * FROM ' + s.table_WorkStages);

            print("table_WorkStages >>" + list.toString());
            print("table_WorkStages size >>" + res_jsonArray.length.toString());
          }
        }
        // utils.hideProgress(context);
      } else {
        print("WorkStages responceSignature - Token Not Verified");
      }
    }
  }

  callOtherWorkEntryScreen() {
    prefs.setString(s.onOffType, "online");
    prefs.setString(s.workType, "other");
    if (prefs.getString(s.key_rural_urban) == "R") {
      Navigator.of(context)
          .push(MaterialPageRoute(
        builder: (context) => OtherWorksRural(),
      ))
          .then((value) {
        isLogin = "OTHER";
        initialize();
        // you can do what you need here
        // setState etc.
      });
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(
        builder: (context) => OtherWorkUrban(),
      ))
          .then((value) {
        isLogin = "OTHER";
        initialize();
        // you can do what you need here
        // setState etc.
      });
    }
  }
}
