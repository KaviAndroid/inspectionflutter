// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unnecessary_new

import 'dart:convert';
import 'package:InspectionAppNew/Resources/Strings.dart' as s;
import 'package:flutter/material.dart';
import 'package:InspectionAppNew/Resources/global.dart';
import '../Resources/ColorsValue.dart' as c;
import '../DataBase/DbHelper.dart';

class ViewImage extends StatefulWidget {
  final workList;
  ViewImage({this.workList});

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  var dbHelper = DbHelper();
  var dbClient;

  var imageList = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    dbClient = await dbHelper.db;

    List recievedWorkList = widget.workList;

    String flag = recievedWorkList[0][s.key_flag];
    String workid = recievedWorkList[0][s.key_work_id];
    String dcode = recievedWorkList[0][s.key_dcode];
    String rural_urban = recievedWorkList[0][s.key_rural_urban];
    String inspection_id = recievedWorkList[0][s.key_inspection_id];

    String conditionParam = "";

    if (flag == "ATR") {
      conditionParam =
          "WHERE flag='$flag' and rural_urban='$rural_urban' and work_id='$workid' and inspection_id='$inspection_id' and dcode='$dcode'";
    } else {
      conditionParam =
          "WHERE flag='$flag' and rural_urban='$rural_urban' and work_id='$workid' and dcode='$dcode'";
    }

    imageList = await dbClient
        .rawQuery("SELECT * FROM ${s.table_save_images} $conditionParam");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: c.colorPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(context),
          ),
          title: Text(s.pending_list),
          centerTitle: true, // like this!
        ),
        body: Container(
          width: screenWidth,
          height: sceenHeight - 100,
          color: c.background_color,
          child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(10),
              children: List.generate(imageList.length, (index) {
                return Card(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: MemoryImage(
                            Base64Decoder().convert(imageList[index]['image'])),
                      ),
                    ),
                  ),
                );
              })),
        ));
  }
}
