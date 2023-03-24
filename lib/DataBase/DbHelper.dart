import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../ModelClass/ModelClass.dart';


class DbHelper{

  Database? myDb;

  Future<Database?> get db async {
    if (myDb != null) return myDb;
    myDb = await initDb();
    return myDb;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "inspection.db");
    var theDb = await openDatabase(path, version: 1, onCreate: onCreate);
    return theDb;
  }

   void onCreate(Database db,int version) async{
     db.execute('DROP TABLE IF EXISTS District');
     await db.execute(
         "CREATE TABLE District( dcode TEXT, dname TEXT )");
     await db.execute(
         "CREATE TABLE Block( dcode TEXT, bcode TEXT, bname TEXT )");

  }

  Future close() async {
    var dbClient = await db;
    dbClient!.close();
  }

}