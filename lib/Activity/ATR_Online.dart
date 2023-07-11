// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:inspection_flutter_app/Activity/ATR_Save.dart';
import 'package:inspection_flutter_app/Activity/Pdf_Viewer.dart';
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Resources/global.dart';
import 'package:inspection_flutter_app/Utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Layout/ReadMoreLess.dart';
import '../Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ATR_Worklist extends StatefulWidget {
  final Flag;
  ATR_Worklist({this.Flag});
  @override
  State<ATR_Worklist> createState() => _ATR_WorklistState();
}

class _ATR_WorklistState extends State<ATR_Worklist> {
  Utils utils = Utils();
  late SharedPreferences prefs;

  //Worklist
  List needImprovementWorkList = [];
  List unSatisfiedWorkList = [];
  List defaultWorklist = [];
  List selectedWorklist = [];

  // Controller Text
  TextEditingController dateController = TextEditingController();

  // Strings
  String totalWorksCount = "0";
  String SDBText = "";
  String npCount = "0";
  String usCount = "0";
  String town_type = "T";

  //BoolVariabless
  bool isNeedImprovementActive = false;
  bool isUnSatisfiedActive = false;
  bool isWorklistAvailable = false;
  bool townActive = true;
  bool munActive = false;
  bool corpActive = false;

  //Date Time
  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  //pdf
  Uint8List? pdf;

  @override
  void initState() {
    dateController.text = ""; //set the initial value of text field
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    await Initial_UI_Design();

    setState(() {});
  }

  Future<void> Initial_UI_Design() async {
    await LoadATRDesign();
  }

  Future<void> LoadATRDesign() async {
    final fromDate = DateTime.now();
    final endDate = fromDate.subtract(const Duration(days: 60));

    String toDate = DateFormat('dd-MM-yyyy').format(fromDate);
    String startDate = DateFormat('dd-MM-yyyy').format(endDate);

    dateController.text = "$startDate to $toDate";
    if (await utils.isOnline()) {
      // API Call
      await fetchOnlineATRWroklist(startDate, toDate);
    } else {
      utils.customAlertWidet(context, "Error", s.no_internet);
    }
    setState(() {
      SDBText = "Block - ${prefs.getString(s.key_bname)}";
    });
  }

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: c.colorPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(context),
          ),
          title: Text(s.work_list),
          centerTitle: true, // like this!
        ),
        body: Container(
            color: c.colorAccentverylight,
            constraints: BoxConstraints(
              minWidth: screenWidth,
              minHeight: sceenHeight - 100.0,
            ),
            child: Stack(
              children: [
                IgnorePointer(
                  ignoring: isSpinnerLoading,
                  child: Column(
                    children: [
                      widget.Flag == "U"
                          ? __Urban_design()
                          : const SizedBox(
                              height: 10,
                            ),
                      __ATR_Dashboard_Design(),
                      __ATR_WorkList_Loader(),
                    ],
                  ),
                ),
                Visibility(
                    visible: isSpinnerLoading,
                    child: Utils().showSpinner(context, "Processing"))
              ],
            )));
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: c.colorPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(context),
          ),
          title: Text(s.work_list),
          centerTitle: true, // like this!
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          color: c.colorAccentverylight,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.Flag == "U"
                    ? __Urban_design()
                    : const SizedBox(
                        height: 10,
                      ),
                __ATR_Dashboard_Design(),
                __ATR_WorkList_Loader(),
              ],
            ),
          ),
        ));
  }

  // *************************** API call Starts here *************************** //

  Future<void> fetchOnlineATRWroklist(String fromDate, String toDate) async {
    utils.showProgress(context, 1);
    setState(() {
      // isSpinnerLoading = true;
      isWorklistAvailable = false;
      isNeedImprovementActive = false;
      isUnSatisfiedActive = false;
    });

    //Empty the Worklist
    defaultWorklist = [];
    unSatisfiedWorkList = [];
    needImprovementWorkList = [];

    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);

    Map jsonRequest = {
      s.key_service_id: s.service_key_get_inspection_details_for_atr,
      s.key_from_date: fromDate,
      s.key_to_date: toDate,
      s.key_rural_urban: widget.Flag,
    };

    if (widget.Flag == "U") {
      Map urbanRequest = {s.key_town_type: town_type};

      jsonRequest.addAll(urbanRequest);
    }

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

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);

    var response = await _ioClient.post(url.main_service_jwt,
        body: jsonEncode(encrypted_request), headers: header);

    utils.hideProgress(context);

    print("Online_Worklist_url>>" + url.main_service_jwt.toString());
    print("Online_Worklist_request_encrpt>>" + encrypted_request.toString());

    if (response.statusCode == 200) {
      String data = response.body;

      print("Online_Worklist_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("Online_Worklist Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("Online_Worklist responceSignature -  $responceSignature");

      print("Online_Worklist responceData -  $responceData");

      if (responceSignature == responceData) {
        print("Online_Worklist responceSignature - Token Verified");

        var userData = jsonDecode(data);

        var status = userData[s.key_status];
        var response_value = userData[s.key_response];

        if (status == s.key_ok && response_value == s.key_ok) {
          Map res_jsonArray = userData[s.key_json_data];
          List<dynamic> inspection_details =
              res_jsonArray[s.key_inspection_details];

          if (inspection_details.isNotEmpty) {
            for (int i = 0; i < inspection_details.length; i++) {
              if (inspection_details[i][s.key_status_id] == 3) {
                needImprovementWorkList.add(inspection_details[i]);
              } else if (inspection_details[i][s.key_status_id] == 2) {
                unSatisfiedWorkList.add(inspection_details[i]);
              }
            }
          }
          totalWorksCount = inspection_details.length.toString();
          usCount = unSatisfiedWorkList.length.toString();
          npCount = needImprovementWorkList.length.toString();
          setState(() {
            if (needImprovementWorkList.isNotEmpty) {
              isNeedImprovementActive = true;
              defaultWorklist = needImprovementWorkList;
            } else if (unSatisfiedWorkList.isNotEmpty) {
              isUnSatisfiedActive = true;
              defaultWorklist = unSatisfiedWorkList;
            } else {
              defaultWorklist = [];
            }
            isWorklistAvailable = true;
            print("WORKLIST >>>>>");
            print(defaultWorklist);
          });
        } else if (status == s.key_ok && response_value == s.key_noRecord) {
          utils.showAlert(context, s.no_data);
          setState(() {
            totalWorksCount = "0";
            npCount = "0";
            usCount = "0";
          });
        }
      } else {
        utils.customAlertWidet(context, "Error", s.jsonError);
        print("Online_Worklist responceSignature - Token Not Verified");
      }
    }
  }

  Future<void> get_PDF(String work_id, String inspection_id) async {
    utils.showProgress(context, 1);

    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);

    Map jsonRequest = {
      s.key_service_id: s.service_key_get_pdf,
      s.key_work_id: work_id,
      s.key_inspection_id: inspection_id,
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

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);

    var response = await _ioClient.post(url.main_service_jwt,
        body: jsonEncode(encrypted_request), headers: header);

    utils.hideProgress(context);

    if (response.statusCode == 200) {
      utils.showProgress(context, 1);

      String data = response.body;

      print("Get_PDF_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("Get_PDF Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("Get_PDF responceSignature -  $responceSignature");

      print("Get_PDF responceData -  $responceData");

      utils.hideProgress(context);

      if (responceSignature == responceData) {
        print("Get_PDF responceSignature - Token Verified");

        var userData = jsonDecode(data);
        var status = userData[s.key_status];
        var response_value = userData[s.key_response];

        if (status == s.key_ok && response_value == s.key_ok) {
          var pdftoString = userData[s.key_json_data];
          print("Get_PDF responceSignature - $pdftoString");

          pdf = const Base64Codec().decode(pdftoString['pdf_string']);
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => PDF_Viewer(
                      pdfBytes: pdf,
                      workID: work_id,
                      inspectionID: inspection_id,
                    )),
          );
        }
      } else {
        utils.customAlertWidet(context, "Error", s.jsonError);
        print("Get_PDF responceSignature - Token Not Verified");
      }
    }
  }
  // *************************** API call Ends here *************************** //

  // *************************** Date  Functions Starts here *************************** //

  Future<void> dateValidation() async {
    String startDate = DateFormat('dd-MM-yyyy').format(selectedFromDate!);
    String endDate = DateFormat('dd-MM-yyyy').format(selectedToDate!);

    if (await utils.isOnline()) {
      dateController.text = "$startDate  To  $endDate";
      fetchOnlineATRWroklist(startDate, endDate);
    } else {
      utils.customAlertWidet(context, "Error", s.no_internet);
    }
  }

  // *************************** Date  Functions Ends here *************************** //

  // *************************** Design Starts Here  *************************** //

  // *************************** ATR DASHBOARD Starts here *************************** //

  __ATR_Dashboard_Design() {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Container(
            width: screenWidth * 0.9,
            height: 200,
            margin:
                const EdgeInsets.only(top: 25, bottom: 10, left: 20, right: 20),
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            decoration: BoxDecoration(
                color: c.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 5.0,
                  ),
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(SDBText,
                      style: GoogleFonts.getFont('Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: c.text_color)),
                ),
                Text(s.total_inspection_works + totalWorksCount,
                    style: GoogleFonts.getFont('Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: c.text_color)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          isUnSatisfiedActive = false;
                          isNeedImprovementActive = true;
                          defaultWorklist = needImprovementWorkList;
                          setState(() {});
                        },
                        child: Container(
                            height: 70,
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: isNeedImprovementActive
                                    ? c.need_improvement
                                    : c.white,
                                border: Border.all(
                                    width: 2, color: c.need_improvement),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 1.0), //(x,y)
                                    blurRadius: 5.0,
                                  ),
                                ]),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(s.need_improvement,
                                      style: GoogleFonts.getFont('Montserrat',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: isNeedImprovementActive
                                              ? c.white
                                              : c.need_improvement)),
                                  Text(npCount,
                                      style: GoogleFonts.getFont('Montserrat',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: isNeedImprovementActive
                                              ? c.white
                                              : c.need_improvement)),
                                ])),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          isUnSatisfiedActive = true;
                          isNeedImprovementActive = false;
                          defaultWorklist = unSatisfiedWorkList;
                          setState(() {});
                        },
                        child: Container(
                            height: 70,
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: isUnSatisfiedActive
                                    ? c.unsatisfied
                                    : c.white,
                                border:
                                    Border.all(width: 2, color: c.unsatisfied),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 3.0), //(x,y)
                                    blurRadius: 5.0,
                                  ),
                                ]),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(s.un_satisfied,
                                      style: GoogleFonts.getFont('Montserrat',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: isUnSatisfiedActive
                                              ? c.white
                                              : c.unsatisfied)),
                                  Text(usCount,
                                      style: GoogleFonts.getFont('Montserrat',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: isUnSatisfiedActive
                                              ? c.white
                                              : c.unsatisfied)),
                                ])),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: c.need_improvement1,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: c.need_improvement, width: 1)),
            margin: const EdgeInsets.only(top: 5),
            width: 200,
            height: 40,
            child: Row(children: [
              Expanded(
                  flex: 1,
                  child: IconButton(
                      color: c.calender_color,
                      iconSize: 18,
                      onPressed: () async {
                        utils.ShowCalenderDialog(context).then((value) => {
                              if (value['flag'])
                                {
                                  selectedFromDate = value['fromDate'],
                                  selectedToDate = value['toDate'],
                                  dateValidation()
                                }
                            });
                      },
                      icon: const Icon(Icons.calendar_month_rounded))),
              Expanded(
                flex: 7,
                child: TextField(
                  controller:
                      dateController, //editing controller of this TextField
                  style: TextStyle(
                    color: c.primary_text_color2,
                    fontWeight: FontWeight.w900,
                    fontSize: screenWidth * 0.03,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 10),
                    isDense: true,
                    hintStyle: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: screenWidth * 0.03,
                        color: c.primary_text_color2),
                    hintText: s.select_from_to_date,
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 0, color: c.need_improvement1),
                        borderRadius: BorderRadius.circular(30.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 0, color: c.need_improvement1),
                        borderRadius: BorderRadius.circular(30.0)),
                  ),
                  readOnly:
                      true, //set it true, so that user will not able to edit text
                  onTap: () async {
                    utils.ShowCalenderDialog(context).then((value) => {
                          if (value['flag'])
                            {
                              selectedFromDate = value['fromDate'],
                              selectedToDate = value['toDate'],
                              dateValidation()
                            }
                        });
                  },
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }

  // *************************** ATR DASHBOARD Ends here *************************** //

  // *************************** ATR Urban starts here *************************** //

  __Urban_design() {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(3),
            child: Text(s.select_tmc,
                style: GoogleFonts.getFont('Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: c.grey_10)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    townActive = true;
                    town_type = "T";
                    munActive = false;
                    corpActive = false;
                    refresh();
                    setState(() {});
                  },
                  child: Container(
                      height: 35,
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: townActive ? c.colorAccentlight : c.white,
                          border: Border.all(
                              width: townActive ? 0 : 2, color: c.colorPrimary),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 5.0,
                            ),
                          ]),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              imagePath.radio,
                              color: townActive ? c.white : c.grey_5,
                              width: 17,
                              height: 17,
                            ),
                            Text("Town Pancha...",
                                style: GoogleFonts.getFont('Roboto',
                                    fontWeight: FontWeight.w800,
                                    fontSize: screenWidth * 0.03,
                                    color: townActive ? c.white : c.grey_6)),
                          ])),
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    town_type = "M";
                    townActive = false;
                    munActive = true;
                    corpActive = false;
                    refresh();
                    setState(() {});
                  },
                  child: Container(
                      height: 35,
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: munActive ? c.colorAccentlight : c.white,
                          border: Border.all(
                              width: munActive ? 0 : 2, color: c.colorPrimary),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 5.0,
                            ),
                          ]),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              imagePath.radio,
                              color: munActive ? c.white : c.grey_5,
                              width: 17,
                              height: 17,
                            ),
                            Text(s.municipality,
                                style: GoogleFonts.getFont('Roboto',
                                    fontWeight: FontWeight.w800,
                                    fontSize: screenWidth * 0.03,
                                    color: munActive ? c.white : c.grey_6)),
                          ])),
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    town_type = "C";
                    townActive = false;
                    munActive = false;
                    corpActive = true;
                    refresh();
                    setState(() {});
                  },
                  child: Container(
                      height: 35,
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: corpActive ? c.colorAccentlight : c.white,
                          border: Border.all(
                              width: corpActive ? 0 : 2, color: c.colorPrimary),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 5.0,
                            ),
                          ]),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              imagePath.radio,
                              color: corpActive ? c.white : c.grey_5,
                              width: 17,
                              height: 17,
                            ),
                            Text(s.corporation,
                                style: GoogleFonts.getFont('Roboto',
                                    fontWeight: FontWeight.w800,
                                    fontSize: screenWidth * 0.03,
                                    color: corpActive ? c.white : c.grey_6)),
                          ])),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // *************************** ATR Urban Ends here *************************** //

  // *************************** ATR Worklist Starts Here  *************************** //

  __ATR_WorkList_Loader() {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      child: Column(
        children: [
          Visibility(
              visible: isWorklistAvailable,
              child: Container(
                margin: const EdgeInsets.only(
                    top: 0, bottom: 10, left: 20, right: 20),
                child: AnimationLimiter(
                  child: ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: isNeedImprovementActive
                        ? int.parse(npCount)
                        : int.parse(usCount),
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 800),
                        child: SlideAnimation(
                          horizontalOffset: 200.0,
                          child: FlipAnimation(
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 0),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Stack(children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 10, left: 10, right: 10, top: 15),
                                  color: c.white,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.inspected_by,
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: c.grey_8),
                                            overflow: TextOverflow.clip,
                                            maxLines: 1,
                                            softWrap: true,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          SizedBox(
                                            width: 80,
                                            /* child:Expanded(
                                             child: Text(defaultWorklist[index][s.key_name], maxLines: 1,
                                                 overflow: TextOverflow.ellipsis,
                                                 textAlign: TextAlign.justify, style: GoogleFonts.getFont('Roboto',
                                                     fontWeight: FontWeight.w600,
                                                     fontSize: 13,
                                                    )),
                                           ),*/
                                            child: Text(
                                              defaultWorklist[index][s.key_name]
                                                          .length >
                                                      25
                                                  ? defaultWorklist[index]
                                                              [s.key_name]
                                                          .substring(0, 25) +
                                                      '...'
                                                  : defaultWorklist[index]
                                                      [s.key_name],
                                              /* utils.splitStringByLength(
                                                  defaultWorklist[index]
                                                      [s.key_name],
                                                  35),*/
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: c.primary_text_color2),
                                              overflow: TextOverflow.clip,
                                              maxLines: 1,
                                              softWrap: true,
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${"( " + defaultWorklist[index][s.key_desig_name]} )",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: c.primary_text_color2),
                                            overflow: TextOverflow.clip,
                                            maxLines: 1,
                                            softWrap: true,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
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
                                            flex: 0,
                                            child: Text(
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
                                            flex: 3,
                                            child: Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  10, 0, 5, 0),
                                              child: Align(
                                                alignment: AlignmentDirectional
                                                    .topStart,
                                                child: Text(
                                                  defaultWorklist[index]
                                                          [s.key_work_id]
                                                      .toString(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
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
                                            flex: 0,
                                            child: Text(
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
                                            flex: 3,
                                            child: Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  10, 0, 5, 0),
                                              child: Align(
                                                alignment: AlignmentDirectional
                                                    .topStart,
                                                child: ExpandableText(
                                                    defaultWorklist[index]
                                                            [s.key_work_name]
                                                        .toString(),
                                                    trimLines: 2,txtcolor: "2",),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
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
                                            flex: 0,
                                            child: Text(
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
                                            flex: 3,
                                            child: Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  10, 0, 5, 0),
                                              child: Align(
                                                alignment: AlignmentDirectional
                                                    .topStart,
                                                child: Text(
                                                  defaultWorklist[index]
                                                          [s.key_work_type_name]
                                                      .toString(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              s.inspected_date,
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
                                            flex: 0,
                                            child: Text(
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
                                            flex: 3,
                                            child: Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  10, 0, 5, 0),
                                              child: Align(
                                                alignment: AlignmentDirectional
                                                    .topStart,
                                                child: Text(
                                                  defaultWorklist[index][
                                                          s.key_inspection_date]
                                                      .toString(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              s.status,
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
                                            flex: 0,
                                            child: Text(
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
                                            flex: 3,
                                            child: Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  10, 0, 5, 0),
                                              child: Align(
                                                alignment: AlignmentDirectional
                                                    .topStart,
                                                child: Text(
                                                  defaultWorklist[index]
                                                          [s.key_status_name]
                                                      .toString(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional.topEnd,
                                  child: GestureDetector(
                                    onTap: () {
                                      selectedWorklist.clear();
                                      selectedWorklist
                                          .add(defaultWorklist[index]);
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                            builder: (context) => ATR_Save(
                                              rural_urban: widget.Flag,
                                              onoff_type:
                                                  prefs.getString(s.onOffType),
                                              selectedWorklist:
                                                  selectedWorklist,
                                              imagelist: [],
                                              flag: "",
                                            ),
                                          ))
                                          .then((value) => initialize());
                                    },
                                    child: Container(
                                      height: 55,
                                      width: 55,
                                      decoration: BoxDecoration(
                                          color: c.colorPrimary,
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(10.0),
                                              bottomLeft: Radius.circular(50))),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, bottom: 5),
                                          child: Image.asset(
                                            imagePath.forword,
                                            width: 25,
                                            height: 25,
                                            color: c.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (await utils.isOnline()) {
                                        get_PDF(
                                            defaultWorklist[index]
                                                    [s.key_work_id]
                                                .toString(),
                                            defaultWorklist[index]
                                                    [s.key_inspection_id]
                                                .toString());
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 10, right: 5),
                                      child: Image.asset(
                                        imagePath.pdf,
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                )
                              ]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )),
          Visibility(
            visible: isWorklistAvailable == false ? true : false,
            child: Align(
              alignment: AlignmentDirectional.center,
              child: Container(
                margin: EdgeInsets.only(top: 50),
                alignment: Alignment.center,
                child: Text(
                  s.no_data,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // *************************** ATR Worklist Ends Here  *************************** //

  // *************************** Design Ends  Here  *************************** //

  // *************************** Refresh Starts  Here  *************************** //

  void refresh() {
    //Empty the Worklist
    defaultWorklist = [];
    unSatisfiedWorkList = [];
    needImprovementWorkList = [];

    isWorklistAvailable = false;

    totalWorksCount = "0";
    npCount = "0";
    usCount = "0";

    dateController.text = s.select_from_to_date;
  }

  // *************************** Refresh Ends  Here  *************************** //
}
