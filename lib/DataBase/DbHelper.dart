import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../Resources/Strings.dart';

class DbHelper {
  Database? myDb;

  Future<Database?> get db async {
    if (myDb != null) return myDb;
    myDb = await initDb();
    return myDb;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "inspection.db");
    var theDb = await openDatabase(path,
        version: 1, onCreate: onCreate, onUpgrade: _onUpgrade);
    return theDb;
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    if (oldVersion < newVersion) {
      // you can execute drop table and create table
      dropAllTable(db);
      onCreate(db, newVersion);
    }
  }

  void onCreate(Database db, int version) async {
    dropAllTable(db);
    await db.execute("CREATE TABLE $table_District ( dcode TEXT, dname TEXT )");
    await db.execute("CREATE TABLE $table_Block ( dcode TEXT, bcode TEXT, bname TEXT )");
    await db.execute("CREATE TABLE $table_Village ( dcode TEXT, bcode TEXT, pvcode TEXT, pvname TEXT )");
    await db.execute("CREATE TABLE $table_FinancialYear ( fin_year TEXT )");
    await db.execute("CREATE TABLE $table_Status ( status_id TEXT , status TEXT )");
    await db.execute("CREATE TABLE $table_OtherCategory ( other_work_category_id TEXT , other_work_category_name TEXT )");
    await db.execute("CREATE TABLE $table_TownList ( dcode TEXT , townpanchayat_id TEXT , townpanchayat_name TEXT )");
    await db.execute("CREATE TABLE $table_Municipality ( dcode TEXT , municipality_id TEXT , municipality_name TEXT )");
    await db.execute("CREATE TABLE $table_Corporation ( dcode TEXT , corporation_id TEXT , corporation_name TEXT )");
    await db.execute("CREATE TABLE $table_WorkStages ( work_group_id TEXT , work_type_id TEXT , work_stage_order TEXT , work_stage_code TEXT , work_stage_name TEXT )");
    await db.execute("CREATE TABLE $table_AtrWorkList ( flag TEXT DEFAULT 'ATR', rural_urban TEXT , dcode TEXT , bcode TEXT, pvcode TEXT, work_id TEXT, work_name TEXT, inspection_id TEXT, inspection_date TEXT, status_id TEXT, status TEXT, description TEXT, inspection_by_officer TEXT, inspection_by_officer_designation TEXT, work_type_name TEXT, dname TEXT, bname TEXT, pvname TEXT, action_status TEXT, action_taken_id TEXT, reported_by TEXT, town_type TEXT, tpcode TEXT, muncode TEXT, corcode TEXT, townpanchayat_name TEXT, municipality_name TEXT, corporation_name TEXT )");
    await db.execute("CREATE TABLE $table_RdprWorkList ( rural_urban TEXT ,town_type TEXT , dcode TEXT, dname TEXT , bcode TEXT, bname TEXT, pvcode TEXT, pvname TEXT, hab_code TEXT, scheme_group_id TEXT, scheme_id TEXT, scheme_name TEXT, work_group_id TEXT, work_type_id TEXT, fin_year TEXT, work_id TEXT, work_name TEXT, as_value TEXT, ts_value TEXT, current_stage_of_work TEXT, is_high_value TEXT, stage_name TEXT, as_date TEXT, ts_date TEXT, work_order_date TEXT, work_type_name TEXT, tpcode TEXT, townpanchayat_name TEXT, muncode TEXT, municipality_name TEXT, corcode TEXT, corporation_name TEXT, upd_date TEXT )");
    await db.execute("CREATE TABLE $table_SchemeList ( rural_urban TEXT , scheme_id TEXT, scheme_name TEXT )");
    await db.execute("CREATE TABLE $table_save_work_details ( flag TEXT ,rural_urban TEXT , dcode TEXT , bcode TEXT, pvcode TEXT, work_id TEXT, scheme_id TEXT,work_status_id TEXT, work_status TEXT, work_stage_id TEXT, work_stage TEXT,current_stage_of_work TEXT, scheme_group_id TEXT, work_group_id TEXT, work_type_id TEXT, fin_year TEXT, work_name TEXT, inspection_id TEXT, description TEXT, town_type TEXT, tpcode TEXT, muncode TEXT, corcode TEXT )");
    await db.execute("CREATE TABLE $table_save_images ( flag TEXT ,work_id TEXT, inspection_id TEXT, image_description TEXT, latitude TEXT, longitude TEXT, serial_no TEXT, rural_urban TEXT, image_path TEXT, image TEXT, dcode TEXT , bcode TEXT, pvcode TEXT, tpcode TEXT, muncode TEXT, corcode TEXT )");
  }

  Future close() async {
    var dbClient = await db;
    dbClient!.close();
  }

  void delete_table_District() {
    // you can execute drop table and create table
    myDb?.execute("DELETE FROM $table_District");
  }

  void delete_table_Block() {
    // you can execute drop table and create table
    myDb?.execute("DELETE FROM $table_Block");
  }

  void delete_table_Village() {
    // you can execute drop table and create table
    myDb?.execute("DELETE FROM $table_Village");
  }

  void delete_table_FinancialYear() {
    // you can execute drop table and create table
    myDb?.execute("DELETE FROM $table_FinancialYear");
  }

  void delete_table_Status() {
    // you can execute drop table and create table
    myDb?.execute("DELETE FROM $table_Status");
  }

  void delete_table_OtherCategory() {
    // you can execute drop table and create table
    myDb?.execute("DELETE FROM $table_OtherCategory");
  }

  void delete_table_TownList() {
    // you can execute drop table and create table
    myDb?.execute("DELETE FROM $table_TownList");
  }

  void delete_table_Municipality() {
    // you can execute drop table and create table
    myDb?.execute("DELETE FROM $table_Municipality");
  }

  void delete_table_Corporation() {
    // you can execute drop table and create table
    myDb?.execute("DELETE FROM $table_Corporation");
  }

  void delete_table_WorkStages() {
    // you can execute drop table and create table
    myDb?.execute("DELETE FROM $table_WorkStages");
  }

  void delete_table_AtrWorkList(String type) {
    type == "ALL"
        ? myDb?.execute("DELETE FROM $table_AtrWorkList")
        :
        // you can execute drop table and create table
        myDb?.execute(
            "DELETE FROM $table_AtrWorkList where rural_urban = '$type'");
  }

  void delete_table_RdprWorkList(String type) {
    type == "ALL"
        ? myDb?.execute("DELETE FROM $table_RdprWorkList")
        :
        // you can execute drop table and create table
        myDb?.execute(
            "DELETE FROM $table_RdprWorkList where rural_urban = '$type'");
  }

  void delete_table_SchemeList(String type) {
    type == "ALL"
        ? myDb?.execute("DELETE FROM $table_SchemeList")
        :
        // you can execute drop table and create table
        myDb?.execute(
            "DELETE FROM $table_SchemeList where rural_urban = '$type'");
  }

  void delete_table_save_work_details() {
    // you can execute drop table and create table
    myDb?.execute("DELETE FROM $table_save_work_details");
  }

  void delete_table_save_images() {
    // you can execute drop table and create table
    myDb?.execute("DELETE FROM $table_save_images");
  }

  Future<void> deleteAll() async {
    delete_table_District();
    delete_table_Block();
    delete_table_Village();
    delete_table_FinancialYear();
    delete_table_Status();
    delete_table_OtherCategory();
    delete_table_TownList();
    delete_table_Municipality();
    delete_table_Corporation();
    delete_table_WorkStages();
    delete_table_AtrWorkList("ALL");
    delete_table_RdprWorkList("ALL");
    delete_table_SchemeList("ALL");
    delete_table_save_work_details();
    delete_table_save_images();
  }

  void dropAllTable(Database db) {
    // you can execute drop table and create table
    db.execute('DROP TABLE IF EXISTS $table_District');
    db.execute('DROP TABLE IF EXISTS $table_Block');
    db.execute('DROP TABLE IF EXISTS $table_Village');
    db.execute('DROP TABLE IF EXISTS $table_FinancialYear');
    db.execute('DROP TABLE IF EXISTS $table_Status');
    db.execute('DROP TABLE IF EXISTS $table_OtherCategory');
    db.execute('DROP TABLE IF EXISTS $table_TownList');
    db.execute('DROP TABLE IF EXISTS $table_Municipality');
    db.execute('DROP TABLE IF EXISTS $table_Corporation');
    db.execute('DROP TABLE IF EXISTS $table_WorkStages');
    db.execute('DROP TABLE IF EXISTS $table_AtrWorkList');
    db.execute('DROP TABLE IF EXISTS $table_RdprWorkList');
    db.execute('DROP TABLE IF EXISTS $table_SchemeList');
    db.execute('DROP TABLE IF EXISTS $table_save_work_details');
    db.execute('DROP TABLE IF EXISTS $table_save_images');
  }
}
