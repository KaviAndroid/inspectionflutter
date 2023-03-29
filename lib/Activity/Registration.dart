// ignore_for_file: avoid_print, file_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspection_flutter_app/Resources/ColorsValue.dart'
    as c;
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

class Registration extends StatefulWidget {
  final registerFlag;
  Registration({this.registerFlag});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  SharedPreferences? prefs;
  var dbHelper = DbHelper();
  var dbClient;

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

  // onResponce Variables
  bool cugValid = false;
  bool islevelValid = false;

  List genderItems = [];
  List levelItems = [];
  List districtItems = [];
  List blockItems = [];
  List designationItems = [];

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
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.registerFlag == 1 ? "Registration" : "Edit Profile"),
        centerTitle: true, // like this!
      ),
      body: SingleChildScrollView(
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
                      showModalBottomSheet(
                          context: context,
                          builder: (builder) => bottomSheet());
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
                child: Column(children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Text(
                          s.regName,
                          style: GoogleFonts.raleway().copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Colors.black),
                        ),
                      ),
                      TextFormField(
                        controller: nameController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                              borderSide: BorderSide(
                                  width: 0.1, color: c.white),
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
                        padding: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Text(
                          s.regNum,
                          style: GoogleFonts.raleway().copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Colors.black),
                        ),
                      ),
                      TextFormField(
                        controller: mobileController,
                        readOnly: widget.registerFlag == 2 || cugValid ? true : false,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                  mobileController.text = '7448944000';
                                  if (Utils()
                                      .isNumberValid(mobileController.text)) {
                                    validateMobile();
                                  } else {
                                    Utils().showToast(
                                        context, "Please Enter Valid Number");
                                  }
                                } else {
                                  Utils().showAlert(context, s.no_internet);
                                }
                              }
                            },
                            icon: Icon(
                              widget.registerFlag == 1 && cugValid
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.arrow_circle_right_outlined,
                              color: c.colorPrimaryDark,
                              size: 28,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 0.1, color: c.white),
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
                          padding: const EdgeInsets.only(top: 10, bottom: 15),
                          child: Text(
                            s.regGender,
                            style: GoogleFonts.raleway().copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                        DropdownButtonFormField2(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 0.1, color: c.white),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: c.colorPrimary),
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                          isExpanded: true,
                          items: cugValid
                              ? genderItems
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item['gender_code'].toString(),
                                        child: Text(
                                          item['gender_name_en'].toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList()
                              : null,
                          validator: (value) {
                            if (value == null) {
                              return 'Please select gender.';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            selectedGender = value.toString();

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
                      ],
                    ),
                  ),
                  Visibility(
                    visible: cugValid ? true : false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: Text(
                            s.regLevel,
                            style: GoogleFonts.raleway().copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                        DropdownButtonFormField2(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 0.1, color: c.white),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: c.colorPrimary),
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                          isExpanded: true,
                          items: cugValid
                              ? levelItems
                                  .map((item) => DropdownMenuItem<String>(
                                        value:
                                            item['localbody_code'].toString(),
                                        child: Text(
                                          item['localbody_name'].toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList()
                              : null,
                          validator: (value) {
                            if (value == null) {
                              return 'Please select level';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            selectedLevel = value.toString();
                            ___loadUI(value.toString(), "L");
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
                      ],
                    ),
                  ),
                  Visibility(
                    visible: islevelValid ? true : false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: Text(
                            s.regDesignation,
                            style: GoogleFonts.raleway().copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                        DropdownButtonFormField2(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 0.1, color: c.white),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: c.colorPrimary),
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                          isExpanded: true,
                          items: designationItems
                              .map((item) => DropdownMenuItem<String>(
                                    value: item['desig_code'].toString(),
                                    child: Text(
                                      item['desig_name'].toString(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select Designation';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            selectedDesignation = value.toString();
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
                      ],
                    ),
                  ),
                  Visibility(
                    visible:
                        cugValid && selectedLevel == "D" || selectedLevel == "B"
                            ? true
                            : false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: Text(
                            s.regDsitrict,
                            style: GoogleFonts.raleway().copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                        DropdownButtonFormField2(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 0.1, color: c.white),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: c.colorPrimary),
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                          isExpanded: true,
                          items: districtItems
                              .map((item) => DropdownMenuItem<String>(
                                    value: item['dcode'].toString(),
                                    child: Text(
                                      item['dname'].toString(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select District';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            //Do something when ch
                            selectedDistrict = value.toString();
                            //anging the item if you want.
                            ___loadUI(value.toString(), "D");
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
                      ],
                    ),
                  ),
                  Visibility(
                    visible: selectedLevel == "B" ? true : false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: Text(
                            s.regBlock,
                            style: GoogleFonts.raleway().copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                        DropdownButtonFormField2(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 0.1, color: c.white),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: c.colorPrimary),
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                          isExpanded: true,
                          items: selectedLevel == "B"
                              ? blockItems
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item['bcode'].toString(),
                                        child: Text(
                                          item['bname'].toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList()
                              : null,
                          validator: (value) {
                            if (value == null) {
                              return 'Please select Block';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            selectedBlock = value.toString();
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
                      ],
                    ),
                  ),
                  Visibility(
                    visible: cugValid ? true : false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: Text(
                            s.regOffice,
                            style: GoogleFonts.raleway().copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                        TextFormField(
                          controller: officeController,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
                          ],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) => value!.isEmpty
                              ? 'Please Enter Office Address'
                              : null,
                          maxLines: 3,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 0.1, color: c.white),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: c.colorPrimary),
                                borderRadius: BorderRadius.circular(10.0)),
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
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: Text(
                            s.regEmail,
                            style: GoogleFonts.raleway().copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.black),
                          ),
                        ),
                        TextFormField(
                          controller: emailController,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[ ]'))
                          ],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) => value!.isEmpty
                              ? 'Please Enter Email'
                              : Utils().isEmailValid(value)
                                  ? 'Enter Valid Email Address'
                                  : null,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 0.1, color: c.white),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: c.colorPrimary),
                                borderRadius: BorderRadius.circular(10.0)),
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  c.colorPrimary),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ))),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              widget.registerFlag == 1 ? goToSave() : goToEdit();
                            }
                          },
                          child: Text(
                            widget.registerFlag == 1 ? s.regSave : s.regEdit,
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

  void TakePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    setState(() {
      _imageFile = File(pickedFile!.path);
    });
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

    setState(() {});
  }

  /// ************************** Load Designation UI *****************************/

  void ___loadUI(String value, String flag) async {
    blockItems = [];
    if (flag == "L") {
      await getDesignationList(value);

      if (value != "S") {
        districtItems = [];
        await getDistrictList();
      }
    } else {
      await getBlockList(value);
    }

    setState(() {
      islevelValid = true;
    });
  }

  /// ************************** Service Call *****************************/

  /// ************************** Mobile Verification API *****************************/

  Future<void> validateMobile() async {
    Map jsonRequest;
    jsonRequest = {
      s.service_id: s.key_verify_mobile_number,
      "mobile_number": mobileController.text
    };
    print("Open_url>>${url.open_service}");
    print("Mobile_verification_request_json>>$jsonRequest");
    http.Response response =
        await http.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("Validation_response>>$data");

      var userData = jsonDecode(data);

      var status = userData[s.status];
      var responseValue = userData[s.response];
      var message = userData[s.message];
      if (status == s.ok && responseValue == s.ok) {
        Utils().showAlert(context, message);
        cugValid = true;
        __initializeBodyUI();
        // Visible Gone
      } else {
        Utils().showAlert(context, message);
      }
    }
  }

  /// ************************** Gender API *****************************/

  Future<void> getGenderList() async {
    Map jsonRequest;
    jsonRequest = {
      s.service_id: s.key_get_profile_gender,
    };
    print(url.open_service);
    http.Response response =
        await http.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var responseData = response.body;
      var data = jsonDecode(responseData);
      print(data);

      var status = data[s.status];
      var responseValue = data[s.response];

      if (status == s.ok && responseValue == s.ok) {
        genderItems = data[s.json_data];
      }
    }
  }

  /// ************************** Level API *****************************/

  Future<void> getStageLevelList() async {
    Map jsonRequest;
    jsonRequest = {
      s.service_id: s.key_get_profile_level,
    };
    http.Response response =
        await http.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var responseData = response.body;
      var data = jsonDecode(responseData);

      var status = data[s.status];
      var responseValue = data[s.response];

      if (status == s.ok && responseValue == s.ok) {
        levelItems = data[s.json_data];
      }
    }
  }

  /// ************************** Designation API *****************************/

  Future<void> getDesignationList(String selectedLevel) async {
    Map jsonRequest;
    jsonRequest = {
      s.service_id: s.key_get_mobile_designation,
      "level_id": selectedLevel,
    };
    http.Response response =
        await http.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var responseData = response.body;
      var data = jsonDecode(responseData);

      var status = data[s.status];
      var responseValue = data[s.response];

      if (status == s.ok && responseValue == s.ok) {
        designationItems = data[s.json_data];
      } else if (status == s.ok && responseValue == s.noRecord) {
        Utils().showAlert(context, "No Designation Found");
      }
    }
  }

  /// ************************** District List API *****************************/

  Future<void> getDistrictList() async {
    Map jsonRequest;
    jsonRequest = {
      s.service_id: s.key_district_list_all,
    };
    http.Response response =
        await http.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var responseData = response.body;
      var data = jsonDecode(responseData);

      var status = data[s.status];
      var responseValue = data[s.response];

      if (status == s.ok && responseValue == s.ok) {
        districtItems = data[s.json_data];
      }
    }
  }

  /// ************************** Block List API *****************************/

  Future<void> getBlockList(String dcode) async {
    Map jsonRequest;
    jsonRequest = {
      s.service_id: s.key_block_list_district_wise,
      s.dcode: dcode,
    };
    http.Response response =
        await http.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var responseData = response.body;
      var data = jsonDecode(responseData);

      var status = data[s.status];
      var responseValue = data[s.response];

      if (status == s.ok && responseValue == s.ok) {
        if (data[s.json_data].length > 0) {
          blockItems = data[s.json_data];
        }
      } else if (status == s.ok && responseValue == s.noRecord) {
        Utils().showAlert(context, "No Block Found");
      }
    }
  }

  /// ************************** Profile API *****************************/

  Future<void> getProfileList() async {}

  /// ************************** Save API *****************************/

  Future<void> goToEdit() async {}

  // ************************** Edit API *****************************/

  Future<void> goToSave() async {
    Map jsonRequest, reqBlock, reqDist;

    jsonRequest = {
      s.service_id: s.key_register,
      s.name: nameController.text.trim(),
      "mobile_number": mobileController.text,
      s.gender: selectedGender.toString(),
      s.level: selectedLevel,
      "designation": selectedDesignation,
      "office_address": officeController.text.trim(),
      s.email: emailController.text.trim(),
    };

    if (selectedLevel == "B") {
      reqBlock = {s.bcode: selectedBlock};
      jsonRequest.addAll(reqBlock);
    } else if (selectedLevel == "D") {
      reqDist = {s.dcode: selectedDistrict};
      jsonRequest.addAll(reqDist);
    }

    // if (selectedLevel == "S") {

    //   http.Response response =
    //       await http.post(url.open_service, body: json.encode(jsonRequest));

    // } else if(selectedLevel == "D") {}

    // if (response.statusCode == 200) {
    //   // If the server did return a 201 CREATED response,
    //   // then parse the JSON.
    //   var responseData = response.body;
    //   var data = jsonDecode(responseData);
    // }
  }
}
