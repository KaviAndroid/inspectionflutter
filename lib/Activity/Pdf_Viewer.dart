// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:inspection_flutter_app/Resources/ColorsValue.dart' as c;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inspection_flutter_app/Resources/ImagePath.dart' as imagePath;

class PDF_Viewer extends StatefulWidget {
  final pdfBytes;
  PDF_Viewer({this.pdfBytes});

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

    // Get the external storage directory
    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      throw Exception("Couldn't get the external storage directory");
    }

    // Get the downloads folder path
    String downloadsPath = '${externalDir.path}/Download';
    Directory downloadsDir = Directory(downloadsPath);
    if (!downloadsDir.existsSync()) {
      downloadsDir.createSync();
    }

    // Save the PDF bytes to a file in the downloads folder
    File pdfFile = File('${downloadsDir.path}/my_pdf_file.pdf');
    try {
      await pdfFile.writeAsBytes(pdfBytes);
      showNotification(
          "PDF Downloaded", "PDF file saved successfully", pdfFile.path);
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
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    const MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
            'your_channel_id', 'your_channel_name', 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title, // Notification Title
      message, // Notification Body
      platformChannelSpecifics,
      payload: payload, // Notification Payload
    );
  }

  Future selectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  }

  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    return;
  }
}
