// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, prefer_interpolation_to_compose_strings, use_build_context_synchronously, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/io_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:speech_to_text/speech_to_text.dart';
import '../DataBase/DbHelper.dart';
import '../Utils/utils.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as recognition;

class OtherWork_Save extends StatefulWidget {
  final category;
  final finYear;
  final dcode;
  final bcode;
  final pvcode;
  final flag;
  final tmccode;
  final townType;

  OtherWork_Save(
      {this.category,
      this.finYear,
      this.dcode,
      this.bcode,
      this.pvcode,
      this.tmccode,
      this.townType,
      this.flag});

  @override
  State<OtherWork_Save> createState() => _OtherWork_SaveState();
}

class _OtherWork_SaveState extends State<OtherWork_Save> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;

  bool noDataFlag = false;
  bool imageListFlag = false;
  bool txtFlag = false;
  bool statusError = false;

  List<Map<String, String>> img_jsonArray = [];
  List<Map<String, String>> img_jsonArray_val = [];

  var _imageFile;
  String workmage = '';
  final _picker = ImagePicker();

  TextEditingController descriptionController = TextEditingController();
  TextEditingController otherWorkDetailsController = TextEditingController();
  TextEditingController remark = TextEditingController();

  String selectedStatus = "";
  String selectedStatusName = "";
  List statusItems = [];

  Map<String, String> defaultSelectedStatus = {
    s.key_status_id: '0',
    s.key_status_name: s.select_status,
  };

  SpeechToText _speechToText = SpeechToText();
  bool speechEnabled = false;
  bool speech = false;
  String _lastWords = '';
  String lang = 'en_US';

  @override
  void initState() {
    initialize();
    _initSpeech();
  }

  @override
  void dispose() {
    super.dispose();
    descriptionController.dispose();
    otherWorkDetailsController.dispose();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    txtFlag = true;

    for (int i = 0;
        i < int.parse(prefs.getString(s.service_key_photo_count).toString());
        i++) {
      Map<String, String> mymap =
          {}; // This created one object in the current scope.

      // First iteration , i = 0
      mymap["latitude"] = '0'; // Now mymap = { name: 'test0' };
      mymap["longitude"] = '0'; // Now mymap = { name: 'test0' };
      mymap["serial_no"] = (i + 1).toString(); // Now mymap = { name: 'test0' };
      mymap["image_description"] = ''; // Now mymap = { name: 'test0' };
      mymap["image"] = '0'; // Now mymap = { name: 'test0' };
      img_jsonArray.add(mymap); // mylist = [mymap];
    }
    print("Img>>" + img_jsonArray.toString());
    if (img_jsonArray.isNotEmpty) {
      noDataFlag = false;
      imageListFlag = true;
    } else {
      noDataFlag = true;
      imageListFlag = false;
    }

    List<Map> list = await dbClient.rawQuery('SELECT * FROM ' + s.table_Status);
    print(list.toString());
    selectedStatus = defaultSelectedStatus[s.key_status_id]!;
    selectedStatusName = defaultSelectedStatus[s.key_status_name]!;
    statusItems.add(defaultSelectedStatus);
    statusItems.addAll(list);
    print('status>>' + statusItems.toString());

    setState(() {});
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context, rootNavigator: true).pop(context);
    return true;
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    speechEnabled = false;
    _speechToText.initialize();
    setState(() {
      descriptionview();
    });
  }

  /// Each time to start a speech recognition session
  void _startListening(String txt) async {
    speechEnabled = false;
    _lastWords = txt;
    await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: lang,
        listenFor: Duration(minutes: 10));
    print("start");
    setState(() {
      descriptionview();
    });
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    speechEnabled = true;
    print("stop");
    speech = false;
    setState(() {
      descriptionview();
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(recognition.SpeechRecognitionResult result) {
    // _lastWords = result.recognizedWords;
    descriptionController.text = _lastWords + ' ' + result.recognizedWords;
    speech = false;
    setState(() {
      descriptionview();
    });
    print("start" + descriptionController.text);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
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
                      child: Container(
                        transform: Matrix4.translationValues(-30.0, 0.0, 0.0),
                        alignment: Alignment.center,
                        child: Text(
                          s.work_details,
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
              color: c.white,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(children: [
                          listview(),
                          StatusView(),
                          descriptionview(),
                        ]),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      // clipBehavior is necessary because, without it, the InkWell's animation
                      // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                      // This comes with a small performance cost, and you should not set [clipBehavior]
                      // unless you need it.
                      clipBehavior: Clip.hardEdge,
                      margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: InkWell(
                        onTap: () {
                          validate();
                        },
                        child: Container(
                            alignment: AlignmentDirectional.center,
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                            child: Text(
                              s.submit,
                              style: TextStyle(
                                  color: c.subscription_type_red_color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
                    ),
                  ]),
            )));
  }

  // *************************** UI Design starts here *************************** //

  listview() {
    return Container(
      color: c.white,
      child: Container(
        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
        height: 110,
        child: Column(children: [
          Visibility(
            visible: imageListFlag,
            child: Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: img_jsonArray == null ? 0 : img_jsonArray.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: Stack(children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        // clipBehavior is necessary because, without it, the InkWell's animation
                        // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                        // This comes with a small performance cost, and you should not set [clipBehavior]
                        // unless you need it.
                        clipBehavior: Clip.hardEdge,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  goToCameraScreen(index);
                                },
                                child: img_jsonArray[index]['image'] == '0'
                                    ? Container(
                                        width: 80,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: new BorderRadius.only(
                                            topLeft: const Radius.circular(10),
                                            topRight: const Radius.circular(10),
                                            bottomLeft:
                                                const Radius.circular(0),
                                            bottomRight:
                                                const Radius.circular(0),
                                          ),
                                          border: Border.all(
                                              color: c.grey, width: 0.2),
                                        ),
                                      )
                                    : Container(
                                        width: 80,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: MemoryImage(Base64Decoder()
                                                .convert(img_jsonArray[index]
                                                    ['image']!)),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (img_jsonArray[index]['image'] != null &&
                                    img_jsonArray[index]['image'].toString() !=
                                        '0') {
                                  showAlert(
                                      context,
                                      img_jsonArray[index]['image_description']
                                          .toString(),
                                      index);
                                } else {
                                  utils.showAlert(
                                      context, "First capture the photo");
                                }
                              },
                              child: Container(
                                width: 80,
                                height: 30,
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(0),
                                    topRight: const Radius.circular(0),
                                    bottomLeft: const Radius.circular(10),
                                    bottomRight: const Radius.circular(10),
                                  ),
                                  border: Border.all(color: c.grey, width: 1),
                                ),
                                child: Text(
                                  img_jsonArray[index]['image_description']!,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(color: c.grey_7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        transform: Matrix4.translationValues(-5.0, 0.0, 0.0),
                        padding: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.grey_7,
                            border: Border.all(color: c.grey, width: 1.4)),
                        child: Image.asset(
                          imagePath.camera,
                          color: c.white,
                          fit: BoxFit.contain,
                          height: 12,
                          width: 12,
                        ),
                      )
                    ]),
                  );
                },
              ),
            ),
          ),
          Visibility(
            visible: noDataFlag,
            child: Align(
              alignment: AlignmentDirectional.center,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  s.no_data,
                  style: TextStyle(fontSize: 15, color: c.grey_10),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  Future<void> showAlert(BuildContext context, String msg, int i) async {
    if (msg != null && msg != '0') {
      remark.text = msg;
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remark'),
          content: Container(
            decoration: BoxDecoration(
                color: c.grey_out,
                border: Border.all(width: 1, color: c.grey_4),
                borderRadius: BorderRadius.circular(10.0)),
            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: TextFormField(
              style: TextStyle(height: 1.5),
              maxLines: 10,
              minLines: 5,
              controller: remark,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText: s.enter_description,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                border: InputBorder.none,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                remark.clear();
                setState(() {
                  listview();
                });
                Navigator.pop(context, 'Cancel');
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                img_jsonArray[i]
                    .update('image_description', (value) => remark.text);
                remark.clear();
                setState(() {
                  listview();
                });
                Navigator.pop(context, 'OK');
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  descriptionview() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
                child: Text(
              s.maximum_length_1000,
              style:
                  TextStyle(fontSize: 12, color: c.subscription_type_red_color),
            )),
            InkWell(
              onTap: () {
                descriptionController.clear();
              },
              child: Text(
                s.clear_text,
                style: TextStyle(fontSize: 12, color: c.darkblue),
              ),
            )
          ],
        ),
        Container(
          decoration: BoxDecoration(
              color: c.grey_out,
              border: Border.all(width: 1, color: c.grey_4),
              borderRadius: BorderRadius.circular(10.0)),
          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: TextFormField(
            style: TextStyle(height: 1.5),
            maxLines: 10,
            minLines: 5,
            controller: descriptionController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            /* validator: (value) => value!.isEmpty
                          ? s.enter_description
                          : null,*/
            decoration: InputDecoration(
              hintText: s.enter_description,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              /* filled: true,
                        fillColor: c.grey_out,*/
              border: InputBorder.none,
            ),
          ),
        ),
        Visibility(
          visible: txtFlag ? true : false,
          child: Container(
            alignment: AlignmentDirectional.center,
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Text(
              s.type_text,
              // state.hasError ? state.errorText : '',
              style: TextStyle(
                  color: c.subscription_type_red_color, fontSize: 12.0),
            ),
          ),
        ),
        Visibility(
          visible: !speech,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: InkWell(
                    onTap: () {
                      speechEnabled = false;
                      lang = 'en_US';
                      speech = true;
                      _startListening(descriptionController.text);
                    },
                    child: Row(
                      children: [
                        Container(
                          child: speech
                              ? Image.asset(
                                  imagePath.mic_mute_icon,
                                  color: c.black,
                                  fit: BoxFit.contain,
                                  height: 15,
                                  width: 15,
                                )
                              : Image.asset(
                                  imagePath.mic,
                                  color: c.black,
                                  fit: BoxFit.contain,
                                  height: 15,
                                  width: 15,
                                ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          s.english,
                          style: TextStyle(fontSize: 13, color: c.grey_8),
                        ),
                      ],
                    )),
              ),
              Expanded(
                flex: 1,
                child: InkWell(
                    onTap: () {
                      lang = 'ta_IND';
                      speech = true;
                      _startListening(descriptionController.text);
                    },
                    child: Row(
                      children: [
                        Container(
                          child: speech
                              ? Image.asset(
                                  imagePath.mic_mute_icon,
                                  color: c.black,
                                  fit: BoxFit.contain,
                                  height: 15,
                                  width: 15,
                                )
                              : Image.asset(
                                  imagePath.mic,
                                  color: c.black,
                                  fit: BoxFit.contain,
                                  height: 15,
                                  width: 15,
                                ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          s.tamil,
                          style: TextStyle(fontSize: 13, color: c.grey_8),
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ),
        Visibility(
          visible: speech,
          child: InkWell(
            onTap: () {
              _stopListening();
            },
            child: Image.asset(
              imagePath.mic_loading,
              height: 60.0,
              width: 60.0,
            ),
          ),
        )
      ]),
    );
  }

  StatusView() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: EdgeInsets.only(top: 15),
          child: TextFormField(
            controller: otherWorkDetailsController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLines: 5,
            minLines: 1,
            validator: (value) => value!.isEmpty
                ? s.please_enter_other_work_details
                : !Utils().isNameValid(value)
                    ? s.please_enter_other_work_details
                    : null,
            decoration: InputDecoration(
              hintText: s.enter_other_work_details,
              hintStyle: GoogleFonts.getFont('Roboto',
                  fontWeight: FontWeight.w800, fontSize: 13, color: c.grey_7),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              filled: true,
              fillColor: c.grey_out,
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: c.red),
                  borderRadius: BorderRadius.circular(10.0)),
              focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: c.red),
                  borderRadius: BorderRadius.circular(10.0)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 0.1, color: c.white),
                  borderRadius: BorderRadius.circular(10.0)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: c.colorPrimary),
                  borderRadius: BorderRadius.circular(10.0)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 15),
          child: Text(
            s.select_status,
            style: GoogleFonts.getFont('Roboto',
                fontWeight: FontWeight.w800, fontSize: 12, color: c.grey_8),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: c.grey_out,
              border: Border.all(
                  width: statusError ? 1 : 0.1,
                  color: statusError ? c.red : c.grey_10),
              borderRadius: BorderRadius.circular(10.0)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2(
              style: const TextStyle(color: Colors.black),
              value: selectedStatus,
              isExpanded: true,
              items: statusItems
                  .map((item) => DropdownMenuItem<String>(
                        value: item[s.key_status_id].toString(),
                        child: Text(
                          item[s.key_status_name].toString(),
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                selectedStatus = value.toString();
                int sIndex = statusItems
                    .indexWhere((f) => f[s.key_status_id] == selectedStatus);
                selectedStatusName = statusItems[sIndex][s.key_status_name];
                value != '0' ? statusError = false : statusError = true;
                setState(() {});
              },
              buttonStyleData: const ButtonStyleData(
                height: 45,
                padding: EdgeInsets.only(right: 10),
              ),
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Visibility(
          visible: statusError ? true : false,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              s.please_enter_status,
              // state.hasError ? state.errorText : '',
              style:
                  TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
            ),
          ),
        ),
      ]),
    );
  }

  // *************************** Camera Action here *************************** //

  Future<bool> checkImageList(List<Map<String, String>> list) async {
    bool flag = false;
    img_jsonArray_val = [];
    for (int i = 0; i < list.length; i++) {
      if (list[i][s.key_image] != null && list[i][s.key_image] != '0') {
        flag = true;
        img_jsonArray_val.add(list[i]);
      }
    }
    return flag;
  }

  Future<void> goToCameraScreen(int i) async {
    final hasPermission = await utils.handleLocationPermission(context);

    if (!hasPermission) return;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("latitude>>" + position.latitude.toString());
    print("longitude>>" + position.longitude.toString());
    if (position.latitude != null && position.longitude != null) {
      TakePhoto(ImageSource.camera, i, position.latitude.toString(),
          position.longitude.toString());
    } else {
      utils.showAlert(context, "Try Again...");
    }
  }

  Future<void> TakePhoto(
      ImageSource source, int i, String latitude, String longitude) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile == null) {
      Navigator.pop(context);

      Utils().showAlert(context, "User Canceled operation");
    } else {
      List<int> imageBytes = await pickedFile.readAsBytes();
      workmage = base64Encode(imageBytes);
      img_jsonArray[i].update('latitude', (value) => latitude);
      img_jsonArray[i].update('longitude', (value) => longitude);
      img_jsonArray[i].update('image', (value) => workmage);

      setState(() {
        _imageFile = File(pickedFile.path);
        print("ImageList>>" + img_jsonArray.toString());
        listview();
      });
    }
    // Navigator.pop(context);
  }

  // *************************** Validation here *************************** //

  Future<void> validate() async {
    if (await checkImageList(img_jsonArray)) {
      if (descriptionController.text.isNotEmpty &&
          descriptionController.text != '') {
        if (selectedStatus.isNotEmpty && selectedStatus != '0') {
          if (otherWorkDetailsController.text.isNotEmpty &&
              otherWorkDetailsController.text != '') {
            saveData();
          } else {
            utils.showAlert(context, "Please Enter Other Work Details");
          }
        } else {
          utils.showAlert(context, "Please Select Status");
        }
      } else {
        utils.showAlert(context, "Please Enter Description");
      }
    } else {
      utils.showAlert(context, "At least Capture one Photo");
    }
  }

  // *************************** API Call here *************************** //

  Future<void> saveData() async {
    List<dynamic> jsonArray = [];
    List<dynamic> inspection_work_details = [];
    for (int i = 0; i < img_jsonArray_val.length; i++) {
      jsonArray.add(img_jsonArray_val[i]);
    }
    Map dataset = {
      s.key_dcode: widget.dcode,
      s.key_rural_urban: prefs.getString(s.key_rural_urban),
      s.key_status_id: selectedStatus,
      s.key_fin_year: widget.finYear,
      'other_work_category_id': widget.category,
      'description': descriptionController.text.toString(),
      'other_work_detail': otherWorkDetailsController.text.toString(),
    };

    Map ruralset = {};
    Map urbanset = {};
    Map imgset = { 'image_details': jsonArray,};

    if (prefs.getString(s.key_rural_urban) == "U") {
      urbanset = {
        s.key_town_type: widget.townType,
        s.key_tpcode: widget.tmccode,
      };
      dataset.addAll(urbanset);
    }else{
      ruralset = {
        s.key_bcode: widget.bcode,
        s.key_pvcode: widget.pvcode,
        s.key_hab_code: "",
      };
      dataset.addAll(ruralset);
    }
    dataset.addAll(imgset);



    inspection_work_details.add(dataset);

    Map main_dataset = {
      s.key_service_id: s.service_key_other_work_inspection_details_save,
      'inspection_work_details': inspection_work_details,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: utils.encryption(
          jsonEncode(main_dataset), prefs.getString(s.userPassKey).toString()),
    };
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service,
        body: json.encode(encrpted_request));
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    print("saveData_url>>" + url.main_service.toString());
    print("saveData_request_json>>" + main_dataset.toString());
    print("saveData_request_encrpt>>" + encrpted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("saveData_response>>" + data);
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data =
          utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      if (status == s.key_ok && response_value == s.key_ok) {
        utils.customAlert(context, "S", s.online_data_save_success).then((value) => _onWillPop());
      } else {
        utils.customAlert(context, "E", s.no_data).then((value) => _onWillPop());
      }
    }
  }

  // *************************** API Call Ends Here here *************************** //
}
