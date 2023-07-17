import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

class SaveOtherWorkDatacontroller with ChangeNotifier {
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
  bool speech = false;
  String _lastWords = '';
  String lang = 'en_US';
  String widgetcategory = "";
  String widgetfinYear = "";
  String widgetdcode = "";
  String widgetbcode = "";
  String widgetpvcode = "";
  String widgetflag = "";
  String widgettmccode = "";
  String widgettownType = "";
  String onoffType = '';
  List widgetselectedworkList = [];
  List selectedwork = [];
  List widgetimagelist = [];
  List imageList = [];
  bool stagevisibility = false;
  bool statusvisibility = false;
  String widgetonoff_type = "";
  int max_img_count = 0;

  SaveOtherWorkDatacontroller(category, finYear, dcode, bcode, pvcode, tmccode,
      townType, flag, selectedworkList, imagelist, onoff_type) {
    widgetcategory = category;
    widgetfinYear = finYear;
    widgetdcode = dcode;
    widgetbcode = bcode;
    widgetpvcode = pvcode;
    widgetflag = flag;
    widgettmccode = tmccode;
    widgettownType = townType;
    widgetselectedworkList.addAll(selectedworkList);
    widgetimagelist.addAll(imagelist);
    widgetonoff_type = onoff_type;
    initialize();
    initSpeech();
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
    selectedwork = widgetselectedworkList;
    print("IMAGE>>>>>>" + widgetimagelist.toString());

    if (widgetflag == "edit") {
      statusvisibility;
      selectedStatus = defaultSelectedStatus[s.key_status_id]!;
      selectedStatusName = defaultSelectedStatus[s.key_status_name]!;
      descriptionController.text = selectedwork[0]['description'];
      otherWorkDetailsController.text = selectedwork[0]['other_work_detail'];
    } else {
      stagevisibility = true;
      statusvisibility = true;
      List<Map> list =
          await dbClient.rawQuery('SELECT * FROM ' + s.table_Status);
      print(list.toString());
      selectedStatus = defaultSelectedStatus[s.key_status_id]!;
      selectedStatusName = defaultSelectedStatus[s.key_status_name]!;
      statusItems.add(defaultSelectedStatus);
      statusItems.addAll(list);
      print('status>>' + statusItems.toString());
    }
    await loadImageList();
    notifyListeners();
  }

  Future<bool> _onWillPop(BuildContext context) async {
    Navigator.of(context, rootNavigator: true).pop(context);
    return true;
  }

  void initSpeech() async {
    _speechToText.initialize();
    notifyListeners();
  }

  /// Each time to start a speech recognition session
  void startListening(String txt) async {
    _lastWords = txt;
    await _speechToText.listen(
        onResult: onSpeechResult,
        localeId: lang,
        listenFor: Duration(minutes: 10));

    print("start");
    notifyListeners();
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void stopListening() async {
    await _speechToText.stop();
    print("stop");
    speech = false;
    notifyListeners();
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(recognition.SpeechRecognitionResult result) {
    // _lastWords = result.recognizedWords;
    descriptionController.text = _lastWords + ' ' + result.recognizedWords;
    _speechToText.isNotListening?speech = false:speech = true;
    notifyListeners();
    print("start" + descriptionController.text);
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
                notifyListeners();
                Navigator.pop(context, 'Cancel');
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                img_jsonArray[i]
                    .update('image_description', (value) => remark.text);
                remark.clear();
                notifyListeners();
                Navigator.pop(context, 'OK');
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
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

  Future<void> goToCameraScreen(int i, BuildContext context) async {
    final hasPermission = await utils.handleLocationPermission(context);

    if (!hasPermission) return;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("latitude>>" + position.latitude.toString());
    print("longitude>>" + position.longitude.toString());
    if (position.latitude != null && position.longitude != null) {
      if (await utils.goToCameraPermission(context)) {
        TakePhoto(ImageSource.camera, i, position.latitude.toString(),
            position.longitude.toString(), context);
      }

    } else {
      utils.showAlert(context, "Try Again...");
    }
  }

  Future<void> TakePhoto(ImageSource source, int i, String latitude,
      String longitude, BuildContext context) async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxHeight: 400,
        maxWidth: 400);

    if (pickedFile == null) {
      Navigator.pop(context);

      Utils().showAlert(context, "User Canceled operation");
    } else {
      List<int> imageBytes = await pickedFile.readAsBytes();
      workmage = base64Encode(imageBytes);
      img_jsonArray[i].update('latitude', (value) => latitude);
      img_jsonArray[i].update('longitude', (value) => longitude);
      img_jsonArray[i].update('image', (value) => workmage);
      img_jsonArray[i]
          .update(s.key_image_path, (value) => pickedFile.path.toString());
      _imageFile = File(pickedFile.path);
      print("ImageList>>" + img_jsonArray.toString());

      notifyListeners();
    }
    // Navigator.pop(context);
  }

  // *************************** Validation here *************************** //

  Future<void> validate(BuildContext context) async {
    if (widgetflag == "edit") {
      if (await checkImageList(img_jsonArray)) {
        if (otherWorkDetailsController.text.isNotEmpty &&
            otherWorkDetailsController.text != '') {
          if (descriptionController.text.isNotEmpty &&
              descriptionController.text != '') {
            if (await utils.isOnline()) {
              editsaveData(context);
            } else {
              utils.customAlertWidet(context, "Error", s.no_internet);
            }
          } else {
            utils.showAlert(context, "Please Enter Description");
          }
        } else {
          utils.showAlert(context, "Please Enter Other Work Details");
        }
      } else {
        utils.showAlert(context, "At least Capture one Photo");
      }
    } else {
      if (await checkImageList(img_jsonArray)) {
        if (selectedStatus.isNotEmpty && selectedStatus != '0') {
          if (otherWorkDetailsController.text.isNotEmpty &&
              otherWorkDetailsController.text != '') {
            if (descriptionController.text.isNotEmpty &&
                descriptionController.text != '') {
              if (await utils.isOnline()) {
                saveData(context);
              } else {
                utils.customAlertWidet(context, "Error", s.no_internet);
              }
            } else {
              utils.showAlert(context, "Please Enter Description");
            }
          } else {
            utils.showAlert(context, "Please Enter Other Work Details");
          }
        } else {
          utils.showAlert(context, "Please Select Status");
        }
      } else {
        utils.showAlert(context, "At least Capture one Photo");
      }
    }
  }

  // *************************** API Call here *************************** //

  Future<void> editsaveData(BuildContext context) async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    utils.showProgress(context, 1);
    List<dynamic> jsonArray = [];
    List<dynamic> inspection_work_details = [];
    for (int i = 0; i < img_jsonArray_val.length; i++) {
      Map<String, String> mymap =
          {}; // This created one object in the current scope.
      // First iteration , i = 0
      mymap["latitude"] = img_jsonArray_val[i][s.key_latitude]
          .toString(); // Now mymap = { name: 'test0' };
      mymap["longitude"] = img_jsonArray_val[i][s.key_longitude]
          .toString(); // Now mymap = { name: 'test0' };
      mymap["serial_no"] = img_jsonArray_val[i][s.key_serial_no].toString();
      mymap["image_description"] = img_jsonArray_val[i][s.key_image_description]
          .toString(); // Now mymap = { name: 'test0' };
      mymap["image"] = img_jsonArray_val[i][s.key_image]
          .toString(); // Now mymap = { name: 'test0' };
      // img_jsonArray_val[i].update('serial_no', (value) => count.toString());
      jsonArray.add(mymap);
    }
    Map dataset = {
      s.key_dcode: selectedwork[0][s.key_dcode],
      s.key_rural_urban: prefs.getString(s.key_rural_urban),
      s.key_status_id: selectedwork[0][s.key_status_id],
      s.key_fin_year: selectedwork[0][s.key_fin_year],
      'other_work_category_id': selectedwork[0][s.key_other_work_category_id],
      'description': descriptionController.text.toString(),
      'other_work_detail': otherWorkDetailsController.text.toString(),
    };

    Map ruralset = {};
    Map urbanset = {};
    Map imgset = {
      'image_details': jsonArray,
    };
    if (widgetflag == "edit") {
      Map set = {
        s.key_other_work_inspection_id: selectedwork[0]
            [s.key_other_work_inspection_id],
      };
      dataset.addAll(set);
    }

    if (prefs.getString(s.key_rural_urban) == "U") {
      urbanset = {
        s.key_town_type: widgettownType,
        s.key_tpcode: widgettmccode,
      };
      dataset.addAll(urbanset);
    } else {
      ruralset = {
        s.key_bcode: selectedwork[0][s.key_bcode],
        s.key_pvcode: selectedwork[0][s.key_pvcode],
        s.key_hab_code: "",
      };
      dataset.addAll(ruralset);
    }
    dataset.addAll(imgset);
    inspection_work_details.add(dataset);

    Map main_dataset = {
      s.key_service_id: s.service_key_other_work_inspection_details_update,
      'other_inspection_work_details': inspection_work_details,
    };
    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: main_dataset,
    };

    String jsonString = jsonEncode(encrypted_request);

    String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

    String header_token = utils.jwt_Encode(key, userName!, headerSignature);
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $header_token"
    };
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service_jwt,
        body: jsonEncode(encrypted_request), headers: header);
    utils.hideProgress(context);
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    print("saveData_url>>" + url.main_service_jwt.toString());
    print("saveData_request_json>>" + main_dataset.toString());
    print("saveData_request_encrpt>>" + jsonString);
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("saveData_response>>" + data);
      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("saveData Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("saveData responceSignature -  $responceSignature");

      print("saveData responceData -  $responceData");

      if (responceSignature == responceData) {
        print("saveData responceSignature - Token Verified");
        var userData = jsonDecode(data);
        var status = userData[s.key_status];
        var response_value = userData[s.key_response];
        if (status == s.key_ok && response_value == s.key_ok) {
          utils
              .customAlertWidet(context, "Success", s.online_data_save_success)
              .then((value) => _onWillPop(context));
        } else {
          utils.customAlertWidet(context, "Error", s.failed);
        }
      } else {
        print("saveData responceSignature - Token Not Verified");
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
    }
  }

  Future<void> saveData(BuildContext context) async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    utils.showProgress(context, 1);
    List<dynamic> jsonArray = [];
    List<dynamic> inspection_work_details = [];
    for (int i = 0; i < img_jsonArray_val.length; i++) {
      int count = i + 1;
      Map<String, String> mymap =
          {}; // This created one object in the current scope.
      // First iteration , i = 0
      mymap["latitude"] = img_jsonArray_val[i][s.key_latitude]
          .toString(); // Now mymap = { name: 'test0' };
      mymap["longitude"] = img_jsonArray_val[i][s.key_longitude]
          .toString(); // Now mymap = { name: 'test0' };
      mymap["serial_no"] = count.toString();
      mymap["image_description"] = img_jsonArray_val[i][s.key_image_description]
          .toString(); // Now mymap = { name: 'test0' };
      mymap["image"] = img_jsonArray_val[i][s.key_image]
          .toString(); // Now mymap = { name: 'test0' };
      // img_jsonArray_val[i].update('serial_no', (value) => count.toString());
      jsonArray.add(mymap);
    }
    Map dataset = {
      s.key_dcode: widgetdcode,
      s.key_rural_urban: prefs.getString(s.key_rural_urban),
      s.key_status_id: selectedStatus,
      s.key_fin_year: widgetfinYear,
      'other_work_category_id': widgetcategory,
      'description': descriptionController.text.toString(),
      'other_work_detail': otherWorkDetailsController.text.toString(),
    };

    Map ruralset = {};
    Map urbanset = {};
    Map imgset = {
      'image_details': jsonArray,
    };
    if (prefs.getString(s.key_rural_urban) == "U") {
      urbanset = {
        s.key_town_type: widgettownType,
        s.key_tpcode: widgettmccode,
      };
      dataset.addAll(urbanset);
    } else {
      ruralset = {
        s.key_bcode: widgetbcode,
        s.key_pvcode: widgetpvcode,
        s.key_hab_code: "",
      };
      dataset.addAll(ruralset);
    }
    dataset.addAll(imgset);
    inspection_work_details.add(dataset);

    Map main_dataset = {
      s.key_service_id: s.service_key_other_work_inspection_details_save,
      'other_inspection_work_details': inspection_work_details,
    };

    Map encrypted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: main_dataset,
    };
    String jsonString = jsonEncode(encrypted_request);

    String headerSignature = utils.generateHmacSha256(jsonString, key!, true);

    String header_token = utils.jwt_Encode(key, userName!, headerSignature);
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $header_token"
    };
    HttpClient _client = HttpClient(context: await utils.globalContext);
    _client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => false;
    IOClient _ioClient = new IOClient(_client);
    var response = await _ioClient.post(url.main_service_jwt,
        body: jsonEncode(encrypted_request), headers: header);

    utils.hideProgress(context);
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    print("saveData_url>>" + url.main_service_jwt.toString());
    print("saveData_request_json>>" + main_dataset.toString());
    print("saveData_request_encrpt>>" + encrypted_request.toString());
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("saveData_response>>" + data);
      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("saveData Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("saveData responceSignature -  $responceSignature");

      print("saveData responceData -  $responceData");

      if (responceSignature == responceData) {
        print("saveData responceSignature - Token Verified");
        var userData = jsonDecode(data);
        var status = userData[s.key_status];
        var response_value = userData[s.key_response];
        if (status == s.key_ok && response_value == s.key_ok) {
          utils
              .customAlertWidet(context, "Success", s.online_data_save_success)
              .then((value) => _onWillPop(context));
        } else {
          utils.customAlertWidet(context, "Error", s.failed);
        }
      } else {
        print("saveData responceSignature - Token Not Verified");
        utils.customAlertWidet(context, "Error", s.jsonError);
      }
    }
  }

  Future<void> setStatus(var value) async {
    selectedStatus = value.toString();
    int sIndex =
        statusItems.indexWhere((f) => f[s.key_status_id] == selectedStatus);
    selectedStatusName = statusItems[sIndex][s.key_status_name];
    value != '0' ? statusError = false : statusError = true;
    notifyListeners();
  }

  Future<void> loadImageList() async {
    img_jsonArray.clear();
    max_img_count =
        int.parse(prefs.getString(s.service_key_photo_count).toString());
    imageList.clear();

    if (widgetflag == "edit") {
      imageList.addAll(widgetimagelist);
    }
    for (int i = 0; i < imageList.length; i++) {
      Map<String, String> mymap =
          {}; // This created one object in the current scope.

      // First iteration , i = 0
      mymap["latitude"] = imageList[i][s.key_latitude]
          .toString(); // Now mymap = { name: 'test0' };
      mymap["longitude"] = imageList[i][s.key_longitude]
          .toString(); // Now mymap = { name: 'test0' };
      mymap["serial_no"] = imageList[i][s.key_serial_no]
          .toString(); // Now mymap = { name: 'test0' };
      mymap["image_description"] = imageList[i][s.key_image_description]
          .toString(); // Now mymap = { name: 'test0' };
      mymap["image"] = imageList[i][s.key_image].toString();
      mymap["image_path"] = imageList[i][s.key_image_path]
          .toString(); // Now mymap = { name: 'test0' };
      img_jsonArray.add(mymap); // mylist = [mymap];
    }

    for (int i = img_jsonArray.length; i < max_img_count; i++) {
      Map<String, String> mymap =
          {}; // This created one object in the current scope.
      int count = i + 1;
      // First iteration , i = 0
      mymap["latitude"] = '0'; // Now mymap = { name: 'test0' };
      mymap["longitude"] = '0'; // Now mymap = { name: 'test0' };
      mymap["serial_no"] = count.toString(); // Now mymap = { name: 'test0' };
      mymap["image_description"] = ''; // Now mymap = { name: 'test0' };
      mymap["image"] = '0';
      mymap["image_path"] = '0'; // Now mymap = { name: 'test0' };
      img_jsonArray.add(mymap); // mylist = [mymap];
    }
    print("Img>>" + img_jsonArray.toString());
    if (img_jsonArray.length > 0) {
      noDataFlag = false;
      imageListFlag = true;
    } else {
      noDataFlag = true;
      imageListFlag = false;
    }
  }
}
