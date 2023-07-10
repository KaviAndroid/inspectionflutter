class FlutterLimitedCheckBoxModel {

  final int selectId;
  final String selectTitle;
  final double? selectValue;
  final String? extraText1;
  final String? extraText2;
  final String? extraText3;
  bool isSelected;

  FlutterLimitedCheckBoxModel({
    required this.selectId,
    required this.selectTitle,
    this.selectValue,
    this.extraText1,
    this.extraText2,
    this.extraText3,
    this.isSelected = false,
  });
}
