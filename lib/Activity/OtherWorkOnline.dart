import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/io_client.dart';
import 'package:inspection_flutter_app/Activity/Login.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../DataBase/DbHelper.dart';
import '../Utils/utils.dart';
import '../Resources/ColorsValue.dart' as c;

class OtherWorkOnline extends StatefulWidget {
  @override
  State<OtherWorkOnline> createState() => _OtherWorkOnlineState();

}
class _OtherWorkOnlineState extends State<OtherWorkOnline> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  List finYearItems=[];
  List distictItems=[];
  String selectedFinYear="";
  String selectedDistrict="";
  bool isLoadingFinYear = false;
  bool isLoadingDistrict = false;
  bool finYearError = false;
  bool districtError=false;

  Map<String, String> defaultSelectedFinYear = {
    s.key_fin_year: s.select_financial_year,
  };
  Map<String, String> defaultSelectedDistrict = {
    s.key_dcode:"0",
    s.key_dname: s.selectDistrict,
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
                                getDistrictList();
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

              //District List
              Visibility( visible: true,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Padding(
                padding:
                const EdgeInsets.only(top: 15, bottom: 15),
                child: Text(
                  s.selectDistrict,
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
                   width: districtError ? 1 : 0.1,
                   color: districtError ? c.red : c.grey_10),
               borderRadius: BorderRadius.circular(10.0)
           ),
           child: IgnorePointer(
             ignoring:  isLoadingDistrict? true : false,
             child: DropdownButtonHideUnderline(
               child: DropdownButton2(
                 style:
                 const TextStyle(color: Colors.black),
                 value: selectedDistrict,
                 isExpanded: true,
                 items: distictItems
                     .map((item) =>
                     DropdownMenuItem<String>(
                       value: item[s.key_dname].toString(),
                       child: Text(
                         item[s.key_dname].toString(),
                         style: const TextStyle(
                           fontSize: 14,
                         ),
                       ),
                     ))
                     .toList(),
                 onChanged: (value) {
                   if (value != s.selectDistrict) {
                     isLoadingDistrict = false;
                     districtError = false;
                     selectedDistrict = value.toString();
                     setState(() {});
                   } else {
                     setState(() {
                       selectedDistrict = value.toString();
                       districtError = true;
                     });
                   }
                 },
                 buttonStyleData: const ButtonStyleData(
                   height: 45,
                   padding: EdgeInsets.only(right: 10),
                 ),
                 iconStyleData: IconStyleData(
                   icon: isLoadingDistrict
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
                        visible: districtError ? true : false,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Please Select District',
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
]
      ),)
    )
    );
  }
  Future<void> getDistrictList() async {
    Map jsonRequest;
    jsonRequest = {
      s.key_service_id: s.service_key_district_list_all,
    };

    HttpClient _client = HttpClient(context: await Utils().globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response =
    await _ioClient.post(url.open_service, body: json.encode(jsonRequest));

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var responseData = response.body;
      var data = jsonDecode(responseData);

      var status = data[s.key_status];
      var responseValue = data[s.key_response];

      if (status == s.key_ok && responseValue == s.key_ok) {
        distictItems = [];
        distictItems.add(selectedDistrict);
        distictItems.addAll(data[s.key_json_data]);
      }
    }
  }

  }

