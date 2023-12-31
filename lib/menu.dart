import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:googleapis/drive/v3.dart' show Media;
import 'dart:convert'; // 確保引入 dart:convert 庫

import 'package:file_picker/file_picker.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert'; // for utf8
import 'dart:async'; // for Stream
import 'SQL.dart';

/*
app:foodapp
package:com.example.foodapp
Launcher:com.example.foodapp.MainActivity
SHA1: 83:4D:3C:8A:4C:BB:10:13:48:81:E5:F3:EA:8D:E9:19:1B:0F:CC:B1
 */
//增加從雲端抓資料與輸出資料
class GoogleAuthClient extends http.BaseClient {     //創建一個 GoogleAuthClient，這是一個用於進行 Google API 請求的客戶端，使用先前獲取的身份驗證標頭進行身份驗證。
  final Map<String, String> _headers;
  final http.Client _client = new http.Client();
  GoogleAuthClient(this._headers);
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
class menu extends StatelessWidget {
  const menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //返回一個 MaterialApp Widget，該Widget定義了應用程式的主題和首頁
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  //HomePage 的狀態類別，用於管理狀態變化
  List<List<dynamic>> _data = [];

  get auth2 => null;

  Future<void> saveCsvToNewDirectory() async {
    try {
      final String csvContent = const ListToCsvConverter().convert(_data);

      final Directory newDirectory =
      Directory('/data/user/0/com.example.foodapp/new');
      final file = File('${newDirectory.path}/new_data.csv');

      // Write the CSV content to the new directory
      await file.writeAsString(csvContent);

      print('CSV data saved to new directory: ${file.path}');
    } catch (e) {
      print('Error saving CSV data: $e');
    }
  }
  Future<String> loadAsset() async { //讀取csv檔案
    return await rootBundle.loadString('assets/file.csv');
  }
  @override
  void initState() {
    //初始化狀態，然後調用 _loadCSV() 方法
    super.initState();
    _loadCSV();
  }
  String? _imagePath;
  void deleteDataAtIndex(int index) {//刪除資料
    setState(() {
      _data.removeAt(index);
    });
  }
  void addNewDataAtIndex(//新增資料
      String listData, String newOption, String newPrice, int ord, int index) {
    List<dynamic> newData = [ord, "", "", listData, newOption, newPrice, ""];
    setState(() {
      _data.insert(index, newData);
    });
  }

  Future<void> saveCsvToLocalDirectory() async {//儲存資料 本地
    try {
      final String csvContent = const ListToCsvConverter().convert(_data);
      final directory = Directory(
          '/data/user/0/com.example.foodapp/new'); // Update the path to your desired directory
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final file = File('${directory.path}/new_data.csv');

      // Write the CSV content to the new directory
    await file.writeAsString(csvContent);

    print('CSV data saved to new directory: ${file.path}');
  } catch (e) {
  print('Error saving CSV data: $e');
  }
  }

  Future<void> _pickImage(int index) async { //選擇圖片
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery, // Choose from the gallery
    );

    if (pickedImage != null) {
      final imagePath = pickedImage.path;

      try {
        final newImagePath =
            '/data/user/0/com.example.foodapp/new/image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File newImageFile = await File(imagePath).copy(newImagePath);
        setState(() {
          _imagePath = newImagePath;
          _data[index][6] =
              newImagePath; // Update _data[index][6] to include the new image path
        });
      } catch (e) {
        print('Error copying image: $e');
      }
    }
  }

  Future<void> createNewDirectory() async { //創建新資料夾
    final Directory newDirectory =
    Directory('/data/user/0/com.example.foodapp/new');
    if (!await newDirectory.exists()) {
      await newDirectory.create(recursive: true);
    }
  }

  Future<void> movePhotosToNewDirectory() async { //移動圖片到新資料夾
    final Directory cacheDirectory = await getTemporaryDirectory();
    final Directory newDirectory =
    Directory('/data/user/0/com.example.foodapp/new');

    for (final file in await cacheDirectory.list().toList()) {
      if (file is File) {
        final newFilePath =
            '${newDirectory.path}/${file.uri.pathSegments.last}';
        await file.copy(newFilePath);
      }
    }
  }
  late String menunewlink;

  Future<void> _incrementCounter() async { //增加計數器  用於測試
    final googleSignIn =
    signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();
    print("User account $account");

    if (account != null) {
      final authHeaders = await account.authHeaders; //從登錄的帳戶中獲取身份驗證標頭（auth headers）。這些標頭將用於進行 Google Drive API 的身份驗證。
      if (authHeaders != null) {
        //檢查身份驗證標頭是否成功獲取。如果 authHeaders 不是 null，表示已經成功獲取身份驗證標頭。
        final authenticateClient = GoogleAuthClient(authHeaders); //創建一個 GoogleAuthClient，這是一個用於進行 Google API 請求的客戶端，使用先前獲取的身份驗證標頭進行身份驗證。
        final driveApi = drive.DriveApi(authenticateClient); //創建一個 Google Drive API 客戶端，使用 GoogleAuthClient 進行身份驗證。

        // 在 Google Drive 上建立 "flutter_menu" 資料夾
        final folderMetadata = drive.File() //創建一個表示 Google Drive 上資料夾的元數據（metadata）。這個資料夾的名稱是 "flutter_menu"，並設定了 MIME 類型為 Google Drive 資料夾。
          ..name = "flutter_menu"
          ..mimeType = "application/vnd.google-apps.folder";

        final folder = await driveApi.files.create(folderMetadata); //使用 Google Drive API 創建一個名為 "flutter_menu" 的資料夾，並獲取創建後的資料夾對象。
        if (folder.id != null) {
          //檢查創建資料夾操作是否成功，如果成功，則繼續執行後續操作。
          // 指定本地文件夾路徑
          final localFolderPath = '/data/user/0/com.example.foodapp/new'; //定義了本地文件夾的路徑，這個文件夾中的內容將被上傳到 Google Drive 的
          // 上傳文件夾中的內容到 "flutter_menu" 資料夾
          await _uploadFolderContents(driveApi, localFolderPath, parentFolderId: folder.id); //調用 _uploadFolderContents 函數，該函數似乎用於上傳本地文件夾的內容到 Google Drive 的資料夾中，並將 Google Drive 資料夾的ID作為參數傳遞。

          final permission = drive.Permission()
            ..type = "anyone"
            ..role = "reader";
          await driveApi.permissions.create(permission, folder.id!);
          // 获取文件夹的 URL

          final folderUrl = "https://drive.google.com/drive/folders/${folder.id}";
          menunewlink = folder.id!;
          print("menunewlink: $menunewlink");

          print("Folder URL: $folderUrl");

        }
      } else {
        print("Auth headers are null");
      }
    } else {
      print("Account is null");
    }
  }

  Future<void> _uploadFolderContents( //上傳文件夾內容
      drive.DriveApi driveApi, String localFolderPath,
      {String? parentFolderId}) async {
    final dir = Directory(localFolderPath);

    if (dir.existsSync()) {
      for (final fileSystemEntity in dir.listSync()) {
        if (fileSystemEntity is File) {
          // 上傳文件
          final driveFile = drive.File();
          driveFile.name = fileSystemEntity.uri.pathSegments.last;
          if (parentFolderId != null) {
            // Check if parentFolderId is not null
            driveFile.parents = [parentFolderId];
          }
          final media =
          Media(fileSystemEntity.openRead(), fileSystemEntity.lengthSync());
          final result =
          await driveApi.files.create(driveFile, uploadMedia: media);
          print("Uploaded ${driveFile.name}: ${result.toJson()}");

        } else if (fileSystemEntity is Directory) {
          // 上傳子文件夾
          final driveFolder = drive.File();
          driveFolder.name = fileSystemEntity.uri.pathSegments.last;

          if (parentFolderId != null) {
            // Check if parentFolderId is not null
            driveFolder.parents = [parentFolderId];
          }

          driveFolder.mimeType = 'application/vnd.google-apps.folder';

          final result = await driveApi.files.create(driveFolder);
          print("Created folder ${driveFolder.name}: ${result.toJson()}");

          // 遞迴上傳子文件夾的內容
          await _uploadFolderContents(driveApi, fileSystemEntity.path,
              parentFolderId: result.id);
        }
      }
    }
  }
  late String shop_storeWallet ;
  late String shop_contractAddress ;
  late String shop_storePassword ;
  Future<void> getShopdata() async {//取得shopdata最後一筆資料
    FoodSql shopdata = FoodSql("shopdata2", "storeWallet TEXT, contractAddress TEXT, storePassword TEXT");
    await shopdata.initializeDatabase();

    Map<String, dynamic>? lastShopData = await shopdata.querylastsql("shopdata2"); // 使用 Map<String, dynamic>? 接收返回值

    if (lastShopData != null) { // 檢查是否返回了資料
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
  String storeName=''   ; //店家名稱
  String storeAddress=''; //店家地址
  String storePhone=''; //店家電話
  String storeWallet=''; //店家錢包
  String currentID=''; //店家ID
  String storeTag='';
  String latitudeAndLongitude=''; //經緯度
  String menuLink=''; //菜單連結
  String storeEmail=''; //店家信箱
  /*
  menuUpdate 更新菜單
  getMenuVersion 查看菜單版本號
  getMenu 用菜單版本號獲取對應的菜單
   */


  Future<void> getacc(String shop_storeWallet, String shop_contractAddress) async {
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
  late String menuVersion  ; //取得menu版本
  Future<void> menuid(String shop_storeWallet, String shop_contractAddress) async {
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
      Uri.parse('http://192.168.1.102:15000/contract/getMenuVersion'),
      headers: headers,
      body: body,
    );
    late String menuid;
    if (response.statusCode == 200) {
      menuid = response.body; // 將整個 API 回傳的內容直接賦值給 storeName
      Map<String, dynamic> jsonData = jsonDecode(menuid);
      menuVersion = jsonData['menuVersion'] ?? '';
      print("menuVersion: $menuVersion");
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }


  Future<void> getmenu(String shop_storeWallet, String shop_contractAddress , String menuVersion) async {
    final Map<String, String> data = {
      'contractAddress': shop_contractAddress,
      'wallet': shop_storeWallet,
      'menuVersion': menuVersion,
    };
    print(data);
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final body = Uri(queryParameters: data).query;
    final response = await http.post(
      Uri.parse('http://192.168.1.102:15000/contract/getMenu'),
      headers: headers,
      body: body,
    );
    late String menulink;
    if (response.statusCode == 200) {
      menulink = response.body; // 將整個 API 回傳的內容直接賦值給 storeName
      Map<String, dynamic> jsonData = jsonDecode(menulink);
      menuLink = jsonData['menuLink'] ?? '';
      print("menuLink: $menuLink");
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }
  //menuUpdate(shop_storeWallet, shop_contractAddress, "0", menunewlink);
  Future<void> menuUpdate(String shop_storeWallet, String shop_contractAddress , String storePassword,String updateMenuLink) async {
    final Map<String, String> data = {
      'contractAddress': shop_contractAddress,
      'storeWallet': shop_storeWallet,
      'storePassword': storePassword,
      'updateMenuLink': updateMenuLink,
    };
    print(data);
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final body = Uri(queryParameters: data).query;
    final response = await http.post(
      Uri.parse('http://192.168.1.102:15000/contract/menuUpdate'),
      headers: headers,
      body: body,
    );
  }



  Future<void> _download() async { //下載資料
    await getShopdata();
    await getacc(shop_storeWallet, shop_contractAddress);
    await menuid(shop_storeWallet, shop_contractAddress); //menuVersion
    await getmenu(shop_storeWallet, shop_contractAddress, menuVersion); //menuLink
    print("1111111111111111");
    print("menuVersion: $menuVersion");

    final googleSignIn =
    signIn.GoogleSignIn.standard(scopes: [drive.DriveApi.driveScope]);
    final signIn.GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account != null) {
      final authHeaders = await account.authHeaders;
      if (authHeaders != null) {
        final authenticateClient = GoogleAuthClient(authHeaders);
        final driveApi = drive.DriveApi(authenticateClient);

        final googleDriveFolderId =menuLink;
        //1cOKclriMA8y4dnvbqgRr3szq8NZUiYEX
        final localFolderPath = '/data/user/0/com.example.foodapp/new';
        final directory = Directory(localFolderPath);
        if (directory.existsSync()) {
          directory.deleteSync(recursive: true);
        }
        directory.createSync(recursive: true);
        final fileList =
        await driveApi.files.list(q: "'$googleDriveFolderId' in parents");
        for (final file in fileList.files!) {
          final drive.Media fileData = await driveApi.files.get(file.id!,
              downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
          final Stream<List<int>> stream = fileData.stream;
          final localFile = File('$localFolderPath/${file.name}');
          final IOSink sink = localFile.openWrite();
          await for (final chunk in stream) {
            sink.add(chunk);
          }
          await sink.close();
        }
      } else {
        print("Auth headers are null");
      }
    } else {
      print("Account is null");
    }
  }

  showAlertDialog(BuildContext context, String listData, int ord, int index) {
    TextEditingController textFieldController1 = TextEditingController();
    TextEditingController textFieldController2 = TextEditingController();
    AlertDialog dialog = AlertDialog(
      //title: Text("AlertDialog component"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(listData),
          TextField(
            controller: textFieldController1,
            decoration: InputDecoration(labelText: "填寫新選項"),
          ),
          TextField(
            controller: textFieldController2,
            decoration: InputDecoration(labelText: "填寫價格"),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          child: Text("新增"),
          onPressed: () {
            // Access input values using textFieldController1.text and textFieldController2.text
            String newOption = textFieldController1.text;
            String newPrice = textFieldController2.text;
            addNewDataAtIndex(listData, newOption, newPrice, ord, index);
            //Navigator.pop(context);
          },
        ),
        /*
        ElevatedButton(
          child: Text("取消"),
          onPressed: () {
            Navigator.pop();
          },
        ),

         */
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  showAlertDialog2(BuildContext context, String listData, int ord, int index) {
    TextEditingController textFieldController1 = TextEditingController();
    TextEditingController textFieldController2 = TextEditingController();
    TextEditingController textFieldController3 = TextEditingController();
    AlertDialog dialog = AlertDialog(
      //title: Text("AlertDialog component"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: textFieldController1,
            decoration: InputDecoration(labelText: "填寫新品項"),
          ),
          TextField(
            controller: textFieldController2,
            decoration: InputDecoration(labelText: "填寫新選項"),
          ),
          TextField(
            controller: textFieldController3,
            decoration: InputDecoration(labelText: "填寫價格"),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          child: Text("新增"),
          onPressed: () {
            // Access input values using textFieldController1.text and textFieldController2.text
            String newshop = textFieldController1.text;
            String newOption = textFieldController2.text;
            String newPrice = textFieldController3.text;
            addNewDataAtIndex(newshop, newOption, newPrice, ord, index);
            //Navigator.pop(context);
          },
        ),
        /*
        ElevatedButton(
          child: Text("取消"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
         */
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  showAlertDialog3(BuildContext context, String listData, int ord, int index) {
    TextEditingController textFieldController1 = TextEditingController();
    AlertDialog dialog = AlertDialog(
      //title: Text("AlertDialog component"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(listData),
          TextField(
            controller: textFieldController1,
            decoration: InputDecoration(labelText: "填寫新選項"),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          child: Text("新增"),
          onPressed: () {
            // Access input values using textFieldController1.text and textFieldController2.text
            String newOption = textFieldController1.text;
            addNewDataAtIndex(listData, newOption, '', ord, index);
            //Navigator.pop(context);
          },
        ),
        /*
        ElevatedButton(
          child: Text("取消"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

         */
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }



  Future<void> _loadCSV() async {
    await _download();
    try {
      final File file = File('/data/user/0/com.example.foodapp/new/new_data.csv');

      // Check if the file exists in the app's data directory
      if (await file.exists()) {
        final String rawData = await file.readAsString();
        final List<List<dynamic>> listData =
        const CsvToListConverter().convert(rawData);

        setState(() {
          _data = listData;
        });
      }
      else {
        // If the file doesn't exist in the app's data directory, copy it from assets
        final rawData = await rootBundle.loadString("assets/new_data.csv");
        List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
        setState(() {
          _data = listData;
        });
      }
    } catch (e) {
      print('Error loading CSV file: $e');
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
              crossAxisAlignment: CrossAxisAlignment.start, // 將子元素靠左對齊
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await getShopdata();
                    await getacc(shop_storeWallet, shop_contractAddress);//取得店家資料
                    await menuid(shop_storeWallet, shop_contractAddress); //menuVersion
                    await getmenu(shop_storeWallet, shop_contractAddress, menuVersion); //menuLink
                    /*
                    FoodSql shopdata = FoodSql("shopdata","storeWallet TEXT, contractAddress TEXT"); //建立資料庫
                    await shopdata.initializeDatabase(); //初始化資料庫 並且創建資料庫
                    print(await shopdata.querytsql("shopdata")); //查詢所有資料

                     */
                  },
                  child: Text("測試"),
                ),
                const Padding(
                  padding: EdgeInsets.all(15),
                ),
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    "店家菜單",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 15, left: 30.0, bottom: 15),
                  //const EdgeInsets.only(left: 40.0)
                  child: Text(
                    "單點",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                for (int index = 0; index < _data.length; index++)
                  if (_data[index][0] == 1)
                    ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 0.0),
                              ),
                              Expanded(
                                //新增圖片
                                child: Row(
                                  children: [
                                    if (index == 0)
                                      if (_data[index][6] == "" && index == 0)
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () async {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("上傳圖片"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () async {
                                                          Navigator.pop(
                                                              context); // Close the dialog
                                                          final pickedFile =
                                                          await ImagePicker()
                                                              .getImage(
                                                            source:
                                                            ImageSource.camera,
                                                          );

                                                          if (pickedFile != null) {
                                                            final imagePath =
                                                                pickedFile.path;
                                                            final newImagePath =
                                                                '/data/user/0/com.example.foodapp/new/image_${DateTime.now().millisecondsSinceEpoch}.jpg';

                                                            try {
                                                              final File
                                                              newImageFile =
                                                              await File(
                                                                  imagePath)
                                                                  .copy(
                                                                  newImagePath);
                                                              setState(() {
                                                                _data[index][6] =
                                                                    newImagePath;
                                                              });
                                                            } catch (e) {
                                                              print(
                                                                  'Error copying image: $e');
                                                            }
                                                          }
                                                        },
                                                        child: Text("相機"),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          _pickImage(index);
                                                          //todo
                                                          Navigator.pop(
                                                              context); // 關閉對話框
                                                        },
                                                        child: Text("從相簿選擇照片"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Icon(
                                              Icons.photo_camera,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                    if (_data[index][6] != "" && index == 0)
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            Image.file(
                                              File(_data[index][6]),
                                              width: 100,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _data[index][6] =
                                                    ""; // Remove the image path
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.red,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (index > 0)
                                      if (_data[index][3] != _data[index - 1][3] &&
                                          index > 0)
                                        if (_data[index][6] == "" && index > 0)
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () async {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text("上傳圖片"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () async {
                                                            Navigator.pop(
                                                                context); // Close the dialog
                                                            final pickedFile =
                                                            await ImagePicker()
                                                                .getImage(
                                                              source: ImageSource
                                                                  .camera,
                                                            );
                                                            if (pickedFile !=
                                                                null) {
                                                              final imagePath =
                                                                  pickedFile.path;
                                                              final newImagePath =
                                                                  '/data/user/0/com.example.foodapp/new/image_${DateTime.now().millisecondsSinceEpoch}.jpg';

                                                              try {
                                                                final File
                                                                newImageFile =
                                                                await File(
                                                                    imagePath)
                                                                    .copy(
                                                                    newImagePath);
                                                                setState(() {
                                                                  _data[index][6] =
                                                                      newImagePath;
                                                                });
                                                              } catch (e) {
                                                                print(
                                                                    'Error copying image: $e');
                                                              }
                                                            }
                                                          },
                                                          child: Text("相機"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            //todo 2
                                                            _pickImage(index);

                                                            Navigator.pop(
                                                                context); // 關閉對話框
                                                          },
                                                          child: Text("從相簿選擇照片"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Icon(
                                                Icons.photo_camera,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                    if (_data[index][6] != "" && index > 0)
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            Image.file(
                                              File(_data[index][6]),
                                              width: 100,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _data[index][6] =
                                                    ""; // Remove the image path
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.red,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                  ],
                                ),
                              ),
                              Expanded(
                                //顯示第一欄  餐點名稱
                                child: Row(
                                  children: [
                                    if (index == 0)
                                      Text(_data[index][3].toString()),
                                    if (index > 0)
                                      if (_data[index][3] != _data[index - 1][3])
                                        Text(_data[index][3].toString()),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(_data[index][4].toString()),
                                    if (_data.length - 1 > index)
                                      if (_data[index][3] != _data[index + 1][3])
                                        TextButton(
                                          onPressed: () {
                                            showAlertDialog(
                                                context,
                                                _data[index][3].toString(),
                                                1,
                                                index + 1);
                                          },
                                          child: const Icon(
                                              Icons.add_circle_outline_sharp,
                                              color: Colors.blue),
                                        ),
                                    if (_data.length - 1 == index)
                                      TextButton(
                                        onPressed: () {
                                          showAlertDialog(
                                              context,
                                              _data[index][3].toString(),
                                              1,
                                              index + 1);
                                        },
                                        child: const Icon(
                                            Icons.add_circle_outline_sharp,
                                            color: Colors.blue),
                                      ),
                                  ],
                                ),
                              ),
                              Text(_data[index][5].toString()),
                              TextButton(
                                onPressed: () {
                                  deleteDataAtIndex(index);
                                },
                                child: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(
                    onPressed: () {
                      int foundindex;
                      for (foundindex = 0; foundindex < _data.length && _data[foundindex][0] == 1; foundindex++) {
                        foundindex++;
                      }
                      showAlertDialog2(context, _data[foundindex][3].toString(), 1,
                          foundindex - 1);
                    },
                    child: const Icon(Icons.add_box_outlined, color: Colors.blue),
                  ),
                ]),
                const Padding(
                  padding: EdgeInsets.only(left: 30.0),
                  //const EdgeInsets.only(left: 40.0)
                  child: Text(
                    "套餐",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                for (int index = 0; index < _data.length; index++)
                  if (_data[index][0] == 2)
                    ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 30.0),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    if (index == 0)
                                      Text(_data[index][3].toString()),
                                    if (index > 0)
                                      if (_data[index][3] != _data[index - 1][3])
                                        Text(_data[index][3].toString()),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(_data[index][4].toString()),
                                    if (_data.length - 1 > index)
                                      if (_data[index][3] != _data[index + 1][3])
                                        TextButton(
                                          onPressed: () {
                                            showAlertDialog3(
                                                context,
                                                _data[index][3].toString(),
                                                2,
                                                index + 1);
                                          },
                                          child: const Icon(
                                              Icons.add_circle_outline_sharp,
                                              color: Colors.blue),
                                        ),
                                    if (_data.length - 1 == index)
                                      TextButton(
                                        onPressed: () {
                                          showAlertDialog3(
                                              context,
                                              _data[index][3].toString(),
                                              2,
                                              index + 1);
                                        },
                                        child: const Icon(
                                            Icons.add_circle_outline_sharp,
                                            color: Colors.blue),
                                      ),
                                  ],
                                ),
                              ),
                              Text(_data[index][5].toString()),
                              TextButton(
                                onPressed: () {
                                  deleteDataAtIndex(index);
                                },
                                child: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(
                    onPressed: () {
                      int foundindex;
                      for (foundindex = 0;
                      foundindex < _data.length && _data[foundindex][0] == 2 ||
                          foundindex < _data.length &&
                              _data[foundindex][0] == 1;
                      foundindex++) {
                        foundindex++;
                      }
                      showAlertDialog2(context, _data[foundindex][3].toString(), 2,
                          foundindex - 1);
                    },
                    child: const Icon(Icons.add_box_outlined, color: Colors.blue),
                  ),
                ]),
                const Padding(
                  padding: EdgeInsets.only(left: 30.0),
                  //const EdgeInsets.only(left: 40.0)
                  child: Text(
                    "套餐選項",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                for (int index = 0; index < _data.length; index++)
                  if (_data[index][0] == 3)
                    ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 30.0),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    if (index == 0)
                                      Text(_data[index][3].toString()),
                                    if (index > 0)
                                      if (_data[index][3] != _data[index - 1][3])
                                        Text(_data[index][3].toString()),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(_data[index][4].toString()),
                                    if (_data.length - 2 > index)
                                      if (_data[index][3] != _data[index + 1][3])
                                        TextButton(
                                          onPressed: () {
                                            showAlertDialog(
                                                context,
                                                _data[index][3].toString(),
                                                3,
                                                index + 1);
                                          },
                                          child: const Icon(
                                              Icons.add_circle_outline_sharp,
                                              color: Colors.blue),
                                        ),
                                    if (_data.length - 1 == index)
                                      TextButton(
                                        onPressed: () {
                                          showAlertDialog(
                                              context,
                                              _data[index][3].toString(),
                                              3,
                                              index + 1);
                                        },
                                        child: const Icon(
                                            Icons.add_circle_outline_sharp,
                                            color: Colors.blue),
                                      ),
                                  ],
                                ),
                              ),
                              Text(_data[index][5].toString()),
                              TextButton(
                                onPressed: () {
                                  deleteDataAtIndex(index);
                                },
                                child: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(
                    onPressed: () {
                      int foundindex = _data.length - 1;
                      //for (foundindex = 0; foundindex < _data.length && _data[foundindex][0] == 1; foundindex++){foundindex++;}
                      showAlertDialog2(context, _data[foundindex][3].toString(), 3,
                          foundindex + 1);
                    },
                    child: const Icon(Icons.add_box_outlined, color: Colors.blue),
                  ),
                ]),
                Column(
                  children: [
                    const Padding(padding: EdgeInsets.all(15)),
                    Container(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: 75,
                        width: 250,
                        child: FilledButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.all(16.0),
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          onPressed: () async {
                            await createNewDirectory(); // 創建新資料夾
                            await movePhotosToNewDirectory(); // 將圖片移動到新資料夾
                            await saveCsvToNewDirectory();// 將csv檔案移動到新資料夾
                            for (int cs = 0; cs < _data.length; cs++) {
                              _data[cs][2] = cs + 1;
                            }
                            await saveCsvToLocalDirectory(); // 將csv檔案移動到本地資料夾
                            await _incrementCounter();
                            await menuUpdate(shop_storeWallet, shop_contractAddress, shop_storePassword, menunewlink);
                            // 操作完成後顯示更新成功的對話框
/*
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('更新成功'),
                                  content: Text('資料已上傳雲端'),

                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('確定'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],

                                );
                              },
                            );

 */
                          },
                          child: const Text('確認更改'),
                        ),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(30)),
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}
