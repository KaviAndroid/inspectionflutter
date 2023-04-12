import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspection_flutter_app/Activity/Login.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/utils.dart';
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import '../Resources/ColorsValue.dart' as c;

class OTPVerification extends StatefulWidget {
  final Flag;
  final mobile_no;
  OTPVerification({this.Flag, this.mobile_no});
  @override
  State<OTPVerification> createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  String design_flag = '';

  String otp_empty_msg = 'Please Enter OTP';
  String num_empty_msg = 'Please Enter Number';

  bool isSpinnerLoading = false;

  TextEditingController mobileNumber = TextEditingController();
  TextEditingController otp = TextEditingController();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    design_flag = widget.Flag;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: c.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Image.asset(
                      imagePath.otp,
                      width: double.infinity,
                      height: 300,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Column(children: [
                        Visibility(
                          visible: design_flag == "OTP" ? true : false,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.otp_verification,
                                  style: GoogleFonts.getFont('Mandali',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: c.black)),
                              const SizedBox(height: 30),
                              Text(s.please_verify_otp,
                                  style: GoogleFonts.getFont('Raleway',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15,
                                      color: c.black)),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: design_flag == "login" ? true : false,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                                s.enter_registered_mobile_number_to_send_otp,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.getFont('Raleway',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    color: c.black)),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    Container(
                        margin: const EdgeInsets.all(20),
                        child: Column(children: [
                          Column(children: [
                            TextFormField(
                              controller: design_flag == "OTP"
                                  ? otp
                                  : design_flag == "login"
                                      ? mobileNumber
                                      : null,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLength: design_flag == "OTP"
                                  ? 6
                                  : design_flag == "login"
                                      ? 10
                                      : null,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) => design_flag == "OTP"
                                  ? value!.isEmpty
                                      ? otp_empty_msg
                                      : null
                                  : design_flag == "login"
                                      ? value!.isEmpty
                                          ? num_empty_msg
                                          : Utils().isNumberValid(value)
                                              ? null
                                              : s.please_enter_valid_num
                                      : null,
                              decoration: InputDecoration(
                                hintText: design_flag == "OTP"
                                    ? 'Enter OTP'
                                    : design_flag == "login"
                                        ? 'Enter Mobile Number'
                                        : null,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                filled: true,
                                fillColor: c.grey_3,
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
                                    borderSide:
                                        BorderSide(width: 1, color: c.white),
                                    borderRadius: BorderRadius.circular(10.0)),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                    design_flag == "OTP"
                                        ? "{ Resend OTP }"
                                        : '',
                                    style: GoogleFonts.getFont('Raleway',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: c.red)),
                              ),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.only(top: 20, bottom: 20),
                              child: Center(
                                child: SizedBox(
                                  width: 250,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  c.colorPrimary),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ))),
                                      onPressed: () {
                                        design_flag == "login"
                                            ? send_OTP()
                                            : design_flag == "OTP"
                                                ? verify_OTP()
                                                : null;
                                      },
                                      child: Text(
                                        design_flag == "OTP"
                                            ? s.verify
                                            : 'Send OTP',
                                        style: GoogleFonts.getFont('Raleway',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: c.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ]))
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  // ************************** Send OTP API *****************************/

  Future<void> send_OTP() async {
    setState(() {
      isSpinnerLoading = true;
    });

    Map jsonRequest = {
      s.key_service_id: s.service_key_resend_otp,
      s.service_key_mobile_number: '7448944737',
    };

    print(jsonRequest);

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response =
        await _ioClient.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
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
          prefs.setString(s.key_mobile, mobileNumber.text);
          design_flag = 'OTP';
        });
      } else if (status == s.key_ok && responseValue == s.key_fail) {
        Utils().showAlert(context, message);
      }
    }
  }

  // ************************** Verify OTP API *****************************/

  Future<void> verify_OTP() async {
    setState(() {
      isSpinnerLoading = true;
    });

    Map jsonRequest = {
      s.key_service_id: s.service_key_resend_otp,
      s.service_key_mobile_number: prefs.getString(s.key_mobile),
      s.key_mobile_otp: otp.text,
    };

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response =
        await _ioClient.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
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

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
      } else if (status == s.key_ok && responseValue == s.key_fail) {
        Utils().showAlert(context, message);
      }
    }
  }
}
