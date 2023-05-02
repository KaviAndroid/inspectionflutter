import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/RdprOnlineWorkListFromFilter.dart';
import 'package:inspection_flutter_app/Layout/ReadMoreLess.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../DataBase/DbHelper.dart';
import '../ModelClass/ModelClass.dart';
import '../Resources/ColorsValue.dart';
import '../Resources/ImagePath.dart';
import '../Resources/Strings.dart';
import '../Resources/global.dart';
import '../Utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class Work_detailed_ViewScreen extends StatefulWidget {
  @override
  final workList;
  final Flag;
  final flag;
  final selectedRDPRworkList;

  Work_detailed_ViewScreen({this.selectedRDPRworkList, this.workList, this.Flag, this.flag});
  State<Work_detailed_ViewScreen> createState() => Work_detailed_ViewScreenState();
}
class Work_detailed_ViewScreenState extends State<Work_detailed_ViewScreen> {
  var appBarvisibility = true;
  bool isWorklistAvailable = false;
  late SharedPreferences prefs;
  Utils utils = Utils();
  bool noDataFlag = false;
  bool imageListFlag = false;
  List workList = [];
  List ImageList = [];
  List<Map<String, String>> img_jsonArray = [];
  List<Map<String, String>> img_jsonArray_val = [];
  String town_type = "T";
  String inspection_id="";
  String work_id="";
  String action_taken_id="";
  String other_work_inspection_id="";
  String type="";
  Uint8List? image;
  @override
  void initState() {
    super.initState();
    if (img_jsonArray.length > 0) {
      noDataFlag = false;
      imageListFlag = true;
    } else {
      noDataFlag = true;
      imageListFlag = false;
    }
    getWorkDetails();
    ;
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
                Padding(
                  padding: EdgeInsets.only(
                    top: 4,
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.center,
                  child: Container(
                    transform: Matrix4.translationValues(80, 2, 15),
                    alignment: Alignment.center,
                    child: Visibility(
                        visible: appBarvisibility,
                        child: Text(
                         "Inspection Taken",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        )),
                  ),
                ),
              ],
            ),
          ),
          /* actions: <Widget>[
            Padding(padding: EdgeInsets.only(top: 8),)
          ],*/
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
              height: 650,
              color: ca1,
              child: Column(
                children: [
                  _WorkList(),
                  Container(
                    child: Text(
                      "Photos",style: TextStyle(
                        fontWeight: FontWeight.bold,fontSize: 15
                    ),
                    ),
                  ),
                  _Photos()
                ],
              )),
        ),
      ),
    );
  }
  _WorkList() {
    return Container(
        color: ca1,
        child: Padding(
          padding: EdgeInsets.only(top: 20,left: 15,right: 15),
         child:Stack(
           children: [
             Visibility(child:Container(
               height: 250,
               child: ListView.builder(
                    itemCount: 1,
                   itemBuilder: (BuildContext context,int index)
            {
              inspection_id=widget.selectedRDPRworkList[index][s.key_inspection_id].toString();
              town_type=widget.selectedRDPRworkList[index][s.key_town_type];
            return InkWell(
            child:Card(
            elevation: 5,
            color: c.white,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomRight: Radius.circular(15),
            ),
            ),
            clipBehavior: Clip.hardEdge,
            child: ClipPath(
            clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20))),
            child: Container(
            child: Container(
            child: Column(children: [
            Container(
            child: Padding(
            padding: EdgeInsets.all(27),
            child: Column(children: [
            Row(
            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
            Expanded(
            flex: 1,
            child: Text(
            s.work_id,
            style: TextStyle(
            fontSize: 15,
            fontWeight:
            FontWeight.normal,
            color: c.black),
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
            FontWeight.normal,
            color: c.black),
            overflow:
            TextOverflow.clip,
            maxLines: 1,
            softWrap: true,
            ),
            ),
            Expanded(
            flex: 1,
            child: Text(
                work_id=widget.selectedRDPRworkList[index][s.key_work_id].toString(),
            style: TextStyle(
            color: c.black),
            maxLines: 1),
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
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      s.status,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.normal,
                          color: c.black),
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
                          FontWeight.normal,
                          color: c.black),
                      overflow:
                      TextOverflow.clip,
                      maxLines: 1,
                      softWrap: true,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(widget.selectedRDPRworkList[index][s.key_status_name].toString(),
                        style: TextStyle(
                            color: c.black),
                        maxLines: 1),
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
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      s.work_name,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.bold,
                          color: c.black),
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
                          FontWeight.normal,
                          color: c.black),
                      overflow:
                      TextOverflow.clip,
                      maxLines: 1,
                      softWrap: true,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(widget.selectedRDPRworkList[index][s.key_work_name],
                        style: TextStyle(
                            color: c.black),
                        maxLines: 4),
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
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      s.description,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.bold,
                          color: c.black),
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
                          FontWeight.normal,
                          color: c.black),
                      overflow:
                      TextOverflow.clip,
                      maxLines: 1,
                      softWrap: true,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(widget.selectedRDPRworkList[index][s.key_description],
                        style: TextStyle(
                          fontSize: 15,
                            color: c.black),
                        maxLines: 1),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
            )
            )
            )
            ]
            )
            ))
            )
            ));
            }
        )
    )
    )
    ])));
  }
  _Photos() {
    return Container(
        color: ca1,
        child: Padding(
        padding: EdgeInsets.only(top: 10,left: 20,right: 15),
    child:Stack(
    children: [
    Visibility(child:Container(
  height: 300,
  child: ListView.builder(
  itemCount: 1,
  itemBuilder: (BuildContext context,int index)
    {
    return InkWell(
    child:Card(
    elevation: 5,
    color: c.white,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(15),
    topLeft: Radius.circular(15),
    topRight: Radius.circular(15),
    bottomRight: Radius.circular(15),
    ),
    ),
    clipBehavior: Clip.hardEdge,
    child: ClipPath(
    clipper: ShapeBorderClipper(
    shape: RoundedRectangleBorder(
    borderRadius:
    BorderRadius.circular(20))),
    child: Container(
    child: Container(
    child: Column(children: [
    Container(
    child: Padding(
    padding: EdgeInsets.all(10),
    child: Column(children: [
    Row(
    mainAxisAlignment:
    MainAxisAlignment
        .spaceBetween,
    crossAxisAlignment:
    CrossAxisAlignment.start,
    children: [
      Expanded(  child: image != null
          ? Image.memory(
        base64.decode(image.toString()),
        width: screenWidth,
        height: screenWidth * 0.3,
        fit: BoxFit.fitWidth,
      )
          : Image.asset(
        imagePath.bg_curve,
        width: screenWidth,
        height: screenWidth * 0.3,
        fit: BoxFit.fill,
      ),
      )
      /*Expanded(
        child: InkWell(
          child: img_jsonArray[index]['image'] == '0'
              ? Container(
            width: 80,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
                bottomLeft:
                const Radius.circular(0),
                bottomRight:
                const Radius.circular(0),
              ),
              border: Border.all(
                  color: c.grey, width: 0.2),
            ),
          )
              : Container(
            width: 80,
            height: 50,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: MemoryImage(Base64Decoder()
                    .convert(img_jsonArray[index]
                ['image']!)),
              ),
            ),
          ),
        ),
      )*/
    ],
    ),
    SizedBox(
    height: 10,
    ),
    ]
    )
    )
    )
    ]))))));
    }
    )))])));
  }
  Future<void> getWorkDetails() async {
    prefs = await SharedPreferences.getInstance();
    late Map json_request;
    prefs.getString(s.key_rural_urban);
    print("Workid>>>>"+work_id);
    print("inspection>>>>"+inspection_id);
    print("towntype>>>>>"+town_type);
    if(type=="atr")
      {
        json_request = {
          s.key_service_id: s.service_key_date_wise_inspection_details_view,
          s.key_action_taken_id:s.service_key_work_id_wise_inspection_details_view
        };
      }
    else
    {
      json_request = {
        s.key_service_id: s.service_key_work_id_wise_inspection_details_view,
        s.key_inspection_id:inspection_id,
        s.key_work_id:work_id,
        s.key_rural_urban:prefs.getString(s.key_rural_urban),
      };
    }
    if (s.key_rural_urban=="U") {
      Map urbanRequest = {s.key_town_type:town_type};
      json_request.addAll(urbanRequest);
    }
    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
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
    var decrypt_data = utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
    var userData = jsonDecode(decrypt_data);
    var status = userData[s.key_status];
    var response_value = userData[s.key_response];
    if (status == s.key_ok && response_value == s.key_ok) {
      List<dynamic> res_jsonArray = userData[s.key_json_data];
      if (res_jsonArray.length > 0) {
        for (int i = 0; i < res_jsonArray.length; i++) {
          String res_image = res_jsonArray[i][s.key_image];
          if (!(res_image == ("null") || res_image == (""))) {
            image = Base64Codec().decode(res_image);
          }
        }
      }
      /*// Map<String,dynamic> res_jsonArray=userData[s.key_json_data];
      List<dynamic> res_jsonArray=userData[s.key_json_data];
      print("res_jsonArray>>>>"+res_jsonArray.toString());
      img_jsonArray.add(userData[s.key_inspection_image]);
      print("image>>>>"+img_jsonArray.toString());*/
    }
    else if (status == s.key_ok && response_value == s.key_noRecord) {
      setState(() {

      });
    }
  }
}