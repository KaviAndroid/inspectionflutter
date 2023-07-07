import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspection_flutter_app/Layout/Multiple_CheckBox.dart';
import 'checkBoxModelClass.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;

class FlutterCustomCheckbox extends StatefulWidget {
  List<FlutterLimitedCheckBoxModel> initialValueList;
  String message;
  int limitCount;

  Function(List<FlutterLimitedCheckBoxModel> selectedList) onChanged;

  FlutterCustomCheckbox({
    Key? key,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: RichText(
        text: new TextSpan(
          // Note: Styles for TextSpans must be explicitly defined.
          // Child text spans will inherit styles from parent
          style: GoogleFonts.getFont('Roboto',
              fontWeight: FontWeight.w800, fontSize: 14, color: c.grey_8),
          children: <TextSpan>[
            new TextSpan(
                text: s.select_financial_year,
                style: new TextStyle(
                    fontWeight: FontWeight.bold, color: c.grey_8)),
            new TextSpan(
                text: " (Any Two)",
                style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    color: c.subscription_type_red_color)),
          ],
        ),
      ),
      content: Container(
          height: 300,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: ListView.builder(
                        itemCount: widget.initialValueList.length,
                        itemBuilder: (context, index) => Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Checkbox(
                                      value: widget
                                          .initialValueList[index].isSelected,
                                      onChanged: (v) {
                                        setState(() {
                                          if (widget.initialValueList[index]
                                                  .isSelected ==
                                              false) {
                                            var checker = widget
                                                .initialValueList
                                                .where((element) =>
                                                    element.isSelected == true)
                                                .toList()
                                                .length;
                                            if (checker < widget.limitCount) {
                                              widget.initialValueList[index]
                                                  .isSelected = true;
                                            }
                                          } else {
                                            widget.initialValueList[index]
                                                .isSelected = false;
                                          }
                                        });
                                        checkedList = widget.initialValueList
                                            .where((element) =>
                                                element.isSelected == true)
                                            .toList();

                                        // widget.onChanged(checkedList);
                                      },
                                    ),
                                    Expanded(
                                        child: Text(
                                      widget
                                          .initialValueList[index].selectTitle,
                                    ))
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                )
                              ],
                            ))),
              ),
              InkWell(
                  onTap: () {
                    print(checkedList.toString());
                    widget.onChanged(checkedList);
                    Navigator.pop(context, 'OK');
                    // setState(() {});
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
          )),
    );
  }
}
