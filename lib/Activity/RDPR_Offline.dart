// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, prefer_interpolation_to_compose_strings, use_build_context_synchronously, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_limited_checkbox/flutter_limited_checkbox.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Layout/Multiple_CheckBox.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../DataBase/DbHelper.dart';
import '../Resources/Strings.dart';
import '../Utils/utils.dart';
import 'WorkList.dart';

class RDPR_Offline extends StatefulWidget with ChangeNotifier {
  @override
  State<RDPR_Offline> createState() => _RDPR_OfflineState();
}

class _RDPR_OfflineState extends State<RDPR_Offline> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  String onOffType = "";
  String level = "";
  String selectedDistrict = "";
  String selectedBlock = "";
  String selectedVillage = "";
  String selectedDistrictName = "";
  String selectedBlockName = "";
  String selectedVillageName = "";
  bool skipFlag = false;
  bool dFlag = false;
  bool bFlag = false;
  bool vFlag = false;
  bool submitFlag = false;
  bool schemeFlag = false;

  // simple usage

  List<FlutterLimitedCheckBoxModel> vList = [];
  List<FlutterLimitedCheckBoxModel> dList = [];
  List<FlutterLimitedCheckBoxModel> bList = [];
  List<FlutterLimitedCheckBoxModel> finyearList = [];
  List<FlutterLimitedCheckBoxModel> schemeList = [];
  List finList = [];
  List schList = [];
  List schIdList = [];
  List selectedSchemeArray = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    onOffType = prefs.getString(s.onOffType)!;
    level = prefs.getString(s.key_level)!;
    schemeFlag = false;
    submitFlag = false;
    finyearList.clear();
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM ' + s.table_FinancialYear);
    for (int i = 0; i < list.length; i++) {
      finyearList.add(FlutterLimitedCheckBoxModel(
          isSelected: false,
          selectTitle: list[i][s.key_fin_year],
          selectId: i));
      print(list.toString());
    }

    if (level == "S") {
      dFlag = true;
      bFlag = false;
      vFlag = false;
      dList.clear();
      selectedDistrict = "";
      selectedBlock = "";
      selectedVillage = "";
      selectedDistrictName = "";
      selectedBlockName = "";
      selectedVillageName = "";
      List<Map> list =
          await dbClient.rawQuery('SELECT * FROM ' + s.table_District);
      for (int i = 0; i < list.length; i++) {
        dList.add(FlutterLimitedCheckBoxModel(
            isSelected: false,
            selectTitle: list[i][s.key_dname],
            selectId: int.parse(list[i][s.key_dcode])));
      }
      print(list.toString());
    } else if (level == "D") {
      dFlag = false;
      bFlag = true;
      vFlag = false;
      bList.clear();
      selectedDistrict = prefs.getString(s.key_dcode).toString();
      selectedBlock = "";
      selectedVillage = "";
      selectedDistrictName = prefs.getString(s.key_dname).toString();
      selectedBlockName = "";
      selectedVillageName = "";
      List<Map> list =
          await dbClient.rawQuery('SELECT * FROM ' + s.table_Block);
      for (int i = 0; i < list.length; i++) {
        bList.add(FlutterLimitedCheckBoxModel(
            isSelected: false,
            selectTitle: list[i][s.key_bname],
            selectId: int.parse(list[i][s.key_bcode])));
      }

      print(list.toString());
    } else if (level == "B") {
      dFlag = false;
      bFlag = false;
      vFlag = true;
      vList.clear();
      selectedDistrict = prefs.getString(s.key_dcode).toString();
      selectedBlock = prefs.getString(s.key_bcode).toString();
      selectedVillage = "";
      selectedDistrictName = prefs.getString(s.key_dname).toString();
      selectedBlockName = prefs.getString(s.key_bname).toString();
      selectedVillageName = "";
      List<Map> list =
          await dbClient.rawQuery('SELECT * FROM ' + s.table_Village);
      for (int i = 0; i < list.length; i++) {
        vList.add(FlutterLimitedCheckBoxModel(
            isSelected: false,
            selectTitle: list[i][s.key_pvname],
            selectId: int.parse(list[i][s.key_pvcode])));
        print(list.toString());
      }
    }
    List<Map> list_urban = await dbClient.rawQuery(
        "SELECT * FROM ${s.table_RdprWorkList} where rural_urban='${prefs.getString(s.key_rural_urban)}' ");
    list_urban.length > 0 && onOffType == "offline"
        ? skipFlag = true
        : skipFlag = false;
    setState(() {});
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
                    child: Text(s.download_work_list,
                        style: GoogleFonts.getFont('Roboto',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: c.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          alignment: AlignmentDirectional.center,
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          color: c.white,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: skipFlag,
                        child: InkWell(
                          onTap: () async {
                            List<Map> schemeList = await dbClient.rawQuery(
                                "SELECT * FROM $table_SchemeList where rural_urban = 'R'");
                            // await dbClient.rawQuery('SELECT * FROM ' + s.table_SchemeList+' where rural_urban = U');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WorkList(
                                          schemeList: schemeList,
                                          scheme: schemeList[0]
                                              [s.key_scheme_id],
                                          flag: 'rdpr_offline',
                                          finYear: '',
                                          dcode: '',
                                          bcode: '',
                                          pvcode: '',
                                          tmccode: '',
                                          townType: '',
                                          selectedschemeList: [],
                                        ))).then((value) {
                              utils.gotoHomePage(context, "RDPR");
                              // you can do what you need here
                              // setState etc.
                            });
                          },
                          child: Container(
                            alignment: AlignmentDirectional.center,
                            margin: const EdgeInsets.only(bottom: 10, top: 15),
                            padding: const EdgeInsets.all(0),
                            child: Text(s.skip,
                                style: GoogleFonts.getFont('Roboto',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: c.primary_text_color2)),
                          ),
                        ),
                      ),
                      Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          // clipBehavior is necessary because, without it, the InkWell's animation
                          // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                          // This comes with a small performance cost, and you should not set [clipBehavior]
                          // unless you need it.
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.only(bottom: 10),
                                  alignment: AlignmentDirectional.center,
                                  decoration: new BoxDecoration(
                                      color: c.grey_4,
                                      borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(10),
                                        topRight: const Radius.circular(10),
                                        bottomLeft: const Radius.circular(0),
                                        bottomRight: const Radius.circular(0),
                                      )),
                                  child: Text(
                                    s.select_values_for_download,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: c.blue_background),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  alignment: AlignmentDirectional.center,
                                  decoration: new BoxDecoration(
                                      color: c.white,
                                      border:
                                          Border.all(color: c.grey_4, width: 1),
                                      borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(5),
                                        topRight: const Radius.circular(5),
                                        bottomLeft: const Radius.circular(5),
                                        bottomRight: const Radius.circular(5),
                                      )),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              s.financial_year,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.normal,
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
                                                  fontWeight: FontWeight.normal,
                                                  color: c.grey_8),
                                              overflow: TextOverflow.clip,
                                              maxLines: 1,
                                              softWrap: true,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: InkWell(
                                              onTap: () {
                                                multiChoiceFinYearSelection(
                                                    finyearList,
                                                    s.select_financial_year);
                                              },
                                              child: Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    30, 0, 30, 0),
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 5, 0, 5),
                                                decoration: new BoxDecoration(
                                                    color: c
                                                        .account_status_green_color,
                                                    border: Border.all(
                                                        color: c
                                                            .account_status_green_color,
                                                        width: 2),
                                                    borderRadius:
                                                        new BorderRadius.only(
                                                      topLeft:
                                                          const Radius.circular(
                                                              25),
                                                      topRight:
                                                          const Radius.circular(
                                                              25),
                                                      bottomLeft:
                                                          const Radius.circular(
                                                              25),
                                                      bottomRight:
                                                          const Radius.circular(
                                                              25),
                                                    )),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .center,
                                                  child: Text(
                                                    s.select,
                                                    style: TextStyle(
                                                        color: c.white,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
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
                                              s.selected_financial_year,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.normal,
                                                  color: c.primary_text_color2),
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
                                                  fontWeight: FontWeight.normal,
                                                  color: c.grey_8),
                                              overflow: TextOverflow.clip,
                                              maxLines: 1,
                                              softWrap: true,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              finList.isNotEmpty
                                                  ? finList.toString()
                                                  : "",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: c.grey_8),
                                              overflow: TextOverflow.clip,
                                              maxLines: 1,
                                              softWrap: true,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: dFlag,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    alignment: AlignmentDirectional.center,
                                    decoration: new BoxDecoration(
                                        color: c.white,
                                        border: Border.all(
                                            color: c.grey_4, width: 1),
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(5),
                                          topRight: const Radius.circular(5),
                                          bottomLeft: const Radius.circular(5),
                                          bottomRight: const Radius.circular(5),
                                        )),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                s.district,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.normal,
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
                                                        FontWeight.normal,
                                                    color: c.grey_8),
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: InkWell(
                                                onTap: () {
                                                  singleChoiceSelection(dList,
                                                      s.selectDistrict, "D");
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      30, 0, 30, 0),
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 5, 0, 5),
                                                  decoration: new BoxDecoration(
                                                      color: c
                                                          .account_status_green_color,
                                                      border: Border.all(
                                                          color: c
                                                              .account_status_green_color,
                                                          width: 2),
                                                      borderRadius:
                                                          new BorderRadius.only(
                                                        topLeft: const Radius
                                                            .circular(25),
                                                        topRight: const Radius
                                                            .circular(25),
                                                        bottomLeft: const Radius
                                                            .circular(25),
                                                        bottomRight:
                                                            const Radius
                                                                .circular(25),
                                                      )),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .center,
                                                    child: Text(
                                                      s.select,
                                                      style: TextStyle(
                                                          color: c.white,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
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
                                                s.selectedDistrict,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color:
                                                        c.primary_text_color2),
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
                                                        FontWeight.normal,
                                                    color: c.grey_8),
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                selectedDistrictName,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: c.grey_8),
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: bFlag,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    alignment: AlignmentDirectional.center,
                                    decoration: new BoxDecoration(
                                        color: c.white,
                                        border: Border.all(
                                            color: c.grey_4, width: 1),
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(5),
                                          topRight: const Radius.circular(5),
                                          bottomLeft: const Radius.circular(5),
                                          bottomRight: const Radius.circular(5),
                                        )),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                s.block,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.normal,
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
                                                        FontWeight.normal,
                                                    color: c.grey_8),
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: InkWell(
                                                onTap: () {
                                                  if (level == "S" &&
                                                      bList.isEmpty) {
                                                    utils.showAlert(context,
                                                        s.selectDistrict);
                                                  } else {
                                                    singleChoiceSelection(bList,
                                                        s.selectBlock, "B");
                                                  }
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      30, 0, 30, 0),
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 5, 0, 5),
                                                  decoration: new BoxDecoration(
                                                      color: c
                                                          .account_status_green_color,
                                                      border: Border.all(
                                                          color: c
                                                              .account_status_green_color,
                                                          width: 2),
                                                      borderRadius:
                                                          new BorderRadius.only(
                                                        topLeft: const Radius
                                                            .circular(25),
                                                        topRight: const Radius
                                                            .circular(25),
                                                        bottomLeft: const Radius
                                                            .circular(25),
                                                        bottomRight:
                                                            const Radius
                                                                .circular(25),
                                                      )),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .center,
                                                    child: Text(
                                                      s.select,
                                                      style: TextStyle(
                                                          color: c.white,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
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
                                                s.selectedBlock,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color:
                                                        c.primary_text_color2),
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
                                                        FontWeight.normal,
                                                    color: c.grey_8),
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                selectedBlockName,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: c.grey_8),
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: vFlag,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    alignment: AlignmentDirectional.center,
                                    decoration: new BoxDecoration(
                                        color: c.white,
                                        border: Border.all(
                                            color: c.grey_4, width: 1),
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(5),
                                          topRight: const Radius.circular(5),
                                          bottomLeft: const Radius.circular(5),
                                          bottomRight: const Radius.circular(5),
                                        )),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                s.village,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.normal,
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
                                                        FontWeight.normal,
                                                    color: c.grey_8),
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: InkWell(
                                                onTap: () {
                                                  if (vList.isEmpty) {
                                                    utils.showAlert(
                                                        context, s.selectBlock);
                                                  } else {
                                                    if (finList.isEmpty) {
                                                      utils.showAlert(context,
                                                          s.select_financial_year);
                                                    } else {
                                                      singleChoiceSelection(
                                                          vList,
                                                          s.select_village,
                                                          "V");
                                                    }
                                                  }
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      30, 0, 30, 0),
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 5, 0, 5),
                                                  decoration: new BoxDecoration(
                                                      color: c
                                                          .account_status_green_color,
                                                      border: Border.all(
                                                          color: c
                                                              .account_status_green_color,
                                                          width: 2),
                                                      borderRadius:
                                                          new BorderRadius.only(
                                                        topLeft: const Radius
                                                            .circular(25),
                                                        topRight: const Radius
                                                            .circular(25),
                                                        bottomLeft: const Radius
                                                            .circular(25),
                                                        bottomRight:
                                                            const Radius
                                                                .circular(25),
                                                      )),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .center,
                                                    child: Text(
                                                      s.select,
                                                      style: TextStyle(
                                                          color: c.white,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
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
                                                s.selected_village,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color:
                                                        c.primary_text_color2),
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
                                                        FontWeight.normal,
                                                    color: c.grey_8),
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                selectedVillageName,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: c.grey_8),
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: schemeFlag,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                                    alignment: AlignmentDirectional.center,
                                    decoration: new BoxDecoration(
                                        color: c.white,
                                        border: Border.all(
                                            color: c.grey_4, width: 1),
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(5),
                                          topRight: const Radius.circular(5),
                                          bottomLeft: const Radius.circular(5),
                                          bottomRight: const Radius.circular(5),
                                        )),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                s.scheme,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.normal,
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
                                                        FontWeight.normal,
                                                    color: c.grey_8),
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: InkWell(
                                                onTap: () {
                                                  if (schemeList.isEmpty) {
                                                    utils.showAlert(context,
                                                        s.select_village);
                                                  } else {
                                                    multiChoiceSchemeSelection(
                                                        schemeList,
                                                        s.select_scheme);
                                                  }
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      30, 0, 30, 0),
                                                  padding: EdgeInsets.fromLTRB(
                                                      0, 5, 0, 5),
                                                  decoration: new BoxDecoration(
                                                      color: c
                                                          .account_status_green_color,
                                                      border: Border.all(
                                                          color: c
                                                              .account_status_green_color,
                                                          width: 2),
                                                      borderRadius:
                                                          new BorderRadius.only(
                                                        topLeft: const Radius
                                                            .circular(25),
                                                        topRight: const Radius
                                                            .circular(25),
                                                        bottomLeft: const Radius
                                                            .circular(25),
                                                        bottomRight:
                                                            const Radius
                                                                .circular(25),
                                                      )),
                                                  child: Align(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .center,
                                                    child: Text(
                                                      s.select,
                                                      style: TextStyle(
                                                          color: c.white,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
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
                                                s.selected_scheme,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color:
                                                        c.primary_text_color2),
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
                                                        FontWeight.normal,
                                                    color: c.grey_8),
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                schList.isNotEmpty
                                                    ? schList.toString()
                                                    : "",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: c.grey_8),
                                                overflow: TextOverflow.clip,
                                                softWrap: true,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      Visibility(
                        visible: submitFlag,
                        child: InkWell(
                          onTap: () {
                            download();
                          },
                          child: Container(
                            width: 200,
                            margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
                            padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                            decoration: new BoxDecoration(
                                color: c.dot_dark_screen2,
                                border: Border.all(
                                    color: c.dot_dark_screen2, width: 2),
                                borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(25),
                                  topRight: const Radius.circular(25),
                                  bottomLeft: const Radius.circular(25),
                                  bottomRight: const Radius.circular(25),
                                )),
                            child: Align(
                              alignment: AlignmentDirectional.center,
                              child: Text(
                                s.download,
                                style: TextStyle(
                                    color: c.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.center,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: Text(
                    s.software_designed_and,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: c.grey_8,
                        fontSize: 15),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void singleChoiceSelection(
      List<FlutterLimitedCheckBoxModel> list, String msg, String key) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(
                msg,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: c.grey_10,
                    fontSize: 15),
                textAlign: TextAlign.start,
              ),
              content: Container(
                height: 400,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FlutterSingleCheckbox(
                          shape: CircleBorder(),
                          singleValueList: list,
                          onChanged: (index) {
                            if (key == "D") {
                              selectedDistrict =
                                  list[index].selectId.toString();
                              selectedDistrictName =
                                  list[index].selectTitle.toString();
                            } else if (key == "B") {
                              selectedBlock = list[index].selectId.toString();
                              selectedBlockName =
                                  list[index].selectTitle.toString();
                            } else if (key == "V") {
                              selectedVillage = list[index].selectId.toString();
                              selectedVillageName =
                                  list[index].selectTitle.toString();
                            }
                          },
                          mainAxisAlignmentOfRow: MainAxisAlignment.start,
                          crossAxisAlignmentOfRow: CrossAxisAlignment.center,
                        ),
                      ),
                    ),
                    InkWell(
                        onTap: () async {
                          Navigator.pop(context, 'OK');
                          submitFlag = false;
                          if (await utils.isOnline()) {
                            if (key == "D") {
                              if (selectedDistrict != "0" &&
                                  selectedDistrict != "") {
                                await loadBlockList(selectedDistrict);
                              }
                            } else if (key == "B") {
                              if (selectedBlock != "0" && selectedBlock != "") {
                                if (level == "S" || level == "D") {
                                  await getVillageList(
                                      selectedDistrict, selectedBlock);
                                } else if (level == "B") {
                                  await loadVillageList(
                                      selectedDistrict, selectedBlock);
                                }
                              }
                            } else if (key == "V") {
                              await loadSchemeList(selectedDistrict,
                                  selectedBlock, selectedVillage, finList);
                            }
                            setState(() {});
                          } else {
                            utils.customAlert(context, "E", s.no_internet);
                          }
                        },
                        child: Container(
                          alignment: AlignmentDirectional.bottomEnd,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Text(
                              s.key_ok,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: c.primary_text_color2,
                                  fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ))
                  ],
                ),
              ));
        });
  }

  void multiChoiceSchemeSelection(
      List<FlutterLimitedCheckBoxModel> list, String msg) {
    int limitCount = list.length;
    List schArray = [];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(
                msg,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: c.grey_10,
                    fontSize: 15),
                textAlign: TextAlign.start,
              ),
              content: Container(
                  height: 400,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FlutterCustomMultipleCheckbox(
                            limit: limitCount,
                            limitedValueList: list,
                            onChanged:
                                (List<FlutterLimitedCheckBoxModel> list) {
                              schList.clear();
                              schIdList.clear();
                              schArray.clear();
                              for (int i = 0; i < list.length; i++) {
                                schList.add(list[i].selectTitle);
                                schIdList.add(list[i].selectId);
                                Map<String, String> map = {
                                  s.key_scheme_id: list[i].selectId.toString(),
                                  s.key_scheme_name: list[i].selectTitle
                                };
                                schArray.add(map);
                              }

                              print(schIdList.toString());
                              print(schArray.toString());
                            },
                            titleTextStyle: TextStyle(
                                // overflow: TextOverflow.ellipsis,
                                fontSize: 13,
                                fontWeight: FontWeight.w500
                                // you can also set other text properties here, like fontSize or fontWeight
                                ),
                            mainAxisAlignmentOfRow: MainAxisAlignment.start,
                            crossAxisAlignmentOfRow: CrossAxisAlignment.center,
                          ),
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            if (schIdList.isNotEmpty) {
                              submitFlag = true;
                              selectedSchemeArray.clear();
                              selectedSchemeArray.addAll(schArray);
                            }
                            Navigator.pop(context, 'OK');

                            setState(() {});
                          },
                          child: Container(
                            alignment: AlignmentDirectional.bottomEnd,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(30, 10, 30, 10),
                              child: Text(
                                s.key_ok,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: c.primary_text_color2,
                                    fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ))
                    ],
                  )));
        });
  }

  void multiChoiceFinYearSelection(
      List<FlutterLimitedCheckBoxModel> list, String msg) {
    int limitCount = 2;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: RichText(
              text: new TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: GoogleFonts.getFont('Roboto',
                    fontWeight: FontWeight.w800, fontSize: 14, color: c.grey_8),
                children: <TextSpan>[
                  new TextSpan(
                      text: s.select_financial_year,
                      style: new TextStyle(
                          fontWeight: FontWeight.bold, color: c.grey_8)),
                  new TextSpan(
                      text: " (Any Two)",
                      style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          color: c.subscription_type_red_color)),
                ],
              ),
            ),
            content: Container(
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FlutterLimitedCheckbox(
                          limit: limitCount,
                          limitedValueList: list,
                          onChanged: (List<FlutterLimitedCheckBoxModel> list) {
                            finList.clear();
                            for (int i = 0; i < list.length; i++) {
                              finList.add(list[i].selectTitle);
                            }
                            print(finList.toString());
                          },
                          mainAxisAlignmentOfRow: MainAxisAlignment.start,
                          crossAxisAlignmentOfRow: CrossAxisAlignment.center,
                        ),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          if (finList.isNotEmpty) {
                            schemeFlag = false;
                            submitFlag = false;
                            selectedVillage = "";
                            selectedVillageName = "";
                            schemeList = [];
                            schList = [];
                            schIdList = [];
                          }
                          Navigator.pop(context, 'OK');

                          setState(() {});
                        },
                        child: Container(
                          alignment: AlignmentDirectional.bottomEnd,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: Text(
                              s.key_ok,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: c.primary_text_color2,
                                  fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ))
                  ],
                )),
          );
        });
  }

  Future<void> loadBlockList(String selectedDistrict) async {
    utils.showProgress(context, 1);
    dFlag = true;
    bFlag = true;
    vFlag = false;
    schemeFlag = false;
    bList.clear();
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM ' + s.table_Block + ' Where dcode=' + selectedDistrict);
    for (int i = 0; i < list.length; i++) {
      bList.add(FlutterLimitedCheckBoxModel(
          isSelected: false,
          selectTitle: list[i][s.key_bname],
          selectId: int.parse(list[i][s.key_bcode])));
    }

    print(list.toString());
    setState(() {
      selectedBlock = "";
      selectedBlockName = "";
      selectedVillage = "";
      selectedVillageName = "";
      submitFlag = false;
      schemeList = [];
      schList = [];
      schIdList = [];
    });
    utils.hideProgress(context);
  }

  Future<void> loadVillageList(String dcode, String bcode) async {
    utils.showProgress(context, 1);
    vFlag = true;
    vList.clear();
    List<Map> list = await dbClient.rawQuery('SELECT * FROM ' +
        s.table_Village +
        ' Where bcode=' +
        bcode +
        ' and dcode=' +
        dcode);
    for (int i = 0; i < list.length; i++) {
      vList.add(FlutterLimitedCheckBoxModel(
          isSelected: false,
          selectTitle: list[i][s.key_pvname],
          selectId: int.parse(list[i][s.key_pvcode])));
      print(list.toString());
    }
    setState(() {
      selectedVillage = "";
      selectedVillageName = "";
      submitFlag = false;
      schemeList = [];
      schList = [];
      schIdList = [];
    });
    utils.hideProgress(context);
  }

  Future<void> getVillageList(
      String selectedDistrict, String selectedBlock) async {
    utils.showProgress(context, 1);
    Map json_request = {};

    json_request = {
      s.key_dcode: selectedDistrict,
      s.key_bcode: selectedBlock,
      s.key_service_id: s.service_key_village_list_district_block_wise,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: utils.encryption(
          jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = IOClient(_client);
    var response = await _ioClient.post(url.master_service,
        body: json.encode(encrpted_request));
    print("VillageList_url>>" + url.master_service.toString());
    print("VillageList_request_json>>" + json_request.toString());
    print("VillageList_request_encrpt>>" + encrpted_request.toString());
    utils.hideProgress(context);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("VillageList_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data =
          utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      vFlag = true;
      vList.clear();
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        res_jsonArray.sort((a, b) {
          return a[s.key_pvname]
              .toLowerCase()
              .compareTo(b[s.key_pvname].toLowerCase());
        });
        if (res_jsonArray.isNotEmpty) {
          for (int i = 0; i < res_jsonArray.length; i++) {
            vList.add(FlutterLimitedCheckBoxModel(
                isSelected: false,
                selectTitle: res_jsonArray[i][s.key_pvname],
                selectId: int.parse(res_jsonArray[i][s.key_pvcode])));
          }
          print(vList.toString());
        }
      }
      setState(() {
        selectedVillage = "";
        selectedVillageName = "";
        submitFlag = false;
        schemeList = [];
        schList = [];
        schIdList = [];
      });
    }
  }

  Future<void> loadSchemeList(String selectedDistrict, String selectedBlock,
      String selectedVillage, List finList) async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    utils.showProgress(context, 1);
    Map json_request = {};
    json_request = {
      s.key_dcode: selectedDistrict,
      s.key_bcode: selectedBlock,
      s.key_pvcode: selectedVillage,
      s.key_fin_year: finList,
      s.key_service_id: s.service_key_scheme_list,
    };

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

    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);

    var response = await _ioClient.post(url.main_service_jwt,
        body: jsonEncode(encrypted_request), headers: header);

    print("SchemeList_url>>" + url.main_service_jwt.toString());
    print("SchemeList_request_json>>" + json_request.toString());
    print("SchemeList_request_encrpt>>" + encrypted_request.toString());
    utils.hideProgress(context);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("SchemeList_response>>" + data);
      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("SchemeList Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("SchemeList responceSignature -  $responceSignature");

      print("SchemeList responceData -  $responceData");

      if (responceSignature == responceData) {
        print("SchemeList responceSignature - Token Verified");
        var userData = jsonDecode(data);
        var status = userData[s.key_status];
        var responseValue = userData[s.key_response];
        schemeList.clear();
        if (status == s.key_ok && responseValue == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          res_jsonArray.sort((a, b) {
            return a[s.key_scheme_name]
                .toLowerCase()
                .compareTo(b[s.key_scheme_name].toLowerCase());
          });
          if (res_jsonArray.length > 0) {
            for (int i = 0; i < res_jsonArray.length; i++) {
              String schName = res_jsonArray[i][s.key_scheme_name];
              if (schName.length >= 30) {
                schName = utils.splitStringByLength(schName, 30);
              }
              schemeList.add(FlutterLimitedCheckBoxModel(
                  isSelected: false,
                  selectTitle: schName,
                  selectId: res_jsonArray[i][s.key_scheme_id]));
            }
            schemeFlag = true;
            submitFlag = false;
            schList = [];
            schIdList = [];
            print("schemeList>>" + schemeList.toString());
          }
        } else if (status == s.key_ok && responseValue == s.key_noRecord) {
          Utils().showAlert(context, "No Scheme Found");
        }
      } else {
        print("SchemeList responceSignature - Token Not Verified");
        utils.customAlert(context, "E", s.jsonError);
      }
    }
  }

  Future<void> download() async {
    if (await utils.isOnline()) {
      getWorkListToDownload(
          finList, selectedDistrict, selectedBlock, selectedVillage, schIdList);
    } else {
      utils.customAlert(context, "E", s.no_internet);
    }
  }

  Future<void> getWorkListToDownload(List finYear, String dcode, String bcode,
      String pvcode, List scheme) async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    utils.showProgress(context, 2);
    late Map json_request;

    Map work_detail = {
      s.key_scode: prefs.getString(s.key_scode),
      s.key_dcode: dcode,
      s.key_bcode: bcode,
      s.key_pvcode: [pvcode],
      s.key_fin_year: finYear,
      s.key_scheme_id: scheme,
    };
    json_request = {
      s.key_service_id: s.service_key_get_inspection_work_details,
      s.key_inspection_work_details: work_detail,
    };

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
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    print("WorkList_url>>" + url.main_service_jwt.toString());
    print("WorkList_request_json>>" + json_request.toString());
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
          if (res_jsonArray.isNotEmpty) {
            dbHelper.delete_table_RdprWorkList('R');
            dbHelper.delete_table_SchemeList('R');

            String sql_scheme =
                'INSERT INTO ${s.table_SchemeList} (rural_urban, scheme_id , scheme_name ) VALUES ';

            List<String> valueSets_scheme = [];

            for (var row in selectedSchemeArray) {
              String values =
                  "( 'R', '${utils.checkNull(row[s.key_scheme_id])}', '${utils.checkNull(row[s.key_scheme_name])}')";
              valueSets_scheme.add(values);
            }

            sql_scheme += valueSets_scheme.join(', ');

            await dbHelper.myDb?.execute(sql_scheme);

            String sql_worklist =
                'INSERT INTO ${s.table_RdprWorkList} (rural_urban,town_type,dcode, dname , bcode, bname , pvcode , pvname, hab_code , scheme_group_id , scheme_id , scheme_name, work_group_id , work_type_id , fin_year, work_id ,work_name , as_value , ts_value , current_stage_of_work , is_high_value , stage_name , as_date , ts_date , upd_date, work_order_date , work_type_name , tpcode   , townpanchayat_name , muncode , municipality_name , corcode , corporation_name) VALUES ';

            List<String> valueSets_worklist = [];

            for (var row in res_jsonArray) {
              String values =
                  " ( 'R', '0', '${utils.checkNull(row[s.key_dcode])}', '${utils.checkNull(row[s.key_dname])}', '${utils.checkNull(row[s.key_bcode])}', '${utils.checkNull(row[s.key_bname])}', '${utils.checkNull(row[s.key_pvcode])}', '${row[s.key_pvname]}', '${utils.checkNull(row[s.key_hab_code])}', '${row[s.key_scheme_group_id]}', '${utils.checkNull(row[s.key_scheme_id])}', '${utils.checkNull(row[s.key_scheme_name])}', '${utils.checkNull(row[s.key_work_group_id])}', '${utils.checkNull(row[s.key_work_type_id])}', '${utils.checkNull(row[s.key_fin_year])}', '${utils.checkNull(row[s.key_work_id])}', '${utils.checkNull(row[s.work_name])}', '${utils.checkNull(row[s.key_as_value])}', '${utils.checkNull(row[s.key_ts_value])}', '${utils.checkNull(row[s.key_current_stage_of_work])}', '${utils.checkNull(row[s.key_is_high_value])}', '${utils.checkNull(row[s.key_stage_name])}', '${utils.checkNull(row[s.key_as_date])}', '${utils.checkNull(row[s.key_ts_date])}', '${utils.checkNull(row[s.key_upd_date])}', '${utils.checkNull(row[s.key_work_order_date])}', '${utils.checkNull(row[s.key_work_type_name])}', '0', '0', '0', '0', '0', '0') ";
              valueSets_worklist.add(values);
            }

            sql_worklist += valueSets_worklist.join(', ');

            await dbHelper.myDb?.execute(sql_worklist);

            /* for (int i = 0; i < selectedSchemeArray.length; i++) {
              await dbClient.rawInsert('INSERT INTO ' +
                  s.table_SchemeList +
                  ' (rural_urban, scheme_id , scheme_name ) VALUES(' +
                  "'" +
                  "R" +
                  "' , '" +
                  selectedSchemeArray[i][s.key_scheme_id].toString() +
                  "' , '" +
                  selectedSchemeArray[i][s.key_scheme_name].toString() +
                  "')");
            } 

            for (int i = 0; i < res_jsonArray.length; i++) {
              await dbClient.rawInsert('INSERT INTO ' +
                  s.table_RdprWorkList +
                  ' (rural_urban,town_type,dcode, dname , bcode, bname , pvcode , pvname, hab_code , scheme_group_id , scheme_id , scheme_name, work_group_id , work_type_id , fin_year, work_id ,work_name , as_value , ts_value , current_stage_of_work , is_high_value , stage_name , as_date , ts_date , upd_date, work_order_date , work_type_name , tpcode   , townpanchayat_name , muncode , municipality_name , corcode , corporation_name  ) VALUES(' +
                  "'" +
                  "R" +
                  "' , '" +
                  "0" +
                  "' , '" +
                  res_jsonArray[i][s.key_dcode].toString() +
                  "' , '" +
                  res_jsonArray[i][s.key_dname].toString() +
                  "' , '" +
                  res_jsonArray[i][s.key_bcode].toString() +
                  "' , '" +
                  res_jsonArray[i][s.key_bname].toString() +
                  "' , '" +
                  res_jsonArray[i][s.key_pvcode].toString() +
                  "' , '" +
                  res_jsonArray[i][s.key_pvname].toString() +
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
                  "0" +
                  "' , '" +
                  "0" +
                  "')");
            } */

            List<Map> list = await dbClient
                .rawQuery('SELECT * FROM ${s.table_RdprWorkList}');

            if (list.isNotEmpty) {
              customAlertwithOk(context, "1", s.download_success, schIdList);
            }
          } else {
            utils.showAlert(context, s.no_data);
          }
        } else {
          utils.showAlert(context, s.no_data);
        }
      } else {
        print("WorkList responceSignature - Token Not Verified");
        utils.customAlert(context, "E", s.jsonError);
      }
    }
  }

  Future<void> customAlertwithOk(
      BuildContext context, String type, String msg, List schArray) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dbHelper = DbHelper();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
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
              width: 300,
              height: 300,
              child: Column(
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                        color: c.green_new,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    child: Center(
                      child: Image.asset(
                        imagePath.success,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: c.white,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text("Success",
                              style: GoogleFonts.getFont('Prompt',
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: c.text_color)),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(msg,
                              style: GoogleFonts.getFont('Roboto',
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: c.black)),
                          const SizedBox(
                            height: 35,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: true,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              c.primary_text_color2),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ))),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                    if (type == "1") {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => WorkList(
                                                    schemeList:
                                                        selectedSchemeArray,
                                                    scheme: selectedSchemeArray[
                                                            0][s.key_scheme_id]
                                                        .toString(),
                                                    flag: 'rdpr_offline',
                                                    finYear: '',
                                                    dcode: '',
                                                    bcode: '',
                                                    pvcode: '',
                                                    tmccode: '',
                                                    townType: '',
                                                    selectedschemeList: [],
                                                  )));
                                      /*.then((value) {
                                        utils.gotoHomePage(
                                            context, "RDPRUrban");
                                        // you can do what you need here
                                        // setState etc.
                                      });*/
                                    }
                                  },
                                  child: Text(
                                    "Okay",
                                    style: GoogleFonts.getFont('Roboto',
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: c.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

/*
  Future<void> showAlert(BuildContext context, String msg,List schArray) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
                Text(''),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                print("schArray"+schArray.toString());
                print("Scheme"+schArray[0].toString());
                Navigator.pop(context, 'OK');
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WorkList(
                          schemeList: selectedSchemeArray,
                          scheme: selectedSchemeArray[0][s.key_scheme_id].toString(),
                          flag: 'rdpr_offline',
                        ))) .then((value) {
                  utils.gotoHomePage(context, "RDPRUrban");
                  // you can do what you need here
                  // setState etc.
                });

              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
*/
}
