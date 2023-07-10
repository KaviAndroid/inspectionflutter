// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, prefer_interpolation_to_compose_strings, use_build_context_synchronously, avoid_unnecessary_containers, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// import 'package:dio/dio.dart';
// import 'package:dio/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/ForgotPassword.dart';
import 'package:inspection_flutter_app/Activity/OTP_Verification.dart';
import 'package:inspection_flutter_app/Activity/Registration.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../DataBase/DbHelper.dart';
import '../Utils/utils.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  Utils utils = Utils();
  TextEditingController user_name = TextEditingController();
  TextEditingController user_password = TextEditingController();
  String userPassKey = "";
  String userDecriptKey = "";
  String version = "";
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  bool _passwordVisible = false;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    _passwordVisible = false;
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    version = s.version + " " + await utils.getVersion();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: c.colorAccentverylight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              transform:
                                  Matrix4.translationValues(0.0, -60.0, 0.0),
                              height: 200,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: c.colorPrimary,
                                  ),
                                  color: c.colorPrimary,
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(200),
                                      bottomRight: Radius.circular(200))),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 40),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                "LOGIN",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 18),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 110, 0, 0),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Align(
                                  alignment: AlignmentDirectional.topCenter,
                                  child: Image.asset(
                                    imagePath.logo,
                                    height: 60,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                            child: Align(
                              alignment: AlignmentDirectional.topCenter,
                              child: Text(
                                s.appName,
                                style: TextStyle(
                                    color: c.grey_8,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Stack(children: <Widget>[
                          Container(
                            transform:
                                Matrix4.translationValues(0.0, -15.0, 0.0),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              // clipBehavior is necessary because, without it, the InkWell's animation
                              // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                              // This comes with a small performance cost, and you should not set [clipBehavior]
                              // unless you need it.
                              clipBehavior: Clip.hardEdge,
                              margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 20, 20, 0),
                                        child: Text(
                                          s.mobileNumber,
                                          style: TextStyle(
                                              color: c.grey_8, fontSize: 15),
                                          textAlign: TextAlign.left,
                                        )),
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: c.grey_3, width: 2),
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(15),
                                            topRight: const Radius.circular(15),
                                            bottomLeft:
                                                const Radius.circular(15),
                                            bottomRight:
                                                const Radius.circular(15),
                                          )),
                                      margin:
                                          EdgeInsets.fromLTRB(20, 10, 20, 10),
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: TextField(
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        controller: user_name,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                          hintText: s.mobileNumber,
                                          hintStyle: TextStyle(
                                              fontSize: 14.0, color: c.grey_6),
                                          border: InputBorder.none,
                                          prefixIcon: SvgPicture.asset(
                                            imagePath.ic_user,
                                            color: c.colorPrimary,
                                            height: 15,
                                            width: 15,
                                          ),
                                          prefixIconConstraints: BoxConstraints(
                                            minHeight: 20,
                                            minWidth: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 10, 20, 0),
                                        child: Text(
                                          s.password,
                                          style: TextStyle(
                                              color: c.grey_8, fontSize: 15),
                                          textAlign: TextAlign.left,
                                        )),
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: c.grey_3, width: 2),
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(15),
                                            topRight: const Radius.circular(15),
                                            bottomLeft:
                                                const Radius.circular(15),
                                            bottomRight:
                                                const Radius.circular(15),
                                          )),
                                      alignment: AlignmentDirectional.center,
                                      margin:
                                          EdgeInsets.fromLTRB(20, 10, 20, 20),
                                      child: TextField(
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        controller: user_password,
                                        obscureText: !_passwordVisible,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                          hintText: s.password,
                                          hintStyle: TextStyle(
                                              fontSize: 14.0, color: c.grey_6),
                                          border: InputBorder.none,
                                          prefixIcon: SvgPicture.asset(
                                            imagePath.ic_user,
                                            color: c.colorPrimary,
                                            height: 15,
                                            width: 15,
                                          ),
                                          prefixIconConstraints: BoxConstraints(
                                            minHeight: 20,
                                            minWidth: 30,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              // Based on passwordVisible state choose the icon
                                              _passwordVisible
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: c.grey_8,
                                            ),
                                            onPressed: () {
                                              // Update the state i.e. toogle the state of passwordVisible variable
                                              setState(() {
                                                _passwordVisible =
                                                    !_passwordVisible;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      alignment: Alignment.centerRight,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ForgotPassword(
                                                        isForgotPassword:
                                                            "forgot_password",
                                                      )));
                                        }, // Handle your callback
                                        child: Text(
                                          s.forgot_password,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: c.full_transparent,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: c.colorPrimaryDark,
                                            shadows: [
                                              Shadow(
                                                  color: c.colorPrimaryDark,
                                                  offset: Offset(0, -3))
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            width: MediaQuery.of(context).size.width,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                alignment: Alignment.bottomCenter,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: c.colorPrimary),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Align(
                                    alignment: AlignmentDirectional.topCenter,
                                    child: InkWell(
                                      onTap: () async {
                                        /* loginScreenBinding.userName.setText("9080873403");
          loginScreenBinding.password.setText("Crd555#&");// local block*/
                                        /*  loginScreenBinding.userName.setText("7877979787");
          loginScreenBinding.password.setText("Crd123#$");// local district*/

                                        /* loginScreenBinding.userName.setText("9751337424");
          loginScreenBinding.password.setText("Test88#$");// local state*/
                                        //prod
                                        /* loginScreenBinding.userName.setText("9750895078");
          loginScreenBinding.password.setText("Test1234#$");//block prod*/

                                        String ss = String.fromCharCodes(
                                            Runes('\u0024'));
                                        user_name.text = "9750895078";
                                        user_password.text = "Test1234#" + ss;
                                        if (user_name.text.isNotEmpty) {
                                          if (user_password.text.isNotEmpty) {
                                            // utils.showToast(context, string.success);

                                            if (await utils.isOnline()) {
                                              utils.hideSoftKeyBoard(context);
                                              if (prefs.getString(
                                                          s.key_user_name) !=
                                                      null &&
                                                  prefs.getString(
                                                          s.key_user_pwd) !=
                                                      null) {
                                                if (user_name.text ==
                                                    prefs.getString(
                                                        s.key_user_name)) {
                                                  callLogin(context);
                                                } else {
                                                  showLogoutLoginAlert(context);
                                                }
                                              } else {
                                                callLogin(context);
                                              }
                                            } else {
                                              utils.customAlertWithDataPassing(
                                                  context,
                                                  "Warning",
                                                  s.internet_error,
                                                  false,
                                                  false, {
                                                "username": user_name.text,
                                                "password": user_password.text
                                              });
                                            }
                                          } else {
                                            utils.showToast(
                                                context, s.password_empty);
                                          }
                                        } else {
                                          utils.showToast(
                                              context, s.user_name_empty);
                                        }
                                      }, // Image tapped
                                      child: Image.asset(
                                        imagePath.right_arrow_icon,
                                        color: Colors.white,
                                        height: 45,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ]),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(top: 20, bottom: 20),
                          // Handle your callback
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                  child: Text(
                                    s.new_user,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: c.d_grey2,
                                        fontSize: 13),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Registration(
                                                  registerFlag: 1,
                                                  profileJson: [],
                                                )));

                                    // utils.showToast(context, "click register");
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: Text(
                                      s.register,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: c.colorPrimaryDark,
                                          fontSize: 13),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style:
                                    TextStyle(fontSize: 15, color: c.d_grey3),
                                children: [
                                  TextSpan(
                                    text: s.otp_validation1,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // Handle the tap event
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  OTPVerification(
                                                    Flag: "login",
                                                  )),
                                        );
                                      },
                                    text: s.otp_validation2,
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.bold), //<-- SEE HERE
                                  ),
                                  TextSpan(
                                    text: s.otp_validation3,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ])),
                ],
              ),
            ),
            Container(
                alignment: AlignmentDirectional.bottomCenter,
                child: Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                    child: Text(
                      version,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: c.d_grey2,
                          fontSize: 12),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Text(
                      s.software_designed_and,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: c.grey_8,
                          fontSize: 14),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ]))
          ],
        ),
      ),
    );
  }

  Future<dynamic> callLogin(BuildContext context) async {
    if (await utils.isAutoDatetimeisEnable()) {
      try {
        await login(context);
      } on Exception catch (_) {
        print('never reached');
        utils.hideProgress(context);
      }
    } else {
      utils
          .customAlertWidet(
              context, "Error", "Please Enable Network Provided Time")
          .then((value) => {
                if (Platform.isAndroid) {utils.openDateTimeSettings()}
              });
    }
  }

  Future<dynamic> login(BuildContext context) async {
    utils.showProgress(context, 1);
    String random_char = utils.generateRandomString(15);
    var request = {
      s.key_service_id: s.service_key_login,
      s.key_user_login_key: random_char,
      s.key_user_name: user_name.text.trim(),
      s.key_user_pwd: utils.getSha256(random_char, user_password.text.trim())
    };
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = IOClient(_client);
    var response = await _ioClient.post(url.login, body: request);
    // http.Response response = await http.post(url.login, body: request);
    print("login_url>>" + url.login.toString());
    print("login_request>>" + request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("login_response>>" + data);
      var decodedData = json.decode(data);
      // var decodedData= await json.decode(json.encode(response.body));
      var STATUS = decodedData[s.key_status];
      var RESPONSE = decodedData[s.key_response];
      var KEY;
      var user_data;
      String decryptedKey;
      String userDataDecrypt;
      if (STATUS.toString() == s.key_ok &&
          RESPONSE.toString() == "LOGIN_SUCCESS") {
        KEY = decodedData[s.key_key];
        user_data = decodedData[s.key_user_data];

        userPassKey = utils.textToMd5(user_password.text);
        decryptedKey = utils.decryption(KEY, userPassKey);
        userDecriptKey = decryptedKey;
        print("userDecriptKey: " + userDecriptKey);

        userDataDecrypt = utils.decryption(user_data, userPassKey);
        var userData = jsonDecode(userDataDecrypt);

        prefs.setString(s.key_name, userData[s.key_name]);
        prefs.setString(s.key_user_name, user_name.text.trim());
        prefs.setString(s.key_user_pwd, user_password.text.trim());
        prefs.setString(s.userPassKey, decryptedKey);
        prefs.setString(s.key_desig_name, userData[s.key_desig_name]);
        prefs.setString(s.key_desig_code, userData[s.key_desig_code]);
        prefs.setString(s.key_level, userData[s.key_levels]);

        if (userData['profile_image_found'] == 'Y') {
          if (!(userData[s.key_profile_image].toString() == ("null") ||
              userData[s.key_profile_image].toString() == (""))) {
            Uint8List bytes =
                Base64Codec().decode(userData[s.key_profile_image].toString());
            prefs.setString(
                s.key_profile_image, userData[s.key_profile_image].toString());
          }
        } else {
          prefs.setString(s.key_profile_image, "");
        }

        if (userData[s.key_levels] == ("S")) {
          prefs.setString(s.key_scode, userData[s.key_statecode]);
          prefs.setString(s.key_stateName, "Tamil Nadu");
          prefs.setString(s.key_dcode, "");
          prefs.setString(s.key_bcode, "");
          await getDistrictList();
          await getBlockList();
        } else if (userData[s.key_levels] == ("D")) {
          prefs.setString(s.key_scode, userData[s.key_statecode]);
          prefs.setString(s.key_dcode, userData[s.key_dcode]);
          prefs.setString(s.key_dname, userData[s.key_dname]);
          prefs.setString(s.key_bcode, "");
          await getBlockList();
        } else if (userData[s.key_levels] == ("B")) {
          prefs.setString(s.key_scode, userData[s.key_statecode]);
          prefs.setString(s.key_dcode, userData[s.key_dcode]);
          prefs.setString(s.key_dname, userData[s.key_dname]);
          prefs.setString(s.key_bcode, userData[s.key_bcode]);
          prefs.setString(s.key_bname, userData[s.key_bname]);
          await getVillageList();
        }
        // utils.hideProgress(context);
        await getProfileData();
        await getDashboardData();

        utils.hideProgress(context);

        utils.gotoHomePage(context, "Login");
      } else {
        utils.hideProgress(context);
        utils.customAlertWidet(context, "Error", s.invalid_usn_pswd);
      }
      return decodedData;
    } else {
      utils.hideProgress(context);
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed');
    }
  }

  Future<void> getDistrictList() async {
    Map json_request = {
      s.key_scode: prefs.getString(s.key_scode) as String,
      s.key_service_id: s.service_key_district_list_all,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
          utils.encryption(jsonEncode(json_request), userDecriptKey),
    };
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = IOClient(_client);
    var response = await _ioClient.post(url.master_service,
        body: json.encode(encrpted_request));
    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    print("districtList_url>>" + url.master_service.toString());
    print("districtList_request_json>>" + json_request.toString());
    print("districtList_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("districtList_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data = utils.decryption(enc_data, userDecriptKey);
      var userData = jsonDecode(decrpt_data);
      print("DistrictList_response>> $userData");

      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        res_jsonArray.sort((a, b) {
          return a[s.key_dname]
              .toLowerCase()
              .compareTo(b[s.key_dname].toLowerCase());
        });
        if (res_jsonArray.isNotEmpty) {
          dbHelper.delete_table_District();

          String sql = 'INSERT INTO ${s.table_District} (dcode, dname) VALUES ';

          List<String> valueSets = [];

          for (var row in res_jsonArray) {
            String values =
                " ('${utils.checkNull(row[s.key_dcode])}', '${utils.checkNull(row[s.key_dname])}')";
            valueSets.add(values);
          }

          sql += valueSets.join(', ');

          await dbHelper.myDb?.execute(sql);

          /* for (int i = 0; i < res_jsonArray.length; i++) {
            await dbClient.rawInsert('INSERT INTO ' +
                s.table_District +
                ' (dcode, dname) VALUES(' +
                res_jsonArray[i][s.key_dcode] +
                ",'" +
                res_jsonArray[i][s.key_dname] +
                "')");
          } */

          List<Map> list =
              await dbClient.rawQuery('SELECT * FROM ' + s.table_District);
          print("table_District" + list.toString());
        }
      }
    }
  }

  Future<void> getBlockList() async {
    Map json_request = {};

    if (prefs.getString(s.key_level) as String == "D") {
      json_request = {
        s.key_dcode: prefs.getString(s.key_dcode) as String,
        s.key_service_id: s.service_key_block_list_district_wise_master,
      };
    } else if (prefs.getString(s.key_level) as String == "S") {
      json_request = {
        s.key_scode: prefs.getString(s.key_scode) as String,
        s.key_service_id: s.service_key_block_list_all,
      };
    }

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
          utils.encryption(jsonEncode(json_request), userDecriptKey),
    };
    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = IOClient(_client);
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
      var decrpt_data = utils.decryption(enc_data, userDecriptKey);
      var userData = jsonDecode(decrpt_data);
      print("BlockList_response>> $userData");

      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        res_jsonArray.sort((a, b) {
          return a[s.key_bname]
              .toLowerCase()
              .compareTo(b[s.key_bname].toLowerCase());
        });
        if (res_jsonArray.isNotEmpty) {
          dbHelper.delete_table_Block();

          String sql =
              'INSERT INTO ${s.table_Block} (dcode, bcode, bname) VALUES ';

          List<String> valueSets = [];

          for (var row in res_jsonArray) {
            String values =
                " ('${utils.checkNull(row[s.key_dcode])}', '${utils.checkNull(row[s.key_bcode])}', '${utils.checkNull(row[s.key_bname])}')";
            valueSets.add(values);
          }

          sql += valueSets.join(', ');

          await dbHelper.myDb?.execute(sql);

          /*
          for (int i = 0; i < res_jsonArray.length; i++) {
            await dbClient.rawInsert('INSERT INTO ' +
                s.table_Block +
                ' (dcode, bcode, bname) VALUES(' +
                res_jsonArray[i][s.key_dcode] +
                "," +
                res_jsonArray[i][s.key_bcode] +
                ",'" +
                res_jsonArray[i][s.key_bname] +
                "')");
          } */

          List<Map> list =
              await dbClient.rawQuery('SELECT * FROM ' + s.table_Block);
          print("table_Block >>" + list.toString());
        }
      }
    }
  }

  Future<void> getVillageList() async {
    Map json_request = {};

    json_request = {
      s.key_dcode: prefs.getString(s.key_dcode) as String,
      s.key_bcode: prefs.getString(s.key_bcode) as String,
      s.key_service_id: s.service_key_village_list_district_block_wise,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content:
          utils.encryption(jsonEncode(json_request), userDecriptKey),
    };
    // http.Response response = await http.post(url.master_service, body: json.encode(encrpted_request));
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = IOClient(_client);
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
      var decrpt_data = utils.decryption(enc_data, userDecriptKey);
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        List<dynamic> res_jsonArray = userData[s.key_json_data];
        res_jsonArray.sort((a, b) {
          return a[s.key_pvname]
              .toLowerCase()
              .compareTo(b[s.key_pvname].toLowerCase());
        });
        if (res_jsonArray.isNotEmpty) {
          dbHelper.delete_table_Village();

          String sql =
              'INSERT INTO ${s.table_Village} (dcode, bcode, pvcode, pvname) VALUES ';

          List<String> valueSets = [];

          for (var row in res_jsonArray) {
            String values =
                " ('${utils.checkNull(row[s.key_dcode])}', '${utils.checkNull(row[s.key_bcode])}', '${utils.checkNull(row[s.key_pvcode])}', '${utils.checkNull(row[s.key_pvname])}')";
            valueSets.add(values);
          }

          sql += valueSets.join(', ');

          await dbHelper.myDb?.execute(sql);

          /*
          for (int i = 0; i < res_jsonArray.length; i++) {
            await dbClient.rawInsert('INSERT INTO ' +
                s.table_Village +
                ' (dcode, bcode, pvcode, pvname) VALUES(' +
                res_jsonArray[i][s.key_dcode] +
                "," +
                res_jsonArray[i][s.key_bcode] +
                "," +
                res_jsonArray[i][s.key_pvcode] +
                ",'" +
                res_jsonArray[i][s.key_pvname] +
                "')");
          } */

          List<Map> list =
              await dbClient.rawQuery('SELECT * FROM ' + s.table_Village);
          print("table_Village >>" + list.toString());
        }
      }
    }
  }

  Future<void> getProfileData() async {
    // utils.showProgress(context, 1);
    late Map json_request;

    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);

    json_request = {
      s.key_service_id: s.service_key_work_inspection_profile_list,
    };

    Map encrypted_request = {
      s.key_user_name: userName,
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
    IOClient _ioClient = IOClient(_client);

    var response = await _ioClient.post(url.main_service_jwt,
        body: jsonEncode(encrypted_request), headers: header);

    print("ProfileData_url>>" + url.main_service_jwt.toString());
    print("ProfileData_request_json>>" + json_request.toString());
    print("ProfileData_request_encrpt>>" + encrypted_request.toString());
    // utils.hideProgress(context);

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;

      print("ProfileData_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("ProfileData Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("ProfileData responceSignature -  $responceSignature");

      print("ProfileData responceData -  $responceData");

      if (responceSignature == responceData) {
        print("ProfileData responceSignature - Token Verified");
        var userData = jsonDecode(data);

        var status = userData[s.key_status];
        var response_value = userData[s.key_response];

        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          if (res_jsonArray.length > 0) {
            for (int i = 0; i < res_jsonArray.length; i++) {
              String name = res_jsonArray[i][s.key_name];
              String mobile = res_jsonArray[i][s.key_mobile];
              String gender = res_jsonArray[i][s.key_gender];
              String level = res_jsonArray[i][s.key_level];
              String desig_code = res_jsonArray[i][s.key_desig_code].toString();
              String desig_name = res_jsonArray[i][s.key_desig_name];
              String dcode = res_jsonArray[i][s.key_dcode].toString();
              String bcode = res_jsonArray[i][s.key_bcode].toString();
              String office_address = res_jsonArray[i][s.key_office_address];
              String email = res_jsonArray[i][s.key_email];
              String profile_image = res_jsonArray[i][s.key_profile_image];
              String role_code = res_jsonArray[i][s.key_role_code].toString();

              if (!(profile_image == ("null") || profile_image == (""))) {
                Uint8List bytes = Base64Codec().decode(profile_image);
                prefs.setString(s.key_profile_image, profile_image);
              } else {
                prefs.setString(s.key_profile_image, "");
              }

              prefs.setString(s.key_desig_name, desig_name);
              prefs.setString(s.key_desig_code, desig_code);
              prefs.setString(s.key_name, name);
              prefs.setString(s.key_role_code, role_code);
              prefs.setString(s.key_level, level);
              prefs.setString(s.key_dcode, dcode);
              prefs.setString(s.key_bcode, bcode);
            }
          }
        } else {
          utils.customAlertWidet(context, "Error", userData[s.key_message]);
        }
      } else {
        print("ProfileData responceSignature - Token Not Verified");
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
    }
  }

  Future<void> getDashboardData() async {
    // utils.showProgress(context, 1);
    late Map json_request;

    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);

    json_request = {
      s.key_service_id: s.service_key_current_finyear_wise_status_count
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: json_request,
    };

    String jsonString = jsonEncode(encrpted_request);

    String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

    String header_token = utils.jwt_Encode(key, userName!, headerSignature);

    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = IOClient(_client);

    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $header_token"
    };

    var response = await _ioClient.post(url.main_service_jwt,
        headers: header, body: json.encode(encrpted_request));

    print("DashboardData_url>>" + url.main_service_jwt.toString());
    print("DashboardData_request_json>>" + json_request.toString());
    print("DashboardData_request_encrpt>>" + encrpted_request.toString());

    // utils.hideProgress(context);

    if (response.statusCode == 200) {
      String data = response.body;

      print("DashboardData_response>>" + data);

      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("DashboardData Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("DashboardData responceSignature -  $responceSignature");

      print("DashboardData responceData -  $responceData");

      if (responceSignature == responceData) {
        var userData = jsonDecode(data);

        var status = userData[s.key_status];
        var response_value = userData[s.key_response];

        if (status == s.key_ok && response_value == s.key_ok) {
          List<dynamic> res_jsonArray = userData[s.key_json_data];
          if (res_jsonArray.isNotEmpty) {
            for (int i = 0; i < res_jsonArray.length; i++) {
              String satisfied_count =
                  res_jsonArray[i][s.key_satisfied].toString();
              String un_satisfied_count =
                  res_jsonArray[i][s.key_unsatisfied].toString();
              String need_improvement_count =
                  res_jsonArray[i][s.key_need_improvement].toString();
              String fin_year = res_jsonArray[i][s.key_fin_year];
              String inspection_type = res_jsonArray[i][s.key_inspection_type];
              if (satisfied_count == ("")) {
                satisfied_count = "0";
              }
              if (un_satisfied_count == ("")) {
                un_satisfied_count = "0";
              }
              if (need_improvement_count == ("")) {
                need_improvement_count = "0";
              }
              int total_inspection_count = int.parse(satisfied_count) +
                  int.parse(un_satisfied_count) +
                  int.parse(need_improvement_count);

              if (inspection_type == ("rdpr")) {
                prefs.setString(s.satisfied_count, satisfied_count);
                prefs.setString(s.un_satisfied_count, un_satisfied_count);
                prefs.setString(
                    s.need_improvement_count, need_improvement_count);
                prefs.setString(
                    s.total_rdpr, total_inspection_count.toString());
                prefs.setString(s.financial_year, fin_year);
              } else {
                prefs.setString(s.satisfied_count_other, satisfied_count);
                prefs.setString(s.un_satisfied_count_other, un_satisfied_count);
                prefs.setString(
                    s.need_improvement_count_other, need_improvement_count);
                prefs.setString(
                    s.total_other, total_inspection_count.toString());
                prefs.setString(s.financial_year, fin_year);
              }
            }
          }
        }
      } else {
        print("saveWorkList responceSignature - Token Not Verified");
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
    }
  }

  Future<void> showLogoutLoginAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  color: c.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 5.0,
                    ),
                  ]),
              width: 350,
              height: 350,
              child: Column(
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                        color: c.yellow_new,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    child: Center(
                      child: Image.asset(
                        imagePath.warning,
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: c.white,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text("Warning",
                              style: GoogleFonts.getFont('Prompt',
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: c.text_color)),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: RichText(
                              text: new TextSpan(
                                // Note: Styles for TextSpans must be explicitly defined.
                                // Child text spans will inherit styles from parent
                                style: GoogleFonts.getFont('Roboto',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: c.grey_8),
                                children: <TextSpan>[
                                  new TextSpan(
                                      text: "Already you have login with ",
                                      style: new TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: c.grey_8)),
                                  new TextSpan(
                                      text: prefs.getString(s.key_user_name),
                                      style: new TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: c.primary_text_color2)),
                                  new TextSpan(
                                      text:
                                          ". Click below Logout & Continue button to login with ",
                                      style: new TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: c.grey_8)),
                                  new TextSpan(
                                      text: user_name.text,
                                      style: new TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: c.primary_text_color2)),
                                  new TextSpan(
                                      text:
                                          ". It may leads to loss of offline data of previous login!",
                                      style: new TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              c.subscription_type_red_color)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: true,
                                child: SizedBox(
                                  width: 180,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                c.yellow_new),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ))),
                                    onPressed: () {
                                      // Navigator.pop(context, false);
                                      dbHelper.deleteAll();
                                      prefs.clear();
                                      callLogin(context);
                                    },
                                    child: Text(
                                      "Logout & Continue",
                                      style: GoogleFonts.getFont('Roboto',
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: c.white),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                  visible: true,
                                  child: const SizedBox(
                                    width: 20,
                                  )),
                              Visibility(
                                visible: true,
                                child: SizedBox(
                                  width: 80,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                c.red_new),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ))),
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: Text(
                                      "Cancel",
                                      style: GoogleFonts.getFont('Roboto',
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: c.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
