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
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController otp = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: c.white,
        body: Column(
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
                        visible: widget.Flag == "register" ? true : false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(s.otp_verification,
                                style: GoogleFonts.mandali().copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                    color: c.black)),
                            const SizedBox(height: 30),
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
                          child: Text(
                              s.enter_registered_mobile_number_to_send_otp,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.raleway().copyWith(
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
                            controller:
                                widget.Flag == "OTP" ? otp : mobileNumber,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            maxLength: widget.Flag == "OTP" ? 6 : 10,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) =>
                                value!.isEmpty ? 'Please Enter OTP' : null,
                            decoration: InputDecoration(
                              hintText: widget.Flag == "OTP"
                                  ? 'Enter OTP'
                                  : 'Enter Mobile Number',
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
                                  widget.Flag == "OTP" ? "{ Resend OTP }" : '',
                                  style: GoogleFonts.raleway().copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: c.red)),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 20, bottom: 20),
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
                                    onPressed: () {},
                                    child: Text(
                                      widget.Flag == "OTP"
                                          ? s.verify
                                          : 'Send OTP',
                                      style: GoogleFonts.raleway().copyWith(
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
        ));
  }
}
