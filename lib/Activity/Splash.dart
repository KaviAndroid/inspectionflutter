import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Layout/AppUpdate.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Resources/global.dart';
import '../Utils/utils.dart';
import 'package:inspection_flutter_app/Resources/url.dart' as url;

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  final LocalAuthentication auth = LocalAuthentication();
  String msg = "You are not authorized.";

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    if (await utils.isOnline()) {
      // checkVersion(context);
      utils.gotoLoginPageFromSplash(context);
    } else {
      if (prefs.getString(s.key_user_name) != null &&
          prefs.getString(s.key_user_pwd) != null) {
        checkBiometricSupport();
      } else {
        utils.gotoLoginPageFromSplash(context);
      }
    }
  }

  Future<void> checkBiometricSupport() async {
    try {
      bool hasbiometrics =
          await auth.canCheckBiometrics; //check if there is authencations,

      if (hasbiometrics) {
        List<BiometricType> availableBiometrics =
            await auth.getAvailableBiometrics();
        if (availableBiometrics.contains(BiometricType.face) ||
            availableBiometrics.contains(BiometricType.fingerprint)) {
          bool pass = await auth.authenticate(
              localizedReason: 'Authenticate with fingerprint/face',
              biometricOnly: true);
          if (pass) {
            msg = "You are Authenicated.";
            setState(() {});
            utils.gotoHomePage(context, "Login");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "Authentication failed. Please use user name and password to login. "),
            ));
            utils.gotoLoginPageFromSplash(context);
          }
        } else {
          msg = "You are not alowed to access biometrics.";
          try {
            bool pass = await auth.authenticate(
                localizedReason: 'Authenticate with pattern/pin/passcode',
                biometricOnly: false);
            if (pass) {
              msg = "You are Authenticated.";
              setState(() {});
              utils.gotoHomePage(context, "Splash");
            }
          } on PlatformException catch (e) {
            msg = "Error while opening fingerprint/face scanner";
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  "Authentication failed. Please use user name and password to login. "),
            ));
            utils.gotoLoginPageFromSplash(context);
          }
        }
      } else {
        msg = "You are not alowed to access biometrics.";
        try {
          bool pass = await auth.authenticate(
              localizedReason: 'Authenticate with pattern/pin/passcode',
              biometricOnly: false);
          if (pass) {
            msg = "You are Authenticated.";
            setState(() {});
            utils.gotoHomePage(context, "Splash");
          }
        } on PlatformException catch (e) {
          msg = "Error while opening fingerprint/face scanner";
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Authentication failed. Please use user name and password to login. "),
          ));
          utils.gotoLoginPageFromSplash(context);
        }
      }
    } on PlatformException catch (e) {
      msg = "Error while opening fingerprint/face scanner";
      msg = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Authentication failed. Please use user name and password to login. "),
      ));
      utils.gotoLoginPageFromSplash(context);
    }
    print("Mess>>" + msg);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    screenWidth = width;
    sceenHeight = height;

    return Scaffold(
      body: InkWell(
        child: Container(
          color: c.colorAccentverylight,
          child: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Column(
                children: <Widget>[
                  Expanded(
                      child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Align(
                          alignment: AlignmentDirectional.topCenter,
                          child: Image.asset(
                            imagePath.tamilnadu_logo,
                            height: 100,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Align(
                          alignment: AlignmentDirectional.topCenter,
                          child: Text(
                            s.appName,
                            style: TextStyle(
                                color: c.grey_9,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                          ),
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(180),
                              topRight: Radius.circular(180))),
                      alignment: AlignmentDirectional.bottomEnd,
                      height: 200,
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: Align(
                          alignment: AlignmentDirectional.bottomCenter,
                          child: Image.asset(
                            imagePath.login_insp,
                          ),
                        ),
                      ))
                ],
              )),
        ),
      ),
    );
  }

  Future<dynamic> checkVersion(BuildContext context) async {
    var request = {
      s.key_service_id: s.service_key_version_check,
      s.key_app_code: s.service_key_appcode,
    };
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = IOClient(_client);
    var response = await _ioClient.post(url.login, body: request);
    // http.Response response = await http.post(url.login, body: request);
    print("checkVersion_url>>" + url.login.toString());
    print("checkVersion_request>>" + request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("checkVersion_response>>" + data);
      var decodedData = json.decode(data);
      // var decodedData= await json.decode(json.encode(response.body));
      String version = decodedData['version'];
      String app_version = await utils.getVersion();
      int v1Number = getExtendedVersionNumber(version);
      int v2Number = getExtendedVersionNumber(app_version);
      if (decodedData[s.key_app_code] == "WI" && (v1Number > v2Number)) {
        prefs.setString(s.download_apk, decodedData['apk_path']);
        /* Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AppUpdate(
                      type: "W",
                      url: s.download_apk,
                    )));*/
        utils.customAlertWidet(context, "Warning", s.download_apk);
      } else {
        if (prefs.getString(s.key_user_name) != null &&
            prefs.getString(s.key_user_pwd) != null) {
          checkBiometricSupport();
        } else {
          utils.gotoLoginPageFromSplash(context);
        }
      }
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed');
    }
  }
  int getExtendedVersionNumber(String version) {
    List versionCells = version.split('.');
    versionCells = versionCells.map((i) => int.parse(i)).toList();
    return versionCells[0] * 100000 + versionCells[1] * 1000 + versionCells[2];
  }
}
