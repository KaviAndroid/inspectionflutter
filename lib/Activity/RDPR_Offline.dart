// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, prefer_interpolation_to_compose_strings, use_build_context_synchronously, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:flutter_limited_checkbox/flutter_limited_checkbox.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../DataBase/DbHelper.dart';
import '../Resources/Strings.dart';
import '../Utils/utils.dart';
import 'WorkList.dart';

class RDPR_Offline extends StatefulWidget {
  const RDPR_Offline({Key? key}) : super(key: key);

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
  bool skipFlag = false;
  bool dFlag = false;
  bool bFlag = false;
  bool vFlag = false;

  // simple usage

  List<FlutterLimitedCheckBoxModel> vList = [];
  List<FlutterLimitedCheckBoxModel> dList = [];
  List<Map<String, String>> districtList = [];
  List<Map<String, String>> blockList = [];
  List<Map<String, String>> villageList = [];

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
    if (level == "S") {
      dFlag = true;
      bFlag = false;
      vFlag = false;
      List<Map> list =
          await dbClient.rawQuery('SELECT * FROM ' + s.table_District);
      for (int i = 0; i < list.length; i++) {
        Map<String, String> maplist = {
          s.key_dcode: list[i][s.key_dcode],
          s.key_dname: list[i][s.key_dname],
        };
        districtList.add(maplist);
      }
      print(list.toString());
    } else if (level == "D") {
      dFlag = false;
      bFlag = true;
      vFlag = false;
      List<Map> list =
          await dbClient.rawQuery('SELECT * FROM ' + s.table_Block);
      for (int i = 0; i < list.length; i++) {
        vList.add(FlutterLimitedCheckBoxModel(
            isSelected: false,
            selectTitle: list[i][s.key_dcode],
            selectId: list[i][s.key_dname]));
      }

      print(list.toString());
    } else if (level == "B") {
      dFlag = false;
      bFlag = false;
      vFlag = true;
      List<Map> list =
          await dbClient.rawQuery('SELECT * FROM ' + s.table_Village);

      for (int i = 0; i < list.length; i++) {
        Map<String, String> maplist = {
          s.key_pvcode: list[i][s.key_pvcode],
          s.key_pvname: list[i][s.key_pvname],
        };
        vList.add(FlutterLimitedCheckBoxModel(
            isSelected: false,
            selectTitle: list[i][s.key_pvname],
            selectId: list[i][s.key_pvcode]));
        villageList.add(maplist);
        print(list.toString());
      }

      List<Map> list_urban = await dbClient.rawQuery(
          "SELECT * FROM ${s.table_RdprWorkList} where rural_urban='${prefs.getString(s.area_type)}' ");
      list_urban.length > 0 && onOffType == "offline"
          ? skipFlag = true
          : skipFlag = false;
      setState(() {});
    }
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
                                              onTap: () {},
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
                                              s.select_financial_year,
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
                                                  singleChoiceSelection(dList);
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
                                                s.selectedDistrict,
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
                                                onTap: () {},
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
                                                s.selectedBlock,
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
                                                  singleChoiceSelection(vList);
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
                                                s.selected_village,
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
                                              onTap: () {},
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
                                              s.selected_scheme,
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
                              ],
                            ),
                          )),
                      Container(
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

  void singleChoiceSelection(List<FlutterLimitedCheckBoxModel> list) {
    FlutterSingleCheckbox(
      singleValueList: list,
      onChanged: (index) {},
    );
/*      SmartSelect<String>.single(
        selectedValue: list[0][s.key_dcode].toString(),
        choiceItems: S2Choice.listFrom<String, Map<String, String>>(
          source: list,
          value: (index, item) => item[s.key_dcode].toString(),
          title: (index, item) => item[s.key_dname].toString(),
        ),
      );*/
  }
/*
    void singleChoiceSelection(List<Map<String, String>> list){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: SmartSelect<String>.single(
                selectedValue: list[0][s.key_dcode].toString(),
                choiceItems: S2Choice.listFrom<String, Map<String, String>>(
                  source: list,
                  value: (index, item) => item[s.key_dcode].toString(),
                  title: (index, item) => item[s.key_dname].toString(),
                ),
              ),
            );
          }
      );}
*/
}
