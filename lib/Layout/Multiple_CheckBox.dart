import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspection/Layout/Multiple_CheckBox.dart';
import 'package:inspection/Utils/utils.dart';
import '../ModelClass/checkBoxModelClass.dart';
import 'package:inspection/Resources/Strings.dart' as s;
import 'package:inspection/Resources/ColorsValue.dart' as c;

class FlutterCustomCheckbox extends StatefulWidget {
  List<FlutterLimitedCheckBoxModel> initialValueList;
  String message;
  int limitCount;
  final flag;
  Function(List<FlutterLimitedCheckBoxModel> selectedList) onChanged;

  FlutterCustomCheckbox({
    Key? key,
    this.flag,
    required this.initialValueList,
    required this.onChanged,
    required this.message,
    required this.limitCount,
  }) : super(key: key);

  @override
  _FlutterLimitedCheckboxState createState() => _FlutterLimitedCheckboxState();
}

class _FlutterLimitedCheckboxState extends State<FlutterCustomCheckbox> {
  List<FlutterLimitedCheckBoxModel> checkedList = [];
  Utils utils = Utils();
  bool selectallflag = false;

  void _onClickFunction(int index, String type) {
    if (type == "Select All") {
      if (selectallflag) {
        for (var item in widget.initialValueList) {
          item.isSelected = true;
        }
        checkedList = widget.initialValueList.toList();
      } else {
        for (var item in widget.initialValueList) {
          item.isSelected = false;
        }
        checkedList = [];
      }
    } else {
      if (widget.initialValueList[index].isSelected == false) {
        var checker = widget.initialValueList
            .where((element) => element.isSelected == true)
            .toList()
            .length;
        if (checker < widget.limitCount) {
          widget.initialValueList[index].isSelected = true;
        }
      } else {
        widget.initialValueList[index].isSelected = false;
      }

      checkedList = widget.initialValueList
          .where((element) => element.isSelected == true)
          .toList();

      if (widget.initialValueList.length == checkedList.length) {
        selectallflag = true;
      } else {
        selectallflag = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: widget.message == s.select_scheme
            ? EdgeInsets.all(20)
            : EdgeInsets.only(
                left: 30,
                right: 30,
                top: MediaQuery.of(context).size.height / 4,
                bottom: MediaQuery.of(context).size.height / 4),
        child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: new TextSpan(
                            // Note: Styles for TextSpans must be explicitly defined.
                            // Child text spans will inherit styles from parent
                            style: GoogleFonts.getFont('Roboto',
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: c.grey_8),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: widget.message,
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: c.grey_8)),
                              new TextSpan(
                                  text: widget.limitCount == 2
                                      ? " (Any Two)"
                                      : "",
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: c.subscription_type_red_color)),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: widget.flag == "select_all" ? true : false,
                          child: Container(
                            margin: EdgeInsets.only(left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Checkbox(
                                  value: selectallflag,
                                  onChanged: (value) {
                                    setState(() {
                                      selectallflag = !selectallflag;
                                      _onClickFunction(0, "Select All");
                                    });
                                  },
                                ),
                                Text(
                                  s.select_all,
                                  style: GoogleFonts.getFont('Roboto',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: c.grey_8),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: ListView.builder(
                              itemCount: widget.initialValueList.length,
                              itemBuilder: (context, index) => Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _onClickFunction(index, "Single");
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Checkbox(
                                              value: widget
                                                  .initialValueList[index]
                                                  .isSelected,
                                              onChanged: (v) {
                                                setState(() {
                                                  _onClickFunction(
                                                      index, "Single");
                                                });
                                              },
                                            ),
                                            Expanded(
                                                child: Text(
                                              widget.initialValueList[index]
                                                  .selectTitle,
                                            ))
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      )
                                    ],
                                  ))),
                    ),
                    InkWell(
                        onTap: () {
                          if (checkedList.length > 0) {
                            widget.onChanged(checkedList);
                            //After Click ok button remove the initial values.
                            for (var item in widget.initialValueList) {
                              item.isSelected = false;
                            }
                            Navigator.pop(context, 'OK');
                          } else {
                            utils.customAlertWidet(context, "Error",
                                "Please select at least one option.");
                          }
                        },
                        child: Container(
                          alignment: AlignmentDirectional.bottomEnd,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: Text(
                              s.key_ok,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: c.primary_text_color2,
                                  fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ))
                  ],
                ))));
  }
}
