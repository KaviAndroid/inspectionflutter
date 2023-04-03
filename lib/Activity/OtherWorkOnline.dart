import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/Login.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Utils/utils.dart';
import '../Resources/ColorsValue.dart' as c;

class OtherWorkOnline extends StatefulWidget {
  @override
  State<OtherWorkOnline> createState() => _OtherWorkOnlineState();
}
class _OtherWorkOnlineState extends State<OtherWorkOnline> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: c.colorPrimary,
        centerTitle: true,
        elevation: 2,
        title: Center(

    )
    )
    );
  }

}