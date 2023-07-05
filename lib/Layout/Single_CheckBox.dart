import 'package:flutter/material.dart';
import 'package:flutter_limited_checkbox/flutter_limited_checkbox.dart';

//ignore: must_be_immutable
class FlutterCustomSingleCheckbox extends StatefulWidget {
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

  FlutterCustomSingleCheckbox({
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
  _FlutterCustomSingleCheckboxState createState() =>
      _FlutterCustomSingleCheckboxState();
}

class _FlutterCustomSingleCheckboxState
    extends State<FlutterCustomSingleCheckbox> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.singleValueList.length,
      itemBuilder: (context, index) => Row(
        mainAxisAlignment: widget.mainAxisAlignmentOfRow,
        crossAxisAlignment: widget.crossAxisAlignmentOfRow,
        children: [
          Checkbox(
            value: widget.singleValueList[index].isSelected,
            onChanged: (v) {
              setState(() {
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
              });
              widget.onChanged(index);
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
          Text(
            widget.singleValueList[index].selectTitle,
            style: widget.titleTextStyle,
          )
        ],
      ),
    );
  }
}
