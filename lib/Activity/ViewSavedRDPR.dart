import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/RdprOnlineWorkListFromFilter.dart';
import 'package:inspection_flutter_app/Layout/ReadMoreLess.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../DataBase/DbHelper.dart';
import '../ModelClass/ModelClass.dart';
import '../Resources/global.dart';
import '../Utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Home.dart';
import 'RdprOnlineWorkListFromGeoLocation.dart';
import 'SaveWorkDetails.dart';
class ViewSavedRDPR extends StatefulWidget {
  @override
  final workList;
  ViewSavedRDPR({this.workList});
  State<ViewSavedRDPR> createState() => _ViewSavedRDPRState();
}
class _ViewSavedRDPRState extends State<ViewSavedRDPR> {
  List<DateTime>? selectedDateRange;
  List workList = [];
  List selectedworkList = [];
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  String WorkId="";
  String inspectionID="";
  String pdf_string_actual ="";
  String fromDate = "";
  String toDate = "";
  String work_id = "";

  // Controller Text
  TextEditingController dateController = TextEditingController();
  TextEditingController workid = TextEditingController();

  @override
  void initState() {
    super.initState();
    initialize();
  }
  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    // getWorkDetails();
    setState(() {
      // getWorkDetails();
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
        child: Scaffold(
        appBar: AppBar(
          backgroundColor: c.colorPrimary,
          centerTitle: true,
          elevation: 2,
          automaticallyImplyLeading: true,
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.only(top: 4,),
                ),
                Align(
                  alignment: AlignmentDirectional.center,
                  child: Container(
                    transform: Matrix4.translationValues(80, 2, 15),
                    alignment: Alignment.center,
                    child: Text(
                      s.work_list,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Padding(padding: EdgeInsets.only(top: 8),
              child: IconButton(
                icon: Icon(Icons.search, color: c.black, size: 25,),
                onPressed: () {},
              ),)
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            child: Column(
              children: [
                _DatePicker(),
                _Workid(),
                _WorkList()
              ],
            ),
          ),
        )),);
  }

  _DatePicker() {
    return Container(
      height: 100,
      child: Container(
        child: Padding(
          padding: EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 25),
          child: TextField(
              controller: dateController,
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixIconConstraints: BoxConstraints(
                    minHeight: 30,
                    minWidth: 20
                ),
                contentPadding: EdgeInsets.only(left: 25, right: 5, top: 15),
                filled: true,
                fillColor: c.grey_2,
                suffixIcon: Padding(
                  padding: EdgeInsets.all(10),
                  child: Image.asset(
                    imagePath.date_picker_icon, height: 30, width: 30,),
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
                selectDateFunc();
              }
          ),),
      ),
    );
  }

  _Workid() {
    return Container(
        height: 90,
        child: Container(
            child: Padding(padding: EdgeInsets.all(15),
              child: InkWell(
                onTap: ()
                async {
                if(await utils.isOnline())
                  {
                  workid.text=work_id;
                  }
                },
                child: TextField(
                  controller: workid,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Work id",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    filled: true,
                    fillColor: c.grey_2,
                    suffixIcon: Material(
                      elevation: 5.0,
                      color: c.dot_dark_screen5,
                      shadowColor: c.dot_dark_screen5,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                     child:InkWell(
                       onTap: ()
                       {
                          if(workid.text.isNotEmpty)
                            {
                              getWorkDetails();
                            }
                          else
                            {
                              utils.showAlert(context, "Please enter a Work Id");
                            }
                       },
                       child: Icon(
                         Icons.arrow_forward_ios, color: c.white, size: 22,),
                     )
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
                ),
              ),)
        )
    );
  }

  _WorkList() {
    return SingleChildScrollView(
      child: Container(
        height: 550,
          color: c.ca,
          child: Stack(children: [
            Visibility(
              child: Container(
                  margin: EdgeInsets.fromLTRB(12, 20, 10, 5),
                  child:ListView.builder(
                    itemCount:workList == null ? 0 : workList.length,
                    itemBuilder: (BuildContext context,int index)
                    {
                      return InkWell(
                        onTap: (){
                          selectedworkList.clear();
                          selectedworkList.add(workList[index]);
                          print('selectedworkList>>'+selectedworkList.toString());
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SaveWorkDetails(
                                    selectedworkList: selectedworkList,
                                  )));
                        },
                        child:  Card(
                            elevation: 5,
                            color: c.colorAccentlight,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            ),

                            clipBehavior: Clip.hardEdge,
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: ClipPath(
                              clipper: ShapeBorderClipper(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              child: Container(
                                  child: Container(
                                    child: Column(
                                        children: [
                                          Column(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  getWorkReportDetails(WorkId,inspectionID);
                                                },
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                    padding: EdgeInsets.fromLTRB(
                                                        20, 5, 5, 0),
                                                    child: Image.asset(
                                                      imagePath.pdf_icon,
                                                      height: 30,
                                                      width: 30,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                             /* Row(
                                                children: [
                                                  Expanded(child: Align(
                                                    alignment: AlignmentDirectional
                                                        .topStart,
                                                    child: Container(
                                                      height: 42,
                                                      width: 42,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .only(
                                                          bottomRight: Radius
                                                              .circular(50),
                                                          topLeft: Radius
                                                              .circular(20),
                                                        ),
                                                        color: c.white,
                                                      ),
                                                    ),
                                                  ),),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 5),
                                                    child: Align(
                                                        alignment: Alignment
                                                            .topRight,
                                                        child: Container(
                                                          child: Image.asset(
                                                            imagePath.pdf_icon,
                                                            height: 35,
                                                            width: 30,
                                                          ),
                                                        )
                                                    ),)
                                                ],
                                              ),*/
                                            ],
                                          ),
                                          Container(
                                            child: Padding(
                                                padding: EdgeInsets.only(top: 5,
                                                    bottom: 0,
                                                    left: 10,
                                                    right: 0),
                                                child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                              s.work_id,
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                                  color: c
                                                                      .white),
                                                              overflow:
                                                              TextOverflow.clip,
                                                              maxLines: 1,
                                                              softWrap: true,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 0,
                                                            child: Text(
                                                              ':',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                                  color: c
                                                                      .white),
                                                              overflow:
                                                              TextOverflow.clip,
                                                              maxLines: 1,
                                                              softWrap: true,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child:Text(workList[index][s.key_work_id].toString(),style: TextStyle(color: c.white),maxLines: 1),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                              s.work_name,
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                                  color: c
                                                                      .white),
                                                              overflow:
                                                              TextOverflow.clip,
                                                              maxLines: 1,
                                                              softWrap: true,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 0,
                                                            child: Text(
                                                              ':',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                                  color: c
                                                                      .white),
                                                              overflow:
                                                              TextOverflow.clip,
                                                              maxLines: 1,
                                                              softWrap: true,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child:Text(
                                                                workList[index][s
                                                                    .key_work_name]
                                                                    .toString(),style: TextStyle(color: c.white),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                              s.inspected_date,
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                                  color: c
                                                                      .white),
                                                              overflow:
                                                              TextOverflow.clip,
                                                              maxLines: 1,
                                                              softWrap: true,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 0,
                                                            child: Text(
                                                              ':',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                                  color: c
                                                                      .white),
                                                              overflow:
                                                              TextOverflow.clip,
                                                              maxLines: 1,
                                                              softWrap: true,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child:Text(
                                                              workList[index][s
                                                                  .key_inspection_date]
                                                                  .toString(),style: TextStyle(color: c.white),maxLines: 2,
                                                            ),),

                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                              s.work_status,
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                                  color: c
                                                                      .white),
                                                              overflow:
                                                              TextOverflow.clip,
                                                              maxLines: 1,
                                                              softWrap: true,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 0,
                                                            child: Text(
                                                              ':',
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                                  color: c
                                                                      .white),
                                                              overflow:
                                                              TextOverflow.clip,
                                                              maxLines: 1,
                                                              softWrap: true,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child:Text(
                                                                workList[index][s
                                                                    .key_status_name]
                                                                    .toString(),maxLines: 2,
                                                               style: TextStyle(color: c.white),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Column(children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              flex: 1,
                                                              child: Align(
                                                                alignment: AlignmentDirectional
                                                                    .bottomEnd,
                                                                child: Container(
                                                                  height: 45,
                                                                  width: 45,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius
                                                                        .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                          70),
                                                                      bottomRight: Radius
                                                                          .circular(
                                                                          20),
                                                                    ),
                                                                    color: c
                                                                        .white,
                                                                  ),
                                                                  child: Container(
                                                                    child: Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                          top: 15,
                                                                          left: 16,
                                                                          right: 5,
                                                                          bottom: 10),
                                                                      child: Image
                                                                          .asset(
                                                                          imagePath
                                                                              .edit_icon),),
                                                                    height: 25,
                                                                    width: 25,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],)
                                                    ]
                                                )),),
                                        ]),
                                  )
                              ),
                            )
                        ),
                      );
                    },
                  )
              ),
            )
          ])
      ),
    );
  }

  Future<void> dateValidation() async {
    if (selectedDateRange != null) {
      DateTime sD = selectedDateRange![0];
      DateTime eD = selectedDateRange![1];
      String startDate = DateFormat('dd-MM-yyyy').format(sD);
      print("Start_date" + startDate);
      String endDate = DateFormat('dd-MM-yyyy').format(eD);
      print("End_date" + endDate);
      fromDate = startDate;
      toDate = endDate;
      print("Startdate>>>>>" + fromDate);
      print("Todate>>>>>" + toDate);
      if (startDate.compareTo(endDate) > 0) {
        dateController.text = s.select_from_to_date;
      } else {
        dateController.text = "$startDate  To  $endDate";
      }
      print("Startdate>>>>>" + fromDate);
      print("Todate>>>>>" + toDate);
      getWorkDetails();
    }
  }

  Future<void> selectDateFunc() async {
    selectedDateRange = await showOmniDateTimeRangePicker(
      context: context,
      type: OmniDateTimePickerType.date,
      startInitialDate: DateTime.now(),
      startFirstDate: DateTime(2000).subtract(const Duration(days: 3652)),
      startLastDate: DateTime.now().add(
        const Duration(days: 3652),
      ),
      endInitialDate: DateTime.now(),
      endFirstDate: DateTime(2000).subtract(const Duration(days: 3652)),
      endLastDate: DateTime.now().add(
        const Duration(days: 3652),
      ),
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0,
              end: 1,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
    );
    dateValidation();
  }

  Future<void> getWorkDetails() async {
    prefs = await SharedPreferences.getInstance();
    late Map json_request;
    json_request = {
      s.key_service_id: s.service_key_date_wise_inspection_details_view,
      s.key_area_type: prefs.getString(s.area_type),
    };
    work_id=workid.text.toString();
    if(work_id.isEmpty!)
      {
        json_request = {
          s.key_work_id:work_id
        };
      }
   if(dateController.text.toString().isNotEmpty)
     {
       json_request = {
         s.key_from_date:fromDate,
         s.key_to_date:toDate,
       };
     }
    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: utils.encryption(
          jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(
        url.main_service, body: json.encode(encrypted_request));
    print("WorkList_url>>" + url.main_service.toString());
    print("WorkList_request_json>>" + json_request.toString());
    print("WorkList_request_encrpt>>" + encrypted_request.toString());
    String data = response.body;
    print("WorkList_response>>" + data);
    var jsonData = jsonDecode(data);
    var enc_data = jsonData[s.key_enc_data];
    var decrpt_data = utils.decryption(
        enc_data, prefs.getString(s.userPassKey).toString());
    var userData = jsonDecode(decrpt_data);
    var status = userData[s.key_status];
    var response_value = userData[s.key_response];
    if (status == s.key_ok && response_value == s.key_ok) {
      Map res_jsonArray = userData[s.key_json_data];
      List<dynamic> RdprWorkList = res_jsonArray[s.key_inspection_details];
      if (RdprWorkList.length > 0) {
        workList=[];
        RdprWorkList.sort((a,b)
        {
          return a[s.key_work_id].compareTo(b[s.key_work_id]);
        });
        workList.addAll(RdprWorkList);
        print("WORKLIST"+workList.toString());
      }
    }
    setState(() {
      _WorkList();
    });
  }
  Future<void> getWorkReportDetails(String work_id,String inspection_id) async{
    WorkId=work_id;
    inspectionID=inspection_id;
    prefs = await SharedPreferences.getInstance();
    late Map json_request;
    json_request = {
      s.key_service_id: s.service_key_get_pdf,
      s.key_work_id: work_id,
      s.key_inspection_id:inspection_id
    };
    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: utils.encryption(
          jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(
        url.main_service, body: json.encode(encrypted_request));
    print("pdf_url>>" + url.main_service.toString());
    print("pdf_request_json>>" + json_request.toString());
    print("pdf_request_encrpt>>" + encrypted_request.toString());
    String data = response.body;
    print("pdf_response>>" + data);
    var jsonData = jsonDecode(data);
    var enc_data = jsonData[s.key_enc_data];
    var decrpt_data = utils.decryption(
        enc_data, prefs.getString(s.userPassKey).toString());
    var userData = jsonDecode(decrpt_data);
    var status = userData[s.key_status];
    var response_value = userData[s.key_response];
    if (status == s.key_ok && response_value == s.key_ok) {
        Map res_jsonArray = userData[s.key_json_data];
        String pdf_string="";
        pdf_string=jsonData.getString("pdf_string");
        pdf_string_actual=pdf_string;
        }
    else
      {
        utils.showAlert(context, jsonData.getString("RESPONSE"));
      }
      }
    }






