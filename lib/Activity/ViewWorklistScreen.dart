// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unnecessary_new, unrelated_type_equality_checks, sized_box_for_whitespace, avoid_types_as_parameter_names

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../Layout/ReadMoreLess.dart';
import '../Utils/utils.dart';
import 'ATR_Save.dart';
import 'Pdf_Viewer.dart';

class ViewWorklist extends StatefulWidget {
  final worklist, flag, fromDate, toDate;
  ViewWorklist({this.worklist, this.flag, this.fromDate, this.toDate});

  @override
  State<ViewWorklist> createState() => _ViewWorklistState();
}

class _ViewWorklistState extends State<ViewWorklist> {
  //Bool Values
  bool isWorklistAvailable = false;
  bool saveEnable = false;

  // Map Values
  Map myWorklist = {};

  // List
  List defaultWorklist = [];
  List selectedWorklist = [];

  //List Dynamic
  List<dynamic> work_details = [];

  Utils utils = Utils();
  late SharedPreferences prefs;

  //pdf
  Uint8List? pdf;

  @override
  void initState() {
    super.initState();
    initialize();
  }

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

    await fetchOnlineOverallWroklist(widget.fromDate, widget.toDate);

    await __ModifiyUI();

    setState(() {});
  }

  // ************************************* UI Changes Starts here ************************************ //

  __ModifiyUI() {
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
    print(defaultWorklist);
  }

  // ************************************* API call Starts here ************************************ //

  Future<void> fetchOnlineOverallWroklist(
      String fromDate, String toDate) async {
    try {
      utils.showProgress(context, 1);

      var userPassKey = prefs.getString(s.userPassKey);
      var rural_urban = prefs.getString(s.key_rural_urban);

      Map jsonRequest = {
        s.key_service_id: s.service_key_overall_inspection_details_for_atr,
        s.key_from_date: fromDate,
        s.key_to_date: toDate,
        s.key_rural_urban: rural_urban,
      };

      Map encrpted_request = {
        s.key_user_name: prefs.getString(s.key_user_name),
        s.key_data_content:
            Utils().encryption(jsonEncode(jsonRequest), userPassKey.toString()),
      };

      print('Request >>>>>>>> $jsonRequest ');

      print(" ENC Request >>> $encrpted_request");

      HttpClient _client = HttpClient(context: await Utils().globalContext);
      _client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => false;
      IOClient _ioClient = new IOClient(_client);
      var response = await _ioClient.post(url.main_service,
          body: json.encode(encrpted_request));

      utils.hideProgress(context);
      if (response.statusCode == 200) {
        String responseData = response.body;

        var jsonData = jsonDecode(responseData);
        var enc_data = jsonData[s.key_enc_data];
        var decrpt_data = Utils().decryption(enc_data, userPassKey.toString());
        var userData = jsonDecode(decrpt_data);
        var status = userData[s.key_status];
        var response_value = userData[s.key_response];

        print(" Responce >>> $userData");

        if (status == s.key_ok && response_value == s.key_ok) {
          work_details = [];
          Map res_jsonArray = userData[s.key_json_data];
          work_details = res_jsonArray[s.key_inspection_details];

          if (work_details.isNotEmpty) {
            isWorklistAvailable = true;
          }
        } else if (status == s.key_ok && response_value == s.key_noRecord) {
          utils.customAlert(context, "E", s.no_data);
          setState(() {
            isWorklistAvailable = false;
          });
        }
      }
    } catch (e) {
      if (e is FormatException) {
        print(e);
        utils.customAlert(context, "E", s.jsonError);
      }
    }
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
          title: Text(s.work_list),
          centerTitle: true, // like this!
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

  Future<void> get_PDF(String work_id, String inspection_id) async {
    try {
      utils.showProgress(context, 1);
      var userPassKey = prefs.getString(s.userPassKey);

      Map jsonRequest = {
        s.key_service_id: s.service_key_get_pdf,
        s.key_work_id: work_id,
        s.key_inspection_id: inspection_id,
      };

      Map encrpted_request = {
        s.key_user_name: prefs.getString(s.key_user_name),
        s.key_data_content:
            Utils().encryption(jsonEncode(jsonRequest), userPassKey.toString()),
      };

      print('Request >>>>>>>> $jsonRequest ');

      print(" ENC Request >>> $encrpted_request");

      HttpClient _client = HttpClient(context: await Utils().globalContext);
      _client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => false;
      IOClient _ioClient = new IOClient(_client);
      var response = await _ioClient.post(url.main_service,
          body: json.encode(encrpted_request));

      utils.hideProgress(context);

      if (response.statusCode == 200) {
        String responseData = response.body;

        var jsonData = jsonDecode(responseData);

        var enc_data = jsonData[s.key_enc_data];
        var decrpt_data = Utils().decryption(enc_data, userPassKey.toString());
        var userData = jsonDecode(decrpt_data);
        var status = userData[s.key_status];
        var response_value = userData[s.key_response];

        print(" Responce >>> $userData");

        if (status == s.key_ok && response_value == s.key_ok) {
          var pdftoString = userData[s.key_json_data];
          pdf = const Base64Codec().decode(pdftoString['pdf_string']);
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => PDF_Viewer(
                      pdfBytes: pdf,
                    )),
          );
        }
      }
    } catch (e) {
      if (e is FormatException) {
        print(e);

        utils.customAlert(context, "E", s.jsonError);
      }
    }
  }

  // *************************** ATR Worklist Starts Here  *************************** //

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
                    itemCount: defaultWorklist.length,
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
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                    fit: BoxFit.contain,
                                    opacity: defaultWorklist[index]
                                                    [s.key_status_id] ==
                                                1 ||
                                            defaultWorklist[index]
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
                                            maxLines: 1,
                                            softWrap: true,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            defaultWorklist[index][s.key_name],
                                            style: TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
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
                                          Text(
                                            "${"( " + defaultWorklist[index][s.key_desig_name]} )",
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
                                                    style: TextStyle(
                                                        color: c.grey_8)),
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
                                                    trimLines: 2),
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
                                                    defaultWorklist[index][s
                                                            .key_work_type_name]
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: c.grey_8)),
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
                                                    defaultWorklist[index][s
                                                            .key_inspection_date]
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: c.grey_8)),
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
                                                    style: TextStyle(
                                                        color: c.grey_8)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible: defaultWorklist[index]
                                                        [s.key_status_id]
                                                    .toString() ==
                                                "1"
                                            ? false
                                            : true,
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
                                                        defaultWorklist[index][s
                                                                        .key_action_status]
                                                                    .toString() ==
                                                                "Y"
                                                            ? s.completed
                                                            : s.pending,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: defaultWorklist[index]
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
                                        visible: defaultWorklist[index]
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
                                                        defaultWorklist[index]
                                                            [s.key_reported_by],
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
                                  child: GestureDetector(
                                    onTap: () {
                                      if (saveEnable) {
                                        selectedWorklist.clear();
                                        selectedWorklist
                                            .add(defaultWorklist[index]);
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
                                  child: GestureDetector(
                                    onTap: () {
                                      get_PDF(
                                          defaultWorklist[index][s.key_work_id]
                                              .toString(),
                                          defaultWorklist[index]
                                                  [s.key_inspection_id]
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
}
