// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unnecessary_new, unrelated_type_equality_checks, sized_box_for_whitespace, avoid_types_as_parameter_names

import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:inspection_flutter_app/Activity/ViewWorklistScreen.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/global.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../DataBase/DbHelper.dart';
import '../Layout/OverallWorklistController.dart';
import '../Utils/utils.dart';

class ViewOverallReport extends StatefulWidget {
  final flag;

  const ViewOverallReport({Key? key, this.flag}) : super(key: key);
  @override
  State<ViewOverallReport> createState() => _ViewOverallReportState();
}

class _ViewOverallReportState extends State<ViewOverallReport> {
  // controller
  OverallWorklistController controllerOverall = OverallWorklistController();
  //Bool Values
  bool isWorklistAvailable = false;
  bool isPiechartAvailable = false;
  bool stateTableUI = false;
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
  List _filteredVillage = [];

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
  String selectedDname = "";
  String selectedBcode = "";
  String selectedBname = "";
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
  ScrollController scrollController = ScrollController();

  Future<bool> _onWillPop() async {
    if (prefs.getString(s.key_rural_urban) == "U") {
      if (blockUI) {
        goToBack();
      } else {
        Navigator.of(context, rootNavigator: true).pop(context);
      }
    } else {
      if (widget.flag == "S") {
        if (blockUI || districtUI) {
          goToBack();
        } else {
          Navigator.of(context, rootNavigator: true).pop(context);
        }
      } else if (widget.flag == "D") {
        if (blockUI) {
          goToBack();
        } else {
          Navigator.of(context, rootNavigator: true).pop(context);
        }
      } else if (widget.flag == "B") {
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
    if (prefs.getString(s.key_rural_urban) == "U") {
      urbanworkListUI = false;
      urbanUI = true;
      await controllerOverall.fetchTMCWorklist(context, tmcType);
    } else {
      if (widget.flag == "S") {
        print("asdasdasd");
        print(stateUI);
        print(blockUI);
        print(districtUI);
        print("asdasdasd");

        if (blockUI) {
          isWorklistAvailable = false;
          blockUI = false;
          selectedBcode = "";
          districtUI = true;

          await controllerOverall.fetchBlockWorklist(
              context, widget.flag, selectedDcode);
          controllerOverall.PieUpdation(selectedDname, "D");
        } else if (districtUI) {
          selectedDcode = "";
          districtUI = false;
          stateTableUI = true;
          stateUI = true;
          await controllerOverall.fetchDistrictWorklist(context);
          controllerOverall.PieUpdation("Tamil Nadu", "S");
        }
      } else if (widget.flag == "D") {
        if (isWorklistAvailable) {
          isWorklistAvailable = false;
          selectedBcode = "";
          blockUI = false;
          districtUI = true;

          await controllerOverall.fetchBlockWorklist(
              context, widget.flag, selectedDcode);
          controllerOverall.PieUpdation(selectedDname, "D");
        }
      }
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
        print("<<< Village >>>>");
        await controllerOverall.fetchVillageWorklist(
            context, widget.flag, selectedDcode, selectedBcode);
        controllerOverall.PieUpdation(
            prefs.getString(s.key_bname)!, widget.flag);
        stateUI = false;
        districtUI = false;
        blockUI = true;
      } else if (widget.flag == "D") {
        await controllerOverall.fetchBlockWorklist(
            context, widget.flag, selectedDcode);
        controllerOverall.PieUpdation(
            prefs.getString(s.key_dname)!, widget.flag);
        stateUI = false;
        districtUI = true;
        blockUI = false;
      } else if (widget.flag == "S") {
        await controllerOverall.fetchDistrictWorklist(context);
        controllerOverall.PieUpdation("Tamil Nadu", widget.flag);
        stateUI = true;
        districtUI = false;
        blockUI = false;
      }
    }

    await controllerOverall.fetchOnlineOverallWroklist(
        from_Date, to_Date, context);

    await __ModifiyUI();

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
        final lowerCaseQuery = _searchQuery.toLowerCase();
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
        await controllerOverall.fetchOnlineOverallWroklist(
            from_Date, to_Date, context);

        await __ModifiyUI();
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

  void gotToTop() {
    scrollController.animateTo(
        //go to top of scroll
        0, //scroll offset to go
        duration: Duration(milliseconds: 500), //duration of scroll
        curve: Curves.fastOutSlowIn //scroll type
        );
  }

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
            controller: scrollController,
            child: Column(
              children: [
                isPiechartAvailable ? _Piechart() : SizedBox(),
                urbanUI ? __TMCTable() : SizedBox(),
                stateTableUI ? __districtTable() : SizedBox(),
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
                                        if (urban_tp_TC > 0) {
                                          tmcType = "T";
                                          await controllerOverall
                                              .fetchTMCWorklist(
                                                  context, tmcType);
                                          urbanUI = false;
                                          urbanworkListUI = true;
                                          await __ModifiyUI();
                                          setState(() {});
                                        } else {
                                          utils.customAlert(context, "E",
                                              s.no_data_available);
                                        }
                                      },
                                      child: Image.asset(
                                        imagePath.arrow_right,
                                        color: c.primary_text_color2,
                                        height: 22,
                                        width: 22,
                                      ),
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
                                        if (urban_mun_TC > 0) {
                                          tmcType = "M";
                                          await controllerOverall
                                              .fetchTMCWorklist(
                                                  context, tmcType);
                                          urbanUI = false;
                                          urbanworkListUI = true;
                                          await __ModifiyUI();
                                          setState(() {});
                                        } else {
                                          utils.customAlert(context, "E",
                                              s.no_data_available);
                                        }
                                      },
                                      child: Image.asset(
                                        imagePath.arrow_right,
                                        color: c.primary_text_color2,
                                        height: 22,
                                        width: 22,
                                      ),
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
                                        if (urban_corp_TC > 0) {
                                          tmcType = "C";
                                          await controllerOverall
                                              .fetchTMCWorklist(
                                                  context, tmcType);
                                          urbanUI = false;
                                          urbanworkListUI = true;
                                          await __ModifiyUI();
                                          setState(() {});
                                        } else {
                                          utils.customAlert(context, "E",
                                              s.no_data_available);
                                        }
                                      },
                                      child: Image.asset(
                                        imagePath.arrow_right,
                                        color: c.primary_text_color2,
                                        height: 22,
                                        width: 22,
                                      ),
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
                                      stateTableUI = true;
                                      districtUI = false;
                                      controllerOverall.PieUpdation(
                                          "Tamil Nadu", "S");

                                      await controllerOverall
                                          .fetchDistrictWorklist(context);
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
                                              gotToTop();
                                              selectedBcode =
                                                  defaultWorklist[index]
                                                      [s.key_bcode];

                                              selectedDcode =
                                                  defaultWorklist[index]
                                                      [s.key_dcode];
                                              selectedBname =
                                                  defaultWorklist[index]
                                                      [s.key_bname];

                                              stateUI = false;
                                              stateTableUI = false;
                                              districtUI = false;
                                              blockUI = true;

                                              await controllerOverall
                                                  .fetchVillageWorklist(
                                                      context,
                                                      widget.flag,
                                                      selectedDcode,
                                                      selectedBcode);

                                              controllerOverall.PieUpdation(
                                                  selectedBname, "B");

                                              await __ModifiyUI();

                                              setState(() {});
                                            },
                                            child: Image.asset(
                                              imagePath.arrow_right,
                                              color: c.primary_text_color2,
                                              height: 22,
                                              width: 22,
                                            ),
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
                                              gotToTop();

                                              selectedDcode =
                                                  defaultWorklist[index]
                                                      [s.key_dcode];
                                              selectedDname =
                                                  defaultWorklist[index]
                                                      [s.key_dname];

                                              stateUI = false;
                                              stateTableUI = false;
                                              districtUI = true;

                                              await controllerOverall
                                                  .fetchBlockWorklist(
                                                      context,
                                                      widget.flag,
                                                      selectedDcode);
                                              controllerOverall.PieUpdation(
                                                  selectedDname, "D");

                                              await __ModifiyUI();

                                              setState(() {});
                                            },
                                            child: Image.asset(
                                              imagePath.arrow_right,
                                              color: c.primary_text_color2,
                                              height: 22,
                                              width: 22,
                                            ),
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
                        Text(
                          s.satisfied,
                          style: TextStyle(
                              color: c.grey_8,
                              fontSize: 13,
                              fontWeight: FontWeight.w400),
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
                        Text(
                          s.un_satisfied,
                          style: TextStyle(
                              color: c.grey_8,
                              fontSize: 13,
                              fontWeight: FontWeight.w400),
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
                        Text(
                          s.need_improvement,
                          style: TextStyle(
                              color: c.grey_8,
                              fontSize: 13,
                              fontWeight: FontWeight.w400),
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
                                            item[s.key_satisfied] > 0
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ViewWorklist(
                                                              worklist: item,
                                                              flag: "S",
                                                              fromDate:
                                                                  from_Date,
                                                              toDate: to_Date,
                                                            )))
                                                : utils.customAlert(context,
                                                    "E", s.no_data_available);
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
                                            item[s.key_unsatisfied] > 0
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ViewWorklist(
                                                              worklist: item,
                                                              flag: "US",
                                                              fromDate:
                                                                  from_Date,
                                                              toDate: to_Date,
                                                            )))
                                                : utils.customAlert(context,
                                                    "E", s.no_data_available);
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
                                            item[s.key_need_improvement] > 0
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ViewWorklist(
                                                              worklist: item,
                                                              flag: "NI",
                                                              fromDate:
                                                                  from_Date,
                                                              toDate: to_Date,
                                                            )))
                                                : utils.customAlert(context,
                                                    "E", s.no_data_available);
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
                margin: EdgeInsets.only(top: 18, left: 10, right: 10),
                // width: screenWidth * 0.9,
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
                            controllerOverall.headerName,
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
                                      ChartData('Need Impr..', nimpCount,
                                          c.need_improvement_color),
                                    ],
                                    legendIconType: LegendIconType.circle,
                                    dataLabelSettings: DataLabelSettings(
                                      showZeroValue: false,
                                      isVisible: true,
                                      labelPosition:
                                          ChartDataLabelPosition.outside,
                                      connectorLineSettings:
                                          ConnectorLineSettings(
                                              color: Colors.black),
                                    ),
                                    pointColorMapper: (ChartData data, _) =>
                                        data.color,
                                    explode: true,
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

  // *************************************** Modifiy UI Starts here *************************************** //

  __ModifiyUI() {
    utils.showProgress(context, 1);

    List<dynamic> work_details = controllerOverall.retriveWorklist();

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

        urban_tp_TC = urban_tp_s + urban_tp_us + urban_tp_nm;
        urban_mun_TC = urban_mun_s + urban_mun_us + urban_mun_nm;
        urban_corp_TC = urban_corp_s + urban_corp_us + urban_corp_nm;

        /*print(
            "######### TOWN ############ -  $urban_tp_TC = $urban_tp_s + $urban_tp_us + $urban_tp_nm");
        print(
            "######### MUN ############ -  $urban_mun_TC = $urban_mun_s + $urban_mun_us + $urban_mun_nm");
        print(
            "######### CORP ############ -  $urban_corp_TC = $urban_corp_s + $urban_corp_us + $urban_corp_nm");

        print("SATISFIED -  $satisfied_count");

        print("UNSATISFIED -  $unSatisfied_count");

        print("NEED IMP -  $needImprovement_count");*/

        isPiechartAvailable = true;
        isWorklistAvailable = false;
      }

      if (stateUI) {
        List districtworkList = controllerOverall.districtworkList;

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
            stateTableUI = true;
            isWorklistAvailable = false;
            tempsatisfied_count = 0;
            tempunSatisfied_count = 0;
            tempneedImprovement_count = 0;
          }
        }
      }

      if (districtUI) {
        List blockworkList = controllerOverall.blockworkList;

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
            isWorklistAvailable = false;

            tempsatisfied_count = 0;
            tempunSatisfied_count = 0;
            tempneedImprovement_count = 0;
          }
        }
      }

      if (blockUI) {
        List villageworkList = controllerOverall.villageworkList;

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
            isPiechartAvailable = true;
            isWorklistAvailable = true;
            tempsatisfied_count = 0;
            tempunSatisfied_count = 0;
            tempneedImprovement_count = 0;
          }
        }
      }

      if (urbanworkListUI) {
        List TMCworkList = controllerOverall.TMCworkList;

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
    utils.hideProgress(context);
  }

  // *************************************** Modifiy UI ends here *************************************** //
}

class ChartData {
  ChartData(this.status, this.count, this.color);
  final String status;
  final String count;
  final Color color;
}
