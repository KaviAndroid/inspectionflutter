import 'package:flutter/material.dart';

import 'checkBoxModelClass.dart';

//ignore: must_be_immutable
class FlutterLimitedCheckbox extends StatefulWidget {
  List<FlutterLimitedCheckBoxModel> limitedValueList;
  int limit;
  Function(List<FlutterLimitedCheckBoxModel> selectedList) onChanged;
  TextStyle? titleTextStyle;
  Color? checkColor;
  Color? activeColor;
  Color? focusColor;
  OutlinedBorder? shape;
  BorderSide? borderSide;
  FocusNode? focusNode;
  double? splashRadius;
  bool autofocus;
  MainAxisAlignment mainAxisAlignmentOfRow;
  CrossAxisAlignment crossAxisAlignmentOfRow;

  FlutterLimitedCheckbox({
    Key? key,
    required this.limitedValueList,
    required this.limit,
    required this.onChanged,
    this.titleTextStyle,
    this.checkColor,
    this.activeColor,
    this.shape,
    this.borderSide,
    this.focusNode,
    this.splashRadius,
    this.focusColor,
    this.autofocus = false,
    this.mainAxisAlignmentOfRow = MainAxisAlignment.center,
    this.crossAxisAlignmentOfRow = CrossAxisAlignment.center,
  }) : super(key: key);

  @override
  _FlutterLimitedCheckboxState createState() =>
      _FlutterLimitedCheckboxState();
}

class _FlutterLimitedCheckboxState
    extends State<FlutterLimitedCheckbox> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.limitedValueList.length,
        itemBuilder: (context, index) => Column(
              children: [
                Row(
                  mainAxisAlignment: widget.mainAxisAlignmentOfRow,
                  crossAxisAlignment: widget.crossAxisAlignmentOfRow,
                  children: [
                    Checkbox(
                      value: widget.limitedValueList[index].isSelected,
                      onChanged: (v) {
                        setState(() {
                          if (widget.limitedValueList[index].isSelected ==
                              false) {
                            var checker = widget.limitedValueList
                                .where((element) => element.isSelected == true)
                                .toList()
                                .length;
                            if (checker < widget.limit) {
                              widget.limitedValueList[index].isSelected = true;
                            }
                          } else {
                            widget.limitedValueList[index].isSelected = false;
                          }
                        });
                        List<FlutterLimitedCheckBoxModel> checkedList = widget
                            .limitedValueList
                            .where((element) => element.isSelected == true)
                            .toList();

                        widget.onChanged(checkedList);
                      },
                      checkColor: widget.checkColor,
                      activeColor: widget.activeColor,
                      shape: widget.shape,
                      side: widget.borderSide,
                      focusColor: widget.focusColor,
                      autofocus: widget.autofocus,
                      focusNode: widget.focusNode,
                      splashRadius: widget.splashRadius,
                    ),
                    Expanded(
                        child: Text(
                      widget.limitedValueList[index].selectTitle,
                      style: widget.titleTextStyle,
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                )
              ],
            ));
  }
}
