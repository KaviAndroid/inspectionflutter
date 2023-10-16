// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unnecessary_new, unrelated_type_equality_checks, sized_box_for_whitespace, avoid_types_as_parameter_names

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:InspectionAppNew/Resources/Strings.dart' as s;
import 'package:InspectionAppNew/Resources/url.dart' as url;
import 'package:InspectionAppNew/Resources/ColorsValue.dart' as c;
import 'package:InspectionAppNew/Resources/ImagePath.dart' as imagePath;
import 'package:InspectionAppNew/Resources/global.dart' as global;
import '../Layout/ReadMoreLess.dart';
import '../Utils/utils.dart';
import 'ATR_Save.dart';
import 'Pdf_Viewer.dart';

class ViewWorklist extends StatefulWidget {
  final worklist, flag, fromDate, toDate, tmcType;
  ViewWorklist(
      {this.worklist, this.flag, this.fromDate, this.toDate, this.tmcType});

  @override
  State<ViewWorklist> createState() => _ViewWorklistState();
}

class _ViewWorklistState extends State<ViewWorklist> {
  @override
  void initState() {
    super.initState();
    initialize();
  }

  //Bool Values
  bool isWorklistAvailable = false;
  bool saveEnable = false;

  // Map Values
  Map myWorklist = {};

  // List
  List defaultWorklist = [];
  List selectedWorklist = [];
  Iterable workListfiltered = [];
  bool searchEnabled = false;
  bool searchIconPressed = false;
  String _searchQuery = '';
  
  Utils utils = Utils();
  late SharedPreferences prefs;

  //pdf
  Uint8List? pdf;

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();

    myWorklist.addAll(widget.worklist);

    if (prefs.getString(s.key_levels) == "B" && widget.flag != "S") {
      if (prefs.getString(s.key_role_code) == "9042" ||
          prefs.getString(s.key_role_code) == "9052") {
        saveEnable = true;
      } else {
        saveEnable = false;
      }
    }

    // print("object >>>> $myWorklist");

    await fetchOnlineOverallWroklist(widget.fromDate, widget.toDate);

    await __ModifiyUI();

    setState(() {});
  }

  // ************************************* UI Changes Starts here ************************************ //

  Future<void> fetchOnlineOverallWroklist(
      String fromDate, String toDate) async {
    try {
      utils.showProgress(context, 1);

      String? key = prefs.getString(s.userPassKey);
      String? userName = prefs.getString(s.key_user_name);

      var rural_urban = prefs.getString(s.key_rural_urban);

      String statusID = "";
      String tmcID = "";

      if (widget.flag == "S") statusID = "1";
      if (widget.flag == "US") statusID = "2";
      if (widget.flag == "NI") statusID = "3";

      if (widget.tmcType == "T") tmcID = myWorklist[s.key_tpcode].toString();
      if (widget.tmcType == "M") tmcID = myWorklist[s.key_muncode].toString();
      if (widget.tmcType == "C") tmcID = myWorklist[s.key_corcode].toString();

      Map jsonRequest = {
        s.key_service_id: s.service_key_overall_report_for_atr,
        s.key_from_date: fromDate,
        s.key_to_date: toDate,
        s.key_rural_urban: rural_urban,
        s.key_dcode: myWorklist[s.key_dcode],
        s.key_status_id: statusID,
        if (rural_urban == "R") s.key_bcode: myWorklist[s.key_bcode],
        if (rural_urban == "R") s.key_pvcode: myWorklist[s.key_pvcode],
        if (rural_urban == "U") s.key_tmc_type: widget.tmcType,
        if (rural_urban == "U") s.key_tmc_id: tmcID,
      };

      Map encrypted_request = {
        s.key_user_name: prefs.getString(s.key_user_name),
        s.key_data_content: jsonRequest,
      };

      String jsonString = jsonEncode(encrypted_request);

      String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

      String header_token = utils.jwt_Encode(key, userName!, headerSignature);

      // print("OverallWroklist_request_encrpt>>" + jsonEncode(encrypted_request));

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

      // print("OverallWroklist_url>>" + url.main_service_jwt.toString());
      // print("OverallWroklist_request_json>>" + jsonRequest.toString());
      // print("OverallWroklist_request_encrpt>>" + encrypted_request.toString());

      utils.hideProgress(context);
      if (response.statusCode == 200) {
        String data = response.body;

        // print("OverallWroklist_response>>" + data);

        String? authorizationHeader = response.headers['authorization'];

        String? token = authorizationHeader?.split(' ')[1];

        // print("OverallWroklist Authorization -  $token");

        String responceSignature = utils.jwt_Decode(key, token!);

        String responceData = utils.generateHmacSha256(data, key, false);

        // print("OverallWroklist responceSignature -  $responceSignature");

        // print("OverallWroklist responceData -  $responceData");

        if (responceSignature == responceData) {
          // print("OverallWroklist responceSignature - Token Verified");
          var userData = jsonDecode(data);
          var status = userData[s.key_status];
          var response_value = userData[s.key_response];

          if (status == s.key_ok && response_value == s.key_ok) {
            List<dynamic> work_details = [];

            Map res_jsonArray = userData[s.key_json_data];
            work_details = res_jsonArray[s.key_inspection_details];

            defaultWorklist.addAll(work_details);
            if (defaultWorklist.isNotEmpty) {
              isWorklistAvailable = true;
            }
          } else if (status == s.key_ok && response_value == s.key_noRecord) {
            utils.customAlertWidet(context, "Error", s.no_data);
          }
        } else {
          // print("OverallWroklist responceSignature - Token Not Verified");
          utils.customAlertWidet(context, "Error", s.jsonError);
        }
      }
    } catch (e) {
      if (e is FormatException) {
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
      // print(e);
    }
  }

  __ModifiyUI() {
    utils.showProgress(context, 1);

    List<dynamic> work_details = global.workDetails;

    // print("Controller WOrklist $work_details");

    var rural_urban = prefs.getString(s.key_rural_urban);
    String Status_ID = "";

    var dcode = myWorklist[s.key_dcode];

    if (widget.flag == "S") {
      Status_ID = "1";
    } else if (widget.flag == "US") {
      Status_ID = "2";
    } else if (widget.flag == "NI") {
      Status_ID = "3";
    }

    if (rural_urban == "R") {
      var bcode = myWorklist[s.key_bcode];
      var pvcode = myWorklist[s.key_pvcode];

      for (int i = 0; i < work_details.length; i++) {
        if (work_details[i][s.key_dcode].toString() == dcode &&
            work_details[i][s.key_bcode].toString() == bcode &&
            work_details[i][s.key_pvcode].toString() == pvcode &&
            work_details[i][s.key_status_id].toString() == Status_ID) {
          defaultWorklist.add(work_details[i]);
        }
      }

      if (defaultWorklist.isNotEmpty) {
        isWorklistAvailable = true;
      }
    } else {
      String dynamicTMC_workList_ID = "";
      String dynamicTMC_ID = "";

      var tmcType = myWorklist[s.key_town_type];

      if (tmcType == "T") {
        dynamicTMC_workList_ID = s.key_tpcode;
        dynamicTMC_ID = s.key_townpanchayat_id;
      }
      if (tmcType == "M") {
        dynamicTMC_workList_ID = s.key_muncode;
        dynamicTMC_ID = s.key_municipality_id;
      }
      if (tmcType == "C") {
        dynamicTMC_workList_ID = s.key_corcode;
        dynamicTMC_ID = s.key_corporation_id;
      }

      var tmcCode = myWorklist[dynamicTMC_ID];

      for (int i = 0; i < work_details.length; i++) {
        if (work_details[i][s.key_dcode].toString() == dcode &&
            work_details[i][dynamicTMC_workList_ID].toString() == tmcCode &&
            work_details[i][s.key_status_id].toString() == Status_ID) {
          defaultWorklist.add(work_details[i]);
        }
      }
    }
    utils.hideProgress(context);
  }

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
          title:searchIconPressed?
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: TextField(
                onChanged: (String value) async {
                  setState(() {
                    onSearchQueryChanged(value);
                  });

                },
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          searchEnabled=false;
                          searchIconPressed=false;
                        });
                        /* Clear the search field */
                      },
                    ),
                    hintText: 'Search...',
                    border: InputBorder.none),
              ),
            ),
          ): Text(s.work_list),
          centerTitle: true,
          actions: [
            // Navigate to the Search Screen
            !searchIconPressed?IconButton(
                onPressed:(){
                  setState(() {
                    searchIconPressed=true;
                  });
                },
                icon: const Icon(Icons.search)):SizedBox(),
          ],// like this!
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            color: c.colorAccentverylight,
            child: SingleChildScrollView(
              child: __ATR_WorkList_Loader(),
            )));
  }

  // *************************** ATR Worklist Starts Here  *************************** //

  Future<void> get_PDF(String action_status, String work_id,
      String inspection_id, String action_taken_id) async {
    try {
      String? key = prefs.getString(s.userPassKey);
      String? userName = prefs.getString(s.key_user_name);
      utils.showProgress(context, 1);
      var userPassKey = prefs.getString(s.userPassKey);
      Map jsonRequest = {};
      action_status == "Y"
          ? jsonRequest = {
              s.key_service_id: s.service_key_get_action_taken_work_pdf,
              s.key_work_id: work_id,
              s.key_inspection_id: inspection_id,
              s.key_action_taken_id: action_taken_id,
            }
          : jsonRequest = {
              s.key_service_id: s.service_key_get_pdf,
              s.key_work_id: work_id,
              s.key_inspection_id: inspection_id,
            };

      Map encrypted_request = {
        s.key_user_name: prefs.getString(s.key_user_name),
        s.key_data_content: jsonRequest
      };

      // print(" ENC Request >>> $encrypted_request");
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

      // print("get_pdf_url>>" + url.main_service_jwt.toString());
      // print("get_pdf_request_encrpt>>" + encrypted_request.toString());

      utils.hideProgress(context);

      if (response.statusCode == 200) {
        String data = response.body;

        // print("ProgressDetails_response>>" + data);

        String? authorizationHeader = response.headers['authorization'];

        String? token = authorizationHeader?.split(' ')[1];

        // print("ProgressDetails Authorization -  $token");

        String responceSignature = utils.jwt_Decode(key, token!);

        String responceData = utils.generateHmacSha256(data, key, false);

        // print("ProgressDetails responceSignature -  $responceSignature");

        // print("ProgressDetails responceData -  $responceData");

        if (responceSignature == responceData) {
          // print("ProgressDetails responceSignature - Token Verified");
          var userData = jsonDecode(data);

          var status = userData[s.key_status];
          var response_value = userData[s.key_response];

          if (status == s.key_ok && response_value == s.key_ok) {
            var pdftoString = userData[s.key_json_data];
            pdf = const Base64Codec().decode(pdftoString['pdf_string']);
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => PDF_Viewer(
                        pdfBytes: pdf,
                        workID: work_id,
                        inspectionID: inspection_id,
                      actionTakenID:action_status == "Y"?action_taken_id:null ,
                      )),
            );
          }
        } else {
          // print("ProgressDetails responceSignature - Token Not Verified");
          utils.customAlertWidet(context, "Error", s.jsonError);
        }
      }
    } catch (e) {
      if (e is FormatException) {
        // print(e);

        utils.customAlertWidet(context, "Error", s.jsonError);
      }
    }
  }

  // *************************** ATR Worklist Starts Here  *************************** //

  @override
  Widget cardElememtWidget(BuildContext context, String title, String value) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: c.grey_8),
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
                  fontSize: 13, fontWeight: FontWeight.bold, color: c.grey_8),
              overflow: TextOverflow.clip,
              maxLines: 1,
              softWrap: true,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: ExpandableText(value, trimLines: 2,txtcolor: "2",),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 10)
    ]);
  }

  __ATR_WorkList_Loader() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
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
                    itemCount: searchEnabled
                        ? workListfiltered.length
                        : defaultWorklist.length,
                    itemBuilder: (context, index) {
                      final item = searchEnabled
                          ? workListfiltered.elementAt(index)
                          : defaultWorklist[index];
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
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                    fit: BoxFit.contain,
                                    opacity: item
                                                    [s.key_status_id] ==
                                                1 ||
                                            item
                                                    [s.key_action_status] ==
                                                "Y"
                                        ? 0.4
                                        : 0,
                                    image: AssetImage(imagePath.satisfied),
                                  )),
                                  margin: const EdgeInsets.only(
                                      bottom: 10, left: 10, right: 10, top: 15),
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
                                            maxLines: 2,
                                            softWrap: true,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          /*   Expanded(
                                            child: Text(item[s.key_name], maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.justify, style: GoogleFonts.getFont('Roboto',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  color: c.primary_text_color2
                                                    )),
                                          ),*/
                                          Text(
                                            item[s.key_name]
                                                        .length >
                                                    25
                                                ? item
                                                            [s.key_name]
                                                        .substring(0, 25) +
                                                    '...'
                                                : item
                                                    [s.key_name],
                                            /*utils.splitStringByLength(
                                                item
                                                    [s.key_name],
                                                30),*/
                                            style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
                                                color: c.primary_text_color2),
                                            overflow: TextOverflow.clip,
                                            maxLines: 2,
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
                                          Text(
                                            "${"( " + item[s.key_desig_name]} )",
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
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
                                      cardElememtWidget(
                                          context,
                                          s.work_id,
                                          item[s.key_work_id]
                                              .toString()),
                                      cardElememtWidget(
                                          context,
                                          s.work_name,
                                          item
                                                  [s.key_work_name]
                                              .toString()),
                                      cardElememtWidget(
                                          context,
                                          s.work_type_name,
                                          item
                                                  [s.key_work_type_name]
                                              .toString()),
                                      cardElememtWidget(
                                          context,
                                          s.inspected_date,
                                          item
                                                  [s.key_inspection_date]
                                              .toString()),
                                      cardElememtWidget(
                                          context,
                                          s.status,
                                          item
                                                  [s.key_status_name]
                                              .toString()),
                                      Visibility(
                                        visible: item
                                                        [s.key_status_id]
                                                    .toString() ==
                                                "1"
                                            ? false
                                            : true,
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    s.atr_status,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: c.grey_8),
                                                    overflow: TextOverflow.clip,
                                                    maxLines: 1,
                                                    softWrap: true,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    margin: const EdgeInsets
                                                        .fromLTRB(10, 0, 5, 0),
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional
                                                              .topStart,
                                                      child: Text(
                                                        item[s
                                                                        .key_action_status]
                                                                    .toString() ==
                                                                "Y"
                                                            ? s.completed
                                                            : s.pending,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: item
                                                                            [
                                                                            s.key_action_status]
                                                                        .toString() ==
                                                                    "Y"
                                                                ? c.account_status_green_color
                                                                : c.grey_9),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: item
                                                        [s.key_action_status]
                                                    .toString() ==
                                                "Y"
                                            ? true
                                            : false,
                                        child: Column(
                                          children: [
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
                                                    s.atr_submit_by,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: c.grey_8),
                                                    overflow: TextOverflow.clip,
                                                    maxLines: 1,
                                                    softWrap: true,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Container(
                                                    margin: const EdgeInsets
                                                        .fromLTRB(10, 0, 5, 0),
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional
                                                              .topStart,
                                                      child: Text(
                                                        item[s
                                                                    .key_reported_by] !=
                                                                null
                                                            ? defaultWorklist[
                                                                    index][
                                                                s.key_reported_by]
                                                            : '',
                                                        style: TextStyle(
                                                            color: c
                                                                .primary_text_color2),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional.topEnd,
                                  child: InkWell(
                                    onTap: () {
                                      if (saveEnable) {
                                        selectedWorklist.clear();
                                        selectedWorklist
                                            .add(item);
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                              builder: (context) => ATR_Save(
                                                rural_urban: prefs.getString(
                                                    s.key_rural_urban),
                                                onoff_type: prefs
                                                    .getString(s.onOffType),
                                                selectedWorklist:
                                                    selectedWorklist,
                                                imagelist: [],
                                                flag: "",
                                              ),
                                            ))
                                            .then((value) => initialize());
                                      }
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
                                          child: saveEnable
                                              ? Image.asset(
                                                  imagePath.forword,
                                                  width: 25,
                                                  height: 25,
                                                  color: c.white,
                                                )
                                              : SizedBox(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      get_PDF(
                                          item
                                                  [s.key_action_status]
                                              .toString(),
                                          item[s.key_work_id]
                                              .toString(),
                                          item
                                                  [s.key_inspection_id]
                                              .toString(),
                                          item
                                                  [s.key_action_taken_id]
                                              .toString());
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

  onSearchQueryChanged(String query) {
    searchEnabled = true;
    query!=null && query !="" ? _searchQuery = query.toLowerCase():_searchQuery ="";
    workListfiltered = defaultWorklist.where((item) {
      final work_id = item[s.key_work_id].toString();
      final work_name = item[s.key_work_name].toLowerCase();
      return work_id.contains(_searchQuery) || work_name.contains(_searchQuery);
    });
  }

}
