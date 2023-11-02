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
  late var database;
  _initializeDatabase() async {
      database = openDatabase(
      join(await getDatabasesPath(), 'foodsql.db'),

      onCreate: (db, version) {return db.execute('CREATE TABLE $table_name($createsql_value)');},
      version: 1,
    ) ;
  }
  FoodSql(String table_name,String createsql_value) {
    this.createsql_value = createsql_value;
    this.table_name = table_name;
    //print('CREATE TABLE $table_name($createsql_value)');
    _initializeDatabase();
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
