import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:InspectionAppNew/Resources/Strings.dart' as s;
import 'package:InspectionAppNew/Resources/url.dart' as url;
import 'package:InspectionAppNew/Resources/ImagePath.dart' as imagePath;
import 'package:shared_preferences/shared_preferences.dart';
import '../DataBase/DbHelper.dart';
import '../Utils/utils.dart';
import '../Resources/ColorsValue.dart' as c;
import 'OtherWorks_Save.dart';

class OtherWorkUrban extends StatefulWidget {
  @override
  State<OtherWorkUrban> createState() => _OtherWorkUrbanState();
}

class _OtherWorkUrbanState extends State<OtherWorkUrban> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  List finYearList = [];
  List schemeList = [];
  List districtItems = [];
  List townList = [];
  List municipalityList = [];
  List corporationList = [];
  List tmcItems = [];
  String selectedLevel = "";
  String selectedScheme = "";
  String selectedFinyear = "";
  String selectedDistrict = "";
  String selectedTMC = "";
  bool submitFlag = false;
  bool schemeFlag = false;

  bool districtError = false;
  bool tmcError = false;
  bool districtFlag = false;
  bool isLoadingD = false;
  bool isLoadingTMC = false;
  bool townActive = true;
  bool munActive = false;
  bool corpActive = false;
  String town_type = "T";
  String onOffType = "";
  int finCount = 0;
  int schemeCount = 0;
  int selectedIndex = 0;

  Map<String, String> defaultSelectedDistrict = {
    s.key_dcode: "0",
    s.key_dname: s.selectDistrict
  };
  Map<String, String> defaultSelectedBlock = {
    s.key_bcode: "0",
    s.key_bname: s.selectBlock
  };
  Map<String, String> defaultSelectedVillage = {
    s.key_pvcode: "0",
    s.key_pvname: s.select_village
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
    onOffType = prefs.getString(s.onOffType)!;

    if (onOffType == "online") {
      finCount = 1;
      schemeCount = 1;
    } else {
      finCount = 2;
      schemeCount = 5;
    }
    List<Map> list =
        await dbClient.rawQuery('SELECT * FROM ' + s.table_FinancialYear);
    print(list.toString());
    for (int i = 0; i < list.length; i++) {
      Map<String, String> map = {
        s.flag: "0",
        s.key_fin_year: list[i][s.key_fin_year]
      };
      finYearList.add(map);
    }
    List<Map> listother =
        await dbClient.rawQuery('SELECT * FROM ' + s.table_OtherCategory);
    print(listother.toString());
    for (int i = 0; i < listother.length; i++) {
      Map<String, String> map = {
        s.flag: "0",
        s.key_other_work_category_id: listother[i]
            [s.key_other_work_category_id],
        s.key_other_work_category_name: listother[i]
            [s.key_other_work_category_name]
      };
      schemeList.add(map);
    }

    selectedLevel = prefs.getString(s.key_level)!;

    print("finYearList>>" + finYearList.toString());
    if (selectedLevel == 'S') {
      districtFlag = true;
      List<Map> list =
          await dbClient.rawQuery('SELECT * FROM ' + s.table_District);
      print(list.toString());
      districtItems.add(defaultSelectedDistrict);
      districtItems.addAll(list);
      selectedDistrict = defaultSelectedDistrict[s.key_dcode]!;
      selectedTMC = "";
    } else {
      selectedDistrict = prefs.getString(s.key_dcode).toString();
      districtFlag = false;
      townList = await dbClient.rawQuery('SELECT * FROM ' + s.table_TownList);
      municipalityList =
          await dbClient.rawQuery('SELECT * FROM ' + s.table_Municipality);
      corporationList =
          await dbClient.rawQuery('SELECT * FROM ' + s.table_Corporation);
      tmcItems.add(defaultSelectedT);
      tmcItems.addAll(townList);
      selectedTMC = defaultSelectedT[s.key_townpanchayat_id]!;
      townActive = true;
      town_type = "T";
      munActive = false;
      corpActive = false;
    }

    setState(() {});
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context, rootNavigator: true).pop(context);
    return true;
  }

  _urban_Card_Design(String title, String twn_type, int index, bool town_active,
      bool mun_active, bool corp_active) {
    return InkWell(
      onTap: () async {
        setState(() {
          town_type = twn_type;
          townActive = town_active;
          munActive = mun_active;
          corpActive = corp_active;
          selectedIndex = index;

          schemeFlag = false;
          selectedScheme = "";
          for (int i = 0; i < schemeList.length; i++) {
            schemeList[i][s.flag] == "1"
                ? schemeList[i][s.flag] = "0"
                : schemeList[i][s.flag] = "0";
          }

          selectedFinyear = "";
          for (int i = 0; i < finYearList.length; i++) {
            finYearList[i][s.flag] == "1"
                ? finYearList[i][s.flag] = "0"
                : finYearList[i][s.flag] = "0";
          }
          submitFlag = false;
        });
        await loadTMC();
      },
      child: Container(
          height: 30,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
              color: selectedIndex == index ? c.colorAccentlight : c.white,
              border: Border.all(
                  width: selectedIndex == index ? 0 : 2, color: c.colorPrimary),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 2.0,
                ),
              ]),
          child: Row(children: [
            SizedBox(
              width: 10,
            ),
            Image.asset(
              imagePath.radio,
              color: selectedIndex == index ? c.white : c.grey_5,
              width: 15,
              height: 15,
            ),
            SizedBox(
              width: 10,
            ),
            Text(title,
                style: GoogleFonts.getFont('Roboto',
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: selectedIndex == index ? c.white : c.grey_6)),
          ])),
    );
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
                    child: Text(s.filter_work_list,
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
                        visible: districtFlag,
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
                                                style: GoogleFonts.getFont(
                                                    'Roboto',
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 12,
                                                    color: c.grey_8),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != "0") {
                                        isLoadingD = true;
                                        selectedDistrict = value.toString();
                                        loadTMCBlock();
                                        setState(() {});
                                      } else {
                                        setState(() {
                                          selectedDistrict = value.toString();
                                          districtError = true;
                                        });
                                      }
                                      setState(() {
                                        schemeFlag = false;
                                        selectedScheme = "";
                                        for (int i = 0;
                                            i < schemeList.length;
                                            i++) {
                                          schemeList[i][s.flag] == "1"
                                              ? schemeList[i][s.flag] = "0"
                                              : schemeList[i][s.flag] = "0";
                                        }

                                        selectedFinyear = "";
                                        for (int i = 0;
                                            i < finYearList.length;
                                            i++) {
                                          finYearList[i][s.flag] == "1"
                                              ? finYearList[i][s.flag] = "0"
                                              : finYearList[i][s.flag] = "0";
                                        }

                                        submitFlag = false;
                                      });
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
                      Container(
                        margin: EdgeInsets.only(top: 10, bottom: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(0),
                              child: Text(s.fetch_tmc_work,
                                  style: GoogleFonts.getFont('Roboto',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: c.grey_8)),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(50, 0, 50, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _urban_Card_Design(s.town_panchayat, "T", 0,
                                      true, false, false),
                                  _urban_Card_Design(s.municipality, "M", 1,
                                      false, true, false),
                                  _urban_Card_Design(s.corporation, "C", 2,
                                      false, false, true),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            child: Text(
                              town_type == "T"
                                  ? s.select_town
                                  : town_type == "M"
                                      ? s.select_municipality
                                      : town_type == "C"
                                          ? s.select_corporation
                                          : s.select_town,
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
                                    width: tmcError ? 1 : 0.1,
                                    color: tmcError ? c.red : c.grey_10),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: IgnorePointer(
                              ignoring: isLoadingTMC ? true : false,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  style: const TextStyle(color: Colors.black),
                                  value: selectedTMC,
                                  isExpanded: true,
                                  items: tmcItems
                                      .map((item) => DropdownMenuItem<String>(
                                            value: town_type == "T"
                                                ? item[s.key_townpanchayat_id]
                                                    .toString()
                                                : town_type == "M"
                                                    ? item[s.key_municipality_id]
                                                        .toString()
                                                    : town_type == "C"
                                                        ? item[s.key_corporation_id]
                                                            .toString()
                                                        : item[s.key_townpanchayat_id]
                                                            .toString(),
                                            child: Text(
                                              town_type == "T"
                                                  ? item[s.key_townpanchayat_name]
                                                      .toString()
                                                  : town_type == "M"
                                                      ? item[s.key_municipality_name]
                                                          .toString()
                                                      : town_type == "C"
                                                          ? item[s.key_corporation_name]
                                                              .toString()
                                                          : item[s.key_townpanchayat_name]
                                                              .toString(),
                                              style: GoogleFonts.getFont(
                                                  'Roboto',
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 12,
                                                  color: c.grey_8),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != "0") {
                                      tmcError = false;
                                      isLoadingTMC = false;
                                      selectedTMC = value.toString();
                                      setState(() {});
                                    } else {
                                      setState(() {
                                        submitFlag = false;
                                        selectedTMC = value.toString();
                                        tmcError = true;
                                      });
                                    }
                                    setState(() {
                                      schemeFlag = false;
                                      selectedScheme = "";
                                      for (int i = 0;
                                          i < schemeList.length;
                                          i++) {
                                        schemeList[i][s.flag] == "1"
                                            ? schemeList[i][s.flag] = "0"
                                            : schemeList[i][s.flag] = "0";
                                      }

                                      selectedFinyear = "";
                                      for (int i = 0;
                                          i < finYearList.length;
                                          i++) {
                                        finYearList[i][s.flag] == "1"
                                            ? finYearList[i][s.flag] = "0"
                                            : finYearList[i][s.flag] = "0";
                                      }

                                      submitFlag = false;
                                    });
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
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5.0),
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
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: RichText(
                          text: new TextSpan(
                            // Note: Styles for TextSpans must be explicitly defined.
                            // Child text spans will inherit styles from parent
                            style: GoogleFonts.getFont('Roboto',
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: c.grey_8),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: s.select_financial_year,
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: c.grey_8)),
                              new TextSpan(
                                  text: onOffType == "online"
                                      ? " (Any One)"
                                      : "(Any Two)",
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: c.subscription_type_red_color)),
                            ],
                          ),
                        ),
                      ),
                      GridView.count(
                          shrinkWrap: true,
                          primary: false,
                          crossAxisCount: 3,
                          childAspectRatio: (1 / .4),
                          children: List.generate(
                              finYearList == null ? 0 : finYearList.length,
                              (index) {
                            return Column(children: [
                              Container(
                                  height: 30,
                                  margin: const EdgeInsets.all(5),
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      color: finYearList[index][s.flag] == "1"
                                          ? c.colorAccentlight
                                          : c.white,
                                      border: Border.all(
                                          width:
                                              finYearList[index][s.flag] == "1"
                                                  ? 1
                                                  : 1,
                                          color:
                                              finYearList[index][s.flag] == "1"
                                                  ? c.colorPrimary
                                                  : c.grey),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(0.0, 1.0), //(x,y)
                                          blurRadius: 2.0,
                                        ),
                                      ]),
                                  child: InkWell(
                                    onTap: () {
                                      if (selectedTMC != null &&
                                          selectedTMC != "0" &&
                                          selectedTMC != "") {
                                        if (finYearList[index][s.flag] == "1") {
                                          finYearList[index][s.flag] = "0";
                                          selectedFinyear = "";
                                          schemeFlag = false;
                                          selectedScheme = "";
                                          for (int i = 0;
                                              i < schemeList.length;
                                              i++) {
                                            schemeList[i][s.flag] == "1"
                                                ? schemeList[i][s.flag] = "0"
                                                : schemeList[i][s.flag] = "0";
                                          }
                                        } else {
                                          finYearList[index][s.flag] = "1";
                                          for (int i = 0;
                                              i < finYearList.length;
                                              i++) {
                                            if (i != index) {
                                              finYearList[i][s.flag] == "1"
                                                  ? finYearList[i][s.flag] = "0"
                                                  : finYearList[i][s.flag] =
                                                      "0";
                                            }
                                          }

                                          selectedFinyear = finYearList[index]
                                              [s.key_fin_year];
                                          schemeFlag = true;
                                        }
                                        print("Fin>>" +
                                            selectedFinyear.toString());
                                      } else {
                                        utils.showAlert(
                                            context, s.first_select_tmc);
                                      }
                                      setState(() {});
                                    },
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Image.asset(
                                            finYearList[index][s.flag] == "0"
                                                ? imagePath.radio
                                                : imagePath.tick,
                                            color: finYearList[index][s.flag] ==
                                                    "0"
                                                ? c.grey_5
                                                : null,
                                            width: 15,
                                            height: 15,
                                          ),
                                          Text(
                                              finYearList[index][s.key_fin_year]
                                                  .toString(),
                                              style: GoogleFonts.getFont(
                                                  'Roboto',
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 11,
                                                  color: finYearList[index]
                                                              [s.flag] ==
                                                          "1"
                                                      ? c.white
                                                      : c.grey_6)),
                                        ]),
                                  )),
                            ]);
                          })),
                      Visibility(
                        visible: schemeFlag,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: RichText(
                            text: new TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: GoogleFonts.getFont('Roboto',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: c.grey_8),
                              children: <TextSpan>[
                                new TextSpan(
                                    text: s.select_other,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: c.grey_8)),
                                new TextSpan(
                                    text: onOffType == "online"
                                        ? " (Any One)"
                                        : "",
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: c.subscription_type_red_color)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: schemeFlag,
                        child: GridView.count(
                            shrinkWrap: true,
                            primary: false,
                            crossAxisCount: 1,
                            childAspectRatio: (1 / .13),
                            children: List.generate(
                                schemeList == null ? 0 : schemeList.length,
                                (index) {
                              return Column(children: [
                                Container(
                                    height: 30,
                                    margin: const EdgeInsets.all(5),
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        color: schemeList[index][s.flag] == "1"
                                            ? c.colorAccentlight
                                            : c.white,
                                        border: Border.all(
                                            width:
                                                schemeList[index][s.flag] == "1"
                                                    ? 1
                                                    : 1,
                                            color:
                                                schemeList[index][s.flag] == "1"
                                                    ? c.colorPrimary
                                                    : c.grey),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 2.0,
                                          ),
                                        ]),
                                    child: InkWell(
                                      onTap: () {
                                        if (schemeList[index][s.flag] == "1") {
                                          schemeList[index][s.flag] = "0";
                                          selectedScheme = "";
                                          submitFlag = false;
                                        } else {
                                          schemeList[index][s.flag] = "1";
                                          for (int i = 0;
                                              i < schemeList.length;
                                              i++) {
                                            if (i != index) {
                                              schemeList[i][s.flag] == "1"
                                                  ? schemeList[i][s.flag] = "0"
                                                  : schemeList[i][s.flag] = "0";
                                            }
                                          }

                                          selectedScheme = schemeList[index]
                                              [s.key_other_work_category_id];
                                          submitFlag = true;
                                        }
                                        print("scheme>>" +
                                            selectedScheme.toString());
                                        setState(() {});
                                      },
                                      child: Row(children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Image.asset(
                                          schemeList[index][s.flag] == "0"
                                              ? imagePath.radio
                                              : imagePath.tick,
                                          color:
                                              schemeList[index][s.flag] == "0"
                                                  ? c.grey_5
                                                  : null,
                                          width: 15,
                                          height: 15,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                            schemeList[index][s
                                                    .key_other_work_category_name]
                                                .toString(),
                                            style: GoogleFonts.getFont('Roboto',
                                                fontWeight: FontWeight.w800,
                                                fontSize: 11,
                                                color: schemeList[index]
                                                            [s.flag] ==
                                                        "1"
                                                    ? c.white
                                                    : c.grey_6)),
                                      ]),
                                    )),
                              ]);
                            })),
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
                                              category: selectedScheme,
                                              finYear: selectedFinyear,
                                              dcode: selectedDistrict,
                                              townType: town_type,
                                              tmccode: selectedTMC,
                                              onoff_type: onOffType,
                                              flag: 'other',
                                              pvcode: "",
                                              bcode: "",
                                              imagelist: [],
                                              selectedworkList: [],
                                            )));
                              },
                              child: Text(
                                onOffType == "online" ? s.submit : s.download,
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

  Future<void> loadTMCBlock() async {
    if (await utils.isOnline()) {
      await getTownList();
      await getMunicipalityList();
      await getCorporationList();
      townActive = true;
      town_type = "T";
      munActive = false;
      corpActive = false;
      isLoadingD = false;
      await loadTMC();
      setState(() {});
    } else {
      utils.customAlertWidet(context, "Error", s.no_internet);
    }
  }

  Future<void> getTownList() async {
    utils.showProgress(context, 1);
    Map json_request = {
      s.key_service_id: s.service_key_townpanchayat_list_district_wise,
      s.key_dcode: selectedDistrict,
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
    print("TownList_url>>" + url.master_service.toString());
    print("TownList_request_json>>" + json_request.toString());
    print("TownList_request_encrpt>>" + encrpted_request.toString());
    utils.hideProgress(context);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("TownList_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data =
          utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      townList = [];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        for (var item in res_jsonArray) {
          item[s.key_townpanchayat_name] =
              item[s.key_townpanchayat_name].toString().replaceAll("'", "\'");
        }
        res_jsonArray.sort((a, b) {
          return a[s.key_townpanchayat_name]
              .toLowerCase()
              .compareTo(b[s.key_townpanchayat_name].toLowerCase());
        });
        if (res_jsonArray.length > 0) {
          for (int i = 0; i < res_jsonArray.length; i++) {
            townList.add(res_jsonArray[i]);
          }
          print("townList >>" + townList.toString());
        }
      }
    }
  }

  Future<void> getMunicipalityList() async {
    utils.showProgress(context, 1);
    Map json_request = {
      s.key_service_id: s.service_key_municipality_list_district_wise,
      s.key_dcode: selectedDistrict,
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
    print("MunicipalityList_url>>" + url.master_service.toString());
    print("MunicipalityList_request_json>>" + json_request.toString());
    print("MunicipalityList_request_encrpt>>" + encrpted_request.toString());
    utils.hideProgress(context);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("MunicipalityList_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data =
          utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      municipalityList = [];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        for (var item in res_jsonArray) {
          item[s.key_municipality_name] =
              item[s.key_municipality_name].toString().replaceAll("'", "\'");
        }
        res_jsonArray.sort((a, b) {
          return a[s.key_municipality_name]
              .toLowerCase()
              .compareTo(b[s.key_municipality_name].toLowerCase());
        });
        if (res_jsonArray.length > 0) {
          for (int i = 0; i < res_jsonArray.length; i++) {
            municipalityList.add(res_jsonArray[i]);
          }
          print("municipalityList >>" + municipalityList.toString());
        }
      }
    }
  }

  Future<void> getCorporationList() async {
    utils.showProgress(context, 1);
    Map json_request = {
      s.key_service_id: s.service_key_corporation_list_district_wise,
      s.key_dcode: selectedDistrict,
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
    print("CorporationList_url>>" + url.master_service.toString());
    print("CorporationList_request_json>>" + json_request.toString());
    print("CorporationList_request_encrpt>>" + encrpted_request.toString());
    utils.hideProgress(context);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("CorporationList_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data =
          utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      corporationList = [];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        for (var item in res_jsonArray) {
          item[s.key_corporation_name] =
              item[s.key_corporation_name].toString().replaceAll("'", "\'");
        }
        res_jsonArray.sort((a, b) {
          return a[s.key_corporation_name]
              .toLowerCase()
              .compareTo(b[s.key_corporation_name].toLowerCase());
        });
        if (res_jsonArray.length > 0) {
          for (int i = 0; i < res_jsonArray.length; i++) {
            corporationList.add(res_jsonArray[i]);
          }
          print("corporationList >>" + corporationList.toString());
        }
      }
    }
  }

  Future<void> loadTMC() async {
    tmcItems = [];
    if (town_type == "T") {
      tmcItems.add(defaultSelectedT);
      tmcItems.addAll(townList);
      selectedTMC = defaultSelectedT[s.key_townpanchayat_id]!;
    } else if (town_type == "M") {
      tmcItems.add(defaultSelectedM);
      tmcItems.addAll(municipalityList);
      selectedTMC = defaultSelectedM[s.key_municipality_id]!;
    } else if (town_type == "C") {
      tmcItems.add(defaultSelectedC);
      tmcItems.addAll(corporationList);
      selectedTMC = defaultSelectedC[s.key_corporation_id]!;
    }
  }
}
