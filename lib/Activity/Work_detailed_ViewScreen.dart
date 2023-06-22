import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import '../Layout/ReadMoreLess.dart';
import '../Resources/ColorsValue.dart';
import '../Utils/utils.dart';
class Work_detailed_ViewScreen extends StatefulWidget {
  @override


  final flag;
  final selectedRDPRworkList;
  final selectedOtherWorkList;
  final selectedATRWorkList;
  final imagelist;
  final town_type;

  Work_detailed_ViewScreen({this.selectedRDPRworkList, this.flag,this.imagelist,this.selectedOtherWorkList,this.selectedATRWorkList,this.town_type});
  State<Work_detailed_ViewScreen> createState() => Work_detailed_ViewScreenState();
}
class Work_detailed_ViewScreenState extends State<Work_detailed_ViewScreen> {
  var appBarvisibility = true;
  bool isWorklistAvailable = false;
  late SharedPreferences prefs;
  Utils utils = Utils();
  bool noDataFlag = false;
  bool imageListFlag = false;
  List workList = [];
  List ImageList = [];
  List<Map<String, String>> img_jsonArray = [];
  List<Map<String, String>> img_jsonArray_val = [];
  String town_type = "T";
  String inspection_id="";
  String work_id="";
  String atr_work_id="";
  String action_taken_id="";
  String other_work_inspection_id="";
  String type="";
  String area_type="";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if(widget.flag=="other")
      {

        getSavedOtherWorkDetails();
      }
      else if(widget.flag=="rdpr"){
        getWorkDetails();
      }
      else if(widget.flag=="atr")
      {
        getAtrWorkDetails();
      }
    });
    setState(() {

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
                    margin: EdgeInsets.fromLTRB(40, 10, 10, 0),
                    alignment: Alignment.center,
                    child: Visibility(
                        visible: appBarvisibility,
                        child: Text(
                         widget.flag=="other"?s.other_inspection_taken:s.inspection_taken,
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
              color: ca1,
              child: Column(
                children: [
                 _WorkList(),
                  _ATRWorkList(),
                  _OtherWorkList(),
                  Container(
                    child:Padding(
                      padding: EdgeInsets.only(top: 15,bottom: 10,left: 10,right: 10),
                        child: Text(
                          "Photos",style: TextStyle(
                            fontWeight: FontWeight.bold,fontSize: 15
                        ),
                        )
                    ),
                  ),
                  _Photos(),
                ],
              )),
        ),
      ),
    );
  }
  _WorkList() {
    return Container(
        color: ca1,
        child: Padding(
          padding: EdgeInsets.only(top: 20,left: 15,right: 15),
         child:Stack(
           children: [
             Visibility(
               visible:widget.flag=="rdpr"?true:false,
                 child:Container(
               child: ListView.builder(
                   physics: NeverScrollableScrollPhysics(),
                   shrinkWrap: true,
                    itemCount: 1,
                   itemBuilder: (BuildContext context,int index)
            {
              // inspection_id=widget.selectedRDPRworkList[index][s.key_inspection_id].toString();
            return InkWell(
            child:Card(
            elevation: 5,
            color: c.white,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomRight: Radius.circular(15),
            ),
            ),
            clipBehavior: Clip.hardEdge,
            child: ClipPath(
            clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20))),
            child: Container(
            child: Container(
            child: Column(children: [
            Container(
            child: Padding(
            padding: EdgeInsets.all(27),
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
            color: c.black),
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
            color: c.black),
            overflow:
            TextOverflow.clip,
            maxLines: 1,
            softWrap: true,
            ),
            ),
            Expanded(
            flex: 1,
            child: Text(
                work_id=widget.selectedRDPRworkList[index][s.key_work_id].toString(),
            style: TextStyle(
            color: c.black),
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
                      s.status,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.normal,
                          color: c.black),
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
                          color: c.black),
                      overflow:
                      TextOverflow.clip,
                      maxLines: 1,
                      softWrap: true,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(widget.selectedRDPRworkList[index][s.key_status_name],
                        style: TextStyle(
                            color: c.black),
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
                          FontWeight.bold,
                          color: c.black),
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
                          color: c.black),
                      overflow:
                      TextOverflow.clip,
                      maxLines: 1,
                      softWrap: true,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ExpandableText(widget.selectedRDPRworkList[index][s.key_work_name],
                        trimLines: 4,),
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
                      s.description,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.bold,
                          color: c.black),
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
                          color: c.black),
                      overflow:
                      TextOverflow.clip,
                      maxLines: 1,
                      softWrap: true,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(widget.selectedRDPRworkList[index][s.key_description],
                        style: TextStyle(
                          fontSize: 15,
                            color: c.black),
                        maxLines: 1),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
            )
            )
            )
            ]
            )
            ))
            )
            ));
            }
        )
    )
    )
    ])));
  }
  _ATRWorkList() {
    return
      Container(
        color: ca1,
        child: Padding(
            padding: EdgeInsets.only(top: 20,left: 15,right: 15),
            child:Stack(
                children: [
                  Visibility(
                      visible:widget.flag=="atr"?true:false,
                      child:Container(
                          child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: 1,
                              itemBuilder: (BuildContext context,int index)
                              {
                                return InkWell(
                                    child:Card(
                                        elevation: 5,
                                        color: c.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(15),
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                          ),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: ClipPath(
                                            clipper: ShapeBorderClipper(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(20))),
                                            child: Container(
                                                child: Container(
                                                    child: Column(children: [
                                                      Container(
                                                          child: Padding(
                                                              padding: EdgeInsets.all(27),
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
                                                                            color: c.black),
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
                                                                            color: c.black),
                                                                        overflow:
                                                                        TextOverflow.clip,
                                                                        maxLines: 1,
                                                                        softWrap: true,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Text(
                                                                          work_id=widget.selectedATRWorkList[index][s.key_workid].toString(),
                                                                          style: TextStyle(
                                                                              color: c.black),
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
                                                                            FontWeight.bold,
                                                                            color: c.black),
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
                                                                            color: c.black),
                                                                        overflow:
                                                                        TextOverflow.clip,
                                                                        maxLines: 1,
                                                                        softWrap: true,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Text(widget.selectedATRWorkList[index][s.key_work_name].toString(),
                                                                          style: TextStyle(
                                                                              color: c.black),
                                                                          maxLines: 4),
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
                                                                        s.description,
                                                                        style: TextStyle(
                                                                            fontSize: 15,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                            color: c.black),
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
                                                                            color: c.black),
                                                                        overflow:
                                                                        TextOverflow.clip,
                                                                        maxLines: 1,
                                                                        softWrap: true,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: Text(widget.selectedATRWorkList[index][s.key_description],
                                                                          style: TextStyle(
                                                                              fontSize: 15,
                                                                              color: c.black),
                                                                          maxLines: 1),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                              ],
                                                              )
                                                          )
                                                      )
                                                    ]
                                                    )
                                                ))
                                        )
                                    ));
                              }
                          )
                      )
                  )
                ])));
  }
  _OtherWorkList() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
        color: ca1,
        child: Padding(
            padding: EdgeInsets.only(top: 20,left: 15,right: 15),
            child:Stack(
                children: [
                  Visibility(
                      visible:widget.flag=="other"?true:false,
                      child:Container(
                      child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 1,
                          itemBuilder: (BuildContext context,int index)
                          {
                            return InkWell(
                                child:Card(
                                    elevation: 5,
                                    color: c.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                        bottomRight: Radius.circular(15),
                                      ),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: ClipPath(
                                        clipper: ShapeBorderClipper(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(20))),
                                        child: Container(
                                            child: Container(
                                                child: Column(children: [
                                                  Container(
                                                      child: Padding(
                                                          padding: EdgeInsets.all(27),
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
                                                                    s.other_work_id,
                                                                    style: TextStyle(
                                                                        fontSize: 15,
                                                                        fontWeight:
                                                                        FontWeight.normal,
                                                                        color: c.black),
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
                                                                        color: c.black),
                                                                    overflow:
                                                                    TextOverflow.clip,
                                                                    maxLines: 1,
                                                                    softWrap: true,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: Text(
                                                                      other_work_inspection_id=widget.selectedOtherWorkList[index][s.key_other_work_inspection_id].toString(),
                                                                      style: TextStyle(
                                                                          color: c.black),
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
                                                                    s.financial_year,
                                                                    style: TextStyle(
                                                                        fontSize: 15,
                                                                        fontWeight:
                                                                        FontWeight.normal,
                                                                        color: c.black),
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
                                                                        color: c.black),
                                                                    overflow:
                                                                    TextOverflow.clip,
                                                                    maxLines: 1,
                                                                    softWrap: true,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: Text(widget.selectedOtherWorkList[index][s.key_fin_year].toString(),
                                                                      style: TextStyle(
                                                                          color: c.black),
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
                                                                    s.status,
                                                                    style: TextStyle(
                                                                        fontSize: 15,
                                                                        fontWeight:
                                                                        FontWeight.normal,
                                                                        color: c.black),
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
                                                                        color: c.black),
                                                                    overflow:
                                                                    TextOverflow.clip,
                                                                    maxLines: 1,
                                                                    softWrap: true,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: Text(widget.selectedOtherWorkList[index][s.key_status_name].toString(),
                                                                      style: TextStyle(
                                                                          color: c.black),
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
                                                                    s.other_inspection,
                                                                    style: TextStyle(
                                                                        fontSize: 15,
                                                                        fontWeight:
                                                                        FontWeight.normal,
                                                                        color: c.black),
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
                                                                        color: c.black),
                                                                    overflow:
                                                                    TextOverflow.clip,
                                                                    maxLines: 1,
                                                                    softWrap: true,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: Text(widget.selectedOtherWorkList[index][s.key_other_work_category_name],
                                                                      style: TextStyle(
                                                                          color: c.black),
                                                                      maxLines: 4),
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
                                                                    s.other_work_details,
                                                                    style: TextStyle(
                                                                        fontSize: 15,
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                        color: c.black),
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
                                                                        color: c.black),
                                                                    overflow:
                                                                    TextOverflow.clip,
                                                                    maxLines: 1,
                                                                    softWrap: true,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: Text(widget.selectedOtherWorkList[index][s.key_other_work_name],
                                                                      style: TextStyle(
                                                                          color: c.black),
                                                                      maxLines: 4),
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
                                                                    s.description,
                                                                    style: TextStyle(
                                                                        fontSize: 15,
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                        color: c.black),
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
                                                                        color: c.black),
                                                                    overflow:
                                                                    TextOverflow.clip,
                                                                    maxLines: 1,
                                                                    softWrap: true,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: Text(widget.selectedOtherWorkList[index][s.key_description],
                                                                      style: TextStyle(
                                                                          fontSize: 15,
                                                                          color: c.black),
                                                                      maxLines: 1),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],
                                                          )
                                                      )
                                                  )
                                                ]
                                                )
                                            ))
                                    )
                                ));
                          }
                      )
                  )
                  )
                ])));
  }
  _Photos() {
    return Visibility(
        visible: imageListFlag ,
          child: Container(
          color: ca1,
          child: Padding(
              padding: EdgeInsets.only(top: 10,left: 20,right: 15),
              child:Stack(
                  children: [
                    ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: ImageList.length,
                        itemBuilder: (BuildContext context,int index)
                        {
                          return Card(
                              elevation: 5,
                              color: c.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              clipBehavior: Clip.hardEdge,
                              margin: EdgeInsets.fromLTRB(5, 5, 5, 20),
                              child: ClipPath(
                                  clipper: ShapeBorderClipper(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10))),
                                  child: Column(
                                      children: [
                                        Container(
                                          height:200,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image:MemoryImage(
                                                  base64.decode(ImageList[index][s.key_image]),
                                                ),
                                              )
                                          ),
                                        ),
                                        Container(
                                          child: Align(
                                            alignment: Alignment.bottomLeft,
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                                              child: Text(
                                                s.description +" : "+  ImageList[index][s.key_image_description].toString(),style: TextStyle(
                                                  fontSize: 14,fontWeight: FontWeight.normal,color: c.black
                                              ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ]
                                  )
                              )
                          );
                        }
                    )
                  ]))
      ));
  }
  Future<void> getWorkDetails() async {
    ImageList.clear();
    List<dynamic> res_jsonArray = widget.selectedRDPRworkList;
    if (res_jsonArray.length > 0) {
      for (int i = 0; i < res_jsonArray.length; i++) {
        List res_image = res_jsonArray[i][s.key_inspection_image];
        res_image.sort((a, b) {
          return a[s.key_serial_no].compareTo(b[s.key_serial_no]);
        });
        print("Res image>>>"+res_image.toString());
        ImageList.addAll(res_image);
        print("image_List>>>>>>"+ImageList.toString());
      }
    }
    setState(() {
      _Photos();
    });
    if (ImageList.length > 0) {
      noDataFlag = false;
      imageListFlag = true;
    } else {
      noDataFlag = true;
      imageListFlag = false;
    }
  }
  Future<void> getSavedOtherWorkDetails() async {
    ImageList.clear();
    List<dynamic> res_jsonArray = widget.selectedOtherWorkList;
    if (res_jsonArray.length > 0) {
      for (int i = 0; i < res_jsonArray.length; i++) {
        List res_image = res_jsonArray[i][s.key_inspection_image];
        res_image.sort((a, b) {
          return a[s.key_serial_no].compareTo(b[s.key_serial_no]);
        });
        print("Res image>>>"+res_image.toString());
        ImageList.addAll(res_image);
        print("image_List>>>>>>"+ImageList.toString());
      }
    }
    setState(() {
      _Photos();
    });
    if (ImageList.length > 0) {
      noDataFlag = false;
      imageListFlag = true;
    } else {
      noDataFlag = true;
      imageListFlag = false;
    }
  }
  Future<void> getAtrWorkDetails() async {
    ImageList.clear();
      List<dynamic> res_jsonArray = widget.selectedATRWorkList;
      if (res_jsonArray.length > 0) {
        for (int i = 0; i < res_jsonArray.length; i++) {
          List res_image = res_jsonArray[i][s.key_inspection_image];
          res_image.sort((a, b) {
            return a[s.key_serial_no].compareTo(b[s.key_serial_no]);
          });
          print("Res image>>>"+res_image.toString());
          ImageList.addAll(res_image);
          print("image_List>>>>>>"+ImageList.toString());
        }
      }
      setState(() {
        _Photos();
      });
    if (ImageList.length > 0) {
      noDataFlag = false;
      imageListFlag = true;
    } else {
      noDataFlag = true;
      imageListFlag = false;
    }
  }
}