
import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/SaveWorkDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:inspection_flutter_app/Resources/url.dart' as url;

import '../DataBase/DbHelper.dart';
import '../Layout/ReadMoreLess.dart';
import '../Utils/utils.dart';

class WorkList extends StatefulWidget {
  final schemeList;
  final finYear;
  final dcode;
  final bcode;
  final pvcode;
  final scheme;
  final flag;

  WorkList({this.schemeList, this.finYear, this.dcode, this.bcode, this.pvcode, this.scheme, this.flag});
  @override
  State<WorkList> createState() =>
      _WorkListState();
}

class _WorkListState extends State<WorkList> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  bool noDataFlag = false;
  bool workListFlag = false;
  List<bool> showFlag=[];
  int flag = 1;
  List workList = [];
  List ongoingWorkList = [];
  List completedWorkList = [];
  List selectedworkList = [];
  List schemeItems = [];
  String selectedScheme="";
  bool isLoadingScheme = false;
  bool schemeError = false;
  bool schemeFlag = false;

  Map<String, String> defaultSelectedScheme = {
    s.key_scheme_id: "0",
    s.key_scheme_name: s.select_scheme
  };

  @override
  void initState() {
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    schemeItems.addAll(widget.schemeList);
    if(widget.flag=='filter'){
      selectedScheme=widget.scheme;
      schemeFlag=true;
      await getWorkList(widget.finYear,widget.dcode,widget.bcode,widget.pvcode,widget.scheme);
    }else{
      schemeFlag=false;
      await getWorkListByVillage(widget.dcode, widget.bcode,widget.pvcode);
    }


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
            color: c.bg_screen,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [

                Visibility(
                  visible: schemeFlag
                      ? true
                      : false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.only(top: 15, bottom: 15,left: 20,right: 20),
                        child: Text(
                          s.select_scheme,
                          style: GoogleFonts.raleway().copyWith(
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
                              style:
                              const TextStyle(color: Colors.black),
                              value: selectedScheme,
                              isExpanded: true,
                              items: schemeItems
                                  .map((item) =>
                                  DropdownMenuItem<String>(
                                    value: item[s.key_scheme_id]
                                        .toString(),
                                    child: Text(
                                      item[s.key_scheme_name].toString(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != "0") {
                                  isLoadingScheme= true;
                                  selectedScheme = value.toString();
                                  getWorkList(widget.finYear,widget.dcode,widget.bcode,widget.pvcode,selectedScheme);
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
                                  duration: const Duration(
                                      milliseconds: 1200),
                                )
                                    : const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black45,
                                ),
                                iconSize: 30,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(15),
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
                Row(
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
                            } else {
                              workList = [];
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
                            s.ongoing_works+' ('+ongoingWorkList.length.toString()+') ',
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
                            } else {
                              workList = [];
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
                            s.completed_works+' ('+completedWorkList.length.toString()+') ',
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
                Expanded(
                  child: Stack(children: [
                    Visibility(
                      visible: workListFlag,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: ListView.builder(
                          itemCount: workList == null ? 0 : workList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return                              InkWell(
                                onTap: () {},
                                child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),

                                    ),

                                    // clipBehavior is necessary because, without it, the InkWell's animation
                                    // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                                    // This comes with a small performance cost, and you should not set [clipBehavior]
                                    // unless you need it.
                                    clipBehavior: Clip.hardEdge,
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child:  ClipPath(
                                      clipper: ShapeBorderClipper(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(3))),
                                      child: Container(
                                          width: 10,
                                          padding: EdgeInsets.fromLTRB(10,5,5,5),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(color: c.colorAccent, width: 5),
                                            ),
                                          ),
                                          child: Container(
                                            child: Column(children: [
                                              Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        selectedworkList.clear();
                                                        selectedworkList.add(workList[index]);
                                                        print('selectedworkList>>'+selectedworkList.toString());

                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => SaveWorkDetails(
                                                                  selectedworkList: selectedworkList,
                                                                )));
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.fromLTRB(
                                                            10, 5, 10, 0),
                                                        child: Image.asset(
                                                          imagePath.action,
                                                          height: 35,
                                                          width: 40,
                                                        ),
                                                      ),
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
                                                                fontWeight:
                                                                FontWeight.bold,
                                                                color: c.grey_8),
                                                            overflow:
                                                            TextOverflow.clip,
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
                                                                FontWeight.bold,
                                                                color: c.grey_8),
                                                            overflow:
                                                            TextOverflow.clip,
                                                            maxLines: 1,
                                                            softWrap: true,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Container(
                                                            margin:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 10, 0),
                                                            child: Align(
                                                              alignment:
                                                              AlignmentDirectional
                                                                  .topStart,
                                                              child: ExpandableText(
                                                                  workList[index][s
                                                                      .key_work_id]
                                                                      .toString(),
                                                                  trimLines: 2),
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
                                                            s.work_name,
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                FontWeight.bold,
                                                                color: c.grey_8),
                                                            overflow:
                                                            TextOverflow.clip,
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
                                                                FontWeight.bold,
                                                                color: c.grey_8),
                                                            overflow:
                                                            TextOverflow.clip,
                                                            maxLines: 1,
                                                            softWrap: true,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Container(
                                                            margin:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 5, 0),
                                                            child: Align(
                                                              alignment:
                                                              AlignmentDirectional
                                                                  .topStart,
                                                              child: ExpandableText(
                                                                  workList[index][s
                                                                      .key_work_name]
                                                                      .toString(),
                                                                  trimLines: 2),
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
                                                            s.stage_name,
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                FontWeight.bold,
                                                                color: c.grey_8),
                                                            overflow:
                                                            TextOverflow.clip,
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
                                                                FontWeight.bold,
                                                                color: c.grey_8),
                                                            overflow:
                                                            TextOverflow.clip,
                                                            maxLines: 1,
                                                            softWrap: true,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Container(
                                                            margin:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 5, 0),
                                                            child: Align(
                                                              alignment:
                                                              AlignmentDirectional
                                                                  .topStart,
                                                              child: ExpandableText(
                                                                  workList[index][s
                                                                      .key_stage_name]
                                                                      .toString(),
                                                                  trimLines: 2),
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
                                                            s.work_type_name,
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                FontWeight.bold,
                                                                color: c.grey_8),
                                                            overflow:
                                                            TextOverflow.clip,
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
                                                                FontWeight.bold,
                                                                color: c.grey_8),
                                                            overflow:
                                                            TextOverflow.clip,
                                                            maxLines: 1,
                                                            softWrap: true,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Container(
                                                            margin:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 10, 0),
                                                            child: Align(
                                                              alignment:
                                                              AlignmentDirectional
                                                                  .topStart,
                                                              child: ExpandableText(
                                                                  workList[index][s
                                                                      .key_work_type_name]
                                                                      .toString(),
                                                                  trimLines: 2),
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
                                                            s.scheme,
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                FontWeight.bold,
                                                                color: c.grey_8),
                                                            overflow:
                                                            TextOverflow.clip,
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
                                                                FontWeight.bold,
                                                                color: c.grey_8),
                                                            overflow:
                                                            TextOverflow.clip,
                                                            maxLines: 1,
                                                            softWrap: true,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Container(
                                                            margin:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 10, 0),
                                                            child: Align(
                                                              alignment:
                                                              AlignmentDirectional
                                                                  .topStart,
                                                              child: ExpandableText(
                                                                  workList[index][s
                                                                      .key_scheme_name]
                                                                      .toString(),
                                                                  trimLines: 2),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 1,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: Container(
                                                            margin:
                                                            EdgeInsets.fromLTRB(
                                                                0, 10, 0, 10),
                                                            child: Text(
                                                              s.financial_year,
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  color: c.grey_8),
                                                              overflow:
                                                              TextOverflow.clip,
                                                              maxLines: 1,
                                                              softWrap: true,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 0,
                                                          child: Container(
                                                            margin:
                                                            EdgeInsets.fromLTRB(
                                                                0, 10, 0, 10),
                                                            child:Text(
                                                              ' : ',
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  color: c.grey_8),
                                                              overflow:
                                                              TextOverflow.clip,
                                                              maxLines: 1,
                                                              softWrap: true,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Container(
                                                            margin:
                                                            EdgeInsets.fromLTRB(
                                                                10, 10, 10, 10),
                                                            child: Align(
                                                              alignment:
                                                              AlignmentDirectional
                                                                  .topStart,
                                                              child: ExpandableText(
                                                                  workList[index][s
                                                                      .key_fin_year]
                                                                      .toString(),
                                                                  trimLines: 2),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: InkWell(
                                                            onTap: (){
                                                              setState(() {
                                                                showFlag[index]=!showFlag[index];
                                                              });

                                                            },
                                                            child:Container(
                                                              alignment:
                                                              Alignment.topLeft,
                                                              margin:
                                                              EdgeInsets.fromLTRB(
                                                                  10, 0, 10, 0),
                                                              child: Align(
                                                                alignment:
                                                                Alignment.topLeft,
                                                                child: Image.asset(
                                                                  imagePath
                                                                      .arrow_down_icon,
                                                                  color: c
                                                                      .primary_text_color2,
                                                                  height: 30,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 0,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Visibility(
                                                visible: showFlag[index],
                                                child: AnimatedSwitcher(
                                                  duration: Duration(seconds: 5),
                                                  child:showFlag[index] ? Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                s.district,
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
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
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
                                                                maxLines: 1,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Container(
                                                                margin:
                                                                EdgeInsets.fromLTRB(
                                                                    10, 0, 10, 0),
                                                                child: Align(
                                                                  alignment:
                                                                  AlignmentDirectional
                                                                      .topStart,
                                                                  child: ExpandableText(
                                                                      workList[index][s
                                                                          .key_dname]
                                                                          .toString(),
                                                                      trimLines: 2),
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
                                                                s.block,
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
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
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
                                                                maxLines: 1,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Container(
                                                                margin:
                                                                EdgeInsets.fromLTRB(
                                                                    10, 0, 5, 0),
                                                                child: Align(
                                                                  alignment:
                                                                  AlignmentDirectional
                                                                      .topStart,
                                                                  child: ExpandableText(
                                                                      workList[index][s
                                                                          .key_bname]
                                                                          .toString(),
                                                                      trimLines: 2),
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
                                                                s.village,
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
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
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
                                                                maxLines: 1,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Container(
                                                                margin:
                                                                EdgeInsets.fromLTRB(
                                                                    10, 0, 5, 0),
                                                                child: Align(
                                                                  alignment:
                                                                  AlignmentDirectional
                                                                      .topStart,
                                                                  child: ExpandableText(
                                                                      workList[index][s
                                                                          .key_pvname]
                                                                          .toString(),
                                                                      trimLines: 2),
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
                                                                s.town_panchayat,
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
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
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
                                                                maxLines: 1,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Container(
                                                                margin:
                                                                EdgeInsets.fromLTRB(
                                                                    10, 0, 10, 0),
                                                                child: Align(
                                                                  alignment:
                                                                  AlignmentDirectional
                                                                      .topStart,
                                                                  child: ExpandableText(
                                                                      workList[index][s
                                                                          .key_townpanchayat_name]
                                                                          .toString(),
                                                                      trimLines: 2),
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
                                                                s.municipality,
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
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
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
                                                                maxLines: 1,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Container(
                                                                margin:
                                                                EdgeInsets.fromLTRB(
                                                                    10, 0, 10, 0),
                                                                child: Align(
                                                                  alignment:
                                                                  AlignmentDirectional
                                                                      .topStart,
                                                                  child: ExpandableText(
                                                                      workList[index][s
                                                                          .key_municipality_name]
                                                                          .toString(),
                                                                      trimLines: 2),
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
                                                                s.corporation,
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
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
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
                                                                maxLines: 1,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Container(
                                                                margin:
                                                                EdgeInsets.fromLTRB(
                                                                    10, 0, 10, 0),
                                                                child: Align(
                                                                  alignment:
                                                                  AlignmentDirectional
                                                                      .topStart,
                                                                  child: ExpandableText(
                                                                      workList[index][s
                                                                          .key_corporation_name]
                                                                          .toString(),
                                                                      trimLines: 2),
                                                                ),
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ), Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                s.as_value,
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
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
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
                                                                maxLines: 1,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Container(
                                                                margin:
                                                                EdgeInsets.fromLTRB(
                                                                    10, 0, 10, 0),
                                                                child: Align(
                                                                  alignment:
                                                                  AlignmentDirectional
                                                                      .topStart,
                                                                  child: ExpandableText(
                                                                      workList[index][s
                                                                          .key_as_value]
                                                                          .toString(),
                                                                      trimLines: 2),
                                                                ),
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ), Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                s.ts_value,
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
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
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
                                                                maxLines: 1,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Container(
                                                                margin:
                                                                EdgeInsets.fromLTRB(
                                                                    10, 0, 10, 0),
                                                                child: Align(
                                                                  alignment:
                                                                  AlignmentDirectional
                                                                      .topStart,
                                                                  child: ExpandableText(
                                                                      workList[index][s
                                                                          .key_ts_value]
                                                                          .toString(),
                                                                      trimLines: 2),
                                                                ),
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ), Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                s.agreement_work_orderdate,
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
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
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
                                                                maxLines: 1,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Container(
                                                                margin:
                                                                EdgeInsets.fromLTRB(
                                                                    10, 0, 10, 0),
                                                                child: Align(
                                                                  alignment:
                                                                  AlignmentDirectional
                                                                      .topStart,
                                                                  child: ExpandableText(
                                                                      workList[index][s
                                                                          .key_work_order_date]
                                                                          .toString(),
                                                                      trimLines: 2),
                                                                ),
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ), Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                s.as_date,
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
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
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
                                                                maxLines: 1,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Container(
                                                                margin:
                                                                EdgeInsets.fromLTRB(
                                                                    10, 0, 10, 0),
                                                                child: Align(
                                                                  alignment:
                                                                  AlignmentDirectional
                                                                      .topStart,
                                                                  child: ExpandableText(
                                                                      workList[index][s
                                                                          .key_as_value]
                                                                          .toString(),
                                                                      trimLines: 2),
                                                                ),
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ), Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                s.ts_date,
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    fontWeight:
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
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
                                                                    FontWeight.bold,
                                                                    color: c.grey_8),
                                                                overflow:
                                                                TextOverflow.clip,
                                                                maxLines: 1,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Container(
                                                                margin:
                                                                EdgeInsets.fromLTRB(
                                                                    10, 0, 10, 0),
                                                                child: Align(
                                                                  alignment:
                                                                  AlignmentDirectional
                                                                      .topStart,
                                                                  child: ExpandableText(
                                                                      workList[index][s
                                                                          .key_ts_date]
                                                                          .toString(),
                                                                      trimLines: 2),
                                                                ),
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),

                                                  ): SizedBox(),
                                                ),
                                              ),
                                            ]),
                                          )),
                                    )));
                          },
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
                )
              ],
            ),
          ),
        ));
  }

  Future<void> getWorkList(String finYear,String dcode, String bcode, String pvcode, String scheme) async {
    late Map json_request;

    Map work_detail = {
      s.key_fin_year: [finYear],
      s.key_dcode: dcode,
      s.key_bcode: bcode,
      s.key_pvcode: [pvcode],
      s.key_scheme_id: [scheme],
    };
    json_request = {
      s.key_service_id: s.service_key_get_inspection_work_details,
      s.key_inspection_work_details: work_detail,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: utils.encryption(
          jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service,
        body: json.encode(encrpted_request));
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    print("WorkList_url>>" + url.main_service.toString());
    print("WorkList_request_json>>" + json_request.toString());
    print("WorkList_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
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
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        res_jsonArray.sort((a, b) {
          return a[s.key_work_id].compareTo(b[s.key_work_id]);
        });
        if (res_jsonArray.length > 0) {
           ongoingWorkList = [];
           completedWorkList = [];
          for (int i = 0; i < res_jsonArray.length; i++) {
            if (res_jsonArray[i][s.key_current_stage_of_work] == 11) {
              completedWorkList.add(res_jsonArray[i]);
            } else {
              ongoingWorkList.add(res_jsonArray[i]);
            }
          }

           if (ongoingWorkList.length > 0) {
             workList = [];
             workList.addAll(ongoingWorkList);
             flag = 1;
             noDataFlag = false;
             workListFlag = true;
           } else if (completedWorkList.length > 0) {
             workList = [];
             workList.addAll(completedWorkList);
             flag = 2;
             noDataFlag = false;
             workListFlag = true;
           } else {
             workList = [];
             flag = 1;
             noDataFlag = true;
             workListFlag = false;
           }
           showFlag=[];
           for(int i=0;i<workList.length;i++){
             showFlag.add(false);
           }
        } else {
          utils.showAlert(context, s.no_data);
        }
      } else {
        utils.showAlert(context, s.no_data);
      }
      setState(() {
        isLoadingScheme= false;
      });
    }
  }
  Future<void> getWorkListByVillage(
      String dcode, String bcode, String pvcode) async {
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

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: utils.encryption(
          jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service,
        body: json.encode(encrpted_request));
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    print("WorkListByVillage_url>>" + url.main_service.toString());
    print("WorkListByVillage_request_json>>" + json_request.toString());
    print("WorkListByVillage_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("WorkListByVillage_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data =
      utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        res_jsonArray.sort((a, b) {
          return a[s.key_work_id].compareTo(b[s.key_work_id]);
        });
        if (res_jsonArray.length > 0) {
           ongoingWorkList = [];
           completedWorkList = [];
          for (int i = 0; i < res_jsonArray.length; i++) {
            if (res_jsonArray[i][s.key_current_stage_of_work] == 11) {
              completedWorkList.add(res_jsonArray[i]);
            } else {
              ongoingWorkList.add(res_jsonArray[i]);
            }
          }
          if (ongoingWorkList.length > 0) {
            workList = [];
            workList.addAll(ongoingWorkList);
            flag = 1;
            noDataFlag = false;
            workListFlag = true;
          } else if (completedWorkList.length > 0) {
            workList = [];
            workList.addAll(completedWorkList);
            flag = 2;
            noDataFlag = false;
            workListFlag = true;
          } else {
            workList = [];
            flag = 1;
            noDataFlag = true;
            workListFlag = false;
          }
          showFlag=[];
          for(int i=0;i<workList.length;i++){
            showFlag.add(false);
          }
        } else {
          utils.showAlert(context, s.no_data);
        }
      } else {
        utils.showAlert(context, s.no_data);
      }
    }
  }

}