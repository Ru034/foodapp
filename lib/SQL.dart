import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//material  模板dog
//parameter 資料庫本體 doggie
//ex  資料庫-1 放大資料的 dogs
//final String ty; //資料
//final String va; //值

// void main(){
//
//   Car myCar = Car(chosenColor:'blue',startingNumberOfDoors:6);
//   print(myCar.colorOfCar);
//   print(myCar.numberOfDoors);
//
//   myCar.drive('Going to NewYork');
//
// }
class FoodSql {
  late String table_name;
  late String createsql_value;
  late Database database;


  Future<void> initializeDatabase() async { //初始化資料庫  並且創建資料庫
    database =await openDatabase(
      join(await getDatabasesPath(), 'foodsql.db'),
      onCreate: (db, version) {return db.execute('CREATE TABLE $table_name($createsql_value)');},
      version: 1,
    ) ;
  }
  FoodSql(this.table_name,this.createsql_value) ; //建構子



  Future<void> insertsql(String db,Map<String, dynamic> mapvalue) async { //插入資料
      await database.insert(
        db, // 确保表名正确
        mapvalue,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
  }
  Future<void> deletesql(String db,String deleteparameter,String deletevalute) async { //刪除資料
    print(deleteparameter) ;
    print(deletevalute) ;
    await database.delete(
      db, // 确保表名正确
      where: '$deleteparameter = ?',
      whereArgs: [deletevalute],
    );
  }

  dynamic querytsql(String db) async {   //查詢所有資料
    var maps = await database.query(db);
    return maps;
  }


}

/*
  int numberOfDoors = 0;
  late String colorOfCar;

  Car({required String chosenColor, required int startingNumberOfDoors}) {
    colorOfCar = chosenColor;
    numberOfDoors = startingNumberOfDoors;
  }

  void drive(String whereToGo) {
    print(whereToGo);
  }
*/
