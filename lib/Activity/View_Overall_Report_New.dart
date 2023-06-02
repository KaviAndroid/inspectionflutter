// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, camel_case_types, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:core';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:inspection_flutter_app/Activity/ViewWorklistScreen.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/global.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../DataBase/DbHelper.dart';
import '../Layout/OverallWorklistController.dart';
import '../Utils/utils.dart';

class Overall_Report_new extends StatefulWidget {
  final flag;

  const Overall_Report_new({Key? key, this.flag}) : super(key: key);

  @override
  State<Overall_Report_new> createState() => _Overall_Report_newState();
}

class _Overall_Report_newState extends State<Overall_Report_new> {
  // controller
  OverallWorklistController controllerOverall = OverallWorklistController();
  //Bool Values
  bool isWorklistAvailable = false;

  // Controller Text
  TextEditingController dateController = TextEditingController();
  ScrollController scrollController = ScrollController();

  //Date Time
  List<DateTime>? selectedDateRange;
  DateTime? startDate;
  DateTime? endDate;

  //List
  late List<ChartData> data;
  List villageworkList = [];
  List selectedworkList = [];

  //String Vlues
  String from_Date = "";
  String to_Date = "";
  String selectedDcode = "";
  String selectedDname = "";
  String selectedBcode = "";
  String selectedBname = "";
  String tmcType = "";
  String dynamicTMC_Name = "";

  //Urban int values

  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<bool> _onWillPop() async {
    if (prefs.getString(s.key_rural_urban) == "U") {
      if (controllerOverall.villageTableUI) {
        controllerOverall.villageTableUI = false;
        controllerOverall.TMCTableUI = true;
        tmcType = "";

        await controllerOverall.fetchOnlineOverallWroklist(
            controllerOverall.tmcFromDate!,
            controllerOverall.tmcToDate!,
            "tmc",
            context,
            selectedDcode,
            "0");
        dateController.text =
            "${controllerOverall.tmcFromDate} to ${controllerOverall.tmcToDate}";

        controllerOverall.PieUpdation(selectedDname, "D");

        setState(() {});
      } else if (controllerOverall.TMCTableUI) {
        controllerOverall.TMCTableUI = false;
        controllerOverall.districtTableUI = true;
        selectedDcode = "";

        await controllerOverall.fetchOnlineOverallWroklist(
            controllerOverall.urbanDistrictFromDate!,
            controllerOverall.urbanDistrictToDate!,
            "D",
            context,
            "0",
            "0");

        dateController.text =
            "${controllerOverall.urbanDistrictFromDate} to ${controllerOverall.urbanDistrictToDate}";

        controllerOverall.PieUpdation("Tamil Nade", "S");

        setState(() {});
      } else {
        Navigator.of(context, rootNavigator: true).pop(context);
      }
    } else {
      if (controllerOverall.villageTableUI) {
        controllerOverall.villageTableUI = false;
        controllerOverall.BlockTableUI = true;
        selectedBcode = "";
        selectedBname = "";

        await controllerOverall.fetchOnlineOverallWroklist(
            controllerOverall.blockFromDate!,
            controllerOverall.blockToDate!,
            "B",
            context,
            selectedDcode,
            "0");

        dateController.text =
            "${controllerOverall.blockFromDate} to ${controllerOverall.blockToDate}";

        controllerOverall.PieUpdation(selectedDname, "D");

        setState(() {});
      } else if (controllerOverall.BlockTableUI) {
        controllerOverall.BlockTableUI = false;
        controllerOverall.districtTableUI = true;
        selectedDcode = "";

        await controllerOverall.fetchOnlineOverallWroklist(
            controllerOverall.districtFromDate!,
            controllerOverall.districtToDate!,
            "D",
            context,
            "0",
            "0");

        dateController.text =
            "${controllerOverall.districtFromDate} to ${controllerOverall.districtToDate}";

        controllerOverall.PieUpdation("Tamil Nade", "S");

        setState(() {});
      } else {
        Navigator.of(context, rootNavigator: true).pop(context);
      }
    }
    return false;
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString(s.onOffType, "online");
    dbClient = await dbHelper.db;
    loadWorkList();
  }

  Future<void> loadWorkList() async {
    final endDate = DateTime.now();
    final fromDate = endDate.subtract(const Duration(days: 60));

    from_Date = DateFormat('dd-MM-yyyy').format(fromDate);
    to_Date = DateFormat('dd-MM-yyyy').format(endDate);

    dateController.text = "$from_Date to $to_Date";

    controllerOverall.PieUpdation("Tamil Nadu", "S");

    await controllerOverall.fetchOnlineOverallWroklist(
        from_Date, to_Date, "D", context, "0", "0");

    setState(() {});
  }

  // *************************** Date  Functions Starts here *************************** //

  Future<void> dateValidation() async {
    if (selectedDateRange != null) {
      DateTime sD = selectedDateRange![0];
      DateTime eD = selectedDateRange![1];

      from_Date = DateFormat('dd-MM-yyyy').format(sD);
      to_Date = DateFormat('dd-MM-yyyy').format(eD);

      if (sD.compareTo(eD) == 1) {
        utils.customAlert(
            context, "E", "End Date should be greater than Start Date");
      } else {
        dateController.text = "$from_Date  To  $to_Date";

        if (controllerOverall.districtTableUI) {
          controllerOverall.PieUpdation("Tamil Nadu", "S");

          await controllerOverall.fetchOnlineOverallWroklist(
              from_Date, to_Date, "D", context, "0", "0");
        }

        if (controllerOverall.BlockTableUI) {
          controllerOverall.PieUpdation(selectedDname, "D");

          await controllerOverall.fetchOnlineOverallWroklist(
              from_Date, to_Date, "B", context, selectedDcode, "0");
        }

        if (controllerOverall.villageTableUI) {
          if (prefs.getString(s.key_rural_urban) == "R") {
            controllerOverall.PieUpdation(selectedBname, "B");

            await controllerOverall.fetchOnlineOverallWroklist(
                from_Date, to_Date, "V", context, selectedDcode, selectedBcode);
          } else {
            if (tmcType == "T") {
              controllerOverall.PieUpdation(selectedDname, "D");

              await controllerOverall.fetchOnlineOverallWroklist(
                  from_Date, to_Date, "T", context, selectedDcode, "0");
            } else if (tmcType == "M") {
              controllerOverall.PieUpdation(selectedDname, "D");

              await controllerOverall.fetchOnlineOverallWroklist(
                  from_Date, to_Date, "M", context, selectedDcode, "0");
            } else if (tmcType == "C") {
              controllerOverall.PieUpdation(selectedDname, "D");

              await controllerOverall.fetchOnlineOverallWroklist(
                  from_Date, to_Date, "C", context, selectedDcode, "0");
            }
          }
        }

        if (controllerOverall.TMCTableUI) {
          controllerOverall.PieUpdation(selectedDname, "D");

          await controllerOverall.fetchOnlineOverallWroklist(
              from_Date, to_Date, "tmc", context, selectedDcode, "0");
        }
      }
      setState(() {});
    }
  }

  Future<void> _selectDateRange() async {
    selectedDateRange = await showOmniDateTimeRangePicker(
      context: context,
      type: OmniDateTimePickerType.date,
      startInitialDate: DateTime.now().subtract(const Duration(days: 60)),
      startFirstDate: DateTime(2000).subtract(const Duration(days: 3652)),
      startLastDate: DateTime.now(),
      endInitialDate: DateTime.now(),
      endLastDate: DateTime.now(),
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
                controllerOverall.pieChartUI ? _Piechart() : const SizedBox(),
                controllerOverall.TMCTableUI ? __TMCTable() : const SizedBox(),
                controllerOverall.districtTableUI
                    ? __districtTable()
                    : const SizedBox(),
                controllerOverall.BlockTableUI
                    ? __blockTable()
                    : const SizedBox(),
                controllerOverall.villageTableUI
                    ? _Village_TMCList()
                    : const SizedBox(),
              ],
            ),
          ),
        ));
  }

  // ************************************* TMC Worklist Loder Design ********************************* //

  __TMCTable() {
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
                                GestureDetector(
                                  onTap: () async {
                                    selectedDcode = "";
                                    controllerOverall.districtTableUI = true;
                                    controllerOverall.TMCTableUI = false;

                                    await controllerOverall
                                        .fetchOnlineOverallWroklist(
                                            controllerOverall
                                                .urbanDistrictFromDate!,
                                            controllerOverall
                                                .urbanDistrictToDate!,
                                            "D",
                                            context,
                                            "0",
                                            "0");

                                    dateController.text =
                                        "${controllerOverall.urbanDistrictFromDate} to ${controllerOverall.urbanDistrictToDate}";

                                    controllerOverall.PieUpdation(
                                        "Tamil Nadu", "S");

                                    setState(() {});
                                  },
                                  child: Icon(Icons.arrow_back_ios_new_rounded,
                                      size: 15, color: c.white),
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
                    itemCount: controllerOverall.TMCworkList.isEmpty
                        ? 0
                        : controllerOverall.TMCworkList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = controllerOverall.TMCworkList[index];
                      return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 800),
                          child: SlideAnimation(
                              horizontalOffset: 200.0,
                              child: GestureDetector(
                                onTap: () async {
                                  tmcType = item[s.key_town_type];
                                  await controllerOverall
                                      .fetchOnlineOverallWroklist(
                                          from_Date,
                                          to_Date,
                                          tmcType,
                                          context,
                                          selectedDcode,
                                          "");

                                  await controllerOverall.PieUpdation(
                                      selectedDname, "D");

                                  setState(() {});
                                },
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
                                                    item[s.key_town_type] == 'T'
                                                        ? s.town_panchayat
                                                        : item[s.key_town_type] ==
                                                                'M'
                                                            ? s.municipality
                                                            : s.corporation,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: c.grey_10,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                Text(
                                                    "( ${item[s.totalcount].toString()} )",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: c
                                                            .primary_text_color2,
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
                                                    item[s.key_satisfied]
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: item[s
                                                                    .key_satisfied] ==
                                                                0
                                                            ? c.grey_10
                                                            : c
                                                                .primary_text_color2,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Container(
                                              height: 50,
                                              child: Center(
                                                child: Text(
                                                    item[s.key_unsatisfied]
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: item[s
                                                                    .key_unsatisfied] ==
                                                                0
                                                            ? c.grey_10
                                                            : c
                                                                .primary_text_color2,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Container(
                                              height: 50,
                                              child: Center(
                                                child: Text(
                                                    item[s.key_need_improvement]
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: item[s
                                                                    .key_need_improvement] ==
                                                                0
                                                            ? c.grey_10
                                                            : c
                                                                .primary_text_color2,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Image.asset(
                                              imagePath.arrow_right,
                                              color: c.primary_text_color2,
                                              height: 22,
                                              width: 22,
                                            ),
                                          ),
                                        ]),
                                  ],
                                ),
                              )));
                    })),
          ],
        ));
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
                                  visible: true,
                                  child: GestureDetector(
                                    onTap: () async {
                                      selectedDcode = "";
                                      selectedDname = "";
                                      controllerOverall.districtTableUI = true;
                                      controllerOverall.BlockTableUI = false;

                                      await controllerOverall
                                          .fetchOnlineOverallWroklist(
                                              controllerOverall
                                                  .districtFromDate!,
                                              controllerOverall.districtToDate!,
                                              "D",
                                              context,
                                              "0",
                                              "0");

                                      dateController.text =
                                          "${controllerOverall.districtFromDate} to ${controllerOverall.districtToDate}";

                                      controllerOverall.PieUpdation(
                                          "Tamil Nadu", "S");

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
                    itemCount: controllerOverall.blockworkList.isEmpty
                        ? 0
                        : controllerOverall.blockworkList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = controllerOverall.blockworkList[index];
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
                                              Text("${item[s.key_bname]}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: c.grey_10,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              Text(
                                                  "( ${item[s.totalcount].toString()} )",
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
                                                  item[s.key_satisfied]
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: item[s
                                                                  .key_satisfied] ==
                                                              0
                                                          ? c.grey_10
                                                          : c
                                                              .primary_text_color2,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                  item[s.key_unsatisfied]
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: item[s
                                                                  .key_unsatisfied] ==
                                                              0
                                                          ? c.grey_10
                                                          : c
                                                              .primary_text_color2,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                  item[s.key_need_improvement]
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: item[s
                                                                  .key_need_improvement] ==
                                                              0
                                                          ? c.grey_10
                                                          : c
                                                              .primary_text_color2,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: GestureDetector(
                                            onTap: () async {
                                              gotToTop();
                                              selectedBcode =
                                                  item[s.key_bcode].toString();

                                              selectedDcode =
                                                  item[s.key_dcode].toString();
                                              selectedBname = item[s.key_bname];

                                              await controllerOverall
                                                  .fetchOnlineOverallWroklist(
                                                      from_Date,
                                                      to_Date,
                                                      "V",
                                                      context,
                                                      selectedDcode,
                                                      selectedBcode);

                                              await controllerOverall
                                                  .PieUpdation(
                                                      selectedBname, "B");

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
                    itemCount: controllerOverall.districtworkList.isEmpty
                        ? 0
                        : controllerOverall.districtworkList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = controllerOverall.districtworkList[index];
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
                                              Text("${item[s.key_dname]}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: c.grey_10,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              Text(
                                                  "( ${item[s.totalcount].toString()} )",
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
                                                  item[s.key_satisfied]
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: item[s
                                                                  .key_satisfied] ==
                                                              0
                                                          ? c.grey_10
                                                          : c
                                                              .primary_text_color2,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                  item[s.key_unsatisfied]
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: item[s
                                                                  .key_unsatisfied] ==
                                                              0
                                                          ? c.grey_10
                                                          : c
                                                              .primary_text_color2,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                  item[s.key_need_improvement]
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: item[s
                                                                  .key_need_improvement] ==
                                                              0
                                                          ? c.grey_10
                                                          : c
                                                              .primary_text_color2,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: GestureDetector(
                                            onTap: () async {
                                              gotToTop();

                                              selectedDcode =
                                                  item[s.key_dcode].toString();
                                              selectedDname = item[s.key_dname];

                                              if (prefs.getString(
                                                      s.key_rural_urban) ==
                                                  "R") {
                                                await controllerOverall
                                                    .fetchOnlineOverallWroklist(
                                                        from_Date,
                                                        to_Date,
                                                        "B",
                                                        context,
                                                        selectedDcode,
                                                        "0");
                                              } else {
                                                await controllerOverall
                                                    .fetchOnlineOverallWroklist(
                                                        from_Date,
                                                        to_Date,
                                                        "tmc",
                                                        context,
                                                        selectedDcode,
                                                        "0");
                                              }

                                              await controllerOverall
                                                  .PieUpdation(
                                                      selectedDname, "D");

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

  _Village_TMCList() {
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
                        onChanged: (String value) async {
                          await controllerOverall.onSearchQueryChanged(
                              value, tmcType);
                          setState(() {});
                        },
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
                  itemCount: controllerOverall.searchEnabled
                      ? controllerOverall.filteredVillage.length
                      : controllerOverall.villageworkList.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (prefs.getString(s.key_rural_urban) == "U") {
                      if (tmcType == "T") {
                        dynamicTMC_Name = s.key_townpanchayat_name;
                      } else if (tmcType == "M") {
                        dynamicTMC_Name = s.key_municipality_name;
                      } else if (tmcType == "C") {
                        dynamicTMC_Name = s.key_corporation_name;
                      }
                    }
                    final item = controllerOverall.searchEnabled
                        ? controllerOverall.filteredVillage.elementAt(index)
                        : controllerOverall.villageworkList[index];
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
                                      prefs.getString(s.key_rural_urban) == "U"
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
                                      "Total Inspected Works ( ${item[s.totalcount]} )",
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
                                                              tmcType: tmcType,
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
                                                              tmcType: tmcType,
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
                                                              tmcType: tmcType,
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
                            "Total Inspected Works - ${controllerOverall.totalWorksCount}",
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
                            "Total ATR Pending Works - ${controllerOverall.atrCount}",
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
                              visible: controllerOverall.pieChartUI,
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
                                      ChartData(
                                          'Satisfied',
                                          controllerOverall.sCount.toString(),
                                          c.satisfied_color),
                                      ChartData(
                                          'UnSatisfied',
                                          controllerOverall.usCount.toString(),
                                          c.unsatisfied_color),
                                      ChartData(
                                          'Need Impr..',
                                          controllerOverall.nimpCount
                                              .toString(),
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
                                visible: !controllerOverall.pieChartUI,
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
                            _selectDateRange();
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
                        _selectDateRange();
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
}

class ChartData {
  ChartData(this.status, this.count, this.color);
  final String status;
  final String count;
  final Color color;
}
