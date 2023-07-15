import 'dart:convert';
import 'dart:core';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/ATR_Save.dart';
import 'package:inspection_flutter_app/Activity/RdprOnlineWorkListFromFilter.dart';
import 'package:inspection_flutter_app/Activity/Work_detailed_ViewScreen.dart';
import 'package:inspection_flutter_app/Layout/ReadMoreLess.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../DataBase/DbHelper.dart';
import '../ModelClass/ModelClass.dart';
import '../Resources/ColorsValue.dart';
import '../Resources/ImagePath.dart';
import '../Resources/Strings.dart';
import '../Resources/global.dart';
import '../Utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import 'Home.dart';
import 'Pdf_Viewer.dart';
import 'RdprOnlineWorkListFromGeoLocation.dart';
import 'SaveWorkDetails.dart';

class ViewSavedATRReport extends StatefulWidget {
  @override
  final workList;
  final Flag;
  final flag;
  ViewSavedATRReport({this.workList, this.Flag, this.flag});
  State<ViewSavedATRReport> createState() => _ViewSavedATRState();
}

class _ViewSavedATRState extends State<ViewSavedATRReport> {
  List workList = [];
  List selectedATRworkList = [];
  List TownWorkList = [];
  List MunicipalityWorkList = [];
  List corporationWorklist = [];
  List needImprovementWorkList = [];
  List unSatisfiedWorkList = [];
  List satisfiedWorkList = [];
  List UrbanWorkList = [];
  List ImageList = [];
  late List<ChartData> data;
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  var appBarvisibility = true;
  var editvisibility = false;
  String WorkId = "";
  String inspectionID = "";
  String pdf_string_actual = "";
  String from_Date = "";
  String to_Date = "";
  String work_id = "";
  String town_type = "T";
  String inspection_id = "";
  String area_type = "";
  String flag_town_type = "";
  String inspection_date = "";
  String flag_tmc_id = "";
  String totalWorksCount = "";
  String nimpCount = " ";
  String usCount = "";
  String sCount = "";
  String townCount = " ";
  String munCount = "";
  String corpCount = "";
  String tappedValue = "";
  String inspectionid = "";
  String type = "";
  //bool Values
  bool isSpinnerLoading = true;
  bool isPiechartLoading = true;
  bool isSatisfiedActive = false;
  bool isNeedImprovementActive = false;
  bool isUnSatisfiedActive = false;
  bool townActive = true;
  bool munActive = false;
  bool corpActive = false;
  bool isWorklistAvailable = false;
  Uint8List? pdf;
  // Controller Text
  TextEditingController dateController = TextEditingController();
  TextEditingController workid = TextEditingController();
  TextEditingController search = TextEditingController();

  //Date Time
  DateTime? selectedFromDate;
  DateTime? selectedToDate;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString(s.onOffType, "online");
    dbClient = await dbHelper.db;
    loadWorkList();
    print("FLAG#####>>>>>>>>" + widget.Flag);
  }

  Future<void> loadWorkList() async {
    final fromDate = DateTime.now();
    final endDate = fromDate.subtract(Duration(days: 60));

    String toDate = DateFormat('dd-MM-yyyy').format(fromDate);
    String startDate = DateFormat('dd-MM-yyyy').format(endDate);
    from_Date = "$startDate";
    to_Date = "$toDate";
    dateController.text = "$from_Date to $to_Date";
    print("date>>>>" + dateController.text);
    await getWorkDetails(startDate, toDate);
    setState(() {
      isSpinnerLoading = false;
    });
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
        backgroundColor: c.ca1,
        appBar: AppBar(
          backgroundColor: c.colorPrimary,
          centerTitle: true,
          elevation: 2,
          automaticallyImplyLeading: true,
          title: Visibility(
              visible: appBarvisibility,
              child: Text(
                s.work_list,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )),

          /* actions: <Widget>[
            Padding(padding: EdgeInsets.only(top: 8),)
          ],*/
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Align(
              child: Column(
            children: [
              widget.Flag == "Urban Area"
                  ? __Urban_design()
                  : const SizedBox(
                      height: 10,
                    ),
              _DatePicker(),
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 5, 10),
                child: Padding(
                    padding: EdgeInsets.all(0),
                    child: Text(
                      s.or,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: c.grey_7),
                      textAlign: TextAlign.center,
                    )),
              ),
              _Workid(),
              isSpinnerLoading ? const SizedBox() : _Piechart(),
              _WorkList(),
              Container(
                alignment: AlignmentDirectional.center,
                child: Visibility(
                  visible: isWorklistAvailable == false ? true : false,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: Padding(
                          padding: EdgeInsets.all(80),
                          child: Text(
                            s.no_data,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ),
                ),
              )
            ],
          )),
        ),
      ),
    );
  }

/*_search()
{
  return Container(
    child:Visibility(
      visible: !searchvisibility,
      child: TextField(
        cursorColor: c.white,
        controller: search,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: Icon(
              Icons.search,),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: Icon(Icons.close),
          ),
        ),
      ),
    )
  );

}*/
  __Urban_design() {
    return Container(
      margin: EdgeInsets.only(top: 2, bottom: 2),
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
                    setState(() {
                      getWorkDetails(from_Date, to_Date);
                      dateController.text = "$from_Date to $to_Date";
                    });
                  },
                  child: Container(
                      // height: 35,
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(3),
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
                            Expanded(
                              child: Text(s.town_panchayat,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.justify,
                                  style: GoogleFonts.getFont('Roboto',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: townActive ? c.white : c.grey_6)),
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
                    setState(() {
                      getWorkDetails(from_Date, to_Date);
                      dateController.text = "$from_Date to $to_Date";
                    });
                  },
                  child: Container(
                      // height: 35,
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(3),
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
                                    fontSize: 13,
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
                    setState(() {
                      getWorkDetails(from_Date, to_Date);
                      dateController.text = "$from_Date to $to_Date";
                    });
                  },
                  child: Container(
                      // height: 35,
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(3),
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
                                    fontSize: 13,
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

  _DatePicker() {
    return Container(
      margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
      height: 45,
      child: Container(
        child: Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
          child: TextField(
              controller: dateController,
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixIconConstraints:
                    BoxConstraints(minHeight: 20, minWidth: 20),
                contentPadding:
                    EdgeInsets.only(left: 15, right: 5, top: 5, bottom: 5),
                filled: true,
                fillColor: c.grey_2,
                suffixIcon: Padding(
                  padding: EdgeInsets.all(5),
                  child: Image.asset(
                    imagePath.date_picker_icon,
                    height: 35,
                    width: 35,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 0.1, color: c.grey_2),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
              ),
              readOnly: true,
              onTap: () async {
                utils.ShowCalenderDialog(context).then((value) => {
                      if (value['flag'])
                        {
                          selectedFromDate = value['fromDate'],
                          selectedToDate = value['toDate'],
                          dateValidation()
                        }
                    });
              }),
        ),
      ),
    );
  }

  Future<void> dateValidation() async {
    workList.clear();
    workid.clear();
    String startDate = DateFormat('dd-MM-yyyy').format(selectedFromDate!);
    print("Start_date" + startDate);
    String endDate = DateFormat('dd-MM-yyyy').format(selectedToDate!);
    print("End_date" + endDate);
    from_Date = startDate;
    to_Date = endDate;
    print("Startdate>>>>>" + from_Date);
    print("Todate>>>>>" + to_Date);

    if (startDate.compareTo(endDate) > 0) {
      dateController.text = s.select_from_to_date;
    } else {
      dateController.text = "$startDate  To  $endDate";
      await getWorkDetails(from_Date, to_Date);
    }
  }

  _Workid() {
    workid.text.isEmpty
        ? dateController.text = "$from_Date to $to_Date"
        : dateController.text = "Select Date";
    return Container(
        margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
        height: 45,
        child: Container(
          child: Padding(
            padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
            child: TextField(
              controller: workid,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter Work id",
                contentPadding:
                    EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 5),
                filled: true,
                fillColor: c.grey_2,
                suffixIcon: Material(
                    elevation: 5.0,
                    color: c.dot_dark_screen5,
                    shadowColor: c.dot_dark_screen5,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (workid.text.isNotEmpty) {
                          getWorkDetails(from_Date, to_Date);
                        } else {
                          utils.showAlert(context, "Please enter a Work Id");
                        }
                      },
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: c.white,
                        size: 22,
                      ),
                    )),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 0.1, color: c.grey_2),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
              ),
            ),
          ),
        ));
  }

  _Piechart() {
    return Container(
        width: 370,
        child: Visibility(
            visible: false,
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
                  Container(
                      child: InkWell(
                          onTap: () {
                            getWorkDetails(from_Date, to_Date);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Align(
                              alignment: AlignmentDirectional.topCenter,
                              child: Text(
                                s.total_inspected_works =
                                    "Total Inspected Works(" +
                                        totalWorksCount +
                                        ")",
                                style: TextStyle(
                                    color: c.grey_9,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ))),
                  Container(
                    height: 230,
                    child: SfCircularChart(
                      legend: Legend(
                        isVisible: false,
                        toggleSeriesVisibility: false,
                        alignment: ChartAlignment.near,
                        orientation: LegendItemOrientation.horizontal,
                        position: LegendPosition.bottom,
                      ),
                      series: <CircularSeries>[
                        DoughnutSeries<ChartData, String>(
                            radius: "65",
                            xValueMapper: (ChartData data, _) => data.status,
                            yValueMapper: (ChartData data, _) =>
                                int.parse(data.count),
                            dataSource: [
                              ChartData('Satisfied', sCount, satisfied_color),
                              ChartData(
                                  'UnSatisfied', usCount, unsatisfied_color),
                              ChartData('Need Improvement', nimpCount,
                                  need_improvement_color),
                            ],
                            legendIconType: LegendIconType.circle,
                            dataLabelSettings: DataLabelSettings(
                              showZeroValue: false,
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside,
                              connectorLineSettings:
                                  ConnectorLineSettings(color: Colors.black),
                            ),
                            pointColorMapper: (ChartData data, _) => data.color,
                            explode: true,
                            onPointTap: (ChartData) {
                              tappedValue = ChartData.pointIndex.toString();
                              setState(() {
                                if (tappedValue == "0") {
                                  isNeedImprovementActive = false;
                                  isUnSatisfiedActive = false;
                                  isSatisfiedActive = true;
                                  workList = satisfiedWorkList;
                                } else if (tappedValue == "1") {
                                  isUnSatisfiedActive = true;
                                  isNeedImprovementActive = false;
                                  isSatisfiedActive = false;
                                  workList = unSatisfiedWorkList;
                                } else if (tappedValue == "2") {
                                  isUnSatisfiedActive = false;
                                  isSatisfiedActive = false;
                                  isNeedImprovementActive = true;
                                  workList = needImprovementWorkList;
                                }
                              });
                            })
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        utils.legendLableDesign(1,s.satisfied, c.satisfied_color),
                        utils.legendLableDesign(1,s.un_satisfied, c.unsatisfied_color),
                        utils.legendLableDesign(1,s.need_improvement, c.need_improvement_color),
                      ],
                    ),
                  )
                ],
              ),
            )));
  }

  _WorkList() {
    return Container(
        color: ca1,
        child: Padding(
          padding: EdgeInsets.only(top: 0, left: 8, right: 8),
          child: Stack(children: [
            Visibility(
              visible: isWorklistAvailable,
              child: Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: AnimationLimiter(
                      key: ValueKey(tappedValue),
                      child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: workList == null ? 0 : workList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 800),
                          child: SlideAnimation(
                              horizontalOffset: 200.0,
                              child: FlipAnimation(
                                child: InkWell(
                                  onTap: () async {
                                    if (await utils.isOnline()) {
                                      selectedATRworkList.clear();
                                      selectedATRworkList.add(workList[index]);
                                      print("SELECTED_ATR_WORKLIST>>>>" +
                                          selectedATRworkList.toString());
                                      print("WORK_ID###" +
                                          selectedATRworkList[0][s.key_work_id]
                                              .toString());
                                      getAtrWorkDetails();
                                    } else {
                                      utils.customAlertWidet(
                                          context, "Error", s.no_internet);
                                    }
                                  },
                                  child: Card(
                                      elevation: 5,
                                      color: c.colorAccentlight,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(15),
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      margin: EdgeInsets.fromLTRB(2, 12, 2, 10),
                                      child: ClipPath(
                                        clipper: ShapeBorderClipper(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20))),
                                        child: Container(
                                            child: Container(
                                          child: Column(children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .topStart,
                                                    child: Container(
                                                      height: 40,
                                                      width: 40,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  35),
                                                        ),
                                                        color: c.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                    child: InkWell(
                                                  onTap: () async {
                                                    if (await utils
                                                        .isOnline()) {
                                                      get_PDF(
                                                          workList[index][
                                                                  s.key_work_id]
                                                              .toString(),
                                                          workList[index][s
                                                                  .key_inspection_id]
                                                              .toString(),
                                                          workList[index][s
                                                                  .key_action_taken_id]
                                                              .toString());
                                                    } else {
                                                      utils.customAlertWidet(
                                                          context,
                                                          "Error",
                                                          s.no_internet);
                                                    }
                                                  },
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              20, 0, 5, 0),
                                                      child: Image.asset(
                                                        imagePath.pdf_icon,
                                                        height: 30,
                                                        width: 30,
                                                      ),
                                                    ),
                                                  ),
                                                ))
                                              ],
                                            ),
                                            Container(
                                              child: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 0,
                                                      bottom: 0,
                                                      left: 10,
                                                      right: 0),
                                                  child: Column(children: [
                                                    workListItem(
                                                        s.work_id,
                                                        workList[index]
                                                                [s.key_work_id]
                                                            .toString()),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    workListItem(
                                                        s.work_name,
                                                        workList[index][
                                                                s.key_work_name]
                                                            .toString()),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    workListItem(
                                                        s.ATRUploadedDate,
                                                        workList[index][s
                                                                .key_action_taken_date]
                                                            .toString()),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Column(
                                                      children: [
                                                        Visibility(
                                                          visible: utils.editdelayHours(
                                                              workList[index][s
                                                                      .key_ins_date]
                                                                  .toString()),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      Visibility(
                                                                    child:
                                                                        Align(
                                                                      alignment:
                                                                          AlignmentDirectional
                                                                              .bottomEnd,
                                                                      child: Container(
                                                                          height: 45,
                                                                          width: 45,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.only(
                                                                              topLeft: Radius.circular(70),
                                                                              bottomRight: Radius.circular(20),
                                                                            ),
                                                                            color:
                                                                                c.white,
                                                                          ),
                                                                          child: InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              if (await utils.isAutoDatetimeisEnable()) {
                                                                                if (await utils.isOnline()) {
                                                                                  await getSavedWorkDetails(workList[index][s.key_work_id].toString(), workList[index][s.key_inspection_id].toString(), workList[index][s.key_action_taken_id].toString());
                                                                                  selectedATRworkList.clear();
                                                                                  selectedATRworkList.add(workList[index]);
                                                                                  print('selectedATRworkList>>' + selectedATRworkList.toString());
                                                                                  Navigator.push(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                          builder: (context) => ATR_Save(
                                                                                                selectedWorklist: selectedATRworkList,
                                                                                                flag: "edit",
                                                                                                onoff_type: "online",
                                                                                                rural_urban: area_type,
                                                                                                imagelist: ImageList,
                                                                                              )));
                                                                                } else {
                                                                                  utils.customAlertWidet(context, "Error", s.no_internet);
                                                                                }
                                                                              } else {
                                                                                utils.customAlertWidet(context, "Error", "Please Enable Network Provided Time").then((value) => {
                                                                                      if (Platform.isAndroid)
                                                                                        {
                                                                                          utils.openDateTimeSettings()
                                                                                        }
                                                                                    });
                                                                              }

                                                                              /*   if(await utils.isOnline())
                                                                              {
                                                                               inspection_date= workList[index]["inspection_date"];
                                                                               town_type=workList[index]["town_type"];
                                                                                area_type=workList[index]["rural_urban"];
                                                                                if(area_type=="U")
                                                                                  {
                                                                                    flag_town_type=workList[index]["town_type"];
                                                                                    if(flag_town_type=="T")
                                                                                      {
                                                                                        flag_tmc_id=workList[index]["tpcode"].toString();
                                                                                      }
                                                                                    else if(flag_town_type=="M")
                                                                                    {
                                                                                      flag_tmc_id=workList[index]["muncode"].toString();
                                                                                    }
                                                                                    else
                                                                                      {
                                                                                        flag_tmc_id=workList[index]["corcode"].toString();
                                                                                      }
                                                                                  }
                                                                              }*/
                                                                              // getRDPRwork(work_id,inspection_id,area_type,flag_town_type,flag_tmc_id);
                                                                            },
                                                                            child:
                                                                                Visibility(
                                                                              child: Container(
                                                                                child: Padding(
                                                                                  padding: EdgeInsets.only(top: 15, left: 16, right: 5, bottom: 10),
                                                                                  child: Image.asset(imagePath.edit_icon),
                                                                                ),
                                                                                height: 25,
                                                                                width: 25,
                                                                              ),
                                                                            ),
                                                                          )),
                                                                    ),
                                                                  )),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ])),
                                            ),
                                          ]),
                                        )),
                                      )),
                                ),
                              )));
                    },
                  ))),
            ),
          ]),
        ));
  }

  workListItem(String name, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            name,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.normal, color: c.white),
            overflow: TextOverflow.clip,
            maxLines: 1,
            softWrap: true,
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Expanded(
          flex: 0,
          child: Text(
            ':',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.normal, color: c.white),
            overflow: TextOverflow.clip,
            maxLines: 1,
            softWrap: true,
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Expanded(
          flex: 2,
          child: ExpandableText(value, trimLines: 2, txtcolor: "1"),
        ),
        SizedBox(
          width: 10,
        ),
      ],
    );
  }

  Future<void> getWorkDetails(String fromDate, String toDate) async {
    if (await utils.isOnline()) {
      utils.showProgress(context, 1);
      prefs = await SharedPreferences.getInstance();
      setState(() {
        workList = [];
        isSpinnerLoading = true;
        isWorklistAvailable = false;
        isSatisfiedActive = false;
        isNeedImprovementActive = false;
        isUnSatisfiedActive = false;
        isPiechartLoading = false;
      });

      late Map json_request;
      String? key = prefs.getString(s.userPassKey);
      String? userName = prefs.getString(s.key_user_name);
      work_id = workid.text.toString();
      if (!work_id.isEmpty) {
        json_request = {
          s.key_work_id: work_id,
          s.key_service_id:
              s.service_key_date_wise_inspection_action_taken_details_view,
          s.key_rural_urban: prefs.getString(s.key_rural_urban),
          s.key_type: 1
        };
      } else if (dateController.text.toString().isNotEmpty) {
        json_request = {
          s.key_service_id:
              s.service_key_date_wise_inspection_action_taken_details_view,
          s.key_rural_urban: prefs.getString(s.key_rural_urban),
          s.key_from_date: fromDate,
          s.key_to_date: toDate,
          s.key_type: 2
        };
      }
      if (prefs.getString(s.key_rural_urban) == "U") {
        Map urbanRequest = {s.key_town_type: town_type};
        json_request.addAll(urbanRequest);
      }
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

      utils.hideProgress(context);
      print("ATRWorkList_url>>" + url.main_service_jwt.toString());
      print("ATRWorkList_request_json>>" + json_request.toString());
      print("ATRWorkList_request_encrpt>>" + encrypted_request.toString());
      String data = response.body;
      print("ATRWorkList_response>>" + data);
      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("ATRWorkList Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("ATRWorkList responceSignature -  $responceSignature");

      print("ATRWorkList responceData -  $responceData");

      if (responceSignature == responceData) {
        print("ATRWorkList responceSignature - Token Verified");
        var userData = jsonDecode(data);
        var status = userData[s.key_status];
        var response_value = userData[s.key_response];
        // utils.hideProgress(context);
        if (status == s.key_ok && response_value == s.key_ok) {
          isWorklistAvailable = true;
          Map res_jsonArray = userData[s.key_json_data];
          List<dynamic> RdprWorkList =
              res_jsonArray[s.key_inspection_action_taken_details];
          if (RdprWorkList.isNotEmpty) {
            satisfiedWorkList = [];
            unSatisfiedWorkList = [];
            needImprovementWorkList = [];
            /* RdprWorkList.sort((a,b ) {
          return a[s.key_ins_date].compareTo(b[s.key_ins_date]);
        });*/
            DateFormat inputFormat = DateFormat('dd-MM-yyyy HH:mm:ss');
            RdprWorkList.sort((a, b) {
              //sorting in ascending order
              return inputFormat
                  .parse(b[s.key_ins_date])
                  .compareTo(inputFormat.parse(a[s.key_ins_date]));
            });

            for (int i = 0; i < RdprWorkList.length; i++) {
              inspectionid = RdprWorkList[i][s.key_inspection_id].toString();
              print("inspectionid>>>>" + inspectionid);
              if (RdprWorkList[i][s.key_status_id] == 1) {
                satisfiedWorkList.add(RdprWorkList[i]);
              } else if (RdprWorkList[i][s.key_status_id] == 2) {
                unSatisfiedWorkList.add(RdprWorkList[i]);
              } else if (RdprWorkList[i][s.key_status_id] == 3) {
                needImprovementWorkList.add(RdprWorkList[i]);
              }
              if (RdprWorkList[i][s.key_rural_urban] == "U") {
                print("Image>>>>" + ImageList.toString());
                workList.add(RdprWorkList[i]);
                if (town_type == "T") {
                  TownWorkList = workList;
                } else if (town_type == "M") {
                  MunicipalityWorkList = workList;
                } else if (town_type == "C") {
                  corporationWorklist = workList;
                }
              } else {
                workList.add(RdprWorkList[i]);
              }
            }
          }
          totalWorksCount = workList.length.toString();
          sCount = satisfiedWorkList.length.toString();
          usCount = unSatisfiedWorkList.length.toString();
          nimpCount = needImprovementWorkList.length.toString();
          setState(() {
            if (prefs.getString(s.key_rural_urban) == "U") {
              if (satisfiedWorkList.isNotEmpty) {
                isSatisfiedActive = true;
                workList = satisfiedWorkList;
                print("satisfied>>>" + workList.toString());
              } else if (unSatisfiedWorkList.isNotEmpty) {
                isUnSatisfiedActive = true;
                workList = unSatisfiedWorkList;
                print("unSatisfied>>>" + workList.toString());
              } else if (needImprovementWorkList.isNotEmpty) {
                isNeedImprovementActive = true;
                workList = needImprovementWorkList;
                print("needImprovement>>>" + workList.toString());
              }
            }
            isSpinnerLoading = false;
            isPiechartLoading = false;
            isWorklistAvailable = true;
          });
        } else if (status == s.key_ok && response_value == s.key_noRecord) {
          setState(() {
            isSpinnerLoading = false;
            isPiechartLoading = false;
            totalWorksCount = "0";
            townCount = "0";
            munCount = "0";
            corpCount = "0";
            sCount = "0";
            nimpCount = "0";
            usCount = "0";
          });
        }
      } else {
        print("ATRWorkList responceSignature - Token Not Verified");
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
    } else {
      utils.customAlertWidet(context, "Error", s.no_internet);
    }
  }

  Future<void> get_PDF(
      String work_id, String inspection_id, String action_taken_id) async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    utils.showProgress(context, 1);
    var userPassKey = prefs.getString(s.userPassKey);

    Map jsonRequest = {
      s.key_service_id: s.service_key_get_action_taken_work_pdf,
      s.key_work_id: work_id,
      s.key_inspection_id: inspection_id,
      s.key_action_taken_id: action_taken_id,
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
    print("get_PDF_url>>" + url.main_service_jwt.toString());
    print("get_PDF_request_json>>" + jsonRequest.toString());
    print("get_PDF_request_encrpt>>" + encrypted_request.toString());
    utils.hideProgress(context);
    if (response.statusCode == 200) {
      String data = response.body;

      print("get_PDF_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("get_PDF Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("get_PDF responceSignature -  $responceSignature");

      print("get_PDF responceData -  $responceData");

      if (responceSignature == responceData) {
        print("get_PDF responceSignature - Token Verified");
        var userData = jsonDecode(data);
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
                      workID: work_id,
                      inspectionID: inspection_id,
                    )),
          );
        }
      } else {
        print("get_PDF responceSignature - Token Not Verified");
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
    }
  }

  Future<void> getSavedWorkDetails(
      String work_id, String inspection_id, String action_taken_id) async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    utils.showProgress(context, 1);
    prefs = await SharedPreferences.getInstance();
    late Map json_request;
    prefs.getString(s.key_rural_urban);
    json_request = {
      s.key_service_id:
          s.service_key_work_id_wise_inspection_action_taken_details_view,
      s.key_inspection_id: inspection_id,
      s.key_work_id: work_id,
      s.key_action_taken_id: action_taken_id,
      s.key_rural_urban: prefs.getString(s.key_rural_urban),
    };
    if (s.key_rural_urban == "U") {
      Map urban_request = {s.key_town_type: town_type};
      json_request.addAll(urban_request);
    }
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
    utils.hideProgress(context);
    print("ATRSavedWorkList_url>>" + url.main_service_jwt.toString());
    print("ATRSavedWorkList_request_json>>" + json_request.toString());
    print("ATRSavedWorkList_request_encrpt>>" + encrypted_request.toString());
    String data = response.body;
    print("ATRSavedWorkList_response>>" + data);
    String? authorizationHeader = response.headers['authorization'];

    String? token = authorizationHeader?.split(' ')[1];

    print("ATRSavedWorkList Authorization -  $token");

    String responceSignature = utils.jwt_Decode(key, token!);

    String responceData = utils.generateHmacSha256(data, key, false);

    print("ATRSavedWorkList responceSignature -  $responceSignature");

    print("ATRSavedWorkList responceData -  $responceData");

    if (responceSignature == responceData) {
      print("ATRSavedWorkList responceSignature - Token Verified");
      var userData = jsonDecode(data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      ImageList.clear();
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        if (res_jsonArray.length > 0) {
          for (int i = 0; i < res_jsonArray.length; i++) {
            for (int i = 0; i < res_jsonArray.length; i++) {
              List res_image = res_jsonArray[i][s.key_inspection_image];
              List<Map<String, String>> img_jsonArray = [];
              for (int j = 0; j < res_image.length; j++) {
                Map<String, String> mymap =
                    {}; // This created one object in the current scope.
                // First iteration , i = 0
                mymap["latitude"] = '0'; // Now mymap = { name: 'test0' };
                mymap["longitude"] = '0'; // Now mymap = { name: 'test0' };
                mymap["serial_no"] = res_image[j][s.key_serial_no]
                    .toString(); // Now mymap = { name: 'test0' };
                mymap["image_description"] = res_image[j]
                        [s.key_image_description]
                    .toString(); // Now mymap = { name: 'test0' };
                mymap["image"] = res_image[j][s.key_image].toString();
                mymap["image_path"] = '0'; // Now mymap = { name: 'test0' };
                img_jsonArray.add(mymap);
              }
              print("Res image>>>" + res_image.toString());
              ImageList.addAll(res_image);
              print("image_List>>>>>>" + ImageList.toString());
            }
          }
        }
      } else if (status == s.key_ok && response_value == s.key_noRecord) {
        utils.customAlertWidet(context, "Error", response_value);
      }
    } else {
      print("ATRSavedWorkList responceSignature - Token Not Verified");
      utils.customAlertWidet(context, "Error", s.jsonError);
    }
  }

  void refresh() {
    TownWorkList = [];
    MunicipalityWorkList = [];
    corporationWorklist = [];
    isWorklistAvailable = false;
  }

  Future<void> getAtrWorkDetails() async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    utils.showProgress(context, 1);
    prefs = await SharedPreferences.getInstance();
    late Map json_request;
    prefs.getString(s.key_rural_urban);
    json_request = {
      s.key_service_id:
          s.service_key_work_id_wise_inspection_action_taken_details_view,
      s.key_inspection_id: selectedATRworkList[0][s.key_inspection_id],
      s.key_work_id: selectedATRworkList[0][s.key_work_id],
      s.key_action_taken_id: selectedATRworkList[0][s.key_action_taken_id],
      s.key_rural_urban: prefs.getString(s.key_rural_urban),
    };
    if (prefs.getString(s.key_rural_urban) == "U") {
      Map urbanRequest = {s.key_town_type: town_type};
      json_request.addAll(urbanRequest);
    }
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

    utils.hideProgress(context);
    print("ATRWorkList_url>>" + url.main_service_jwt.toString());
    print("ATRWorkList_request_json>>" + json_request.toString());
    print("ATRWorkList_request_encrpt>>" + encrypted_request.toString());
    String data = response.body;
    print("ATRWorkList_response>>" + data);
    String? authorizationHeader = response.headers['authorization'];

    String? token = authorizationHeader?.split(' ')[1];

    print("ATRWorkList Authorization -  $token");

    String responceSignature = utils.jwt_Decode(key, token!);

    String responceData = utils.generateHmacSha256(data, key, false);

    print("ATRWorkList responceSignature -  $responceSignature");

    print("ATRWorkList responceData -  $responceData");
    if (responceSignature == responceData) {
      print("ATRWorkList responceSignature - Token Verified");
      var userData = jsonDecode(data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        if (res_jsonArray.length > 0) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Work_detailed_ViewScreen(
                        selectedATRWorkList: res_jsonArray,
                        flag: "atr",
                        imagelist: [],
                        selectedOtherWorkList: [],
                        selectedRDPRworkList: [],
                        town_type: town_type,
                      )));
        }
      } else if (status == s.key_ok && response_value == s.key_noRecord) {
        utils.customAlertWidet(context, "Error", response_value);
      }
    } else {
      print("ATRWorkList responceSignature - Token Not Verified");
      utils.customAlertWidet(context, "Error", s.jsonError);
    }
  }
}

class ChartData {
  ChartData(this.status, this.count, this.color);
  final String status;
  final String count;
  final Color color;
}
