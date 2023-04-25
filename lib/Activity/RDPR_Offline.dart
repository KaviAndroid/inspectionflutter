// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, prefer_interpolation_to_compose_strings, use_build_context_synchronously, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_limited_checkbox/flutter_limited_checkbox.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../DataBase/DbHelper.dart';
import '../Resources/Strings.dart';
import '../Utils/utils.dart';
import 'WorkList.dart';

class RDPR_Offline extends StatefulWidget with ChangeNotifier{

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
      List<Map> list =
          await dbClient.rawQuery('SELECT * FROM ' + s.table_Block);
      for (int i = 0; i < list.length; i++) {
        bList.add(FlutterLimitedCheckBoxModel(
            isSelected: false,
            selectTitle: list[i][s.key_bname],
            selectId:int.parse(list[i][s.key_bcode])));
      }

      print(list.toString());
    } else if (level == "B") {
      dFlag = false;
      bFlag = false;
      vFlag = true;
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
        "SELECT * FROM ${s.table_RdprWorkList} where rural_urban='${prefs.getString(s.area_type)}' ");
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
                                                multiChoiceSelection(finyearList,s.select_financial_year,"F");
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
                                              finList.toString(),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: c.grey_10),
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
                                                  singleChoiceSelection(dList,s.selectDistrict,"D");
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
                                                    color: c.grey_10),
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
                                                  singleChoiceSelection(bList,s.selectBlock,"B");
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
                                                    color: c.grey_10),
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
                                                  singleChoiceSelection(vList,s.select_village,"V");
                                                  // singleChoiceDialog(villageList,s.select_village);
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
                                                    color: c.grey_10),
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
                                              s.scheme,
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
                                                multiChoiceSelection(schemeList,s.select_scheme,"S");
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
                                              s.selected_scheme,
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
                                              schList.toString(),
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: c.grey_10),
                                              overflow: TextOverflow.clip,
                                              maxLines: 1,
                                              softWrap: true,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),),
                              ],
                            ),
                          )),
                      Visibility(
                        visible: submitFlag,
                        child: Container(
                        width: 200,
                        margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
                        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                        decoration: new BoxDecoration(
                            color: c.dot_dark_screen2,
                            border:
                                Border.all(color: c.dot_dark_screen2, width: 2),
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
                      ),),
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


    void singleChoiceSelection(List<FlutterLimitedCheckBoxModel> list,String msg,String key){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(msg,style: TextStyle(color: c.grey_10,fontSize: 14),),
              content: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                  Expanded(child:  Align(
                    alignment: Alignment.centerLeft,
                    child: FlutterSingleCheckbox(
                      shape: CircleBorder(),
                      singleValueList: list,
                      onChanged: (index) {
                        if(key=="D"){
                          selectedDistrict=list[index].selectId.toString();
                          selectedDistrictName=list[index].selectTitle.toString();
                        }else if(key=="B"){
                          selectedBlock=list[index].selectId.toString();
                          selectedBlockName=list[index].selectTitle.toString();
                        }else if(key=="V"){
                          selectedVillage=list[index].selectId.toString();
                          selectedVillageName=list[index].selectTitle.toString();
                        }
                      },
                      mainAxisAlignmentOfRow: MainAxisAlignment.start,
                      crossAxisAlignmentOfRow: CrossAxisAlignment.center,
                    ),
                  ),),
                  Container(
                      alignment: AlignmentDirectional.bottomEnd,
                      child:      Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
              child: InkWell(
                onTap: (){
                  submitFlag = false;
                  if(key=="D"){
                    loadBlockList(selectedDistrict);
                  }else if(key=="B"){
                    level== "S" ?getVillageList(selectedDistrict,selectedBlock):loadVillageList(selectedBlock);
                    getVillageList(selectedDistrict,selectedBlock);
                  }else if(key=="V"){
                    loadSchemeList(selectedDistrict,selectedBlock,selectedVillage,finList);
                  }
                  Navigator.pop(context, 'OK');
                  setState(() {

                  });

                },
                child: Text(
                s.key_ok ,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: c.primary_text_color2,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
              ),
            ))
                ],)

              ),
            );
          }
      );}
    void multiChoiceSelection(List<FlutterLimitedCheckBoxModel> list,String msg,String key){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(msg,style: TextStyle(color: c.grey_10,fontSize: 14),),
              content: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                  Expanded(child:  Align(
                    alignment: Alignment.centerLeft,
                    child: FlutterLimitedCheckbox(
                      limit: 2,
                      limitedValueList: list,
                      onChanged: (List<FlutterLimitedCheckBoxModel> list){
                        if(key=="F"){
                          finList.clear();
                          for (int i = 0; i < list.length; i++) {
                            finList.add(list[i].selectTitle);
                          }
                          print(finList.toString());
                        }else{
                          schList.clear();
                          schIdList.clear();
                          for (int i = 0; i < list.length; i++) {
                            schList.add(list[i].selectTitle);
                            schIdList.add(list[i].selectId);
                          }
                          print(schIdList.toString());
                        }

                        },
                      mainAxisAlignmentOfRow: MainAxisAlignment.start,
                      crossAxisAlignmentOfRow: CrossAxisAlignment.center,
                    ),
                  ),),
                  Container(
                      alignment: AlignmentDirectional.bottomEnd,
                      child:      Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
              child: InkWell(
                onTap: (){
            if(key=="F"){
              Navigator.pop(context, 'OK');
              submitFlag = false;
            }else{
              submitFlag=true;
              Navigator.pop(context, 'OK');

            }
            setState(() {

            });
                },
                child: Text(
                s.key_ok ,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: c.primary_text_color2,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
              ),
            ))
                ],)

              ),
            );
          }
      );}

  Future<void> loadBlockList(String selectedDistrict) async {
    dFlag = true;
    bFlag = true;
    vFlag = false;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM ' + s.table_Block+' Where dcode='+selectedDistrict);
    for (int i = 0; i < list.length; i++) {
      bList.add(FlutterLimitedCheckBoxModel(
          isSelected: false,
          selectTitle: list[i][s.key_bname],
          selectId:int.parse(list[i][s.key_bcode])));
    }

    print(list.toString());
    setState(() {

    });
  }

  Future<void> loadVillageList(String selectedBlock) async {
    dFlag = true;
    bFlag = true;
    vFlag = true;
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM ' + s.table_Village+' Where bcode='+selectedBlock);
    for (int i = 0; i < list.length; i++) {
      vList.add(FlutterLimitedCheckBoxModel(
          isSelected: false,
          selectTitle: list[i][s.key_pvname],
          selectId: int.parse(list[i][s.key_pvcode])));
      print(list.toString());
    }
  }

  Future<void> getVillageList(String selectedDistrict, String selectedBlock) async {
    Map json_request = {};

    json_request = {
      s.key_dcode: selectedDistrict ,
      s.key_bcode: selectedBlock,
      s.key_service_id: s.service_key_village_list_district_block_wise,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
      utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
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
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("VillageList_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      dFlag = true;
      bFlag = true;
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

      });
    }
  }

  Future<void> loadSchemeList(String selectedDistrict, String selectedBlock, String selectedVillage, List finList) async {
    Map json_request = {};
    json_request = {
      s.key_dcode: selectedDistrict,
      s.key_bcode: selectedBlock,
      s.key_pvcode: selectedVillage,
      s.key_fin_year: finList,
      s.key_service_id: s.service_key_scheme_list,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: utils.encryption(
          json.encode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service,
        body: json.encode(encrpted_request));
    print("SchemeList_url>>" + url.main_service.toString());
    print("SchemeList_request_json>>" + json_request.toString());
    print("SchemeList_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("SchemeList_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = utils.decryption(
          enc_data.toString(), prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
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
            schemeList.add(FlutterLimitedCheckBoxModel(
                isSelected: false,
                selectTitle: res_jsonArray[i][s.key_scheme_name],
                selectId: int.parse(res_jsonArray[i][s.key_scheme_id])));
          }
          schemeFlag = true;

          print("schemeList>>" + schemeList.toString());
        }
        setState(() {

        });
      } else if (status == s.key_ok && responseValue == s.key_noRecord) {
        Utils().showAlert(context, "No Scheme Found");
      }
    }
  }

}
