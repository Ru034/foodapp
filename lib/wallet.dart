import 'package:googleapis/appengine/v1.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:http/http.dart' as http;
import 'dart:async'; // for Stream
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'dart:convert';
import 'main.dart';
import 'main2.dart';
import 'SQL.dart';

class wallet extends StatelessWidget {
  const wallet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //返回一個 MaterialApp Widget，該Widget定義了應用程式的主題和首頁
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  //const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {


  late String shop_storeWallet;
  late String shop_contractAddress;
  late String shop_storePassword;
  Future<void> getShopdata() async {
    //取得shopdata最後一筆資料
    FoodSql shopdata = FoodSql("shopdata2", "storeWallet TEXT, contractAddress TEXT, storePassword TEXT");
    await shopdata.initializeDatabase();
    Map<String, dynamic>? lastShopData = await shopdata
        .querylastsql("shopdata2"); // 使用 Map<String, dynamic>? 接收返回值
    if (lastShopData != null) {
      // 檢查是否返回了資料
      shop_storeWallet = lastShopData['storeWallet'].toString();
      shop_contractAddress = lastShopData['contractAddress'].toString();
      shop_storePassword = lastShopData['storePassword'].toString();
    } else {
      // 處理沒有資料的情況，例如給予預設值或者處理其他邏輯
    }
    // print(await shopdata.querytsql("shopdata"));
    // print("000000000000000000000000000000000000000000000");
    // print("shop_storeWallet: $shop_storeWallet");
    // print("shop_contractAddress: $shop_contractAddress");
  }

  String storeName = ''; //店家名稱
  String storeAddress = ''; //店家地址
  String storePhone = ''; //店家電話
  String storeWallet = ''; //店家錢包
  String currentID = ''; //店家ID
  String storeTag = '';
  String latitudeAndLongitude = ''; //經緯度
  String menuLink = ''; //菜單連結
  String storeEmail = ''; //店家信箱
  Future<void> getacc(
      String shop_storeWallet, String shop_contractAddress) async {
    final Map<String, String> data = {
      'contractAddress': shop_contractAddress,
      'wallet': shop_storeWallet,
    };
    print(data);
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final body = Uri(queryParameters: data).query;
    final response = await http.post(
      Uri.parse('http://192.168.1.102:15000/contract/getStore'),
      headers: headers,
      body: body,
    );
    late String toll;
    if (response.statusCode == 200) {
      toll = response.body; // 將整個 API 回傳的內容直接賦值給 storeName
      Map<String, dynamic> jsonData = jsonDecode(toll);
      storeName = jsonData['storeName'] ?? '';
      storeAddress = jsonData['storeAddress'] ?? '';
      storePhone = jsonData['storePhone'] ?? '';
      storeWallet = jsonData['storeWallet'] ?? '';
      currentID = jsonData['currentID'] ?? '';
      storeTag = jsonData['storeTag'] ?? '';
      latitudeAndLongitude = jsonData['latitudeAndLongitude'] ?? '';
      menuLink = jsonData['menuLink'] ?? '';
      storeEmail = jsonData['storeEmail'] ?? '';
      //print(toll);
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  String money ="0"; //計算餘額
  Future<void> getmoney(String storeWallet) async {
    final Map<String, String> data = {
      'account': storeWallet,
    };
    print(data);
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final body = Uri(queryParameters: data).query;
    final response = await http.post(
      Uri.parse('http://192.168.1.102:15000/getBalance'),
      headers: headers,
      body: body,
    );
    late String money2;
    if (response.statusCode == 200) {
      money2 = response.body; // 將整個 API 回傳的內容直接賦值給 storeName
      Map<String, dynamic> jsonData = jsonDecode(money2);
      money = jsonData['balance'] ?? '';
      print("money: $money");
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }
  Future<void> _initializeData() async {
    await getShopdata();
    await getacc(shop_storeWallet, shop_contractAddress);
    await getmoney(storeWallet);
    setState(() {
      money;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
        children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(15),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(15),
                ),
                Text(
                  "錢包:",
                  style: TextStyle(
                    fontSize: 30, // 調整字體大小
                    //fontWeight: FontWeight.bold, // 加粗
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(5),
                ),
                Text(
                  storeWallet,
                  style: TextStyle(
                    fontSize: 15, // 調整字體大小
                    //fontWeight: FontWeight.bold, // 加粗
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(15),
                ),
              ],
            ),


            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(15),
                ),
                Text(
                  "餘額:",
                  style: TextStyle(
                    fontSize: 30, // 調整字體大小
                    //fontWeight: FontWeight.bold, // 加粗
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(5),
                ),

                Text(
                  //Todo 從API抓值
                  money,
                  style: TextStyle(
                    fontSize: 15, // 調整字體大小
                    //fontWeight: FontWeight.bold, // 加粗
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(5),
                ),
                Text(
                  "wei",
                  style: TextStyle(
                    fontSize: 30, // 調整字體大小
                    //fontWeight: FontWeight.bold, // 加粗
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(15),
                ),
              ],
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(15),
                ),

                Text(
                  "交易明細",
                  style: TextStyle(
                    fontSize: 40, // 調整字體大小
                    fontWeight: FontWeight.bold, // 加粗
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ));
  }
}
