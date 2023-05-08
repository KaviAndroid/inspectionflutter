import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/WorkList.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../DataBase/DbHelper.dart';
import '../Layout/ReadMoreLess.dart';
import '../Utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class VillageListFromGeoLocation extends StatefulWidget {
  final villageList;
  VillageListFromGeoLocation({this.villageList});
  @override
  State<VillageListFromGeoLocation> createState() =>
      _VillageListFromGeoLocationState();
}

class _VillageListFromGeoLocationState
    extends State<VillageListFromGeoLocation> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  bool noDataFlag = false;
  bool villageListFlag = false;

  @override
  void initState() {
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    if (widget.villageList.length > 0) {
      noDataFlag = false;
      villageListFlag = true;
    } else {
      noDataFlag = true;
      villageListFlag = false;
    }
    setState(() {});
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context, rootNavigator: true).pop(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: c.colorPrimary,
            centerTitle: true,
            elevation: 2,
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: Container(
                      transform: Matrix4.translationValues(-30.0, 0.0, 0.0),
                      alignment: Alignment.center,
                      child: Text(
                        s.village_list,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            color: c.white,
            child:Stack(children: [
            Visibility(
              visible: villageListFlag,
              child: Container(
                color: c.white,
                margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: ListView.builder(
                  itemCount: widget.villageList == null
                      ? 0
                      : widget.villageList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        List schemeItems = [];
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WorkList(
                                  schemeList: schemeItems,
                                  finYear:'',
                                  dcode: widget.villageList[index][s.key_dcode].toString(),
                                  bcode: widget.villageList[index][s.key_bcode].toString(),
                                  pvcode:widget.villageList[index][s.key_pvcode].toString(),
                                  scheme:  '',
                                  tmccode: '',
                                  townType: '',
                                  flag: 'geo',
                                  selectedschemeList:[],
                                )));
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        // clipBehavior is necessary because, without it, the InkWell's animation
                        // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                        // This comes with a small performance cost, and you should not set [clipBehavior]
                        // unless you need it.
                        clipBehavior: Clip.hardEdge,
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: IntrinsicHeight(
                    child:Row(
                          children: [
                            Container(
                              width: 10,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(10),
                                    topRight: const Radius.circular(0),
                                    bottomLeft: const Radius.circular(10),
                                    bottomRight: const Radius.circular(0),
                                  ),
                                  gradient: LinearGradient(
                                      colors: [
                                        c.colorPrimary,
                                        c.colorAccentverylight,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight)),
                              child: Text(
                                "",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: c.grey_10),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.villageList[index][s.key_pvname],
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: c.grey_10),
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Visibility(
              visible: noDataFlag,
              child: Align(
                alignment: AlignmentDirectional.center,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    s.no_village,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            )
          ]),),
        ));
  }

}

