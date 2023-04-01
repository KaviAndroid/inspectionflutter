
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  List finYearItems=[];
  String selectedFinYear="";
  bool isLoadingFinYear = false;
  bool finYearError = false;

  Map<String, String> defaultSelectedFinYear = {
    s.key_fin_year: s.select_financial_year,
  };

  @override
  void initState() {
    super.initState();
    initialize();
  }
  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM '+s.table_FinancialYear);
    print(list.toString());
    finYearItems.add(defaultSelectedFinYear);
    finYearItems.addAll(list);
    selectedFinYear = defaultSelectedFinYear[s.key_fin_year]!;
    print(finYearItems.toString());
    setState(() {
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
                        s.filter_work_list,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body:Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            color: c.white,
            child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 15, bottom: 15),
                      child: Text(
                        s.select_financial_year,
                        style: GoogleFonts.raleway().copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: c.grey_8),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: c.grey_out,
                          border: Border.all(
                              width: finYearError ? 1 : 0.1,
                              color: finYearError ? c.red : c.grey_10),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: IgnorePointer(
                        ignoring: isLoadingFinYear ? true : false,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            style:
                            const TextStyle(color: Colors.black),
                            value: selectedFinYear,
                            isExpanded: true,
                            items: finYearItems
                                .map((item) =>
                                DropdownMenuItem<String>(
                                  value: item[s.key_fin_year].toString(),
                                  child: Text(
                                    item[s.key_fin_year].toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                                .toList(),
                            onChanged: (value) {
                              if (value != s.select_financial_year) {
                                isLoadingFinYear = false;
                                finYearError = false;
                                selectedFinYear = value.toString();
                                setState(() {});
                              } else {
                                setState(() {
                                  selectedFinYear = value.toString();
                                  finYearError = true;
                                });
                              }
                            },
                            buttonStyleData: const ButtonStyleData(
                              height: 45,
                              padding: EdgeInsets.only(right: 10),
                            ),
                            iconStyleData: IconStyleData(
                              icon: isLoadingFinYear
                                  ? SpinKitCircle(
                                color: c.colorPrimary,
                                size: 30,
                                duration: const Duration(
                                    milliseconds: 1200),
                              )
                                  : const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black45,
                              ),
                              iconSize: 30,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Visibility(
                      visible: finYearError ? true : false,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Please Select Financial Year',
                          // state.hasError ? state.errorText : '',
                          style: TextStyle(
                              color: Colors.redAccent.shade700,
                              fontSize: 12.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),

      ),);
  }
}
