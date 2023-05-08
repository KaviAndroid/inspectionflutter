// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unnecessary_new, unrelated_type_equality_checks, sized_box_for_whitespace, avoid_types_as_parameter_names

import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/global.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../DataBase/DbHelper.dart';
import '../Utils/utils.dart';

class ViewOverallReport extends StatefulWidget {
  final flag, dcode, bcode;

  const ViewOverallReport({Key? key, this.flag, this.dcode, this.bcode})
      : super(key: key);
  @override
  State<ViewOverallReport> createState() => _ViewOverallReportState();
}

class _ViewOverallReportState extends State<ViewOverallReport> {
  //Bool Values
  bool isPiechartLoading = false;
  bool isWorklistAvailable = false;

  // Controller Text
  TextEditingController dateController = TextEditingController();

  //Date Time
  List<DateTime>? selectedDateRange;

  //List
  late List<ChartData> data;
  List defaultWorklist = [];
  List selectedworkList = [];
  List villageworkList = [];

  //String Vlues
  String header_name = "";
  String nimpCount = "";
  String usCount = "";
  String sCount = "";
  String atrCount = "";
  String totalWorksCount = "";
  String from_Date = "";
  String to_Date = "";

  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;

  Future<bool> _onWillPop() async {
    Navigator.of(context, rootNavigator: true).pop(context);
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
    dbClient = await dbHelper.db;
    loadWorkList();
  }

  Future<void> loadWorkList() async {
    final fromDate = DateTime.now();
    final endDate = fromDate.subtract(Duration(days: 60));

    from_Date = DateFormat('dd-MM-yyyy').format(fromDate);
    to_Date = DateFormat('dd-MM-yyyy').format(endDate);
    dateController.text = "$from_Date to $to_Date";
    await fetchVillageWorklist();
    await fetchOnlineOverallWroklist(from_Date, to_Date);

    if (widget.flag == "B") {
      header_name = "Block - ${prefs.getString(s.key_bname)}";
    } else if (widget.flag == "D") {
      header_name = "District - ${prefs.getString(s.key_dname)}";
    } else if (widget.flag == "S") {
      header_name = "District - ${prefs.getString(s.key_stateName)}";
    }
  }

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
        await fetchOnlineOverallWroklist(startDate, endDate);
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop(context),
            ),
            title: Text(s.over_all_inspection_report),
            centerTitle: true, // like this!
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _Piechart(),
                widget.flag == "B" ? __workListLoder() : SizedBox()
              ],
            ),
          ),
        ));
  }

  // ************************************* Village Worklist Loder Design ********************************* //

  __workListLoder() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
          color: c.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 5.0,
            ),
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 15),
            child: Align(
              alignment: AlignmentDirectional.topCenter,
              child: Text(
                header_name,
                style: TextStyle(
                    color: c.text_color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Align(
              alignment: AlignmentDirectional.topCenter,
              child: Text(
                "Total Inspected Works ( $totalWorksCount )",
                style: TextStyle(
                    color: c.grey_9, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    s.satisfied,
                    style: TextStyle(
                        color: c.grey_9,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  Container(
                    height: 50,
                    width: 100,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: c.satisfied1,
                        border: Border.all(width: 2, color: c.satisfied1),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 3.0,
                          ),
                        ]),
                    child: Center(
                      child: Text(
                        "8",
                        style: TextStyle(
                            color: c.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    s.un_satisfied,
                    style: TextStyle(
                        color: c.grey_9,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  Container(
                    height: 50,
                    width: 100,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: c.unsatisfied1,
                        border: Border.all(width: 2, color: c.unsatisfied1),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 3.0,
                          ),
                        ]),
                    child: Center(
                      child: Text(
                        "8",
                        style: TextStyle(
                            color: c.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    s.need_improvement,
                    style: TextStyle(
                        color: c.grey_9,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  Container(
                    height: 50,
                    width: 100,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        color: c.need_improvement1,
                        border:
                            Border.all(width: 2, color: c.need_improvement1),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 1.0), //(x,y)
                            blurRadius: 3.0,
                          ),
                        ]),
                    child: Center(
                      child: Text(
                        "8",
                        style: TextStyle(
                            color: c.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  // ******************************************* Pichaart Design *************************************** //

  _Piechart() {
    return Visibility(
      visible: isPiechartLoading,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
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
                                      'Satisfied', sCount, c.satisfied_color),
                                  ChartData('UnSatisfied', usCount,
                                      c.unsatisfied_color),
                                  ChartData('Need Improvement', nimpCount,
                                      c.need_improvement_color),
                                ],
                                legendIconType: LegendIconType.circle,
                                dataLabelSettings: DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.outside,
                                  connectorLineSettings: ConnectorLineSettings(
                                      color: Colors.black),
                                ),
                                pointColorMapper: (ChartData data, _) =>
                                    data.color,
                                explode: false,
                              )
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
      ),
    );
  }

  // *************************************** API call Starts here *************************************** //

  Future<void> fetchVillageWorklist() async {
    utils.showProgress(context, 1);

    String? d_code = "";
    String? b_code = "";

    if (widget.flag == "B") {
      d_code = prefs.getString(s.key_dcode);
      b_code = prefs.getString(s.key_bcode);
    } else if (widget.flag == "D") {
      d_code = prefs.getString(s.key_dcode);
      b_code = widget.bcode;
    } else if (widget.flag == "S") {
      d_code = widget.dcode;
      b_code = widget.bcode;
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

    if (response.statusCode == 200) {
      String responseData = response.body;

      var jsonData = jsonDecode(responseData);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = Utils().decryption(enc_data, userPassKey.toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];

      utils.hideProgress(context);

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
        utils.hideProgress(context);

        setState(() {
          totalWorksCount = "0";
          nimpCount = "0";
          usCount = "0";
        });
      }
    }
  }

  Future<void> fetchOnlineOverallWroklist(
      String fromDate, String toDate) async {
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

      if (status == s.key_ok && response_value == s.key_ok) {
        Map res_jsonArray = userData[s.key_json_data];
        List<dynamic> work_details = res_jsonArray[s.key_inspection_details];

        if (work_details.isNotEmpty) {
          int satisfied_count = 0;
          int unSatisfied_count = 0;
          int needImprovement_count = 0;
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

          for (int i = 0; i < villageworkList.length; i++) {
            for (int j = 0; j < work_details.length; j++) {
              print("2st");

              print((work_details[j][s.key_dcode]));
              print((work_details[j][s.key_bcode]));
              print((work_details[j][s.key_pvcode]));

              print("*********");

              print((villageworkList[i][s.key_dcode]));
              print((villageworkList[i][s.key_bcode]));
              print((villageworkList[i][s.key_pvcode]));

              if (work_details[j][s.key_dcode].toString() ==
                      villageworkList[i][s.key_dcode] &&
                  work_details[j][s.key_bcode].toString() ==
                      villageworkList[i][s.key_bcode] &&
                  work_details[j][s.key_pvcode].toString() ==
                      villageworkList[i][s.key_pvcode]) {
                print("3st");

                if (work_details[j][s.key_status_id] == 1) {
                  satisfied_count = satisfied_count + 1;
                } else if (work_details[j][s.key_status_id] == 2) {
                  if (work_details[j][s.key_action_status] == "N") {
                    ATR_count = ATR_count + 1;
                  }
                  unSatisfied_count = unSatisfied_count + 1;
                } else if (work_details[j][s.key_status_id] == 3) {
                  if (work_details[j][s.key_action_status] == "N") {
                    print("6st");

                    ATR_count = ATR_count + 1;
                  }
                  needImprovement_count = needImprovement_count + 1;
                }
              }

              Map<String, dynamic> villageDashboard = {
                s.key_satisfied: satisfied_count,
                s.key_unsatisfied: unSatisfied_count,
                s.key_need_improvement: needImprovement_count
              };

              Map<String, dynamic> updatedWorkDetail =
                  Map<String, dynamic>.from(work_details[j]);
              updatedWorkDetail.addAll(villageDashboard);

              defaultWorklist.add(updatedWorkDetail);

              print("def -  $defaultWorklist");

              __workListLoder();
            }
          }

          int tot_count =
              satisfied_count + unSatisfied_count + needImprovement_count;

          print(tot_count);

          setState(() {
            sCount = satisfied_count.toString();
            usCount = unSatisfied_count.toString();
            nimpCount = needImprovement_count.toString();
            atrCount = ATR_count.toString();
            totalWorksCount = tot_count.toString();
            isPiechartLoading = true;
          });
        }
      } else if (status == s.key_ok && response_value == s.key_noRecord) {
        utils.showAlert(context, s.no_data);
        setState(() {
          totalWorksCount = "0";
          nimpCount = "0";
          usCount = "0";
          atrCount = "0";
          sCount = "0";
          isPiechartLoading = true;
        });
      }
    }
  }
}

class ChartData {
  ChartData(this.status, this.count, this.color);
  final String status;
  final String count;
  final Color color;
}
