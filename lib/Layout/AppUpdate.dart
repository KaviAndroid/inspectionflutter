import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/utils.dart';


class AppUpdate extends StatefulWidget {
  final type;
  final url;
  AppUpdate({this.type,this.url});

  @override
  State<AppUpdate> createState() => _AppUpdateState();
}

class _AppUpdateState extends State<AppUpdate> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var type;

  @override
  void initState(){
    super.initState();
    initialize();
    // utils.gotoLoginPageFromSplash(context);
  }
  Future<void> initialize() async {
    prefs =  await SharedPreferences.getInstance();
    type=widget.type;
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body:Container(
          alignment: Alignment.center,
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
              Expanded(
                flex: 3,
                child: Container(
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
                          ? imagePath.download
                          : type == "S"
                          ? imagePath.success
                          : imagePath.error,
                      height: type == "W" ? 60 : 200,
                      width: type == "W" ? 60 : 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
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
                                ? "Download"
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
                        Text(s.download_apk,
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
                              type == "W" || type == "E" ? true : false,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        c.primary_text_color2),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(15),
                                        ))),
                                onPressed: () {
                                  utils.launchURL(prefs.getString(s.download_apk).toString());
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
              )
            ],
          ),
        ),);
  }
}
