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


class SaveDatacontroller with ChangeNotifier {
  Utils utils = Utils();
  late SharedPreferences prefs;
  var dbHelper = DbHelper();
  var dbClient;
  bool noDataFlag = false;
  bool imageListFlag = false;
  List<Map<String, String>> img_jsonArray = [];
  List<Map<String, String>> img_jsonArray_val = [];
  String workmage = '';
  String onoffType = '';
  String rural_urban = '';
  String widgetonoff_type = '';
  String widgetrural_urban = '';
  String widgettownType = '';
  String widgetflag = '';
  TextEditingController descriptionController = TextEditingController();
  String selectedStatus = "";
  String selectedStage = "";
  String selectedStatusName = "";
  String selectedStageName = "";
  List selectedwork = [];
  List widgetselectedworkList = [];
  List widgetimagelist = [];
  List statusItems = [];
  List stageItems = [];
  List stageItemsAll = [];
  bool txtFlag = false;
  bool statusError = false;
  bool stageError = false;
  final _picker = ImagePicker();
  var _imageFile;
  List imageList=[];
  bool stagevisibility=false;
  bool statusvisibility=false;

  Map<String, String> defaultSelectedStatus = {
    s.key_status_id: '0',
    s.key_status_name: s.select_status,
  };
  Map<String, String> defaultSelectedStage = {
    s.key_work_group_id: '0',
    s.key_work_type_id: '0',
    s.key_work_stage_code: '00',
    s.key_work_stage_name: s.select_stage,
  };
  TextEditingController remark = TextEditingController();
  SpeechToText _speechToText = SpeechToText();
  bool speechEnabled = false;
  bool speech = false;
  String lastWords = '';
  String lang = 'en_US';
  int max_img_count=0;

  SaveDatacontroller(rural_urban, onoff_type, selectedworkList, townType, flag, imagelist) {
     widgetonoff_type = onoff_type;
     widgetrural_urban = rural_urban;
     widgettownType = townType;
     widgetflag = flag;
     widgetselectedworkList.addAll(selectedworkList);
     widgetimagelist.addAll(imagelist);

     initialize();
    initSpeech();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    dbClient = await dbHelper.db;
    txtFlag = true;
    onoffType=widgetonoff_type;
    rural_urban=widgetrural_urban;
    selectedwork = widgetselectedworkList;
    print("selectedwork"+selectedwork.toString());
    if(widgetflag=="edit")
    {
      stagevisibility;
      statusvisibility;
      selectedStatus = defaultSelectedStatus[s.key_status_id]!;
      selectedStatusName = defaultSelectedStatus[s.key_status_name]!;
      selectedStage = defaultSelectedStage[s.key_work_stage_code].toString();
      selectedStageName = defaultSelectedStage[s.key_work_stage_name].toString();
      descriptionController.text=selectedwork[0]['description'];
      // imageList.addAll(widget.);
    }
    else
    {
      stagevisibility=true;
      statusvisibility=true;
      var isExists = await dbClient.rawQuery(
          "SELECT count(1) as cnt  FROM ${s.table_save_work_details} WHERE work_id='${selectedwork[0][s.key_work_id].toString()}' and rural_urban='${rural_urban}' and flag='rdpr'");
      if (isExists[0]['cnt'] > 0) {
        print("exists>>>>");
        List<Map> list = await dbClient.rawQuery('SELECT * FROM ' + s.table_save_work_details+" WHERE work_id='${selectedwork[0][s.key_work_id].toString()}' and rural_urban='${rural_urban}' and flag='rdpr'");
        selectedStatus=list[0]['work_status_id'];
        selectedStatusName=list[0]['work_status'];
        selectedStage=list[0]['work_stage_id'];
        selectedStageName=list[0]['work_stage'];
        descriptionController.text=list[0]['description'];
      }else{
        selectedStatus = defaultSelectedStatus[s.key_status_id]!;
        selectedStatusName = defaultSelectedStatus[s.key_status_name]!;
        selectedStage = defaultSelectedStage[s.key_work_stage_code].toString();
        selectedStageName = defaultSelectedStage[s.key_work_stage_name].toString();
        descriptionController.text="";
      }
    }
    await loadImageList();

    List<Map> list = await dbClient.rawQuery('SELECT * FROM ' + s.table_Status);
    print(list.toString());
    statusItems.add(defaultSelectedStatus);
    statusItems.addAll(list);
    print('status>>' + statusItems.toString());

    await loadStages();

    notifyListeners();
  }

  /// This has to happen only once per app
  void initSpeech() async {
    speechEnabled = false;
    _speechToText.initialize();
    notifyListeners();
  }

  /// Each time to start a speech recognition session
  void startListening(String txt) async {
    speechEnabled = false;
    lastWords = txt;
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
    speechEnabled = true;
    print("stop");
    speech = false;
    notifyListeners();
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void onSpeechResult(recognition.SpeechRecognitionResult result) {
    // _lastWords = result.recognizedWords;
    descriptionController.text = lastWords + ' ' + result.recognizedWords;
    speech = false;
    notifyListeners();
    print("start" + descriptionController.text);
  }

  Future<void> goToCameraScreen(int i, BuildContext context) async {
    final hasPermission = await utils.handleLocationPermission(context);

    if (!hasPermission) return;
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("latitude>>" + position.latitude.toString());
    print("longitude>>" + position.longitude.toString());
    if (position.latitude != null && position.longitude != null) {
      TakePhoto(ImageSource.camera, i, position.latitude.toString(),
          position.longitude.toString(),context);
    } else {
      utils.showAlert(context, "Try Again...");
    }
  }

  Future<void> TakePhoto(
      ImageSource source, int i, String latitude, String longitude, BuildContext context) async {
    // final pickedFile = await _picker.pickImage(source: source);
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
      img_jsonArray[i].update('latitude', (value) => latitude);
      img_jsonArray[i].update('longitude', (value) => longitude);
      img_jsonArray[i].update('image', (value) => workmage);
      _imageFile = File(pickedFile.path);
      print("ImageList>>" + img_jsonArray.toString());

      notifyListeners();
    }
    // Navigator.pop(context);
  }

  Future<void> loadStages() async {
    List<Map> stageList =
    await dbClient.rawQuery('SELECT * FROM ' + s.table_WorkStages);
    print(stageList.toString());
    stageItemsAll.addAll(stageList);
    stageItems.add(defaultSelectedStage);
    print('stage>>' + stageItems.toString());
    print('stageItemsAll>>' + stageItemsAll.toString());
    print('stageItemsAll>>' + stageItemsAll.length.toString());

    // stageItems.addAll(stageItemsAll);
    for (int i = 0; i < stageItemsAll.length; i++) {
      if (stageItemsAll[i][s.key_work_group_id].toString() ==
          selectedwork[0][s.key_work_group_id].toString() &&
          stageItemsAll[i][s.key_work_type_id].toString() ==
              selectedwork[0][s.key_work_type_id].toString()) {
        stageItems.add(stageItemsAll[i]);
      }
    }
    print('stage>>' + stageItems.toString());
    print('stage>>' + stageItems.length.toString());
  }

  Future<void> validate(BuildContext context) async {
    if(widgetflag=="edit")
    {
      if (await checkImageList(img_jsonArray)) {
        if (!descriptionController.text.isEmpty &&
            descriptionController.text != '') {
          onoffType=="online"?saveData(context):saveDataOffline(context);

        } else {
          utils.showAlert(context, "Please Enter Description");
        }

      } else {
        utils.showAlert(context, "At least Capture one Photo");
      }

    }else{
    if (await checkImageList(img_jsonArray)) {
      if (!selectedStage.isEmpty && selectedStage != '00') {
        if (!descriptionController.text.isEmpty &&
            descriptionController.text != '') {
          if (!selectedStatus.isEmpty && selectedStatus != '0') {
            onoffType=="online"?saveData(context):saveDataOffline(context);
          } else {
            utils.showAlert(context, "Please Select Status");
          }
        } else {
          utils.showAlert(context, "Please Enter Description");
        }
      } else {
        utils.showAlert(context, "Please Select Stage");
      }
    } else {
      utils.showAlert(context, "At least Capture one Photo");
    }
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

  Future<void> saveData(BuildContext context) async {
    List<dynamic> jsonArray = [];
    List<dynamic> inspection_work_details = [];
    for (int i = 0; i < img_jsonArray_val.length; i++) {
      int count=i+1;
      img_jsonArray[i].update('serial_no', (value) => count.toString());
      jsonArray.add(img_jsonArray_val[i]);
    }

    Map dataset = {
      s.key_dcode: selectedwork[0][s.key_dcode].toString(),
      s.key_rural_urban: prefs.getString(s.key_rural_urban),
      s.key_work_id: selectedwork[0][s.key_work_id].toString(),
      'description': descriptionController.text.toString(),
    };
    Map ruralset = {};
    Map urbanset = {};
    Map imgset = { 'image_details': jsonArray,};

    if(widgetflag=="edit")
    {
      Map set = {
        s.key_inspection_id: selectedwork[0][s.key_inspection_id],
      };
      dataset.addAll(set);
    }
    else
    {
      Map set = {
      s.key_status_id: selectedStatus,
      s.key_work_stage_code: selectedStage,
      s.key_work_group_id: selectedwork[0][s.key_work_group_id].toString(),
      s.key_work_type_id: selectedwork[0][s.key_work_type_id].toString(),
    };
    dataset.addAll(set);

    }


    if (rural_urban == "U") {
      if(widgettownType == "T"){
        urbanset = {
          s.key_town_type: widgettownType,
          s.key_tpcode: selectedwork[0][s.key_tpcode],
        };

      }else if(widgettownType == "M"){
        urbanset = {
          s.key_town_type: widgettownType,
          s.key_muncode: selectedwork[0][s.key_muncode],
        };

      }else if(widgettownType == "C"){
        urbanset = {
          s.key_town_type: widgettownType,
          s.key_corcode: selectedwork[0][s.key_corcode],
        };

      }
      dataset.addAll(urbanset);
    }else{
      ruralset = {
        s.key_bcode: selectedwork[0][s.key_bcode].toString(),
        s.key_pvcode: selectedwork[0][s.key_pvcode].toString(),
        s.key_hab_code: selectedwork[0][s.key_hab_code].toString(),
      };
      dataset.addAll(ruralset);
    }
    dataset.addAll(imgset);

    inspection_work_details.add(dataset);

    Map main_dataset = {
      s.key_service_id: s.service_key_work_inspection_details_save,
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
        utils.customAlert(context, "S", s.online_data_save_success).then((value) => onWillPop(context));
      } else {
        utils.customAlert(context, "E", s.no_data).then((value) => onWillPop(context));
      }
    }
  }
  Future<void> saveDataOffline(BuildContext context) async{
    var count = 0;
    var imageCount = 0;

    var isExists = await dbClient.rawQuery(
        "SELECT count(1) as cnt  FROM ${s.table_save_work_details} WHERE work_id='${selectedwork[0][s.key_work_id].toString()}' and rural_urban='${rural_urban}' and flag='rdpr'");
    if (isExists[0]['cnt'] > 0) {
      print("Edit>>>>");
      print("Edit>>>>"+isExists.toString());
      for (int i = 0; i < selectedwork.length; i++) {
        count = await dbClient.rawInsert(" UPDATE " +
            s.table_save_work_details +
            " SET description = '" +
            descriptionController.text +
            "', work_status_id = '" +
            selectedStatus +
            "', work_status = '" +
            selectedStatusName +
            "', work_stage_id = '" +
            selectedStage +
            "', work_stage = '" +
            selectedStageName +
            "' WHERE rural_urban = '" +
            rural_urban.toString()  +
            "' AND work_id = '" +
            selectedwork[i][s.key_work_id].toString() +
            "'AND flag =  '" +
            "rdpr" +
            "'AND dcode =  '" +
            selectedwork[i][s.key_dcode].toString() +
            "'");
      }

    }else{
      for (int i = 0; i < selectedwork.length; i++) {
        if(rural_urban=="R"){
          count = await dbClient.rawInsert('INSERT INTO ' +
              s.table_save_work_details +
              ' (flag  ,rural_urban  , dcode  , bcode , pvcode , work_id , scheme_id ,work_status_id , work_status , work_stage_id , work_stage ,current_stage_of_work , scheme_group_id , work_group_id , work_type_id , fin_year , work_name , inspection_id , description , town_type , tpcode , muncode , corcode    ) VALUES(' +
              "'" +
              "rdpr" +
              "' , '" +
              rural_urban.toString() +
              "' , '" +
              selectedwork[i][s.key_dcode].toString() +
              "' , '" +
              selectedwork[i][s.key_bcode].toString() +
              "' , '" +
              selectedwork[i][s.key_pvcode].toString() +
              "' , '" +
              selectedwork[i][s.key_work_id].toString() +
              "' , '" +
              selectedwork[i][s.key_scheme_id].toString() +
              "' , '" +
              selectedStatus +
              "' , '" +
              selectedStatusName +
              "' , '" +
              selectedStage +
              "' , '" +
              selectedStageName +
              "' , '" +
              selectedwork[i][s.key_current_stage_of_work].toString() +
              "' , '" +
              selectedwork[i][s.key_scheme_group_id].toString() +
              "' , '" +
              selectedwork[i][s.key_work_group_id].toString() +
              "' , '" +
              selectedwork[i][s.key_work_type_id].toString() +
              "' , '" +
              selectedwork[i][s.key_fin_year].toString() +
              "' , '" +
              selectedwork[i][s.key_work_name].toString() +
              "' , '" +
              "0" +
              "' , '" +
              descriptionController.text.toString() +
              "' , '" +
              "0"+
              "' , '" +
              "0" +
              "' , '" +
              "0" +
              "' , '" +
              "0" +
              "')");
        }else{
          if(widgettownType=="T"){
            count = await dbClient.rawInsert('INSERT INTO ' +
                s.table_save_work_details +
                ' (flag  ,rural_urban  , dcode  , bcode , pvcode , work_id , scheme_id ,work_status_id , work_status , work_stage_id , work_stage ,current_stage_of_work , scheme_group_id , work_group_id , work_type_id , fin_year , work_name , inspection_id , description , town_type , tpcode , muncode , corcode    ) VALUES(' +
                "'" +
                "rdpr" +
                "' , '" +
                rural_urban.toString() +
                "' , '" +
                selectedwork[i][s.key_dcode].toString() +
                "' , '" +
                "0" +
                "' , '" +
                "0" +
                "' , '" +
                selectedwork[i][s.key_work_id].toString() +
                "' , '" +
                selectedwork[i][s.key_scheme_id].toString() +
                "' , '" +
                selectedStatus +
                "' , '" +
                selectedStatusName +
                "' , '" +
                selectedStage +
                "' , '" +
                selectedStageName +
                "' , '" +
                selectedwork[i][s.key_current_stage_of_work].toString() +
                "' , '" +
                selectedwork[i][s.key_scheme_group_id].toString() +
                "' , '" +
                selectedwork[i][s.key_work_group_id].toString() +
                "' , '" +
                selectedwork[i][s.key_work_type_id].toString() +
                "' , '" +
                selectedwork[i][s.key_fin_year].toString() +
                "' , '" +
                selectedwork[i][s.key_work_name].toString() +
                "' , '" +
                "0" +
                "' , '" +
                descriptionController.text.toString() +
                "' , '" +
                widgettownType+
                "' , '" +
                selectedwork[i][s.key_tpcode].toString() +
                "' , '" +
                "0" +
                "' , '" +
                "0" +
                "')");
          }
          else if(widgettownType=="M"){
            count = await dbClient.rawInsert('INSERT INTO ' +
                s.table_save_work_details +
                ' (flag  ,rural_urban  , dcode  , bcode , pvcode , work_id , scheme_id ,work_status_id , work_status , work_stage_id , work_stage ,current_stage_of_work , scheme_group_id , work_group_id , work_type_id , fin_year , work_name , inspection_id , description , town_type , tpcode , muncode , corcode    ) VALUES(' +
                "'" +
                "rdpr" +
                "' , '" +
                rural_urban.toString() +
                "' , '" +
                selectedwork[i][s.key_dcode].toString() +
                "' , '" +
                "0" +
                "' , '" +
                "0" +
                "' , '" +
                selectedwork[i][s.key_work_id].toString() +
                "' , '" +
                selectedwork[i][s.key_scheme_id].toString() +
                "' , '" +
                selectedStatus +
                "' , '" +
                selectedStatusName +
                "' , '" +
                selectedStage +
                "' , '" +
                selectedStageName +
                "' , '" +
                selectedwork[i][s.key_current_stage_of_work].toString() +
                "' , '" +
                selectedwork[i][s.key_scheme_group_id].toString() +
                "' , '" +
                selectedwork[i][s.key_work_group_id].toString() +
                "' , '" +
                selectedwork[i][s.key_work_type_id].toString() +
                "' , '" +
                selectedwork[i][s.key_fin_year].toString() +
                "' , '" +
                selectedwork[i][s.key_work_name].toString() +
                "' , '" +
                "0" +
                "' , '" +
                descriptionController.text.toString() +
                "' , '" +
                widgettownType+
                "' , '" +
                "0" +
                "' , '" +
                selectedwork[i][s.key_muncode].toString()+
                "' , '" +
                "0" +
                "')");
          }
          else if(widgettownType=="C"){
            count = await dbClient.rawInsert('INSERT INTO ' +
                s.table_save_work_details +
                ' (flag  ,rural_urban  , dcode  , bcode , pvcode , work_id , scheme_id ,work_status_id , work_status , work_stage_id , work_stage ,current_stage_of_work , scheme_group_id , work_group_id , work_type_id , fin_year , work_name , inspection_id , description , town_type , tpcode , muncode , corcode    ) VALUES(' +
                "'" +
                "rdpr" +
                "' , '" +
                rural_urban.toString() +
                "' , '" +
                selectedwork[i][s.key_dcode].toString() +
                "' , '" +
                "0" +
                "' , '" +
                "0" +
                "' , '" +
                selectedwork[i][s.key_work_id].toString() +
                "' , '" +
                selectedwork[i][s.key_scheme_id].toString() +
                "' , '" +
                selectedStatus +
                "' , '" +
                selectedStatusName +
                "' , '" +
                selectedStage +
                "' , '" +
                selectedStageName +
                "' , '" +
                selectedwork[i][s.key_current_stage_of_work].toString() +
                "' , '" +
                selectedwork[i][s.key_scheme_group_id].toString() +
                "' , '" +
                selectedwork[i][s.key_work_group_id].toString() +
                "' , '" +
                selectedwork[i][s.key_work_type_id].toString() +
                "' , '" +
                selectedwork[i][s.key_fin_year].toString() +
                "' , '" +
                selectedwork[i][s.key_work_name].toString() +
                "' , '" +
                "0" +
                "' , '" +
                descriptionController.text.toString() +
                "' , '" +
                widgettownType+
                "' , '" +
                "0" +
                "' , '" +
                "0" +
                "' , '" +
                selectedwork[i][s.key_corcode].toString() +
                "')");
          }
        }


      }
    }
    //Image Data
    if (count > 0) {
      var serial_count = 0;
      // print(img_jsonArray_val);

      for (int i = 0; i < img_jsonArray_val.length; i++) {
        serial_count++;

        var imageExists = await dbClient.rawQuery(
            "SELECT * FROM ${s.table_save_images} WHERE work_id='${selectedwork[0][s.key_work_id].toString()}' and flag='rdpr' and dcode='${selectedwork[0][s.key_dcode].toString()}'and rural_urban='${rural_urban}' and serial_no='${serial_count.toString()}'");

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
              rural_urban.toString() +
              "' AND work_id = '" +
              selectedwork[0][s.key_work_id].toString() +
              "' AND serial_no = '" +
              serial_count.toString() +
              "' AND flag = '" +
              "rdpr"+
              "' AND dcode = '" +
              selectedwork[0][s.key_dcode].toString() +
              "'");
        } else {
          print("img ins");

          print(img_jsonArray_val[i][s.key_image_path].toString());
          if(rural_urban.toString()=="R"){
            imageCount = await dbClient.rawInsert('INSERT INTO ' +
                s.table_save_images +
                ' (flag, work_id, inspection_id, image_description, latitude, longitude, serial_no, rural_urban,  dcode, bcode, pvcode, tpcode, muncode, corcode, image_path, image) VALUES('
                    "'rdpr' ," +
                "'" +
                selectedwork[0][s.key_work_id].toString() +
                "' , '" +
                "0" +
                "' , '" +
                img_jsonArray_val[i][s.key_image_description].toString() +
                "' , '" +
                img_jsonArray_val[i][s.key_latitude].toString() +
                "' , '" +
                img_jsonArray_val[i][s.key_longitude].toString() +
                "' , '" +
                serial_count.toString() +
                "' , '" +
                rural_urban.toString() +
                "' , '" +
                selectedwork[0][s.key_dcode].toString() +
                "' , '" +
                selectedwork[0][s.key_bcode].toString() +
                "' , '" +
                selectedwork[0][s.key_pvcode].toString() +
                "' , '" +
                "0" +
                "' , '" +
                "0" +
                "' , '" +
                "0" +
                "' , '" +
                img_jsonArray_val[i][s.key_image_path].toString() +
                "' , '" +
                img_jsonArray_val[i][s.key_image].toString() +
                "')");
          }
          else{
            imageCount = await dbClient.rawInsert('INSERT INTO ' +
                s.table_save_images +
                ' (flag, work_id, inspection_id, image_description, latitude, longitude, serial_no, rural_urban,  dcode, bcode, pvcode, tpcode, muncode, corcode, image_path, image) VALUES('
                    "'rdpr' ," +
                "'" +
                selectedwork[0][s.key_work_id].toString() +
                "' , '" +
                "0" +
                "' , '" +
                img_jsonArray_val[i][s.key_image_description].toString() +
                "' , '" +
                img_jsonArray_val[i][s.key_latitude].toString() +
                "' , '" +
                img_jsonArray_val[i][s.key_longitude].toString() +
                "' , '" +
                serial_count.toString() +
                "' , '" +
                rural_urban.toString() +
                "' , '" +
                selectedwork[0][s.key_dcode].toString() +
                "' , '" +
                "0" +
                "' , '" +
                "0" +
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
    }
    if (count > 0 && imageCount > 0) {
      utils.customAlert(context, "S", s.save_success).then((value) => {
        Navigator.pop(context)      });
    }
  }
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
      List<Map> list = await dbClient.rawQuery('SELECT * FROM ' + s.table_save_images+" WHERE work_id='${selectedwork[0][s.key_work_id].toString()}' and rural_urban='${rural_urban}' and flag='rdpr'");
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
      img_jsonArray.add(mymap); // mylist = [mymap];
    }

    for (int i = img_jsonArray.length; i < max_img_count; i++) {
      Map<String, String> mymap =
      {}; // This created one object in the current scope.

      // First iteration , i = 0
      mymap["latitude"] = '0'; // Now mymap = { name: 'test0' };
      mymap["longitude"] = '0'; // Now mymap = { name: 'test0' };
      mymap["serial_no"] = '0'; // Now mymap = { name: 'test0' };
      mymap["image_description"] = ''; // Now mymap = { name: 'test0' };
      mymap["image"] = '0'; // Now mymap = { name: 'test0' };
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
  Future<bool> onWillPop(BuildContext context) async {
    Navigator.of(context, rootNavigator: true).pop(context);
    return true;
  }
  Future<void> clearRemark()async{
    remark.clear();
    notifyListeners();
  }
  Future<void> setRemark(int i)async{
    img_jsonArray[i]
        .update('image_description', (value) => remark.text);
    remark.clear();
    notifyListeners();
  }
  Future<void> setStage(var value)async{
    selectedStage = value.toString();
    int sIndex = stageItems.indexWhere((f) => f[s.key_work_stage_code] == selectedStage);
    selectedStageName = stageItems[sIndex][s.key_work_stage_name];
    value != '00'?stageError = false:stageError = true;
    notifyListeners();
  }
  Future<void> setStatus(var value)async{
    selectedStatus = value.toString();
    int sIndex = statusItems.indexWhere((f) => f[s.key_status_id] == selectedStatus);
   selectedStatusName = statusItems[sIndex][s.key_status_name];
    value != '0'?statusError = false:statusError = true;
    notifyListeners();
  }
}