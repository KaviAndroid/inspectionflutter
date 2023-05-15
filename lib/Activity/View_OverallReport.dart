// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unnecessary_new, unrelated_type_equality_checks, sized_box_for_whitespace, avoid_types_as_parameter_names

import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/ViewWorklistScreen.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/global.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;

import '../DataBase/DbHelper.dart';
import '../Utils/utils.dart';

class ViewOverallReport extends StatefulWidget {
  final flag;

  const ViewOverallReport({Key? key, this.flag}) : super(key: key);
  @override
  State<ViewOverallReport> createState() => _ViewOverallReportState();
}

class _ViewOverallReportState extends State<ViewOverallReport> {
  //Bool Values
  bool isWorklistAvailable = false;
  bool isPiechartAvailable = false;
  bool stateUI = false;
  bool districtUI = false;
  bool blockUI = false;
  bool urbanUI = false;
  bool searchEnabled = false;
  bool urbanworkListUI = false;

  // Controller Text
  TextEditingController dateController = TextEditingController();

  //Date Time
  List<DateTime>? selectedDateRange;

  //List
  late List<ChartData> data;
  List defaultWorklist = [];
  List selectedworkList = [];
  List villageworkList = [];
  List districtworkList = [];
  List blockworkList = [];
  List TMCworkList = [];
  List _filteredVillage = [];

  //List Dynamic
  List<dynamic> work_details = [];

  //String Vlues
  String header_name = "";
  String nimpCount = "";
  String usCount = "";
  String sCount = "";
  String atrCount = "";
  String totalWorksCount = "";
  String from_Date = "";
  String to_Date = "";
  String selectedDcode = "";
  String selectedBcode = "";
  String tmcType = "";
  String dynamicTMC_ID = "";
  String dynamicTMC_Name = "";
  String _searchQuery = '';

  //Urban int values
  int urban_tp_s = 0;
  int urban_mun_s = 0;
  int urban_corp_s = 0;
  int urban_tp_us = 0;
  int urban_mun_us = 0;
  int urban_corp_us = 0;
  int urban_tp_nm = 0;
  int urban_mun_nm = 0;
  int urban_corp_nm = 0;
  int urban_tp_TC = 0;
  int urban_mun_TC = 0;
  int urban_corp_TC = 0;

  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;

  Future<bool> _onWillPop() async {
    if (prefs.getString(s.key_rural_urban) == "U") {
      if (isWorklistAvailable) {
        goToBack();
      } else {
        Navigator.of(context, rootNavigator: true).pop(context);
      }
    } else {
      if (isWorklistAvailable && widget.flag != "B") {
        goToBack();
      } else {
        Navigator.of(context, rootNavigator: true).pop(context);
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString(s.onOffType, "online");
    if (prefs.getString(s.key_rural_urban) == "U") {
      urbanUI = true;
    }
    dbClient = await dbHelper.db;
    loadWorkList();
  }

  Future<void> goToBack() async {
    isWorklistAvailable = false;
    if (prefs.getString(s.key_rural_urban) == "U") {
      urbanworkListUI = false;
      urbanUI = true;
      await fetchTMCWorklist();
    } else {
      selectedBcode = "";
      blockUI = false;
      districtUI = true;
      await fetchBlockWorklist();
    }
    await __ModifiyUI();

    setState(() {});
  }

  Future<void> loadWorkList() async {
    final endDate = DateTime.now();
    final fromDate = endDate.subtract(Duration(days: 60));

    from_Date = DateFormat('dd-MM-yyyy').format(fromDate);
    to_Date = DateFormat('dd-MM-yyyy').format(endDate);
    dateController.text = "$from_Date to $to_Date";

    if (!urbanUI) {
      if (widget.flag == "B") {
        await fetchVillageWorklist();
        header_name = "Block - ${prefs.getString(s.key_bname)}";
        stateUI = false;
        districtUI = false;
        blockUI = true;
      } else if (widget.flag == "D") {
        await fetchBlockWorklist();
        header_name = "District - ${prefs.getString(s.key_dname)}";
        stateUI = false;
        districtUI = true;
        blockUI = false;
      } else if (widget.flag == "S") {
        await fetchDistrictWorklist();
        header_name = "State - Tamil Nadu";
        stateUI = true;
        districtUI = false;
        blockUI = false;
      }
    }

    await fetchOnlineOverallWroklist(from_Date, to_Date);

    __ModifiyUI();

    setState(() {});
  }

  // *************************** Search  Functions Starts here *************************** //

  void _onSearchQueryChanged(String query) {
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
    setState(() {
      searchEnabled = true;
      _searchQuery = query;
      _filteredVillage = defaultWorklist.where((item) {
        final name = item[compareVilageName].toLowerCase();
        final lowerCaseQuery = query.toLowerCase();
        return name.contains(lowerCaseQuery);
      }).toList();
    });
  }

  // *************************** Date  Functions Starts here *************************** //

  Future<void> dateValidation() async {
    if (selectedDateRange != null) {
      DateTime sD = selectedDateRange![0];
      DateTime eD = selectedDateRange![1];

      from_Date = DateFormat('dd-MM-yyyy').format(sD);
      to_Date = DateFormat('dd-MM-yyyy').format(eD);

      if (sD.compareTo(eD) == 1) {
        utils.showAlert(context, "End Date should be greater than Start Date");
      } else {
        dateController.text = "$from_Date  To  $to_Date";
        await fetchOnlineOverallWroklist(from_Date, to_Date);

        __ModifiyUI();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: c.ca1,
          appBar: AppBar(
            backgroundColor: c.colorPrimary,
            title: Text(s.over_all_inspection_report),
            centerTitle: true, // like this!
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                isPiechartAvailable ? _Piechart() : SizedBox(),
                urbanUI ? __TMCTable() : SizedBox(),
                stateUI ? __districtTable() : SizedBox(),
                districtUI ? __blockTable() : SizedBox(),
                isWorklistAvailable ? __workListLoder() : SizedBox(),
              ],
            ),
          ),
        ));
  }

  // ************************************* TMC Worklist Loder Design ********************************* //

  __TMCTable() {
    return Container(
        width: screenWidth * 0.9,
        margin: EdgeInsets.only(top: 20),
        child: AnimationLimiter(
            child: AnimationConfiguration.staggeredList(
                duration: const Duration(milliseconds: 800),
                position: 0,
                child: SlideAnimation(
                    horizontalOffset: 200.0,
                    child: Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 7, horizontal: 0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(
                                1.3), // Set width of column 0 to 3 times the width of other columns
                            1: FlexColumnWidth(
                                1), // Set width of column 1 to the same as other columns
                            2: FlexColumnWidth(
                                1), // Set width of column 1 to the same as other columns
                            3: FlexColumnWidth(
                                1.2), // Set width of column 1 to the same as other columns
                            4: FlexColumnWidth(
                                0.5), // Set width of column 1 to the same as other columns
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(
                                decoration: BoxDecoration(
                                    color: c.dot_light_screen3,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10))),
                                children: [
                                  TableCell(
                                      child: Container(
                                    height: 50,
                                    child: Center(
                                      child: Text(s.town_type,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: c.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  )),
                                  TableCell(
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Text(s.satisfied,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Text(s.un_satisfied,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Text(s.need_improvement,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                      child: Container(
                                          height: 50, child: SizedBox())),
                                ]),
                            TableRow(
                                decoration: BoxDecoration(
                                  color: c.white,
                                ),
                                children: [
                                  TableCell(
                                      child: Container(
                                    height: 50,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(s.town_panchayat,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.grey_10,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500)),
                                        Text("( $urban_tp_TC )",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.primary_text_color2,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  )),
                                  TableCell(
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Text(urban_tp_s.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.primary_text_color2,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Text(urban_tp_us.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.primary_text_color2,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Text(urban_tp_nm.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.primary_text_color2,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: GestureDetector(
                                      onTap: () async {
                                        tmcType = "T";
                                        await fetchTMCWorklist();
                                        urbanUI = false;
                                        urbanworkListUI = true;
                                        await __ModifiyUI();
                                        setState(() {});
                                      },
                                      child: Image.asset(imagePath.arrow_right,color: c.primary_text_color2,height: 22,width: 22,),
                                    ),
                                  ),
                                ]),
                            TableRow(
                                decoration: BoxDecoration(
                                  color: c.full_transparent,
                                ),
                                children: [
                                  TableCell(
                                      child: Container(
                                    height: 50,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(s.municipality,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.grey_10,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500)),
                                        Text("( $urban_mun_TC )",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.primary_text_color2,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  )),
                                  TableCell(
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Text(urban_mun_s.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.primary_text_color2,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Text(urban_mun_us.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.primary_text_color2,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Text(urban_mun_nm.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.primary_text_color2,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: GestureDetector(
                                      onTap: () async {
                                        tmcType = "M";
                                        await fetchTMCWorklist();
                                        urbanUI = false;
                                        urbanworkListUI = true;
                                        await __ModifiyUI();
                                        setState(() {});
                                      },
                                      child:Image.asset(imagePath.arrow_right,color: c.primary_text_color2,height: 22,width: 22,),
                                    ),
                                  ),
                                ]),
                            TableRow(
                                decoration: BoxDecoration(
                                  color: c.white,
                                ),
                                children: [
                                  TableCell(
                                      child: Container(
                                    height: 50,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(s.corporation,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.grey_10,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500)),
                                        Text("( $urban_corp_TC )",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.primary_text_color2,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  )),
                                  TableCell(
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Text(urban_corp_s.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.primary_text_color2,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Text(urban_corp_us.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.primary_text_color2,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      height: 50,
                                      child: Center(
                                        child: Text(urban_corp_nm.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: c.primary_text_color2,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: GestureDetector(
                                      onTap: () async {
                                        tmcType = "C";
                                        await fetchTMCWorklist();
                                        urbanUI = false;
                                        urbanworkListUI = true;
                                        await __ModifiyUI();
                                        setState(() {});
                                      },
                                      child: Image.asset(imagePath.arrow_right,color: c.primary_text_color2,height: 22,width: 22,),
                                    ),
                                  ),
                                ]),
                          ],
                        ))))));
  }

  // ************************************* Block Worklist Loder Design ********************************* //

  __blockTable() {
    return Container(
        margin: EdgeInsets.only(top: 15),
        width: screenWidth * 0.9,
        child: Column(
          children: [
            Table(
                columnWidths: const {
                  0: FlexColumnWidth(
                      1.3), // Set width of column 0 to 3 times the width of other columns
                  1: FlexColumnWidth(
                      1), // Set width of column 1 to the same as other columns
                  2: FlexColumnWidth(
                      1), // Set width of column 1 to the same as other columns
                  3: FlexColumnWidth(
                      1.2), // Set width of column 1 to the same as other columns
                  4: FlexColumnWidth(
                      0.5), // Set width of column 1 to the same as other columns
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                      decoration: BoxDecoration(
                          color: c.dot_light_screen3,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10))),
                      children: [
                        TableCell(
                            child: Container(
                          height: 50,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: widget.flag == "S"
                                  ? MainAxisAlignment.spaceEvenly
                                  : MainAxisAlignment.center,
                              children: [
                                Visibility(
                                  visible: widget.flag == "S" ? true : false,
                                  child: GestureDetector(
                                    onTap: () async {
                                      selectedDcode = "";
                                      stateUI = true;
                                      districtUI = false;

                                      await fetchDistrictWorklist();
                                      await __ModifiyUI();

                                      setState(() {});
                                    },
                                    child: Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 15,
                                        color: c.white),
                                  ),
                                ),
                                Text(s.block,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: c.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        )),
                        TableCell(
                          child: Container(
                            height: 50,
                            child: Center(
                              child: Text(s.satisfied,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: c.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            height: 50,
                            child: Center(
                              child: Text(s.un_satisfied,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: c.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            height: 50,
                            child: Center(
                              child: Text(s.need_improvement,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: c.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                        TableCell(
                            child: Container(height: 50, child: SizedBox())),
                      ])
                ]),
            AnimationLimiter(
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    primary: false,
                    itemCount:
                        defaultWorklist.isEmpty ? 0 : defaultWorklist.length,
                    itemBuilder: (BuildContext context, int index) {
                      return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 800),
                          child: SlideAnimation(
                              horizontalOffset: 200.0,
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(
                                      1.3), // Set width of column 0 to 3 times the width of other columns
                                  1: FlexColumnWidth(
                                      1), // Set width of column 1 to the same as other columns
                                  2: FlexColumnWidth(
                                      1), // Set width of column 1 to the same as other columns
                                  3: FlexColumnWidth(
                                      1.2), // Set width of column 1 to the same as other columns
                                  4: FlexColumnWidth(
                                      0.5), // Set width of column 1 to the same as other columns
                                },
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  TableRow(
                                      decoration: BoxDecoration(
                                        color: index % 2 == 0
                                            ? c.white
                                            : c.full_transparent,
                                      ),
                                      children: [
                                        TableCell(
                                            child: Container(
                                          height: 50,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                  "${defaultWorklist[index][s.key_bname]}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: c.grey_10,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              Text(
                                                  "( ${defaultWorklist[index][s.total_inspected_works].toString()} )",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color:
                                                          c.primary_text_color2,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ],
                                          ),
                                        )),
                                        TableCell(
                                          child: Container(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                  defaultWorklist[index]
                                                          [s.key_satisfied]
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: defaultWorklist[
                                                                      index][
                                                                  s.key_satisfied] ==
                                                              0
                                                          ? c.grey_10
                                                          : c.primary_text_color2,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500)),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                  defaultWorklist[index]
                                                          [s.key_unsatisfied]
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: defaultWorklist[
                                                                      index][
                                                                  s.key_unsatisfied] ==
                                                              0
                                                          ? c.grey_10
                                                          : c.primary_text_color2,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500)),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                  defaultWorklist[index][s
                                                          .key_need_improvement]
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: defaultWorklist[
                                                                      index][
                                                                  s.key_need_improvement] ==
                                                              0
                                                          ? c.grey_10
                                                          : c.primary_text_color2,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500)),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: GestureDetector(
                                            onTap: () async {
                                              selectedBcode =
                                                  defaultWorklist[index]
                                                      [s.key_bcode];

                                              selectedDcode =
                                                  defaultWorklist[index]
                                                      [s.key_dcode];

                                              stateUI = false;
                                              districtUI = false;
                                              blockUI = true;

                                              await fetchVillageWorklist();
                                              await __ModifiyUI();

                                              setState(() {});
                                            },
                                            child: Image.asset(imagePath.arrow_right,color: c.primary_text_color2,height: 22,width: 22,),
                                          ),
                                        ),
                                      ]),
                                ],
                              )));
                    })),
          ],
        ));
  }

  // ************************************* District Worklist Loder Design ********************************* //

  __districtTable() {
    return Container(
        margin: EdgeInsets.only(top: 15),
        width: screenWidth * 0.9,
        child: Column(
          children: [
            Table(
                columnWidths: const {
                  0: FlexColumnWidth(
                      1.3), // Set width of column 0 to 3 times the width of other columns
                  1: FlexColumnWidth(
                      1), // Set width of column 1 to the same as other columns
                  2: FlexColumnWidth(
                      1), // Set width of column 1 to the same as other columns
                  3: FlexColumnWidth(
                      1.2), // Set width of column 1 to the same as other columns
                  4: FlexColumnWidth(
                      0.5), // Set width of column 1 to the same as other columns
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                      decoration: BoxDecoration(
                          color: c.dot_light_screen3,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10))),
                      children: [
                        TableCell(
                            child: Container(
                          height: 50,
                          child: Center(
                            child: Text(s.district,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: c.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                          ),
                        )),
                        TableCell(
                          child: Container(
                            height: 50,
                            child: Center(
                              child: Text(s.satisfied,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: c.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            height: 50,
                            child: Center(
                              child: Text(s.un_satisfied,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: c.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            height: 50,
                            child: Center(
                              child: Text(s.need_improvement,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: c.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ),
                        TableCell(
                            child: Container(height: 50, child: SizedBox())),
                      ]),
                ]),
            AnimationLimiter(
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    primary: false,
                    itemCount:
                        defaultWorklist.isEmpty ? 0 : defaultWorklist.length,
                    itemBuilder: (BuildContext context, int index) {
                      return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 800),
                          child: SlideAnimation(
                              horizontalOffset: 200.0,
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(
                                      1.3), // Set width of column 0 to 3 times the width of other columns
                                  1: FlexColumnWidth(
                                      1), // Set width of column 1 to the same as other columns
                                  2: FlexColumnWidth(
                                      1), // Set width of column 1 to the same as other columns
                                  3: FlexColumnWidth(
                                      1.2), // Set width of column 1 to the same as other columns
                                  4: FlexColumnWidth(
                                      0.5), // Set width of column 1 to the same as other columns
                                },
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  TableRow(
                                      decoration: BoxDecoration(
                                        color: index % 2 == 0
                                            ? c.white
                                            : c.full_transparent,
                                      ),
                                      children: [
                                        TableCell(
                                            child: Container(
                                          height: 50,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                  "${defaultWorklist[index][s.key_dname]}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: c.grey_10,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              Text(
                                                  "( ${defaultWorklist[index][s.total_inspected_works].toString()} )",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color:
                                                          c.primary_text_color2,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ],
                                          ),
                                        )),
                                        TableCell(
                                          child: Container(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                  defaultWorklist[index]
                                                          [s.key_satisfied]
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: defaultWorklist[
                                                                      index][
                                                                  s.key_satisfied] ==
                                                              0
                                                          ? c.grey_10
                                                          : c.primary_text_color2,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500)),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                  defaultWorklist[index]
                                                          [s.key_unsatisfied]
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: defaultWorklist[
                                                                      index][
                                                                  s.key_unsatisfied] ==
                                                              0
                                                          ? c.grey_10
                                                          : c.primary_text_color2,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500)),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                  defaultWorklist[index][s
                                                          .key_need_improvement]
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: defaultWorklist[
                                                                      index][
                                                                  s.key_need_improvement] ==
                                                              0
                                                          ? c.grey_10
                                                          : c.primary_text_color2,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500)),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: GestureDetector(
                                            onTap: () async {
                                              selectedDcode =
                                                  defaultWorklist[index]
                                                      [s.key_dcode];

                                              stateUI = false;
                                              districtUI = true;

                                              await fetchBlockWorklist();
                                              await __ModifiyUI();

                                              setState(() {});
                                            },
                                            child: Image.asset(imagePath.arrow_right,color: c.primary_text_color2,height: 22,width: 22,),
                                          ),
                                        ),
                                      ]),
                                ],
                              )));
                    })),
          ],
        ));
  }

  // ************************************* Village Worklist Loder Design ********************************* //

  __workListLoder() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 10),
        width: screenWidth * 0.9,
        child: Column(
          children: [
            Container(
              height: 40,
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: c.colorAccentveryverylight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: TextField(
                        onChanged: _onSearchQueryChanged,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: c.white),
                          hintText: 'Search Village...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(
                      Icons.search,
                      color: c.white,
                    ),
                  ),
                ],
              ),
            ),
            Card(
              color: c.white,
              margin: EdgeInsets.only(bottom: 5),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.satisfied1,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            s.satisfied,
                            style: TextStyle(
                                color: c.grey_8,
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.unsatisfied1,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            s.un_satisfied,
                            style: TextStyle(
                                color: c.grey_8,
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: c.need_improvement1,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            s.need_improvement,
                            style: TextStyle(
                                color: c.grey_8,
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AnimationLimiter(
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  primary: false,
                  itemCount: searchEnabled
                      ? _filteredVillage.length
                      : defaultWorklist.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = searchEnabled
                        ? _filteredVillage[index]
                        : defaultWorklist[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 800),
                      child: SlideAnimation(
                        horizontalOffset: 200.0,
                        child: FlipAnimation(
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 0),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            color: c.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 15),
                                  child: Align(
                                    alignment: AlignmentDirectional.topCenter,
                                    child: Text(
                                      urbanworkListUI
                                          ? "${item[dynamicTMC_Name]}"
                                          : "${item[s.key_pvname]}",
                                      style: TextStyle(
                                          color: c.text_color,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 10, bottom: 10),
                                  child: Align(
                                    alignment: AlignmentDirectional.topCenter,
                                    child: Text(
                                      "Total Inspected Works ( ${item[s.total_inspected_works]} )",
                                      style: TextStyle(
                                          color: c.grey_9,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          s.satisfied,
                                          style: TextStyle(
                                              color: c.grey_9,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ViewWorklist(
                                                          worklist: item,
                                                          flag: "S",
                                                          fromDate: from_Date,
                                                          toDate: to_Date,
                                                        )));
                                          },
                                          child: Container(
                                            height: 50,
                                            width: 100,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10),
                                            decoration: BoxDecoration(
                                                color: c.satisfied1,
                                                border: Border.all(
                                                    width: 2,
                                                    color: c.satisfied1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(
                                                        0.0, 1.0), //(x,y)
                                                    blurRadius: 3.0,
                                                  ),
                                                ]),
                                            child: Center(
                                              child: Text(
                                                "${item[s.key_satisfied]}",
                                                style: TextStyle(
                                                    color: c.black,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          s.un_satisfied,
                                          style: TextStyle(
                                              color: c.grey_9,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ViewWorklist(
                                                          worklist: item,
                                                          flag: "US",
                                                          fromDate: from_Date,
                                                          toDate: to_Date,
                                                        )));
                                          },
                                          child: Container(
                                            height: 50,
                                            width: 100,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10),
                                            decoration: BoxDecoration(
                                                color: c.unsatisfied1,
                                                border: Border.all(
                                                    width: 2,
                                                    color: c.unsatisfied1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(
                                                        0.0, 1.0), //(x,y)
                                                    blurRadius: 3.0,
                                                  ),
                                                ]),
                                            child: Center(
                                              child: Text(
                                                "${item[s.key_unsatisfied]}",
                                                style: TextStyle(
                                                    color: c.black,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          s.need_improvement,
                                          style: TextStyle(
                                              color: c.grey_9,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ViewWorklist(
                                                          worklist: item,
                                                          flag: "NI",
                                                          fromDate: from_Date,
                                                          toDate: to_Date,
                                                        )));
                                          },
                                          child: Container(
                                            height: 50,
                                            width: 100,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10),
                                            decoration: BoxDecoration(
                                                color: c.need_improvement1,
                                                border: Border.all(
                                                    width: 2,
                                                    color: c.need_improvement1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(
                                                        0.0, 1.0), //(x,y)
                                                    blurRadius: 3.0,
                                                  ),
                                                ]),
                                            child: Center(
                                              child: Text(
                                                "${item[s.key_need_improvement]}",
                                                style: TextStyle(
                                                    color: c.black,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  // ******************************************* Pichaart Design *************************************** //

  _Piechart() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Align(
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
                margin: EdgeInsets.only(top: 18),
                width: screenWidth * 0.9,
                child: Card(
                  color: c.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: Align(
                          alignment: AlignmentDirectional.topCenter,
                          child: Text(
                            header_name,
                            style: TextStyle(
                                color: c.grey_9,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Align(
                          alignment: AlignmentDirectional.topCenter,
                          child: Text(
                            "Total Inspected Works - $totalWorksCount",
                            style: TextStyle(
                                color: c.grey_9,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Align(
                          alignment: AlignmentDirectional.topCenter,
                          child: Text(
                            "Total ATR Pending Works - $atrCount",
                            style: TextStyle(
                                color: c.grey_9,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 230,
                        child: Stack(
                          children: [
                            Visibility(
                              visible: isPiechartAvailable,
                              child: SfCircularChart(
                                legend: Legend(
                                  isVisible: true,
                                  alignment: ChartAlignment.near,
                                  orientation: LegendItemOrientation.horizontal,
                                  position: LegendPosition.bottom,
                                ),
                                series: <CircularSeries>[
                                  DoughnutSeries<ChartData, String>(
                                    radius: "65",
                                    xValueMapper: (ChartData data, _) =>
                                        data.status,
                                    yValueMapper: (ChartData data, _) =>
                                        int.parse(data.count),
                                    dataSource: [
                                      ChartData('Satisfied', sCount,
                                          c.satisfied_color),
                                      ChartData('UnSatisfied', usCount,
                                          c.unsatisfied_color),
                                      ChartData('Need Improvement', nimpCount,
                                          c.need_improvement_color),
                                    ],
                                    legendIconType: LegendIconType.circle,
                                    dataLabelSettings: DataLabelSettings(
                                      isVisible: true,
                                      labelPosition:
                                          ChartDataLabelPosition.outside,
                                      connectorLineSettings:
                                          ConnectorLineSettings(
                                              color: Colors.black),
                                    ),
                                    pointColorMapper: (ChartData data, _) =>
                                        data.color,
                                    explode: false,
                                  )
                                ],
                              ),
                            ),
                            Visibility(
                                visible: !isPiechartAvailable,
                                child: Center(
                                  child: Text(
                                    s.no_data,
                                    style: TextStyle(
                                        color: c.yellow_new,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ))
                          ],
                        ),
                      )
                    ],
                  ),
                )),
            Positioned(
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                    color: c.need_improvement1,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: c.need_improvement, width: 1)),
                width: screenWidth * 0.5,
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
                            borderSide: BorderSide(
                                width: 0, color: c.need_improvement1),
                            borderRadius: BorderRadius.circular(30.0)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 0, color: c.need_improvement1),
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
              ),
            )
          ],
        ),
      ),
    );
  }

  // *************************************** API call Starts here *************************************** //

  Future<void> fetchTMCWorklist() async {
    try {
      utils.showProgress(context, 1);

      var userPassKey = prefs.getString(s.userPassKey);

      String service_key_tmc = "";
      String dynamicTMC_Name = "";
      if (tmcType == "T") {
        service_key_tmc = s.service_key_townpanchayat_list_district_wise;
        dynamicTMC_Name = s.key_townpanchayat_name;
      } else if (tmcType == "M") {
        service_key_tmc = s.service_key_municipality_list_district_wise;
        dynamicTMC_Name = s.key_municipality_name;
      } else if (tmcType == "C") {
        service_key_tmc = s.service_key_corporation_list_district_wise;
        dynamicTMC_Name = s.key_corporation_name;
      }

      Map jsonRequest = {
        s.key_service_id: service_key_tmc,
        s.key_dcode: prefs.getString(s.key_dcode),
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
      IOClient _ioClient = new IOClient(_client);
      var response = await _ioClient.post(url.master_service,
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

        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> tmc_details = userData[s.key_json_data];

          if (tmc_details.isNotEmpty) {
            //Empty the Worklist
            TMCworkList = [];

            tmc_details.sort((a, b) {
              return a[dynamicTMC_Name].compareTo(b[dynamicTMC_Name]);
            });

            TMCworkList.addAll(tmc_details);
          }
        } else if (status == s.key_ok && response_value == s.key_noRecord) {
          utils.customAlert(context, "W", s.no_data);

          setState(() {
            totalWorksCount = "0";
            nimpCount = "0";
            usCount = "0";
          });
        }
      }
    } catch (e) {
      if (e is FormatException) {
        utils.customAlert(context, "E", s.jsonError);
      }
    }
  }

  Future<void> fetchDistrictWorklist() async {
    try {
      utils.showProgress(context, 1);

      var userPassKey = prefs.getString(s.userPassKey);

      Map jsonRequest = {
        s.key_service_id: s.service_key_district_list_all,
        s.key_statecode: prefs.getString(s.key_statecode),
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
      IOClient _ioClient = new IOClient(_client);
      var response = await _ioClient.post(url.master_service,
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

        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> district_details = userData[s.key_json_data];

          if (district_details.isNotEmpty) {
            //Empty the Worklist
            districtworkList = [];

            district_details.sort((a, b) {
              return a[s.key_dname].compareTo(b[s.key_dname]);
            });

            districtworkList.addAll(district_details);
          }
        } else if (status == s.key_ok && response_value == s.key_noRecord) {
          utils.customAlert(context, "W", s.no_data);

          setState(() {
            totalWorksCount = "0";
            nimpCount = "0";
            usCount = "0";
          });
        }
      }
    } catch (e) {
      if (e is FormatException) {
        utils.customAlert(context, "E", s.jsonError);
      }
    }
  }

  Future<void> fetchBlockWorklist() async {
    try {
      String d_code = "";

      utils.showProgress(context, 1);

      widget.flag == "S"
          ? d_code = selectedDcode
          : d_code = prefs.getString(s.key_dcode).toString();

      var userPassKey = prefs.getString(s.userPassKey);

      Map jsonRequest = {
        s.key_service_id: s.service_key_block_list_district_wise,
        s.key_statecode: prefs.getString(s.key_statecode),
        s.key_dcode: d_code
      };

      Map encrpted_request = {
        s.key_user_name: prefs.getString(s.key_user_name),
        s.key_data_content:
            Utils().encryption(jsonEncode(jsonRequest), userPassKey.toString()),
      };

      print(" Json Request >>> $jsonRequest");

      print(" ENCCCC Request >>> $encrpted_request");

      HttpClient _client = HttpClient(context: await Utils().globalContext);
      _client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => false;
      IOClient _ioClient = new IOClient(_client);
      var response = await _ioClient.post(url.master_service,
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

        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> block_details = userData[s.key_json_data];

          if (block_details.isNotEmpty) {
            //Empty the Worklist
            blockworkList = [];

            block_details.sort((a, b) {
              return a[s.key_bname].compareTo(b[s.key_bname]);
            });

            blockworkList.addAll(block_details);
          }
        } else if (status == s.key_ok && response_value == s.key_noRecord) {
          utils.customAlert(context, "W", s.no_data);

          setState(() {
            totalWorksCount = "0";
            nimpCount = "0";
            usCount = "0";
          });
        }
      }
    } catch (e) {
      if (e is FormatException) {
        utils.customAlert(context, "E", s.jsonError);
      }
    }
  }

  Future<void> fetchVillageWorklist() async {
    try {
      utils.showProgress(context, 1);

      String? d_code = "";
      String? b_code = "";

      if (widget.flag == "B") {
        d_code = prefs.getString(s.key_dcode);
        b_code = prefs.getString(s.key_bcode);
      } else if (widget.flag == "D") {
        d_code = prefs.getString(s.key_dcode);
        b_code = selectedBcode;
      } else if (widget.flag == "S") {
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
      IOClient _ioClient = new IOClient(_client);
      var response = await _ioClient.post(url.master_service,
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

          setState(() {
            totalWorksCount = "0";
            nimpCount = "0";
            usCount = "0";
          });
        }
      }
    } catch (e) {
      if (e is FormatException) {
        utils.customAlert(context, "E", s.jsonError);
      }
    }
  }

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
        } else if (status == s.key_ok && response_value == s.key_noRecord) {
          utils.customAlert(context, "E", s.no_data);
          setState(() {
            totalWorksCount = "0";
            nimpCount = "0";
            usCount = "0";
            atrCount = "0";
            sCount = "0";
            isWorklistAvailable = false;
          });
        }
      }
    } catch (e) {
      if (e is FormatException) {
        utils.customAlert(context, "E", s.jsonError);
      }
    }
  }

  // *************************************** Modifiy UI Starts here *************************************** //

  __ModifiyUI() {
    if (work_details.isNotEmpty) {
      Map<String, dynamic> villageDashboard = {};
      Map<String, dynamic> districtDashboard = {};
      Map<String, dynamic> blockDashboard = {};
      Map<String, dynamic> tmcDashboard = {};
      int satisfied_count = 0;
      int unSatisfied_count = 0;
      int needImprovement_count = 0;

      int tempsatisfied_count = 0;
      int tempunSatisfied_count = 0;
      int tempneedImprovement_count = 0;

      int ATR_count = 0;

      //Empty the Worklist
      defaultWorklist = [];

      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
      work_details.sort((a, b) {
        //sorting in ascending order
        return inputFormat
            .parse(b[s.key_inspection_date])
            .compareTo(inputFormat.parse(a[s.key_inspection_date]));
      });

      if (urbanUI) {
        String? tempDcode = prefs.getString(s.key_dcode);
        urban_tp_s = 0;
        urban_mun_s = 0;
        urban_corp_s = 0;
        urban_tp_us = 0;
        urban_mun_us = 0;
        urban_corp_us = 0;
        urban_tp_nm = 0;
        urban_mun_nm = 0;
        urban_corp_nm = 0;

        for (int j = 0; j < work_details.length; j++) {
          if (work_details[j][s.key_dcode].toString() == tempDcode) {
            if (work_details[j][s.key_town_type] == "T") {
              if (work_details[j][s.key_status_id] == 1) {
                urban_tp_s = urban_tp_s + 1;
                satisfied_count = satisfied_count + 1;
              } else if (work_details[j][s.key_status_id] == 2) {
                if (work_details[j][s.key_action_status] == "N") {
                  ATR_count = ATR_count + 1;
                }
                urban_tp_us = urban_tp_us + 1;
                unSatisfied_count = unSatisfied_count + 1;
              } else if (work_details[j][s.key_status_id] == 3) {
                if (work_details[j][s.key_action_status] == "N") {
                  ATR_count = ATR_count + 1;
                }
                urban_tp_nm = urban_tp_nm + 1;
                needImprovement_count = needImprovement_count + 1;
              }
            }
            if (work_details[j][s.key_town_type] == "M") {
              if (work_details[j][s.key_status_id] == 1) {
                urban_mun_s = urban_mun_s + 1;
                satisfied_count = satisfied_count + 1;
              } else if (work_details[j][s.key_status_id] == 2) {
                if (work_details[j][s.key_action_status] == "N") {
                  ATR_count = ATR_count + 1;
                }
                urban_mun_us = urban_mun_us + 1;
                unSatisfied_count = unSatisfied_count + 1;
              } else if (work_details[j][s.key_status_id] == 3) {
                if (work_details[j][s.key_action_status] == "N") {
                  ATR_count = ATR_count + 1;
                }
                urban_mun_nm = urban_mun_nm + 1;
                needImprovement_count = needImprovement_count + 1;
              }
            }
            if (work_details[j][s.key_town_type] == "C") {
              if (work_details[j][s.key_status_id] == 1) {
                urban_corp_s = urban_corp_s + 1;
                satisfied_count = satisfied_count + 1;
              } else if (work_details[j][s.key_status_id] == 2) {
                if (work_details[j][s.key_action_status] == "N") {
                  ATR_count = ATR_count + 1;
                }
                urban_corp_us = urban_corp_us + 1;
                unSatisfied_count = unSatisfied_count + 1;
              } else if (work_details[j][s.key_status_id] == 3) {
                if (work_details[j][s.key_action_status] == "N") {
                  ATR_count = ATR_count + 1;
                }
                urban_corp_nm = urban_corp_nm + 1;
                needImprovement_count = needImprovement_count + 1;
              }
            }
          }
        }

        // int tempTotCount = urban_tp_s +
        //     urban_tp_us +
        //     urban_tp_nm +
        //     urban_mun_s +
        //     urban_mun_us +
        //     urban_mun_nm +
        //     urban_corp_s +
        //     urban_corp_us +
        //     urban_corp_nm;

        urban_tp_TC = urban_tp_s + urban_tp_us + urban_tp_nm;
        urban_mun_TC = urban_mun_s + urban_mun_us + urban_mun_nm;
        urban_corp_TC = urban_corp_s + urban_corp_us + urban_corp_nm;

        print(
            "######### TOWN ############ -  $urban_tp_TC = $urban_tp_s + $urban_tp_us + $urban_tp_nm");
        print(
            "######### MUN ############ -  $urban_mun_TC = $urban_mun_s + $urban_mun_us + $urban_mun_nm");
        print(
            "######### CORP ############ -  $urban_corp_TC = $urban_corp_s + $urban_corp_us + $urban_corp_nm");

        print("SATISFIED -  $satisfied_count");

        print("UNSATISFIED -  $unSatisfied_count");

        print("NEED IMP -  $needImprovement_count");

        isPiechartAvailable = true;
      }

      if (stateUI) {
        for (int i = 0; i < districtworkList.length; i++) {
          for (int j = 0; j < work_details.length; j++) {
            if (work_details[j][s.key_dcode].toString() ==
                districtworkList[i][s.key_dcode]) {
              if (work_details[j][s.key_status_id] == 1) {
                tempsatisfied_count = tempsatisfied_count + 1;
                satisfied_count = satisfied_count + 1;
              } else if (work_details[j][s.key_status_id] == 2) {
                if (work_details[j][s.key_action_status] == "N") {
                  ATR_count = ATR_count + 1;
                }
                tempunSatisfied_count = tempunSatisfied_count + 1;
                unSatisfied_count = unSatisfied_count + 1;
              } else if (work_details[j][s.key_status_id] == 3) {
                if (work_details[j][s.key_action_status] == "N") {
                  ATR_count = ATR_count + 1;
                }
                tempneedImprovement_count = tempneedImprovement_count + 1;
                needImprovement_count = needImprovement_count + 1;
              }
            }
          }

          int tempTotCount = tempsatisfied_count +
              tempunSatisfied_count +
              tempneedImprovement_count;

          if (tempTotCount > 0) {
            print(
                " $tempTotCount = $tempsatisfied_count + $tempunSatisfied_count + $tempneedImprovement_count ");

            districtDashboard = {
              s.key_dcode: districtworkList[i][s.key_dcode],
              s.key_dname: districtworkList[i][s.key_dname],
              s.total_inspected_works: tempTotCount,
              s.key_satisfied: tempsatisfied_count,
              s.key_unsatisfied: tempunSatisfied_count,
              s.key_need_improvement: tempneedImprovement_count
            };

            defaultWorklist.add(districtDashboard);
            isPiechartAvailable = true;
            tempsatisfied_count = 0;
            tempunSatisfied_count = 0;
            tempneedImprovement_count = 0;
          }
        }
      }

      if (districtUI) {
        for (int i = 0; i < blockworkList.length; i++) {
          for (int j = 0; j < work_details.length; j++) {
            if (work_details[j][s.key_dcode].toString() ==
                    blockworkList[i][s.key_dcode] &&
                work_details[j][s.key_bcode].toString() ==
                    blockworkList[i][s.key_bcode]) {
              if (work_details[j][s.key_status_id] == 1) {
                tempsatisfied_count = tempsatisfied_count + 1;
                satisfied_count = satisfied_count + 1;
              } else if (work_details[j][s.key_status_id] == 2) {
                if (work_details[j][s.key_action_status] == "N") {
                  ATR_count = ATR_count + 1;
                }
                tempunSatisfied_count = tempunSatisfied_count + 1;
                unSatisfied_count = unSatisfied_count + 1;
              } else if (work_details[j][s.key_status_id] == 3) {
                if (work_details[j][s.key_action_status] == "N") {
                  ATR_count = ATR_count + 1;
                }
                tempneedImprovement_count = tempneedImprovement_count + 1;
                needImprovement_count = needImprovement_count + 1;
              }
            }
          }

          int tempTotCount = tempsatisfied_count +
              tempunSatisfied_count +
              tempneedImprovement_count;

          if (tempTotCount > 0) {
            print(
                " $tempTotCount = $tempsatisfied_count + $tempunSatisfied_count + $tempneedImprovement_count ");

            blockDashboard = {
              s.key_dcode: blockworkList[i][s.key_dcode],
              s.key_bcode: blockworkList[i][s.key_bcode],
              s.key_bname: blockworkList[i][s.key_bname],
              s.total_inspected_works: tempTotCount,
              s.key_satisfied: tempsatisfied_count,
              s.key_unsatisfied: tempunSatisfied_count,
              s.key_need_improvement: tempneedImprovement_count
            };

            defaultWorklist.add(blockDashboard);
            isPiechartAvailable = true;

            tempsatisfied_count = 0;
            tempunSatisfied_count = 0;
            tempneedImprovement_count = 0;
          }
        }
      }

      if (blockUI) {
        for (int i = 0; i < villageworkList.length; i++) {
          for (int j = 0; j < work_details.length; j++) {
            if (work_details[j][s.key_dcode].toString() ==
                    villageworkList[i][s.key_dcode] &&
                work_details[j][s.key_bcode].toString() ==
                    villageworkList[i][s.key_bcode] &&
                work_details[j][s.key_pvcode].toString() ==
                    villageworkList[i][s.key_pvcode]) {
              if (work_details[j][s.key_status_id] == 1) {
                tempsatisfied_count = tempsatisfied_count + 1;
                satisfied_count = satisfied_count + 1;
              } else if (work_details[j][s.key_status_id] == 2) {
                if (work_details[j][s.key_action_status] == "N") {
                  ATR_count = ATR_count + 1;
                }
                tempunSatisfied_count = tempunSatisfied_count + 1;
                unSatisfied_count = unSatisfied_count + 1;
              } else if (work_details[j][s.key_status_id] == 3) {
                if (work_details[j][s.key_action_status] == "N") {
                  ATR_count = ATR_count + 1;
                }
                tempneedImprovement_count = tempneedImprovement_count + 1;
                needImprovement_count = needImprovement_count + 1;
              }
            }
          }
          int tempTotCount = tempsatisfied_count +
              tempunSatisfied_count +
              tempneedImprovement_count;

          if (tempTotCount > 0) {
            print(
                " $tempTotCount = $tempsatisfied_count + $tempunSatisfied_count + $tempneedImprovement_count ");

            villageDashboard = {
              s.key_dcode: villageworkList[i][s.key_dcode],
              s.key_bcode: villageworkList[i][s.key_bcode],
              s.key_pvcode: villageworkList[i][s.key_pvcode],
              s.key_pvname: villageworkList[i][s.key_pvname],
              s.total_inspected_works: tempTotCount,
              s.key_satisfied: tempsatisfied_count,
              s.key_unsatisfied: tempunSatisfied_count,
              s.key_need_improvement: tempneedImprovement_count
            };

            defaultWorklist.add(villageDashboard);
            isPiechartAvailable = false;
            isWorklistAvailable = true;
            tempsatisfied_count = 0;
            tempunSatisfied_count = 0;
            tempneedImprovement_count = 0;
          }
        }
      }

      if (urbanworkListUI) {
        String dynamicTMC_workList_ID = "";
        if (tmcType == "T") {
          dynamicTMC_workList_ID = s.key_tpcode;
          dynamicTMC_ID = s.key_townpanchayat_id;
          dynamicTMC_Name = s.key_townpanchayat_name;
        }
        if (tmcType == "M") {
          dynamicTMC_workList_ID = s.key_muncode;
          dynamicTMC_ID = s.key_municipality_id;
          dynamicTMC_Name = s.key_municipality_name;
        }
        if (tmcType == "C") {
          dynamicTMC_workList_ID = s.key_corcode;
          dynamicTMC_ID = s.key_corporation_id;
          dynamicTMC_Name = s.key_corporation_name;
        }

        for (int i = 0; i < TMCworkList.length; i++) {
          for (int j = 0; j < work_details.length; j++) {
            if (work_details[j][s.key_dcode].toString() ==
                    TMCworkList[i][s.key_dcode] &&
                work_details[j][dynamicTMC_workList_ID].toString() ==
                    TMCworkList[i][dynamicTMC_ID]) {
              if (work_details[j][s.key_status_id] == 1) {
                tempsatisfied_count = tempsatisfied_count + 1;
                satisfied_count = satisfied_count + 1;
              } else if (work_details[j][s.key_status_id] == 2) {
                if (work_details[j][s.key_action_status] == "N") {
                  ATR_count = ATR_count + 1;
                }
                tempunSatisfied_count = tempunSatisfied_count + 1;
                unSatisfied_count = unSatisfied_count + 1;
              } else if (work_details[j][s.key_status_id] == 3) {
                if (work_details[j][s.key_action_status] == "N") {
                  ATR_count = ATR_count + 1;
                }
                tempneedImprovement_count = tempneedImprovement_count + 1;
                needImprovement_count = needImprovement_count + 1;
              }
            }
          }

          int tempTotCount = tempsatisfied_count +
              tempunSatisfied_count +
              tempneedImprovement_count;

          if (tempTotCount > 0) {
            print(
                " $tempTotCount = $tempsatisfied_count + $tempunSatisfied_count + $tempneedImprovement_count ");

            tmcDashboard = {
              s.key_dcode: TMCworkList[i][s.key_dcode],
              dynamicTMC_ID: TMCworkList[i][dynamicTMC_ID],
              dynamicTMC_Name: TMCworkList[i][dynamicTMC_Name],
              s.key_town_type: tmcType,
              s.total_inspected_works: tempTotCount,
              s.key_satisfied: tempsatisfied_count,
              s.key_unsatisfied: tempunSatisfied_count,
              s.key_need_improvement: tempneedImprovement_count
            };

            defaultWorklist.add(tmcDashboard);
            isWorklistAvailable = true;
            isPiechartAvailable = false;
            tempsatisfied_count = 0;
            tempunSatisfied_count = 0;
            tempneedImprovement_count = 0;
          }
        }
      }

      print(
          "*********************************** Block Worklist *******************************************");

      print(blockworkList);

      print(
          "*********************************** Overall Worklist *******************************************");

      print(work_details);

      int tot_count =
          satisfied_count + unSatisfied_count + needImprovement_count;

      setState(() {
        sCount = satisfied_count.toString();
        usCount = unSatisfied_count.toString();
        nimpCount = needImprovement_count.toString();
        atrCount = ATR_count.toString();
        totalWorksCount = tot_count.toString();
      });
    }
  }

  // *************************************** Modifiy UI ends here *************************************** //
}

class ChartData {
  ChartData(this.status, this.count, this.color);
  final String status;
  final String count;
  final Color color;
}
