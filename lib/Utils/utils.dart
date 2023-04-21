import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspection_flutter_app/Activity/Login.dart';
import 'package:inspection_flutter_app/Activity/Pdf_Viewer.dart';
import 'package:intl/intl.dart';
import '../Activity/Home.dart';
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:location/location.dart' as loc;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:permission_handler/permission_handler.dart';

class Utils {
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
    if (s == "Login") {
      Timer(
          const Duration(seconds: 2),
          () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => Home(
                        isLogin: s,
                      ))));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Home(
                    isLogin: s,
                  )));
    }
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
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(msg),
          actions: <Widget>[
            TextButton(
              child: const Text('Allow Permission'),
              onPressed: () {
                openAppSettings();
              },
            ),
          ],
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
      child: Center(
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
      ),
    );
  }

  Future<bool> editdelayHours(String myDate) async {
    DateFormat inputFormat = DateFormat('dd-MM-yyyy hh:mm:ss');
    DateTime dateTimeLup = inputFormat.parse(myDate);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy hh:mm:ss').format(now);
    DateTime dateTimeNow = inputFormat.parse(formattedDate);
    bool flag = false;
    // double  hoursOfMonth=month*30*24;
    // DateTime dateTimeNow = DateTime.now();

    final differenceInDays = dateTimeNow.difference(dateTimeLup).inDays;
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
}
