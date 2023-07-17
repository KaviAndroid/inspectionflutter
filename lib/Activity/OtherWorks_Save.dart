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
import 'package:inspection_flutter_app/Layout/SaveOtherWorkDataController.dart';
import 'package:provider/provider.dart';
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
  final selectedworkList;
  final imagelist;
  final onoff_type;

  OtherWork_Save(
      {this.category,
      this.finYear,
      this.dcode,
      this.bcode,
      this.pvcode,
      this.tmccode,
      this.townType,
      this.flag,
        this.selectedworkList,
        this.imagelist,
        this.onoff_type});

  @override
  State<OtherWork_Save> createState() => _OtherWork_SaveState();
}

class _OtherWork_SaveState extends State<OtherWork_Save> {
  Utils utils = Utils();
   late SaveOtherWorkDatacontroller refer;

  @override
  void initState() {
    setState(() {
    });
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context, rootNavigator: true).pop(context);
    return true;
  }

  /// This has to happen only once per app

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: MultiProvider(
        providers: [
        ChangeNotifierProvider(create: (_) => SaveOtherWorkDatacontroller(widget.category, widget.finYear, widget.dcode, widget.bcode, widget.pvcode, widget.tmccode, widget.townType, widget.flag, widget.selectedworkList, widget.imagelist, widget.onoff_type))
    ],
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
    body: Consumer<SaveOtherWorkDatacontroller>(builder: (context, ref, child) {
    refer=ref;
    return Container(
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
                          OtherWorkdetail(),
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
                          refer.validate(context);
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
                    ),
                  ]),
            );}))
        ));
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
            visible: refer.imageListFlag,
            child: Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: refer.img_jsonArray == null ? 0 : refer.img_jsonArray.length,
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
                                  if(widget.flag=="edit")
                                  {
                                    utils.showAlert(context, "Image Can't edit");
                                  }
                                  else
                                  {
                                    refer.goToCameraScreen(index,context);
                                  }
                                },
                                child: refer.img_jsonArray[index]['image'] == '0'
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
                },
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
                      refer.lang = 'en_US';
                      refer.speech = true;
                      refer.startListening(refer.descriptionController.text);
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
                      refer.startListening(refer.descriptionController.text);
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
  OtherWorkdetail()
  {
    return  Container(
        margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: TextFormField(
        controller: refer.otherWorkDetailsController,
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
    );
  }
  StatusView() {
    return Visibility(
      visible: refer.statusvisibility,
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    width: refer.statusError ? 1 : 0.1,
                    color: refer.statusError ? c.red : c.grey_10),
                borderRadius: BorderRadius.circular(10.0)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2(
                style: const TextStyle(color: Colors.black),
                value: refer.selectedStatus,
                isExpanded: true,
                items: refer.statusItems
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
                  refer.setStatus(value);
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
            visible: refer.statusError ? true : false,
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
      ),
    );
  }



  // *************************** API Call Ends Here here *************************** //
}
