import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../DataBase/DbHelper.dart';
import '../Layout/ReadMoreLess.dart';
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
  bool noDataFlag=false;
  bool villageListFlag=false;


  @override
  void initState(){
    initialize();
  }
  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    if(widget.villageList.length > 0){
      noDataFlag=false;
      villageListFlag=true;
    }else{
      noDataFlag=true;
      villageListFlag=false;
    }
    setState(() {

    });
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
                Visibility(
                  visible: villageListFlag,
                  child: Container(
              margin:EdgeInsets.fromLTRB(20, 10, 20, 10),child: ListView.builder(
    itemCount: widget.villageList == null ? 0 : widget.villageList.length,
    itemBuilder: (BuildContext context, int index){
    return InkWell(
      onTap: (){
        getWorkListByVillage(widget.villageList[index][s.key_dcode].toString(),widget.villageList[index][s.key_bcode].toString(),widget.villageList[index][s.key_pvcode].toString());
      },
      child:  Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      // clipBehavior is necessary because, without it, the InkWell's animation
      // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
      // This comes with a small performance cost, and you should not set [clipBehavior]
      // unless you need it.
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
    child: Row(children: [
      Container(width: 15,
          height: 35,
          decoration: BoxDecoration(
              borderRadius:
              new BorderRadius.only(
                topLeft:
                const Radius.circular(
                    10),
                topRight:
                const Radius.circular(
                    0),
                bottomLeft:
                const Radius.circular(
                    10),
                bottomRight:
                const Radius.circular(
                    0),
              ),
              gradient: LinearGradient(
                  colors: [
                    c.colorPrimary,
                    c.colorAccentverylight,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight
              )
          )     ,
        child:       Text(
          "",
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: c.grey_10),
        ),
      ),
      SizedBox(width: 10,),
      Container(height: 35,
        alignment: Alignment.centerLeft,
        child:Text(
        widget.villageList[index][s.key_pvname],
        style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: c.grey_10),
      ),
      ),
    ],),
    ),);
    },
    ),
    ),),
                Visibility(
                  visible: noDataFlag,
                  child: Align(
                  alignment: AlignmentDirectional.center,
                  child:Container(
                    alignment: Alignment.center,
                    child: Text(
                      s.no_village,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  ),
                )
              ]),));

  }

  Future<void> getWorkListByVillage(String dcode, String bcode, String pvcode) async {
    late Map json_request;

    Map work_detail = {
      s.key_dcode: dcode,
      s.key_bcode: bcode,
      s.key_pvcode: [pvcode],

    };
    json_request = {
      s.key_service_id: s.sevice_key_get_village_pending_works,
      s.key_inspection_work_details: work_detail,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
      utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    HttpClient _client = HttpClient(context:await utils.globalContext);
    _client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service, body: json.encode(encrpted_request));
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    print("WorkListByVillage_url>>" + url.main_service.toString());
    print("WorkListByVillage_request_json>>" + json_request.toString());
    print("WorkListByVillage_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("WorkListByVillage_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        if (res_jsonArray.length > 0) {
          List ongoingWorkList=[];
          List completedWorkList=[];
          for(int i=0; i<res_jsonArray.length;i++){
            if(res_jsonArray[i][s.key_current_stage_of_work] == 11){
              completedWorkList.add(res_jsonArray[i]);
            }else{
              ongoingWorkList.add(res_jsonArray[i]);
            }
          }

          Navigator.push(context, MaterialPageRoute(builder: (context) => WorkListFromGeoLocation(completedWorkList: completedWorkList,ongoingWorkList: ongoingWorkList,)));
        }else{
          utils.showAlert(context, s.no_village);
        }
      }
      else{
        utils.showAlert(context, s.no_village);
      }
    }
  }


}




class WorkListFromGeoLocation extends StatefulWidget {
  final completedWorkList;
  final ongoingWorkList;
  WorkListFromGeoLocation({this.completedWorkList,this.ongoingWorkList});
  @override
  State<WorkListFromGeoLocation> createState() => _WorkListFromGeoLocationState();
}

class _WorkListFromGeoLocationState extends State<WorkListFromGeoLocation> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  bool noDataFlag=false;
  bool workListFlag=false;
  int flag=1;
  List workList=[];


  @override
  void initState(){
    initialize();
  }
  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;

    if(widget.ongoingWorkList.length > 0){
      workList=[];
      workList.addAll(widget.ongoingWorkList);
      flag=1;
      noDataFlag=false;
      workListFlag=true;
    }else if(widget.completedWorkList.length > 0){
      workList=[];
      workList.addAll(widget.completedWorkList);
      flag=2;
      noDataFlag=false;
      workListFlag=true;
    }else {
      workList=[];
      flag=1;
      noDataFlag=true;
      workListFlag=false;
    }
    setState(() {

    });
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
                        s.work_list,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            color: c.bg_screen,
            child: Column(
              mainAxisSize: MainAxisSize.max,
            children: [
            Row(
              children: [
               Expanded(
                 flex: 1,
              child: InkWell(
                onTap: (){
                  setState(() {
                    flag=1;
                    if(widget.ongoingWorkList.length > 0){
                      workList=[];
                      workList.addAll(widget.ongoingWorkList);
                      noDataFlag=false;
                      workListFlag=true;
                    }else{
                      workList=[];
                      noDataFlag=true;
                      workListFlag=false;
                    }
                  });
                },
                child: Container(
                 margin: EdgeInsets.fromLTRB(20, 20, 0, 0),
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                alignment: AlignmentDirectional.center,
                decoration: new BoxDecoration(
                    color: flag == 1 ? c.colorAccent : c.white,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(30),
                      topRight: const Radius.circular(0),
                      bottomLeft: const Radius.circular(30),
                      bottomRight: const Radius.circular(0),
                    )),
                child: Text(
                  s.ongoing_works,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    color: flag == 1 ? c.white : c.grey_8,),
                ),
              ),
              ),
              ),
                Expanded(
                 flex: 1,
                 child: InkWell(
                   onTap: (){
                     setState(() {
                       flag=2;
                       if(widget.completedWorkList.length > 0){
                         workList=[];
                         workList.addAll(widget.completedWorkList);
                         noDataFlag=false;
                         workListFlag=true;
                       }else{
                         workList=[];
                         noDataFlag=true;
                         workListFlag=false;
                       }
                     });
                   },
                   child: Container(
                 margin: EdgeInsets.fromLTRB(0, 20, 20, 0),
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                alignment: AlignmentDirectional.center,
                decoration: new BoxDecoration(
                    color: flag == 2 ? c.colorAccent : c.white,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(0),
                      topRight: const Radius.circular(30),
                      bottomLeft: const Radius.circular(0),
                      bottomRight: const Radius.circular(30),
                    )),
                child: Text(
                  s.completed_works,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    color: flag == 2 ? c.white : c.grey_8,),
                ),
              ),),
              ),

            ],),
            Expanded(child: Stack(
              children: [
                Visibility(
                  visible: workListFlag,
                  child: Container(
                    margin:EdgeInsets.fromLTRB(20, 10, 20, 10),child: ListView.builder(
                    itemCount: workList == null ? 0 : workList.length ,
                    itemBuilder: (BuildContext context, int index){
                      return InkWell(
                        onTap: (){
                        },
                        child:  Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          // clipBehavior is necessary because, without it, the InkWell's animation
                          // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                          // This comes with a small performance cost, and you should not set [clipBehavior]
                          // unless you need it.
                          clipBehavior: Clip.hardEdge,
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: Row(children: [
                            Container(
                              width: 10,
                              decoration: BoxDecoration(
                                  borderRadius:
                                  new BorderRadius.only(
                                    topLeft:
                                    const Radius.circular(
                                        10),
                                    topRight:
                                    const Radius.circular(
                                        0),
                                    bottomLeft:
                                    const Radius.circular(
                                        10),
                                    bottomRight:
                                    const Radius.circular(
                                        0),
                                  ),
                                  gradient: LinearGradient(
                                      colors: [
                                        c.colorPrimary,
                                        c.colorAccentverylight,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight
                                  )
                              )     ,
                              child:       Text(
                                "",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: c.grey_10),
                              ),
                            ),
                            SizedBox(width: 10,),
                            Expanded(child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                InkWell(
                                onTap: (){
                            },
                              child: Container(
                                padding: EdgeInsets.fromLTRB(10,5,10,0),
                                child: Image.asset(
                                imagePath.action,
                                height: 35,
                                width: 40,
                              ),
                              ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Expanded(
                                  flex:2,
                                  child:Text(
                                  s.work_id,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: c.grey_8),
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  softWrap: true,
                                ),
                                ),
                                Expanded(
                                  flex:0,
                                  child:Text(
                                  ' : ',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: c.grey_8),
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  softWrap: true,
                                ),
                                ),
                                Expanded(
                                  flex:3,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Align(
                                    alignment: AlignmentDirectional.topStart,
                                    child: ExpandableText( workList[index][s.key_work_id] .toString(),trimLines: 2),
                                ),
                                ),
                                ),
                              ],),
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Expanded(
                                  flex:2,
                                  child:Text(
                                  s.work_name,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: c.grey_8),
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  softWrap: true,
                                ),
                                ),
                                Expanded(
                                  flex:0,
                                  child:Text(
                                  ' : ',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: c.grey_8),
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  softWrap: true,
                                ),
                                ),
                                Expanded(
                                  flex:3,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                    child: Align(
                                    alignment: AlignmentDirectional.topStart,
                                    child: ExpandableText( workList[index][s.key_work_name] .toString(),trimLines: 2),
                                ),
                                ),
                                ),
                              ],),
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Expanded(
                                  flex:2,
                                  child:Text(
                                  s.work_type_name,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: c.grey_8),
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  softWrap: true,
                                ),
                                ),
                                Expanded(
                                  flex:0,
                                  child:Text(
                                  ' : ',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: c.grey_8),
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  softWrap: true,
                                ),
                                ),
                                Expanded(
                                  flex:3,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Align(
                                    alignment: AlignmentDirectional.topStart,
                                    child: ExpandableText( workList[index][s.key_work_type_name] .toString(),trimLines: 2),
                                ),
                                ),
                                ),
                              ],),
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Expanded(
                                  flex:2,
                                  child:Text(
                                  s.scheme,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: c.grey_8),
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  softWrap: true,
                                ),
                                ),
                                Expanded(
                                  flex:0,
                                  child:Text(
                                  ' : ',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: c.grey_8),
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  softWrap: true,
                                ),
                                ),
                                Expanded(
                                  flex:3,
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Align(
                                    alignment: AlignmentDirectional.topStart,
                                    child: ExpandableText( workList[index][s.key_scheme_name] .toString(),trimLines: 2),
                                ),
                                ),
                                ),
                              ],),
                              SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex:2,
                                      child:Text(
                                        s.scheme,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: c.grey_8),
                                        overflow: TextOverflow.clip,
                                        maxLines: 1,
                                        softWrap: true,
                                      ),
                                    ),
                                    Expanded(
                                      flex:0,
                                      child:Text(
                                        ' : ',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: c.grey_8),
                                        overflow: TextOverflow.clip,
                                        maxLines: 1,
                                        softWrap: true,
                                      ),
                                    ),
                                    Expanded(
                                      flex:3,
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: Align(
                                          alignment: AlignmentDirectional.topStart,
                                          child: ExpandableText( workList[index]['scheme_name'] .toString(),trimLines: 2),
                                        ),
                                      ),
                                    ),
                                  ],),
                                SizedBox(height: 10,),


                            ],

                            ),
                          ),
                        ]),));
                    },
                  ),
                  ),),
                Visibility(
                  visible: noDataFlag,
                  child: Align(
                    alignment: AlignmentDirectional.center,
                    child:Container(
                      alignment: Alignment.center,
                      child: Text(
                        s.no_village,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                )
              ]),)],),),));

  }

}

