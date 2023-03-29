import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../DataBase/DbHelper.dart';
import '../Utils/utils.dart';

class RdprOnlineWorkList extends StatefulWidget {
  const RdprOnlineWorkList({Key? key}) : super(key: key);

  @override
  State<RdprOnlineWorkList> createState() => _RdprOnlineWorkListState();
}

class _RdprOnlineWorkListState extends State<RdprOnlineWorkList> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  List finYear=[];
  String selectedFinYear="";

  @override
  void initState() {
    super.initState();
    initialize();
  }
  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    setState(() {
      finYear = dbClient.rawQuery('SELECT * FROM '+s.table_FinancialYear);
    });
  }
  Future<bool> _onWillPop() async {
    Navigator.of(context, rootNavigator: true).pop(context);
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child:Scaffold(
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
                    child:Container(
                      transform: Matrix4.translationValues(-30.0, 0.0, 0.0),
                      alignment: Alignment.center,
                      child: Text(
                        s.financial_year,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: Text(
                  'Select Fin Year',
                  style: GoogleFonts.raleway().copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.black),
                ),
              ),
              DropdownButtonFormField2(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 0.1, color: c.white),
                      borderRadius: BorderRadius.circular(10.0)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: c.white),
                      borderRadius: BorderRadius.circular(10.0)),
                ),
                isExpanded: true,
                // hint: const Text(
                //   'Select Your Gender',
                //   style: TextStyle(fontSize: 14),
                // ),
                items: finYear.isNotEmpty
                    ? finYear
                    .map((item) => DropdownMenuItem<String>(
                  value: item['bcode'].toString(),
                  child: Text(
                    item['bname'].toString(),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ))
                    .toList()
                    : null,
                validator: (value) {
                  if (value == null) {
                    return 'Please select Financial Year';
                  }
                  return null;
                },
                onChanged: (value) {
                  //Do something when changing the item if you want.
                },
                onSaved: (value) {
                  selectedFinYear = value.toString();
                },
                buttonStyleData: const ButtonStyleData(
                  height: 45,
                  padding: EdgeInsets.only(right: 10),
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black45,
                  ),
                  iconSize: 30,
                ),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),

      ),);
  }
}
