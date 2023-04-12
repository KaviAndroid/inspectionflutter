import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import '../Resources/global.dart';
import '../Utils/utils.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Utils utils = Utils();

  @override
  void initState() {
    super.initState();
    utils.gotoLoginPageFromSplash(context);
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
}
