import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:InspectionAppNew/Activity/Login.dart';
import 'package:InspectionAppNew/Resources/Strings.dart' as s;
import 'package:InspectionAppNew/Resources/url.dart' as url;
import 'package:InspectionAppNew/Resources/ImagePath.dart' as imagePath;
import 'package:shared_preferences/shared_preferences.dart';
import '../Utils/utils.dart';
import 'package:InspectionAppNew/Resources/url.dart' as url;
import '../Resources/ColorsValue.dart' as c;

class OTPVerification extends StatefulWidget {
  final Flag;
  OTPVerification({this.Flag});
  @override
  State<OTPVerification> createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  String design_flag = '';
  Utils utils = Utils();

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
    setState(() {});
  }
  Future<bool> _onWillPop() async {
    Navigator.of(context, rootNavigator: true).pop(context);
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
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
                                  style: GoogleFonts.getFont('Roboto',
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
                                style: GoogleFonts.getFont('Roboto',
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
                              child: InkWell(
                                onTap: () async {
                                  if (await utils.isOnline()) {
                                    prefs
                                        .getString(s.key_mobile)
                                        .toString()
                                        .isNotEmpty
                                        ? send_OTP(prefs
                                        .getString(s.key_mobile)
                                        .toString())
                                        : utils.showAlert(
                                        context, s.please_enter_otp);
                                  } else {
                                    utils.customAlertWidet(
                                        context, "Error", s.no_internet);
                                  }
                                },
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                      design_flag == "OTP"
                                          ? "{ Resend OTP }"
                                          : '',
                                      style: GoogleFonts.getFont('Roboto',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: c.red)),
                                ),
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
                                      onPressed: () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        if (await utils.isOnline()) {
                                          design_flag == "login"
                                              ? (utils.isNumberValid(
                                              mobileNumber.text
                                                  .toString()) &&
                                              (mobileNumber.text
                                                  .toString()
                                                  .isNotEmpty))
                                              ? send_OTP(mobileNumber.text
                                              .toString())
                                              : utils.showAlert(context,
                                              s.please_enter_valid_num)
                                              : design_flag == "OTP"
                                              ? otp.text
                                              .toString()
                                              .isNotEmpty
                                              ? verify_OTP()
                                              : utils.showAlert(context,
                                              s.please_enter_otp)
                                              : null;
                                        } else {
                                          utils.customAlertWidet(
                                              context, "Error", s.no_internet);
                                        }
                                      },
                                      child: Text(
                                        design_flag == "OTP"
                                            ? s.verify
                                            : 'Send OTP',
                                        style: GoogleFonts.getFont('Roboto',
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
        )), onWillPop: _onWillPop);
  }

  // ************************** Send OTP API *****************************/

  Future<void> send_OTP(String mobileNumber) async {
    utils.showProgress(context, 1);
    setState(() {
      isSpinnerLoading = true;
    });

    Map jsonRequest = {
      s.key_service_id: s.service_key_resend_otp,
      s.service_key_mobile_number: mobileNumber,
    };

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response =
        await _ioClient.post(url.open_service, body: json.encode(jsonRequest));
    print("send_OTP_url>>" + url.open_service.toString());
    print("send_OTP_request_json>>" + jsonRequest.toString());
    utils.hideProgress(context);
    if (response.statusCode == 200) {
      var responseData = response.body;
      var data = jsonDecode(responseData);

      print("send_OTP_request_encrypt>>" + data.toString());

      var status = data[s.key_status];
      var responseValue = data[s.key_response];
      var message = data[s.key_message];

      setState(() {
        isSpinnerLoading = false;
      });

      if (status == s.key_ok && responseValue == s.key_ok) {
        Utils().customAlertWidet(context, "Success", message);

        setState(() {
          prefs.setString(s.key_mobile, mobileNumber);
          design_flag = 'OTP';
        });
      } else if (status == s.key_ok && responseValue == s.key_fail) {
        Utils().customAlertWidet(context, "Error", message);
      }
    }
  }

  // ************************** Verify OTP API *****************************/

  Future<void> verify_OTP() async {
    utils.showProgress(context, 1);
    setState(() {
      isSpinnerLoading = true;
    });

    Map jsonRequest = {
      s.key_service_id: s.service_key_verify_otp,
      s.key_mobile_otp: otp.text,
      s.service_key_mobile_number: prefs.getString(s.key_mobile),
    };

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response =
        await _ioClient.post(url.open_service, body: json.encode(jsonRequest));
    utils.hideProgress(context);
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
        utils.customAlertWithDataPassing(
            context, "Success", message, true, false, {});
      } else if (status == s.key_ok && responseValue == s.key_fail) {
        utils.customAlertWidet(context, "Error", message);
      }
    }
  }
}
