
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/io_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/url.dart' as url;
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;
import 'package:speech_to_text/speech_recognition_result.dart' as recognition;
import 'package:speech_to_text/speech_to_text.dart';

import '../Activity/ATR_Online.dart';
import '../DataBase/DbHelper.dart';
import '../Utils/utils.dart';

class AtrSaveDataController with ChangeNotifier{
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  Utils utils = Utils();

  //controller
  TextEditingController descriptionController = TextEditingController();
  TextEditingController remark = TextEditingController();
  SpeechToText _speechToText = SpeechToText();

  late PermissionStatus cameraPermission, speechPermission;

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
  String widgetonoff_type = '';
  String widgetrural_urban = '';
  String widgetflag = '';
  List widgetselectedworkList = [];
  int max_img_count=0;
  List imageList=[];
  List widgetimagelist = [];

  AtrSaveDataController(rural_urban, onoff_type, selectedworkList,flag, imagelist) {
    widgetonoff_type = onoff_type;
    widgetrural_urban = rural_urban;
    widgetselectedworkList.addAll(selectedworkList);
    widgetflag=flag;
    widgetimagelist.addAll(imagelist);
    initialize();
  }
  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    txtFlag = true;
    selectedwork = widgetselectedworkList;
    print("IMAGE>>>>>>"+widgetimagelist.toString());
    if(widgetflag=="edit")
      {
        descriptionController.text=selectedwork[0]['description'];
      }
    print(selectedwork);
    loadImageList();
    await checkData();
    notifyListeners();
  }
  void startListening(String txt, BuildContext context) async {
    speechPermission = await Permission.speech.status;
    if (await Permission.speech.request().isGranted) {
      speechPermission = await Permission.speech.status;
    }
    print("Speech check $speechPermission");
    if (speechPermission.isGranted || speechPermission.isLimited) {
      await _speechToText.initialize();
      speechEnabled = false;
      _lastWords = txt;
      await _speechToText.listen(
          onResult: onSpeechResult,
          localeId: lang,
          listenFor: Duration(minutes: 10));
      print("start");
     notifyListeners();
    } else if (speechPermission.isDenied ||
        speechPermission.isPermanentlyDenied ||
        speechPermission.isRestricted) {
      Utils().showAppSettings(context, s.speech_permission);
    }
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void stopListening() async {
    await _speechToText.stop();
    speechEnabled = true;
    print("stop");
    speech = false;
    notifyListeners();
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(recognition.SpeechRecognitionResult result) {
    // _lastWords = result.recognizedWords;
    descriptionController.text = '$_lastWords ${result.recognizedWords}';
    speech = false;
    notifyListeners();
    print("start${descriptionController.text}");
  }



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

  // *************************** Show Alert Ends here *************************** //

  // *************************** Camera Function starts here *************************** //

  Future<void> goToCameraScreen(int i, BuildContext context) async {
    final hasPermission = await utils.handleLocationPermission(context);

    if (!hasPermission) return;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("latitude>>${position.latitude}");
    print("longitude>>${position.longitude}");
    if (position.longitude != null) {
      TakePhoto(i, position.latitude.toString(), position.longitude.toString(),context);
    } else {
      utils.showAlert(context, "Try Again...");
    }
  }

  Future<void> TakePhoto(int i, String latitude, String longitude, BuildContext context) async {
    if (await goToCameraPermission(context)) {
      final pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          maxHeight: 400,
          maxWidth: 400);
      if (pickedFile == null) {
        Utils().showAlert(context, "User Canceled operation");
      } else {
        List<int> imageBytes = await pickedFile.readAsBytes();
        workmage = base64Encode(imageBytes);
        img_jsonArray[i].update(s.key_latitude, (value) => latitude);
        img_jsonArray[i].update(s.key_longitude, (value) => longitude);
        img_jsonArray[i].update(s.key_image, (value) => workmage);
        img_jsonArray[i]
            .update(s.key_image_path, (value) => pickedFile.path.toString());
        _imageFile = File(pickedFile.path);
        notifyListeners();
      }
    }

    // Navigator.pop(context);
  }

  // *************************** Camera Function Ends here *************************** //

  // *************************** Validation start here *************************** //
  Future<void> loadImageList()async {
    img_jsonArray.clear();
    max_img_count=int.parse(prefs.getString(s.service_key_photo_count).toString());
    imageList.clear();
    if(widgetflag=="edit")
    {
      imageList.addAll(widgetimagelist);
    }
    else
    {
      List<Map> list = await dbClient.rawQuery('SELECT * FROM ' + s.table_save_images+" WHERE work_id='${selectedwork[0][s.key_work_id].toString()}' and rural_urban='${widgetrural_urban}' and flag='rdpr'");
      imageList.addAll(list);
    }
    for (int i = 0; i < imageList.length; i++) {
      Map<String, String> mymap =
      {}; // This created one object in the current scope.

      // First iteration , i = 0
      mymap["latitude"] = imageList[i][s.key_latitude].toString(); // Now mymap = { name: 'test0' };
      mymap["longitude"] = imageList[i][s.key_longitude].toString(); // Now mymap = { name: 'test0' };
      mymap["serial_no"] = imageList[i][s.key_serial_no].toString(); // Now mymap = { name: 'test0' };
      mymap["image_description"] = imageList[i][s.key_image_description].toString(); // Now mymap = { name: 'test0' };
      mymap["image"] = imageList[i][s.key_image].toString(); // Now mymap = { name: 'test0' };
      mymap["image_path"] = imageList[i][s.key_image_path].toString(); // Now mymap = { name: 'test0' };
      img_jsonArray.add(mymap); // mylist = [mymap];
    }

    for (int i = img_jsonArray.length; i < max_img_count; i++) {
      Map<String, String> mymap =
      {}; // This created one object in the current scope.
      int count=i+1;
      // First iteration , i = 0
      mymap["latitude"] = '0'; // Now mymap = { name: 'test0' };
      mymap["longitude"] = '0'; // Now mymap = { name: 'test0' };
      mymap["serial_no"] = count.toString(); // Now mymap = { name: 'test0' };
      mymap["image_description"] = ''; // Now mymap = { name: 'test0' };
      mymap["image"] = '0'; // Now mymap = { name: 'test0' };
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

  Future<void> validate(BuildContext context) async {
    if(widgetflag=="edit")
      {
        if (await checkImageList(img_jsonArray)) {
          if (descriptionController.text != "") {
            if(widgetonoff_type=="online")
              {
                await onlineSave(context);
              }
          }
          else {
            utils.showAlert(context, "Please Enter Discription");
          }
          }
      }
    else
      {
        if (await checkImageList(img_jsonArray)) {
          if (descriptionController.text != "") {
            widgetonoff_type == "offline"
                ? await offlineSave(context)
                : await onlineSave(context);
          } else {
            utils.showAlert(context, "Please Enter Discription");
          }
        } else {
          utils.showAlert(context, "At least Capture one Photo");
        }
      }
  }

  // *************************** Validation Ends here *************************** //

  // *************************** SAVE DATA *************************** //

  Future<void> onlineSave(BuildContext context) async {
    String? key = prefs.getString(s.userPassKey);
    String? userName = prefs.getString(s.key_user_name);
    isSpinnerLoading = true;
    notifyListeners();
    List<dynamic> jsonArray = [];
    List<dynamic> inspection_work_details = [];
    for (int i = 0; i < img_jsonArray_val.length; i++) {
      int count=i+1;
      img_jsonArray_val[i].update('serial_no', (value) => count.toString());
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

    if (widgetrural_urban == "U") {
      dataset.addAll(urbanRequest);
    }
    Map set = {
      s.key_service_id:s.service_key_work_id_wise_inspection_action_taken_details_view,
      s.key_work_id:selectedwork[0][s.key_work_id],
      s.key_action_taken_id:selectedwork[0][s.key_action_taken_id],
      s.key_inspection_id:selectedwork[0][s.key_inspection_id],
      s.key_rural_urban:selectedwork[0][s.key_rural_urban],
    };
    if(widgetflag=="edit")
      {
        dataset.addAll(set);
      }
    inspection_work_details.add(dataset);

    Map main_dataset = {
      s.key_service_id: s.service_key_action_taken_details_save,
      'inspection_work_details': inspection_work_details,
    };

    Map encrpted_request = {
      s.key_user_name: prefs.getString(s.key_user_name),
      s.key_data_content: main_dataset,
    };

    String jsonString = jsonEncode(encrpted_request);

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
        body: jsonEncode(encrpted_request), headers: header);
    // http.Response response = await http.post(url.main_service, body: json.encode(encrpted_request));
    // print("onlineSave_url>>${url.main_service}");
    // print("onlineSave_request_json>>$main_dataset");
    // print("onlineSave_request_encrpt>>$encrpted_request");
    isSpinnerLoading = false;
    notifyListeners();
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      String data = response.body;
      print("onlineSave_response>>$data");
      String? authorizationHeader = response.headers['authorization'];

      String? token = authorizationHeader?.split(' ')[1];

      print("onlineSave Authorization -  $token");

      String responceSignature = utils.jwt_Decode(key, token!);

      String responceData = utils.generateHmacSha256(data, key, false);

      print("onlineSave responceSignature -  $responceSignature");

      print("onlineSave responceData -  $responceData");

      if (responceSignature == responceData) {
        print("ProfileData responceSignature - Token Verified");
        var userData = jsonDecode(data);
      var status = userData[s.key_status];
      var response_value = userData[s.key_response];
      var msg = userData[s.key_message];
      if (status == s.key_ok && response_value == s.key_ok) {
        utils.customAlert(context, "S", s.online_data_save_success).then((value) =>onWillPop(context));
        gotoDelete(selectedwork,true);
/*        Timer(Duration(seconds: 3), () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ATR_Worklist(
              Flag: widgetrural_urban,
            ),
          ));
        });*/

      } else {
        utils.customAlert(context, "E", s.no_data).then((value) => onWillPop(context));
      }

    }
  }
  Future<bool> onWillPop(BuildContext context) async {
    Navigator.of(context, rootNavigator: true).pop(context);
    return true;
  }

  // *************************** SAVE DATA Ends here *************************** //

  // *************************** INSERT DATA *************************** //

  Future<void> offlineSave(BuildContext context) async {
    isSpinnerLoading = true;
    notifyListeners();
    var count = 0;
    var imageCount = 0;

    var isExists = await dbClient.rawQuery(
        "SELECT count(1) as cnt  FROM ${s.table_save_work_details} WHERE rural_urban = '${selectedwork[0][s.key_rural_urban].toString()}' and work_id='${selectedwork[0][s.key_work_id].toString()}' and inspection_id='${selectedwork[0][s.key_inspection_id].toString()}' and dcode='${selectedwork[0][s.key_dcode].toString()}'");

    // print(isExists);
    // print(imageExists);

    if (isExists[0]['cnt'] > 0) {
      print("Edit>>>>");

      for (int i = 0; i < selectedwork.length; i++) {
        count = await dbClient.rawInsert(" UPDATE " +
            s.table_save_work_details +
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
            s.table_save_work_details +
            ' (flag, dcode, bcode , pvcode, inspection_id, description , work_id, work_name, rural_urban, town_type, tpcode, muncode, corcode) VALUES('
                "'ATR' ," +
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
            selectedwork[i][s.key_work_name] +
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
            "SELECT * FROM ${s.table_save_images} WHERE rural_urban = '${selectedwork[0][s.key_rural_urban].toString()}' and work_id='${selectedwork[0][s.key_work_id].toString()}' and inspection_id='${selectedwork[0][s.key_inspection_id].toString()}' and dcode='${selectedwork[0][s.key_dcode].toString()}' and serial_no='${serial_count.toString()}'");

        if (imageExists.length > 0) {
          await File(imageExists[0][s.key_image_path]).exists()
              ? await File(imageExists[0][s.key_image_path]).delete()
              : null;

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

          print(img_jsonArray_val[i][s.key_image_path].toString());
          imageCount = await dbClient.rawInsert('INSERT INTO ' +
              s.table_save_images +
              ' (flag, work_id, inspection_id, image_description, latitude, longitude, serial_no, rural_urban,  dcode, bcode, pvcode, tpcode, muncode, corcode, image_path, image) VALUES('
                  "'ATR' ," +
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
    isSpinnerLoading = false;
    notifyListeners();

    if (count > 0 && imageCount > 0) {
      utils.customAlert(context, "S", s.save_success).then((value) => {
        Navigator.pop(context)
      });
    }
  }

  // *************************** INSERT DATA Ends here *************************** //

  // *************************** Check DATA Ends here *************************** //

  Future<void> checkData() async {
    var isExists = await dbClient.rawQuery(
        "SELECT * FROM ${s.table_save_work_details} WHERE rural_urban='${selectedwork[0][s.key_rural_urban].toString()}' and work_id='${selectedwork[0][s.key_work_id].toString()}' and inspection_id='${selectedwork[0][s.key_inspection_id].toString()}' and dcode='${selectedwork[0][s.key_dcode].toString()}'");
    var imageExists = await dbClient.rawQuery(
        "SELECT * FROM ${s.table_save_images} WHERE rural_urban='${selectedwork[0][s.key_rural_urban].toString()}' and work_id='${selectedwork[0][s.key_work_id].toString()}' and inspection_id='${selectedwork[0][s.key_inspection_id].toString()}' and dcode='${selectedwork[0][s.key_dcode].toString()}'");

    if (isExists.length > 0 && imageExists.length > 0) {
      for (int i = 0; i < imageExists.length; i++) {
        img_jsonArray[i]
            .update(s.key_latitude, (value) => imageExists[i][s.key_latitude]);
        img_jsonArray[i].update(
            s.key_longitude, (value) => imageExists[i][s.key_longitude]);
        img_jsonArray[i].update(
            s.key_image_path, (value) => imageExists[i][s.key_image_path]);
        img_jsonArray[i]
            .update(s.key_image, (value) => imageExists[i][s.key_image]);
        img_jsonArray[i].update(s.key_image_description,
                (value) => imageExists[i][s.key_image_description]);
      }

      descriptionController.text = isExists[0][s.key_description];
      notifyListeners();
    }
  }

  // *************************** Check DATA Ends here *************************** //

  /// ************************** Check Camera Permission *****************************/

  Future<bool> goToCameraPermission(BuildContext context) async {
    cameraPermission = await Permission.camera.status;
    print("object$cameraPermission");

    bool flag = false;
    if (await Permission.camera.request().isGranted) {
      cameraPermission = await Permission.camera.status;
      flag = true;
      print("object$cameraPermission");
    }
    if (cameraPermission.isDenied || cameraPermission.isPermanentlyDenied) {
      Utils().showAppSettings(context, s.cam_permission);
    }
    return flag;
  }
  gotoDelete(List workList, bool save) async {
    String conditionParam = "";

    String flag = 'ATR';
    String workid = workList[0][s.key_work_id].toString();
    String dcode = workList[0][s.key_dcode].toString();
    String rural_urban = widgetrural_urban;
    String inspection_id = workList[0][s.key_inspection_id].toString();
    print("flag>>>>"+flag.toString());

    if (flag == "ATR") {
      conditionParam =
      "WHERE flag='$flag' and rural_urban='$rural_urban' and work_id='$workid' and inspection_id='$inspection_id' and dcode='$dcode'";
    } else {
      conditionParam =
      "WHERE flag='$flag'and rural_urban='$rural_urban' and work_id='$workid' and dcode='$dcode'";
    }

    var imageDelete = await dbClient
        .rawQuery("DELETE FROM ${s.table_save_images} $conditionParam ");
    var workListDelete = await dbClient
        .rawQuery("DELETE FROM ${s.table_save_work_details} $conditionParam");

  }
}