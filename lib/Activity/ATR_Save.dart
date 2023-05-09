// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes, prefer_const_constructors, prefer_interpolation_to_compose_strings, use_build_context_synchronously, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inspection_flutter_app/Activity/ATR_Online.dart';
import 'package:inspection_flutter_app/Layout/AtrSaveDataController.dart';
import 'package:provider/provider.dart';
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
import 'package:permission_handler/permission_handler.dart';

class ATR_Save extends StatefulWidget {
  final rural_urban, onoff_type, selectedWorklist,flag,imagelist;
  ATR_Save({this.rural_urban, this.onoff_type, this.selectedWorklist,this.flag,this.imagelist});

  @override
  State<ATR_Save> createState() => _ATR_SaveState();
}

class _ATR_SaveState extends State<ATR_Save> {
  Utils utils = Utils();
  late AtrSaveDataController refer;
  @override
  void initState() {
    super.initState();
    setState(() {

    });
  }


  /// Each time to start a speech recognition session

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
        ChangeNotifierProvider(create: (_) => AtrSaveDataController(widget.rural_urban, widget.onoff_type,widget.selectedWorklist,widget.flag,widget.imagelist))
    ],
      child:Scaffold(
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
        body: Consumer<AtrSaveDataController>(builder: (context, ref, child) {
          refer=ref;
          return
            Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            color: c.white,
            child: Stack(
              children: [
                IgnorePointer(
                  ignoring: refer.isSpinnerLoading,
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
                    visible: refer.isSpinnerLoading,
                    child: Utils().showSpinner(context, "Processing"))
              ],
            ));})

      ));
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
            visible: refer.imageListFlag,
            child: Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: List.generate(refer.img_jsonArray.length, (index) {
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
                              if(widget.flag=="edit")
                                {
                                  utils.showAlert(context, "Image can't edit");
                                }
                              else
                                {
                                  refer.goToCameraScreen(index,context);
                                }
                                },
                                child: refer.img_jsonArray[index]['image'] == '0'
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
                                                .convert(refer.img_jsonArray[index]
                                                    ['image']!)),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (refer.img_jsonArray[index]['image'] != null &&
                                    refer.img_jsonArray[index]['image'].toString() !=
                                        '0') {
                                  refer.showAlert(
                                      context,
                                      refer.img_jsonArray[index]['image_description']
                                          .toString(),
                                      index);
                                } else {
                                  utils.showAlert(
                                      context, "First capture the photo");
                                }
                              },
                              child: Container(
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
                                  refer.img_jsonArray[index]['image_description']!,
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
            visible: refer.noDataFlag,
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
                refer.descriptionController.clear();
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
            controller: refer.descriptionController,
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
          visible: refer.txtFlag ? true : false,
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
          visible: !refer.speech,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: InkWell(
                    onTap: () {
                      refer.speechEnabled = false;
                      refer.lang = 'en_US';
                      refer.speech = true;
                      refer.startListening(refer.descriptionController.text,context);
                    },
                    child: Row(
                      children: [
                        Container(
                          child: refer.speech
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
                      refer.lang = 'ta_IND';
                      refer.speech = true;
                      refer.startListening(refer.descriptionController.text,context);
                    },
                    child: Row(
                      children: [
                        Container(
                          child: refer.speech
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
          visible: refer.speech,
          child: InkWell(
            onTap: () {
              refer.stopListening();
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
            FocusManager.instance.primaryFocus?.unfocus();
            refer.validate(context);
          } else {
            utils.showAlert(context, s.no_internet);
          }
        },
        child: Container(
            alignment: AlignmentDirectional.center,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
            child: Text(
              widget.flag=="edit"?s.update: s.submit,
              style: TextStyle(
                  color: c.subscription_type_red_color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            )),
      ),
    );
  }

  // *************************** Design Ends here *************************** //

}
