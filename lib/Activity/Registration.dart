// ignore_for_file: avoid_print, file_names, unrelated_type_equality_isSpinnerLoadings, use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
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
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DataBase/DbHelper.dart';
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import '../Utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Login.dart';

class Registration extends StatefulWidget {
  final registerFlag;
  final profileJson;
  Registration({this.registerFlag, this.profileJson});
  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  SharedPreferences? prefs;
  Utils utils = Utils();
  var dbHelper = DbHelper();
  var dbClient;

  late PermissionStatus storagePermission;
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

  //edit values
  String? edit_name;
  String? edit_mobile;
  String? edit_gender;
  String? edit_desig_code;
  String? edit_desig_name;
  String? edit_dcode;
  String? edit_bcode;
  String? edit_office_address;
  String? edit_email;
  Uint8List? edit_profile_image;
  String? edit_profile;

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
    s.key_desig_code: "0",
    s.key_desig_name: s.selectDesignation
  };
  Map<String, String> defaultSelectedBlock = {
    s.key_bcode: "0",
    s.key_bname: s.selectBlock
  };
  Map<String, String> defaultSelectedDistrict = {
    s.key_dcode: "0",
    s.key_dname: s.selectDistrict
  };

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<bool> onWillPop(BuildContext context) async {
    Navigator.of(context, rootNavigator: true).pop(context);
    return true;
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
    dbClient = await dbHelper.db;
    prefs = await SharedPreferences.getInstance();
    widget.registerFlag == 2 ? await getProfileList() : setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    screenWidth = width;
    sceenHeight = height;

    // if (isSpinnerLoading) {
    //   Utils().showSpinner(context, "message", isSpinnerLoading);
    // }

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
                      style: GoogleFonts.getFont('Roboto',
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
                      ignoring: isSpinnerLoading,
                      child: Column(children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15, bottom: 15),
                              child: Text(
                                s.regName,
                                style: GoogleFonts.getFont('Roboto',
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
                                  ? s.please_enter_name
                                  : !Utils().isNameValid(value)
                                      ? s.please_enter_valid_name
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
                                style: GoogleFonts.getFont('Roboto',
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
                                  ? s.please_enter_num
                                  : Utils().isNumberValid(value)
                                      ? null
                                      : s.please_enter_valid_num,
                              maxLength: 10,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                suffixIcon: IconButton(
                                    onPressed: () async {
                                      if (!cugValid) {
                                        if (await Utils().isOnline()) {
                                          // mobileController.text = '7877979787';
                                          if (Utils().isNumberValid(
                                              mobileController.text)) {
                                            isLoadingCUG = true;
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();

                                            validateMobile();
                                            setState(() {});
                                          } else {
                                            Utils().showToast(context,
                                                s.please_enter_valid_num);
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
                                                : widget.registerFlag == 2
                                                    ? null
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
                          visible: cugValid || widget.registerFlag == 2
                              ? true
                              : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 15),
                                child: Text(
                                  s.regGender,
                                  style: GoogleFonts.getFont('Roboto',
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
                                    items: cugValid || widget.registerFlag == 2
                                        ? genderItems
                                            .map((item) =>
                                                DropdownMenuItem<String>(
                                                  value: item[s.key_gender_code]
                                                      .toString(),
                                                  child: Text(
                                                    item[s.key_gender_name_en]
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
                                visible: genderError,
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
                          visible: cugValid || widget.registerFlag == 2
                              ? true
                              : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 15),
                                child: Text(
                                  s.regLevel,
                                  style: GoogleFonts.getFont('Roboto',
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
                                      items: cugValid ||
                                              widget.registerFlag == 2
                                          ? levelItems
                                              .map((item) =>
                                                  DropdownMenuItem<String>(
                                                    value: item[s
                                                            .key_localbody_code]
                                                        .toString(),
                                                    child: Text(
                                                      item[s.key_localbody_name]
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
                                visible: levelError,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    s.please_enter_level,
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
                          visible: islevelValid || widget.registerFlag == 2
                              ? true
                              : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 15),
                                child: Text(
                                  s.regDesignation,
                                  style: GoogleFonts.getFont('Roboto',
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
                                    items: islevelValid ||
                                            widget.registerFlag == 2
                                        ? designationItems
                                            .map(
                                              (item) =>
                                                  DropdownMenuItem<String>(
                                                value: item[s.key_desig_code]
                                                    .toString(),
                                                child: Text(
                                                  item[s.key_desig_name]
                                                      .toString(),
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
                                visible: desigError,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    s.please_enter_desig,
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
                          visible: (cugValid || widget.registerFlag == 2) &&
                                  (selectedLevel == "D" || selectedLevel == "B")
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
                                  style: GoogleFonts.getFont('Roboto',
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
                                          print("val>>" + value.toString());
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
                                visible: districtError,
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
                          visible: selectedLevel == "B" ? true : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 15),
                                child: Text(
                                  s.regBlock,
                                  style: GoogleFonts.getFont('Roboto',
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
                                                  value: item[s.key_bcode]
                                                      .toString(),
                                                  child: Text(
                                                    item[s.key_bname]
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
                                visible: blockError,
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
                          visible: cugValid || widget.registerFlag == 2
                              ? true
                              : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 15),
                                child: Text(
                                  s.regOffice,
                                  style: GoogleFonts.getFont('Roboto',
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
                                    ? s.please_enter_office_address
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
                          visible: cugValid || widget.registerFlag == 2
                              ? true
                              : false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 15),
                                child: Text(
                                  s.regEmail,
                                  style: GoogleFonts.getFont('Roboto',
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
                                        ? s.please_enter_email
                                        : Utils().isEmailValid(value)
                                            ? null
                                            : s.please_enter_email,
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
                          visible: cugValid || widget.registerFlag == 2
                              ? true
                              : false,
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
                                  dropDownValidation();
                                  if (_formKey.currentState!.validate()) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();

                                    if (await utils.isOnline()) {
                                      boolFlag
                                          ? profileImage == null
                                              ? Utils().showAlert(context,
                                                  s.please_upload_image)
                                              : widget.registerFlag == 1
                                                  ? goToSave()
                                                  : goToEdit()
                                          : print("object Error");
                                    } else {
                                      utils.customAlertWidet(
                                          context, "Error", s.no_internet);
                                    }
                                  }
                                },
                                child: Text(
                                  widget.registerFlag == 1
                                      ? s.regSave
                                      : s.regEdit,
                                  style: GoogleFonts.getFont('Roboto',
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
                    Visibility(
                        visible: isSpinnerLoading,
                        child: Utils().showSpinner(context, "Processing"))
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
              )),
          Align(
              alignment: Alignment.bottomCenter,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: c.white,
                child: ClipOval(
                    child: _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : edit_profile_image != null
                            ? Image.memory(
                                edit_profile_image!,
                                // base64.decode(edit_profile_image.toString()),
                                width: screenWidth,
                                height: screenWidth * 0.3,
                                fit: BoxFit.fitWidth,
                              )
                            : Image.asset(
                                imagePath.regUser,
                                color: c.colorPrimary,
                                width: 100,
                              )
                    /*                    child: widget.registerFlag == 1 ?
                    _imageFile == null ? Image.asset(
                            imagePath.regUser,
                            color: c.colorPrimary,
                            width: 100,
                          ) : Image.file(
                            _imageFile!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,)
                        :edit_profile_image==null?Image.asset(
                      imagePath.regUser,
                      color: c.colorPrimary,
                      width: 100,
                    ) :Image.memory(
                      edit_profile_image!,
                      // base64.decode(edit_profile_image.toString()),
                      width: screenWidth,
                      height: screenWidth * 0.3,
                      fit: BoxFit.fitWidth,
                    )*/
                    ),
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

  /// ************************** Check Storage Permission *****************************/

  Future<bool> gotoStorage() async {
    bool flag = false;

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        storagePermission = await Permission.manageExternalStorage.request();
      } else {
        storagePermission = await Permission.storage.request();
      }
      if (storagePermission.isLimited || storagePermission.isGranted) {
        flag = true;
      }
    } else if (Platform.isIOS) {
      flag = true;
    }

    if (!flag) {
      await Utils().showAppSettings(context, s.storage_permission);

      if (Platform.isAndroid) {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        var sdkInt = androidInfo.version.sdkInt;
        if (sdkInt >= 33) {
          storagePermission = await Permission.manageExternalStorage.request();
        } else {
          storagePermission = await Permission.storage.request();
        }
        if (storagePermission.isLimited || storagePermission.isGranted) {
          flag = true;
        }
      } else if (Platform.isIOS) {
        flag = true;
      }
    }

    return flag;
  }

  /// ************************** Image Picker *****************************/

  Future<void> TakePhoto(ImageSource source) async {
    if (source == ImageSource.camera) {
      if (await utils.goToCameraPermission(context)) {
        // final pickedFile = await _picker.pickImage(source: source);
        final pickedFile = await _picker.pickImage(
            source: source, imageQuality: 80, maxHeight: 400, maxWidth: 400);
        if (pickedFile == null) {
          Navigator.pop(context);

          Utils().customAlertWidet(context, "Error", "User Canceled operation");
        } else {
          List<int> imageBytes = await pickedFile.readAsBytes();
          profileImage = base64Encode(imageBytes);
          setState(() {
            _imageFile = File(pickedFile.path);
          });
          Navigator.pop(context);
        }
      }
    } else {
      if (await gotoStorage()) {
        // final pickedFile = await _picker.pickImage(source: source);
        final pickedFile = await _picker.pickImage(
            source: source, imageQuality: 80, maxHeight: 400, maxWidth: 400);
        if (pickedFile == null) {
          Navigator.pop(context);

          Utils().customAlertWidet(context, "Error", "User Canceled operation");
        } else {
          List<int> imageBytes = await pickedFile.readAsBytes();
          profileImage = base64Encode(imageBytes);
          prefs?.setString("UIMG", profileImage!);
          setState(() {
            _imageFile = File(pickedFile.path);
          });
          Navigator.pop(context);
        }
      }
    }
  }

  /// ************************** Registration UI *****************************/

  Future<void> __initializeBodyUI() async {
    // API call For LEVEL etc...

    if (widget.registerFlag == 1 && cugValid) {
      // Call Other Open Services for New Entry
      await getGenderList();
      await getStageLevelList();
    } else if (widget.registerFlag == 2) {
      await mapEditedValues();
    }

    setState(() {
      isLoadingCUG = false;
      if (widget.registerFlag == 2) {
        selectedGender = edit_gender;
        selectedDesignation = edit_desig_code;
        if (selectedLevel == "D") {
          selectedDistrict = edit_dcode;
        } else if (selectedLevel == "B") {
          selectedDistrict = edit_dcode;
          selectedBlock = edit_bcode;
        }
      }
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
    isLoadingDcode = false;
    districtError = false;
    selectedDistrict = value.toString();
    selectedBlock = defaultSelectedBlock['bcode'];
    setState(() {});
  }

  /// ************************** Service Call *****************************/

  /// ************************** Mobile Verification API *****************************/

  Future<void> validateMobile() async {
    Map jsonRequest;
    jsonRequest = {
      s.key_service_id: s.service_key_verify_mobile_number,
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
        Utils().customAlertWidet(context, "Success", message);
        cugValid = true;
        __initializeBodyUI();
        // Visible Gone
      } else {
        isLoadingCUG = false;
        Utils().customAlertWidet(context, "Error", message);
        setState(() {});
      }
    }
  }

  /// ************************** Gender API *****************************/

  Future<void> getGenderList() async {
    Map jsonRequest;
    jsonRequest = {
      s.key_service_id: s.service_key_get_profile_gender,
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
      s.key_service_id: s.service_key_get_profile_level,
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
      print(data);
      var status = data[s.key_status];
      var responseValue = data[s.key_response];
      levelItems = [];
      if (status == s.key_ok && responseValue == s.key_ok) {
        levelItems = data[s.key_json_data];
      }
    }
  }

  /// ************************** Designation API *****************************/

  Future<void> getDesignationList(String selectedLevel) async {
    Map jsonRequest;
    jsonRequest = {
      s.key_service_id: s.service_key_get_mobile_designation,
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
      print(data);
      var status = data[s.key_status];
      var responseValue = data[s.key_response];

      if (status == s.key_ok && responseValue == s.key_ok) {
        List<dynamic> sort_desig = data[s.key_json_data];
        sort_desig.sort((a, b) {
          return a[s.key_desig_name].compareTo(b[s.key_desig_name]);
        });
        designationItems = [];
        designationItems.add(defaultSelectedDesignation);
        designationItems.addAll(sort_desig);
      } else if (status == s.key_ok && responseValue == s.key_noRecord) {
        Utils().showAlert(context, "No Designation Found");
      }
    }
  }

  /// ************************** District List API *****************************/

  Future<void> getDistrictList() async {
    Map jsonRequest;
    jsonRequest = {
      s.key_service_id: s.service_key_district_list_all,
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
        List<dynamic> sort_dist = data[s.key_json_data];
        sort_dist.sort((a, b) {
          return a[s.key_dname].compareTo(b[s.key_dname]);
        });
        districtItems = [];
        districtItems.add(defaultSelectedDistrict);
        districtItems.addAll(sort_dist);
      }
    }
  }

  /// ************************** Block List API *****************************/

  Future<void> getBlockList(String dcode) async {
    Map jsonRequest;
    jsonRequest = {
      s.key_service_id: s.service_key_block_list_district_wise,
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
          List<dynamic> sort_block = data[s.key_json_data];
          sort_block.sort((a, b) {
            return a[s.key_bname].compareTo(b[s.key_bname]);
          });
          blockItems = [];
          blockItems.add(defaultSelectedBlock);
          blockItems.addAll(sort_block);
          print("blockItems>>" + blockItems.toString());
        }
      } else if (status == s.key_ok && responseValue == s.key_noRecord) {
        Utils().showAlert(context, "No Block Found");
      }
    }
  }

  /// ************************** Profile API *****************************/

  Future<void> getProfileList() async {
    List<dynamic> res_jsonArray = widget.profileJson;
    if (res_jsonArray.length > 0) {
      for (int i = 0; i < res_jsonArray.length; i++) {
        edit_name = res_jsonArray[i][s.key_name];
        edit_mobile = res_jsonArray[i][s.key_mobile];
        edit_gender = res_jsonArray[i][s.key_gender];
        selectedLevel = res_jsonArray[i][s.key_level];
        edit_desig_code = res_jsonArray[i][s.key_desig_code].toString();
        edit_dcode = res_jsonArray[i][s.key_dcode].toString();
        edit_bcode = res_jsonArray[i][s.key_bcode].toString();
        edit_office_address = res_jsonArray[i][s.key_office_address];
        edit_email = res_jsonArray[i][s.key_email];
        String profile_image = res_jsonArray[i][s.key_profile_image];

        if (!(profile_image == ("null") || profile_image == (""))) {
          profileImage = profile_image;
          // edit_profile_image = Base64Codec().decode(profile_image);
          // edit_profile_image = base64Decode(profile_image);
          edit_profile_image =
              base64.decode(profile_image.replaceAll(RegExp(r'\s+'), ''));
        }
      }
      await __initializeBodyUI();
      setState(() {
        nameController.text = edit_name!;
        emailController.text = edit_email!;
        officeController.text = edit_office_address!;
        mobileController.text = edit_mobile!;
      });
    }
  }
/*
  Future<void> getProfileList() async {
    setState(() {
      isSpinnerLoading = true;
    });

    var userPassKey = prefs!.getString(s.userPassKey);

    Map jsonRequest = {
      s.key_service_id: s.service_key_work_inspection_profile_list,
    };

    Map encrpted_request = {
      s.key_user_name: prefs?.getString(s.key_user_name),
      s.key_data_content:
          Utils().encryption(jsonEncode(jsonRequest), userPassKey.toString()),
    };

    print(json.encode(encrpted_request));

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service,
        body: json.encode(encrpted_request));

    setState(() {
      isSpinnerLoading = false;
    });
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String responseData = response.body;

      var jsonData = jsonDecode(responseData);

      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = Utils().decryption(enc_data, userPassKey.toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];

      print(status);
      print(response_value);
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        if (res_jsonArray.length > 0) {
          for (int i = 0; i < res_jsonArray.length; i++) {
            edit_name = res_jsonArray[i][s.key_name];
            edit_mobile = res_jsonArray[i][s.key_mobile];
            edit_gender = res_jsonArray[i][s.key_gender];
            edit_level = res_jsonArray[i][s.key_level];
            edit_desig_code = res_jsonArray[i][s.key_desig_code].toString();
            edit_dcode = res_jsonArray[i][s.key_dcode].toString();
            edit_bcode = res_jsonArray[i][s.key_bcode].toString();
            edit_office_address = res_jsonArray[i][s.key_office_address];
            edit_email = res_jsonArray[i][s.key_email];
            String profile_image = res_jsonArray[i][s.key_profile_image];

            if (!(profile_image == ("null") || profile_image == (""))) {
              // edit_profile_image = Base64Codec().decode(profile_image);
              // edit_profile_image = base64Decode(profile_image);
              edit_profile_image=base64.decode(profile_image.replaceAll(RegExp(r'\s+'), ''));

            }
          }
          await __initializeBodyUI();
          setState(() {
            nameController.text = edit_name!;
            emailController.text = edit_email!;
            officeController.text = edit_office_address!;
            mobileController.text = edit_mobile!;
          });
        }
      }
    }
  }
*/

  /// ************************** Edit API *****************************/

  Future<void> goToEdit() async {
    String? key = prefs?.getString(s.userPassKey);
    String? userName = prefs?.getString(s.key_user_name);
    setState(() {
      isSpinnerLoading = true;
      gotToTop();
    });

    Map jsonRequest, reqBlock, reqDist;

    jsonRequest = {
      s.key_service_id: s.service_key_Update_work_inspection_profile,
      s.key_profile_image: profileImage,
      s.key_name: nameController.text.trim(),
      s.service_key_mobile_number: mobileController.text,
      s.key_gender: selectedGender.toString(),
      s.key_level: selectedLevel,
      s.key_designation: selectedDesignation,
      s.key_office_address: officeController.text.trim(),
      s.key_email: emailController.text.trim(),
      if (selectedLevel == "B" || selectedLevel == "D")
        s.key_dcode: selectedDistrict,
      if (selectedLevel == "B") s.key_bcode: selectedBlock,
    };

    // if (selectedLevel == "B") {
    //   reqBlock = {s.key_dcode: selectedDistrict, s.key_bcode: selectedBlock};
    //   jsonRequest.addAll(reqBlock);
    // } else if (selectedLevel == "D") {
    //   reqDist = {s.key_dcode: selectedDistrict};
    //   jsonRequest.addAll(reqDist);
    // }

    print("Prof image >> $profileImage");

    Map encrypted_request = {
      s.key_user_name: userName,
      s.key_data_content: jsonRequest,
    };

    String jsonString = jsonEncode(encrypted_request);

    String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

    String header_token = utils.jwt_Encode(key, userName!, headerSignature);
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $header_token"
    };

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service_jwt,
        body: jsonString, headers: header);

    print("EditProfileData_url>>" + url.main_service_jwt.toString());
    print("EditProfileData_request_json>>" + jsonRequest.toString());
    print("EditProfileData_request_encrpt>> ${jsonEncode(encrypted_request)}");
    setState(() {
      isSpinnerLoading = false;
    });

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;

      print("EditProfileData_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("EditProfileData Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("EditProfileData responceSignature -  $responceSignature");

      print("EditProfileData responceData -  $responceData");

      if (responceSignature == responceData) {
        print("EditProfileData responceSignature - Token Verified");
        var userData = jsonDecode(data);
        var status = userData[s.key_status];
        var response_value = userData[s.key_response];
        if (status == s.key_ok && response_value == s.key_ok) {
          print(status);
          print(response_value);
          dbHelper.deleteAll();
          utils
              .customAlertWidet(context, "Success", s.edit_profile_success)
              .then((value) => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Login()),
                  (route) => false));
        } else {
          utils.customAlertWidet(context, "Error", s.jsonError);
        }
      } else {
        print("EditProfileData responceSignature - Token Not Verified");
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
    }
  }

  // ************************** Save API *****************************/

  Future<void> goToSave() async {
    setState(() {
      isSpinnerLoading = true;
      gotToTop();
    });
    Map jsonRequest, reqBlock, reqDist;

    jsonRequest = {
      s.key_service_id: s.service_key_register,
      s.key_profile_image: profileImage,
      s.key_name: nameController.text.trim(),
      s.service_key_mobile_number: mobileController.text,
      s.key_gender: selectedGender.toString(),
      s.key_level: selectedLevel,
      s.key_designation: selectedDesignation,
      s.key_office_address: officeController.text.trim(),
      s.key_email: emailController.text.trim(),
      if (selectedLevel == "B" || selectedLevel == "D")
        s.key_dcode: selectedDistrict,
      if (selectedLevel == "B") s.key_bcode: selectedBlock,
    };

    // if (selectedLevel == "B") {
    //   reqBlock = {s.key_dcode: selectedDistrict, s.key_bcode: selectedBlock};
    //   jsonRequest.addAll(reqBlock);
    // } else if (selectedLevel == "D") {
    //   reqDist = {s.key_dcode: selectedDistrict};
    //   jsonRequest.addAll(reqDist);
    // }

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
        Utils().customAlertWidet(context, "Success", message);

        setState(() {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => OTPVerification(
                        Flag: "OTP",
                      )),
              (route) => false);
        });
      } else if (status == s.key_ok && responseValue == s.key_fail) {
        Utils().customAlertWidet(context, "Error", message);
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

  /// ************************** Registration UI *****************************/

  Future<void> mapEditedValues() async {
    await getGenderList();
    await getStageLevelList();
    await getDesignationList(selectedLevel.toString());

    if (selectedLevel == "D") {
      await getDistrictList();
    } else if (selectedLevel == "B") {
      await getDistrictList();
      await getBlockList(edit_dcode.toString());
    }
  }
}
