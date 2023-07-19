// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unnecessary_new, unrelated_type_equality_checks, sized_box_for_whitespace, avoid_types_as_parameter_names, unnecessary_null_comparison, avoid_unnecessary_containers

import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:inspection/Activity/Home.dart';
import 'package:inspection/Activity/Login.dart';
import 'package:inspection/Activity/ViewSavedATRReport.dart';
import 'package:inspection/Activity/ViewSavedOther.dart';
import 'package:inspection/Activity/ViewSavedRDPRReport.dart';
import 'package:inspection/Resources/Strings.dart' as s;
import 'package:inspection/Resources/url.dart' as url;
import 'package:inspection/Resources/ImagePath.dart' as imagePath;
import 'package:inspection/Resources/ColorsValue.dart' as c;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Activity/ForgotPassword.dart';
import '../Activity/Registration.dart';
import '../Activity/View_Overall_Report_New.dart';
import '../DataBase/DbHelper.dart';
import '../Utils/utils.dart';

class DrawerApp extends StatefulWidget {
  @override
  State<DrawerApp> createState() => _DrawerAppState();
}

class _DrawerAppState extends State<DrawerApp> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  String name = "",
      designation = "",
      level = "",
      level_head = "",
      level_value = "",
      profile_image = "",
      area_type = "",
      version = "";
  bool atrFlag = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
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
    } else {
      profile_image = "";
    }

    if (level == "S") {
      level_head = "State : ";
      if (prefs.getString(s.key_stateName) != null &&
          prefs.getString(s.key_stateName) != "") {
        level_value = prefs.getString(s.key_stateName)!;
      } else {
        level_value = "";
      }
    } else if (level == "D") {
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
    if (prefs.getString(s.key_rural_urban) != null &&
        prefs.getString(s.key_rural_urban) != "" &&
        prefs.getString(s.key_rural_urban) == "R") {
      area_type = s.rural_area;
    } else if (prefs.getString(s.key_rural_urban) != null &&
        prefs.getString(s.key_rural_urban) != "" &&
        prefs.getString(s.key_rural_urban) == "U") {
      area_type = s.urban_area;
    }
    version = s.version + " " + await utils.getVersion();
    setState(() {});
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
              padding: EdgeInsets.only(top: 22),
              width: MediaQuery.of(context).size.width,
              height: 220,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                c.colorAccentlight,
                c.colorPrimaryDark,
              ], begin: Alignment.bottomLeft, end: Alignment.topRight)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.topStart,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: new BoxDecoration(
                              color: c.white,
                              border: Border.all(color: c.white, width: 2),
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(0),
                                topRight: const Radius.circular(0),
                                bottomLeft: const Radius.circular(0),
                                bottomRight: const Radius.circular(110),
                              )),
                          alignment: AlignmentDirectional.topStart,
                          margin: EdgeInsets.fromLTRB(0, 10, 15, 0),
                          child: Container(
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                      colors: [
                                        c.colorPrimaryDark,
                                        c.colorAccentlight,
                                      ],
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight)),
                              child: profile_image != null &&
                                      profile_image != ""
                                  ? InkWell(
                                      onTap: () => showDialog(
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                backgroundColor:
                                                    Colors.transparent,
                                                insetPadding: EdgeInsets.all(2),
                                                title: Container(
                                                  decoration: BoxDecoration(),
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Expanded(
                                                    child: Image.memory(
                                                      base64.decode(
                                                          profile_image
                                                              .replaceAll(
                                                                  RegExp(
                                                                      r'\s+'),
                                                                  '')),
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          context: context),
                                      child: CircleAvatar(
                                          backgroundImage: MemoryImage(
                                            base64.decode(profile_image),
                                          ),
                                          radius: 30.0))
                                  : CircleAvatar(
                                      backgroundImage: AssetImage(
                                        imagePath.regUser,
                                      ),
                                      radius: 30.0)),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 20, 10, 0),
                          alignment: Alignment.topRight,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            area_type,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: c.white,
                                fontSize: 13),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Column(children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 10, 10, 0),
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: c.white,
                              fontSize: 13),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 5, 10, 0),
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          designation,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: c.white,
                              fontSize: 11),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 5, 10, 0),
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          level_head + level_value,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: c.white,
                              fontSize: 11),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ]),
                  ])),
          Expanded(
            child: SingleChildScrollView(
                child: Column(
              children: [
                Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 10, 5),
                    child: InkWell(
                      onTap: () async {
                        // Navigator.of(context).pop();
                        var isExists = await dbClient.rawQuery(
                            "SELECT count(1) as cnt FROM ${s.table_save_work_details} ");

                        // print(isExists);

                        isExists[0]['cnt'] > 0
                            ? utils.customAlertWidet(
                                context, "Error", s.edit_message)
                            : getProfileList();

/*                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Registration(registerFlag: 2)));*/
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              imagePath.edit_user,
                              height: 25,
                              width: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              s.edit_profile,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: c.darkblue,
                                  fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ]),
                    )),
                Divider(color: c.grey_6),
                Container(
                    margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Overall_Report_new(flag: level),
                        ));
                        print("### FLAG #### $level");
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              imagePath.report_ic,
                              height: 25,
                              width: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              s.over_all_inspection_report,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: c.darkblue,
                                  fontSize: 13),
                            ),
                          ]),
                    )),
                Divider(color: c.grey_6),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
                  child: Visibility(
                      visible: atrFlag,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ViewSavedATRReport(Flag: area_type)));
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                imagePath.atr_logo,
                                height: 25,
                                width: 25,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                s.atr_report,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: c.darkblue,
                                    fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ]),
                      )),
                ),
                Visibility(
                  visible: atrFlag,
                  child: Divider(color: c.grey_6),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ViewSavedRDPRReport(Flag: area_type),
                        ));
                        print("FLAG####$area_type");
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              imagePath.inspection_ic,
                              height: 25,
                              width: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              s.view_inspected_work,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: c.darkblue,
                                  fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ]),
                    )),
                Divider(color: c.grey_6),
                Container(
                    margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ViewSavedOther(Flag: area_type),
                        ));
                        print("FLAG####$area_type");
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              imagePath.infrastructure,
                              height: 25,
                              width: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              s.view_inspected_other_work,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: c.darkblue,
                                  fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ]),
                    )),
                Divider(color: c.grey_6),
                Container(
                    margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPassword(
                                      isForgotPassword: "change_password",
                                    )));
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              imagePath.forgot_password,
                              height: 25,
                              width: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              s.change_password,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: c.darkblue,
                                  fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ]),
                    )),
                Divider(color: c.grey_6),
                Container(
                    margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
                    child: InkWell(
                      onTap: () async {
                        await getAll_Stage();
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              imagePath.refresh,
                              height: 25,
                              width: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              s.refresh_work_stages_up_to_date,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: c.darkblue,
                                  fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ]),
                    )),
                Divider(color: c.grey_6),
                Container(
                    margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
                    child: InkWell(
                      onTap: () {
                        // Navigator.of(context).pop(false);
                        // Navigator.push(context,MaterialPageRoute(builder:(context) => Login()));
                        // showAlertDialog();
                        logout();
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              imagePath.log_out_ic,
                              height: 25,
                              width: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              s.log_out,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: c.darkblue,
                                  fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ]),
                    )),
                Divider(color: c.grey_6),
              ],
            )),
          ),
          Container(
              alignment: Alignment.center,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 5, 5),
                      child: Image.asset(
                        imagePath.version_icon,
                        fit: BoxFit.fill,
                        color: c.primary_text_color2,
                        height: 20,
                        width: 20,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      child: Text(
                        version,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: c.grey_8,
                            fontSize: 15),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ]))
        ],
      )),
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

  Future<bool> checkLocalData() async {
    bool syncFlag = false;
    var isExists = await dbClient
        .rawQuery("SELECT count(1) as cnt FROM ${s.table_save_work_details} ");

    // print(isExists);

    isExists[0]['cnt'] > 0 ? syncFlag = true : syncFlag = false;
    setState(() {});

    return syncFlag;
  }

  Future<void> stageApi() async {
    getAll_Stage();

    /* List<Map> list = await dbClient.rawQuery('SELECT * FROM '+s.table_WorkStages);
    print("table_WorkStages >>" + list.toString());
    print("table_WorkStages_size >>" + list.length.toString());
    if(list.length == 0){
      getAll_Stage();
    }*/
  }

  Future<void> getAll_Stage() async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    utils.showProgress(context, 1);
    try {
      late Map json_request;

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
        "Authorization": "Bearer $header_token"
      };
      // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
      HttpClient _client = HttpClient(context: await utils.globalContext);
      _client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => false;
      IOClient _ioClient = new IOClient(_client);
      var response = await _ioClient.post(url.main_service_jwt,
          body: jsonEncode(encrypted_request), headers: header);

      print("RefreshWorkStages_url>>${url.main_service_jwt}");
      print("RefreshWorkStages_request_json>>$json_request");
      print("RefreshWorkStages_request_encrpt>>$encrypted_request");
      utils.hideProgress(context);

      if (response.statusCode == 200) {
        utils.showProgress(context, 1);

        // If the server did return a 201 CREATED response,
        // then parse the JSON.
        String data = response.body;
        print("RefreshWorkStages_response>>$data");
        String? authorizationHeader = response.headers['authorization'];

        String? token = authorizationHeader?.split(' ')[1];

        print("RefreshWorkStages Authorization -  $token");

        String responceSignature = utils.jwt_Decode(key, token!);

        String responceData = utils.generateHmacSha256(data, key, false);

        print("RefreshWorkStages responceSignature -  $responceSignature");

        print("RefreshWorkStages responceData -  $responceData");

        utils.hideProgress(context);

        if (responceSignature == responceData) {
          utils.showProgress(context, 1);

          print("RefreshWorkStages responceSignature - Token Verified");
          var userData = jsonDecode(data);
          var status = userData[s.key_status];
          var response_value = userData[s.key_response];
          if (status == s.key_ok && response_value == s.key_ok) {
            List<dynamic> res_jsonArray = userData[s.key_json_data];
            if (res_jsonArray.isNotEmpty) {
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
              //       "'" +
              //       res_jsonArray[i][s.key_work_group_id].toString() +
              //       "' , '" +
              //       res_jsonArray[i][s.key_work_type_id].toString() +
              //       "' , '" +
              //       res_jsonArray[i][s.key_work_stage_order].toString() +
              //       "' , '" +
              //       res_jsonArray[i][s.key_work_stage_code].toString() +
              //       "' , '" +
              //       res_jsonArray[i][s.key_work_stage_name] +
              //       "')");
              // }

              List<Map> list = await dbClient
                  .rawQuery('SELECT * FROM ' + s.table_WorkStages);

              if (list.isNotEmpty) {
                utils.customAlertWidet(
                    context, "Success", s.refresh_work_stages_success);
              }
            }
            utils.hideProgress(context);
          }
        } else {
          print("RefreshWorkStages responceSignature - Token Not Verified");
          utils.customAlertWidet(context, "Error", s.jsonError);
        }
      }
    } on Exception catch (exception) {
      utils.hideProgress(context);
      utils.customAlertWidet(context, "Error",
          s.failed); // only executed if error is of type Exception
    } catch (error) {
      utils.hideProgress(context);
      utils.customAlertWidet(context, "Error",
          s.failed); // executed for errors of all types other than Exception
    }

    Navigator.pop(context);
  }

  Future<void> getProfileList() async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);

    utils.showProgress(context, 1);
    var userPassKey = prefs.getString(s.userPassKey);

    Map jsonRequest = {
      s.key_service_id: s.service_key_work_inspection_profile_list,
    };

    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: jsonRequest,
    };

    String jsonString = jsonEncode(encrypted_request);

    String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

    String header_token = utils.jwt_Encode(key, userName!, headerSignature);
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $header_token"
    };

    try{
      HttpClient _client = HttpClient(context: await Utils().globalContext);
      _client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => false;
      IOClient _ioClient = new IOClient(_client);
      var response = await _ioClient.post(url.main_service_jwt,
          body: jsonEncode(encrypted_request), headers: header);
      print("ProfileData_url>>" + url.main_service_jwt.toString());
      print("ProfileData_request_json>>" + jsonRequest.toString());
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
          var userData = jsonDecode(data);
          var status = userData[s.key_status];
          var response_value = userData[s.key_response];

          print(status);
          print(response_value);
          if (status == s.key_ok && response_value == s.key_ok) {
            List<dynamic> res_jsonArray = userData[s.key_json_data];
            if (res_jsonArray.isNotEmpty) {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Registration(
                        registerFlag: 2,
                        profileJson: res_jsonArray,
                      )));
            }
          }
        } else {
          print("ProfileData responceSignature - Token Not Verified");
          utils.customAlertWidet(context, "Error", s.jsonError);
        }
      }
    } on Exception catch (exception) {
      utils.hideProgress(context); // only executed if error is of type Exception
    } catch (error) {
      utils.hideProgress(context); // executed for errors of all types other than Exception
    }



  }
}
