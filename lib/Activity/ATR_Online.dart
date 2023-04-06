// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspection_flutter_app/Resources/global.dart';
import 'package:inspection_flutter_app/Utils/utils.dart';
import 'package:intl/intl.dart';
import '../Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class ATR_Worklist extends StatefulWidget {
  @override
  State<ATR_Worklist> createState() => _ATR_WorklistState();
}

class _ATR_WorklistState extends State<ATR_Worklist> {
  List<DateTime>? selectedDateRange;

  // Controller Text
  TextEditingController dateController = TextEditingController();

  // Strings

  String SDBText = "Block";
  String totalWorksCount = "0";

  @override
  void initState() {
    dateController.text = ""; //set the initial value of text field
    super.initState();
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
          title: Text(s.work_list),
          centerTitle: true, // like this!
        ),
        body: SingleChildScrollView(
          child: Container(
            color: c.colorAccentverylight,
            constraints: BoxConstraints(
              minHeight: sceenHeight - 100,
            ),
            child: Column(
              children: [
                __ATR_Dashboard_Design(),
              ],
            ),
          ),
        ));
  }

  // *************************** Date  Functions Starts here *************************** //

  Future<void> dateValidation() async {
    if (selectedDateRange != null) {
      DateTime sD = selectedDateRange![0];
      DateTime eD = selectedDateRange![1];

      String startDate = DateFormat('dd-MM-yyyy').format(sD);
      String endDate = DateFormat('dd-MM-yyyy').format(eD);

      // if (startDate.compareTo(endDate) == 0) {
      //   print("Both date time are at same moment.");
      // }

      if (startDate.compareTo(endDate) > 0) {
        dateController.text = s.select_from_to_date;
      } else {
        dateController.text = "$startDate  To  $endDate";
      }
    }
  }

  Future<void> selectDateFunc() async {
    selectedDateRange = await showOmniDateTimeRangePicker(
      context: context,
      type: OmniDateTimePickerType.date,
      startInitialDate: DateTime.now(),
      startFirstDate: DateTime(2000).subtract(const Duration(days: 3652)),
      startLastDate: DateTime.now().add(
        const Duration(days: 3652),
      ),
      endInitialDate: DateTime.now(),
      endFirstDate: DateTime(2000).subtract(const Duration(days: 3652)),
      endLastDate: DateTime.now().add(
        const Duration(days: 3652),
      ),
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0,
              end: 1,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
    );
    dateValidation();
  }

  // *************************** Date  Functions Ends here *************************** //

  // *************************** Date  Functions Ends here *************************** //

  __ATR_Dashboard_Design() {
    return Container(
      height: 280,
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          Container(
            width: screenWidth * 0.9,
            height: 200,
            margin:
                const EdgeInsets.only(top: 50, bottom: 10, left: 20, right: 20),
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
            decoration: BoxDecoration(
                color: c.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 5.0,
                  ),
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(SDBText,
                      style: GoogleFonts.montserrat().copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: c.text_color)),
                ),
                Text(s.total_inspection_works + totalWorksCount,
                    style: GoogleFonts.montserrat().copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: c.text_color)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Container(
                          height: 70,
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: c.need_improvement,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0.0, 1.0), //(x,y)
                                  blurRadius: 5.0,
                                ),
                              ]),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(s.need_improvement,
                                    style: GoogleFonts.montserrat().copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: c.white)),
                                Text(totalWorksCount,
                                    style: GoogleFonts.montserrat().copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: c.white)),
                              ])),
                    ),
                    Expanded(
                      child: Container(
                          height: 70,
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: c.unsatisfied,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0.0, 3.0), //(x,y)
                                  blurRadius: 5.0,
                                ),
                              ]),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(s.un_satisfied,
                                    style: GoogleFonts.montserrat().copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: c.white)),
                                Text(totalWorksCount,
                                    style: GoogleFonts.montserrat().copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: c.white)),
                              ])),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 25),
            width: 200,
            child: TextField(
              controller: dateController, //editing controller of this TextField
              style: TextStyle(
                color: c.primary_text_color2,
                fontWeight: FontWeight.w800,
                fontSize: 10.5,
              ),
              decoration: InputDecoration(
                hintStyle: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.2,
                    color: c.primary_text_color2),
                hintText: s.select_from_to_date,
                prefixIconColor: c.calender_color,
                prefixIcon: IconButton(
                    onPressed: () async {
                      selectDateFunc();
                    },
                    icon: Icon(Icons.calendar_month_rounded)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                filled: true,
                fillColor: c.need_improvement1,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: c.need_improvement),
                    borderRadius: BorderRadius.circular(30.0)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: c.need_improvement),
                    borderRadius: BorderRadius.circular(30.0)),
              ),
              readOnly:
                  true, //set it true, so that user will not able to edit text
              onTap: () async {
                selectDateFunc();
              },
            ),
          )
        ],
      ),
    );
  }

  // *************************** Date  Functions Ends here *************************** //
}
