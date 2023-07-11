// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unnecessary_new, unrelated_type_equality_checks

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/ATR_Save.dart';
import 'package:inspection_flutter_app/Activity/View_Image.dart';
import 'package:inspection_flutter_app/Layout/ReadMoreLess.dart';
import 'package:inspection_flutter_app/Resources/global.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DataBase/DbHelper.dart';
import '../Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import '../Utils/utils.dart';
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:inspection_flutter_app/Resources/url.dart' as url;

import 'SaveWorkDetails.dart';

class PendingScreen extends StatefulWidget {
  PendingScreen();

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;

  int worklistCount = 0;

  // Bool Variables
  bool isWorklistAvailable = false;
  bool flag = false;
  bool flagTab = false;
  int flagTaped = 1;
  String level = "";

  List<Map> atr_WorkList = [];
  List<Map> rdpr_WorkList = [];

  List defaultWorklist = [];
  List selectedWorklist = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    level = prefs.getString(s.key_level).toString();
    // utils.customAlertWidet(context, "Success", s.online_data_save_success);
    await fetchOfflineWorklist();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: c.background_color,
        appBar: AppBar(
          backgroundColor: c.colorPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(context),
          ),
          title: Text(s.pending_list),
          centerTitle: true, // like this!
        ),
        body: Column(
          children: [
            Visibility(
              visible: flagTab,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          flag = false;
                          flagTaped = 1;
                          fetchOfflineWorklist();
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(20, 10, 0, 0),
                        padding: EdgeInsets.all(10),
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        alignment: AlignmentDirectional.center,
                        decoration: new BoxDecoration(
                            color: flagTaped == 1 ? c.colorAccent : c.white,
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(30),
                              topRight: const Radius.circular(0),
                              bottomLeft: const Radius.circular(30),
                              bottomRight: const Radius.circular(0),
                            )),
                        child: Text(
                          s.rdpr_works +
                              ' (' +
                              rdpr_WorkList.length.toString() +
                              ') ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: flagTaped == 1 ? c.white : c.grey_8,
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
                          flag = true;
                          flagTaped = 2;
                          fetchOfflineWorklist();
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 20, 0),
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        alignment: AlignmentDirectional.center,
                        decoration: new BoxDecoration(
                            color: flagTaped == 2 ? c.colorAccent : c.white,
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(0),
                              topRight: const Radius.circular(30),
                              bottomLeft: const Radius.circular(0),
                              bottomRight: const Radius.circular(30),
                            )),
                        child: Text(
                          s.action_taken_report +
                              ' (' +
                              atr_WorkList.length.toString() +
                              ') ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: flagTaped == 2 ? c.white : c.grey_8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Container(
              margin: const EdgeInsets.only(top: 0),
              color: c.background_color,
              width: screenWidth,
              height: sceenHeight - 80,
              child: __PendingScreenListAdaptor(),
            )),
          ],
        ));
  }

  // *************************** Pending Design Starts here *************************** //

  __PendingScreenListAdaptor() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: AnimationLimiter(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: defaultWorklist.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 800),
                  child: SlideAnimation(
                    horizontalOffset: 150.0,
                    child: FlipAnimation(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Stack(children: [
                        Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 25),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: c.light_green,
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              selectedWorklist.clear();
                                              selectedWorklist
                                                  .add(defaultWorklist[index]);
                                              await __imageWorkList(
                                                  selectedWorklist);
                                            },
                                            child: Image.asset(
                                              imagePath.gallery,
                                              width: 25,
                                              height: 25,
                                              color: c.sky_blue,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
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
                                              s.work_id,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
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
                                                  fontWeight: FontWeight.bold,
                                                  color: c.grey_8),
                                              overflow: TextOverflow.clip,
                                              maxLines: 1,
                                              softWrap: true,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  10, 0, 5, 0),
                                              child: Align(
                                                alignment: AlignmentDirectional
                                                    .topStart,
                                                child: Text(
                                                  defaultWorklist[index]
                                                          [s.key_work_id]
                                                      .toString(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
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
                                              s.work_name,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
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
                                                  fontWeight: FontWeight.bold,
                                                  color: c.grey_8),
                                              overflow: TextOverflow.clip,
                                              maxLines: 1,
                                              softWrap: true,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  10, 0, 5, 0),
                                              child: Align(
                                                alignment: AlignmentDirectional
                                                    .topStart,
                                                child: ExpandableText(
                                                    defaultWorklist[index]
                                                            [s.key_work_name]
                                                        .toString(),
                                                    trimLines: 2,txtcolor: "2",),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Visibility(
                                        visible: flagTaped == 2 ? !flag : flag,
                                        // visible: flag,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                s.inspection_id,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
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
                                                    fontWeight: FontWeight.bold,
                                                    color: c.grey_8),
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 0, 5, 0),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .topStart,
                                                  child: Text(
                                                    defaultWorklist[index][
                                                            s.key_inspection_id]
                                                        .toString(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Visibility(
                                        visible: flagTaped == 2 ? flag : !flag,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                s.financial_year,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
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
                                                    fontWeight: FontWeight.bold,
                                                    color: c.grey_8),
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 0, 5, 0),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .topStart,
                                                  child: Text(
                                                    defaultWorklist[index]
                                                            [s.key_fin_year]
                                                        .toString(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Visibility(
                                        visible: flagTaped == 2 ? flag : !flag,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                s.status,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
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
                                                    fontWeight: FontWeight.bold,
                                                    color: c.grey_8),
                                                overflow: TextOverflow.clip,
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 0, 5, 0),
                                                child: Align(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .topStart,
                                                  child: Text(
                                                    defaultWorklist[index]
                                                            ['work_status']
                                                        .toString(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              selectedWorklist.clear();
                                              selectedWorklist
                                                  .add(defaultWorklist[index]);
                                              await __editWorkList(
                                                  selectedWorklist);
                                            },
                                            child: Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  10, 0, 0, 0),
                                              decoration: BoxDecoration(
                                                  color: c.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.asset(
                                                  imagePath.edit,
                                                  width: 17,
                                                  height: 17,
                                                  color: c.sky_blue,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              selectedWorklist.clear();
                                              selectedWorklist
                                                  .add(defaultWorklist[index]);
                                              await __deleteWorklist(
                                                  selectedWorklist);
                                            },
                                            child: Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  10, 0, 10, 0),
                                              decoration: BoxDecoration(
                                                  color: c.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.asset(
                                                  imagePath.delete,
                                                  width: 17,
                                                  height: 17,
                                                  color: c.sky_blue,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              selectedWorklist.clear();
                                              selectedWorklist
                                                  .add(defaultWorklist[index]);

                                              await __uploadWorklist(
                                                  selectedWorklist);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: c.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.asset(
                                                  imagePath.upload_img,
                                                  width: 17,
                                                  height: 17,
                                                  color: c.sky_blue,
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Text(
                                        flagTaped == 2 &&
                                                defaultWorklist[index]
                                                        [s.key_rural_urban] ==
                                                    "R"
                                            ? s.atr_for_rural
                                            : flagTaped == 2 &&
                                                    defaultWorklist[index][s
                                                            .key_rural_urban] ==
                                                        "U"
                                                ? s.atr_for_urban
                                                : flagTaped == 1 &&
                                                        defaultWorklist[index][s
                                                                .key_rural_urban] ==
                                                            "R"
                                                    ? s.ins_rural_work
                                                    : flagTaped == 1 &&
                                                            defaultWorklist[index][s
                                                                    .key_rural_urban] ==
                                                                "U"
                                                        ? s.ins_urban_work
                                                        : "",
                                        style: GoogleFonts.getFont('Roboto',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color: c.grey_9)),
                                  ),
                                )
                              ],
                            )),
                        Positioned(
                            top: 0,
                            left: 10,
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: c.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 5.0,
                                    ),
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  flag
                                      ? imagePath.infrastructure
                                      : imagePath.graph_ic,
                                  width: 17,
                                  height: 17,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ))
                      ]),
                    )),
                  ),
                );
              })),
    );
  }

  // *************************** Pending Design Ends here *************************** //

  // *************************** ADOPTOR ACTION Starts here *************************** //

  __imageWorkList(List workList) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ViewImage(workList: workList)),
    );
  }

  __deleteWorklist(List workList) async {
    await utils
        .customAlertWidet(context, "Warning", s.delete_local_data_msg)
        .then((value) async {
      bool flag = (value as bool);
      if (flag) {
        await gotoDelete(workList, false);
        await fetchOfflineWorklist();
      }
    });
  }

  __editWorkList(List workList) async {
    String rural_urban = workList[0][s.key_rural_urban];
    String flag = workList[0][s.key_flag];

    if (flag == "rdpr") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SaveWorkDetails(
                    selectedworkList: workList,
                    rural_urban: rural_urban,
                    onoff_type: "offline",
                    flag: "pending",
                    townType: "",
                    imagelist: [],
                  ))).then((value) => {initialize()});
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(
            builder: (context) => ATR_Save(
              rural_urban: rural_urban,
              onoff_type: "offline",
              selectedWorklist: workList,
              imagelist: [],
              flag: "",
            ),
          ))
          .then((value) => {initialize()});
    }
  }

  __uploadWorklist(List workList) async {
    if (await utils.isOnline()) {
      await utils
          .customAlertWidet(context, "Warning", s.upload_local_data_msg)
          .then((value) {
        bool flag = (value as bool);
        if (flag) {
          gotoUpload(workList);
        }
      });
    } else {
      utils.customAlertWidet(context, "Error", s.no_internet);
    }
  }

  // *************************** ADOPTOR ACTION ends here *************************** //

  // *************************** Fetch Offline Worklist starts  Here  *************************** //

  Future<void> fetchOfflineWorklist() async {
    //Empty the Worklist
    defaultWorklist = [];
    atr_WorkList = [];
    rdpr_WorkList = [];

    rdpr_WorkList = await dbClient.rawQuery(
        "SELECT * FROM ${s.table_save_work_details} WHERE flag='rdpr' ");
    if (level == "B") {
      atr_WorkList = await dbClient.rawQuery(
          "SELECT * FROM ${s.table_save_work_details} WHERE flag='ATR' ");
      flagTab = true;
    } else {
      flagTab = false;
    }

    if (flagTaped == 1) {
      if (rdpr_WorkList.isEmpty) {
        setState(() {
          isWorklistAvailable = false;
        });
      } else {
        defaultWorklist = rdpr_WorkList;

        print("<<<<<<<<< WORKLIST >>>>>>>");
        print(defaultWorklist);

        setState(() {
          isWorklistAvailable = true;
          flag = false;
        });
      }
    } else {
      if (atr_WorkList.isEmpty) {
        setState(() {
          isWorklistAvailable = false;
        });
      } else {
        defaultWorklist = atr_WorkList;

        print("<<<<<<<<< WORKLIST >>>>>>>");
        print(defaultWorklist);

        setState(() {
          isWorklistAvailable = true;
          flag = false;
        });
      }
    }

    setState(() {});
  }

  // *************************** Fetch Offline Worklist ends  Here  *************************** //

  // *************************** GO TO DELETE   *************************** //

  gotoDelete(List workList, bool save) async {
    String conditionParam = "";

    String flag = workList[0][s.key_flag];
    String workid = workList[0][s.key_work_id];
    String dcode = workList[0][s.key_dcode];
    String rural_urban = workList[0][s.key_rural_urban];
    String inspection_id = workList[0][s.key_inspection_id];

    if (flag == "ATR") {
      conditionParam =
          "WHERE flag='$flag' and rural_urban='$rural_urban' and work_id='$workid' and inspection_id='$inspection_id' and dcode='$dcode'";
    } else {
      conditionParam =
          "WHERE flag='$flag'and rural_urban='$rural_urban' and work_id='$workid' and dcode='$dcode'";
    }

    var imageDelete = await dbClient
        .rawQuery("DELETE FROM ${s.table_save_images} $conditionParam ");
    var workListDelete = await dbClient
        .rawQuery("DELETE FROM ${s.table_save_work_details} $conditionParam");

    if (save) {
      // Save Delete

      var offlineWorkListDelete = await dbClient
          .rawQuery("DELETE FROM ${s.table_AtrWorkList} $conditionParam");

      if (imageDelete.length == 0 &&
          workListDelete.length == 0 &&
          offlineWorkListDelete.length == 0) {
        await utils.customAlertWidet(
            context, "Success", s.online_data_save_success);
      }
    } else {
      // Normal Delete

      if (imageDelete.length == 0 && workListDelete.length == 0) {
        utils.customAlertWidet(
            context, "Success", s.delete_local_data_msg_success);
      }
    }
  }

  // *************************** GO TO DELETE   *************************** //

  gotoUpload(List workList) async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    utils.showProgress(context, 1);
    if (await utils.isOnline()) {
      String conditionParam = "";

      String rural_urban = workList[0][s.key_rural_urban];
      String work_id = workList[0][s.key_work_id];
      String dcode = workList[0][s.key_dcode];
      String flag = workList[0][s.key_flag];
      String inspection_id = workList[0][s.key_inspection_id];

      List<dynamic> inspection_work_details = [];
      Map dataset = {};
      //Get Offline Imager

      if (flag == "ATR") {
        conditionParam =
            "WHERE flag='$flag' and rural_urban='$rural_urban' and work_id='$work_id' and inspection_id='$inspection_id' and dcode='$dcode'";
        dataset = {
          s.key_dcode: dcode,
          s.key_rural_urban: rural_urban,
          s.key_work_id: work_id,
          s.key_inspection_id: inspection_id,
          'description': workList[0][s.key_description],
        };
      } else {
        conditionParam =
            "WHERE flag='$flag' and rural_urban='$rural_urban' and work_id='$work_id' and dcode='$dcode'";

        dataset = {
          s.key_dcode: dcode,
          s.key_rural_urban: rural_urban,
          s.key_work_id: work_id,
          s.key_status_id: workList[0]['work_status_id'].toString(),
          s.key_work_stage_code: workList[0]['work_stage_id'].toString(),
          s.key_work_group_id: workList[0][s.key_work_group_id].toString(),
          s.key_work_type_id: workList[0][s.key_work_type_id].toString(),
          'description': workList[0][s.key_description],
        };
      }

      var imageExists = [];
      imageExists = await dbClient
          .rawQuery("SELECT * FROM ${s.table_save_images} $conditionParam");

      Map urbanRequest = {};
      Map ruralRequest = {};
      Map main_dataset = {};
      Map imgset = {
        'image_details': imageExists,
      };

      if (rural_urban == "U") {
        if (workList[0][s.key_town_type] == "T") {
          urbanRequest = {
            s.key_town_type: workList[0][s.key_town_type],
            s.key_tpcode: workList[0][s.key_tpcode],
          };
        } else if (workList[0][s.key_town_type] == "M") {
          urbanRequest = {
            s.key_town_type: workList[0][s.key_town_type],
            s.key_muncode: workList[0][s.key_muncode],
          };
        } else if (workList[0][s.key_town_type] == "C") {
          urbanRequest = {
            s.key_town_type: workList[0][s.key_town_type],
            s.key_corcode: workList[0][s.key_corcode],
          };
        }
        dataset.addAll(urbanRequest);
      } else {
        ruralRequest = {
          s.key_bcode: workList[0][s.key_bcode],
          s.key_pvcode: workList[0][s.key_pvcode],
        };
        dataset.addAll(ruralRequest);
      }

      dataset.addAll(imgset);

      inspection_work_details.add(dataset);
      if (flag == "ATR") {
        main_dataset = {
          s.key_service_id: s.service_key_action_taken_details_save,
          'inspection_work_details': inspection_work_details,
        };
      } else {
        main_dataset = {
          s.key_service_id: s.service_key_work_inspection_details_save,
          'inspection_work_details': inspection_work_details,
        };
      }

      Map encrypted_request = {
        s.key_user_name: prefs.getString(s.key_user_name),
        s.key_data_content: main_dataset,
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

      print("saveWorkList_url>>" + url.main_service_jwt.toString());
      print("saveWorkList_request_json>>" + main_dataset.toString());
      print("saveWorkList_request_encrpt>>" + encrypted_request.toString());
      utils.hideProgress(context);

      if (response.statusCode == 200) {
        // If the server did return a 201 CREATED response,
        // then parse the JSON.
        String data = response.body;
        print("saveWorkList_response>>$data");
        String? authorizationHeader = response.headers['authorization'];

        String? token = authorizationHeader?.split(' ')[1];

        print("saveWorkList Authorization -  $token");

        String responceSignature = utils.jwt_Decode(key, token!);

        String responceData = utils.generateHmacSha256(data, key, false);

        print("saveWorkList responceSignature -  $responceSignature");

        print("saveWorkList responceData -  $responceData");

        if (responceSignature == responceData) {
          print("saveWorkList responceSignature - Token Verified");
          var userData = jsonDecode(data);
          var status = userData[s.key_status];
          var response_value = userData[s.key_response];
          var msg = userData[s.key_message];
          if (status == s.key_ok && response_value == s.key_ok) {
            await gotoDelete(workList, true);

            fetchOfflineWorklist();
          } else {
            await utils.customAlertWidet(context, "Error", msg);
          }
        } else {
          print("saveWorkList responceSignature - Token Not Verified");
          utils.customAlertWidet(context, "Error", s.jsonError);
        }
      }
    } else {
      utils.customAlertWidet(context, "Error", s.no_internet);
      //no internet
    }
  }
}
