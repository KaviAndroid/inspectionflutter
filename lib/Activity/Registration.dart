// ignore_for_file: avoid_print, file_names, unrelated_type_equality_isSpinnerLoadings, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/OTP_Verification.dart';
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:google_fonts/google_fonts.dart';
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:inspection_flutter_app/Resources/global.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../DataBase/DbHelper.dart';
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import '../Utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Registration extends StatefulWidget {
  final registerFlag;
  Registration({this.registerFlag});
  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  SharedPreferences? prefs;
  var dbHelper = DbHelper();
  ScrollController scrollController = ScrollController();

  //ImagePickers
  File? _imageFile;
  final _picker = ImagePicker();

  // Controller
  TextEditingController mobileController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController officeController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  //Dropdown OnSaved Variables
  String? selectedGender;
  String? selectedLevel;
  String? selectedDistrict;
  String? selectedBlock;
  String? selectedDesignation;
  String? profileImage;

  // onResponce Variables
  bool cugValid = false;
  bool islevelValid = false;
  bool boolFlag = false;

  //Spinner Loading Varibles
  bool isLoadingCUG = false;
  bool isLoadingLevel = false;
  bool isLoadingDcode = false;
  bool isSpinnerLoading = false;

  List genderItems = [];
  List levelItems = [];
  List districtItems = [];
  List blockItems = [];
  List designationItems = [];

  //Error Values

  bool genderError = false;
  bool levelError = false;
  bool desigError = false;
  bool districtError = false;
  bool blockError = false;

  //default Values

  Map<String, String> defaultSelectedDesignation = {
    "desig_code": "0",
    "desig_name": "Select Designation"
  };
  Map<String, String> defaultSelectedBlock = {
    "bcode": "0",
    "bname": "Select Block"
  };
  Map<String, String> defaultSelectedDistrict = {
    "dcode": "0",
    "dname": "Select District"
  };

  @override
  void initState() {
    super.initState();
    initialize();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    mobileController.dispose();
    nameController.dispose();
    officeController.dispose();
    emailController.dispose();
  }

  Future<void> initialize() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    screenWidth = width;
    sceenHeight = height;

    return Scaffold(
      backgroundColor: c.d_grey,
      appBar: AppBar(
        backgroundColor: c.colorPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(context),
        ),
        title: Text(widget.registerFlag == 1 ? "Registration" : "Edit Profile"),
        centerTitle: true, // like this!
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        //over all Container
        child: Column(
          children: [
            __userProfile(),

            ///********************  Edit Button ************************/

            Container(
                margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                child: Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.white,
                      shadowColor: Colors.grey,
                    ),
                    onPressed: () {
                      isSpinnerLoading
                          ? null
                          : showModalBottomSheet(
                              context: context,
                              builder: (builder) => bottomSheet(),
                              isDismissible: true,
                            );
                    },
                    icon: Icon(
                      Icons.edit,
                      color: c.colorPrimaryDark,
                    ),
                    label: Text(
                      s.regEdit,
                      style: GoogleFonts.raleway().copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: c.colorPrimaryDark),
                    ),
                  ),
                )),

            ///********************  Reg Form ************************/

            Form(
              key: _formKey,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Stack(
                  children: [
                    IgnorePointer(
                      ignoring: isSpinnerLoading ? true : false,
                      child: Column(children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 15),
                              child: Text(
                                s.regName,
                                style: GoogleFonts.raleway().copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: Colors.black),
                              ),
                            ),
                            TextFormField(
                              controller: nameController,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) => value!.isEmpty
                                  ? 'Please Enter Name'
                                  : !Utils().isNameValid(value)
                                      ? 'Please Enter Valid Name'
                                      : null,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                filled: true,
                                fillColor: Colors.white,
                                errorBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(width: 1, color: c.red),
                                    borderRadius: BorderRadius.circular(10.0)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(width: 1, color: c.red),
                                    borderRadius: BorderRadius.circular(10.0)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(width: 0.1, color: c.white),
                                    borderRadius: BorderRadius.circular(10.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: c.colorPrimary),
                                    borderRadius: BorderRadius.circular(10.0)),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 15),
                              child: Text(
                                s.regNum,
                                style: GoogleFonts.raleway().copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: Colors.black),
                              ),
                            ),
                            TextFormField(
                              controller: mobileController,
                              readOnly: widget.registerFlag == 2 || cugValid
                                  ? true
                                  : false,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) => value!.isEmpty
                                  ? 'Please Enter Mobile'
                                  : Utils().isNumberValid(value)
                                      ? null
                                      : 'Please Enter Valid Number',
                              maxLength: 10,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                suffixIcon: IconButton(
                                    onPressed: () async {
                                      if (!cugValid) {
                                        if (await Utils().isOnline()) {
                                          mobileController.text = '9025878965';
                                          if (Utils().isNumberValid(
                                              mobileController.text)) {
                                            isLoadingCUG = true;
                                            validateMobile();
                                            setState(() {});
                                          } else {
                                            Utils().showToast(context,
                                                "Please Enter Valid Number");
                                          }
                                        } else {
                                          Utils().showAlert(
                                              context, s.no_internet);
                                        }
                                      }
                                    },
                                    icon: isLoadingCUG
                                        ? SpinKitCircle(
                                            color: c.colorPrimary,
                                            size: 30,
                                            duration: const Duration(
                                                milliseconds: 1200),
                                          )
                                        : Icon(
                                            widget.registerFlag == 1 && cugValid
                                                ? Icons
                                                    .check_circle_outline_rounded
                                                : Icons
                                                    .arrow_circle_right_outlined,
                                            color: c.colorPrimaryDark,
                                            size: 28,
                                          )),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(width: 0.1, color: c.white),
                                    borderRadius: BorderRadius.circular(10.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 1, color: c.colorPrimary),
                                    borderRadius: BorderRadius.circular(10.0)),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ],
                        ),
                        Visibility(
                          visible: cugValid ? true : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 15),
                                child: Text(
                                  s.regGender,
                                  style: GoogleFonts.raleway().copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: Colors.black),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: genderError ? 1 : 0.1,
                                        color: genderError ? c.red : c.white),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    value: selectedGender,
                                    style: const TextStyle(color: Colors.black),
                                    isExpanded: true,
                                    items: cugValid
                                        ? genderItems
                                            .map((item) =>
                                                DropdownMenuItem<String>(
                                                  value: item['gender_code']
                                                      .toString(),
                                                  child: Text(
                                                    item['gender_name_en']
                                                        .toString(),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ))
                                            .toList()
                                        : null,
                                    onChanged: (value) {
                                      setState(() {
                                        genderError = false;
                                        selectedGender = value.toString();
                                      });
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
                                visible: genderError ? true : false,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'Please Select Gender',
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
                          visible: cugValid ? true : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 15),
                                child: Text(
                                  s.regLevel,
                                  style: GoogleFonts.raleway().copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: Colors.black),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: levelError ? 0.1 : 1,
                                        color: levelError ? c.red : c.white),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: IgnorePointer(
                                  ignoring: isLoadingLevel ? true : false,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      style:
                                          const TextStyle(color: Colors.black),
                                      value: selectedLevel,
                                      isExpanded: true,
                                      items: cugValid
                                          ? levelItems
                                              .map((item) =>
                                                  DropdownMenuItem<String>(
                                                    value:
                                                        item['localbody_code']
                                                            .toString(),
                                                    child: Text(
                                                      item['localbody_name']
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ))
                                              .toList()
                                          : null,
                                      onChanged: (value) {
                                        isLoadingLevel = true;
                                        ___loadUIDesignation(value.toString());
                                        setState(() {});
                                      },
                                      buttonStyleData: const ButtonStyleData(
                                        height: 45,
                                        padding: EdgeInsets.only(right: 10),
                                      ),
                                      iconStyleData: IconStyleData(
                                        icon: isLoadingLevel
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
                                visible: levelError ? true : false,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'Please Select Level',
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
                          visible: islevelValid ? true : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 15),
                                child: Text(
                                  s.regDesignation,
                                  style: GoogleFonts.raleway().copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: Colors.black),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: desigError ? 1 : 0.1,
                                        color: desigError ? c.red : c.white),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    value: selectedDesignation,
                                    style: const TextStyle(color: Colors.black),
                                    isExpanded: true,
                                    items: islevelValid
                                        ? designationItems
                                            .map(
                                              (item) =>
                                                  DropdownMenuItem<String>(
                                                value: item['desig_code']
                                                    .toString(),
                                                child: Text(
                                                  item['desig_name'].toString(),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList()
                                        : null,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value != "0") {
                                          desigError = false;
                                        } else {
                                          desigError = true;
                                        }
                                        selectedDesignation = value.toString();
                                      });
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
                                visible: desigError ? true : false,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    'Please Select Designation',
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
                          visible: cugValid && selectedLevel == "D" ||
                                  selectedLevel == "B"
                              ? true
                              : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 15),
                                child: Text(
                                  s.regDsitrict,
                                  style: GoogleFonts.raleway().copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: Colors.black),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: districtError ? 1 : 0.1,
                                        color: districtError ? c.red : c.white),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: IgnorePointer(
                                  ignoring: isLoadingDcode ? true : false,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      style:
                                          const TextStyle(color: Colors.black),
                                      value: selectedDistrict,
                                      isExpanded: true,
                                      items: districtItems
                                          .map((item) =>
                                              DropdownMenuItem<String>(
                                                value: item['dcode'].toString(),
                                                child: Text(
                                                  item['dname'].toString(),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != "0") {
                                          isLoadingDcode = true;
                                          ___loadUIBlock(value.toString());
                                          setState(() {});
                                        } else {
                                          setState(() {
                                            selectedDistrict = value.toString();
                                            districtError = true;
                                            blockItems = [];
                                          });
                                        }
                                      },
                                      buttonStyleData: const ButtonStyleData(
                                        height: 45,
                                        padding: EdgeInsets.only(right: 10),
                                      ),
                                      iconStyleData: IconStyleData(
                                        icon: isLoadingDcode
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
                                    'Please Select District',
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
                          visible: selectedLevel == "B" ? true : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 15),
                                child: Text(
                                  s.regBlock,
                                  style: GoogleFonts.raleway().copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: Colors.black),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: blockError ? 1 : 0.1,
                                        color: blockError ? c.red : c.white),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    value: selectedBlock,
                                    style: const TextStyle(color: Colors.black),
                                    isExpanded: true,
                                    items: selectedLevel == "B"
                                        ? blockItems
                                            .map((item) =>
                                                DropdownMenuItem<String>(
                                                  value:
                                                      item['bcode'].toString(),
                                                  child: Text(
                                                    item['bname'].toString(),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ))
                                            .toList()
                                        : null,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value != "0") {
                                          blockError = false;
                                        } else {
                                          blockError = true;
                                        }
                                        selectedBlock = value.toString();
                                      });
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
                                    'Please Select Block',
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
                          visible: cugValid ? true : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 15),
                                child: Text(
                                  s.regOffice,
                                  style: GoogleFonts.raleway().copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: Colors.black),
                                ),
                              ),
                              TextFormField(
                                controller: officeController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) => value!.isEmpty
                                    ? 'Please Enter Office Address'
                                    : null,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  filled: true,
                                  fillColor: Colors.white,
                                  errorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(width: 1, color: c.red),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(width: 1, color: c.red),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 0.1, color: c.white),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1, color: c.colorPrimary),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: cugValid ? true : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 15),
                                child: Text(
                                  s.regEmail,
                                  style: GoogleFonts.raleway().copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: Colors.black),
                                ),
                              ),
                              TextFormField(
                                controller: emailController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp(r'\s')),
                                ],
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please Enter Email'
                                        : Utils().isEmailValid(value)
                                            ? null
                                            : 'Please Enter Valid Email',
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  filled: true,
                                  fillColor: Colors.white,
                                  errorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(width: 1, color: c.red),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(width: 1, color: c.red),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 0.1, color: c.white),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1, color: c.colorPrimary),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: cugValid ? true : false,
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
                                  dropDownValidation();
                                  if (_formKey.currentState!.validate()) {
                                    boolFlag
                                        ? profileImage == null
                                            ? Utils().showAlert(context,
                                                "Please Upload Profile Image")
                                            : widget.registerFlag == 1
                                                ? goToSave()
                                                : goToEdit()
                                        : print("object Error");
                                  }
                                },
                                child: Text(
                                  widget.registerFlag == 1
                                      ? s.regSave
                                      : s.regEdit,
                                  style: GoogleFonts.raleway().copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: c.white),
                                ),
                              ),
                            ),
                          ),
                        )
                      ]),
                    ),
                    Center(
                      child: isSpinnerLoading
                          ? Column(
                              children: [
                                Container(
                                  height: sceenHeight * 0.15,
                                  width: screenWidth * 0.35,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(80.0),
                                      color: c.grey_7,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(0.0, 1.0), //(x,y)
                                          blurRadius: 6.0,
                                        ),
                                      ]),
                                  child: Stack(
                                    children: [
                                      SpinKitDualRing(
                                        color: c.grey_8,
                                        duration: const Duration(
                                            seconds: 1, milliseconds: 500),
                                        size: 125,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SpinKitPouringHourGlassRefined(
                                            color: c.white,
                                            duration: const Duration(
                                                seconds: 1, milliseconds: 500),
                                            size: 50,
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          Text("Processing...",
                                              style: GoogleFonts.raleway()
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 15,
                                                      color: c.white))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// ************************** User Image *****************************/
  __userProfile() {
    return (SizedBox(
      width: screenWidth,
      height: screenWidth * 0.4,
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: Image.asset(
              imagePath.bg_curve,
              width: screenWidth,
              height: screenWidth * 0.3,
              fit: BoxFit.fill,
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: c.white,
                child: ClipOval(
                    child: _imageFile == null
                        ? Image.asset(
                            imagePath.regUser,
                            color: c.colorPrimary,
                            width: 100,
                          )
                        : Image.file(
                            _imageFile!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          )),
              ))
        ],
      ),
    ));
  }

  /// ************************** Bottom Sheet *****************************/

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: screenWidth,
      margin: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Text(
            "Choose Profile Photo",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.camera),
                onPressed: () {
                  TakePhoto(ImageSource.camera);
                },
                label: Text("Camera"),
              ),
              TextButton.icon(
                icon: Icon(Icons.image),
                onPressed: () {
                  TakePhoto(ImageSource.gallery);
                },
                label: Text("Gallery"),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// ************************** Image Picker *****************************/

  Future<void> TakePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile == null) {
      Navigator.pop(context);

      Utils().showAlert(context, "User Canceled operation");
    } else {
      List<int> imageBytes = await pickedFile.readAsBytes();
      profileImage = base64Encode(imageBytes);
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
    Navigator.pop(context);
  }

  /// ************************** Registration UI *****************************/

  void __initializeBodyUI() async {
    // API call For LEVEL etc...

    if (widget.registerFlag == 1 && cugValid) {
      // Call Other Open Services for New Entry
      await getGenderList();
      await getStageLevelList();
    } else {
      // Call Profile Data for edit
      await getProfileList();
    }

    setState(() {
      isLoadingCUG = false;
    });
  }

  /// ************************** Load Designation UI *****************************/

  void ___loadUIDesignation(String value) async {
    await getDesignationList(value);

    if (value != "S") {
      await getDistrictList();
    }

    setState(() {
      isLoadingLevel = false;
      levelError = false;
      selectedDesignation = defaultSelectedDesignation['desig_code'];
      selectedDistrict = defaultSelectedDistrict['dcode'];
      selectedLevel = value.toString();
      print(designationItems);
      islevelValid = true;
    });
  }

  /// ************************** Load Block UI *****************************/

  void ___loadUIBlock(String value) async {
    await getBlockList(value);
    setState(() {
      isLoadingDcode = false;
      districtError = false;
      selectedDistrict = value.toString();
      selectedBlock = defaultSelectedBlock['bcode'];
    });
  }

  /// ************************** Service Call *****************************/

  /// ************************** Mobile Verification API *****************************/

  Future<void> validateMobile() async {
    Map jsonRequest;
    jsonRequest = {
      s.key_service_id: s.sevice_key_verify_mobile_number,
      "mobile_number": mobileController.text
    };
    print("Open_url>>${url.open_service}");
    print("Mobile_verification_request_json>>$jsonRequest");

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response =
        await _ioClient.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("Validation_response>>$data");

      var userData = jsonDecode(data);

      var status = userData[s.key_status];
      var responseValue = userData[s.key_response];
      var message = userData[s.key_message];
      if (status == s.key_ok && responseValue == s.key_ok) {
        Utils().showAlert(context, message);
        cugValid = true;
        __initializeBodyUI();
        // Visible Gone
      } else {
        isLoadingCUG = false;
        Utils().showAlert(context, message);
        setState(() {});
      }
    }
  }

  /// ************************** Gender API *****************************/

  Future<void> getGenderList() async {
    Map jsonRequest;
    jsonRequest = {
      s.key_service_id: s.sevice_key_get_profile_gender,
    };
    print(url.open_service);
    //Old Way
    // http.Response response =
    //     await http.post(url.open_service, body: json.encode(jsonRequest));

    //New Way With certification
    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response =
        await _ioClient.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var responseData = response.body;
      var data = jsonDecode(responseData);
      print(data);

      var status = data[s.key_status];
      var responseValue = data[s.key_response];

      if (status == s.key_ok && responseValue == s.key_ok) {
        genderItems = data[s.key_json_data];
      }
    }
  }

  /// ************************** Level API *****************************/

  Future<void> getStageLevelList() async {
    Map jsonRequest;
    jsonRequest = {
      s.key_service_id: s.sevice_key_get_profile_level,
    };

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response =
        await _ioClient.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var responseData = response.body;
      var data = jsonDecode(responseData);

      var status = data[s.key_status];
      var responseValue = data[s.key_response];

      if (status == s.key_ok && responseValue == s.key_ok) {
        levelItems = data[s.key_json_data];
      }
    }
  }

  /// ************************** Designation API *****************************/

  Future<void> getDesignationList(String selectedLevel) async {
    Map jsonRequest;
    jsonRequest = {
      s.key_service_id: s.sevice_key_get_mobile_designation,
      "level_id": selectedLevel,
    };

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response =
        await _ioClient.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var responseData = response.body;
      var data = jsonDecode(responseData);

      var status = data[s.key_status];
      var responseValue = data[s.key_response];

      if (status == s.key_ok && responseValue == s.key_ok) {
        designationItems = [];
        designationItems.add(defaultSelectedDesignation);
        designationItems.addAll(data[s.key_json_data]);
      } else if (status == s.key_ok && responseValue == s.key_noRecord) {
        Utils().showAlert(context, "No Designation Found");
      }
    }
  }

  /// ************************** District List API *****************************/

  Future<void> getDistrictList() async {
    Map jsonRequest;
    jsonRequest = {
      s.key_service_id: s.sevice_key_district_list_all,
    };

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response =
        await _ioClient.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var responseData = response.body;
      var data = jsonDecode(responseData);

      var status = data[s.key_status];
      var responseValue = data[s.key_response];

      if (status == s.key_ok && responseValue == s.key_ok) {
        districtItems = [];
        districtItems.add(defaultSelectedDistrict);
        districtItems.addAll(data[s.key_json_data]);
      }
    }
  }

  /// ************************** Block List API *****************************/

  Future<void> getBlockList(String dcode) async {
    Map jsonRequest;
    jsonRequest = {
      s.key_service_id: s.sevice_key_block_list_district_wise,
      s.key_dcode: dcode,
    };

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response =
        await _ioClient.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var responseData = response.body;
      var data = jsonDecode(responseData);

      var status = data[s.key_status];
      var responseValue = data[s.key_response];

      if (status == s.key_ok && responseValue == s.key_ok) {
        if (data[s.key_json_data].length > 0) {
          blockItems = [];
          blockItems.add(defaultSelectedBlock);
          blockItems.addAll(data[s.key_json_data]);
        }
      } else if (status == s.key_ok && responseValue == s.key_noRecord) {
        Utils().showAlert(context, "No Block Found");
      }
    }
  }

  /// ************************** Profile API *****************************/

  Future<void> getProfileList() async {}

  /// ************************** Edit API *****************************/

  Future<void> goToEdit() async {}

  // ************************** Save API *****************************/

  Future<void> goToSave() async {
    setState(() {
      isSpinnerLoading = true;
      gotToTop();
    });
    Map jsonRequest, reqBlock, reqDist;

    jsonRequest = {
      s.key_service_id: s.sevice_key_register,
      s.key_profile_image: profileImage,
      s.key_name: nameController.text.trim(),
      "mobile_number": mobileController.text,
      s.key_gender: selectedGender.toString(),
      s.key_level: selectedLevel,
      "designation": selectedDesignation,
      "office_address": officeController.text.trim(),
      s.key_email: emailController.text.trim(),
    };

    if (selectedLevel == "B") {
      reqBlock = {s.key_dcode: selectedDistrict, s.key_bcode: selectedBlock};
      jsonRequest.addAll(reqBlock);
    } else if (selectedLevel == "D") {
      reqDist = {s.key_dcode: selectedDistrict};
      jsonRequest.addAll(reqDist);
    }
    print('save>>>>>>>>${jsonRequest}');

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response =
        await _ioClient.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var responseData = response.body;
      var data = jsonDecode(responseData);

      print(data);

      var status = data[s.key_status];
      var responseValue = data[s.key_response];
      var message = data[s.key_message];

      setState(() {
        isSpinnerLoading = false;
      });

      if (status == s.key_ok && responseValue == s.key_ok) {
        Utils().showAlert(context, message);

        setState(() {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => OTPVerification(
                        Flag: "register",
                      )),
              (route) => false);
        });
      } else if (status == s.key_ok && responseValue == s.key_fail) {
        Utils().showAlert(context, message);
      }
    }
  }

// DD Validation

  void dropDownValidation() {
    selectedGender == null || selectedGender == '0'
        ? genderError = true
        : genderError = false;
    selectedLevel == null || selectedLevel == '0'
        ? levelError = true
        : levelError = false;
    selectedDesignation == null || selectedDesignation == '0'
        ? desigError = true
        : desigError = false;

    if (selectedLevel == "B") {
      selectedDistrict == null || selectedDistrict == '0'
          ? districtError = true
          : districtError = false;
      selectedBlock == null || selectedBlock == '0'
          ? blockError = true
          : blockError = false;

      genderError || levelError || desigError || districtError || blockError
          ? boolFlag = false
          : boolFlag = true;
    } else if (selectedLevel == "D") {
      selectedDistrict == null || selectedDistrict == '0'
          ? districtError = true
          : districtError = false;

      genderError || levelError || desigError || districtError
          ? boolFlag = false
          : boolFlag = true;
    } else if (selectedLevel == "S") {
      genderError || levelError || desigError
          ? boolFlag = false
          : boolFlag = true;
    }
    print("&&&&&&&&&&&&&&&&");
    print(boolFlag);
    setState(() {});
  }

// Scroll Top

  void gotToTop() {
    scrollController.animateTo(
        //go to top of scroll
        0, //scroll offset to go
        duration: Duration(milliseconds: 500), //duration of scroll
        curve: Curves.fastOutSlowIn //scroll type
        );
  }
}
