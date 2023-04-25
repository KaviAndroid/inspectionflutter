// ignore_for_file: unused_local_variable, non_constant_identifier_names, file_names, camel_case_types, prefer_typing_uninitialized_variables, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_print, library_prefixes

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:inspection_flutter_app/Resources/global.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Resources/ColorsValue.dart' as c;
import 'package:inspection_flutter_app/Resources/Strings.dart' as s;
import '../Utils/utils.dart';

class PendingScreen extends StatefulWidget {
  const PendingScreen({Key? key}) : super(key: key);

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  Utils utils = Utils();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
    // await Initial_UI_Design();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.colorPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pop(context),
        ),
        title: Text(s.pending_list),
        centerTitle: true, // like this!
      ),
      body: SingleChildScrollView(child: __PendingScreenListAdaptor()),
    );
  }

  // *************************** Pending Design Starts here *************************** //

  __PendingScreenListAdaptor() {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      width: screenWidth,
      height: sceenHeight - 100,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: AnimationLimiter(
                child: ListView.builder(itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 800),
                child: SlideAnimation(
                  horizontalOffset: 200.0,
                  child: FlipAnimation(
                      child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  )),
                ),
              );
            })),
          )
        ],
      ),
    );
  }

  // *************************** Pending Design Ends here *************************** //
}
