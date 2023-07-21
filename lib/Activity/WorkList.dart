import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:InspectionAppNew/Activity/SaveWorkDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:InspectionAppNew/Resources/Strings.dart' as s;
import 'package:InspectionAppNew/Resources/ColorsValue.dart' as c;
import 'package:InspectionAppNew/Resources/ImagePath.dart' as imagePath;
import 'package:InspectionAppNew/Resources/url.dart' as url;

import '../DataBase/DbHelper.dart';
import '../Layout/ReadMoreLess.dart';
import '../Resources/Strings.dart';
import '../Utils/utils.dart';

class WorkList extends StatefulWidget {
  final schemeList;
  final finYear;
  final dcode;
  final bcode;
  final pvcode;
  final scheme;
  final flag;
  final tmccode;
  final townType;
  final selectedschemeList;
  final asvalue;

  WorkList(
      {this.schemeList,
      this.finYear,
      this.dcode,
      this.bcode,
      this.pvcode,
      this.scheme,
      this.tmccode,
      this.townType,
      this.selectedschemeList,
      this.flag,
      this.asvalue});
  @override
  State<WorkList> createState() => _WorkListState();
}

class _WorkListState extends State<WorkList> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  bool noDataFlag = false;
  bool workListFlag = false;
  List<bool> showFlag = [];
  List<bool> progressFlag = [];
  int flag = 1;
  List workListAll = [];
  List workList = [];
  List progressList = [];
  List ongoingWorkList = [];
  List completedWorkList = [];
  List selectedworkList = [];
  List schemeItems = [];
  List monthItems = [];
  String selectedScheme = "";
  String selectedMonth = "";
  String areaType = "";
  String as_value = "";
  bool isLoadingScheme = false;
  bool schemeError = false;
  bool schemeFlag = false;
  bool all = false;
  bool delay = false;
  bool flagB = false;
  bool flagV = false;
  bool flagT = false;
  bool flagM = false;
  bool flagC = false;
  bool flagTab = false;
  bool flagList = false;
  bool sidebarOpen = false;
  bool delaytab = false;

  double yOffset = 0;
  double xOffset = 0;
  double pageScale = 1;
  TextEditingController asController = TextEditingController();

  Map<String, String> defaultSelectedScheme = {
    s.key_scheme_id: "0",
    s.key_scheme_name: s.select_scheme
  };
  Map<String, String> defaultSelectedMonth = {'monthId': "00", 'month': '0'};

  @override
  void initState() {
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    // schemeItems.addAll(widget.schemeList);
    all = true;
    areaType = prefs.getString(s.key_rural_urban)!;
    if (areaType == 'R') {
      flagB = true;
      flagV = true;
      flagT = false;
      flagM = false;
      flagC = false;
    } else {
      flagB = false;
      flagV = false;
      if (widget.townType == "T") {
        flagT = true;
        flagM = false;
        flagC = false;
      } else if (widget.townType == "M") {
        flagT = false;
        flagM = true;
        flagC = false;
      } else if (widget.townType == "C") {
        flagT = false;
        flagM = false;
        flagC = true;
      }
    }
    if (widget.flag == 'rdpr_online') {
      if (await utils.isOnline()) {
        selectedScheme = widget.scheme;
        schemeFlag = false;
        await getWorkList(widget.finYear, widget.dcode, widget.bcode,
            widget.pvcode, widget.scheme);
      } else {
        utils.customAlertWidet(context, "Error", s.no_internet);
      }
    } else if (widget.flag == 'rdpr_offline') {
      schemeItems.addAll(widget.schemeList);
      selectedScheme = widget.scheme;
      schemeFlag = true;
      await fetchOfflineWorkList(areaType, widget.scheme);
    } else if (widget.flag == 'geo') {
      if (await utils.isOnline()) {
        schemeFlag = false;
        await getWorkListByVillage(widget.dcode, widget.bcode, widget.pvcode);
      } else {
        utils.customAlertWidet(context, "Error", s.no_internet);
      }
    } else if (widget.flag == 'tmc_online') {
      if (await utils.isOnline()) {
        schemeItems.addAll(widget.schemeList);
        selectedScheme = widget.scheme;
        schemeFlag = true;
        await getWorkListByTMC(widget.dcode, widget.tmccode, widget.townType,
            widget.selectedschemeList, widget.finYear);
      } else {
        utils.customAlertWidet(context, "Error", s.no_internet);
      }
    } else if (widget.flag == 'tmc_offline') {
      schemeItems.addAll(widget.schemeList);
      selectedScheme = widget.scheme;
      schemeFlag = true;
      await fetchOfflineWorkList(areaType, widget.scheme);
    } else if (widget.flag == 'delayed_works') {
      if (await utils.isOnline()) {
        delay = false;
        schemeFlag = false;
        flagTab = true;
        await getdelayedWorkListByVillage(widget.pvcode);
      } else {
        utils.customAlertWidet(context, "Error", s.no_internet);
      }
    }
    monthItems = [];
    monthItems.add(defaultSelectedMonth);
    for (int i = 0; i < 7; i++) {
      Map<String, String> mymap =
          {}; // This created one object in the current scope.
      // First iteration , i = 0
      mymap['monthId'] = (i + 1).toString(); // Now mymap = { name: 'test0' };
      mymap['month'] = (i + 1).toString(); // Now mymap = { name: 'test0' };
      monthItems.add(mymap);
    }
    print("months>>" + monthItems.toString());
    selectedMonth = defaultSelectedMonth['monthId']!;

    setState(() {});
  }

  void setSidebarState() {
    setState(() {
      xOffset = sidebarOpen ? 165 : 0;
      yOffset = sidebarOpen ? 70 : 0;
      pageScale = sidebarOpen ? 0.8 : 1;
    });
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context, rootNavigator: true).pop(context);
    return true;
  }

  @override
  Widget cardElememtWidget(
      BuildContext context, String title, String value, int index) {
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
            flex: title == s.financial_year ? 2 : 3,
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: ExpandableText(value, trimLines: 2,txtcolor: "2",),
              ),
            ),
          ),
          title == s.financial_year
              ? Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        showFlag[index] = !showFlag[index];
                      });
                    },
                    child: Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset(
                          imagePath.arrow_down_icon,
                          color: c.primary_text_color2,
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
      SizedBox(height: 10)
    ]);
  }

  @override
  Widget visiblityCardElememtWidget(BuildContext context, bool isVisible,
      String title, String value, int index) {
    return Visibility(
      visible: isVisible,
      child: Container(
        margin: EdgeInsets.only(top: 0),
        child: cardElememtWidget(context, title, value, index),
      ),
    );
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
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Container(
                      transform: Matrix4.translationValues(-30.0, 0.0, 0.0),
                      alignment: Alignment.center,
                      child: Text(
                        s.work_list,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            color: c.bg_screen,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Visibility(
                  visible: schemeFlag ? true : false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 15, left: 20, right: 20),
                        child: Text(
                          s.select_scheme,
                          style: GoogleFonts.getFont('Roboto',
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: c.grey_8),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        decoration: BoxDecoration(
                            color: c.grey_out,
                            border: Border.all(
                                width: schemeError ? 1 : 0.1,
                                color: schemeError ? c.red : c.grey_10),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: IgnorePointer(
                          ignoring: isLoadingScheme ? true : false,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              style: const TextStyle(color: Colors.black),
                              value: selectedScheme,
                              isExpanded: true,
                              items: schemeItems
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item[s.key_scheme_id].toString(),
                                        child: Text(
                                          item[s.key_scheme_name].toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) async {
                                if (value != "0") {
                                  isLoadingScheme = true;
                                  selectedScheme = value.toString();
                                  if (widget.flag == 'rdpr_online') {
                                    if (await utils.isOnline()) {
                                      await getWorkList(
                                          widget.finYear,
                                          widget.dcode,
                                          widget.bcode,
                                          widget.pvcode,
                                          selectedScheme);
                                    } else {
                                      utils.customAlertWidet(
                                          context, "Error", s.no_internet);
                                    }
                                  } else if (widget.flag == 'tmc_online') {
                                    if (await utils.isOnline()) {
                                      List schemeArray = [];
                                      Map<String, String> map = {
                                        s.key_scheme_id: selectedScheme,
                                      };
                                      schemeArray.add(map);
                                      await getWorkListByTMC(
                                          widget.dcode,
                                          widget.tmccode,
                                          widget.townType,
                                          schemeArray,
                                          widget.finYear);
                                    } else {
                                      utils.customAlertWidet(
                                          context, "Error", s.no_internet);
                                    }
                                  } else if (widget.flag == 'tmc_offline' ||
                                      widget.flag == 'rdpr_offline') {
                                    await fetchOfflineWorkList(
                                        areaType, selectedScheme);
                                  }

                                  setState(() {});
                                } else {
                                  setState(() {
                                    selectedScheme = value.toString();
                                    schemeError = true;
                                  });
                                }
                              },
                              buttonStyleData: const ButtonStyleData(
                                height: 45,
                                padding: EdgeInsets.only(right: 10),
                              ),
                              iconStyleData: IconStyleData(
                                icon: isLoadingScheme
                                    ? SpinKitCircle(
                                        color: c.colorPrimary,
                                        size: 30,
                                        duration:
                                            const Duration(milliseconds: 1200),
                                      )
                                    : const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black45,
                                      ),
                                iconSize: 30,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Visibility(
                        visible: schemeError ? true : false,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            s.please_enter_scheme,
                            // state.hasError ? state.errorText : '',
                            style: TextStyle(
                                color: Colors.redAccent.shade700,
                                fontSize: 12.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Visibility(
                    visible: delaytab,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () async {
                              flagTab = true;
                              flagList = true;
                              all = true;
                              delay = false;
                              selectedMonth = defaultSelectedMonth['monthId']!;
                              asController.text = '0';
                              await fetchWorkListAll();
                              setState(() {});
                            },
                            child: Container(
                                height: 35,
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    color: all ? c.colorAccentlight : c.white,
                                    border: Border.all(
                                        width: all ? 0 : 2,
                                        color: c.colorPrimary),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 5.0,
                                      ),
                                    ]),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Image.asset(
                                        imagePath.radio,
                                        color: all ? c.white : c.grey_5,
                                        width: 17,
                                        height: 17,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text("All Works",
                                          style: GoogleFonts.getFont('Roboto',
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                              color: all ? c.white : c.grey_6)),
                                    ])),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              flagTab = false;
                              flagList = false;
                              all = false;
                              delay = true;
                              selectedMonth = defaultSelectedMonth['monthId']!;
                              asController.text = '0';
                              setState(() {});
                            },
                            child: Container(
                                height: 35,
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    color: delay ? c.colorAccentlight : c.white,
                                    border: Border.all(
                                        width: delay ? 0 : 2,
                                        color: c.colorPrimary),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(0.0, 1.0), //(x,y)
                                        blurRadius: 5.0,
                                      ),
                                    ]),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Image.asset(
                                        imagePath.radio,
                                        color: delay ? c.white : c.grey_5,
                                        width: 17,
                                        height: 17,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text('Only Delayed Works',
                                          style: GoogleFonts.getFont('Roboto',
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                              color:
                                                  delay ? c.white : c.grey_6)),
                                    ])),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: delay,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: c.grey_out,
                              border: Border.all(width: 0.1, color: c.grey_10),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 10, left: 5, right: 0),
                                child: Text(
                                  'Month >=',
                                  style: GoogleFonts.getFont('Roboto',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: c.grey_8),
                                ),
                              ),
                              Container(
                                width: 70,
                                height: 30,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    style: const TextStyle(color: Colors.black),
                                    value: selectedMonth,
                                    isExpanded: true,
                                    items: monthItems
                                        .map((item) => DropdownMenuItem<String>(
                                              value: item['monthId'].toString(),
                                              child: Text(
                                                item['month'].toString(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) async {
                                      if (value != "00") {
                                        selectedMonth = value.toString();
                                        await fetchWorkList(
                                            'month', selectedMonth);
                                        setState(() {});
                                      } else {
                                        setState(() {
                                          selectedMonth = value.toString();
                                        });
                                      }
                                    },
                                    buttonStyleData: const ButtonStyleData(
                                      height: 45,
                                      padding: EdgeInsets.only(right: 10),
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '(or)',
                          style: GoogleFonts.getFont('Roboto',
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: c.grey_8),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                                color: c.grey_out,
                                border:
                                    Border.all(width: 0.1, color: c.grey_10),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, bottom: 0, left: 5, right: 0),
                                  child: Text(
                                    'AS Value >=',
                                    style: GoogleFonts.getFont('Roboto',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        color: c.grey_8),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    alignment: AlignmentDirectional.center,
                                    height: 30,
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 13),
                                      maxLines: 1,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      controller: asController,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        /* contentPadding:
                            const EdgeInsets.symmetric(vertical: 10, horizontal: 15),*/
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    selectedMonth =
                                        defaultSelectedMonth['monthId']!;
                                    utils.hideSoftKeyBoard(context);
                                    if (int.parse(asController.text) > 0) {
                                      fetchWorkList('as', asController.text);
                                    } else {
                                      utils.customAlertWidet(context, "Error",
                                          "Please Enter AS value");
                                    }
                                  },
                                  child: Container(
                                    width: 25,
                                    height: 30,
                                    alignment: Alignment.centerRight,
                                    decoration: BoxDecoration(
                                        color: c.colorPrimary,
                                        border: Border.all(
                                            width: 0, color: c.grey_10),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(0),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(0),
                                          bottomRight: Radius.circular(10),
                                        )),
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    child: Image.asset(
                                      imagePath.right_arrow_icon,
                                      fit: BoxFit.contain,
                                      color: c.white,
                                      height: 18,
                                      width: 18,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: flagTab,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              flag = 1;
                              if (ongoingWorkList.length > 0) {
                                workList = [];
                                workList.addAll(ongoingWorkList);
                                noDataFlag = false;
                                workListFlag = true;
                                showFlag = [];
                                for (int i = 0; i < workList.length; i++) {
                                  showFlag.add(false);
                                }
                                progressFlag = [];
                                for (int i = 0; i < workList.length; i++) {
                                  progressFlag.add(false);
                                }
                              } else {
                                workList = [];
                                showFlag = [];
                                progressFlag = [];
                                noDataFlag = true;
                                workListFlag = false;
                              }
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(20, 10, 0, 0),
                            padding: EdgeInsets.all(10),
                            height: 40,
                            width: MediaQuery.of(context).size.width,
                            alignment: AlignmentDirectional.center,
                            decoration: new BoxDecoration(
                                color: flag == 1 ? c.colorAccent : c.white,
                                borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(30),
                                  topRight: const Radius.circular(0),
                                  bottomLeft: const Radius.circular(30),
                                  bottomRight: const Radius.circular(0),
                                )),
                            child: Text(
                              s.ongoing_works +
                                  ' (' +
                                  ongoingWorkList.length.toString() +
                                  ') ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: flag == 1 ? c.white : c.grey_8,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              flag = 2;
                              if (completedWorkList.length > 0) {
                                workList = [];
                                workList.addAll(completedWorkList);
                                noDataFlag = false;
                                workListFlag = true;
                                showFlag = [];
                                for (int i = 0; i < workList.length; i++) {
                                  showFlag.add(false);
                                }
                                progressFlag = [];
                                for (int i = 0; i < workList.length; i++) {
                                  progressFlag.add(false);
                                }
                              } else {
                                workList = [];
                                showFlag = [];
                                progressFlag = [];
                                noDataFlag = true;
                                workListFlag = false;
                              }
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 20, 0),
                            padding: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            alignment: AlignmentDirectional.center,
                            decoration: new BoxDecoration(
                                color: flag == 2 ? c.colorAccent : c.white,
                                borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(0),
                                  topRight: const Radius.circular(30),
                                  bottomLeft: const Radius.circular(0),
                                  bottomRight: const Radius.circular(30),
                                )),
                            child: Text(
                              s.completed_works +
                                  ' (' +
                                  completedWorkList.length.toString() +
                                  ') ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: flag == 2 ? c.white : c.grey_8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: flagList,
                  child: Expanded(
                    child: Stack(children: [
                      Visibility(
                        visible: workListFlag,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: AnimationLimiter(
                            child: ListView.builder(
                              itemCount: workList == null ? 0 : workList.length,
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 800),
                                  child: SlideAnimation(
                                    horizontalOffset: 200.0,
                                    child: FlipAnimation(
                                        child: InkWell(
                                            onTap: () {},
                                            child: Card(
                                                elevation: 2,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),

                                                // clipBehavior is necessary because, without it, the InkWell's animation
                                                // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                                                // This comes with a small performance cost, and you should not set [clipBehavior]
                                                // unless you need it.
                                                clipBehavior: Clip.hardEdge,
                                                margin: EdgeInsets.fromLTRB(
                                                    0, 10, 0, 10),
                                                child: ClipPath(
                                                  clipper: ShapeBorderClipper(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3))),
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            10, 5, 5, 5),
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        left: BorderSide(
                                                            color:
                                                                c.colorAccent,
                                                            width: 5),
                                                      ),
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        Visibility(
                                                          visible:
                                                              !progressFlag[
                                                                  index],
                                                          child: Container(
                                                            child: Column(
                                                                children: [
                                                                  Container(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            GestureDetector(
                                                                              onTap: () async {
                                                                                if (await utils.isOnline()) {
                                                                                  await getProgressDetails(workList[index][s.key_work_id].toString(), index);
                                                                                } else {
                                                                                  utils.customAlertWidet(context, "Error", s.no_internet);
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                  transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
                                                                                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Image.asset(
                                                                                        imagePath.rising,
                                                                                        height: 20,
                                                                                        width: 20,
                                                                                      ),
                                                                                      Container(
                                                                                        padding: EdgeInsets.only(left: 15),
                                                                                        child: Text(
                                                                                          s.view_progress,
                                                                                          style: TextStyle(color: c.sky_blue),
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  )),
                                                                            ),
                                                                            Spacer(),
                                                                            InkWell(
                                                                              onTap: () {
                                                                                selectedworkList.clear();
                                                                                selectedworkList.add(workList[index]);
                                                                                print('selectedworkList>>' + selectedworkList.toString());

                                                                                Navigator.push(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                        builder: (context) => SaveWorkDetails(
                                                                                              selectedworkList: selectedworkList,
                                                                                              onoff_type: prefs.getString(s.onOffType),
                                                                                              rural_urban: prefs.getString(s.key_rural_urban),
                                                                                              townType: widget.townType,
                                                                                              flag: "worklist",
                                                                                              imagelist: [],
                                                                                            )));
                                                                              },
                                                                              child: Container(
                                                                                //transform: Matrix4.translationValues(20.0, 0.0, 0.0),
                                                                                width: 30,
                                                                                // padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                                                                child: Image.asset(
                                                                                  imagePath.ic_camera,
                                                                                  color: c.primary_text_color2,
                                                                                  height: 30,
                                                                                  width: 30,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        cardElememtWidget(
                                                                            context,
                                                                            s.work_id,
                                                                            workList[index][s.key_work_id].toString(),
                                                                            index),
                                                                        cardElememtWidget(
                                                                            context,
                                                                            s.work_name,
                                                                            workList[index][s.key_work_name].toString(),
                                                                            index),
                                                                        cardElememtWidget(
                                                                            context,
                                                                            s.stage_name,
                                                                            workList[index][s.key_stage_name].toString(),
                                                                            index),
                                                                        cardElememtWidget(
                                                                            context,
                                                                            s.work_type_name,
                                                                            workList[index][s.key_work_type_name].toString(),
                                                                            index),
                                                                        cardElememtWidget(
                                                                            context,
                                                                            s.scheme,
                                                                            workList[index][s.key_scheme_name].toString(),
                                                                            index),
                                                                        cardElememtWidget(
                                                                            context,
                                                                            s.financial_year,
                                                                            workList[index][s.key_fin_year].toString(),
                                                                            index),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    child: showFlag[
                                                                            index]
                                                                        ? Container(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                cardElememtWidget(context, s.district, workList[index][s.key_dname].toString(), index),
                                                                                visiblityCardElememtWidget(context, flagB, s.block, workList[index][s.key_bname].toString(), index),
                                                                                visiblityCardElememtWidget(context, flagV, s.village, workList[index][s.key_pvname].toString(), index),
                                                                                visiblityCardElememtWidget(context, flagT, s.town_panchayat, workList[index][s.key_townpanchayat_name].toString(), index),
                                                                                visiblityCardElememtWidget(context, flagM, s.municipality, workList[index][s.key_municipality_name].toString(), index),
                                                                                visiblityCardElememtWidget(context, flagC, s.corporation, workList[index][s.key_corporation_name].toString(), index),
                                                                                cardElememtWidget(context, s.as_value, workList[index][s.key_as_value].toString(), index),
                                                                                cardElememtWidget(context, s.ts_value, workList[index][s.key_ts_value].toString(), index),
                                                                                cardElememtWidget(context, s.agreement_work_orderdate, workList[index][s.key_work_order_date].toString(), index),
                                                                                cardElememtWidget(context, s.last_visited_date, workList[index][s.key_upd_date].toString(), index),
                                                                                cardElememtWidget(context, s.as_date, workList[index][s.key_as_date].toString(), index),
                                                                                cardElememtWidget(context, s.ts_date, workList[index][s.key_ts_date].toString(), index),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        : SizedBox(),
                                                                  ),
                                                                ]),
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: progressFlag[
                                                              index],
                                                          child: Container(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    InkWell(
                                                                      onTap:
                                                                          () {},
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            10,
                                                                        height:
                                                                            30,
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              0,
                                                                          height:
                                                                              0,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        for (int i =
                                                                                0;
                                                                            i < progressFlag.length;
                                                                            i++) {
                                                                          if (i ==
                                                                              index) {
                                                                            progressFlag[i] =
                                                                                !progressFlag[index];
                                                                          } else {
                                                                            progressFlag[i] =
                                                                                false;
                                                                          }
                                                                        }
                                                                        setSidebarState();
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        child: Image
                                                                            .asset(
                                                                          imagePath
                                                                              .back_arrow,
                                                                          color:
                                                                              c.primary_text_color2,
                                                                          height:
                                                                              20,
                                                                          width:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                        padding: EdgeInsets.only(
                                                                            left:
                                                                                70),
                                                                        alignment:
                                                                            Alignment
                                                                                .center,
                                                                        child:
                                                                            Text(
                                                                          workList[index][s.key_work_id]
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(color: c.sky_blue),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        )),
                                                                  ],
                                                                ),
                                                                ListView
                                                                    .builder(
                                                                        shrinkWrap:
                                                                            true,
                                                                        itemCount: progressList ==
                                                                                null
                                                                            ? 0
                                                                            : progressList
                                                                                .length,
                                                                        itemBuilder:
                                                                            (BuildContext context,
                                                                                int index) {
                                                                          return Column(
                                                                              children: [
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      flex: 1,
                                                                                      child: Text(
                                                                                        progressList[index][s.key_date].toString(),
                                                                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c.grey_8),
                                                                                        overflow: TextOverflow.clip,
                                                                                        maxLines: 1,
                                                                                        softWrap: true,
                                                                                      ),
                                                                                    ),
                                                                                    Expanded(
                                                                                      flex: 1,
                                                                                      child: Image.asset(
                                                                                        imagePath.circle,
                                                                                        height: 13,
                                                                                        width: 13,
                                                                                      ),
                                                                                    ),
                                                                                    Expanded(
                                                                                      flex: 3,
                                                                                      child: Container(
                                                                                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                                        child: Align(
                                                                                          alignment: AlignmentDirectional.topStart,
                                                                                          child: Text(
                                                                                            progressList[index][s.key_stage_name].toString(),
                                                                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c.grey_7),
                                                                                            overflow: TextOverflow.clip,
                                                                                            maxLines: 2,
                                                                                            softWrap: true,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      flex: 1,
                                                                                      child: Text(
                                                                                        '',
                                                                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c.grey_8),
                                                                                        overflow: TextOverflow.clip,
                                                                                        maxLines: 1,
                                                                                        softWrap: true,
                                                                                      ),
                                                                                    ),
                                                                                    Expanded(
                                                                                      flex: 1,
                                                                                      child: Visibility(
                                                                                          visible: progressList[index][s.key_stage_name] == "Not Started" ? false : true,
                                                                                          child: Image.asset(
                                                                                            imagePath.arrow_up_icon,
                                                                                            height: 40,
                                                                                            width: 10,
                                                                                            color: c.colorAccent,
                                                                                          )),
                                                                                    ),
                                                                                    Expanded(
                                                                                        flex: 3,
                                                                                        child: Visibility(
                                                                                          visible: progressList[index][s.key_stage_name] == "Not Started" ? false : true,
                                                                                          child: Container(
                                                                                            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                                                            child: Align(
                                                                                              alignment: AlignmentDirectional.topStart,
                                                                                              child: Text(
                                                                                                progressList[index][s.key_days].toString() + " " + s.key_days,
                                                                                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c.grey_8),
                                                                                                overflow: TextOverflow.clip,
                                                                                                maxLines: 1,
                                                                                                softWrap: true,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        )),
                                                                                  ],
                                                                                ),
                                                                              ]);
                                                                        }),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )))),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: noDataFlag,
                        child: Align(
                          alignment: AlignmentDirectional.center,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              s.no_data,
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      )
                    ]),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Future<void> getWorkList(List finYear, String dcode, String bcode,
      String pvcode, String scheme) async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    utils.showProgress(context, 1);
    late Map json_request;

    Map work_detail = {
      s.key_fin_year: finYear,
      s.key_dcode: dcode,
      s.key_bcode: bcode,
      s.key_pvcode: [pvcode],
      s.key_scheme_id: [scheme],
      s.key_flag: "2"
    };
    json_request = {
      s.key_service_id: s.service_key_get_inspection_work_details,
      s.key_inspection_work_details: work_detail,
    };

    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: json_request
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

    print("WorkList_url>>" + url.main_service_jwt.toString());
    print("WorkList_request_encrypt>>" + encrypted_request.toString());
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    utils.hideProgress(context);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;

      print("WorkList_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("WorkList Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("WorkList responceSignature -  $responceSignature");

      print("WorkList responceData -  $responceData");
      if (responceSignature == responceData) {
        print("WorkList responceSignature - Token Verified");
        var userData = jsonDecode(data);

        var status = userData[s.key_status];
        var response_value = userData[s.key_response];

        if (status == s.key_ok && response_value == s.key_ok) {
          print("test------>>" + userData[s.key_json_data].toString());
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          res_jsonArray.sort((a, b) {
            return a[s.key_work_id].compareTo(b[s.key_work_id]);
          });
          if (res_jsonArray.length > 0) {
            flagTab = true;
            flagList = true;
            ongoingWorkList = [];
            completedWorkList = [];
            workListAll = [];
            workList = [];
            for (int i = 0; i < res_jsonArray.length; i++) {
              if (res_jsonArray[i][s.key_current_stage_of_work] == 11) {
                completedWorkList.add(res_jsonArray[i]);
              } else {
                ongoingWorkList.add(res_jsonArray[i]);
              }
              workListAll.add(res_jsonArray[i]);
            }

            if (ongoingWorkList.length > 0) {
              workList.addAll(ongoingWorkList);
              flag = 1;
              noDataFlag = false;
              workListFlag = true;
            } else if (completedWorkList.length > 0) {
              workList.addAll(completedWorkList);
              flag = 2;
              noDataFlag = false;
              workListFlag = true;
            } else {
              flag = 1;
              noDataFlag = true;
              workListFlag = false;
            }
            showFlag = [];
            for (int i = 0; i < workList.length; i++) {
              showFlag.add(false);
            }
            progressFlag = [];
            for (int i = 0; i < workList.length; i++) {
              progressFlag.add(false);
            }
          } else {
            utils.showAlert(context, s.no_data);
          }
        } else {
          utils.showAlert(context, s.no_data);
        }
        setState(() {
          isLoadingScheme = false;
        });
      } else {
        print("WorkList responceSignature - Token Not Verified");
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
    }
  }

  Future<void> getWorkListByTMC(String dcode, String tmccode, String towntype,
      List scheme, List finYear) async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    utils.showProgress(context, 1);
    late Map json_request;
    late Map work_detail;

    List schemeArray = [];
    for (int i = 0; i < scheme.length; i++) {
      schemeArray.add(scheme[i][s.key_scheme_id]);
    }
    if (towntype == "T") {
      work_detail = {
        s.key_fin_year: finYear,
        s.key_dcode: dcode,
        s.key_townpanchayat_id: tmccode,
        s.key_scheme_id: schemeArray,
      };
      json_request = {
        s.key_service_id:
            s.service_key_get_inspection_work_details_townpanchayat_wise,
        s.key_inspection_work_details: work_detail,
      };
    } else if (towntype == "M") {
      work_detail = {
        s.key_fin_year: finYear,
        s.key_dcode: dcode,
        s.key_municipality_id: tmccode,
        s.key_scheme_id: schemeArray,
      };
      json_request = {
        s.key_service_id:
            s.service_key_get_inspection_work_details_municipality_wise,
        s.key_inspection_work_details: work_detail,
      };
    } else if (towntype == "C") {
      work_detail = {
        s.key_fin_year: finYear,
        s.key_dcode: dcode,
        s.key_corporation_id: tmccode,
        s.key_scheme_id: schemeArray,
      };
      json_request = {
        s.key_service_id:
            s.service_key_get_inspection_work_details_corporation_wise,
        s.key_inspection_work_details: work_detail,
      };
    }

    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: json_request
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

    print("WorkList_url>>" + url.main_service_jwt.toString());
    print("WorkList_request_encrpt>>" + encrypted_request.toString());
    utils.hideProgress(context);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;

      print("WorkList_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("WorkList Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("WorkList responceSignature -  $responceSignature");

      print("WorkList responceData -  $responceData");
      if (responceSignature == responceData) {
        print("WorkList responceSignature - Token Verified");
        var userData = jsonDecode(data);

        var status = userData[s.key_status];
        var response_value = userData[s.key_response];
        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          res_jsonArray.sort((a, b) {
            return a[s.key_work_id].compareTo(b[s.key_work_id]);
          });
          if (res_jsonArray.length > 0) {
            flagTab = true;
            flagList = true;
            ongoingWorkList = [];
            completedWorkList = [];
            workListAll = [];
            workList = [];
            for (int i = 0; i < res_jsonArray.length; i++) {
              if (res_jsonArray[i][s.key_current_stage_of_work] == 11) {
                completedWorkList.add(res_jsonArray[i]);
              } else {
                ongoingWorkList.add(res_jsonArray[i]);
              }
              workListAll.add(res_jsonArray[i]);
            }

            if (ongoingWorkList.length > 0) {
              workList.addAll(ongoingWorkList);
              flag = 1;
              noDataFlag = false;
              workListFlag = true;
            } else if (completedWorkList.length > 0) {
              workList.addAll(completedWorkList);
              flag = 2;
              noDataFlag = false;
              workListFlag = true;
            } else {
              flag = 1;
              noDataFlag = true;
              workListFlag = false;
            }
            showFlag = [];
            for (int i = 0; i < workList.length; i++) {
              showFlag.add(false);
            }
            progressFlag = [];
            for (int i = 0; i < workList.length; i++) {
              progressFlag.add(false);
            }
            if (prefs.getString(s.onOffType) == "offline") {
              dbHelper.delete_table_RdprWorkList('U');

              String sql_worklist =
                  'INSERT INTO ${s.table_RdprWorkList} (rural_urban,town_type,dcode, dname , bcode, bname , pvcode , pvname, hab_code , scheme_group_id , scheme_id , scheme_name, work_group_id , work_type_id , fin_year, work_id ,work_name , as_value , ts_value , current_stage_of_work , is_high_value , stage_name , as_date , ts_date , upd_date, work_order_date , work_type_name , tpcode   , townpanchayat_name , muncode , municipality_name , corcode , corporation_name) VALUES ';

              List<String> valueSets_worklist = [];

              for (var row in res_jsonArray) {
                String tpCode = '';
                String tpName = '';
                String munCode = '';
                String munName = '';
                String corpCode = '';
                String corpName = '';

                if (towntype == "T") {
                  munCode = utils.checkNull(row[s.key_tpcode]);
                  munName = utils.checkNull(row[s.key_townpanchayat_name]);
                  tpCode = '0';
                  tpName = '0';
                  corpCode = '0';
                  corpName = '0';
                } else if (towntype == "M") {
                  tpCode = utils.checkNull(row[s.key_muncode]);
                  tpName = utils.checkNull(row[s.key_municipality_name]);
                  munCode = '0';
                  munName = '0';
                  corpCode = '0';
                  corpName = '0';
                } else if (towntype == "C") {
                  corpCode = utils.checkNull(row[s.key_corcode]);
                  corpName = utils.checkNull(row[s.key_corporation_name]);
                  munCode = '0';
                  munName = '0';
                  tpCode = '0';
                  tpName = '0';
                }

                String values =
                    " ( 'U', '$towntype', '${utils.checkNull(row[s.key_dcode])}', '${utils.checkNull(row[s.key_dname])}', '0', '0', '0', '0', '${utils.checkNull(row[s.key_hab_code])}', '${row[s.key_scheme_group_id]}', '${utils.checkNull(row[s.key_scheme_id])}', '${utils.checkNull(row[s.key_scheme_name])}', '${utils.checkNull(row[s.key_work_group_id])}', '${utils.checkNull(row[s.key_work_type_id])}', '${utils.checkNull(row[s.key_fin_year])}', '${utils.checkNull(row[s.key_work_id])}', '${utils.checkNull(row[s.key_work_name])}', '${utils.checkNull(row[s.key_as_value])}', '${utils.checkNull(row[s.key_ts_value])}', '${utils.checkNull(row[s.key_current_stage_of_work])}', '${utils.checkNull(row[s.key_is_high_value])}', '${utils.checkNull(row[s.key_stage_name])}', '${utils.checkNull(row[s.key_as_date])}', '${utils.checkNull(row[s.key_ts_date])}', '${utils.checkNull(row[s.key_upd_date])}', '${utils.checkNull(row[s.key_work_order_date])}', '${utils.checkNull(row[s.key_work_type_name])}', '$tpCode', '$tpName', '$munCode', '$munName', '$corpCode', '$corpName') ";
                valueSets_worklist.add(values);
              }

              sql_worklist += valueSets_worklist.join(', ');

              await dbHelper.myDb?.execute(sql_worklist);

              /* for (int i = 0; i < res_jsonArray.length; i++) {
                if (towntype == "T") {
                  await dbClient.rawInsert('INSERT INTO ' +
                      s.table_RdprWorkList +
                      ' (rural_urban,town_type,dcode, dname , bcode, bname , pvcode , pvname, hab_code , scheme_group_id , scheme_id , scheme_name, work_group_id , work_type_id , fin_year, work_id ,work_name , as_value , ts_value , current_stage_of_work , is_high_value , stage_name , as_date , ts_date , upd_date, work_order_date , work_type_name , tpcode   , townpanchayat_name , muncode , municipality_name , corcode , corporation_name  ) VALUES(' +
                      "'" +
                      "U" +
                      "' , '" +
                      towntype +
                      "' , '" +
                      res_jsonArray[i][s.key_dcode].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_dname].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_bcode].toString() +
                      "' , '" +
                      "0" +
                      "' , '" +
                      res_jsonArray[i][s.key_pvcode].toString() +
                      "' , '" +
                      "0" +
                      "' , '" +
                      res_jsonArray[i][s.key_hab_code].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_scheme_group_id].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_scheme_id].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_scheme_name].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_group_id].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_type_id].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_fin_year].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_id].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_name].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_as_value].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_ts_value].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_current_stage_of_work].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_is_high_value].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_stage_name].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_as_date].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_ts_date].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_upd_date].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_order_date].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_type_name].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_tpcode].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_townpanchayat_name].toString() +
                      "' , '" +
                      "0" +
                      "' , '" +
                      "0" +
                      "' , '" +
                      "0" +
                      "' , '" +
                      "0" +
                      "')");
                } else if (towntype == "M") {
                  await dbClient.rawInsert('INSERT INTO ' +
                      s.table_RdprWorkList +
                      ' (rural_urban,town_type,dcode, dname , bcode, bname , pvcode , pvname, hab_code , scheme_group_id , scheme_id , scheme_name, work_group_id , work_type_id , fin_year, work_id ,work_name , as_value , ts_value , current_stage_of_work , is_high_value , stage_name , as_date , upd_date, ts_date , work_order_date , work_type_name , tpcode   , townpanchayat_name  ) VALUES(' +
                      "'" +
                      "U" +
                      "' , '" +
                      towntype +
                      "' , '" +
                      res_jsonArray[i][s.key_dcode].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_dname].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_bcode].toString() +
                      "' , '" +
                      "0" +
                      "' , '" +
                      res_jsonArray[i][s.key_pvcode].toString() +
                      "' , '" +
                      "0" +
                      "' , '" +
                      res_jsonArray[i][s.key_hab_code].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_scheme_group_id].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_scheme_id].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_scheme_name].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_group_id].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_type_id].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_fin_year].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_id].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_name].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_as_value].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_ts_value].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_current_stage_of_work].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_is_high_value].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_stage_name].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_as_date].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_ts_date].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_upd_date].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_order_date].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_type_name].toString() +
                      "' , '" +
                      "0" +
                      "' , '" +
                      "0" +
                      "' , '" +
                      res_jsonArray[i][s.key_muncode].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_municipality_name].toString() +
                      "' , '" +
                      "0" +
                      "' , '" +
                      "0" +
                      "')");
                } else if (towntype == "C") {
                  await dbClient.rawInsert('INSERT INTO ' +
                      s.table_RdprWorkList +
                      ' (rural_urban,town_type,dcode, dname , bcode, bname , pvcode , pvname, hab_code , scheme_group_id , scheme_id , scheme_name, work_group_id , work_type_id , fin_year, work_id ,work_name , as_value , ts_value , current_stage_of_work , is_high_value , stage_name , as_date , upd_date, ts_date , work_order_date , work_type_name , tpcode   , townpanchayat_name  ) VALUES(' +
                      "'" +
                      "U" +
                      "' , '" +
                      towntype +
                      "' , '" +
                      res_jsonArray[i][s.key_dcode].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_dname].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_bcode].toString() +
                      "' , '" +
                      "0" +
                      "' , '" +
                      res_jsonArray[i][s.key_pvcode].toString() +
                      "' , '" +
                      "0" +
                      "' , '" +
                      res_jsonArray[i][s.key_hab_code].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_scheme_group_id].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_scheme_id].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_scheme_name].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_group_id].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_type_id].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_fin_year].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_id].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_name].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_as_value].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_ts_value].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_current_stage_of_work].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_is_high_value].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_stage_name].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_as_date].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_ts_date].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_upd_date].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_order_date].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_work_type_name].toString() +
                      "' , '" +
                      "0" +
                      "' , '" +
                      "0" +
                      "' , '" +
                      "0" +
                      "' , '" +
                      "0" +
                      "' , '" +
                      res_jsonArray[i][s.key_corcode].toString() +
                      "' , '" +
                      res_jsonArray[i][s.key_corporation_name].toString() +
                      "')");
                }
              } */

              List<Map> list = await dbClient
                  .rawQuery('SELECT * FROM ' + s.table_RdprWorkList);
              print("table_RdprWorkList" + list.toString());
            }
          } else {
            utils.showAlert(context, s.no_data);
          }
        } else {
          utils.showAlert(context, s.no_data);
        }
      } else {
        print("WorkList responceSignature - Token Not Verified");
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
      setState(() {
        isLoadingScheme = false;
      });
    }
  }

  Future<void> getProgressDetails(String workId, int index) async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    utils.showProgress(context, 1);
    late Map json_request;
    json_request = {
      s.key_service_id: s.service_key_work_progress_detail,
      s.key_work_id: workId,
    };

    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: json_request
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

    print("ProgressDetails_url>>" + url.main_service_jwt.toString());
    print("ProgressDetails_request_encrpt>>" + encrypted_request.toString());
    utils.hideProgress(context);

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;

      print("ProgressDetails_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("ProgressDetails Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("ProgressDetails responceSignature -  $responceSignature");

      print("ProgressDetails responceData -  $responceData");

      if (responceSignature == responceData) {
        print("ProgressDetails responceSignature - Token Verified");
        var userData = jsonDecode(data);

        var status = userData[s.key_status];
        var response_value = userData[s.key_response];

        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          if (res_jsonArray.length > 0) {
            progressList = [];
            for (int i = 0; i < res_jsonArray.length; i++) {
              progressList.add(res_jsonArray[i]);
            }
            if (progressList.length > 0) {
              for (int i = 0; i < progressFlag.length; i++) {
                if (i == index) {
                  progressFlag[i] = !progressFlag[index];
                } else {
                  progressFlag[i] = false;
                }
              }

              setSidebarState();

              setState(() {});
            }
          } else {
            utils.showAlert(context, s.no_data);
          }
        } else {
          utils.showAlert(context, s.no_data);
        }
      } else {
        print("ProfileData responceSignature - Token Not Verified");
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
    }
  }

  Future<void> getWorkListByVillage(
      String dcode, String bcode, String pvcode) async {
    utils.showProgress(context, 1);
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);

    late Map json_request;

    Map work_detail = {
      s.key_dcode: dcode,
      s.key_bcode: bcode,
      s.key_pvcode: [pvcode],
    };
    json_request = {
      s.key_service_id: s.service_key_get_village_pending_works,
      s.key_inspection_work_details: work_detail,
    };

    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: json_request
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

    print("WorkListByVillage_url>>" + url.main_service_jwt.toString());
    print("WorkListByVillage_request_encrpt>>" + encrypted_request.toString());
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    utils.hideProgress(context);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;

      print("WorkListByVillage_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("WorkListByVillage Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("WorkListByVillage responceSignature -  $responceSignature");

      print("WorkListByVillage responceData -  $responceData");
      if (responceSignature == responceData) {
        print("WorkListByVillage responceSignature - Token Verified");
        var userData = jsonDecode(data);

        var status = userData[s.key_status];
        var response_value = userData[s.key_response];
        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          res_jsonArray.sort((a, b) {
            return a[s.key_work_id].compareTo(b[s.key_work_id]);
          });
          if (res_jsonArray.length > 0) {
            flagTab = true;
            flagList = true;
            ongoingWorkList = [];
            completedWorkList = [];
            workListAll = [];
            workList = [];
            for (int i = 0; i < res_jsonArray.length; i++) {
              if (res_jsonArray[i][s.key_current_stage_of_work] == 11) {
                completedWorkList.add(res_jsonArray[i]);
              } else {
                ongoingWorkList.add(res_jsonArray[i]);
              }
              workListAll.add(res_jsonArray[i]);
            }
            if (ongoingWorkList.length > 0) {
              workList.addAll(ongoingWorkList);
              flag = 1;
              noDataFlag = false;
              workListFlag = true;
            } else if (completedWorkList.length > 0) {
              workList.addAll(completedWorkList);
              flag = 2;
              noDataFlag = false;
              workListFlag = true;
            } else {
              flag = 1;
              noDataFlag = true;
              workListFlag = false;
            }
            showFlag = [];
            for (int i = 0; i < workList.length; i++) {
              showFlag.add(false);
            }
            progressFlag = [];
            for (int i = 0; i < workList.length; i++) {
              progressFlag.add(false);
            }
          } else {
            utils.showAlert(context, s.no_data);
          }
        } else {
          utils.showAlert(context, s.no_data);
        }
      } else {
        print("WorkListByVillage responceSignature - Token Not Verified");
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
    }
  }

  Future<void> fetchWorkListAll() async {
    utils.showProgress(context, 1);
    ongoingWorkList = [];
    completedWorkList = [];
    workList = [];
    for (int i = 0; i < workListAll.length; i++) {
      if (workListAll[i][s.key_current_stage_of_work] == 11) {
        completedWorkList.add(workListAll[i]);
      } else {
        ongoingWorkList.add(workListAll[i]);
      }
    }

    if (ongoingWorkList.length > 0) {
      workList.addAll(ongoingWorkList);
      flag = 1;
      noDataFlag = false;
      workListFlag = true;
    } else if (completedWorkList.length > 0) {
      workList.addAll(completedWorkList);
      flag = 2;
      noDataFlag = false;
      workListFlag = true;
    } else {
      flag = 1;
      noDataFlag = true;
      workListFlag = false;
    }
    showFlag = [];
    for (int i = 0; i < workList.length; i++) {
      showFlag.add(false);
    }
    progressFlag = [];
    for (int i = 0; i < workList.length; i++) {
      progressFlag.add(false);
    }
    setState(() {});
    utils.hideProgress(context);
  }

  Future<void> fetchWorkList(String type, String val) async {
    utils.showProgress(context, 1);
    flagTab = true;
    flagList = true;
    ongoingWorkList = [];
    completedWorkList = [];
    workList = [];
    for (int i = 0; i < workListAll.length; i++) {
      if (type == 'as') {
        if (int.parse(workListAll[i][s.key_as_value]) >= int.parse(val)) {
          if (workListAll[i][s.key_current_stage_of_work] == 11) {
            completedWorkList.add(workListAll[i]);
          } else {
            ongoingWorkList.add(workListAll[i]);
          }
        }
      } else {
        if (await utils.delayHours(
            context, workListAll[i][s.key_upd_date], int.parse(val))) {
          if (workListAll[i][s.key_current_stage_of_work] == 11) {
            completedWorkList.add(workListAll[i]);
          } else {
            ongoingWorkList.add(workListAll[i]);
          }
        }
      }
    }

    if (ongoingWorkList.length > 0) {
      workList.addAll(ongoingWorkList);
      flag = 1;
      noDataFlag = false;
      workListFlag = true;
    } else if (completedWorkList.length > 0) {
      workList.addAll(completedWorkList);
      flag = 2;
      noDataFlag = false;
      workListFlag = true;
    } else {
      flag = 1;
      noDataFlag = true;
      workListFlag = false;
    }
    showFlag = [];
    for (int i = 0; i < workList.length; i++) {
      showFlag.add(false);
    }
    progressFlag = [];
    for (int i = 0; i < workList.length; i++) {
      progressFlag.add(false);
    }

    setState(() {});
    utils.hideProgress(context);
  }

  Future<void> fetchOfflineWorkList(String areatype, String scheme) async {
    utils.showProgress(context, 1);
    List<Map> list = await dbClient.rawQuery(
        "SELECT * FROM ${s.table_RdprWorkList} where rural_urban='${areatype}' and scheme_id='${scheme}' ");
    print(
        "SELECT * FROM ${s.table_RdprWorkList} where rural_urban='${areatype}' and scheme_id='${scheme}' ");
    flagTab = true;
    flagList = true;
    ongoingWorkList = [];
    completedWorkList = [];
    workList = [];
    workListAll = [];
    workListAll.addAll(list);
    for (int i = 0; i < workListAll.length; i++) {
      if (workListAll[i][s.key_current_stage_of_work] == 11) {
        completedWorkList.add(workListAll[i]);
      } else {
        ongoingWorkList.add(workListAll[i]);
      }
    }

    print(workListAll.toString());
    if (ongoingWorkList.length > 0) {
      workList.addAll(ongoingWorkList);
      flag = 1;
      noDataFlag = false;
      workListFlag = true;
    } else if (completedWorkList.length > 0) {
      workList.addAll(completedWorkList);
      flag = 2;
      noDataFlag = false;
      workListFlag = true;
    } else {
      flag = 1;
      noDataFlag = true;
      workListFlag = false;
    }
    showFlag = [];
    for (int i = 0; i < workList.length; i++) {
      showFlag.add(false);
    }
    progressFlag = [];
    for (int i = 0; i < workList.length; i++) {
      progressFlag.add(false);
    }

    setState(() {
      isLoadingScheme = false;
    });
    utils.hideProgress(context);
  }

  Future<void> getdelayedWorkListByVillage(String pvcode) async {
    utils.showProgress(context, 1);
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);

    late Map json_request;

    Map work_detail = {
      s.key_dcode: widget.dcode,
      s.key_bcode: widget.bcode,
      s.key_pvcode: widget.pvcode,
      s.key_fin_year: widget.finYear,
      s.key_scheme_id: widget.schemeList,
      s.key_as_value: widget.asvalue,
      s.key_month: widget.tmccode,
      s.key_flag: "2"
    };
    json_request = {
      s.key_service_id: s.service_key_get_inspection_delayed_work_details,
    };
    json_request.addAll(work_detail);
    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: json_request
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

    print("DelayedWorkListByVillage_url>>" + url.main_service_jwt.toString());
    print("DelayedWorkListByVillage_request_encrpt>>" +
        encrypted_request.toString());
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    utils.hideProgress(context);
    if (response.statusCode == 200) {
      String data = response.body;

      print("DelayedWorkListByVillage_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("DelayedWorkListByVillage Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("DelayedWorkListByVillage responceSignature -  $responceSignature");

      print("DelayedWorkListByVillage responceData -  $responceData");
      if (responceSignature == responceData) {
        print("DelayedWorkListByVillage responceSignature - Token Verified");
        var userData = jsonDecode(data);

        var status = userData[s.key_status];
        var response_value = userData[s.key_response];
        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          res_jsonArray.sort((a, b) {
            return a[s.key_work_id].compareTo(b[s.key_work_id]);
          });
          if (res_jsonArray.length > 0) {
            flagTab = true;
            flagList = true;
            ongoingWorkList = [];
            completedWorkList = [];
            workListAll = [];
            workList = [];
            for (int i = 0; i < res_jsonArray.length; i++) {
              if (res_jsonArray[i][s.key_current_stage_of_work] == 11) {
                completedWorkList.add(res_jsonArray[i]);
              } else {
                ongoingWorkList.add(res_jsonArray[i]);
              }
              workListAll.add(res_jsonArray[i]);
            }
            if (ongoingWorkList.length > 0) {
              workList.addAll(ongoingWorkList);
              flag = 1;
              noDataFlag = false;
              workListFlag = true;
            } else if (completedWorkList.length > 0) {
              workList.addAll(completedWorkList);
              flag = 2;
              noDataFlag = false;
              workListFlag = true;
            } else {
              flag = 1;
              noDataFlag = true;
              workListFlag = false;
            }
            showFlag = [];
            for (int i = 0; i < workList.length; i++) {
              showFlag.add(false);
            }
            progressFlag = [];
            for (int i = 0; i < workList.length; i++) {
              progressFlag.add(false);
            }
          } else {
            utils.showAlert(context, s.no_data);
          }
        } else {
          utils.showAlert(context, s.no_data);
        }
      } else {
        print(
            "DelayedWorkListByVillage responceSignature - Token Not Verified");
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
    }
  }
}
