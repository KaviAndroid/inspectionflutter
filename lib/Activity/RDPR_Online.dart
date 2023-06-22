import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/Delayed_Work_Filter_Screen.dart';
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

import 'RdprOnlineWorkListFromGeoLocation.dart';

class RDPR_Online extends StatefulWidget {
  @override
  State<RDPR_Online> createState() => _RDPR_OnlineState();
}

class _RDPR_OnlineState extends State<RDPR_Online> {
  TextEditingController distance = TextEditingController();

  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  var location = loc.Location();

  @override
  void initState() {
    super.initState();
    distance = TextEditingController(text: "20");
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    setState(() {});
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
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
/*               InkWell(
                child: Image.asset(
                  imagePath.back,
                  fit: BoxFit.contain,
                  color: c.white,
                  height: 20,
                  width: 20,
                ),
                onTap: (){
                  Navigator.pop(context);
                  // utils.gotoHomePage(context, "s");
                },
              ),*/
                Align(
                  alignment: AlignmentDirectional.center,
                  child: Container(
                    transform: Matrix4.translationValues(-30.0, 0.0, 0.0),
                    alignment: Alignment.center,
                    child: Text(
                      s.get_village_list,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
            color: c.white,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      if (distance.text != null && distance.text != "") {
                        getLocation();
                      } else {
                        utils.showAlert(context, s.enter_distance_in_km);
                      }
                    },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      padding: EdgeInsets.all(9.0),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: c.yello,
                                          border: Border.all(
                                              color: c.grey, width: 1.4)),
                                      child: Image.asset(
                                        imagePath.location,
                                        fit: BoxFit.contain,
                                        height: 50,
                                        width: 50,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Container(
                                            alignment:
                                                AlignmentDirectional.bottomEnd,
                                            height: 30,
                                            width: 50,
                                            decoration: new BoxDecoration(
                                                color: c.bg,
                                                border: Border.all(
                                                    color: c.grey, width: 2),
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
                                            margin: EdgeInsets.fromLTRB(
                                                20, 0, 5, 0),
                                            child: TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.black),
                                              controller: distance,
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.zero,
                                                isDense: true,
                                                hintText:
                                                    s.enter_distance_in_km,
                                                hintStyle: TextStyle(
                                                    fontSize: 11.0,
                                                    color: c.grey_6),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            alignment:
                                                AlignmentDirectional.bottomEnd,
                                            height: 30,
                                            child: Text(
                                              "Km",
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: c.grey_7),
                                            ),
                                          ),
                                        ]),
                                  ),
                                )
                              ]),
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 5, 20, 20),
                            child: Text(
                              s.click_here_to_get_villages,
                              style: TextStyle(
                                  color: c.grey_7,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                        ]),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RdprOnlineWorkList()));
                    },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              padding: EdgeInsets.all(1.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: c.yello,
                                  border:
                                      Border.all(color: c.grey, width: 1.4)),
                              child: Image.asset(
                                imagePath.choice,
                                fit: BoxFit.contain,
                                height: 70,
                                width: 70,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 5, 20, 20),
                            child: Text(
                              s.click_here_to_get_villages_through_selection,
                              style: TextStyle(
                                  color: c.grey_7,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                        ]),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DelayedWorkFilterScreen()));
                    },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              padding: EdgeInsets.all(1.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: c.grey, width: 1.4)),
                              child: Image.asset(
                                imagePath.delay_works,
                                fit: BoxFit.contain,
                                height: 70,
                                width: 70,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 5, 20, 20),
                            child: Text(
                              s.delay_work_in_block,
                              style: TextStyle(
                                  color: c.grey_7,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                        ]),
                  )
                ])),
      ),
    );
  }

  Future<void> getLocation() async {
    final hasPermission = await utils.handleLocationPermission(context);

    if (!hasPermission) return;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("latitude>>" + position.latitude.toString());
    print("longitude>>" + position.longitude.toString());
    if (await utils.isOnline()) {
      getVillageListOfLocation(
          position.latitude.toString(), position.longitude.toString());
    } else {
      utils.customAlert(context, "E", s.no_internet);
    }
  }

  Future<void> getVillageListOfLocation(
      String latitude, String longitude) async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    utils.showProgress(context, 1);
    late Map json_request;

    json_request = {
      s.key_service_id: s.service_key_get_calculate_distance,
      s.key_latitude: latitude,
      s.key_longitude: longitude,
      s.key_distance: distance.text,
    };

    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
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
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service_jwt,
        body: jsonEncode(encrypted_request), headers: header);

    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    print("VillageListOfLocation_url>>" + url.main_service_jwt.toString());
    print("VillageListOfLocation_request_json>>" + json_request.toString());
    print("VillageListOfLocation_request_encrpt>>" +
        encrypted_request.toString());
    utils.hideProgress(context);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("VillageListOfLocation_response>>" + data);
      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("VillageListOfLocation Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("VillageListOfLocation responceSignature -  $responceSignature");

      print("VillageListOfLocation responceData -  $responceData");

      if (responceSignature == responceData) {
        print("VillageListOfLocation responceSignature - Token Verified");
        var userData = jsonDecode(data);
        var status = userData[s.key_status];
        var response_value = userData[s.key_response];
        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          res_jsonArray.sort((a, b) {
            return a[s.key_pvname].compareTo(b[s.key_pvname]);
          });
          if (res_jsonArray.length > 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VillageListFromGeoLocation(
                          villageList: userData[s.key_json_data],
                        )));
          } else {
            utils.showAlert(context, s.no_village);
          }
        } else {
          utils.showAlert(context, s.no_village);
        }
      } else {
        print("VillageListOfLocation responceSignature - Token Not Verified");
        utils.customAlert(context, "E", s.jsonError);
      }
    }
  }
}
