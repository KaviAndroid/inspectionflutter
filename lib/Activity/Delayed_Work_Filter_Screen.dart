// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print, non_constant_identifier_names, prefer_interpolation_to_compose_strings, prefer_typing_uninitialized_variables, avoid_function_literals_in_foreach_calls

import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:InspectionAppNew/Activity/Home.dart';
import 'package:InspectionAppNew/Activity/WorkList.dart';
import 'package:InspectionAppNew/Layout/Single_CheckBox.dart';
import 'package:InspectionAppNew/Resources/Strings.dart' as s;
import 'package:InspectionAppNew/Resources/ColorsValue.dart' as c;
import 'package:InspectionAppNew/Resources/ImagePath.dart' as imagePath;
import 'package:InspectionAppNew/Resources/url.dart' as url;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

import '../DataBase/DbHelper.dart';
import '../Layout/Multiple_CheckBox.dart';
import '../Layout/ReadMoreLess.dart';
import '../ModelClass/checkBoxModelClass.dart';
import '../Resources/Strings.dart';
import '../Resources/Strings.dart';
import '../Utils/utils.dart';
import 'Pdf_Viewer.dart';

class DelayedWorkFilterScreen extends StatefulWidget {
  const DelayedWorkFilterScreen({Key? key}) : super(key: key);

  @override
  State<DelayedWorkFilterScreen> createState() => _DelayedWorkFilterScreenState();
}

class _DelayedWorkFilterScreenState extends State<DelayedWorkFilterScreen> {
  //Bool Error
  bool finYearError = false;
  bool districtError = false;
  bool blockError = false;
  bool schemeError = false;

  //bool Loading
  bool isLoadingDistrict = false;

  //Bool visibility
  bool bFlag = false;
  bool dFlag = false;
  bool sFlag = false;
  bool delay = false;
  //Bool
  bool submitFlag = false;
  bool schemeFlag = false;

  //String
  String selectedFinYear = "";
  String selectedLevel = "";
  String selectedDistrict = "";
  String selectedBlock = "";
  String selectedMonth = "";
  String tableHeaderName = "";
  String tempTableHeaderName = "";

  //List
  List finYearItems = [];
  List districtItems = [];
  List blockItems = [];
  List monthItems = [];
  List finList = [];

  List villagelist = [];
  List schList = [];
  List schIdList = [];
  List schArray = [];
  List pvListHeader = [];
  List<FlutterLimitedCheckBoxModel> finyearList = [];
  List<FlutterLimitedCheckBoxModel> SchemeListvalue = [];

  //Default Values
  Map<String, String> defaultSelectedFinYear = {
    s.key_fin_year: s.select_financial_year,
  };
  Map<String, String> defaultSelectedBlock = {s.key_bcode: "0", s.key_bname: s.selectBlock};
  Map<String, String> defaultSelectedDistrict = {s.key_dcode: "0", s.key_dname: s.selectDistrict};
  Map<String, String> defaultSelectedMonth = {'monthId': "0", 'month': '0'};

  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;

  TextEditingController asController = TextEditingController();

  String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    finyearList.clear();
    List<Map> list = await dbClient.rawQuery('SELECT * FROM ' + s.table_FinancialYear);
    for (int i = 0; i < list.length; i++) {
      finyearList.add(FlutterLimitedCheckBoxModel(isSelected: false, selectTitle: list[i][s.key_fin_year], selectId: i));
      print(list.toString());
    }
    selectedLevel = prefs.getString(s.key_level)!;
    print("#############" + finYearItems.toString());
    if (selectedLevel == 'S') {
      sFlag = true;
      List<Map> list = await dbClient.rawQuery('SELECT * FROM ${s.table_District}');
      print(list.toString());
      districtItems.add(defaultSelectedDistrict);
      districtItems.addAll(list);
      selectedDistrict = defaultSelectedDistrict[s.key_dcode]!;
      selectedBlock = defaultSelectedBlock[s.key_bcode]!;
      selectedFinYear = defaultSelectedFinYear[s.key_fin_year]!;
    } else if (selectedLevel == 'D') {
      dFlag = true;
      List<Map> list = await dbClient.rawQuery('SELECT * FROM ${s.table_Block}');
      print(list.toString());
      blockItems.add(defaultSelectedBlock);
      blockItems.addAll(list);
      selectedDistrict = prefs.getString(s.key_dcode)!;
      selectedBlock = defaultSelectedBlock[s.key_bcode]!;
    } else if (selectedLevel == 'B') {
      bFlag = true;
      delay = true;
      selectedDistrict = prefs.getString(s.key_dcode)!;
      selectedBlock = prefs.getString(s.key_bcode)!;
    }

    monthItems.add(defaultSelectedMonth);
    for (int i = 1; i < 5; i++) {
      Map<String, String> mymap = {}; // This created one object in the current scope.
      // First iteration , i = 0
      mymap['monthId'] = (i * 3).toString(); // Now mymap = { name: 'test0' };
      mymap['month'] = (i * 3).toString(); // Now mymap = { name: 'test0' };
      monthItems.add(mymap);
    }
    print("selectedBlock>>$selectedBlock");
    print("months>>$monthItems");
    selectedMonth = defaultSelectedMonth['monthId']!;

    setState(() {});
  }

  void loadUIBlock(String value) async {
    if (await utils.isOnline()) {
      selectedDistrict = value.toString();
      await getBlockList(value);
      setState(() {});
    } else {
      utils.customAlertWidet(context, "Error", s.no_internet);
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
          backgroundColor: c.white,
          appBar: AppBar(
            backgroundColor: c.colorPrimary,
            centerTitle: true,
            elevation: 2,
            title: Center(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      s.plan_to_inspect,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    padding: EdgeInsets.all(5),
                    child: InkWell(
                        child: Image.asset(
                          imagePath.home,
                          color: c.white,
                          height: 25,
                          width: 25,
                        ),
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Home(
                                        isLogin: "",
                                      )));
                        }),
                  )
                ],
              ),
            ),
          ),
          body: Container(
            // padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            color: c.white,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: villagelist.isEmpty ? true : false,
                        child: Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15),
                                child: Text(
                                  s.select_financial_year,
                                  style: GoogleFonts.getFont('Roboto', fontWeight: FontWeight.w800, fontSize: 12, color: c.grey_8),
                                ),
                              ),
                              Container(
                                  height: 30,
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                      color: c.grey_out, border: Border.all(width: finYearError ? 1 : 0.1, color: finYearError ? c.red : c.grey_10), borderRadius: BorderRadius.circular(10.0)),
                                  child: InkWell(
                                      onTap: () {
                                        multiChoiceFinYearSelection(finyearList, s.select_financial_year);
                                      },
                                      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            finList.isNotEmpty ? finList.join(', ') : s.select_financial_year,
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: c.grey_10),
                                            overflow: TextOverflow.clip,
                                            maxLines: 1,
                                            softWrap: true,
                                          ),
                                        ),
                                      ]))
                                  /*child: IgnorePointer(
                        ignoring: isLoadingFinYear ? true : false,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            style: const TextStyle(color: Colors.black),
                            value: selectedFinYear,
                            isExpanded: true,
                            items: finYearItems
                                .map((item) => DropdownMenuItem<String>(
                                      value: item[s.key_fin_year].toString(),
                                      child: Text(
                                        item[s.key_fin_year].toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != s.select_financial_year) {
                                isLoadingFinYear = false;
                                finYearError = false;
                                selectedFinYear = value.toString();
                                print(">>>>>#################"+selectedFinYear.toString());
                                setState(() {});
                              } else {
                                setState(() {
                                  selectedFinYear = value.toString();
                                  finYearError = true;
                                });
                              }
                            },
                            buttonStyleData: const ButtonStyleData(
                              height: 30,
                              padding: EdgeInsets.only(right: 10),
                            ),
                            iconStyleData: IconStyleData(
                              icon: isLoadingFinYear
                                  ? SpinKitCircle(
                                      color: c.colorPrimary,
                                      size: 30,
                                      duration: const Duration(milliseconds: 1200),
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
                      ),*/
                                  ),
                              const SizedBox(height: 8.0),
                              Visibility(
                                visible: sFlag ? true : false,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: Text(
                                        s.selectDistrict,
                                        style: GoogleFonts.getFont('Roboto', fontWeight: FontWeight.w800, fontSize: 12, color: c.grey_8),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: c.grey_out, border: Border.all(width: districtError ? 1 : 0.1, color: districtError ? c.red : c.grey_10), borderRadius: BorderRadius.circular(10.0)),
                                      child: IgnorePointer(
                                        ignoring: isLoadingDistrict ? true : false,
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton2(
                                            style: const TextStyle(color: Colors.black),
                                            value: selectedDistrict,
                                            isExpanded: true,
                                            items: districtItems
                                                .map((item) => DropdownMenuItem<String>(
                                                      value: item[s.key_dcode].toString(),
                                                      child: Text(
                                                        item[s.key_dname].toString(),
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                            onChanged: (value) {
                                              villagelist = [];
                                              schIdList = [];
                                              schList = [];
                                              SchemeListvalue.clear();
                                              blockItems = [];
                                              selectedBlock = defaultSelectedBlock[s.key_bcode]!;
                                              blockError = true;
                                              schemeError = true;
                                              selectedMonth = "0";
                                              asController.text = "0";

                                              if (value != "0") {
                                                isLoadingDistrict = true;
                                                loadUIBlock(value.toString());
                                              } else {
                                                setState(() {
                                                  selectedDistrict = value.toString();
                                                  districtError = true;
                                                });
                                              }
                                              setState(() {});
                                            },
                                            buttonStyleData: const ButtonStyleData(
                                              height: 30,
                                              padding: EdgeInsets.only(right: 10),
                                            ),
                                            iconStyleData: IconStyleData(
                                              icon: isLoadingDistrict
                                                  ? SpinKitCircle(
                                                      color: c.colorPrimary,
                                                      size: 30,
                                                      duration: const Duration(milliseconds: 1200),
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
                                      visible: districtError ? true : false,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          s.please_enter_district,
                                          style: TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: dFlag ? true : false,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: Text(
                                        s.selectBlock,
                                        style: GoogleFonts.getFont('Roboto', fontWeight: FontWeight.w800, fontSize: 12, color: c.grey_8),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: c.grey_out, border: Border.all(width: blockError ? 1 : 0.1, color: blockError ? c.red : c.grey_10), borderRadius: BorderRadius.circular(10.0)),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton2(
                                          value: selectedBlock,
                                          style: const TextStyle(color: Colors.black),
                                          isExpanded: true,
                                          items: blockItems
                                              .map((item) => DropdownMenuItem<String>(
                                                    value: item[s.key_bcode].toString(),
                                                    child: Text(
                                                      item[s.key_bname].toString(),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (value) async {
                                            villagelist = [];
                                            selectedMonth = "0";
                                            asController.text = "0";
                                            if (finList.isNotEmpty) {
                                              schIdList = [];
                                              schList = [];
                                              SchemeListvalue.clear();
                                              schemeError = true;
                                              selectedBlock = value.toString();
                                              if (value != "0") {
                                                print(value);
                                                blockError = false;
                                                delay = true;
                                                await getSchemeList();
                                              } else {
                                                blockError = true;
                                              }
                                            } else {
                                              utils.showAlert(context, s.select_financial_year);
                                            }
                                            setState(() {});

                                            //Do something when changing the item if you want.
                                          },
                                          buttonStyleData: const ButtonStyleData(
                                            height: 30,
                                            padding: EdgeInsets.only(right: 10),
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(
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
                                    const SizedBox(height: 8.0),
                                    Visibility(
                                      visible: blockError ? true : false,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          s.please_enter_block,
                                          // state.hasError ? state.errorText : '',
                                          style: TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                  visible: schemeFlag ? true : false,
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5, bottom: 10),
                                      child: Text(
                                        s.select_scheme,
                                        style: GoogleFonts.getFont('Roboto', fontWeight: FontWeight.w800, fontSize: 12, color: c.grey_8),
                                      ),
                                    ),
                                    Container(
                                     /* height: 150,
                                      width: 350,*/
                                      constraints: BoxConstraints(
                                        minHeight: 40, //minimum height
                                        minWidth: MediaQuery.of(context).size.width, // minimum width

                                        maxHeight: 150,
                                        //maximum height set to 100% of vertical height

                                        maxWidth: MediaQuery.of(context).size.width,
                                        //maximum width set to 100% of width
                                      ),
                                      padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          color: c.grey_out, border: Border.all(width: schemeError ? 1 : 0.1, color: schemeError ? c.red : c.grey_10), borderRadius: BorderRadius.circular(10.0)),
                                      child: InkWell(
                                          onTap: () {
                                            SchemeListvalue.isNotEmpty ? multiChoiceSchemeSelection(SchemeListvalue) : null;
                                            print("Schemelist#######" + SchemeListvalue.toString());
                                            setState(() {});
                                          },
                                          child: schList.isNotEmpty
                                              ? ListView.builder(
                                                  itemCount: schList.length,
                                                  itemBuilder: (context, index) {
                                                    var s_no = index + 1;
                                                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            s_no.toString() + " : ",
                                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: c.grey_10),
                                                            overflow: TextOverflow.clip,
                                                            softWrap: true,
                                                          ),
                                                          Expanded(
                                                              child: Text(
                                                            schList[index],
                                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: c.grey_10),
                                                            overflow: TextOverflow.clip,
                                                            softWrap: true,
                                                          )),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      )
                                                    ]);
                                                  })
                                              : Text(
                                                  s.select_scheme,
                                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: c.grey_10),
                                                  overflow: TextOverflow.clip,
                                                  softWrap: true,
                                                )

                                          // Text(
                                          //   schList.isNotEmpty
                                          //       ? schList.join(',\n\n ')
                                          //       : s.select_scheme,
                                          //   style: TextStyle(
                                          //       fontSize: 13,
                                          //       fontWeight:
                                          //           FontWeight.normal,
                                          //       color: c.grey_10),
                                          //   overflow: TextOverflow.clip,
                                          //   softWrap: true,
                                          // )

                                          ),
                                    ),
                                  ])),
                              Visibility(
                                visible: delay,
                                child: Container(
                                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          decoration: BoxDecoration(color: c.grey_out, border: Border.all(width: 0.1, color: c.grey_10), borderRadius: BorderRadius.circular(10.0)),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 0),
                                                child: Text(
                                                  'Months Delayed >  ',
                                                  style: GoogleFonts.getFont('Roboto', fontWeight: FontWeight.w800, fontSize: 12, color: c.grey_8),
                                                ),
                                              ),
                                              Expanded(
                                                child: SizedBox(
                                                  height: 30,
                                                  child: DropdownButtonHideUnderline(
                                                    child: DropdownButton2(
                                                      alignment: Alignment.center,
                                                      buttonStyleData: const ButtonStyleData(
                                                        padding: EdgeInsets.symmetric(horizontal: 0),
                                                        height: 30,
                                                        width: 50,
                                                      ),
                                                      menuItemStyleData: const MenuItemStyleData(
                                                        height: 40,
                                                      ),
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
                                                        villagelist = [];
                                                        if (value != "0") {
                                                          selectedMonth = value.toString();
                                                          submitFlag = true;
                                                        } else {
                                                          selectedMonth = value.toString();
                                                          asController.text != "0" && int.parse(asController.text) > 0 ? submitFlag = true : submitFlag = false;
                                                        }
                                                        setState(() {});
                                                      },
                                                      dropdownStyleData: DropdownStyleData(
                                                        width: 50,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(15),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(color: c.grey_out, border: Border.all(width: 0.1, color: c.grey_10), borderRadius: BorderRadius.circular(10.0)),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 0, bottom: 0, left: 5, right: 0),
                                                child: Text(
                                                  'AS Value >=',
                                                  style: GoogleFonts.getFont('Roboto', fontWeight: FontWeight.w800, fontSize: 12, color: c.grey_8),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                                  alignment: AlignmentDirectional.center,
                                                  height: 30,
                                                  child: TextFormField(
                                                    onChanged: (v) async => validateAs(v),
                                                    style: TextStyle(fontSize: 13),
                                                    maxLines: 1,
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                    controller: asController,
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    decoration: InputDecoration(
                                                      hintText: '0',
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                  onTap: () {
                                                    utils.hideSoftKeyBoard(context);
                                                    if (asController.text.isNotEmpty && int.parse(asController.text) > 0) {
                                                      submitFlag = true;
                                                    } else {
                                                      utils.customAlertWidet(context, "Error", "Please Enter AS value");
                                                    }
                                                  },
                                                  child: Visibility(
                                                    visible: false,
                                                    child: Container(
                                                      width: 25,
                                                      height: 30,
                                                      alignment: Alignment.centerRight,
                                                      decoration: BoxDecoration(
                                                          color: c.colorPrimary,
                                                          border: Border.all(width: 0, color: c.grey_10),
                                                          borderRadius: const BorderRadius.only(
                                                            topLeft: Radius.circular(0),
                                                            topRight: Radius.circular(10),
                                                            bottomLeft: Radius.circular(0),
                                                            bottomRight: Radius.circular(10),
                                                          )),
                                                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                                    ),
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: submitFlag,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: Center(
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(c.colorPrimary),
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ))),
                                      onPressed: () async {
                                        if (finList.isNotEmpty) {
                                          if (selectedDistrict.isNotEmpty && selectedDistrict != "0") {
                                            if (selectedBlock.isNotEmpty && selectedBlock != "0") {
                                              if (schIdList.isNotEmpty) {
                                                asController.text.isEmpty ? asController.text = "0" : null;
                                                if (int.parse(asController.text) > 0 || selectedMonth != "0") {
                                                  await fetchDelayedWorkList();
                                                  // await getdelayedWorkListAll();
                                                } else {
                                                  utils.customAlertWidet(context, "Error", "Please Select AS value or Months");
                                                }
                                              } else {
                                                utils.showAlert(context, s.select_scheme);
                                              }
                                            } else {
                                              utils.showAlert(context, s.selectBlock);
                                            }
                                          } else {
                                            utils.showAlert(context, s.selectDistrict);
                                          }
                                        } else {
                                          utils.showAlert(context, s.select_financial_year);
                                        }

                                        // pvTable = true;
                                        setState(() {});
                                      },
                                      child: Text(
                                        s.submit,
                                        style: GoogleFonts.getFont('Roboto', fontWeight: FontWeight.w800, fontSize: 15, color: c.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ])),
                      ),
                      Visibility(
                          visible: villagelist.isNotEmpty ? true : false,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                villagelist.clear();
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              child: Container(
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.primary_text_color2))),
                                child: Text(
                                  s.click_to_filter,
                                  style: GoogleFonts.getFont('Roboto', fontWeight: FontWeight.w800, fontSize: 16, color: c.primary_text_color2),
                                ),
                              ),
                            ),
                          )),
                      Visibility(
                          child: Container(
                              margin: EdgeInsets.only(right: 20, left: 20),
                              child: Stack(children: [
                                Visibility(
                                    visible: villagelist.isNotEmpty ? true : false,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 5, bottom: 5),
                                          child: Text(
                                            s.village_list,
                                            style: GoogleFonts.getFont('Roboto', fontWeight: FontWeight.bold, fontSize: 16, color: c.grey_9),
                                          ),
                                        ),
                                        ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: villagelist.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              return InkWell(
                                                  onTap: () async {
                                                    setState(() {
                                                      villagelist[index][key_flag] == "0" ? villagelist[index][key_flag] = "1" : villagelist[index][key_flag] = "0";
                                                    });
                                                  },
                                                  child: Card(
                                                      elevation: 5,
                                                      margin: EdgeInsets.only(top: 10, bottom: 10),
                                                      color: c.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.only(
                                                          bottomLeft: Radius.circular(20),
                                                          topLeft: Radius.circular(20),
                                                          topRight: Radius.circular(20),
                                                          bottomRight: Radius.circular(20),
                                                        ),
                                                      ),
                                                      child: ClipPath(
                                                          clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.topRight, colors: [c.colorAccent, c.colorAccent]),
                                                                    borderRadius: const BorderRadius.only(
                                                                      topLeft: Radius.circular(20),
                                                                      topRight: Radius.circular(20),
                                                                      bottomLeft: Radius.circular(20),
                                                                      bottomRight: Radius.circular(20),
                                                                    )),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Container(
                                                                        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20),
                                                                        child: Text(
                                                                          villagelist[index][key_pvname],
                                                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: c.white),
                                                                          textAlign: TextAlign.start,
                                                                          overflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: Container(
                                                                        alignment: Alignment.centerRight,
                                                                        padding: EdgeInsets.only(top: 10, bottom: 10, right: 20),
/*                                                                decoration:
                                                                    BoxDecoration(
                                                                        color: c
                                                                            .dot_light_screen_lite1,
                                                                        borderRadius:
                                                                            const BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(0),
                                                                          topRight:
                                                                              Radius.circular(20),
                                                                          bottomLeft:
                                                                              Radius.circular(0),
                                                                          bottomRight:
                                                                              Radius.circular(20),
                                                                        )),*/
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                          children: [
                                                                            Text(villagelist[index][key_total_count].toString(),
                                                                                style: TextStyle(color: c.white, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.right, maxLines: 1),
                                                                            InkWell(
                                                                              onTap: () async {
                                                                                setState(() {
                                                                                  villagelist[index][key_flag] == "0" ? villagelist[index][key_flag] = "1" : villagelist[index][key_flag] = "0";
                                                                                });
                                                                              },
                                                                              child: Container(
                                                                                margin: EdgeInsets.fromLTRB(5, 5, 0, 0),
                                                                                child: Align(
                                                                                  child: Image.asset(
                                                                                    imagePath.arrow_down_icon,
                                                                                    color: c.white,
                                                                                    height: 25,
                                                                                  ),
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
                                                Visibility(
                                                  visible: villagelist[index][key_flag] == "1",
                                                  child: AnimationLimiter(
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Align(
                                                              alignment: Alignment.topLeft,
                                                              child: InkWell(
                                                                onTap: () => Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => WorkList(
                                                                          finYear: finList,
                                                                          dcode: selectedDistrict,
                                                                          bcode: selectedBlock,
                                                                          pvcode: villagelist[index][s.key_pvcode].toString(),
                                                                          tmccode: selectedMonth,
                                                                          flag: "delayed_works",
                                                                          asvalue: asController.text,
                                                                          selectedschemeList: "",
                                                                          townType: '',
                                                                          scheme: '',
                                                                          schemeList: schIdList,
                                                                        ))),
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                      gradient: LinearGradient(
                                                                          begin: Alignment.topLeft, end: Alignment.topRight, colors: [c.primary_text_color2, c.primary_text_color2]),
                                                                      borderRadius: const BorderRadius.only(
                                                                        topLeft: Radius.circular(10),
                                                                        topRight: Radius.circular(10),
                                                                        bottomLeft: Radius.circular(10),
                                                                        bottomRight: Radius.circular(10),
                                                                      )),
                                                                  margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
                                                                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                                  child: Align(
                                                                    alignment: AlignmentDirectional.center,
                                                                    child: Text(
                                                                      s.view_details,
                                                                      style: TextStyle(color: c.white, fontSize: 13, fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment: Alignment.center,
                                                              child: InkWell(
                                                                onTap: () async {
                                                                  await selectAllSublist(index);
                                                                  setState(() {});
                                                                },
                                                                child: Container(
/*                                                                        decoration:
                                                                           BoxDecoration(
                                                                           gradient: LinearGradient(
                                                                           begin:
                                                                           Alignment.topLeft,
                                                                           end: Alignment.topRight,
                                                                           colors: [
                                                                           c.primary_text_color2,
                                                                           c.primary_text_color2
                                                                           ]),
                                                                           borderRadius:
                                                                           const BorderRadius
                                                                           .only(
                                                                           topLeft:
                                                                           Radius.circular(10),
                                                                           topRight:
                                                                           Radius.circular(10),
                                                                           bottomLeft:
                                                                           Radius.circular(10),
                                                                           bottomRight:
                                                                           Radius.circular(10),
                                                                           )),*/
                                                                  margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
                                                                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                                  child: Align(
                                                                    alignment: Alignment.centerRight,
                                                                    child: Text(
                                                                      s.select_all,
                                                                      style: TextStyle(color: c.primary_text_color2, fontSize: 13, fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Align(
                                                              alignment: Alignment.topRight,
                                                              child: InkWell(
                                                                onTap: () async {
                                                                  await clearAllSublist(index);
                                                                  setState(() {});
                                                                },
                                                                child: Container(
/*                                                                        decoration:
                                                                           BoxDecoration(
                                                                           gradient: LinearGradient(
                                                                           begin:
                                                                           Alignment.topLeft,
                                                                           end: Alignment.topRight,
                                                                           colors: [
                                                                           c.primary_text_color2,
                                                                           c.primary_text_color2
                                                                           ]),
                                                                           borderRadius:
                                                                           const BorderRadius
                                                                           .only(
                                                                           topLeft:
                                                                           Radius.circular(10),
                                                                           topRight:
                                                                           Radius.circular(10),
                                                                           bottomLeft:
                                                                           Radius.circular(10),
                                                                           bottomRight:
                                                                           Radius.circular(10),
                                                                           )),*/
                                                                  margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
                                                                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                                  child: Align(
                                                                    alignment: Alignment.centerRight,
                                                                    child: Text(
                                                                      s.clear_all,
                                                                      style: TextStyle(color: c.primary_text_color2, fontSize: 13, fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                        subList(index),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                            ],
                                                          ))));
                                            })
                                      ],
                                    ))
                              ])))
                    ],
                  )),
                ),
                Visibility(
                  visible: villagelist.isNotEmpty ? true : false,
                  child: GestureDetector(
                    onTap: () {
                      downloadPlan();
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(15),
                        alignment: AlignmentDirectional.bottomCenter,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.topRight, colors: [c.colorPrimaryDark, c.colorPrimaryDark]),
                            border: Border.all(color: c.colorAccent, width: 0),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(30),
                              topRight: const Radius.circular(30),
                              bottomLeft: const Radius.circular(0),
                              bottomRight: const Radius.circular(0),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              s.download,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: c.white),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Image.asset(
                              imagePath.download,
                              fit: BoxFit.contain,
                              color: c.white,
                              height: 18,
                              width: 18,
                            ),
                          ],
                        )),
                  ),
                )
              ],
            ),
          )),
    );
  }

  /*
  ***********************************************************************************************
                                              * API CALL *
  */
  Future<void> getdelayedWorkListAll() async {
    utils.showProgress(context, 1);
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);

    late Map json_request;

    Map work_detail = {
      s.key_dcode: selectedDistrict,
      s.key_bcode: selectedBlock,
      s.key_fin_year: finList,
      s.key_scheme_id: schIdList,
      if (selectedMonth.isNotEmpty) s.key_month: selectedMonth,
      if (asController.text.isNotEmpty) s.key_as_value: asController.text,
      s.key_flag: "2"
    };
    json_request = {
      s.key_service_id: s.service_key_get_inspection_delayed_work_details,
    };
    json_request.addAll(work_detail);
    Map encrypted_request = {s.key_user_name: prefs.getString(s.key_user_name), s.key_data_content: json_request};
    String jsonString = jsonEncode(encrypted_request);

    String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

    String header_token = utils.jwt_Encode(key, userName!, headerSignature);
    Map<String, String> header = {"Content-Type": "application/json", "Authorization": "Bearer $header_token"};

    HttpClient client = HttpClient(context: await utils.globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    var response = await ioClient.post(url.main_service_jwt, body: jsonEncode(encrypted_request), headers: header);

    print("DelayedWorkListAll_url>>" + url.main_service_jwt.toString());
    print("DelayedWorkListAll_request_encrpt>>" + encrypted_request.toString());
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    utils.hideProgress(context);
    if (response.statusCode == 200) {
      String data = response.body;

      print("DelayedWorkListAll_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("DelayedWorkListByVillage Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("DelayedWorkListAll responceSignature -  $responceSignature");

      print("DelayedWorkListAll responceData -  $responceData");
      if (responceSignature == responceData) {
        print("DelayedWorkListAll responceSignature - Token Verified");
        var userData = jsonDecode(data);

        var status = userData[s.key_status];
        var response_value = userData[s.key_response];
        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          res_jsonArray.sort((a, b) {
            return a[s.key_work_id].compareTo(b[s.key_work_id]);
          });
          print("DelayedWorkListAll_response>>" + res_jsonArray.toString());

          if (res_jsonArray.isNotEmpty) {
          } else {
            utils.showAlert(context, s.no_data);
          }
        } else {
          utils.showAlert(context, s.no_data);
        }
      } else {
        print("DelayedWorkListAll responceSignature - Token Not Verified");
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
    }
  }

  Future<void> fetchDelayedWorkList() async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    utils.showProgress(context, 1);

    Map json_request = {
      s.key_service_id: s.service_key_get_inspection_delayed_work_details,
      s.key_dcode: selectedDistrict,
      s.key_bcode: selectedBlock,
      s.key_fin_year: finList,
      s.key_scheme_id: schIdList,
      s.key_flag: "1",
      if (selectedMonth.isNotEmpty) s.key_month: selectedMonth,
      if (asController.text.isNotEmpty) s.key_as_value: asController.text,
    };

    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: json_request,
    };

    String jsonString = jsonEncode(encrypted_request);

    String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

    String header_token = utils.jwt_Encode(key, userName!, headerSignature);
    Map<String, String> header = {"Content-Type": "application/json", "Authorization": "Bearer $header_token"};

    HttpClient client = HttpClient(context: await utils.globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    var response = await ioClient.post(url.main_service_jwt, body: jsonEncode(encrypted_request), headers: header);

    print("VillageList_response_url>>${url.main_service_jwt}");
    print("VillageList_response_request_json>> ${jsonEncode(json_request)}");
    print("VillageList_response_request_encrpt>>$encrypted_request");

    utils.hideProgress(context);

    if (response.statusCode == 200) {
      String data = response.body;

      print("VillageList_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("VillageList Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("VillageList responceSignature -  $responceSignature");

      print("VillageList responceData -  $responceData");

      if (responceSignature == responceData) {
        print("VillageList responceSignature - Token Verified");
        var userData = jsonDecode(data);

        var status = userData[s.key_status];
        var response_value = userData[s.key_response];

        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          print(res_jsonArray);
          villagelist = [];
          if (res_jsonArray.isNotEmpty) {
            for (var item in res_jsonArray) {
              item[key_flag] = '0';
              List list = jsonDecode(item[key_workdetails]);
              list.forEach((item2) {
                item2[key_flag] = false;
                // Additional calculations or logic can be added here if needed
              });
              item[key_workdetails] = list;
              // Additional calculations or logic can be added here if needed
            }
            villagelist = res_jsonArray;
            print(villagelist);
          }
        } else {
          utils.showAlert(context, "No Data");
        }
      }
    }
  }

  Future<void> getBlockList(String dcode) async {
    Map json_request = {
      s.key_dcode: dcode,
      s.key_service_id: s.service_key_block_list_district_wise_master,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: utils.encryption(jsonEncode(json_request), prefs.getString(s.userPassKey).toString()),
    };
    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    HttpClient client = HttpClient(context: await utils.globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    var response = await ioClient.post(url.master_service, body: json.encode(encrpted_request));
    print("BlockList_url>>${url.master_service}");
    print("BlockList_request_json>> ${jsonEncode(json_request)}");
    print("BlockList_request_encrpt>>$encrpted_request");
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("BlockList_response>>$data");
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = utils.decryption(enc_data.toString(), prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var responseValue = userData[s.key_response];
      if (status == s.key_ok && responseValue == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        res_jsonArray.sort((a, b) {
          return a[s.key_bname].toLowerCase().compareTo(b[s.key_bname].toLowerCase());
        });
        if (res_jsonArray.isNotEmpty) {
          blockItems = [];
          blockItems.add(defaultSelectedBlock);
          blockItems.addAll(res_jsonArray);
          selectedBlock = defaultSelectedBlock[s.key_bcode]!;
          dFlag = true;
        }
      } else if (status == s.key_ok && responseValue == s.key_noRecord) {
        Utils().showAlert(context, "No Block Found");
      }
      isLoadingDistrict = false;
      districtError = false;
      setState(() {});
    }
  }

  void multiChoiceFinYearSelection(List<FlutterLimitedCheckBoxModel> list, String msg) {
    int limitCount = 2;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return FlutterCustomCheckbox(
              flag: "",
              initialValueList: list,
              message: msg,
              limitCount: limitCount,
              onChanged: (List<FlutterLimitedCheckBoxModel> list) async {
                finList.clear();
                villagelist = [];
                schIdList = [];
                schList = [];
                selectedMonth = "0";
                asController.text = "0";
                schemeError = true;
                for (int i = 0; i < list.length; i++) {
                  finList.add(list[i].selectTitle);
                }
                if (selectedLevel == "B") {
                  delay = true;
                  await getSchemeList();
                } else {
                  selectedBlock = defaultSelectedBlock[s.key_bcode]!;
                  blockError = true;
                }
                setState(() {});
              });
          /*AlertDialog(
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
                            finListchecked.clear();
                            for (int i = 0; i < list.length; i++) {
                              finListchecked.add(list[i].selectTitle);
                            }
                            print(finListchecked.toString());
                          },
                          mainAxisAlignmentOfRow: MainAxisAlignment.start,
                          crossAxisAlignmentOfRow: CrossAxisAlignment.center,
                        ),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          finList.clear();
                          if (finListchecked.isNotEmpty) {
                            finList.addAll(finListchecked);
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
          );*/
        });
  }

  void multiChoiceSchemeSelection(List<FlutterLimitedCheckBoxModel> list) {
    int limitCount = list.length;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return FlutterCustomCheckbox(
              flag: "select_all",
              initialValueList: list,
              message: s.select_scheme,
              limitCount: limitCount,
              onChanged: (List<FlutterLimitedCheckBoxModel> list) {
                villagelist = [];
                schList.clear();
                schIdList.clear();
                schArray.clear();
                for (int i = 0; i < list.length; i++) {
                  schList.add(list[i].selectTitle);
                  schIdList.add(list[i].selectId);
                  Map<String, String> map = {s.key_scheme_id: list[i].selectId.toString(), s.key_scheme_name: list[i].selectTitle};
                  schArray.add(map);
                }
                schIdList.isNotEmpty ? schemeError = false : schemeError = true;
                setState(() {});
              });
          /* AlertDialog(
            title: Row(children: [
              Text(s.select_scheme,
                  style: GoogleFonts.getFont('Roboto',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: c.grey_8)),
              Container(
                alignment: AlignmentDirectional.topEnd,
                margin: EdgeInsets.only(left: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      s.select_all,
                      style: GoogleFonts.getFont('Roboto',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: c.grey_8),
                    ),
                    Checkbox(
                      value: schemelistflag,
                      onChanged: (value) {
                        setState(() {
                          schemelistflag = true;
                        });
                      },
                    ),
                  ],
                ),
              )
            ]),
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
                            SchemeListchecked.clear();
                            for (int i = 0; i < list.length; i++) {
                              SchemeListchecked.add(list[i].selectTitle);
                            }
                          },
                          mainAxisAlignmentOfRow: MainAxisAlignment.start,
                          crossAxisAlignmentOfRow: CrossAxisAlignment.center,
                        ),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.pop(context, 'OK');
                          if (SchemeListchecked.isNotEmpty) {
                            schemeList.clear();
                            schemeList.addAll(SchemeListchecked);
                          }

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
          );*/
        });
  }

  Future<void> getSchemeList() async {
    utils.showProgress(context, 1);
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    Map json_request = {};
    json_request = {
      s.key_dcode: selectedDistrict,
      s.key_bcode: selectedBlock,
      s.key_fin_year: finList,
      s.key_service_id: s.service_key_scheme_list_blockwise,
    };
    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: json_request,
    };

    String jsonString = jsonEncode(encrypted_request);

    String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

    String header_token = utils.jwt_Encode(key, userName!, headerSignature);
    Map<String, String> header = {"Content-Type": "application/json", "Authorization": "Bearer $header_token"};
    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    HttpClient client = HttpClient(context: await utils.globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    var response = await ioClient.post(url.main_service_jwt, body: jsonEncode(encrypted_request), headers: header);

    utils.hideProgress(context);
    print("SchemeList_url>>" + url.main_service_jwt.toString());
    print("SchemeList_request_json>>" + json_request.toString());
    print("SchemeList_request_encrpt>>" + encrypted_request.toString());
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
        if (status == s.key_ok && responseValue == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          res_jsonArray.sort((a, b) {
            return a[s.key_scheme_name].toLowerCase().compareTo(b[s.key_scheme_name].toLowerCase());
          });
          if (res_jsonArray.isNotEmpty) {
            SchemeListvalue.clear();
            schemeFlag = true;
            for (int i = 0; i < res_jsonArray.length; i++) {
              String schName = res_jsonArray[i][s.key_scheme_name];
              // if (schName.length >= 30) {
              //   schName = utils.splitStringByLength(schName, 30);
              // }
              SchemeListvalue.add(FlutterLimitedCheckBoxModel(isSelected: false, selectTitle: schName, selectId: res_jsonArray[i][s.key_scheme_id]));
              print(res_jsonArray.toString());
            }
          }
        } else if (status == s.key_ok && responseValue == s.key_noRecord) {
          Utils().showAlert(context, "No Scheme Found");
        }
      } else {
        print("SchemeList responceSignature - Token Not Verified");
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
    }
  }

  Widget subList(int mainIndex) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: villagelist[mainIndex][key_workdetails].length,
      itemBuilder: (context, index) {
        final item = villagelist[mainIndex][key_workdetails][index];
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 800),
          child: SlideAnimation(
            horizontalOffset: 200.0,
            child: FlipAnimation(
              child: Container(
                  margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 10),
                  decoration: BoxDecoration(
                      color: c.dot_light_screen_lite1,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              s.work_id + " : " + item[s.key_work_id].toString(),
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: c.grey_8),
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: true,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                                padding: EdgeInsets.all(2),
                                child: Center(
                                  child: Checkbox(
                                    side: BorderSide(width: 1, color: c.grey_6),
                                    value: item[s.key_flag],
                                    onChanged: (v) async {
                                      print("cliked");
                                      print("cliked" + item[key_flag].toString());
                                      setState(() {
                                        if (item[key_flag] == false) {
                                          item[key_flag] = true;
                                        } else {
                                          item[key_flag] = false;
                                        }
                                      });
                                      print("cliked" + item[key_flag].toString());
                                    },
                                  ),
                                )),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              s.work_name,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: c.grey_8),
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: true,
                            ),
                          ),
                          Expanded(
                            flex: 0,
                            child: Text(
                              ' : ',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: c.grey_8),
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: true,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Align(
                                alignment: AlignmentDirectional.topStart,
                                child: ExpandableText(
                                  item[s.key_work_name].toString(),
                                  trimLines: 2,
                                  txtcolor: "2",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              s.work_type_name,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: c.grey_8),
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: true,
                            ),
                          ),
                          Expanded(
                            flex: 0,
                            child: Text(
                              ' : ',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: c.grey_8),
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              softWrap: true,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Align(
                                alignment: AlignmentDirectional.topStart,
                                child: ExpandableText(
                                  item[s.key_work_type_name].toString(),
                                  trimLines: 2,
                                  txtcolor: "2",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ),
        );
      },
    );
  }

  void downloadPlan() {
    List selectedList = [];
    List work_id_list = [];
    for (var item in villagelist) {
      List list = item[key_workdetails];
      for (var item2 in list) {
        if (item2[key_flag] == true) {
          selectedList.add(item2);
          work_id_list.add(item2[key_work_id]);
        }
        // Additional calculations or logic can be added here if needed
      }
      // Additional calculations or logic can be added here if needed
    }
    print("selectedList>>" + selectedList.toString());
    print("work_id_list>>" + work_id_list.toString());
    downloadDelayedWorkList(work_id_list);
  }

  Future<void> downloadDelayedWorkList(List<dynamic> work_id_list) async {
    utils.showProgress(context, 1);
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);

    late Map json_request;
    Map work_detail = {
      s.key_dcode: selectedDistrict,
      s.key_bcode: selectedBlock,
      s.key_work_id: work_id_list,
    };
    json_request = {
      s.key_service_id: s.service_key_get_inspection_work_details_by_work_id,
      s.key_inspection_work_details: work_detail,
    };
    Map encrypted_request = {s.key_user_name: prefs.getString(s.key_user_name), s.key_data_content: json_request};
    String jsonString = jsonEncode(encrypted_request);

    String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

    String header_token = utils.jwt_Encode(key, userName!, headerSignature);
    Map<String, String> header = {"Content-Type": "application/json", "Authorization": "Bearer $header_token"};
    var response;
    try {
      HttpClient client = HttpClient(context: await utils.globalContext);
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
      IOClient ioClient = IOClient(client);
      response = await ioClient.post(url.main_service_jwt, body: jsonEncode(encrypted_request), headers: header);

      print("downloadDelayedWorkList_url>>" + url.main_service_jwt.toString());
      print("downloadDelayedWorkList_request_encrpt>>" + encrypted_request.toString());
    } catch (error) {
      utils.hideProgress(context);
      print('error (${error.toString()}) has been caught');
    }
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    utils.hideProgress(context);
    if (response.statusCode == 200) {
      String data = response.body;

      print("downloadDelayedWorkList_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("downloadDelayedWorkList Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("downloadDelayedWorkList responceSignature -  $responceSignature");

      print("downloadDelayedWorkList responceData -  $responceData");
      if (responceSignature == responceData) {
        print("downloadDelayedWorkList responceSignature - Token Verified");
        var userData = jsonDecode(data);

        var status = userData[s.key_status];
        var response_value = userData[s.key_response];
        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          /*res_jsonArray.sort((a, b) {
            return a[s.key_work_id].compareTo(b[s.key_work_id]);
          });*/
          if (res_jsonArray.isNotEmpty) {
            dbHelper.delete_table_PlannedDelayWorkList('R');
            String sql_worklist =
                'INSERT INTO ${s.table_PlannedDelayWorkList} (rural_urban,town_type,dcode, dname , bcode, bname , pvcode , pvname, hab_code , scheme_group_id , scheme_id , scheme_name, work_group_id , work_type_id , fin_year, work_id ,work_name , as_value , ts_value , current_stage_of_work , is_high_value , stage_name , as_date , ts_date , upd_date, work_order_date , work_type_name , tpcode   , townpanchayat_name , muncode , municipality_name , corcode , corporation_name) VALUES ';

            List<String> valueSets_worklist = [];

            for (var row in res_jsonArray) {
              String values =
                  " ( 'R', '0', '${utils.checkNull(row[s.key_dcode])}', '${utils.checkNull(row[s.key_dname])}', '${utils.checkNull(row[s.key_bcode])}', '${utils.checkNull(row[s.key_bname])}', '${utils.checkNull(row[s.key_pvcode])}', '${row[s.key_pvname]}', '${utils.checkNull(row[s.key_hab_code])}', '${row[s.key_scheme_group_id]}', '${utils.checkNull(row[s.key_scheme_id])}', '${utils.checkNull(row[s.key_scheme_name])}', '${utils.checkNull(row[s.key_work_group_id])}', '${utils.checkNull(row[s.key_work_type_id])}', '${utils.checkNull(row[s.key_fin_year])}', '${utils.checkNull(row[s.key_work_id])}', '${utils.checkNull(row[s.key_work_name])}', '${utils.checkNull(row[s.key_as_value])}', '${utils.checkNull(row[s.key_ts_value])}', '${utils.checkNull(row[s.key_current_stage_of_work])}', '${utils.checkNull(row[s.key_is_high_value])}', '${utils.checkNull(row[s.key_stage_name])}', '${utils.checkNull(row[s.key_as_date])}', '${utils.checkNull(row[s.key_ts_date])}', '${utils.checkNull(row[s.key_upd_date])}', '${utils.checkNull(row[s.key_work_order_date])}', '${utils.checkNull(row[s.key_work_type_name])}', '0', '0', '0', '0', '0', '0') ";
              valueSets_worklist.add(values);
            }

            sql_worklist += valueSets_worklist.join(', ');

            await dbHelper.myDb?.execute(sql_worklist);
            if (res_jsonArray.isNotEmpty) {
              List result = res_jsonArray
                  .fold({}, (previousValue, element) {
                    Map val = previousValue as Map;
                    String date = element[key_pvname];
                    if (!val.containsKey(date)) {
                      val[date] = [];
                    }
                    element.remove(key_pvname);
                    val[date]?.add(element);
                    return val;
                  })
                  .entries
                  .map((e) => {e.key: e.value})
                  .toList();

              pvListHeader = [];

              for (var pvlistCount = 0; pvlistCount < result.length; pvlistCount++) {
                Map<dynamic, dynamic> data = result[pvlistCount];
                tableHeaderName = data.keys.first.toString();
                pvListHeader.add(tableHeaderName);
              }

              final pdf = pw.Document();

              pdf.addPage(
                pw.MultiPage(
                  pageFormat: PdfPageFormat.a4,
                  build: (pw.Context context) {
                    List<pw.Widget> pages = [];

                    pages.add(pw.Column(children: [
                      _buildHeader(context),

                      pw.SizedBox(height: 20), // Space between date and heading
                      pw.Center(
                        child: pw.Text(
                          'Inspection Plan Details',
                          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      pw.Flex(
                        direction: pw.Axis.horizontal,
                        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'District : ${res_jsonArray[0][key_dname]}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                          pw.Text(
                            'Block : ${res_jsonArray[0][key_bname]}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ]));

                    for (var headerCount = 0; headerCount < pvListHeader.length; headerCount++) {
                      pages.add(
                        pw.Container(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildContent(context, pvListHeader, result, headerCount),
                            ],
                          ),
                        ),
                      );
                    }

                    return pages;
                  },
                ),
              );

              Uint8List pdfBytes = await pdf.save();
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => PDF_Viewer(
                          pdfBytes: pdfBytes,
                          workID: work_id,
                          inspectionID: inspection_id,
                          flag: 'planned_delay_works',
                        )),
              ); // Page Page
              /*utils.customAlertWithDataPassing(context, "Success",
                  s.download_success, false, true, 'planned_delay_works');*/
            }
          } else {
            utils.showAlert(context, s.no_data);
          }
        } else {
          utils.showAlert(context, s.no_data);
        }
      } else {
        utils.showAlert(context, s.no_data);
      }
    } else {
      print("downloadDelayedWorkList responceSignature - Token Not Verified");
      utils.customAlertWidet(context, "Error", s.jsonError);
    }
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Container(),
        pw.Text(
          'Date: $currentDate',
          style: pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  pw.Widget _buildContent(pw.Context context, List<dynamic> pvListHeader, List<dynamic> result, int headerCount) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 20), // Space between content and table
        pvNameHeaderTable(context, pvListHeader, headerCount),
        detailsTable(context, result, pvListHeader, headerCount),
      ],
    );
  }

  pw.Table pvNameHeaderTable(pw.Context context, List<dynamic> list, int index) {
    String headerValue = "Village : ${list[index]}";

    return pw.Table.fromTextArray(
      defaultColumnWidth: pw.FixedColumnWidth(5),
      context: context,
      data: [
        [headerValue],
      ],
      cellAlignment: pw.Alignment.center,
      cellStyle: pw.TextStyle(fontSize: 10),
      border: pw.TableBorder.all(),
    );
  }

  pw.Table detailsTable(pw.Context context, List<dynamic> result, List pvListHeader, int headersCount) {
    String villageName = pvListHeader[headersCount];
    List<String> listofHeader = [work_id, work_name, work_type_name, as_value];

    List<List<dynamic>> mlist = [];

    for (var data in result[headersCount][villageName]) {
      List<String> list2 = [];
      mlist.isEmpty ? mlist.add(listofHeader) : null;
      list2.add(data[key_work_id].toString());
      list2.add(data[key_work_name]);
      list2.add(data[key_work_type_name]);
      list2.add(data[key_as_value].toString());
      mlist.add(list2);
    }

    return pw.Table.fromTextArray(
      context: context,
      data: [...mlist],
      cellStyle: pw.TextStyle(fontSize: 10),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.normal),
      columnWidths: {
        0: pw.FlexColumnWidth(1),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1),
      },
      border: pw.TableBorder.all(),
    );
  }

  validateAs(String v) {
    if (asController.text.isNotEmpty && int.parse(asController.text) > 0) {
      submitFlag = true;
    } else {
      selectedMonth != "0" ? submitFlag = true : submitFlag = false;
      /*utils.customAlertWidet(
          context,
          "Error",
          "Please Enter AS value");*/
    }
  }

  Future<void> selectAllSublist(int index) async {
    for (var sampletaxData in villagelist[index][key_workdetails]) {
      sampletaxData[key_flag] = true;
    }
  }
  Future<void> clearAllSublist(int index) async {
    for (var sampletaxData in villagelist[index][key_workdetails]) {
      sampletaxData[key_flag] = false;
    }
  }
}
