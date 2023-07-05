// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, use_build_context_synchronously, nullable_type_in_catch_clause

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspection_flutter_app/Activity/Login.dart';
import 'package:intl/intl.dart';
import 'package:open_settings/open_settings.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Activity/Home.dart';
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:location/location.dart' as loc;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:permission_handler/permission_handler.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;

import '../DataBase/DbHelper.dart';

class Utils {
  Future<bool> isAutoDatetimeisEnable() async {
    bool isAutoDateTimeEnabled = false;
    isAutoDateTimeEnabled = Platform.environment['AUTO_TIME'] == 'true';
    // return isAutoDateTimeEnabled;
    return true;
  }

  void openDateTimeSettings() async {
    OpenSettings.openDateSetting();
  }

  Future<bool> isOnline() async {
    bool online = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      print('Connection Available!');
    } on SocketException catch (_) {
      online = false;
      print('No internet!');
    }
    return online;
  }

  bool isEmailValid(value) {
    return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value);
  }

  bool isNumberValid(value) {
    return RegExp(r'^[6789]\d{9}$').hasMatch(value);
  }

  bool isOtpValid(value) {
    return RegExp(r'^[0123456789]\d{5}').hasMatch(value);
  }

  bool isNameValid(value) {
    return RegExp(r"([a-zA-Z',.-]+( [a-zA-Z',.-]+)*){2,30}").hasMatch(value);
  }

  bool isPasswordValid(value) {
    return RegExp(
            "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#%^&+=])(?=\\S+).{4,}")
        .hasMatch(value);
  }

  void gotoHomePage(BuildContext context, String s) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Home(
                  isLogin: s,
                )));
  }

  Future<void> gotoLoginPageFromSplash(BuildContext context) async {
    Timer(
        const Duration(seconds: 2),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login())));
  }

  Future<void> hideSoftKeyBoard(BuildContext context) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  Future<bool> delayHours(
      BuildContext context, String upDate, int month) async {
    DateFormat inputFormat = DateFormat('dd-MM-yyyy');
    DateTime dateTimeLup = inputFormat.parse(upDate);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    DateTime dateTimeNow = inputFormat.parse(formattedDate);
    bool flag = false;
    double hoursOfMonth = month * 30 * 24;
    // DateTime dateTimeNow = DateTime.now();

    final differenceInDays = dateTimeNow.difference(dateTimeLup).inDays;
    print('days>>' + '$differenceInDays');

    final differenceInHours = dateTimeNow.difference(dateTimeLup).inHours;
    print('hours>>' + '$differenceInHours');
    if (differenceInHours >= hoursOfMonth) {
      flag = true;
    } else {
      flag = false;
    }
    return flag;
  }

  String encryption(String plainText, String ENCRYPTION_KEY) {
    String ENCRYPTION_IV = '2SN22SkJGDyOAXUU';
    final key = encrypt.Key.fromUtf8(fixKey(ENCRYPTION_KEY));
    final iv = encrypt.IV.fromUtf8(ENCRYPTION_IV);
    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return encrypted.base64 + ":" + iv.base64;
  }

  String decryption(String plainText, String ENCRYPTION_KEY) {
    final dateList = plainText.split(":");
    final key = encrypt.Key.fromUtf8(fixKey(ENCRYPTION_KEY));
    final iv = encrypt.IV.fromBase64(dateList[1]);

    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'));
    final decrypted =
        encrypter.decrypt(encrypt.Encrypted.from64(dateList[0]), iv: iv);
    print("Final Result: " + decrypted);

    return decrypted;
  }

  String fixKey(String key) {
    if (key.length < 16) {
      int numPad = 16 - key.length;

      for (int i = 0; i < numPad; i++) {
        key += "0"; //0 pad to len 16 bytes
      }

      return key;
    }

    if (key.length > 16) {
      return key.substring(0, 16); //truncate to 16 bytes
    }

    return key;
  }

  String getSha256(String value1, String user_password) {
    String value = textToMd5(user_password) + value1;
    var bytes = utf8.encode(value);
    return sha256.convert(bytes).toString();
  }

  String textToMd5(String text) {
    var bytes = utf8.encode(text);
    Digest md5Result = md5.convert(bytes);
    return md5Result.toString();
  }

  String generateRandomString(int length) {
    final _random = Random();
    const _availableChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final randomString = List.generate(length,
            (index) => _availableChars[_random.nextInt(_availableChars.length)])
        .join();

    return randomString;
  }

  Uri textToUri(String text) {
    print(Uri.parse(text));
    return Uri.parse(text);
  }

  void showToast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 1),
      action: SnackBarAction(
        label: 'ACTION',
        onPressed: () {},
      ),
    ));
  }

  Future<void> showAppSettings(BuildContext context, String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(msg,
              style: GoogleFonts.getFont('Roboto',
                  fontSize: 15, fontWeight: FontWeight.w800, color: c.black)),
          actions: <Widget>[
            TextButton(
              child: Text('Allow Permission',
                  style: GoogleFonts.getFont('Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: c.primary_text_color2)),
              onPressed: () async {
                await openAppSettings();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> customAlert(
      BuildContext context, String type, String msg) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dbHelper = DbHelper();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
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
              width: 300,
              height: 300,
              child: Column(
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                        color: type == "W"
                            ? c.yellow_new
                            : type == "S"
                                ? c.green_new
                                : c.red_new,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    child: Center(
                      child: Image.asset(
                        type == "W"
                            ? imagePath.warning
                            : type == "S"
                                ? imagePath.success
                                : imagePath.error,
                        height: type == "W" ? 60 : 100,
                        width: type == "W" ? 60 : 100,
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
                          Text(
                              type == "W"
                                  ? "Warning"
                                  : type == "S"
                                      ? "Success"
                                      : "Oops...",
                              style: GoogleFonts.getFont('Prompt',
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: c.text_color)),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(msg,
                              style: GoogleFonts.getFont('Roboto',
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: c.black)),
                          const SizedBox(
                            height: 35,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Visibility(
                                visible:
                                    type == "S" || type == "E" ? true : false,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              c.primary_text_color2),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ))),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: Text(
                                    "Okay",
                                    style: GoogleFonts.getFont('Roboto',
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: c.white),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: type == "W" ? true : false,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              c.green_new),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ))),
                                  onPressed: () {
                                    if (msg == s.logout) {
                                      dbHelper.deleteAll();
                                      prefs.clear();
                                      Navigator.pop(context, true);
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Login()));
                                    } else {
                                      Navigator.pop(context, true);
                                    }
                                  },
                                  child: Text(
                                    "Yes",
                                    style: GoogleFonts.getFont('Roboto',
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: c.white),
                                  ),
                                ),
                              ),
                              Visibility(
                                  visible: type == "W" ? true : false,
                                  child: const SizedBox(
                                    width: 50,
                                  )),
                              Visibility(
                                visible: type == "W" ? true : false,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              c.red_new),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ))),
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: Text(
                                    "No",
                                    style: GoogleFonts.getFont('Roboto',
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: c.white),
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

  Future<void> customAlertwithOk(
      BuildContext context, String type, String msg, List schArray) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dbHelper = DbHelper();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
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
              width: 300,
              height: 300,
              child: Column(
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                        color: c.green_new,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    child: Center(
                      child: Image.asset(
                        imagePath.success,
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
                          Text("Success",
                              style: GoogleFonts.getFont('Prompt',
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: c.text_color)),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(msg,
                              style: GoogleFonts.getFont('Roboto',
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: c.black)),
                          const SizedBox(
                            height: 35,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: true,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              c.primary_text_color2),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ))),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                    if (type == "1") {}
                                  },
                                  child: Text(
                                    "Okay",
                                    style: GoogleFonts.getFont('Roboto',
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: c.white),
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

  Future<void> customAlertWithOkCancel(
      BuildContext context, String type, String msg) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dbHelper = DbHelper();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
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
              width: 300,
              height: 300,
              child: Column(
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                        color: type == "W"
                            ? c.yellow_new
                            : type == "S"
                                ? c.green_new
                                : c.red_new,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    child: Center(
                      child: Image.asset(
                        type == "W"
                            ? imagePath.warning
                            : type == "S"
                                ? imagePath.success
                                : imagePath.error,
                        height: type == "W" ? 60 : 100,
                        width: type == "W" ? 60 : 100,
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
                          Text(
                              type == "W"
                                  ? "Warning"
                                  : type == "S"
                                      ? "Success"
                                      : "Oops...",
                              style: GoogleFonts.getFont('Prompt',
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: c.text_color)),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(msg,
                              style: GoogleFonts.getFont('Roboto',
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: c.black)),
                          const SizedBox(
                            height: 35,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Visibility(
                                visible:
                                    type == "S" || type == "E" ? true : false,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              c.primary_text_color2),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ))),
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: Text(
                                    "Okay",
                                    style: GoogleFonts.getFont('Roboto',
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: c.white),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: type == "W" ? true : false,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              c.green_new),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ))),
                                  onPressed: () {
                                    if (msg == s.logout_msg) {
                                      dbHelper.deleteAll();
                                      prefs.clear();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Login()));
                                    } else {
                                      Navigator.pop(context, true);
                                    }
                                  },
                                  child: Text(
                                    "Ok",
                                    style: GoogleFonts.getFont('Roboto',
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: c.white),
                                  ),
                                ),
                              ),
                              Visibility(
                                  visible: type == "W" ? true : false,
                                  child: const SizedBox(
                                    width: 50,
                                  )),
                              Visibility(
                                visible: type == "W" ? true : false,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              c.red_new),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
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

  Future<void> showalertforOffline(BuildContext context, String msg,
      String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dbHelper = DbHelper();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              height: 320,
              margin: EdgeInsets.all(30),
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
                          Text(msg,
                              style: GoogleFonts.getFont('Roboto',
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: c.black)),
                          const SizedBox(
                            height: 35,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: true,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              c.green_new),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ))),
                                  onPressed: () {
                                    OpenSettings.openWIFISetting();
                                    Navigator.pop(context, false);
                                  },
                                  child: Text(
                                    "Settings",
                                    style: GoogleFonts.getFont('Roboto',
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: c.white),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: true,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              c.primary_text_color2),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ))),
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                    offlineMode(username, password, context);
                                  },
                                  child: Text(
                                    "Continue With Off-Line",
                                    style: GoogleFonts.getFont('Roboto',
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: c.white),
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

  Future<void> showAlert(BuildContext context, String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
                Text(''),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<SecurityContext> get globalContext async {
    final sslCert1 = await rootBundle.load(imagePath.certificate);
    SecurityContext sc = new SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }

  Future<String> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = "";
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    print("app>>" +
        appName +
        " >>" +
        packageName +
        " >>" +
        packageInfo.version +
        " >>" +
        buildNumber);
    return packageInfo.version;
  }

  Future<bool> goToCameraPermission(BuildContext context) async {
    late PermissionStatus cameraPermission, speechPermission;
    cameraPermission = await Permission.camera.status;
    print("object$cameraPermission");

    bool flag = false;
    if (await Permission.camera.request().isGranted) {
      cameraPermission = await Permission.camera.status;
      flag = true;
      print("object$cameraPermission");
    }
    if (cameraPermission.isDenied || cameraPermission.isPermanentlyDenied) {
      Utils().showAppSettings(context, s.cam_permission);
    }
    return flag;
  }

  Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;
    var location = loc.Location();

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!await location.serviceEnabled()) {
        location.requestService();
      }
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Widget showSpinner(BuildContext context, String message) {
    return WillPopScope(
        onWillPop: () async => false,
/*      child: Center(
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(80.0),
              color: c.grey_6,
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
                lineWidth: 5,
                color: c.grey_7,
                duration: const Duration(seconds: 1, milliseconds: 500),
                size: 100,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitPouringHourGlassRefined(
                    color: c.white,
                    duration: const Duration(seconds: 1, milliseconds: 500),
                    size: 50,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(message,
                      style: GoogleFonts.getFont('Roboto',
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.none,
                          fontSize: 10,
                          color: c.white))
                ],
              ),
            ],
          ),
        ),
      ),*/
        child: Center(
          child: Container(
            height: 100,
            width: 100,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitFadingCircle(
                      color: c.primary_text_color2,
                      duration: const Duration(seconds: 1, milliseconds: 500),
                      size: 50,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(message,
                        style: GoogleFonts.getFont('Roboto',
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.none,
                            fontSize: 10,
                            color: c.primary_text_color2))
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> showLoading(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierColor: Color(0xFF77000000),
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              height: 100,
              width: 100,
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitFadingCircle(
                        color: c.primary_text_color2,
                        duration: const Duration(seconds: 1, milliseconds: 500),
                        size: 50,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(message,
                          style: GoogleFonts.getFont('Roboto',
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.none,
                              fontSize: 15,
                              color: c.primary_text_color2))
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showProgress(BuildContext context, int i) async {
    i == 1
        ? showLoading(context, s.loading)
        : showLoading(context, s.downloading);
  }

  Future<void> hideProgress(BuildContext context) async {
    Navigator.pop(context, true);
  }

  bool editdelayHours(String myDate) {
    DateFormat inputFormat = DateFormat('dd-MM-yyyy HH:mm:ss');
    DateTime dateTimeLup = inputFormat.parse(myDate);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy HH:mm:ss').format(now);
    DateTime dateTimeNow = inputFormat.parse(formattedDate);
    bool flag = false;
    // double  hoursOfMonth=month*30*24;
    // DateTime dateTimeNow = DateTime.now();

    final differenceInDays = dateTimeNow.difference(dateTimeLup).inDays;
    print('dateTimeLup>>' + '$dateTimeLup');
    print('now>>' + '$now');
    print('days>>' + '$differenceInDays');

    final differenceInHours = dateTimeNow.difference(dateTimeLup).inHours;
    print('hours>>' + '$differenceInHours');
    if (differenceInHours < 48) {
      flag = true;
    } else {
      flag = false;
    }
    return flag;
  }

  launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> offlineMode(
      String username, String password, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userName = prefs.getString(s.key_user_name).toString();
    String passWord = prefs.getString(s.key_user_pwd).toString();
    if (username == userName && password == passWord) {
      gotoHomePage(context, "Login");
    } else {
      customAlert(context, "E", s.no_offline_data);
    }
  }

  String generateHmacSha256(String message, String S_key, bool flag) {
    String hashData = "";
    var key = utf8.encode(S_key);
    var jsonData = utf8.encode(message);

    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(jsonData);

    hashData = digest.toString();

    if (flag) {
      String encodedhashData = base64.encode(utf8.encode(hashData));
      return encodedhashData;
    }

    return hashData;
  }

  String jwt_Encode(String secretKey, String userName, String encodedhashData) {
    String token = "";

    DateTime currentTime = DateTime.now();

    DateTime expirationTime = currentTime.add(const Duration(minutes: 20));

    String exp = (expirationTime.millisecondsSinceEpoch / 1000).toString();

    Map payload = {
      "exp": exp,
      "username": userName,
      "signature": encodedhashData,
    };

    final jwt = JWT(payload, issuer: "tnrd.tn.gov.in");

    token = jwt.sign(SecretKey(secretKey));

    print('Signed token: Bearer $token\n');

    return token;
  }

  String jwt_Decode(String secretKey, String jwtToken) {
    String signature = "";

    try {
      // Verify a token
      final jwt = JWT.verify(jwtToken, SecretKey(secretKey));

      Map<String, dynamic> headerJWT = jwt.payload;

      String head_sign = headerJWT['signature'];

      List<int> bytes = base64.decode(head_sign);

      signature = utf8.decode(bytes);
    } on Exception catch (e) {
      print(e);
    }

    return signature;
  }

  String checkNull(dynamic value) {
    return value == null ? '' : value.toString();
  }

  String splitStringByLength(String str, int length) {
    String sname = '';

    for (int i = 0; i < str.length; i++) {
      if (i == (length + 1) || i == (length + 1) * 2 || i == (length + 1) * 3) {
        sname += "\n${str[i]}";
      } else {
        sname += str[i];
      }
    }

    return sname;
  }

/*
  Future<Map<String, dynamic>> ShowCalenderDialog(BuildContext context) async {
    int currentIndex = 0;

    //Date Time
    List<DateTime> selectedfromDateRange = [];
    List<DateTime> selectedtoDateRange = [];
    DateTime? selectedFromDate;
    DateTime? selectedToDate;

    Map<String, dynamic> jsonValue = {
      "fromDate": "",
      "toDate": "",
      "flag": false
    };

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 0.9, // Adjust this value as needed
          heightFactor: 0.85,
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  currentIndex == 1
                                      ? setState(() {
                                          currentIndex = 0;
                                        })
                                      : null;
                                },
                                child: Container(
                                  width: 150,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'From Date',
                                      style: TextStyle(
                                        color: currentIndex == 0
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: Duration(milliseconds: 400),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width:
                                                currentIndex == 0 ? 2.0 : 1.0,
                                            color: currentIndex == 0
                                                ? c.primary_text_color2
                                                : Colors.white))),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (selectedFromDate != null) {
                                    setState(() {
                                      currentIndex = 1;
                                    });
                                  } else {
                                    customAlert(context, "E",
                                        "Please Select From Date");
                                  }
                                },
                                child: Container(
                                  width: 150,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'To Date',
                                      style: TextStyle(
                                        color: currentIndex == 1
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: Duration(milliseconds: 400),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width:
                                                currentIndex == 0 ? 2.0 : 1.0,
                                            color: currentIndex == 1
                                                ? c.primary_text_color2
                                                : Colors.white))),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      child: Center(
                        child: currentIndex == 0
                            ? CalendarDatePicker2(
                                config: CalendarDatePicker2Config(
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                  currentDate:
                                      selectedFromDate ?? DateTime.now(),
                                  selectedDayHighlightColor: c.colorAccentlight,
                                  weekdayLabels: [
                                    'Sun',
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat'
                                  ],
                                  weekdayLabelTextStyle: const TextStyle(
                                      color: Color(0xFF07b3a5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10),
                                  firstDayOfWeek: 1,
                                  controlsHeight: 50,
                                  controlsTextStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  dayTextStyle: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF252b34),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  disabledDayTextStyle: const TextStyle(
                                      color: Colors.grey, fontSize: 10),
                                ),
                                value: selectedfromDateRange,
                                onValueChanged: (value) async {
                                  selectedFromDate = value[0];
                                  if (selectedFromDate != null) {
                                    selectedToDate = null;
                                  }
                                },
                              )
                            : CalendarDatePicker2(
                                config: CalendarDatePicker2Config(
                                  firstDate: selectedFromDate,
                                  lastDate: DateTime.now(),
                                  currentDate: DateTime.now(),
                                  selectedDayHighlightColor: c.colorAccentlight,
                                  weekdayLabels: [
                                    'Sun',
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat'
                                  ],
                                  weekdayLabelTextStyle: const TextStyle(
                                      color: Color(0xFF07b3a5),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10),
                                  firstDayOfWeek: 1,
                                  controlsHeight: 50,
                                  controlsTextStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  dayTextStyle: const TextStyle(
                                      color: Color(0xFF252b34),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10),
                                  disabledDayTextStyle: const TextStyle(
                                      color: Colors.grey, fontSize: 10),
                                ),
                                value: selectedtoDateRange,
                                onValueChanged: (value) async {
                                  print("value change");
                                  selectedToDate = value[0];
                                },
                              ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                currentIndex = 0;
                                selectedFromDate = null;
                                selectedToDate = null;
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              child: Text(
                                "CANCEL",
                                style: TextStyle(
                                  color: c.colorPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (selectedToDate != null &&
                                    selectedFromDate != null) {
                                  currentIndex = 0;
                                  jsonValue = {
                                    "fromDate": selectedFromDate,
                                    "toDate": selectedToDate,
                                    "flag": true
                                  };
                                  Navigator.of(context).pop();
                                } else {
                                  customAlert(
                                      context, "E", "Please Select To Date");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              child: Text(
                                "OK",
                                style: TextStyle(
                                  color: c.colorPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        );
      },
    );
    return jsonValue;
  }
*/
  Future<Map<String, dynamic>> ShowCalenderDialog(BuildContext context) async {
    int currentIndex = 0;

    //Date Time
    List<DateTime> selectedfromDateRange = [];
    List<DateTime> selectedtoDateRange = [];
    DateTime? selectedFromDate;
    DateTime? selectedToDate;

    Map<String, dynamic> jsonValue = {
      "fromDate": "",
      "toDate": "",
      "flag": false
    };

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          widthFactor: 0.9, // Adjust this value as needed
          heightFactor: 0.85,
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                   setState(() {
                                    currentIndex = 0;
                                  });
                                },
                                child: Container(
                                  width: 150,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'From Date',
                                      style: TextStyle(
                                        color: currentIndex == 0
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: Duration(milliseconds: 400),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width:
                                            currentIndex == 0 ? 2.0 : 1.0,
                                            color: currentIndex == 0
                                                ? c.primary_text_color2
                                                : Colors.white))),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (selectedFromDate != null) {
                                    setState(() {
                                      currentIndex = 1;
                                    });
                                  } else {
                                    customAlert(context, "E",
                                        "Please Select From Date");
                                  }
                                },
                                child: Container(
                                  width: 150,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'To Date',
                                      style: TextStyle(
                                        color: currentIndex == 1
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: Duration(milliseconds: 400),
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width:
                                            currentIndex == 0 ? 2.0 : 1.0,
                                            color: currentIndex == 1
                                                ? c.primary_text_color2
                                                : Colors.white))),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      child: Center(
                        child: currentIndex == 0
                            ? CalendarDatePicker2(
                          config: CalendarDatePicker2Config(
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                            currentDate:
                            selectedFromDate ?? DateTime.now(),
                            selectedDayHighlightColor: c.colorAccentlight,
                            weekdayLabels: [
                              'Sun',
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat'
                            ],
                            weekdayLabelTextStyle: const TextStyle(
                                color: Color(0xFF07b3a5),
                                fontWeight: FontWeight.bold,
                                fontSize: 10),
                            firstDayOfWeek: 1,
                            controlsHeight: 50,
                            controlsTextStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            dayTextStyle: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF252b34),
                              fontWeight: FontWeight.bold,
                            ),
                            disabledDayTextStyle: const TextStyle(
                                color: Colors.grey, fontSize: 10),
                          ),
                          value: selectedfromDateRange,
                          onValueChanged: (value) async {
                            selectedFromDate = value[0];
                            if (selectedFromDate != null) {
                              selectedToDate = null;
                            }
                          },
                        )
                            : CalendarDatePicker2(
                          config: CalendarDatePicker2Config(
                          /*  firstDate: selectedFromDate,
                            lastDate: DateTime.now(),
                            currentDate: DateTime.now(),*/
                            selectedDayHighlightColor: c.colorAccentlight,
                            weekdayLabels: [
                              'Sun',
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat'
                            ],
                            weekdayLabelTextStyle: const TextStyle(
                                color: Color(0xFF07b3a5),
                                fontWeight: FontWeight.bold,
                                fontSize: 10),
                            firstDayOfWeek: 1,
                            controlsHeight: 50,
                            controlsTextStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            dayTextStyle: const TextStyle(
                                color: Color(0xFF252b34),
                                fontWeight: FontWeight.bold,
                                fontSize: 10),
                            disabledDayTextStyle: const TextStyle(
                                color: Colors.grey, fontSize: 10),
                          ),
                          value: selectedtoDateRange,
                          onValueChanged: (value) async {
                            print("value change");
                            selectedToDate = value[0];
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                currentIndex = 0;
                                selectedFromDate = null;
                                selectedToDate = null;
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              child: Text(
                                "CANCEL",
                                style: TextStyle(
                                  color: c.colorPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (selectedToDate != null &&
                                    selectedFromDate != null) {
                                  currentIndex = 0;
                                  jsonValue = {
                                    "fromDate": selectedFromDate,
                                    "toDate": selectedToDate,
                                    "flag": true
                                  };
                                  Navigator.of(context).pop();
                                } else {
                                  customAlert(
                                      context, "E", "Please Select To Date");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              child: Text(
                                "OK",
                                style: TextStyle(
                                  color: c.colorPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        );
      },
    );
    return jsonValue;
  }

}
