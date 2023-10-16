// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, prefer_interpolation_to_compose_strings, use_build_context_synchronously, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:InspectionAppNew/Activity/OtherWorks_Save.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:InspectionAppNew/Resources/Strings.dart' as s;
import 'package:InspectionAppNew/Resources/ColorsValue.dart' as c;
import 'package:InspectionAppNew/Resources/url.dart' as url;
import '../DataBase/DbHelper.dart';
import '../Utils/utils.dart';

class OtherWorksRural extends StatefulWidget {
  @override
  State<OtherWorksRural> createState() => OtherWorksRuralState();
}

class OtherWorksRuralState extends State<OtherWorksRural> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  List finYearItems = [];
  List districtItems = [];
  List blockItems = [];
  List villageItems = [];
  List categoryItems = [];

  String selectedFinYear = "";
  String selectedDistrict = "";
  String selectedBlock = "";
  String selectedVillage = "";
  String selectedCategory = "";
  String selectedLevel = "";

  bool isLoadingFinYear = false;
  bool isLoadingD = false;
  bool isLoadingB = false;
  bool isLoadingV = false;
  bool isLoadingCategory = false;
  bool finYearError = false;
  bool districtError = false;
  bool blockError = false;
  bool villageError = false;
  bool categoryError = false;
  bool submitFlag = false;
  bool isSpinnerLoading = false;

  bool blockFlag = false;
  bool districtFlag = false;
  bool villageFlag = false;
  bool categoryFlag = false;

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

  Map<String, String> defaultSelectedCategory = {
    s.key_other_work_category_id: "0",
    s.key_other_work_category_name: s.select_other
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
    print(list.toString());
    finYearItems.add(defaultSelectedFinYear);
    finYearItems.addAll(list);
    selectedFinYear = defaultSelectedFinYear[s.key_fin_year]!;
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
                              decoration: BoxDecoration(
                                  color: c.grey_out,
                                  border: Border.all(
                                      width: finYearError ? 1 : 0.1,
                                      color: finYearError ? c.red : c.grey_10),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: IgnorePointer(
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
                                                  fontSize: 14,
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
                                        categoryError = true;
                                        categoryItems = [];
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
                                          categoryError = true;
                                          categoryItems = [];
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
                              ),
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
                                                  fontSize: 14,
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
                                        categoryError = true;
                                        villageItems = [];
                                        categoryItems = [];
                                        setState(() {});
                                      } else {
                                        setState(() {
                                          submitFlag = false;
                                          selectedDistrict = value.toString();
                                          districtError = true;
                                          blockError = true;
                                          villageError = true;
                                          categoryError = true;
                                          blockItems = [];
                                          villageItems = [];
                                          categoryItems = [];
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
                                  onChanged: (value) {
                                    if (value != "0") {
                                      submitFlag = false;
                                      isLoadingB = true;
                                      loadUIVillage(value.toString());
                                      categoryError = true;
                                      categoryItems = [];
                                      setState(() {});
                                    } else {
                                      setState(() {
                                        submitFlag = false;
                                        selectedBlock = value.toString();
                                        blockError = true;
                                        villageError = true;
                                        villageItems = [];
                                        categoryError = true;
                                        categoryItems = [];
                                      });
                                    }
                                    //Do something when changing the item if you want.
                                  },
                                  buttonStyleData: const ButtonStyleData(
                                    height: 45,
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
                                                fontSize: 14,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != "0") {
                                      submitFlag = false;
                                      isLoadingV = true;
                                      loadUICategory(value.toString());
                                      setState(() {});
                                    } else {
                                      setState(() {
                                        submitFlag = false;
                                        selectedVillage = value.toString();
                                        villageError = true;
                                        categoryError = true;
                                        categoryItems = [];
                                      });
                                    }
                                    //Do something when changing the item if you want.
                                  },
                                  buttonStyleData: const ButtonStyleData(
                                    height: 45,
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
                        visible: categoryFlag ? true : false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 15),
                              child: Text(
                                s.select_other,
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
                                      width: categoryError ? 1 : 0.1,
                                      color: categoryError ? c.red : c.grey_10),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: IgnorePointer(
                                ignoring: isLoadingCategory ? true : false,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    style: const TextStyle(color: Colors.black),
                                    value: selectedCategory,
                                    isExpanded: true,
                                    items: categoryItems
                                        .map((item) => DropdownMenuItem<String>(
                                              value: item[s
                                                      .key_other_work_category_id]
                                                  .toString(),
                                              child: Text(
                                                item[s.key_other_work_category_name]
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != "0") {
                                        isLoadingCategory = true;
                                        validate(value.toString());
                                        setState(() {});
                                      } else {
                                        setState(() {
                                          submitFlag = false;
                                          selectedCategory = value.toString();
                                          categoryError = true;
                                        });
                                      }
                                    },
                                    buttonStyleData: const ButtonStyleData(
                                      height: 45,
                                      padding: EdgeInsets.only(right: 10),
                                    ),
                                    iconStyleData: IconStyleData(
                                      icon: isLoadingCategory
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
                              visible: categoryError ? true : false,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  s.please_enter_category,
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OtherWork_Save(
                                              category: selectedCategory,
                                              finYear: selectedFinYear,
                                              dcode: selectedDistrict,
                                              bcode: selectedBlock,
                                              pvcode: selectedVillage,
                                              flag: 'other',
                                              tmccode: "",
                                              townType: "",
                                              selectedworkList: [],
                                              imagelist: [],
                                              onoff_type: "",
                                            )));
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

  // *************************** UI Design starts here *************************** //

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

  void loadUICategory(String value) async {
    if (await utils.isOnline()) {
      if (selectedFinYear != s.select_financial_year) {
        await getCategoryList(value);
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
      isLoadingCategory = false;
      categoryError = false;
      selectedCategory = value.toString();
    });
  }

  // *************************** UI Design ends here *************************** //

  // *************************** API Call starts here *************************** //

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
        utils.customAlertWidet(context, "Error", "No Block Found");
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
        utils.customAlertWidet(context, "Error", "No Village Found");
      }
    }
  }

  // *************************** API Call Ends here *************************** //

  // *************************** DB Call *************************** //

  Future<void> getCategoryList(String value) async {
    setState(() {
      isSpinnerLoading = true;
    });

    List<dynamic> categoryList =
        await dbClient.rawQuery("SELECT * FROM ${s.table_OtherCategory} ");

    categoryItems = [];
    categoryItems.add(defaultSelectedCategory);
    categoryItems.addAll(categoryList);

    selectedCategory = defaultSelectedCategory[s.key_other_work_category_id]!;
    categoryFlag = true;

    print("Category Items >>>");
    print(categoryItems);
    setState(() {});
  }
}
