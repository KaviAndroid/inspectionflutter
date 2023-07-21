import 'package:flutter/material.dart';

import '../ModelClass/checkBoxModelClass.dart';

//ignore: must_be_immutable
class FlutterSingleCheckbox extends StatefulWidget {
  List<FlutterLimitedCheckBoxModel> singleValueList;
  Function(int index) onChanged;
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

  FlutterSingleCheckbox({
    Key? key,
    required this.singleValueList,
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
  _FlutterSingleCheckboxState createState() => _FlutterSingleCheckboxState();
}

class _FlutterSingleCheckboxState extends State<FlutterSingleCheckbox> {
  void _onClickFunction(int index) {
    if (widget.singleValueList[index].isSelected == false) {
      var checker = widget.singleValueList
          .where((element) => element.isSelected == true)
          .toList()
          .length;
      var checkerIndex = widget.singleValueList
          .indexWhere((element) => element.isSelected == true);
      if (checker < 2) {
        if (checkerIndex != -1) {
          widget.singleValueList[checkerIndex].isSelected = false;
          widget.singleValueList[index].isSelected = true;
        } else {
          widget.singleValueList[index].isSelected = true;
        }
      }
    } else {
      widget.singleValueList[index].isSelected = false;
    }
    widget.onChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.singleValueList.length,
      itemBuilder: (context, index) => InkWell(
          onTap: () {
            setState(() {
              _onClickFunction(index);
            });
          },
          child: Row(
            mainAxisAlignment: widget.mainAxisAlignmentOfRow,
            crossAxisAlignment: widget.crossAxisAlignmentOfRow,
            children: [
              Checkbox(
                value: widget.singleValueList[index].isSelected,
                onChanged: (v) {
                  setState(() {
                    _onClickFunction(index);
                  });
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
                widget.singleValueList[index].selectTitle,
                style: widget.titleTextStyle,
              ))
            ],
          )),
    );
  }
}
