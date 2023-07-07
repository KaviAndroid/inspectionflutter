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
import '../Layout/Multiple_CheckBox.dart';
import '../Layout/ReadMoreLess.dart';
import '../Layout/checkBoxModelClass.dart';
import '../Resources/Strings.dart';
import '../Utils/utils.dart';

class RdprOnlineWorkList extends StatefulWidget {
  const RdprOnlineWorkList({Key? key}) : super(key: key);

  @override
  State<RdprOnlineWorkList> createState() => _RdprOnlineWorkListState();
}

class _RdprOnlineWorkListState extends State<RdprOnlineWorkList> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  List finYearItems = [];
  List districtItems = [];
  List blockItems = [];
  List villageItems = [];
  List schemeItems = [];
  List finList = [];
  List finListchecked = [];
  List schemelistWithCount = [];

  String selectedFinYear = "";
  String selectedDistrict = "";
  String selectedBlock = "";
  String selectedVillage = "";
  String selectedScheme = "";
  String selectedLevel = "";

  bool isLoadingFinYear = false;
  bool isLoadingD = false;
  bool isLoadingB = false;
  bool isLoadingV = false;
  bool isLoadingScheme = false;
  bool finYearError = false;
  bool districtError = false;
  bool blockError = false;
  bool villageError = false;
  bool schemeError = false;
  bool submitFlag = false;

  bool blockFlag = false;
  bool districtFlag = false;
  bool villageFlag = false;
  bool schemeFlag = false;
  List<FlutterLimitedCheckBoxModel> finyearList = [];
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
  Map<String, String> defaultSelectedVillage = {
    s.key_pvcode: "0",
    s.key_pvname: s.select_village
  };

  Map<String, String> defaultSelectedScheme = {
    s.key_scheme_id: "0",
    s.key_scheme_name: s.select_scheme
  };
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
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
    print(finYearItems.toString());
    if (selectedLevel == 'S') {
      districtFlag = true;
      List<Map> list =
          await dbClient.rawQuery('SELECT * FROM ' + s.table_District);
      print(list.toString());
      districtItems.add(defaultSelectedDistrict);
      districtItems.addAll(list);
      selectedDistrict = defaultSelectedDistrict[s.key_dcode]!;
      selectedBlock = defaultSelectedBlock[s.key_bcode]!;
      selectedVillage = defaultSelectedVillage[s.key_pvcode]!;
      selectedFinYear = defaultSelectedFinYear[s.key_fin_year]!;
    } else if (selectedLevel == 'D') {
      blockFlag = true;
      List<Map> list =
          await dbClient.rawQuery('SELECT * FROM ' + s.table_Block);
      print(list.toString());
      blockItems.add(defaultSelectedBlock);
      blockItems.addAll(list);
      selectedDistrict = prefs.getString(s.key_dcode)!;
      selectedBlock = defaultSelectedBlock[s.key_bcode]!;
      selectedVillage = defaultSelectedVillage[s.key_pvcode]!;
    } else if (selectedLevel == 'B') {
      villageFlag = true;
      List<Map> list =
          await dbClient.rawQuery('SELECT * FROM ' + s.table_Village);
      print(list.toString());
      villageItems.add(defaultSelectedVillage);
      villageItems.addAll(list);
      selectedDistrict = prefs.getString(s.key_dcode)!;
      selectedBlock = prefs.getString(s.key_bcode)!;
      selectedVillage = defaultSelectedVillage[s.key_pvcode]!;
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
                      s.filter_work_list,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
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
                Visibility(
                  visible: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 15),
                              child: Text(
                                s.select_financial_year,
                                style: GoogleFonts.getFont('Roboto',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: c.grey_8),
                              ),
                            ),
                            Container(
                                height: 40,
                                padding: EdgeInsets.only(left: 15),
                                decoration: BoxDecoration(
                                    color: c.grey_out,
                                    border: Border.all(
                                        width: finYearError ? 1 : 0.1,
                                        color:
                                            finYearError ? c.red : c.grey_10),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: InkWell(
                                    onTap: () {
                                      multiChoiceFinYearSelection(
                                          finyearList, s.select_financial_year);
                                    },
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                /* child: IgnorePointer(
                                ignoring: isLoadingFinYear ? true : false,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    style: const TextStyle(color: Colors.black),
                                    value: selectedFinYear,
                                    isExpanded: true,
                                    items: finYearItems
                                        .map((item) => DropdownMenuItem<String>(
                                              value: item[s.key_fin_year]
                                                  .toString(),
                                              child: Text(
                                                item[s.key_fin_year].toString(),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != s.select_financial_year) {
                                        submitFlag = false;
                                        isLoadingFinYear = false;
                                        finYearError = false;
                                        selectedFinYear = value.toString();
                                        schemeError = true;
                                        schemeItems = [];
                                        villageError = true;
                                        selectedVillage =
                                            defaultSelectedVillage[
                                                s.key_pvcode]!;
                                        setState(() {});
                                      } else {
                                        setState(() {
                                          submitFlag = false;
                                          selectedFinYear = value.toString();
                                          finYearError = true;
                                          schemeError = true;
                                          schemeItems = [];
                                          villageError = true;
                                          selectedVillage =
                                              defaultSelectedVillage[
                                                  s.key_pvcode]!;
                                        });
                                      }
                                    },
                                    buttonStyleData: const ButtonStyleData(
                                      height: 45,
                                      padding: EdgeInsets.only(right: 10),
                                    ),
                                    iconStyleData: IconStyleData(
                                      icon: isLoadingFinYear
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
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                ),
                              ),*/
                                ),
                            const SizedBox(height: 8.0),
                            Visibility(
                              visible: finYearError ? true : false,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  s.please_select_financial_year,
                                  // state.hasError ? state.errorText : '',
                                  style: TextStyle(
                                      color: Colors.redAccent.shade700,
                                      fontSize: 12.0),
                                ),
                              ),
                            ),
                          ])),
                      Visibility(
                        visible: districtFlag ? true : false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 15),
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
                                ignoring: isLoadingD ? true : false,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    style: const TextStyle(color: Colors.black),
                                    value: selectedDistrict,
                                    isExpanded: true,
                                    items: districtItems
                                        .map((item) => DropdownMenuItem<String>(
                                              value:
                                                  item[s.key_dcode].toString(),
                                              child: Text(
                                                item[s.key_dname].toString(),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != "0") {
                                        submitFlag = false;
                                        isLoadingD = true;
                                        loadUIBlock(value.toString());
                                        villageError = true;
                                        schemeError = true;
                                        villageItems = [];
                                        schemeItems = [];
                                        setState(() {});
                                      } else {
                                        setState(() {
                                          submitFlag = false;
                                          selectedDistrict = value.toString();
                                          districtError = true;
                                          blockError = true;
                                          villageError = true;
                                          schemeError = true;
                                          blockItems = [];
                                          villageItems = [];
                                          schemeItems = [];
                                        });
                                      }
                                    },
                                    buttonStyleData: const ButtonStyleData(
                                      height: 40,
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
                        visible: blockFlag ? true : false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 15),
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
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 15),
                                  isExpanded: true,
                                  items: blockItems
                                      .map((item) => DropdownMenuItem<String>(
                                            value: item[s.key_bcode].toString(),
                                            child: Text(
                                              item[s.key_bname].toString(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != "0") {
                                      submitFlag = false;
                                      isLoadingB = true;
                                      loadUIVillage(value.toString());
                                      schemeError = true;
                                      schemeItems = [];
                                      setState(() {});
                                    } else {
                                      setState(() {
                                        submitFlag = false;
                                        selectedBlock = value.toString();
                                        blockError = true;
                                        villageError = true;
                                        villageItems = [];
                                        schemeError = true;
                                        schemeItems = [];
                                      });
                                    }
                                    //Do something when changing the item if you want.
                                  },
                                  buttonStyleData: const ButtonStyleData(
                                    height: 40,
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
                        visible: villageFlag ? true : false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 15),
                              child: Text(
                                s.select_village,
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
                                      width: villageError ? 1 : 0.1,
                                      color: villageError ? c.red : c.grey_10),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  value: selectedVillage,
                                  style: const TextStyle(color: Colors.black),
                                  isExpanded: true,
                                  items: villageItems
                                      .map((item) => DropdownMenuItem<String>(
                                            value:
                                                item[s.key_pvcode].toString(),
                                            child: Text(
                                              item[s.key_pvname].toString(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != "0") {
                                      submitFlag = true;
                                      isLoadingV = true;
                                      loadUIScheme(value.toString());
                                      setState(() {});
                                    } else {
                                      setState(() {
                                        submitFlag = false;
                                        selectedVillage = value.toString();
                                        villageError = true;
                                        schemeError = true;
                                        schemeItems = [];
                                      });
                                    }
                                    //Do something when changing the item if you want.
                                  },
                                  buttonStyleData: const ButtonStyleData(
                                    height: 40,
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
                              visible: villageError ? true : false,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  s.please_enter_village,
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
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 15),
                              child: Text(
                                s.select_scheme,
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
                                              value: item[s.key_scheme_id]
                                                  .toString(),
                                              child: Text(
                                                item[s.key_scheme_name]
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != "0") {
                                        isLoadingScheme = true;
                                        validate(value.toString());
                                        setState(() {});
                                      } else {
                                        setState(() {
                                          submitFlag = false;
                                          selectedScheme = value.toString();
                                          schemeError = true;
                                        });
                                      }
                                    },
                                    buttonStyleData: const ButtonStyleData(
                                      height: 40,
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
                      Visibility(
                          visible:
                              schemelistWithCount.isNotEmpty ? true : false,
                          child: Container(
                              child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: schemelistWithCount.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return InkWell(
                                        onTap: () async {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WorkList(
                                                        schemeList: '',
                                                        finYear: finList,
                                                        dcode: selectedDistrict,
                                                        bcode: selectedBlock,
                                                        pvcode: selectedVillage,
                                                        scheme:
                                                            schemelistWithCount[
                                                                    index][
                                                                s.key_scheme_id],
                                                        tmccode: '',
                                                        townType: '',
                                                        flag: 'rdpr_online',
                                                        selectedschemeList: [],
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
                                                bottomRight:
                                                    Radius.circular(20),
                                              ),
                                            ),
                                            child: ClipPath(
                                                clipper: ShapeBorderClipper(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20))),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 10,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Text(""),
                                                          decoration:
                                                              BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                      begin: Alignment
                                                                          .topLeft,
                                                                      end: Alignment.topRight,
                                                                      colors: [
                                                                        c.colorPrimary,
                                                                        c.colorAccentverylight
                                                                      ]),
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            20),
                                                                    topRight: Radius
                                                                        .circular(
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
                                                              schemelistWithCount[
                                                                      index][
                                                                  key_scheme_name],
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  color:
                                                                      c.black),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              overflow:
                                                                  TextOverflow
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
                                                                      topRight:
                                                                          Radius.circular(
                                                                              20),
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              0),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              20),
                                                                    )),
                                                            child: Text(
                                                                schemelistWithCount[
                                                                            index]
                                                                        [
                                                                        key_total_count]
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    color: c
                                                                        .primary_text_color2,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 1),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ))));
                                  }))),
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
                              onPressed: () async {
                                await fetchWorksCountSchemeWise();
                                setState(() {});
                                /*Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WorkList(
                                              schemeList: schemeItems,
                                              finYear: finList,
                                              dcode: selectedDistrict,
                                              bcode: selectedBlock,
                                              pvcode: selectedVillage,
                                              scheme: selectedScheme,
                                              tmccode: '',
                                              townType: '',
                                              flag: 'rdpr_online',
                                              selectedschemeList: [],
                                            )));*/
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  void loadUIVillage(String value) async {
    if (await utils.isOnline()) {
      await getVillageList(value);
      setState(() {
        isLoadingB = false;
        blockError = false;
        selectedBlock = value.toString();
      });
    } else {
      utils.customAlertWidet(context, "Error", s.no_internet);
    }
  }

  void loadUIScheme(String value) async {
    if (await utils.isOnline()) {
      if (finList.isNotEmpty) {
        await getSchemeList(value);
        setState(() {
          isLoadingV = false;
          villageError = false;
          selectedVillage = value.toString();
        });
      } else {
        setState(() {
          isLoadingV = false;
          villageError = true;
          selectedVillage = defaultSelectedVillage[s.key_pvcode]!;
          utils.showAlert(context, s.please_select_financial_year);
        });
      }
    } else {
      utils.customAlertWidet(context, "Error", s.no_internet);
    }
  }

  void validate(String value) async {
    setState(() {
      submitFlag = true;
      isLoadingScheme = false;
      schemeError = false;
      selectedScheme = value.toString();
    });
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
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.master_service,
        body: json.encode(encrpted_request));
    print("BlockList_url>>" + url.master_service.toString());
    print("BlockList_request_json>>" + json_request.toString());
    print("BlockList_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("BlockList_response>>" + data);
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
        if (res_jsonArray.length > 0) {
          blockItems = [];
          blockItems.add(defaultSelectedBlock);
          blockItems.addAll(res_jsonArray);
          selectedBlock = defaultSelectedBlock[s.key_bcode]!;
          blockFlag = true;
        }
      } else if (status == s.key_ok && responseValue == s.key_noRecord) {
        Utils().showAlert(context, "No Block Found");
      }
      isLoadingD = false;
      districtError = false;
      setState(() {});
    }
  }

  Future<void> getVillageList(String bcode) async {
    Map json_request = {
      s.key_dcode: selectedDistrict,
      s.key_bcode: bcode,
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
    IOClient _ioClient = new IOClient(_client);
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
      var decrpt_data = utils.decryption(
          enc_data.toString(), prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var responseValue = userData[s.key_response];
      if (status == s.key_ok && responseValue == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        res_jsonArray.sort((a, b) {
          return a[s.key_pvname]
              .toLowerCase()
              .compareTo(b[s.key_pvname].toLowerCase());
        });
        if (res_jsonArray.length > 0) {
          villageItems = [];
          villageItems.add(defaultSelectedVillage);
          villageItems.addAll(res_jsonArray);
          selectedVillage = defaultSelectedVillage[s.key_pvcode]!;
          villageFlag = true;
        }
      } else if (status == s.key_ok && responseValue == s.key_noRecord) {
        Utils().showAlert(context, "No Village Found");
      }
    }
  }

  Future<void> getSchemeList(String pvcode) async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    Map json_request = {};
    if (selectedLevel == 'S') {
      json_request = {
        s.key_dcode: selectedDistrict,
        s.key_bcode: selectedBlock,
        s.key_pvcode: pvcode,
        s.key_fin_year: finList,
        s.key_service_id: s.service_key_scheme_list,
      };
    } else if (selectedLevel == 'D') {
      json_request = {
        s.key_dcode: prefs.getString(s.key_dcode),
        s.key_bcode: selectedBlock,
        s.key_pvcode: pvcode,
        s.key_fin_year: finList,
        s.key_service_id: s.service_key_scheme_list,
      };
    } else if (selectedLevel == 'B') {
      json_request = {
        s.key_dcode: prefs.getString(s.key_dcode),
        s.key_bcode: prefs.getString(s.key_bcode),
        s.key_pvcode: pvcode,
        s.key_fin_year: finList,
        s.key_service_id: s.service_key_scheme_list,
      };
    }

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
            schemeItems = [];
            schemeItems.add(defaultSelectedScheme);
            schemeItems.addAll(res_jsonArray);
            selectedScheme = defaultSelectedScheme[s.key_scheme_id]!;
            schemeFlag = true;
            print("schemeItems>>" + schemeItems.toString());
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
                    fontWeight: FontWeight.w800, fontSize: 13, color: c.grey_8),
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
                          schemeFlag = false;
                          submitFlag = false;
                          selectedVillage = defaultSelectedVillage[s.key_pvcode]!;
                          if(finListchecked.isNotEmpty)
                            {
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
          );
        });
  }

  Future<void> fetchWorksCountSchemeWise() async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    utils.showProgress(context, 1);

    late Map json_request;

    Map work_detail = {
      s.key_fin_year: finList,
      s.key_dcode: selectedDistrict,
      s.key_bcode: selectedBlock,
      s.key_pvcode: [selectedVillage],
      s.key_flag: "1",
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

    print("WorksCountSchemeWise_url>>${url.master_service}");
    print("WorksCountSchemeWise_request_json>> ${jsonEncode(json_request)}");
    print("WorksCountSchemeWise_request_encrpt>>$encrypted_request");

    utils.hideProgress(context);

    if (response.statusCode == 200) {
      String data = response.body;

      print("WorksCountSchemeWise_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("WorksCountSchemeWise Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("WorksCountSchemeWise responceSignature -  $responceSignature");

      print("WorksCountSchemeWise responceData -  $responceData");

      if (responceSignature == responceData) {
        print("WorksCountSchemeWise responceSignature - Token Verified");
        var userData = jsonDecode(data);

        var status = userData[s.key_status];
        var response_value = userData[s.key_response];

        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          print(res_jsonArray);
          schemelistWithCount = [];
          if (res_jsonArray.length > 0) {
            for (int i = 0; i < res_jsonArray.length; i++) {
              Map<String, String> map = {
                key_total_count: res_jsonArray[i][key_total_count].toString(),
                key_scheme_name: res_jsonArray[i][key_scheme_name],
                key_scheme_id: res_jsonArray[i][key_scheme_id].toString()
              };
              schemelistWithCount.add(map);
            }
          }
        } else {
          utils.showAlert(context, s.no_data);
        }
      }
    }
  }
}
