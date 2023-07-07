import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/Home.dart';
import 'package:inspection_flutter_app/Activity/WorkList.dart';
import 'package:inspection_flutter_app/Layout/Single_CheckBox.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:shared_preferences/shared_preferences.dart';

import '../DataBase/DbHelper.dart';
import '../Layout/Multiple_CheckBox.dart';
import '../Layout/checkBoxModelClass.dart';
import '../Resources/Strings.dart';
import '../Resources/Strings.dart';
import '../Utils/utils.dart';

class DelayedWorkFilterScreen extends StatefulWidget {
  const DelayedWorkFilterScreen({Key? key}) : super(key: key);

  @override
  State<DelayedWorkFilterScreen> createState() =>
      _DelayedWorkFilterScreenState();
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
  List<FlutterLimitedCheckBoxModel> finyearList = [];
  List<FlutterLimitedCheckBoxModel> SchemeListvalue = [];

  //Default Values
  Map<String, String> defaultSelectedFinYear = {
    s.key_fin_year: s.select_financial_year,
  };
  Map<String, String> defaultSelectedBlock = {
    s.key_bcode: "0",
    s.key_bname: s.selectBlock
  };
  Map<String, String> defaultSelectedDistrict = {
    s.key_dcode: "0",
    s.key_dname: s.selectDistrict
  };
  Map<String, String> defaultSelectedMonth = {'monthId': "00", 'month': '0'};

  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;

  TextEditingController asController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
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
    selectedLevel = prefs.getString(s.key_level)!;
    print("#############" + finYearItems.toString());
    if (selectedLevel == 'S') {
      sFlag = true;
      List<Map> list =
          await dbClient.rawQuery('SELECT * FROM ${s.table_District}');
      print(list.toString());
      districtItems.add(defaultSelectedDistrict);
      districtItems.addAll(list);
      selectedDistrict = defaultSelectedDistrict[s.key_dcode]!;
      selectedBlock = defaultSelectedBlock[s.key_bcode]!;
      selectedFinYear = defaultSelectedFinYear[s.key_fin_year]!;
    } else if (selectedLevel == 'D') {
      dFlag = true;
      List<Map> list =
          await dbClient.rawQuery('SELECT * FROM ${s.table_Block}');
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
      Map<String, String> mymap =
          {}; // This created one object in the current scope.
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
          appBar: AppBar(
            backgroundColor: c.colorPrimary,
            centerTitle: true,
            elevation: 2,
            title: Center(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Text(
                        s.plan_to_inspect,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    padding: EdgeInsets.all(5),
                    child: GestureDetector(
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
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            color: c.white,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 15),
                  child: Text(
                    s.select_financial_year,
                    style: GoogleFonts.getFont('Roboto',
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: c.grey_8),
                  ),
                ),
                Container(
                    height: 30,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        color: c.grey_out,
                        border: Border.all(
                            width: finYearError ? 1 : 0.1,
                            color: finYearError ? c.red : c.grey_10),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: InkWell(
                        onTap: () {
                          multiChoiceFinYearSelection(
                              finyearList, s.select_financial_year);
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  finList.isNotEmpty
                                      ? finList.join(', ')
                                      : s.select_financial_year,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                      color: c.grey_10),
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
                          style: GoogleFonts.getFont('Roboto',
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
                                schIdList = [];
                                schList = [];
                                SchemeListvalue.clear();
                                blockItems = [];
                                selectedBlock =
                                    defaultSelectedBlock[s.key_bcode]!;
                                blockError = true;
                                schemeError = true;
                                selectedMonth="00";
                                asController.text="0";

                                if (value != "0") {
                                  isLoadingDistrict = true;
                                  loadUIBlock(value.toString());
                                  setState(() {});
                                } else {
                                  setState(() {
                                    selectedDistrict = value.toString();
                                    districtError = true;
                                  });
                                }
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
                        visible: districtError ? true : false,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            s.please_enter_district,
                            style: TextStyle(
                                color: Colors.redAccent.shade700,
                                fontSize: 12.0),
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
                          style: GoogleFonts.getFont('Roboto',
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: c.grey_8),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: c.grey_out,
                            border: Border.all(
                                width: blockError ? 1 : 0.1,
                                color: blockError ? c.red : c.grey_10),
                            borderRadius: BorderRadius.circular(10.0)),
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
                              selectedMonth="00";
                              asController.text="0";
                              if(finList.isNotEmpty){
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
                                }else{
                                  blockError = true;
                                }
                                setState(() {});
                              }else{
                                utils.showAlert(context, s.select_financial_year);
                              }

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
                            style: TextStyle(
                                color: Colors.redAccent.shade700,
                                fontSize: 12.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            Visibility(
                visible: schemeFlag ? true : false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                  child: Text(
                    s.select_scheme,
                    style: GoogleFonts.getFont('Roboto',
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: c.grey_8),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 30,
                  ),
                  child:Container(
                    padding: EdgeInsets.only(top: 5,bottom: 5, left: 10, right: 10),
                    decoration: BoxDecoration(
                        color: c.grey_out,
                        border: Border.all(
                            width: schemeError ? 1 : 0.1,
                            color: schemeError ? c.red : c.grey_10),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: InkWell(
                        onTap: () {
                          SchemeListvalue.length > 0
                              ? multiChoiceSchemeSelection(SchemeListvalue)
                              : null;
                          print(
                              "Schemelist#######" + SchemeListvalue.toString());
                          setState(() {});
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  schList.isNotEmpty
                                      ? schList.join(', ')
                                      : s.select_scheme,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                      color: c.grey_10),
                                  overflow: TextOverflow.clip,
                                  softWrap: true,
                                ),
                              ),
                            ]))),),])),
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
                            decoration: BoxDecoration(
                                color: c.grey_out,
                                border:
                                    Border.all(width: 0.1, color: c.grey_10),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 5, bottom: 5, left: 5, right: 0),
                                  child: Text(
                                    'Months Delayed',
                                    style: GoogleFonts.getFont('Roboto',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        color: c.grey_8),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 30,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2(
                                        style: const TextStyle(
                                            color: Colors.black),
                                        value: selectedMonth,
                                        isExpanded: true,
                                        items: monthItems
                                            .map((item) =>
                                                DropdownMenuItem<String>(
                                                  value: item['monthId']
                                                      .toString(),
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
                                            submitFlag = true;
                                            setState(() {});
                                          }
                                        },
                                        buttonStyleData: const ButtonStyleData(
                                          height: 30,
                                          padding: EdgeInsets.only(right: 10),
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
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                    onTap: () {
                                      utils.hideSoftKeyBoard(context);
                                      if (asController.text.isNotEmpty &&
                                          int.parse(asController.text) > 0) {
                                        submitFlag = true;
                                      } else {
                                        utils.customAlertWidet(context, "Error",
                                            "Please Enter AS value");
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
                                            border: Border.all(
                                                width: 0, color: c.grey_10),
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(0),
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(10),
                                            )),
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 5, 5, 5),
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
                            backgroundColor: MaterialStateProperty.all<Color>(
                                c.colorPrimary),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ))),
                        onPressed: () async {
                          if(selectedDistrict.isNotEmpty){
                            if(selectedBlock.isNotEmpty){
                              if(finList.isNotEmpty){
                              if(schIdList.isNotEmpty){
                                asController.text.isEmpty
                                    ? asController.text = "0"
                                    : null;
                                if (int.parse(asController.text) > 0 ||
                                    selectedMonth != "00") {
                                  await fetchDelayedWorkList();
                                } else {
                                  utils.customAlertWidet(context, "Error",
                                      "Please Select AS value or Months");
                                }
                              }else{
                                utils.showAlert(context, s.select_scheme);
                              }
                              }else{
                                utils.showAlert(context, s.select_financial_year);
                              }
                            }else{
                              utils.showAlert(context, s.selectBlock);
                            }
                          }else{
                            utils.showAlert(context, s.selectDistrict);
                          }


                          // pvTable = true;
                          setState(() {});
                        },
                        child: Text(
                          s.submit,
                          style: GoogleFonts.getFont('Roboto',
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: c.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                    child: Container(
                        child: Stack(children: [
                  Visibility(
                      visible: villagelist.isNotEmpty ? true : false,
                      child: Container(
                          child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: villagelist.length,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                    onTap: () async {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => WorkList(
                                                    finYear: finList,
                                                    dcode: selectedDistrict,
                                                    bcode: selectedBlock,
                                                    pvcode: villagelist[index]
                                                        [s.key_pvcode],
                                                    tmccode: selectedMonth,
                                                    flag: "delayed_works",
                                                    asvalue: asController.text,
                                                    selectedschemeList: "",
                                                    townType: '',
                                                    scheme: '',
                                                    schemeList: schIdList,
                                                  )));
                                    },
                                    child: Card(
                                        elevation: 5,
                                        margin: EdgeInsets.only(
                                            top: 10, left: 15, bottom: 10),
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
                                            clipper: ShapeBorderClipper(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20))),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 10,
                                                      padding: EdgeInsets.only(
                                                          top: 10, bottom: 10),
                                                      child: Text(""),
                                                      decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .topRight,
                                                              colors: [
                                                                c.colorPrimary,
                                                                c.colorAccentverylight
                                                              ]),
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    20),
                                                            topRight:
                                                                Radius.circular(
                                                                    0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    20),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    0),
                                                          )),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10,
                                                                bottom: 10),
                                                        child: Text(
                                                          villagelist[index]
                                                              [key_pvname],
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color: c.black),
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 10,
                                                                bottom: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                                color: c
                                                                    .dot_light_screen_lite1,
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          20),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          0),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          20),
                                                                )),
                                                        child: Text(
                                                            villagelist[index][
                                                                    key_total_count]
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: c
                                                                    .primary_text_color2,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center,
                                                            maxLines: 1),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ))));
                              })))
                ])))
              ],
            )),
          )),
    );
  }

  /*
  ***********************************************************************************************
                                              * API CALL *
  */

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

    print("VillageList_response_url>>${url.master_service}");
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
          if (res_jsonArray.length > 0) {
            for (int i = 0; i < res_jsonArray.length; i++) {
              Map<String, String> map = {
                key_total_count: res_jsonArray[i][key_total_count].toString(),
                key_pvname: res_jsonArray[i][key_pvname],
                key_pvcode: res_jsonArray[i][key_pvcode].toString()
              };
              villagelist.add(map);
              print("villageList#####" + villagelist[i][key_pvcode].toString());
            }
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
      var decrpt_data = utils.decryption(
          enc_data.toString(), prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var responseValue = userData[s.key_response];
      if (status == s.key_ok && responseValue == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        res_jsonArray.sort((a, b) {
          return a[s.key_bname]
              .toLowerCase()
              .compareTo(b[s.key_bname].toLowerCase());
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

  void multiChoiceFinYearSelection(
      List<FlutterLimitedCheckBoxModel> list, String msg) {
    int limitCount = 2;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return FlutterCustomCheckbox(
              initialValueList: list,
              message: msg,
              limitCount: limitCount,
              onChanged: (List<FlutterLimitedCheckBoxModel> list) async {
                finList.clear();
                schIdList = [];
                schList = [];
                selectedMonth="00";
                asController.text="0";
                schemeError = true;
                for (int i = 0; i < list.length; i++) {
                  finList.add(list[i].selectTitle);
                }
                if(selectedLevel=="B"){
                  delay = true;
                  await getSchemeList();
                }else{
                  selectedBlock =
                  defaultSelectedBlock[s.key_bcode]!;
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
              initialValueList: list,
              message: s.select_scheme,
              limitCount: limitCount,
              onChanged: (List<FlutterLimitedCheckBoxModel> list) {
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
                schIdList.isNotEmpty?schemeError = false:schemeError=true;
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
            return a[s.key_scheme_name]
                .toLowerCase()
                .compareTo(b[s.key_scheme_name].toLowerCase());
          });
          if (res_jsonArray.length > 0) {
            SchemeListvalue.clear();
            schemeFlag = true;
            for (int i = 0; i < res_jsonArray.length; i++) {
              String schName = res_jsonArray[i][s.key_scheme_name];
              if (schName.length >= 30) {
                schName = utils.splitStringByLength(schName, 30);
              }
              SchemeListvalue.add(FlutterLimitedCheckBoxModel(
                  isSelected: false,
                  selectTitle: schName,
                  selectId: res_jsonArray[i][s.key_scheme_id]));
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
}
