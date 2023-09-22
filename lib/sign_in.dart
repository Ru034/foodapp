import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:http/http.dart' as http;
import 'dart:async'; // for Stream
import 'package:geocoding/geocoding.dart';





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
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = new http.Client();

  GoogleAuthClient(this._headers);

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
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
  TextEditingController _password = TextEditingController(); //密碼
  TextEditingController _storeAddress  = TextEditingController(); //店家地址
  TextEditingController _storePhone  = TextEditingController(); //店家電話
  TextEditingController _storeWallet  = TextEditingController(); //店家錢包
  TextEditingController _storeTag = TextEditingController(); //店家標籤
  TextEditingController _latitudeAndLongitude  = TextEditingController(); //店家經緯度
  TextEditingController _menuLink  = TextEditingController(); //菜單連結
  Map<String, double> _latitudeAndLongitude_no = {
    "latitude": 0.0,
    "longitude": 0.0,
  };

  Future<void> getCoordinates() async {
    String address = _storeAddress.text; // Get the address
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations != null && locations.length > 0) {
        Location location = locations.first;
        _latitudeAndLongitude_no["latitude"] = location.latitude;
        _latitudeAndLongitude_no["longitude"] = location.longitude;
        print('Latitude: ${location.latitude}, Longitude: ${location.longitude}');
        setState(() {
          _latitudeAndLongitude.text = "${_latitudeAndLongitude_no['latitude']} ${_latitudeAndLongitude_no['longitude']}";
        });
      } else {
        print('No location found for this address.');
      }
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  Future<void> _incrementCounter() async {
    final googleSignIn = signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();

    if (account != null) {
      final authHeaders = await account.authHeaders;

      if (authHeaders != null) {
        final authenticateClient = GoogleAuthClient(authHeaders);
        final driveApi = drive.DriveApi(authenticateClient);

        final folderMetadata = drive.File()
          ..name = "flutter_menu"
          ..mimeType = "application/vnd.google-apps.folder";

        final folder = await driveApi.files.create(folderMetadata);

        if (folder.id != null) {
          // Get the temp directory of the app
          final Directory tempDir = await getTemporaryDirectory();

          // Load the CSV file from assets
          final ByteData data = await rootBundle.load('assets/菜單.csv');
          final List<int> bytes = data.buffer.asUint8List();

          // Create a new file and write the contents
/*
          final File newCsvFile = File('${tempDir.path}/new_data.csv');
          await newCsvFile.writeAsBytes(bytes);
          final csvFileMetadata = drive.File()
            ..name = "new_data.csv"
            ..parents = [folder.id!];

          final drive.Media fileContent = drive.Media(newCsvFile.openRead(), newCsvFile.lengthSync());
          await driveApi.files.create(csvFileMetadata, uploadMedia: fileContent);


 */
          final permission = drive.Permission()
            ..type = "anyone"
            ..role = "reader";

          await driveApi.permissions.create(permission, folder.id!);

          final folderUrl = "https://drive.google.com/drive/folders/${folder.id}";
          _menuLink.text = folder.id!;
        }
      }
    }
  }


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
                        "密碼:",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Add spacing between text and input field
                    Expanded(
                      child: TextField(
                        controller: _password,
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
                    ElevatedButton(
                      onPressed: () async {
                        //todo 使用API抓
                        //_storeWallet
                      },
                      child: Text("取得錢包"),
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
                          labelText: "每一項請用空格隔開",
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
                        "google連接:",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    SizedBox(width: 10), // Add spacing between text and input field
                    Expanded(
                      child:
                      ElevatedButton(
                        onPressed: () async {
                          _incrementCounter();
                        },
                        child: Text("連接雲端帳號"),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    await getCoordinates();
                    print(_storeName.text); //店家名稱
                    print(_password.text); //店家密碼
                    print(_menuLink.text); //菜單連結
                    print(_storePhone.text); //店家電話
                    print(_storeWallet.text); //店家錢包
                    print(_storeTag.text); //店家標籤
                    print(_latitudeAndLongitude.text);  //店家經緯度
                    print(_menuLink.text); //菜單連結
                  },
                  child: Text("送出 "),
                ),
              ],
            ),
          ],
        ));
  }
}
