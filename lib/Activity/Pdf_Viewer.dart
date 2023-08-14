// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print

import 'dart:ffi';


import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:InspectionAppNew/Utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:InspectionAppNew/Resources/ColorsValue.dart' as c;
import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:InspectionAppNew/Resources/Strings.dart' as s;

class PDF_Viewer extends StatefulWidget {
  final pdfBytes;
  final workID;
  final inspectionID;
  final flag;
  PDF_Viewer({this.pdfBytes, this.workID, this.inspectionID, this.flag});

  @override
  State<PDF_Viewer> createState() => _PDF_ViewerState();
}

class _PDF_ViewerState extends State<PDF_Viewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.colorPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_rounded, color: Colors.white),
            onPressed: () => {downloadPDF(widget.pdfBytes)},
          )
        ],
        title: const Text("Document"),
        centerTitle: true, // like this!
      ),
      body: SfPdfViewer.memory(widget.pdfBytes),
    );
  }

  // ********************************************* Download PDF Func ***************************************//

  Future<void> downloadPDF(Uint8List pdfBytes) async {
    bool flag = false;
    PermissionStatus status;

    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var sdkInt = androidInfo.version.sdkInt;
      if (sdkInt >= 30) {
        print("sdk version $sdkInt");
        status = await Permission.manageExternalStorage.request();
        if (status != PermissionStatus.granted) {
          await Utils().showAppSettings(context, s.storage_permission);
        } else {
          flag = true;
        }
      } else {
        print("sdk version $sdkInt");
        status = await Permission.storage.request();
        if (status != PermissionStatus.granted) {
          await Utils().showAppSettings(context, s.storage_permission);
        } else {
          flag = true;
        }
      }
    } else if (Platform.isIOS) {
      flag = true;
    } else {
      throw Exception('Unsupported platform');
    }

    print("Permission Status $flag");

    if (flag) {
      Directory? downloadDirectory;

      if (Platform.isAndroid) {
        downloadDirectory = Directory('/storage/emulated/0/Download');
        if (!await downloadDirectory.exists()) {
          downloadDirectory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        downloadDirectory = await getApplicationDocumentsDirectory();
        print("IOS - $downloadDirectory");
      }

      downloadDirectory ??= await getApplicationDocumentsDirectory();
      print("ANDROID 2 - $downloadDirectory");

      String downloadsPath = downloadDirectory.path;

      Directory downloadsDir = Directory(downloadsPath);
      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync();
      }

      try {
        await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
          //It would be more appropriate if you can show your own dialog
          //to the user before requesting the notifications permissons.
          if (!isAllowed) {
            AwesomeNotifications().requestPermissionToSendNotifications(
              permissions: [
                NotificationPermission.Alert,
                NotificationPermission.Sound,
                NotificationPermission.Badge,
                NotificationPermission.Vibration,
                NotificationPermission.Light,
                NotificationPermission.FullScreenIntent,
              ],
            );
          } else {
            setPDFDirectory(downloadsDir, pdfBytes);
          }
        });
      } catch (e) {
        print('Error writing PDF to file: $e');
        return;
      }
    }
  }

  // ********************************************* Notification PDF Func ***************************************//

  Future<void> showNotification(
      String title, String message, String payload) async {
    await AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      // resource://drawable/logo
      null,
      [
        NotificationChannel(
            channelKey: 'view_pdf',
            channelName: 'PDF',
            channelDescription: 'channel_description',
            importance: NotificationImportance.Max,
            icon: null)
      ],
      debug: true,
    );

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'view_pdf', //Same as above in initilize,
        title: title,
        body: message,
        wakeUpScreen: true,
        fullScreenIntent: true,
        criticalAlert: true,
        //Other parameters
      ),
      // actionButtons: <NotificationActionButton>[
      //   NotificationActionButton(key: 'view', label: 'View'),
      // ],
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: (receivedAction) {
        print("<<<<<<<<<<<<<< Notification Tapped >>>>>>>>>>>>>>>");
        _openFilePath(payload);

        // if (receivedAction.buttonKeyPressed == "view") {
        //   _openFilePath(payload);
        // }
        throw ("DOne");
      },
    );
  }

  void _openFilePath(String path) async {
    final result = await OpenFile.open(path);
    /*if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      print("asdsdasd $status");

      if (status != PermissionStatus.granted) {
        status = await Permission.manageExternalStorage.request();
      }
      if (status.isGranted) {
        final result = await OpenFile.open(path);
      } else {
        Utils().showAppSettings(context, s.storage_permission);
      }

    } else if (Platform.isIOS) {
      final result = await OpenFile.open(path);
    }*/
  }

  Future<void> showAppSettings(BuildContext context, String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(msg,
              style: GoogleFonts.getFont('Roboto',
                  fontSize: 15, fontWeight: FontWeight.w800, color: c.black)),
          actions: <Widget>[
            TextButton(
              child: Text('Allow Permission',
                  style: GoogleFonts.getFont('Roboto',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: c.primary_text_color2)),
              onPressed: () {
                Navigator.pop(context, true);
                Permission.manageExternalStorage.request();
              },
            ),
          ],
        );
      },
    );
  }

  void setPDFDirectory(Directory downloadsDir, Uint8List pdfBytes) async {
    String fileName;

    if (widget.flag == 'planned_delay_works') {
      fileName =
          "Inspection Plan_${DateFormat('dd-MM-yyyy_HH-mm-ss').format(DateTime.now())}";
    }else if (widget.workID != null) {
      fileName =
          "Inspection${widget.inspectionID}_${widget.workID}_${DateFormat('dd-MM-yyyy_HH-mm-ss').format(DateTime.now())}";
    } else {
      fileName =
          "OtherWorks_${DateFormat('dd-MM-yyyy_HH-mm-ss').format(DateTime.now())}";
    }

    // Save the PDF bytes to a file in the downloads folder
    File pdfFile = File('${downloadsDir.path}/$fileName.pdf');
    await pdfFile.writeAsBytes(pdfBytes);

    showNotification(s.appName, "File Path : ${pdfFile.path}", pdfFile.path);
  }
}
