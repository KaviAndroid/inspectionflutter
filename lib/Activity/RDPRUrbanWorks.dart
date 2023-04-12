import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/SaveWorkDetails.dart';
import 'package:inspection_flutter_app/Activity/WorkList.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../DataBase/DbHelper.dart';
import '../Layout/ReadMoreLess.dart';
import '../Utils/utils.dart';

class RDPRUrbanWorks extends StatefulWidget {
  const RDPRUrbanWorks({Key? key}) : super(key: key);

  @override
  State<RDPRUrbanWorks> createState() => _RDPRUrbanWorksState();
}

class _RDPRUrbanWorksState extends State<RDPRUrbanWorks> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  List finYearItems=[];
  List districtItems = [];
  List schemeItems = [];
  List tmcItems = [];
  String selectedLevel="";
  String selectedDistrict="";
  String selectedTMC="";
  bool submitFlag = false;

  bool districtError = false;
  bool tmcError = false;
  bool districtFlag = false;
  bool isLoadingD = false;
  bool isLoadingTMC = false;
  Map<String, String> defaultSelectedDistrict = {
    s.key_dcode: "0",
    s.key_dname: s.selectDistrict
  };
  Map<String, String> defaultSelectedT = {
    s.key_townpanchayat_id: "0",
    s.key_townpanchayat_name: s.select_town
  };
  Map<String, String> defaultSelectedM = {
    s.key_municipality_id: "0",
    s.key_municipality_name: s.select_municipality
  };
  Map<String, String> defaultSelectedC = {
    s.key_corporation_id: "0",
    s.key_corporation_name: s.select_corporation
  };
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM '+s.table_FinancialYear);
    print(list.toString());
    finYearItems.addAll(list);
    selectedLevel=prefs.getString(s.key_level)!;
    print(finYearItems.toString());
    if(selectedLevel=='S'){
      districtFlag=true;
      List<Map> list = await dbClient.rawQuery('SELECT * FROM '+s.table_District);
      print(list.toString());
      districtItems.add(defaultSelectedDistrict);
      districtItems.addAll(list);
      selectedDistrict = defaultSelectedDistrict[s.key_dcode]!;
    }else {
      districtFlag=true;
    }

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
      child:Scaffold(
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
                  child:Container(
                    transform: Matrix4.translationValues(-30.0, 0.0, 0.0),
                    alignment: Alignment.center,
                    child: Text(
                      s.filter_work_list,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body:Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          color: c.white,
          height: MediaQuery.of(context).size.height,
          child:SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: districtFlag
                            ? true
                            : false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets.only(top: 15, bottom: 15),
                              child: Text(
                                s.selectDistrict,
                                style: GoogleFonts.raleway().copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: c.grey_8),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: c.grey_out,
                                  border: Border.all(
                                      width: districtError ? 1 : 0.1,
                                      color: districtError ? c.red : c.grey_10),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: IgnorePointer(
                                ignoring: isLoadingD ? true : false,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    style:
                                    const TextStyle(color: Colors.black),
                                    value: selectedDistrict,
                                    isExpanded: true,
                                    items: districtItems
                                        .map((item) =>
                                        DropdownMenuItem<String>(
                                          value: item[s.key_dcode]
                                              .toString(),
                                          child: Text(
                                            item[s.key_dname].toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ))
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != "0") {
                                        submitFlag=false;
                                        isLoadingD= true;
                                        loadTMCBlock(value.toString());
                                        setState(() {});
                                      } else {
                                        setState(() {
                                          submitFlag=false;
                                          selectedDistrict = value.toString();
                                          districtError = true;
                                        });
                                      }
                                    },
                                    buttonStyleData: const ButtonStyleData(
                                      height: 45,
                                      padding: EdgeInsets.only(right: 10),
                                    ),
                                    iconStyleData: IconStyleData(
                                      icon: isLoadingD
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
                              visible: districtError ? true : false,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  s.please_enter_district,
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
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                              const EdgeInsets.only(top: 15, bottom: 15),
                              child: Text(
                                s.select_tmc,
                                style: GoogleFonts.raleway().copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: c.grey_8),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: c.grey_out,
                                  border: Border.all(
                                      width: tmcError ? 1 : 0.1,
                                      color: tmcError ? c.red : c.grey_10),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: IgnorePointer(
                                ignoring: isLoadingTMC ? true : false,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    style:
                                    const TextStyle(color: Colors.black),
                                    value: selectedTMC,
                                    isExpanded: true,
                                    items: tmcItems
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
                                        isLoadingTMC= true;
                                        selectedTMC = value.toString();
                                        setState(() {});
                                      } else {
                                        setState(() {
                                          submitFlag=false;
                                          selectedTMC = value.toString();
                                          tmcError = true;
                                        });
                                      }
                                    },
                                    buttonStyleData: const ButtonStyleData(
                                      height: 45,
                                      padding: EdgeInsets.only(right: 10),
                                    ),
                                    iconStyleData: IconStyleData(
                                      icon: isLoadingTMC
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
                              visible: tmcError ? true : false,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  s.select_tmc,
                                  // state.hasError ? state.errorText : '',
                                  style: TextStyle(
                                      color: Colors.redAccent.shade700,
                                      fontSize: 12.0),
                                ),
                              ),
                            ),
                          ],
                        ),

                      Visibility(
                        visible: submitFlag,
                        child: Container(
                          margin: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Center(
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                  MaterialStateProperty.all<Color>(
                                      c.colorPrimary),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ))),
                              onPressed: () {

                              },
                              child: Text(s.submit,
                                style: GoogleFonts.raleway().copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: c.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

      ),);
  }

  void loadTMCBlock(String string) {

  }
}
