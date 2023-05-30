// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings, avoid_print, file_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'dart:convert';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/global.dart' as global;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:shared_preferences/shared_preferences.dart';
import '../DataBase/DbHelper.dart';
import '../Utils/utils.dart';

class OverallWorklistController extends ChangeNotifier {
  //API CALL List Dynamic
  List<dynamic>? workDetails;

  //DB CALL List
  List districtworkList = [];
  List villageworkList = [];
  List blockworkList = [];
  List TMCworkList = [];

  //String Vlues
  String headerName = "";

  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  /*
  *******************************  Constructor *********************************
  */

  Future<void> initializeDB() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;

    notifyListeners();
  }

  List<dynamic> retriveWorklist() {
    return workDetails ?? [];
  }

  /*
  *******************************  Database CALL Starts Here *********************************
  */

  Future<void> fetchDistrictWorklist(BuildContext context) async {
    utils.showProgress(context, 1);
    await initializeDB();
    try {
      List<Map> districtList =
          await dbClient.rawQuery('SELECT * FROM ' + s.table_District);

      print(" District List All >>> $districtList");

      if (districtList.isNotEmpty) {
        //Empty the Worklist
        districtworkList = [];

        districtworkList.addAll(districtList);

        districtworkList.sort((a, b) {
          String nameA = a[s.key_dname].toString().toLowerCase();
          String nameB = b[s.key_dname].toString().toLowerCase();
          return nameA.compareTo(nameB);
        });

        notifyListeners();
      }
    } catch (e) {
      if (e is FormatException) {
        utils.customAlert(context, "E", s.jsonError);
      }
    }
    utils.hideProgress(context);
  }

  Future<void> fetchBlockWorklist(
      BuildContext context, String level, String selectedDcode) async {
    utils.showProgress(context, 1);
    await initializeDB();

    try {
      String? d_code = "";

      level == "S"
          ? d_code = selectedDcode
          : d_code = prefs.getString(s.key_dcode).toString();

      List<Map> blockList = await dbClient
          .rawQuery("SELECT * FROM ${s.table_Block} where dcode = $d_code");

      print(" Block List All >>> $blockList");

      if (blockList.isNotEmpty) {
        //Empty the Worklist
        blockworkList = [];

        blockworkList.addAll(blockList);

        blockworkList.sort((a, b) {
          String nameA = a[s.key_bname].toString().toLowerCase();
          String nameB = b[s.key_bname].toString().toLowerCase();
          return nameA.compareTo(nameB);
        });

        notifyListeners();
      }
    } catch (e) {
      if (e is FormatException) {
        utils.customAlert(context, "E", s.jsonError);
      }
    }
    utils.hideProgress(context);
  }

  Future<void> fetchVillageWorklist(BuildContext context, String level,
      String selectedDcode, String selectedBcode) async {
    utils.showProgress(context, 1);
    await initializeDB();

    try {
      String? d_code = "";
      String? b_code = "";

      if (level == "B") {
        d_code = prefs.getString(s.key_dcode);
        b_code = prefs.getString(s.key_bcode);
      } else if (level == "D") {
        d_code = prefs.getString(s.key_dcode);
        b_code = selectedBcode;
      } else if (level == "S") {
        d_code = selectedDcode;
        b_code = selectedBcode;
      }

      var userPassKey = prefs.getString(s.userPassKey);

      Map jsonRequest = {
        s.key_service_id: s.service_key_village_list_district_block_wise,
        s.key_dcode: d_code,
        s.key_bcode: b_code,
      };

      Map encrpted_request = {
        s.key_user_name: prefs.getString(s.key_user_name),
        s.key_data_content:
            Utils().encryption(jsonEncode(jsonRequest), userPassKey.toString()),
      };

      print(" ENCCCC Request >>> $encrpted_request");

      HttpClient _client = HttpClient(context: await Utils().globalContext);
      _client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => false;
      IOClient _ioClient = IOClient(_client);
      var response = await _ioClient.post(url.master_service,
          body: json.encode(encrpted_request));

      if (response.statusCode == 200) {
        String responseData = response.body;

        var jsonData = jsonDecode(responseData);
        var enc_data = jsonData[s.key_enc_data];
        var decrpt_data = Utils().decryption(enc_data, userPassKey.toString());
        var userData = jsonDecode(decrpt_data);
        var status = userData[s.key_status];
        var response_value = userData[s.key_response];

        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> village_details = userData[s.key_json_data];

          if (village_details.isNotEmpty) {
            //Empty the Worklist
            villageworkList = [];

            village_details.sort((a, b) {
              return a[s.key_pvname].compareTo(b[s.key_pvname]);
            });

            villageworkList.addAll(village_details);
          }
        } else if (status == s.key_ok && response_value == s.key_noRecord) {
          utils.customAlert(context, "W", s.no_data);
        }
      }
    } catch (e) {
      if (e is FormatException) {
        utils.customAlert(context, "E", s.jsonError);
      }
    }
    utils.hideProgress(context);

    notifyListeners();

    /*    
    String? d_code = "";
    String? b_code = "";

    if (level == "B") {
      d_code = prefs.getString(s.key_dcode);
      b_code = prefs.getString(s.key_bcode);
    } else if (level == "D") {
      d_code = prefs.getString(s.key_dcode);
      b_code = selectedBcode;
    } else if (level == "S") {
      d_code = selectedDcode;
      b_code = selectedBcode;
    }

    var villageList = await dbClient.rawQuery(
      "SELECT * FROM ${s.table_Village} where dcode = $d_code and bcode = $b_code",
    );

    print("Village List -  $villageList");

    if (villageList.isNotEmpty) {
      //Empty the Worklist
      villageworkList = [];

      villageworkList.addAll(villageList);

      villageworkList.sort((a, b) {
        String nameA = a[s.key_pvname].toString().toLowerCase();
        String nameB = b[s.key_pvname].toString().toLowerCase();
        return nameA.compareTo(nameB);
      });

      

    }  */
  }

  Future<void> fetchTMCWorklist(BuildContext context, String tmcType) async {
    utils.showProgress(context, 1);
    await initializeDB();

    try {
      String tableName = "";
      String dynamicTMC_Name = "";

      if (tmcType == "T") {
        tableName = s.table_TownList;
        dynamicTMC_Name = s.key_townpanchayat_name;
      } else if (tmcType == "M") {
        tableName = s.table_Municipality;
        dynamicTMC_Name = s.key_municipality_name;
      } else if (tmcType == "C") {
        tableName = s.table_Corporation;
        dynamicTMC_Name = s.key_corporation_name;
      }

      List<Map> TMCList = await dbClient.rawQuery(
          "SELECT * FROM $tableName where dcode = ${prefs.getString(s.key_dcode)}");

      print(" TMC List All >>> $TMCList");

      if (TMCList.isNotEmpty) {
        //Empty the Worklist
        TMCworkList = [];

        TMCworkList.addAll(TMCList);

        TMCworkList.sort((a, b) {
          String nameA = a[dynamicTMC_Name].toString().toLowerCase();
          String nameB = b[dynamicTMC_Name].toString().toLowerCase();
          return nameA.compareTo(nameB);
        });

        notifyListeners();
      }
    } catch (e) {
      if (e is FormatException) {
        utils.customAlert(context, "E", s.jsonError);
      }
    }
    utils.hideProgress(context);
  }

  /*
  *******************************  Database CALL Ends Here *********************************
  */

  /*
  *******************************  API CALL Starts Here *********************************
  */

  Future<void> fetchOnlineOverallWroklist(
      String fromDate, String toDate, BuildContext context) async {
    try {
      utils.showProgress(context, 1);
      await initializeDB();

      String? key = prefs.getString(s.userPassKey);
      String? userName = prefs.getString(s.key_user_name);

      var rural_urban = prefs.getString(s.key_rural_urban);

      Map jsonRequest = {
        s.key_service_id: s.service_key_overall_inspection_details_for_atr,
        s.key_from_date: fromDate,
        s.key_to_date: toDate,
        s.key_rural_urban: rural_urban,
      };

      Map encrypted_request = {
        s.key_user_name: prefs.getString(s.key_user_name),
        s.key_data_content: jsonRequest,
      };

      String jsonString = jsonEncode(encrypted_request);

      String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

      String header_token = utils.jwt_Encode(key, userName!, headerSignature);

      print("OverallWroklist_request_encrpt>>" + jsonEncode(encrypted_request));

      Map<String, String> header = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $header_token"
      };
      HttpClient _client = HttpClient(context: await Utils().globalContext);
      _client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => false;
      IOClient _ioClient = IOClient(_client);
      var response = await _ioClient.post(url.main_service_jwt,
          body: jsonEncode(encrypted_request), headers: header);

      print("OverallWroklist_url>>" + url.main_service_jwt.toString());
      print("OverallWroklist_request_json>>" + jsonRequest.toString());
      print("OverallWroklist_request_encrpt>>" + encrypted_request.toString());

      utils.hideProgress(context);
      if (response.statusCode == 200) {
        String data = response.body;

        print("OverallWroklist_response>>" + data);

        String? authorizationHeader = response.headers['authorization'];

        String? token = authorizationHeader?.split(' ')[1];

        print("OverallWroklist Authorization -  $token");

        String responceSignature = utils.jwt_Decode(key, token!);

        String responceData = utils.generateHmacSha256(data, key, false);

        print("OverallWroklist responceSignature -  $responceSignature");

        print("OverallWroklist responceData -  $responceData");

        if (responceSignature == responceData) {
          print("OverallWroklist responceSignature - Token Verified");
          var userData = jsonDecode(data);
          var status = userData[s.key_status];
          var response_value = userData[s.key_response];

          if (status == s.key_ok && response_value == s.key_ok) {
            workDetails = [];

            Map res_jsonArray = userData[s.key_json_data];
            workDetails = res_jsonArray[s.key_inspection_details];

            global.updateWorkDetails(workDetails!);

            notifyListeners();
          } else if (status == s.key_ok && response_value == s.key_noRecord) {
            utils.customAlert(context, "E", s.no_data);
          }
        } else {
          print("OverallWroklist responceSignature - Token Not Verified");
          utils.customAlert(context, "E", s.jsonError);
        }
      }
    } catch (e) {
      if (e is FormatException) {
        utils.customAlert(context, "E", s.jsonError);
      }
    }
  }

  /*
  *******************************  API CALL OVER *********************************
  */

  PieUpdation(String updName, String flag) {
    String SDBV_name = "";

    if (flag == "D") {
      SDBV_name = "District";
    } else if (flag == "B") {
      SDBV_name = "Block";
    } else if (flag == "V") {
      SDBV_name = "Village";
    } else {
      SDBV_name = "State";
    }

    headerName = "$SDBV_name - $updName";
    notifyListeners();
  }
}
