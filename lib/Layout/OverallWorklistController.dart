// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings, avoid_print, file_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'dart:convert';
import 'package:inspection/Resources/Strings.dart' as s;
import 'package:inspection/Resources/url.dart' as url;
import 'package:shared_preferences/shared_preferences.dart';
import '../DataBase/DbHelper.dart';
import '../Utils/utils.dart';

class OverallWorklistController extends ChangeNotifier {
  //API CALL List Dynamic
  List<dynamic>? workDetails;
  List<dynamic>? pieChartDetails;

  DateTime? selectedDate;

  //DB CALL List
  List districtworkList = [];
  List villageworkList = [];
  List blockworkList = [];
  List TMCworkList = [];
  Iterable filteredVillage = [];

  //bool Flag

  bool TMCTableUI = false;
  bool districtTableUI = false;
  bool BlockTableUI = false;
  bool villageTableUI = false;
  bool pieChartUI = false;
  bool searchEnabled = false;

  //String Vlues
  String headerName = "";
  String? sCount;
  String? usCount;
  String? nimpCount;
  String? atrCount;
  String? totalWorksCount;
  String _searchQuery = '';

  //date
  String? districtFromDate;
  String? districtToDate;
  String? blockFromDate;
  String? blockToDate;
  String? urbanDistrictFromDate;
  String? urbanDistrictToDate;
  String? tmcFromDate;
  String? tmcToDate;

  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;

  // *************************** Search  Functions Starts here *************************** //

  onSearchQueryChanged(String query, String tmcType) {
    String compareVilageName = "";
    if (prefs.getString(s.key_rural_urban) == "U") {
      if (tmcType == "T") {
        compareVilageName = s.key_townpanchayat_name;
      } else if (tmcType == "M") {
        compareVilageName = s.key_municipality_name;
      } else if (tmcType == "C") {
        compareVilageName = s.key_corporation_name;
      }
    } else {
      compareVilageName = s.key_pvname;
    }
    searchEnabled = true;
    _searchQuery = query;
    filteredVillage = villageworkList.where((item) {
      final name = item[compareVilageName].toLowerCase();
      final lowerCaseQuery = _searchQuery.toLowerCase();
      return name.contains(lowerCaseQuery);
    });
    notifyListeners();
  }

  Future<void> initializeDB() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;

    notifyListeners();
  }

  List<dynamic> retriveWorklist() {
    return workDetails ?? [];
  }

  List<dynamic> retrivepieChartDetails() {
    return pieChartDetails ?? [];
  }

  Future<void> setFirstDate(DateTime date) async {
    selectedDate = date;
    notifyListeners();
  }

  __ModifiyUI(String flag, String fromDate, String toDate) {
    if (workDetails!.isNotEmpty) {
      if (prefs.getString(s.key_rural_urban) == "R") {
        workDetails!.sort((a, b) {
          // Sorting in ascending order based on name field
          return a[s.key_dname].compareTo(b[s.key_dname]);
        });
        if (flag == "D") {
          districtFromDate = fromDate;
          districtToDate = toDate;
          districtworkList.clear();
          districtworkList.addAll(workDetails!);

          districtworkList.sort((a, b) {
            String nameA = a[s.key_dname].toString().toLowerCase();
            String nameB = b[s.key_dname].toString().toLowerCase();
            return nameA.compareTo(nameB);
          });
          districtTableUI = true;
          villageTableUI = false;
          BlockTableUI = false;
        } else if (flag == "B") {
          blockFromDate = fromDate;
          blockToDate = toDate;
          blockworkList.clear();
          blockworkList.addAll(workDetails!);

          blockworkList.sort((a, b) {
            String nameA = a[s.key_bname].toString().toLowerCase();
            String nameB = b[s.key_bname].toString().toLowerCase();
            return nameA.compareTo(nameB);
          });
          districtTableUI = false;
          BlockTableUI = true;
          villageTableUI = false;
        } else if (flag == "V") {
          villageworkList.clear();
          villageworkList.addAll(workDetails!);

          villageworkList.sort((a, b) {
            String nameA = a[s.key_pvname].toString().toLowerCase();
            String nameB = b[s.key_pvname].toString().toLowerCase();
            return nameA.compareTo(nameB);
          });
          districtTableUI = false;
          villageTableUI = true;
          BlockTableUI = false;
        }
      } else if (prefs.getString(s.key_rural_urban) == "U") {
        if (flag == "D") {
          urbanDistrictFromDate = fromDate;
          urbanDistrictToDate = toDate;
          districtworkList.clear();
          districtworkList.addAll(workDetails!);

          districtworkList.sort((a, b) {
            String nameA = a[s.key_dname].toString().toLowerCase();
            String nameB = b[s.key_dname].toString().toLowerCase();
            return nameA.compareTo(nameB);
          });
          districtTableUI = true;
          villageTableUI = false;
          BlockTableUI = false;
          TMCTableUI = false;
        } else if (flag == "tmc") {
          tmcFromDate = fromDate;
          tmcToDate = toDate;
          TMCworkList.clear();
          TMCworkList.addAll(workDetails!);

          TMCTableUI = true;
          districtTableUI = false;
          villageTableUI = false;
          BlockTableUI = false;
        } else if (flag == "T") {
          villageworkList.clear();
          villageworkList.addAll(workDetails!);

          villageworkList.sort((a, b) {
            String nameA = a[s.key_townpanchayat_name].toString().toLowerCase();
            String nameB = b[s.key_townpanchayat_name].toString().toLowerCase();
            return nameA.compareTo(nameB);
          });
          TMCTableUI = false;
          districtTableUI = false;
          villageTableUI = true;
          BlockTableUI = false;
        } else if (flag == "M") {
          villageworkList.clear();
          villageworkList.addAll(workDetails!);

          villageworkList.sort((a, b) {
            String nameA = a[s.key_municipality_name].toString().toLowerCase();
            String nameB = b[s.key_municipality_name].toString().toLowerCase();
            return nameA.compareTo(nameB);
          });

          TMCTableUI = false;
          districtTableUI = false;
          villageTableUI = true;
          BlockTableUI = false;
        } else if (flag == "C") {
          villageworkList.clear();
          villageworkList.addAll(workDetails!);

          villageworkList.sort((a, b) {
            String nameA = a[s.key_corporation_name].toString().toLowerCase();
            String nameB = b[s.key_corporation_name].toString().toLowerCase();
            return nameA.compareTo(nameB);
          });

          TMCTableUI = false;
          districtTableUI = false;
          villageTableUI = true;
          BlockTableUI = false;
        }
      }
      notifyListeners();
    }
  }

  /*
  *******************************  API CALL Starts Here *********************************
  */

  Future<void> fetchOnlineOverallWroklist(String fromDate, String toDate,
      String flag, BuildContext context, String dcode, String bcode) async {
    try {
      utils.showProgress(context, 1);
      await initializeDB();

      String? key = prefs.getString(s.userPassKey);
      String? userName = prefs.getString(s.key_user_name);

      var rural_urban = prefs.getString(s.key_rural_urban);

      Map jsonRequest = {
        s.key_service_id: s.service_key_overall_report,
        s.key_from_date: fromDate,
        s.key_to_date: toDate,
        s.key_flag: flag,
        s.key_rural_urban: rural_urban,
        if (flag != "D") s.key_dcode: dcode,
        if (flag == "V") s.key_bcode: bcode
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
            workDetails = res_jsonArray[s.key_level_wise_report];
            pieChartDetails = res_jsonArray[s.key_status_wise_count];

            // Sum the atr_pending_count values using fold
            int sumAtrPendingCount = 0;
            for (var report in workDetails!) {
              var atrCount = report['atr_pending_count'].toString();
              int? parsedCount = int.tryParse(atrCount);
              if (parsedCount != null) {
                sumAtrPendingCount += parsedCount;
              }
            }

            sCount = pieChartDetails![0]['satisfied'].toString();
            usCount = pieChartDetails![0]['unsatisfied'].toString();
            nimpCount = pieChartDetails![0]['need_improvement'].toString();
            totalWorksCount = pieChartDetails![0]['totalcount'].toString();
            atrCount = sumAtrPendingCount.toString();

            if (int.parse(totalWorksCount!) > 0) {
              pieChartUI = true;
              notifyListeners();
            }

            __ModifiyUI(flag, fromDate, toDate);

            notifyListeners();
          } else if (status == s.key_ok && response_value == s.key_noRecord) {
            utils.customAlertWidet(context, "Error", s.no_data);
          }
        } else {
          pieChartUI=false;
          print("OverallWroklist responceSignature - Token Not Verified");
          utils.customAlertWidet(context, "Error", s.jsonError);
        }
      }
    } catch (e) {
      if (e is FormatException) {
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
      print(e);
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
