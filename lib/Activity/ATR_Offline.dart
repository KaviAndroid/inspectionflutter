// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:inspection_flutter_app/Activity/ATR_Save.dart';
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/DataBase/DbHelper.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Layout/ReadMoreLess.dart';
import '../Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import '../Utils/utils.dart';
import 'package:inspection_flutter_app/Resources/global.dart';
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;

import 'Pdf_Viewer.dart';

class ATR_Offline_worklist extends StatefulWidget {
  final Flag;
  ATR_Offline_worklist({this.Flag});
  @override
  State<ATR_Offline_worklist> createState() => _ATR_Offline_worklistState();
}

class _ATR_Offline_worklistState extends State<ATR_Offline_worklist>
    with TickerProviderStateMixin {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;

  //Date Time
  List<DateTime>? selectedDateRange;

  //Worklist
  List needImprovementWorkList = [];
  List unSatisfiedWorkList = [];
  List defaultWorklist = [];
  List selectedWorklist = [];
  List urbanOfflineList = [];
  List<Map> list = [];

  // Controller Text
  TextEditingController dateController = TextEditingController();

  // Strings
  String totalWorksCount = "0";
  String SDBText = "";
  String npCount = "0";
  String usCount = "0";
  String town_type = "";

  // Bool Variables
  bool isSpinnerLoading = true;
  bool isWorklistAvailable = false;
  bool isNeedImprovementActive = false;
  bool isUnSatisfiedActive = false;
  bool townActive = false;
  bool munActive = false;
  bool corpActive = false;

  //pdf
  Uint8List? pdf;

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    controller.repeat(reverse: true);
    initialize();
  }

  @override
  void dispose() {
    controller.reset();
    controller.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;

    widget.Flag == "U"
        ? prefs.getString(s.atr_date_u) != null
            ? dateController.text = prefs.getString(s.atr_date_u).toString()
            : s.select_from_to_date
        : widget.Flag == "R"
            ? prefs.getString(s.atr_date_r) != null
                ? dateController.text = prefs.getString(s.atr_date_r).toString()
                : s.select_from_to_date
            : null;

    fetchOfflineWorklist();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.colorPrimary,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => {controller.reset(), Navigator.pop(context)}),
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
                    // Download Text Icon
                    FadeTransition(
                      opacity: controller,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: GestureDetector(
                          onTap: () => selectDateFunc(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                imagePath.download,
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(s.download_text,
                                  style: GoogleFonts.getFont('Roboto',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: c.primary_text_color2))
                            ],
                          ),
                        ),
                      ),
                    ),

                    widget.Flag == "U"
                        ? __Urban_design()
                        : const SizedBox(
                            height: 10,
                          ),

                    // Dashboard
                    __ATR_Dashboard_Design(),

                    // Worklist Design
                    __ATR_WorkList_Loader(),
                  ],
                ),
              ),
              Visibility(
                  visible: isSpinnerLoading,
                  child: Utils().showSpinner(context, "Processing"))
            ],
          )),
    );
  }

  // *************************** API Call starts  Here  *************************** //

  Future<void> fetchOnlineATRWroklist(String fromDate, String toDate) async {
    setState(() {
      isSpinnerLoading = true;
      isWorklistAvailable = false;
      isNeedImprovementActive = false;
      isUnSatisfiedActive = false;
    });

    var userPassKey = prefs.getString(s.userPassKey);

    Map jsonRequest = {
      s.key_service_id: s.service_key_get_inspection_details_for_atr,
      s.key_from_date: fromDate,
      s.key_to_date: toDate,
      s.key_rural_urban: prefs.getString(s.area_type)
    };

    if (widget.Flag == "U") {
      Map urbanRequest = {s.key_town_type: town_type};

      jsonRequest.addAll(urbanRequest);
    }

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
          Utils().encryption(jsonEncode(jsonRequest), userPassKey.toString()),
    };

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service,
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
        widget.Flag == "U"
            ? prefs.setString(s.atr_date_u, dateController.text)
            : prefs.setString(s.atr_date_r, dateController.text);
        Map res_jsonArray = userData[s.key_json_data];
        List<dynamic> inspection_details =
            res_jsonArray[s.key_inspection_details];

        if (inspection_details.isNotEmpty) {
          if (widget.Flag == "U") {
            dbHelper.delete_table_AtrWorkList('U');
          } else if (widget.Flag == "R") {
            dbHelper.delete_table_AtrWorkList('R');
          }
          for (int i = 0; i < inspection_details.length; i++) {
            await dbClient.rawInsert('INSERT INTO ' +
                s.table_AtrWorkList +
                ' (dcode, bcode , pvcode, inspection_id  , inspection_date , status_id, status , description , work_id, work_name  , inspection_by_officer , inspection_by_officer_designation, work_type_name  , dname , bname, pvname , rural_urban, town_type, tpcode, townpanchayat_name, muncode, municipality_name, corcode, corporation_name) VALUES(' +
                "'" +
                inspection_details[i][s.key_dcode].toString() +
                "' , '" +
                inspection_details[i][s.key_bcode].toString() +
                "' , '" +
                inspection_details[i][s.key_pvcode].toString() +
                "' , '" +
                inspection_details[i][s.key_inspection_id].toString() +
                "' , '" +
                inspection_details[i][s.key_inspection_date] +
                "' , '" +
                inspection_details[i][s.key_status_id].toString() +
                "' , '" +
                inspection_details[i][s.key_status_name] +
                "' , '" +
                inspection_details[i][s.key_description] +
                "' , '" +
                inspection_details[i][s.key_work_id].toString() +
                "' , '" +
                inspection_details[i][s.key_work_name] +
                "' , '" +
                inspection_details[i][s.key_name] +
                "' , '" +
                inspection_details[i][s.key_desig_name] +
                "' , '" +
                inspection_details[i][s.key_work_type_name] +
                "' , '" +
                inspection_details[i][s.key_dname] +
                "' , '" +
                inspection_details[i][s.key_bname] +
                "' , '" +
                inspection_details[i][s.key_pvname] +
                "' , '" +
                inspection_details[i][s.key_rural_urban] +
                "' , '" +
                inspection_details[i][s.key_town_type] +
                "' , '" +
                inspection_details[i][s.key_tpcode].toString() +
                "' , '" +
                inspection_details[i][s.key_townpanchayat_name] +
                "' , '" +
                inspection_details[i][s.key_muncode].toString() +
                "' , '" +
                inspection_details[i][s.key_municipality_name] +
                "' , '" +
                inspection_details[i][s.key_corcode].toString() +
                "' , '" +
                inspection_details[i][s.key_corporation_name] +
                "')");
          }
          fetchOfflineWorklist();
        }
      } else if (status == s.key_ok && response_value == s.key_noRecord) {
        setState(() {
          utils.showAlert(context, s.no_data);
          isSpinnerLoading = false;
          isWorklistAvailable = false;
          totalWorksCount = "0";
          npCount = "0";
          usCount = "0";
        });
      }
    }
  }

  Future<void> get_PDF(String work_id, String inspection_id) async {
    if (await utils.isOnline()) {
      setState(() {
        isSpinnerLoading = true;
      });

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

      HttpClient _client = HttpClient(context: await Utils().globalContext);
      _client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => false;
      IOClient _ioClient = new IOClient(_client);
      var response = await _ioClient.post(url.main_service,
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
          var pdftoString = userData[s.key_json_data];
          pdf = const Base64Codec().decode(pdftoString['pdf_string']);
          setState(() {
            isSpinnerLoading = false;
          });
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => PDF_Viewer(
                      pdfBytes: pdf,
                    )),
          );
        }
      }
    } else {
      setState(() {
        isSpinnerLoading = false;
      });
      utils.showAlert(context, "asd");
    }
  }

  // *************************** API Call Ends  Here  *************************** //

  // *************************** Fetch Offline Worklist starts  Here  *************************** //

  Future<void> fetchOfflineWorklist() async {
    list = await dbClient.rawQuery(
        "SELECT * FROM ${s.table_AtrWorkList} where rural_urban='${widget.Flag}' ");

    if (list.isEmpty) {
      isSpinnerLoading = false;
      isWorklistAvailable = false;
    } else {
      totalWorksCount = list.length.toString();

      //Empty the Worklist
      defaultWorklist = [];
      unSatisfiedWorkList = [];
      needImprovementWorkList = [];

      for (int i = 0; i < list.length; i++) {
        if (list[i][s.key_status_id] == "3") {
          needImprovementWorkList.add(list[i]);
        } else if (list[i][s.key_status_id] == "2") {
          unSatisfiedWorkList.add(list[i]);
        }
      }

      usCount = unSatisfiedWorkList.length.toString();
      npCount = needImprovementWorkList.length.toString();

      if (needImprovementWorkList.isNotEmpty) {
        isNeedImprovementActive = true;
        isUnSatisfiedActive = false;
        defaultWorklist = needImprovementWorkList;
      } else if (unSatisfiedWorkList.isNotEmpty) {
        isUnSatisfiedActive = true;
        isNeedImprovementActive = false;
        defaultWorklist = unSatisfiedWorkList;
      }

      if (prefs.getString(s.onOffType) == "offline" && widget.Flag == "U") {
        urbanOfflineList = list;
        if (list[0][s.key_town_type] == "T") {
          townActive = true;
        } else if (list[0][s.key_town_type] == "M") {
          munActive = true;
        } else if (list[0][s.key_town_type] == "C") {
          corpActive = true;
        }
      }

      dateController.text = widget.Flag == "U"
          ? prefs.getString(s.atr_date_u).toString()
          : prefs.getString(s.atr_date_r).toString();
      setState(() {
        isSpinnerLoading = false;
        isWorklistAvailable = true;
      });
    }
    setState(() {
      SDBText = "Block - ${prefs.getString(s.key_bname)}";
    });
  }

  // *************************** Fetch Offline Worklist ends  Here  *************************** //

  // *************************** Date  Functions Starts here *************************** //

  Future<void> dateValidation() async {
    if (selectedDateRange != null) {
      DateTime sD = selectedDateRange![0];
      DateTime eD = selectedDateRange![1];

      String startDate = DateFormat('dd-MM-yyyy').format(sD);
      String endDate = DateFormat('dd-MM-yyyy').format(eD);

      if (sD.compareTo(eD) == 1) {
        utils.showAlert(context, "End Date should be greater than Start Date");
      } else {
        dateController.text = "$startDate  To  $endDate";
        fetchOnlineATRWroklist(startDate, endDate);
      }
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

  // *************************** Date  Functions Ends here *************************** //

  // *************************** ATR DASHBOARD Starts here *************************** //

  __ATR_Dashboard_Design() {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 0),
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Container(
            width: screenWidth * 0.9,
            height: 200,
            margin:
                const EdgeInsets.only(top: 25, bottom: 10, left: 20, right: 20),
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
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
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: c.text_color)),
                ),
                Text(s.total_inspection_works + totalWorksCount,
                    style: GoogleFonts.getFont('Montserrat',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(s.need_improvement,
                                      style: GoogleFonts.getFont('Montserrat',
                                          fontWeight: FontWeight.w800,
                                          fontSize: screenWidth * 0.03,
                                          color: isNeedImprovementActive
                                              ? c.white
                                              : c.need_improvement)),
                                  Text(npCount,
                                      style: GoogleFonts.getFont('Montserrat',
                                          fontWeight: FontWeight.w800,
                                          fontSize: screenWidth * 0.03,
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
                                          fontWeight: FontWeight.w800,
                                          fontSize: screenWidth * 0.03,
                                          color: isUnSatisfiedActive
                                              ? c.white
                                              : c.unsatisfied)),
                                  Text(usCount,
                                      style: GoogleFonts.getFont('Montserrat',
                                          fontWeight: FontWeight.w800,
                                          fontSize: screenWidth * 0.03,
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
                        selectDateFunc();
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
                    selectDateFunc();
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

  // *************************** ATR Worklist Starts Here  *************************** //

  __ATR_WorkList_Loader() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(top: 0),
        height: widget.Flag == "U" ? sceenHeight - 465 : sceenHeight - 405,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Visibility(
                      visible: isWorklistAvailable,
                      child: Container(
                        margin: const EdgeInsets.only(
                            top: 0, bottom: 10, left: 20, right: 20),
                        child: AnimationLimiter(
                          child: ListView.builder(
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
                                          vertical: 10, horizontal: 0),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Stack(children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 10,
                                              left: 10,
                                              right: 10,
                                              top: 15),
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: c.grey_8),
                                                    overflow: TextOverflow.clip,
                                                    maxLines: 1,
                                                    softWrap: true,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    defaultWorklist[index][s
                                                        .inspection_by_officer],
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: c
                                                            .primary_text_color2),
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
                                                    "${"( " + defaultWorklist[index][s.inspection_by_officer_designation]} )",
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: c
                                                            .primary_text_color2),
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
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: c.grey_8),
                                                      overflow:
                                                          TextOverflow.clip,
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
                                                      overflow:
                                                          TextOverflow.clip,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                              .fromLTRB(
                                                          10, 0, 5, 0),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional
                                                                .topStart,
                                                        child: Text(
                                                          defaultWorklist[index]
                                                                  [
                                                                  s.key_work_id]
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
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: c.grey_8),
                                                      overflow:
                                                          TextOverflow.clip,
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
                                                      overflow:
                                                          TextOverflow.clip,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                              .fromLTRB(
                                                          10, 0, 5, 0),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional
                                                                .topStart,
                                                        child: ExpandableText(
                                                            defaultWorklist[
                                                                        index][
                                                                    s.key_work_name]
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
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: c.grey_8),
                                                      overflow:
                                                          TextOverflow.clip,
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
                                                      overflow:
                                                          TextOverflow.clip,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                              .fromLTRB(
                                                          10, 0, 5, 0),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional
                                                                .topStart,
                                                        child: Text(
                                                          defaultWorklist[index]
                                                                  [
                                                                  s.key_work_type_name]
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
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: c.grey_8),
                                                      overflow:
                                                          TextOverflow.clip,
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
                                                      overflow:
                                                          TextOverflow.clip,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                              .fromLTRB(
                                                          10, 0, 5, 0),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional
                                                                .topStart,
                                                        child: Text(
                                                          defaultWorklist[index]
                                                                  [
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
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: c.grey_8),
                                                      overflow:
                                                          TextOverflow.clip,
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
                                                      overflow:
                                                          TextOverflow.clip,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                              .fromLTRB(
                                                          10, 0, 5, 0),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional
                                                                .topStart,
                                                        child: Text(
                                                          defaultWorklist[index]
                                                                  [
                                                                  s.key_status_name]
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
                                          alignment:
                                              AlignmentDirectional.topEnd,
                                          child: GestureDetector(
                                            onTap: () {
                                              selectedWorklist.clear();
                                              selectedWorklist
                                                  .add(defaultWorklist[index]);
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                builder: (context) => ATR_Save(
                                                  area_type: widget.Flag,
                                                  onoff_type: prefs
                                                      .getString(s.onOffType),
                                                  selectedWorklist:
                                                      selectedWorklist,
                                                ),
                                              ));
                                            },
                                            child: Container(
                                              height: 55,
                                              width: 55,
                                              decoration: BoxDecoration(
                                                  color: c.colorPrimary,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  10.0),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  50))),
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
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
                                            onTap: () {
                                              get_PDF(
                                                  defaultWorklist[index]
                                                          [s.key_work_id]
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
                        alignment: Alignment.center,
                        child: Text(
                          s.no_data,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // *************************** ATR Worklist Ends Here  *************************** //

  // *************************** ATR Urban starts here *************************** //

  __Urban_design() {
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 5),
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
                    setState(() {});
                    refresh();
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
                            Text(
                              "Town Pancha...",
                              style: GoogleFonts.getFont('Roboto',
                                  fontWeight: FontWeight.w800,
                                  fontSize: screenWidth * 0.03,
                                  color: townActive ? c.white : c.grey_6),
                            ),
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
                    setState(() {});
                    refresh();
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
                    setState(() {});
                    refresh();
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

  // *************************** Refresh Starts  Here  *************************** //

  void refresh() {
    if (prefs.getString(s.onOffType) == "offline" && widget.Flag == "U") {
      if (urbanOfflineList.isNotEmpty) {
        if (urbanOfflineList[0][s.key_town_type] == "T") {
          if (townActive) {
            fetchOfflineWorklist();
          } else {
            emptyDatas();
          }
        } else if (urbanOfflineList[0][s.key_town_type] == "M") {
          if (munActive) {
            fetchOfflineWorklist();
          } else {
            emptyDatas();
          }
        } else if (urbanOfflineList[0][s.key_town_type] == "C") {
          if (corpActive) {
            fetchOfflineWorklist();
          } else {
            emptyDatas();
          }
        }
      }
    }
  }

  // *************************** Refresh Ends  Here  *************************** //

  // *************************** Empty Data Starts  Here  *************************** //

  void emptyDatas() {
    //Empty the Worklist
    unSatisfiedWorkList = [];
    needImprovementWorkList = [];

    isWorklistAvailable = false;

    totalWorksCount = "0";
    npCount = "0";
    usCount = "0";

    dateController.text = s.select_from_to_date;
  }

  // *************************** Empty Data Ends  Here  *************************** //
}
