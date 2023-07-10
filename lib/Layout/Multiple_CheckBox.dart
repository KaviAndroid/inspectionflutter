import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspection_flutter_app/Layout/Multiple_CheckBox.dart';
import '../ModelClass/checkBoxModelClass.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;

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
  bool selectallflag = false;
  void _onClickFunction(int index) {
    if (selectallflag == true) {
      checkedList = widget.initialValueList
          .where((element) => element.isSelected == false)
          .toList();
    }

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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(20),
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
                                  text: widget.message == 2 ? " (Any Two)" : "",
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
                                            _onClickFunction(index);
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Checkbox(
                                              value: !selectallflag
                                                  ? widget
                                                      .initialValueList[index]
                                                      .isSelected
                                                  : true,
                                              onChanged: (v) {
                                                setState(() {
                                                  !selectallflag
                                                      ? widget
                                                          .initialValueList[
                                                              index]
                                                          .isSelected
                                                      : true;
                                                  _onClickFunction(index);
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
                          if (selectallflag == true) {
                            checkedList = widget.initialValueList
                                .where((element) => element.isSelected == false)
                                .toList();
                            widget.onChanged(checkedList);
                          } else {
                            widget.onChanged(checkedList);
                          }
                          //After Click ok button remove the initial values.
                          for (var item in widget.initialValueList) {
                            item.isSelected = false;
                          }
                          Navigator.pop(context, 'OK');
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
