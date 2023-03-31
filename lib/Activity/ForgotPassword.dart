import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Utils/utils.dart';
import '../Resources/ColorsValue.dart'as c;

class ForgotPassword extends StatefulWidget {
  @override
  final isForgotPassword;
  ForgotPassword({this.isForgotPassword});
  State<ForgotPassword> createState() => _ForgotPasswordState();
}
class _ForgotPasswordState extends State<ForgotPassword> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  String userPassKey = "";
  String userDecryptKey = "";
  var tcVisibility = false;
  var visibility = false;
  var tvisibility = false;
  String mobilenumber = "";
  String Otp = "";
  String newpassword = "";
  String confirmpassword = "";
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  TextEditingController mobile_number = TextEditingController();
  TextEditingController otp = TextEditingController();
  TextEditingController new_password = TextEditingController();
  TextEditingController confirm_password = TextEditingController();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: c.white,
        resizeToAvoidBottomInset: false,
        body: Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(imagePath.otp, width: double.infinity,
                  height: 300,),
                Stack(
                    children: <Widget>[
                      Visibility(
                        visible: !visibility,
                        child: Padding(padding: EdgeInsets.only(bottom: 35),
                            child: Text(
                                s.enter_registered_mobile_number_to_send_otp,
                                style: TextStyle(fontWeight: FontWeight.normal,
                                    fontSize: 15,
                                    color: Colors.black),
                                textAlign: TextAlign.center)
                        ),),
                      Visibility(
                        visible: !visibility,
                        child: Padding(padding: EdgeInsets.only(top: 20),
                          child: Container(
                              height: 45,
                              decoration: new BoxDecoration(
                                  color: c.ca2,
                                  border: Border.all(color: c.ca2, width: 2),
                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(10),
                                    topRight: const Radius.circular(10),
                                    bottomLeft: const Radius.circular(10),
                                    bottomRight: const Radius.circular(10),
                                  )),
                              child: TextField(
                                controller: mobile_number,
                                textAlign: TextAlign.start,
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  // suffixIcon: Icon(Icons.visibility_off_outlined),
                                  contentPadding: EdgeInsets.only(top: 15,
                                      left: 15),
                                  isDense: true,
                                  border: InputBorder.none,
                                ),
                              )
                          ),),),
                      Visibility(
                        visible: !visibility,
                        child: Padding(padding: EdgeInsets.only(top: 100),
                          child: SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: Container(
                                child: TextButton(
                                  child: Text(s.send_otp,
                                      style: TextStyle(color: c.white)),
                                  style: ButtonStyle(
                                      padding: MaterialStateProperty.all<
                                          EdgeInsets>(EdgeInsets.all(15)),
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(c.colorPrimary),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(25),
                                                topRight: Radius.circular(25),
                                                bottomLeft: Radius.circular(25),
                                                bottomRight: Radius.circular(
                                                    25),
                                              ),
                                              side: BorderSide(
                                                  color: Colors.cyan)
                                          )
                                      )
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (!mobile_number.text.isEmpty) {
                                        if (mobile_number.text.length != 10) {
                                          utils.showToast(context,
                                              s.mobile_number_must_be_of_10_digits);
                                        }
                                        else {
                                          if (widget.isForgotPassword ==
                                              "forgot_password") {
                                            FORGOT_PASSWORD_send_otp(context);
                                          }
                                          else if (widget.isForgotPassword ==
                                              "change_password") {
                                            change_password_send_otpParams(
                                                context);
                                          }
                                          else {
                                            send_otp(context);
                                          }
                                        }

                                        /*if(mobile_number.text.length!=10)
                                          {
                                            utils.showToast(context,'Mobile Number must be of 10 digit');
                                          }
                                        else
                                          {
                                            print('SEND OTP');
                                            tcVisibility=!tcVisibility;
                                            visibility=!visibility;
                                          }*/

                                      }
                                      else {
                                        utils.showAlert(context,
                                            s.enter_a_valid_mobile_number);
                                      }
                                    });
                                  },
                                )
                            ),
                          ),
                        ),),
                      //Change Password
                    ]
                  //OTP VERIFICATION
                ),
                Visibility(
                  visible: tcVisibility,
                  child: Padding(padding: EdgeInsets.only(bottom: 10),
                      child: Text(s.otp_verification, style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black))
                  ),),
                Visibility(
                  visible: tcVisibility,
                  child: Padding(padding: EdgeInsets.only(bottom: 15),
                      child: Text(s.please_verify_otp, style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                          color: Colors.black), textAlign: TextAlign.center)
                  ),),
                Visibility(
                  visible: tcVisibility,
                  child: Padding(padding: EdgeInsets.only(top: 20),
                    child: Container(
                        height: 55,
                        decoration: new BoxDecoration(
                            color: c.ca2,
                            border: Border.all(color: c.ca2, width: 2),
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(10),
                              topRight: const Radius.circular(10),
                              bottomLeft: const Radius.circular(10),
                              bottomRight: const Radius.circular(10),
                            )),
                        child: TextField(
                          maxLength: 6,
                          controller: otp,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            // suffixIcon: Icon(Icons.visibility_off_outlined),
                              contentPadding: EdgeInsets.only(
                                  top: 45, left: 15),
                              isDense: true,
                              border: InputBorder.none,
                              hintText: s.otp
                          ),
                        )
                    ),),),
                Visibility(
                  visible: tcVisibility,
                  child: Padding(padding: EdgeInsets.only(left: 200),
                    child: SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: Container(
                          child: TextButton(
                            child: Text(
                              s.resend_otp, style: TextStyle(color: c
                                .colorAccent), textAlign: TextAlign.end,),
                            /*style: ButtonStyle(
                                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                                  backgroundColor: MaterialStateProperty.all<Color>(c.colorPrimary),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(25),
                                            topRight: Radius.circular(25),
                                            bottomLeft: Radius.circular(25),
                                            bottomRight: Radius.circular(25),
                                          ),
                                          side: BorderSide(color: Colors.cyan)
                                      )
                                  )
                              ),*/
                            onPressed: () {
                              setState(() {
                                if (widget.isForgotPassword ==
                                    "forgot_password") {
                                  ResendOtpForgotPasswordParams(context);
                                }
                                else if (widget.isForgotPassword ==
                                    "change_password") {
                                  change_password_Resend_otpParams(context);
                                }
                                else {
                                  resend_otp(context);
                                }
                              });
                            },
                          )
                      ),
                    ),
                  ),),
                Visibility(
                  visible: tcVisibility,
                  child: Padding(padding: EdgeInsets.only(top: 20),
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Container(
                          child: TextButton(
                            child: Text(s.verify, style: TextStyle(color: c
                                .white)),
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.all(15)),
                                backgroundColor: MaterialStateProperty.all<
                                    Color>(c.colorPrimary),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(25),
                                          topRight: Radius.circular(25),
                                          bottomLeft: Radius.circular(25),
                                          bottomRight: Radius.circular(25),
                                        ),
                                        side: BorderSide(color: Colors.cyan)
                                    )
                                )
                            ),
                            onPressed: () {
                              setState(() {
                                if (!otp.text.isEmpty) {
                                  if (otp.text.length == 6) {
                                    if (widget.isForgotPassword ==
                                        "forgot_password") {
                                      FORGOT_PASSWORD_OTP_Params(context);
                                    }
                                    else if (widget.isForgotPassword ==
                                        "change_password") {
                                      change_password_OTP_Params(context);
                                    }
                                    else {
                                      otp_params(context);
                                    }
                                  }
                                  else {
                                    utils.showToast(
                                        context, 'OTP Must be 6 characters');
                                  }
                                }
                                else {
                                  utils.showToast(
                                      context, 'OTP Must be filled');
                                }
                              });
                            },
                          )
                      ),
                    ),
                  ),),
                Visibility(
                  visible: tvisibility,
                  child: Padding(padding: EdgeInsets.only(bottom: 30),
                      child: Text('Change Password', style: TextStyle(
                          fontSize: 18,
                          color: c.black,
                          fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center)
                  ),),
                Visibility(
                  visible: tvisibility,
                  child: Padding(padding: EdgeInsets.only(top: 20),
                      child: Text(
                          'Please Enter New Password and Confirm Password',
                          style: TextStyle(fontWeight: FontWeight.normal,
                              fontSize: 15,
                              color: Colors.black), textAlign: TextAlign.center)
                  ),),
                Visibility(
                  visible: tvisibility,
                  child: Padding(padding: EdgeInsets.only(top: 20),
                    child: Container(
                        height: 50,
                        decoration: new BoxDecoration(
                            color: c.ca2,
                            border: Border.all(color: c.ca2, width: 2),
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(10),
                              topRight: const Radius.circular(10),
                              bottomLeft: const Radius.circular(10),
                              bottomRight: const Radius.circular(10),
                            )),
                        child: TextField(
                          maxLength: 15,
                          controller: new_password,
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                              suffixIcon: Icon(Icons.visibility_off_outlined),
                              contentPadding: EdgeInsets.only(
                                  top: 35, left: 15),
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Enter New Password'
                          ),
                        )
                    ),
                  ),),
                Visibility(
                  visible: tvisibility,
                  child: Padding(padding: EdgeInsets.only(top: 25.0),
                    child: Container(
                        height: 50,
                        decoration: new BoxDecoration(
                            color: c.ca2,
                            border: Border.all(color: c.ca2, width: 2),
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(10),
                              topRight: const Radius.circular(10),
                              bottomLeft: const Radius.circular(10),
                              bottomRight: const Radius.circular(10),
                            )),
                        child: TextField(
                          maxLength: 15,
                          controller: confirm_password,
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                              suffixIcon: Icon(Icons.visibility_off_outlined),
                              contentPadding: EdgeInsets.only(
                                  top: 35, left: 15),
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Enter Confirm Password'
                          ),
                        )
                    ),),),
                Visibility(
                  visible: tvisibility,
                  child: Padding(padding: EdgeInsets.only(top: 80),
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Container(
                          child: TextButton(
                            child: Text('SUBMIT', style: TextStyle(color: c
                                .white)),
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.all(15)),
                                backgroundColor: MaterialStateProperty.all<
                                    Color>(c.colorPrimary),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(25),
                                          topRight: Radius.circular(25),
                                          bottomLeft: Radius.circular(25),
                                          bottomRight: Radius.circular(25),
                                        ),
                                        side: BorderSide(color: Colors.cyan)
                                    )
                                )
                            ),
                            onPressed: () {
                              setState(() {});
                              tcVisibility ? 'true' : 'false';
                              ValidatePassword();
                            },
                          )
                      ),
                    ),
                  ),)
              ],
            )
        )
    );
  }

  Future<void> ValidatePassword()async{
    if(new_password.text.length & confirm_password.text.length!=0)
    {
      if(new_password.text.length & confirm_password.text.length >=8)
      {
          if(await utils.isOnline())
            {
              if(widget.isForgotPassword=="forgot_password")
                {
                  forgot_password_Params(context);
                }
              else if(widget.isForgotPassword=="Change_password")
                {
                  changepassword(context);
                }
            }
      }
      else
      {
        utils.showToast(context, 'Password must be atleast 8 to 15 Characters');
      }
      if(new_password.text!=confirm_password.text)
      {
        utils.showToast(context, 'New Password and Confirm Password must be Same');
      }
      else
      {
        utils.showToast(context, 'Password Changed Successfully');
      }
    }
    else
    {
      utils.showToast(context, 'Password Field Must not be Empty');
    }
  }
    Future<dynamic> send_otp(BuildContext context) async {
    Map request={
      s.service_id:"ResendOtp",
      s.mobileNumber:mobile_number,
    };
    http.Response response = await http.post(url.open_service, body: jsonEncode(request));
    print("send_otp_url>>" + url.open_service.toString());
    print("otp>>" + request.toString());
    String data=response.body;
    print("otp_response>>"+data);
    var decodedData = json.decode(data);
    var STATUS = decodedData[s.status];
    var RESPONSE = decodedData[s.response];
    if (STATUS.toString() == s.key_ok && RESPONSE.toString() == "SUCCESS")
      {
        String mask=mobile_number.text.replaceAll("\\w(?=\\w{4})", "*");
        mobile_number.text=mask;
      }
    else
      {
        utils.showToast(context, "Failed");
      }
    }
    Future<void>resend_otp(BuildContext context) async {
      Map request={
        s.service_id:"ResendOtp",
        s.mobileNumber:mobile_number,
      };
      http.Response response = await http.post(url.open_service, body: jsonEncode(request));
      print("Resend_otp_url>>" + url.open_service.toString());
      print("Resendotp>>" + request.toString());
      String data=response.body;
      print("Resendotp_response>>"+data);
      var decodedData = json.decode(data);
      var STATUS = decodedData[s.status];
      var RESPONSE = decodedData[s.response];
      if (STATUS.toString() == s.key_ok && RESPONSE.toString() == "SUCCESS")
      {
          mobile_number.text="";
      }
      else
        {
          utils.showToast(context, "Failed");
        }
    }
    Future<dynamic> otp_params(BuildContext context) async {
    Map request={
      s.service_id:"VerifyOtp",
      s.mobileOTP:otp.text,
      s.mobileNumber:mobile_number,
    };
    http.Response response = await http.post(url.open_service, body: jsonEncode(request));
    print("otp_url>>" + url.open_service.toString());
    print("otp>>" + request.toString());
    String data=response.body;
    print("otp_response>>"+data);
    var decodedData = json.decode(data);
    var STATUS = decodedData[s.status];
    var RESPONSE = decodedData[s.response];
    if (STATUS.toString() == s.key_ok && RESPONSE.toString() == "SUCCESS")
    {
      tcVisibility = !tcVisibility;
      visibility = visibility;
      tvisibility = !tvisibility;
      utils.showToast(context, "SUCCESS");
    }
    else
    {
      utils.showToast(context, "Failed");
    }
  }
    Future<dynamic> FORGOT_PASSWORD_send_otp(BuildContext context) async {
    Map request = {
      s.service_id: "sendOTP_for_forgot_password",
      s.mobileNumber: mobile_number.text,
      s.key_appcode:"WI",
    };
    print(mobile_number.text);
    http.Response response = await http.post(url.open_service, body: jsonEncode(request));
    print("forgot_password_url>>" + url.open_service.toString());
    print("otp_request>>" + request.toString());
    String data = response.body;
    print("password_response>>" + data);
    var decodedData = json.decode(data);
    var STATUS = decodedData[s.status];
    var RESPONSE = decodedData[s.response];
    if (STATUS.toString() == s.key_ok && RESPONSE.toString() == "SUCCESS") {
      tcVisibility = !tcVisibility;
      visibility = !visibility;
      mobilenumber=mobile_number.text.toString();
      String mask=mobile_number.text.replaceAll("\\w(?=\\w{4})", "*");
      mobile_number.text=mask;
    }
  }
    Future<void> ResendOtpForgotPasswordParams(BuildContext context) async {
    Map request={
        s.service_id:"ResendOtpForgotPassword",
        s.mobileNumber: mobile_number.toString(),
        s.key_appcode:"WI",
    };
    print("Resend_Otp"+request.toString());
    http.Response response = await http.post(url.open_service, body: jsonEncode(request));
    print("Resend_forgot_password_url>>" + url.open_service.toString());
    print("Resend_forgot_password_request>>" + request.toString());
    String data = response.body;
    print("Resend_forgot_password_response>>" + data);
    var decodedData = json.decode(data);
    var STATUS = decodedData[s.status];
    var RESPONSE = decodedData[s.response];
    var KEY;
    if (STATUS.toString() == s.key_ok && RESPONSE.toString() == "SUCCESS") {
      otp.text="";
    }
    else
      {
        utils.showToast(context,"FAILED");
      }
  }
    Future<void> FORGOT_PASSWORD_OTP_Params(BuildContext context) async {
    Map request={
      s.service_id:"ForgotPasswordVerifyOtp",
      s.mobileNumber: mobile_number.toString(),
      s.mobileOTP:otp.text,
      s.key_appcode:"WI",
    };
    print("FORGOT_PASSWORD_OTP"+request.toString());
    http.Response response = await http.post(url.open_service, body: jsonEncode(request));
    print("FORGOT_PASSWORD_OTP_url>>" + url.open_service.toString());
    print("FORGOT_PASSWORD_OTP_request>>" + request.toString());
    String data = response.body;
    print("FORGOT_PASSWORD_OTP_response>>" + data);
    var decodedData = json.decode(data);
    var STATUS = decodedData[s.status];
    var RESPONSE = decodedData[s.response];
    var KEY;
    if (STATUS.toString() == s.key_ok && RESPONSE.toString() == "SUCCESS") {
            mobilenumber=mobile_number.text.toString();
            Otp=otp.text.toString();
            tcVisibility = !tcVisibility;
            visibility = visibility;
            tvisibility = !tvisibility;

    }
    else
    {
      utils.showToast(context,"FAILED");
    }
  }
    Future<void>forgot_password_Params(BuildContext context) async {
    Map request={
      s.service_id:"ForgotPassword",
      s.mobileNumber: mobile_number.toString(),
      s.mobileOTP:otp.text,
      s.key_appcode:"WI",
    };
    print("forgot_password"+request.toString());
    http.Response response = await http.post(url.open_service, body: jsonEncode(request));
    print("forgot_password_url>>" + url.open_service.toString());
    print("forgot_password_request>>" + request.toString());
    String data = response.body;
    print("forgot_password_response>>" + data);
    var decodedData = json.decode(data);
    var STATUS = decodedData[s.status];
    var RESPONSE = decodedData[s.response];
    var KEY;
    if (STATUS.toString() == s.key_ok && RESPONSE.toString() == "SUCCESS") {
      mobilenumber=mobile_number.text.toString();
      Otp=otp.text.toString();
    }
    else
    {
      utils.showToast(context,"FAILED");
    }
  }
    Future<void>change_password_send_otpParams(BuildContext context) async {
      late Map json_request;
      json_request = {
        s.service_id:"sendOTP_for_change_password",
        s.mobileNumber:mobile_number.text.toString(),
      };

      Map encrypted_request = {
        s.user_name: prefs.getString(s.user_name),
        s.data_content:
        utils.encryption(jsonEncode(json_request), userDecryptKey),
      };
      http.Response response = await http.post(url.main_service, body: json.encode(encrypted_request));
      String data=response.body;
      print("Change_password_otp"+data);
      print("change_password_send_otp_url>>" + url.main_service.toString());
      print("change_password_send_otp_request_json>>" + json_request.toString());
      print("change_password_send_otp_request_encrypt>>" + encrypted_request.toString());
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrypt_data = utils.decryption(enc_data, userDecryptKey);
      var userData = jsonDecode(decrypt_data);
      var status = userData[s.status];
      var response_value = userData[s.response];
      if (status == s.key_ok && response_value == s.key_ok) {
        mobilenumber=mobile_number.text.toString();
        String mask=mobile_number.text.replaceAll("\\w(?=\\w{4})", "*");
        mobile_number.text=mask;
      }
      else
      {
        utils.showToast(context,"FAILED");
      }
  }
    Future<void>change_password_Resend_otpParams(BuildContext context) async {
    late Map json_request;
    json_request = {
      s.service_id:"ResendOtpChangePassword",
      s.mobileNumber:mobile_number.text.toString(),
    };

    Map encrypted_request = {
      s.user_name: prefs.getString(s.user_name),
      s.data_content:
      utils.encryption(jsonEncode(json_request), userDecryptKey),
    };
    http.Response response = await http.post(url.main_service, body: json.encode(encrypted_request));
    String data=response.body;
    print("Change_password_Resend_otp"+data);
    print("change_password_Resend_otp_url>>" + url.main_service.toString());
    print("change_password_Resend_otp_request_json>>" + json_request.toString());
    print("change_password_Resend_otp_request_encrypt>>" + encrypted_request.toString());
    var jsonData = jsonDecode(data);
    var enc_data = jsonData[s.key_enc_data];
    var decrpt_data = utils.decryption(enc_data, userDecryptKey);
    var userData = jsonDecode(decrpt_data);
    var status = userData[s.status];
    var response_value = userData[s.response];
    if (status == s.key_ok && response_value == s.key_ok) {
      utils.showToast(context, "SUCCESS");
    }
    else
    {
      utils.showToast(context,"FAILED");
    }
  }
    Future<void> change_password_OTP_Params(BuildContext context) async {
    late Map json_request;
    json_request = {
      s.service_id:"ChangePasswordVerifyOtp",
      s.mobileNumber:mobile_number.text.toString(),
      s.mobileOTP:otp.text.toString(),
    };

    Map encrypted_request = {
      s.user_name: prefs.getString(s.user_name),
      s.data_content:
      utils.encryption(jsonEncode(json_request), userDecryptKey),
    };
    http.Response response = await http.post(url.main_service, body: json.encode(encrypted_request));
    String data=response.body;
    print("Change_password_otp"+data);
    print("change_password_send_otp_url>>" + url.main_service.toString());
    print("change_password_send_otp_request_json>>" + json_request.toString());
    print("change_password_send_otp_request_encrypt>>" + encrypted_request.toString());
    var jsonData = jsonDecode(data);
    var enc_data = jsonData[s.key_enc_data];
    var decrpt_data = utils.decryption(enc_data, userDecryptKey);
    var userData = jsonDecode(decrpt_data);
    var status = userData[s.status];
    var response_value = userData[s.response];
    if (status == s.key_ok && response_value == s.key_ok) {
      utils.showToast(context, "SUCCESS");
      tcVisibility = !tcVisibility;
      visibility = visibility;
      tvisibility = !tvisibility;
    }
    else
    {
      utils.showToast(context,"FAILED");
    }
  }
  Future <void>changepassword(BuildContext context) async
  {
    Map request={
      s.service_id:"ChangePassword",
      s.mobileNumber: mobilenumber,
      s.mobileOTP:Otp,
      s.newpassword:"new_password",
      s.confirmpassword:"confirm_password"
    };
    print("changepassword"+request.toString());
    http.Response response = await http.post(url.open_service, body: jsonEncode(request));
    print("changepassword_url>>" + url.open_service.toString());
    print("changepassword_request>>" + request.toString());
    String data = response.body;
    print("changepassword_response>>" + data);
    var decodedData = json.decode(data);
    var STATUS = decodedData[s.status];
    var RESPONSE = decodedData[s.response];
    var KEY;
    if (STATUS.toString() == s.key_ok && RESPONSE.toString() == "SUCCESS") {
     utils.showToast(context, "SUCCESS");
    }
    else
    {
      utils.showToast(context,"FAILED");
    }
  }
    Widget showButton() {
      return Container(
        child: Visibility(
          visible: true,
          child: Padding(padding: EdgeInsets.all(15.0),
            child: Container(
                height: 40,
                decoration: new BoxDecoration(
                    color: c.ca2,
                    border: Border.all(color: c.ca2, width: 2),
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10),
                      topRight: const Radius.circular(10),
                      bottomLeft: const Radius.circular(10),
                      bottomRight: const Radius.circular(10),
                    )),
                alignment: AlignmentDirectional.center,
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                      suffixIcon: Icon(Icons.visibility_off_outlined),
                      contentPadding: EdgeInsets.all(10.0),
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Enter Confirm Password'
                  ),
                )
            ),),),
      );
    }
  }
