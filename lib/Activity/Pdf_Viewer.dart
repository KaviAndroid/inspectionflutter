// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'dart:io';
import 'dart:typed_data';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:open_file/open_file.dart';

class PDF_Viewer extends StatefulWidget {
  final pdfBytes;
  final workID;
  final inspectionID;
  PDF_Viewer({this.pdfBytes, this.workID, this.inspectionID});

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
    // Check if we have storage permission
    var status = await Permission.storage.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Permission denied');
      }
    }

    Directory? downloadDirectory;

    if (Platform.isAndroid) {
      List<Directory>? storageDirectories =
          await getExternalStorageDirectories();
      if (storageDirectories != null && storageDirectories.isNotEmpty) {
        // Choose the first directory which usually represents the primary external storage
        downloadDirectory = Directory('${storageDirectories[0].path}/Download');
        print("ANDROID 1 - $downloadDirectory");
      }
    } else if (Platform.isIOS) {
      downloadDirectory = await getDownloadsDirectory();
      print("IOS - $downloadDirectory");
    }

    downloadDirectory ??= await getApplicationDocumentsDirectory();
    print("ANDROID 2 - $downloadDirectory");

    // Get the downloads folder path
    // Directory? directory = Platform.isAndroid
    //     ? await getExternalStorageDirectory()
    //     : await getDownloadsDirectory();

    String downloadsPath = '${downloadDirectory.path}/Download';

    Directory downloadsDir = Directory(downloadsPath);
    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync();
    }

    String fileName = "Inspection${widget.inspectionID}_${widget.workID}";

    // Save the PDF bytes to a file in the downloads folder
    File pdfFile = File('${downloadsDir.path}/$fileName.pdf');
    try {
      await pdfFile.writeAsBytes(pdfBytes);
      showNotification(
          "Inspection App", "PDF file saved successfully", pdfFile.path);
    } catch (e) {
      print('Error writing PDF to file: $e');
      return;
    }

    print('PDF file saved successfully');
    print('PDF file path: ${pdfFile.path}');
  }

  // ********************************************* Notification PDF Func ***************************************//

  Future<void> showNotification(
      String title, String message, String payload) async {
    await AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
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
      }
    });

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
      actionButtons: <NotificationActionButton>[
        NotificationActionButton(key: 'view', label: 'View'),
      ],
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: (receivedAction) {
        print("${receivedAction.buttonKeyPressed} - action here");
        if (receivedAction.buttonKeyPressed == "view") {
          print("Success");
          _openFilePath(payload);
        }
        throw ("DOne");
      },
    );
  }

  void _openFilePath(String path) async {
    final result = await OpenFile.open(path);
  }
}
