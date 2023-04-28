import 'dart:convert';
import 'dart:core';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/RdprOnlineWorkListFromFilter.dart';
import 'package:inspection_flutter_app/Activity/Work_detailed_ViewScreen.dart';
import 'package:inspection_flutter_app/Layout/ReadMoreLess.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
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

class ViewSavedRDPRReport extends StatefulWidget {
  @override
  final workList;
  final Flag;
  final flag;
  ViewSavedRDPRReport({this.workList, this.Flag, this.flag});
  State<ViewSavedRDPRReport> createState() => _ViewSavedRDPRState();
}
class _ViewSavedRDPRState extends State<ViewSavedRDPRReport> {
  List<DateTime>? selectedDateRange;
  List workList = [];
  List selectedworkList = [];
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
  //bool Values
  bool isSpinnerLoading = true;
  bool isPiechartLoading = true;
  bool isSatisfiedActive=false;
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
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
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
        appBar: AppBar(
          backgroundColor: c.colorPrimary,
          centerTitle: true,
          elevation: 2,
          automaticallyImplyLeading: true,
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 4,
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.center,
                  child: Container(
                    transform: Matrix4.translationValues(80, 2, 15),
                    alignment: Alignment.center,
                    child: Visibility(
                        visible: appBarvisibility,
                        child: Text(
                          s.work_list,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        )),
                  ),
                ),
              ],
            ),
          ),
          /* actions: <Widget>[
            Padding(padding: EdgeInsets.only(top: 8),)
          ],*/
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            height: 751,
            color: ca1,
              child: Column(
            children: [
              widget.Flag == "Urban Area"
                  ? __Urban_design()
                  : const SizedBox(
                      height: 10,
                    ),
              _DatePicker(),
              _Workid(),
              isSpinnerLoading ? const SizedBox() : _Piechart(),
              _WorkList(),
            ],
          )),
        ),
        /*body:Container(
            color: c.ca1,
            child: Stack(
              children: [
               IgnorePointer(
                   ignoring: isSpinnerLoading,
                   child: Column(
                     children: [
                       widget.Flag=="Urban Area"
                           ? __Urban_design():const SizedBox(
                         height: 10,
                       ),
                       _DatePicker(),
                       _Workid(),
                       _Piechart(),
                       _WorkList(),
                     ],
                   )
               ),
                Visibility(
                    visible: isSpinnerLoading,
                    child: Utils().showSpinner(context, "Processing"))
              ],
            )
        )*/
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
                            Text("Town Pancha...",
                                style: GoogleFonts.getFont('Roboto',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
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
                      height: 35,
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
                contentPadding: EdgeInsets.only(left: 15, right: 5, top: 5,bottom: 5),
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
                selectDateFunc();
              }),
        ),
      ),
    );
  }

  Future<void> dateValidation() async {
    if (selectedDateRange != null) {
      DateTime sD = selectedDateRange![0];
      DateTime eD = selectedDateRange![1];
      String startDate = DateFormat('dd-MM-yyyy').format(sD);
      print("Start_date" + startDate);
      String endDate = DateFormat('dd-MM-yyyy').format(eD);
      print("End_date" + endDate);
      from_Date = startDate;
      to_Date = endDate;
      print("Startdate>>>>>" + from_Date);
      print("Todate>>>>>" + to_Date);
      if (sD.compareTo(eD) == 1) {
        utils.showAlert(context, "End Date should be greater than Start Date");
      } else {
        dateController.text = "$startDate  To  $endDate";
        getWorkDetails(from_Date, to_Date);
      }
      if (startDate.compareTo(endDate) > 0) {
        dateController.text = s.select_from_to_date;
      } else {
        dateController.text = "$startDate  To  $endDate";
      }
    }
  }

  _Workid() {
    return Container(
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
                      getWorkDetails(from_Date,to_Date);
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
      child:Visibility(
        visible:  isPiechartLoading,
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
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Align(
                        alignment: AlignmentDirectional.topCenter,
                        child: Text(
                          s.total_inspected_works ="Total Inspected Works(" + totalWorksCount + ")",
                          style: TextStyle(
                              color: c.grey_9,
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    )),
                Container(
                  height: 230,
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
                          xValueMapper: (ChartData data, _) => data.status,
                          yValueMapper: (ChartData data, _) => int.parse(data.count),
                          dataSource: [
                                ChartData('Satisfied', sCount, satisfied_color),
                                ChartData('UnSatisfied', usCount, unsatisfied_color),
                                ChartData('Need Improvement', nimpCount,need_improvement_color),
                          ],
                          legendIconType: LegendIconType.circle,
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            connectorLineSettings:
                            ConnectorLineSettings(color: Colors.black),
                          ),
                          pointColorMapper: (ChartData data, _) => data.color,
                          explode:true,
                          onPointTap: (ChartData)
                          {
                            tappedValue = ChartData.pointIndex.toString();
                            setState(() {
                              if(tappedValue=="0")
                              {
                                isNeedImprovementActive=false;
                                isUnSatisfiedActive=false;
                                isSatisfiedActive=true;
                                workList=satisfiedWorkList;
                              }
                              else if(tappedValue=="1")
                              {

                                isUnSatisfiedActive=true;
                                isNeedImprovementActive=false;
                                isSatisfiedActive=false;
                                workList=unSatisfiedWorkList;
                              }
                              else if(tappedValue=="2")
                              {

                                isUnSatisfiedActive=false;
                                isSatisfiedActive=false;
                                isNeedImprovementActive=true;
                                workList=needImprovementWorkList;
                              }
                            });
                          }
                      )
                    ],
                  ),
                )
              ],
            ),
          )
      )

       );
  }
  _WorkList() {
    return Container(
      color: ca1,
        height: 300,
        child: Padding(
          padding: EdgeInsets.only(top: 0,left: 8,right: 8),
          child: Stack(
              children: [
            Visibility(
              visible: isWorklistAvailable,
              child: Container(
                  child: ListView.builder(
                    itemCount: workList == null ? 0 : workList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          selectedworkList.clear();
                          selectedworkList.add(workList[index]);
                          print('selectedworkList>>' +
                              selectedworkList.toString());
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Work_detailed_ViewScreen(
                                    selectedworkList: selectedworkList,
                                  )));
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
                            margin: EdgeInsets.fromLTRB(0, 7, 0, 0),
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
                                                decoration:
                                                BoxDecoration(
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
                                                onTap: () {
                                                  get_PDF(
                                                      workList[index][
                                                      s.key_work_id]
                                                          .toString(),
                                                      workList[index][s
                                                          .key_inspection_id]
                                                          .toString());
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
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      s.work_id,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          color: c.white),
                                                      overflow:
                                                      TextOverflow.clip,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Text(
                                                      ':',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          color: c.white),
                                                      overflow:
                                                      TextOverflow.clip,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                        workList[index]
                                                        [s.key_work_id]
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: c.white),
                                                        maxLines: 1),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      s.work_name,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          color: c.white),
                                                      overflow:
                                                      TextOverflow.clip,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Text(
                                                      ':',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          color: c.white),
                                                      overflow:
                                                      TextOverflow.clip,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      workList[index]
                                                      [s.key_work_name]
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: c.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      s.inspected_date,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          color: c.white),
                                                      overflow:
                                                      TextOverflow.clip,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Text(
                                                      ':',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          color: c.white),
                                                      overflow:
                                                      TextOverflow.clip,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      workList[index][s
                                                          .key_inspection_date]
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: c.white),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      s.work_status,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          color: c.white),
                                                      overflow:
                                                      TextOverflow.clip,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Text(
                                                      ':',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          color: c.white),
                                                      overflow:
                                                      TextOverflow.clip,
                                                      maxLines: 1,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      workList[index][
                                                      s.key_status_name]
                                                          .toString(),
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: c.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Column(
                                                children: [
                                                  Visibility(
                                                    visible: editdelayHours(
                                                        workList[index][s
                                                            .key_inspection_date]),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                            flex: 1,
                                                            child: Visibility(
                                                              child: Align(
                                                                alignment:
                                                                AlignmentDirectional
                                                                    .bottomEnd,
                                                                child:
                                                                Container(
                                                                    height:
                                                                    45,
                                                                    width:
                                                                    45,
                                                                    decoration:
                                                                    BoxDecoration(
                                                                      borderRadius:
                                                                      BorderRadius.only(
                                                                        topLeft:
                                                                        Radius.circular(70),
                                                                        bottomRight:
                                                                        Radius.circular(20),
                                                                      ),
                                                                      color:
                                                                      c.white,
                                                                    ),
                                                                    child:
                                                                    InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        Navigator.push(context,
                                                                            MaterialPageRoute(builder: (context) => SaveWorkDetails()));
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
                                                                        child:
                                                                        Container(
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
                      );
                    },
                  )),
            ),
            Visibility(
              visible: isWorklistAvailable == false ? true : false,
              child: Align(
                alignment: AlignmentDirectional.center,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    s.no_data,
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ]),
        ));
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

  Future<void> getWorkDetails(String fromDate, String toDate) async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      workList=[];
      isSpinnerLoading = true;
      isWorklistAvailable = false;
      isSatisfiedActive=false;
      isNeedImprovementActive = false;
      isUnSatisfiedActive = false;
    });

    late Map json_request;
    work_id = workid.text.toString();
    if (!work_id.isEmpty) {
      json_request = {
        s.key_work_id: work_id,
        s.key_service_id: s.service_key_date_wise_inspection_details_view,
        s.key_rural_urban: prefs.getString(s.area_type),
        s.key_type: 1
      };
    } else if (dateController.text.toString().isNotEmpty) {
      json_request = {
        s.key_service_id: s.service_key_date_wise_inspection_details_view,
        s.key_rural_urban: prefs.getString(s.area_type),
        s.key_from_date: fromDate,
        s.key_to_date: toDate,
        s.key_type: 2
      };
    }
    if (widget.Flag == "Urban Area") {
      Map urbanRequest = {s.key_town_type: town_type};
      json_request.addAll(urbanRequest);
    }
    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(
        url.main_service, body: json.encode(encrypted_request));
    print("WorkList_url>>" + url.main_service.toString());
    print("WorkList_request_json>>" + json_request.toString());
    print("WorkList_request_encrpt>>" + encrypted_request.toString());
    String data = response.body;
    print("WorkList_response>>" + data);
    var jsonData = jsonDecode(data);
    var enc_data = jsonData[s.key_enc_data];
    var decrpt_data =
    utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
    var userData = jsonDecode(decrpt_data);
    var status = userData[s.key_status];
    var response_value = userData[s.key_response];
    if (status == s.key_ok && response_value == s.key_ok) {
      isWorklistAvailable = true;
      Map res_jsonArray = userData[s.key_json_data];
      List<dynamic> RdprWorkList = res_jsonArray[s.key_inspection_details];
      if (RdprWorkList.isNotEmpty) {
        satisfiedWorkList=[];
        unSatisfiedWorkList=[];
        needImprovementWorkList=[];

        RdprWorkList.sort((a, b) {
          return a[s.key_work_id].compareTo(b[s.key_work_id]);
        });
        for (int i = 0; i < RdprWorkList.length; i++) {
          if (RdprWorkList[i][s.key_status_id]==1) {
            satisfiedWorkList.add(RdprWorkList[i]);
          } else if (RdprWorkList[i][s.key_status_id]==2) {
            unSatisfiedWorkList.add(RdprWorkList[i]);
          } else if (RdprWorkList[i][s.key_status_id]==3) {
            needImprovementWorkList.add(RdprWorkList[i]);
          }
          if(RdprWorkList[i][s.key_rural_urban]=="U")
          {
            print("Image>>>>"+ImageList.toString());
            workList.add(RdprWorkList[i]);
            if([s.key_town_type]=="T")
            {
              TownWorkList=workList;
            }
            else if([s.key_town_type]=="M")
            {
              MunicipalityWorkList=workList;
            }
            else if([s.key_town_type]=="C")
            {
              corporationWorklist=workList;
            }
          }
          else
            {
              workList.add(RdprWorkList[i]);
            }
        }
      }
      totalWorksCount = workList.length.toString();
      sCount = satisfiedWorkList.length.toString();
      usCount = unSatisfiedWorkList.length.toString();
      nimpCount = needImprovementWorkList.length.toString();
      setState(() {
        if(s.key_rural_urban=="U")
          {
            if(satisfiedWorkList.isNotEmpty)
            {
              isSatisfiedActive=true;
              workList=satisfiedWorkList;
              print("satisfied>>>"+workList.toString());
            }
            else if(unSatisfiedWorkList.isNotEmpty)
            {
              isUnSatisfiedActive=true;
              workList=unSatisfiedWorkList;
              print("unSatisfied>>>"+workList.toString());
            }
            else if(needImprovementWorkList.isNotEmpty) {
              isNeedImprovementActive=true;
              workList=needImprovementWorkList;
              print("needImprovement>>>"+workList.toString());
            }
          }
        isSpinnerLoading=false;
        isPiechartLoading=true;
        isWorklistAvailable=true;
      });
    }
    else if (status == s.key_ok && response_value == s.key_noRecord) {
      setState(() {
        isSpinnerLoading = false;
        isPiechartLoading=false;
        totalWorksCount = "0";
        townCount="0";
        munCount="0";
        corpCount="0";
        sCount="0";
        nimpCount = "0";
        usCount = "0";
      });
    }
  }
  Future<void> get_PDF(String work_id, String inspection_id) async {
    var userPassKey = prefs.getString(s.userPassKey);

    Map jsonRequest = {
      s.key_service_id: s.service_key_get_pdf,
      s.key_work_id: work_id,
      s.key_inspection_id: inspection_id,
    };
    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
      Utils().encryption(jsonEncode(jsonRequest), userPassKey.toString()),
    };

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service,
        body: json.encode(encrypted_request));

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
  }
  Future<void> getRDPRwork (String work_id, String inspection_id, String area_type, String flag_town_type, String flag_tmc_id)async {
    var userPassKey = prefs.getString(s.userPassKey);
    Map jsonRequest = {
      s.key_service_id: s.service_key_work_id_wise_inspection_details_view,
      s.key_work_id: work_id,
      s.key_inspection_id: inspection_id,
      s.key_rural_urban: area_type,
    };
    print("AREA_TYPE>>>"+s.key_rural_urban);
    print("JSON_REQUEST>>>>" + jsonRequest.toString());
    if (s.key_rural_urban == "U") {
      Map urbanRequest = {s.key_town_type: "town_type"};
      jsonRequest.addAll(urbanRequest);
      print("JSON_REQUEST>>>>" + jsonRequest.toString());
    }
    if (s.key_town_type == "T") {
      Map Request = {s.key_townpanchayat_id: "tpcode"
      };
      jsonRequest.addAll(Request);
    }
    else if (s.key_town_type == "M") {
      Map Request = {s.key_municipality_id: "muncode"
      };
      jsonRequest.addAll(Request);
    }
    else {
      Map Request = {s.key_corporation_id: "corcode"
      };
      jsonRequest.addAll(Request);
    }
    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
      Utils().encryption(jsonEncode(jsonRequest), userPassKey.toString()),
    };
    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service,
        body: json.encode(encrypted_request));

    if (response.statusCode == 200) {
      String responseData = response.body;
      var jsonData = jsonDecode(responseData);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = Utils().decryption(enc_data, userPassKey.toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        print("JSON_REQUEST>>>>" + jsonRequest.toString());
      }
    }
  }
  bool editdelayHours(String myDate){
    DateFormat inputFormat = DateFormat('dd-MM-yyyy');
    DateTime dateTimeLup = inputFormat.parse(myDate);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy hh:mm:ss').format(now);
    DateTime dateTimeNow = inputFormat.parse(formattedDate);
    bool flag = false;
    final differenceInDays = dateTimeNow.difference(dateTimeLup).inDays;
    final differenceInHours = dateTimeNow.difference(dateTimeLup).inHours;
    print('days>>' + '$differenceInDays');
    print('hours>>' + '$differenceInHours');
    if (differenceInHours < 48) {
      flag = true;
      editvisibility=!editvisibility;
    } else {
      flag = false;
      editvisibility=editvisibility;
    }
    return flag;
  }
  void refresh() {
    TownWorkList = [];
    MunicipalityWorkList = [];
    corporationWorklist = [];
    isWorklistAvailable = false;
  }
}

class ChartData {
  ChartData(this.status, this.count, this.color);
  final String status;
  final String count;
  final Color color;
}