import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:InspectionAppNew/Layout/SaveDataController.dart';
import 'package:provider/provider.dart';
import 'package:InspectionAppNew/Resources/Strings.dart' as s;
import 'package:InspectionAppNew/Resources/ColorsValue.dart' as c;
import 'package:InspectionAppNew/Resources/url.dart' as url;
import 'package:InspectionAppNew/Resources/ImagePath.dart' as imagePath;
import '../Utils/utils.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as recognition;

class SaveWorkDetails extends StatefulWidget {
  final rural_urban, onoff_type,selectedworkList,townType,flag,imagelist;
  SaveWorkDetails({this.rural_urban, this.onoff_type,this.selectedworkList,this.townType,this.flag,this.imagelist});
  @override
  State<SaveWorkDetails> createState() => _SaveWorkDetailsState();
}

class _SaveWorkDetailsState extends State<SaveWorkDetails>{

  Utils utils = Utils();
  late SaveDatacontroller refer;
  bool micFlagTamil=false;

  Future<bool> _onWillPop() async {
    Navigator.of(context, rootNavigator: true).pop(context);
    return true;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      if (Platform.isAndroid) {
        micFlagTamil=true;
      } else if (Platform.isIOS) {
        micFlagTamil=false;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop:_onWillPop,

        child: MultiProvider(
    providers: [
    ChangeNotifierProvider(create: (_) => SaveDatacontroller(widget.rural_urban, widget.onoff_type,widget.selectedworkList,widget.townType,widget.flag,widget.imagelist))
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
              body: Consumer<SaveDatacontroller>(builder: (context, ref, child) {
                refer=ref;
                return Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  color: c.white,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(children: [
                              listview(),
                              StatusView(),
                              stageview(),
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
                              utils.hideSoftKeyBoard(context);
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
                );
              }),
            ),
    ));

  }

  Future<void> showAlert(BuildContext context, String msg, int i) async {
    if (msg != null && msg != '0') {
      refer.remark.text = msg;
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
              controller: refer.remark,
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
                refer.clearRemark();
                Navigator.pop(context, 'Cancel');
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                refer.setRemark(i);
                Navigator.pop(context, 'OK');
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }



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
                                  showAlert(
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
        Column(
        children: [
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
                      onTap: () async {
                        await refer.initSpeech();
                        refer.startListening(context, refer.descriptionController.text,'en_US');
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
                Visibility(
                  visible: micFlagTamil,
                    child: Expanded(
                  flex: 1,
                  child: InkWell(
                      onTap: () async {
                        await refer.initSpeech();
                        refer.startListening(context, refer.descriptionController.text,'ta_IND');
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
                )),
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
        ],
        )

      ]),
    );
  }

  stageview() {
    return Visibility(
      visible: refer.stagevisibility,
        child: Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 15),
          child: Text(
            s.select_stage,
            style: GoogleFonts.getFont('Roboto',
                fontWeight: FontWeight.w800, fontSize: 12, color: c.grey_8),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: c.grey_out,
              border: Border.all(
                  width: refer.stageError ? 1 : 0.1,
                  color: refer.stageError ? c.red : c.grey_10),
              borderRadius: BorderRadius.circular(10.0)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2(
              style: const TextStyle(color: Colors.black),
              value: refer.selectedStage,
              isExpanded: true,
              items: refer.stageItems
                  .map((item) => DropdownMenuItem<String>(
                        value: item[s.key_work_stage_code].toString(),
                        child: Text(
                          item[s.key_work_stage_name].toString(),
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                refer.setStage(value);
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
          visible: refer.stageError ? true : false,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              s.please_enter_stage,
              // state.hasError ? state.errorText : '',
              style:
                  TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
            ),
          ),
        ),
      ]),
    ));
  }

  StatusView() {
    return  Visibility(
        visible: refer.statusvisibility,
      child:Container(
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
    ));
  }



}
