import 'package:flutter/material.dart';



class sign_in extends StatelessWidget {
  const sign_in ({Key? key}) : super(key: key);

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
  //HomePage 的狀態類別，用於管理狀態變化
  TextEditingController _storeName   = TextEditingController(); //店家名稱
  TextEditingController _storeAddress  = TextEditingController(); //店家地址
  TextEditingController _storePhone  = TextEditingController(); //店家電話
  TextEditingController _storeWallet  = TextEditingController(); //店家錢包
  TextEditingController _storeTag = TextEditingController(); //店家標籤
  TextEditingController _latitudeAndLongitude  = TextEditingController(); //店家經緯度
  TextEditingController _menuLink  = TextEditingController(); //菜單連結

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        title: Text("Blofood"),
      ),
      */

        body: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    "店家資訊",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Store Name
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2, left: 20.0, bottom: 15),
                      child: Text(
                        "店名:",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Add spacing between text and input field
                    Expanded(
                      child: TextField(
                        controller: _storeName,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                // Address
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2, left: 20.0, bottom: 15),
                      child: Text(
                        "地址:",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Add spacing between text and input field
                    Expanded(
                      child: TextField(
                        controller: _storeAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                // Phone Number
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2, left: 20.0, bottom: 15),
                      child: Text(
                        "電話:",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Add spacing between text and input field
                    Expanded(
                      child: TextField(
                        controller: _storePhone,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                // Wallet
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2, left: 20.0, bottom: 15),
                      child: Text(
                        "錢包:",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Add spacing between text and input field
                    Expanded(
                      child: TextField(
                        controller: _storeWallet,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2, left: 20.0, bottom: 15),
                      child: Text(
                        "標籤:",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Add spacing between text and input field
                    Expanded(
                      child: TextField(
                        controller: _storeTag,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    print(_storeName);
                    print(_storeAddress);
                  },
                  child: Text("送出 "),
                ),
              ],
            ),
          ],
        ));
  }
}
