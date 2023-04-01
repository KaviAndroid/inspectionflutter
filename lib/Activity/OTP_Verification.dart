import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/global.dart';
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:http/http.dart' as http;
import '../Utils/utils.dart';
import '../Resources/ColorsValue.dart' as c;

class OTPVerification extends StatefulWidget {
  final Flag;
  OTPVerification({this.Flag});
  @override
  State<OTPVerification> createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  var visibility = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController otp = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: c.white,
        body: Container(
          margin: const EdgeInsets.only(top: 20),
          width: screenWidth,
          height: sceenHeight,
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
                height: screenWidth * 0.2,
                margin: const EdgeInsets.only(top: 10),
                child: Stack(children: [
                  Visibility(
                    visible: widget.Flag == "register" ? true : false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.otp_verification,
                            style: GoogleFonts.mandali().copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: c.black)),
                        Text(s.please_verify_otp,
                            style: GoogleFonts.raleway().copyWith(
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                                color: c.black)),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: widget.Flag == "OTP" ? true : false,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(s.enter_registered_mobile_number_to_send_otp,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.raleway().copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              color: c.black)),
                    ),
                  ),
                ]),
              ),
              Expanded(
                child: Form(
                  key: formKey,
                  child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Visibility(
                              visible: widget.Flag == "register" ? true : false,
                              child: Column(children: [
                                TextFormField(
                                  controller: otp,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  maxLength: 6,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please Enter OTP'
                                      : null,
                                  decoration: InputDecoration(
                                    hintText: 'Enter OTP',
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    filled: true,
                                    fillColor: c.grey_3,
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
                                            width: 1, color: c.white),
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text("{ Resend OTP }",
                                        style: GoogleFonts.raleway().copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: c.red)),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 20, bottom: 20),
                                  child: Center(
                                    child: SizedBox(
                                      width: screenWidth * 0.7,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(c.colorPrimary),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ))),
                                        onPressed: () {},
                                        child: Text(
                                          s.verify,
                                          style: GoogleFonts.raleway().copyWith(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                              color: c.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            Visibility(
                              visible: widget.Flag == "OTP" ? true : false,
                              child: Column(children: <Widget>[
                                TextFormField(
                                  controller: mobileNumber,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  maxLength: 10,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please Enter Mobile Number'
                                      : Utils().isNumberValid(value)
                                          ? null
                                          : 'Please Enter Mobile Number',
                                  decoration: InputDecoration(
                                    hintText: 'Enter mobile Number',
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    filled: true,
                                    fillColor: c.grey_3,
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
                                            width: 1, color: c.white),
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 20, bottom: 20),
                                  child: Center(
                                    child: SizedBox(
                                      width: screenWidth * 0.7,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(c.colorPrimary),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ))),
                                        onPressed: () {},
                                        child: Text(
                                          s.send_otp,
                                          style: GoogleFonts.raleway().copyWith(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                              color: c.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ])),
                ),
              ),
            ],
          ),
        ));
  }
}
