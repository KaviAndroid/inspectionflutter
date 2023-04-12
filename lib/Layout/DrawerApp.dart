
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/Login.dart';
import 'package:inspection_flutter_app/Activity/ViewSavedRDPR.dart';
import 'package:inspection_flutter_app/Layout/DrawerApp.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Activity/ForgotPassword.dart';
import '../Activity/Registration.dart';
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

  @override
  void initState() {
    super.initState();
    initialize();
  }
  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs?.getString(s.key_name) != null && prefs?.getString(s.key_name) != "" ) {
      name=prefs!.getString(s.key_name)!;
    } else {
      name="";
    }
    if (prefs?.getString(s.key_desig_name) != null && prefs?.getString(s.key_desig_name) != "" ) {
      designation=prefs!.getString(s.key_desig_name)!;
    } else {
      designation="";
    }
    if (prefs?.getString(s.key_level) != null && prefs?.getString(s.key_level) != "" ) {
      level=prefs!.getString(s.key_level)!;
    } else {
      level="";
    }
    if (prefs?.getString(s.key_profile_image) != null && prefs?.getString(s.key_profile_image) != "" ) {
      profile_image=prefs!.getString(s.key_profile_image)!;
    } else {
      profile_image="";
    }

    if(level=="S"){
      level_head="State : ";
      if (prefs?.getString(s.key_stateName) != null && prefs?.getString(s.key_stateName) != "" ) {
        level_value=prefs!.getString(s.key_stateName)!;
      } else {
        level_value="";
      }
    }else if(level=="D"){
      level_head="District : ";
      if (prefs?.getString(s.key_dname) != null && prefs?.getString(s.key_dname) != "" ) {
        level_value=prefs!.getString(s.key_dname)!;
      } else {
        level_value="";
      }

    }else if(level=="B"){
      level_head="Block : ";
      if (prefs?.getString(s.key_bname) != null && prefs?.getString(s.key_bname) != "" ) {
        level_value=prefs!.getString(s.key_bname)!;
      } else {
        level_value="";
      }

    }
    if (prefs?.getString(s.area_type) != null && prefs?.getString(s.area_type) != "" && prefs?.getString(s.area_type) == "R" ) {
      area_type=s.rural_area;
    } else if (prefs?.getString(s.area_type) != null && prefs?.getString(s.area_type) != "" && prefs?.getString(s.area_type) == "U" ) {
      area_type=s.urban_area;
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
     version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    print("app>>"+appName+" >>"+packageName+" >>"+version+" >>"+buildNumber );
    setState(() {

    });
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
            Container(
              padding: EdgeInsets.only(top: 22),
              width:MediaQuery.of(context).size.width,
              height: 220,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        c.colorAccentlight,
                        c.colorPrimaryDark,
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight
                  )
              ),
              child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                Stack(
                  alignment: AlignmentDirectional.topStart,
                  children: [
              Container(
                width:120,
                  height: 120,
                  decoration: new BoxDecoration(
                      color: c.white,
                      border: Border.all(
                          color: c.white, width: 2),
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(0),
                        topRight: const Radius.circular(0),
                        bottomLeft: const Radius.circular(0),
                        bottomRight:
                        const Radius.circular(110),
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
                            end: Alignment.topRight
                        )
                    ),
                    child:                          ClipOval(
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
    height: 60,
    ),):SvgPicture.asset(
    imagePath.user,
    height: 50,
    )
    ),
                )
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

                   ],),

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
                      level_head+level_value,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: c.white,
                          fontSize: 11),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ]),
              ])),

        Expanded(child: SingleChildScrollView(

    child: Column(
    children: [
    Container(
      margin: EdgeInsets.fromLTRB(20, 10, 10, 5),
      child:InkWell(
        onTap: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Registration(registerFlag: 2)));

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
      SizedBox(width: 10,),
      Text(
        s.edit_profile,
        style: TextStyle(
            fontWeight: FontWeight.normal,
            color: c.darkblue,
            fontSize: 13),
        textAlign: TextAlign.center,
      ),
    ]),)
    ),
      Divider(color: c.grey_6),
      Container(
      margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
        child:InkWell(
            onTap: (){

            },child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        imagePath.report_ic,
        height: 25,
        width: 25,
      ),
      SizedBox(width: 10,),
      Text(
        s.over_all_inspection_report,
        style: TextStyle(
            fontWeight: FontWeight.normal,
            color: c.darkblue,
            fontSize: 13),
        textAlign: TextAlign.center,
      ),
    ]),)
    ),
      Divider(color: c.grey_6),
      Container(
          margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
        child:InkWell(
            onTap: (){

            },child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        imagePath.atr_logo,
        height: 25,
        width: 25,
      ),
      SizedBox(width: 10,),
      Text(
        s.atr_report,
        style: TextStyle(
            fontWeight: FontWeight.normal,
            color: c.darkblue,
            fontSize: 13),
        textAlign: TextAlign.center,
      ),
    ]),)
    ),
      Divider(color: c.grey_6),
      Container(
          margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
        child:InkWell(
            onTap: (){
              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) => ViewSavedRDPR(),
              ));
            },child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        imagePath.inspection_ic,
        height: 25,
        width: 25,
      ),
      SizedBox(width: 10,),
      Text(
        s.view_inspected_work,
        style: TextStyle(
            fontWeight: FontWeight.normal,
            color: c.darkblue,
            fontSize: 13),
        textAlign: TextAlign.center,
      ),
    ]),)
    ),
      Divider(color: c.grey_6),

               Container(
                   margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
                   child: InkWell(
                     onTap: () {
                     }, child: Row(
                       mainAxisAlignment: MainAxisAlignment.start,
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         Image.asset(
                           imagePath.infrastructure,
                           height: 25,
                           width: 25,
                         ),
                         SizedBox(width: 10,),
                         Text(
                           s.view_inspected_other_work,
                           style: TextStyle(
                               fontWeight: FontWeight.normal,
                               color: c.darkblue,
                               fontSize: 13),
                           textAlign: TextAlign.center,
                         ),
                       ]),)
               ),
               Divider(color: c.grey_6),
               Container(
                   margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
                   child: InkWell(
                     onTap: () {
                       Navigator.push(
                           context,
                           MaterialPageRoute(
                               builder: (context) =>
                                   ForgotPassword(
                                     isForgotPassword:
                                     "change_password",
                                   )));
                     }, child: Row(
                       mainAxisAlignment: MainAxisAlignment.start,
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         Image.asset(
                           imagePath.forgot_password,
                           height: 25,
                           width: 25,
                         ),
                         SizedBox(width: 10,),
                         Text(
                           s.change_password,
                           style: TextStyle(
                               fontWeight: FontWeight.normal,
                               color: c.darkblue,
                               fontSize: 13),
                           textAlign: TextAlign.center,
                         ),
                       ]),)
               ),
               Divider(color: c.grey_6),
               Container(
                   margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
                   child: InkWell(
                     onTap: () {
                       stageApi();
                       // getAll_Stage();
                     }, child: Row(
                       mainAxisAlignment: MainAxisAlignment.start,
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         Image.asset(
                           imagePath.refresh,
                           height: 25,
                           width: 25,
                         ),
                         SizedBox(width: 10,),
                         Text(
                           s.refresh_work_stages_up_to_date,
                           style: TextStyle(
                               fontWeight: FontWeight.normal,
                               color: c.darkblue,
                               fontSize: 13),
                           textAlign: TextAlign.center,
                         ),
                       ]),)
               ),
               Divider(color: c.grey_6),
               Container(
                   margin: EdgeInsets.fromLTRB(20, 5, 10, 5),
                   child: InkWell(
                     onTap: () {
                       // Navigator.of(context).pop(false);
                       // Navigator.push(context,MaterialPageRoute(builder:(context) => Login()));
                       showAlertDialog();
                     },child: Row(
                       mainAxisAlignment: MainAxisAlignment.start,
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         Image.asset(
                           imagePath.log_out_ic,
                           height: 25,
                           width: 25,
                         ),
                         SizedBox(width: 10,),
                         Text(
                           s.log_out,
                           style: TextStyle(
                               fontWeight: FontWeight.normal,
                               color: c.darkblue,
                               fontSize: 13),
                           textAlign: TextAlign.center,
                         ),
                       ]),)
               ),
               Divider(color: c.grey_6),


    ],
    )),),
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
                      s.version+" "+version,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: c.grey_8,
                          fontSize: 15),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ]))

          ],)),
    );
  }

  Future<void> showAlertDialog() async {

    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.pop(context,MaterialPageRoute(builder:(context)=>DrawerApp()));
      },
    );
    Widget OkButton = TextButton(
      child: Text("Ok"),
      onPressed:  () {
        Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>Login()));
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text("Are You Sure You Want To Logout? "),
      actions: [
        cancelButton,
        OkButton,
      ],
    );
    showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }
  Future<void> stageApi() async {
    List<Map> list = await dbClient.rawQuery('SELECT * FROM '+s.table_WorkStages);
    print("table_WorkStages >>" + list.toString());
    print("table_WorkStages_size >>" + list.length.toString());
    if(list.length == 0){
      getAll_Stage();
    }
  }
  Future<void> getAll_Stage() async {
    late Map json_request;

    json_request = {
      s.key_service_id: s.service_key_work_type_stage_link,
    };

    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
      utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context:await utils.globalContext);
    _client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service, body: json.encode(encrypted_request));
    print("RefreshWorkStages_url>>" + url.main_service.toString());
    print("RefreshWorkStages_request_json>>" + json_request.toString());
    print("RefreshWorkStages_request_encrpt>>" + encrypted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("RefreshWorkStages_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrptData = utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrptData);
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