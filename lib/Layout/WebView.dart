import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Utils/utils.dart';

class webView extends StatefulWidget {
  final de_Url;
  webView({this.de_Url});
  @override
  createState() => _webViewState();
}

class _webViewState extends State<webView> {
  var transactionResult = "";

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
  }
  Future<bool> _onWillPop() async {
    Navigator.of(context, rootNavigator: true).pop(context);
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          elevation: 0,
          toolbarHeight: 2,
        ),
        body: SafeArea(
            child: WebView(
              initialUrl: widget.de_Url,
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (String url) async {
                _closeWebView(context);

              },
              gestureNavigationEnabled: true,
            )),
      ),
    );
  }




  _closeWebView(context) {
    Navigator.pop(context);
  }


}
