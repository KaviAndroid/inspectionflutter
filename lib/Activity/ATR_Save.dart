// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inspection_flutter_app/Activity/ATR_Offline.dart';
import 'package:inspection_flutter_app/Activity/ATR_Online.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../DataBase/DbHelper.dart';
import '../Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import '../Utils/utils.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as recognition;
import 'package:inspection_flutter_app/Resources/global.dart';
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:http/io_client.dart';

class ATR_Save extends StatefulWidget {
  final area_type, onoff_type, selectedWorklist;
  ATR_Save({this.area_type, this.onoff_type, this.selectedWorklist});

  @override
  State<ATR_Save> createState() => _ATR_SaveState();
}

class _ATR_SaveState extends State<ATR_Save> {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;

  //controller
  TextEditingController descriptionController = TextEditingController();
  TextEditingController remark = TextEditingController();
  SpeechToText _speechToText = SpeechToText();

  //image
  final _picker = ImagePicker();

  //list
  List<Map<String, String>> img_jsonArray = [];
  List<Map<String, String>> img_jsonArray_val = [];
  List selectedwork = [];

  //bool
  bool imageListFlag = false;
  bool noDataFlag = false;
  bool txtFlag = false;
  bool speechEnabled = false;
  bool speech = false;
  bool isSpinnerLoading = false;

  //string
  String _lastWords = '';
  String lang = 'en_US';
  String workmage = '';
  String selectedStatus = "";
  String selectedStage = "";
  var _imageFile;

  @override
  void initState() {
    initialize();
    _initSpeech();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    txtFlag = true;
    selectedwork = widget.selectedWorklist;
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
      mymap["image_path"] = '';
      mymap["image"] = '0'; // Now mymap = { name: 'test0' };
      img_jsonArray.add(mymap); // mylist = [mymap];
    }
    if (img_jsonArray.length > 0) {
      noDataFlag = false;
      imageListFlag = true;
    } else {
      noDataFlag = true;
      imageListFlag = false;
    }
    await checkData();
    setState(() {});
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
    descriptionController.text = '$_lastWords ${result.recognizedWords}';
    speech = false;
    setState(() {
      descriptionview();
    });
    print("start${descriptionController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            color: c.white,
            child: Stack(
              children: [
                IgnorePointer(
                  ignoring: isSpinnerLoading,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(children: <Widget>[
                              listview(),
                              descriptionview(),
                              submitActivity(),
                            ]),
                          ),
                        ),
                      ]),
                ),
                Visibility(
                  visible: isSpinnerLoading,
                  child:
                      Center(child: Utils().showSpinner("Data uploading...")),
                )
              ],
            )));
  }

  // *************************** Design Starts here *************************** //

  listview() {
    return Container(
      color: c.white,
      child: Container(
        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
        width: screenWidth,
        height: screenWidth,
        child: Column(children: [
          Visibility(
            visible: imageListFlag,
            child: Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: List.generate(img_jsonArray.length, (index) {
                  return Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: Stack(children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
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
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
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
                                width: 160,
                                height: 30,
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
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
                }),
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

  submitActivity() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.fromLTRB(20, 40, 20, 10),
      child: InkWell(
        onTap: () async {
          if (await utils.isOnline()) {
            setState(() {
              isSpinnerLoading = true;
            });
            validate();
          } else {
            utils.showAlert(context, s.no_internet);
          }
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
    );
  }

  // *************************** Design Ends here *************************** //

  // *************************** Show Alert Starts here *************************** //

  Future<void> showSuccessAlert(BuildContext context, String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
                Text(''),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'OK');
                // _onWillPop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showAlert(BuildContext context, String msg, int i) async {
    if (msg != '0') {
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

  // *************************** Show Alert Ends here *************************** //

  // *************************** Camera Function starts here *************************** //

  Future<void> goToCameraScreen(int i) async {
    final hasPermission = await utils.handleLocationPermission(context);
    print("pos - $i");

    if (!hasPermission) return;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("latitude>>${position.latitude}");
    print("longitude>>${position.longitude}");
    if (position.longitude != null) {
      TakePhoto(i, position.latitude.toString(), position.longitude.toString());
    } else {
      utils.showAlert(context, "Try Again...");
    }
  }

  Future<void> TakePhoto(int i, String latitude, String longitude) async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxHeight: 400,
        maxWidth: 400);
    if (pickedFile == null) {
      Navigator.pop(context);

      Utils().showAlert(context, "User Canceled operation");
    } else {
      List<int> imageBytes = await pickedFile.readAsBytes();
      workmage = base64Encode(imageBytes);
      img_jsonArray[i].update(s.key_latitude, (value) => latitude);
      img_jsonArray[i].update(s.key_longitude, (value) => longitude);
      img_jsonArray[i].update(s.key_image, (value) => workmage);
      img_jsonArray[i]
          .update(s.key_image_path, (value) => pickedFile.path.toString());
      setState(() {
        _imageFile = File(pickedFile.path);
        listview();
      });
    }
    // Navigator.pop(context);
  }

  // *************************** Camera Function Ends here *************************** //

  // *************************** Validation start here *************************** //

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

  Future<void> validate() async {
    if (await checkImageList(img_jsonArray)) {
      if (descriptionController.text != "") {
        widget.onoff_type == "offline"
            ? await offlineSave()
            : await onlineSave();
      } else {
        utils.showAlert(context, "Please Enter Discription");
      }
    } else {
      utils.showAlert(context, "At least Capture one Photo");
    }
  }

  // *************************** Validation Ends here *************************** //

  // *************************** SAVE DATA *************************** //

  Future<void> onlineSave() async {
    List<dynamic> jsonArray = [];
    List<dynamic> inspection_work_details = [];
    for (int i = 0; i < img_jsonArray_val.length; i++) {
      jsonArray.add(img_jsonArray_val[i]);
    }
    Map dataset = {
      s.key_dcode: selectedwork[0][s.key_dcode],
      s.key_rural_urban: selectedwork[0][s.key_rural_urban],
      s.key_bcode: selectedwork[0][s.key_bcode],
      s.key_pvcode: selectedwork[0][s.key_pvcode],
      s.key_work_id: selectedwork[0][s.key_work_id],
      s.key_inspection_id: selectedwork[0][s.key_inspection_id],
      'description': descriptionController.text.toString(),
      'image_details': jsonArray,
    };

    Map urbanRequest = {
      s.key_town_type: selectedwork[0][s.key_town_type],
      s.key_tpcode: selectedwork[0][s.key_tpcode],
      s.key_muncode: selectedwork[0][s.key_muncode],
      s.key_corcode: selectedwork[0][s.key_corcode],
    };

    if (widget.area_type == "U") {
      dataset.addAll(urbanRequest);
    }

    inspection_work_details.add(dataset);

    Map main_dataset = {
      s.key_service_id: s.service_key_action_taken_details_save,
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
    // print("onlineSave_url>>${url.main_service}");
    // print("onlineSave_request_json>>$main_dataset");
    // print("onlineSave_request_encrpt>>$encrpted_request");
    setState(() {
      isSpinnerLoading = false;
    });
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("onlineSave_response>>$data");
      var jsonData = jsonDecode(data);
      var enc_data = jsonData[s.key_enc_data];
      var decrpt_data =
          utils.decryption(enc_data, prefs.getString(s.userPassKey).toString());
      var userData = jsonDecode(decrpt_data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      var msg = userData[s.key_message];
      if (status == s.key_ok && response_value == s.key_ok) {
        showSuccessAlert(context, "Your Data is Synchronized to the server!");
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ATR_Worklist(
            Flag: widget.area_type,
          ),
        ));
      } else {
        utils.showAlert(context, msg);
      }
    }
  }

  // *************************** SAVE DATA Ends here *************************** //

  // *************************** INSERT DATA *************************** //

  Future<void> offlineSave() async {
    var count = 0;
    var imageCount = 0;

    var isExists = await dbClient.rawQuery(
        "SELECT * FROM ${s.table_save_atr_work_details} WHERE work_id='${selectedwork[0][s.key_work_id].toString()}' and inspection_id='${selectedwork[0][s.key_inspection_id].toString()}' and dcode='${selectedwork[0][s.key_dcode].toString()}'");

    // print(isExists);
    // print(imageExists);

    if (isExists.length > 0) {
      print("Edit>>>>");

      for (int i = 0; i < selectedwork.length; i++) {
        count = await dbClient.rawInsert(" UPDATE " +
            s.table_save_atr_work_details +
            " SET description = '" +
            descriptionController.text +
            "' WHERE rural_urban = '" +
            selectedwork[i][s.key_rural_urban] +
            "' AND work_id = '" +
            selectedwork[i][s.key_work_id].toString() +
            "'AND inspection_id =  '" +
            selectedwork[i][s.key_inspection_id].toString() +
            "'AND dcode =  '" +
            selectedwork[i][s.key_dcode].toString() +
            "'");
      }
    } else {
      print("Insert>>");
      for (int i = 0; i < selectedwork.length; i++) {
        count = await dbClient.rawInsert('INSERT INTO ' +
            s.table_save_atr_work_details +
            ' (dcode, bcode , pvcode, inspection_id, description , work_id, rural_urban, town_type, tpcode, muncode, corcode) VALUES(' +
            "'" +
            selectedwork[i][s.key_dcode].toString() +
            "' , '" +
            selectedwork[i][s.key_bcode].toString() +
            "' , '" +
            selectedwork[i][s.key_pvcode].toString() +
            "' , '" +
            selectedwork[i][s.key_inspection_id].toString() +
            "' , '" +
            descriptionController.text +
            "' , '" +
            selectedwork[i][s.key_work_id].toString() +
            "' , '" +
            selectedwork[i][s.key_rural_urban] +
            "' , '" +
            selectedwork[i][s.key_town_type] +
            "' , '" +
            selectedwork[i][s.key_tpcode].toString() +
            "' , '" +
            selectedwork[i][s.key_muncode].toString() +
            "' , '" +
            selectedwork[i][s.key_corcode].toString() +
            "')");
      }
    }
    print(count);
    if (count > 0) {
      var serial_count = 0;
      // print(img_jsonArray_val);

      for (int i = 0; i < img_jsonArray_val.length; i++) {
        serial_count++;

        var imageExists = await dbClient.rawQuery(
            "SELECT * FROM ${s.table_save_images} WHERE work_id='${selectedwork[0][s.key_work_id].toString()}' and inspection_id='${selectedwork[0][s.key_inspection_id].toString()}' and dcode='${selectedwork[0][s.key_dcode].toString()}' and serial_no='${serial_count.toString()}'");
        print(
            "SELECT * FROM ${s.table_save_images} WHERE work_id='${selectedwork[0][s.key_work_id].toString()}' and inspection_id='${selectedwork[0][s.key_inspection_id].toString()}' and dcode='${selectedwork[0][s.key_dcode].toString()}' and serial_no='${serial_count.toString()}'");

        if (imageExists.length > 0) {
          print("img upd");

          await File(imageExists[0][s.key_image_path]).delete();

          imageCount = await dbClient.rawInsert(" UPDATE " +
              s.table_save_images +
              " SET image_description = '" +
              img_jsonArray_val[i][s.key_image_description].toString() +
              "', latitude = '" +
              img_jsonArray_val[i][s.key_latitude].toString() +
              "', longitude = '" +
              img_jsonArray_val[i][s.key_longitude].toString() +
              "', serial_no = '" +
              serial_count.toString() +
              "', image_path = '" +
              img_jsonArray_val[i][s.key_image_path].toString() +
              "', image = '" +
              img_jsonArray_val[i][s.key_image].toString() +
              "' WHERE rural_urban = '" +
              selectedwork[0][s.key_rural_urban] +
              "' AND work_id = '" +
              selectedwork[0][s.key_work_id].toString() +
              "' AND serial_no = '" +
              serial_count.toString() +
              "' AND inspection_id = '" +
              selectedwork[0][s.key_inspection_id].toString() +
              "' AND dcode = '" +
              selectedwork[0][s.key_dcode].toString() +
              "'");
        } else {
          print("img ins");
          imageCount = await dbClient.rawInsert('INSERT INTO ' +
              s.table_save_images +
              ' (atr_flag, work_id, inspection_id, image_description, latitude, longitude, serial_no, rural_urban,  dcode, bcode, pvcode, tpcode, muncode, corcode, image_path, image) VALUES('
                  "'Y' ," +
              "'" +
              selectedwork[0][s.key_work_id].toString() +
              "' , '" +
              selectedwork[0][s.key_inspection_id].toString() +
              "' , '" +
              img_jsonArray_val[i][s.key_image_description].toString() +
              "' , '" +
              img_jsonArray_val[i][s.key_latitude].toString() +
              "' , '" +
              img_jsonArray_val[i][s.key_longitude].toString() +
              "' , '" +
              serial_count.toString() +
              "' , '" +
              selectedwork[0][s.key_rural_urban] +
              "' , '" +
              selectedwork[0][s.key_dcode].toString() +
              "' , '" +
              selectedwork[0][s.key_bcode].toString() +
              "' , '" +
              selectedwork[0][s.key_pvcode].toString() +
              "' , '" +
              selectedwork[0][s.key_tpcode].toString() +
              "' , '" +
              selectedwork[0][s.key_muncode].toString() +
              "' , '" +
              selectedwork[0][s.key_corcode].toString() +
              "' , '" +
              img_jsonArray_val[i][s.key_image_path].toString() +
              "' , '" +
              img_jsonArray_val[i][s.key_image].toString() +
              "')");
        }
      }
    }
    setState(() {
      isSpinnerLoading = false;
    });

    if (count > 0 && imageCount > 0) {
      utils.showAlert(context, "Success");
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ATR_Offline_worklist(
          Flag: widget.area_type,
        ),
      ));
    } else {
      utils.showAlert(context, "Fail");
    }
  }

  // *************************** INSERT DATA Ends here *************************** //

  // *************************** Check DATA Ends here *************************** //

  Future<void> checkData() async {
    var isExists = await dbClient.rawQuery(
        "SELECT * FROM ${s.table_save_atr_work_details} WHERE work_id='${selectedwork[0][s.key_work_id].toString()}' and inspection_id='${selectedwork[0][s.key_inspection_id].toString()}' and dcode='${selectedwork[0][s.key_dcode].toString()}'");
    var imageExists = await dbClient.rawQuery(
        "SELECT * FROM ${s.table_save_images} WHERE work_id='${selectedwork[0][s.key_work_id].toString()}' and inspection_id='${selectedwork[0][s.key_inspection_id].toString()}' and dcode='${selectedwork[0][s.key_dcode].toString()}'");

    if (isExists.length > 0 && imageExists.length > 0) {
      for (int i = 0; i < imageExists.length; i++) {
        img_jsonArray[i]
            .update(s.key_latitude, (value) => imageExists[i][s.key_latitude]);
        img_jsonArray[i].update(
            s.key_longitude, (value) => imageExists[i][s.key_longitude]);
        img_jsonArray[i]
            .update(s.key_image, (value) => imageExists[i][s.key_image]);
        img_jsonArray[i].update(s.key_image_description,
            (value) => imageExists[i][s.key_image_description]);
      }

      descriptionController.text = isExists[0][s.key_description];
      setState(() {
        listview();
      });
    }
  }

  // *************************** Check DATA Ends here *************************** //
}
