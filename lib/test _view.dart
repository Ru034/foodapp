import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) { //返回一個 MaterialApp Widget，該Widget定義了應用程式的主題和首頁
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

Future<String> loadAsset() async { //這是一個用來非同步讀取資源的方法，返回一個表示CSV檔案內容的字串
  return await rootBundle.loadString('assets/file.csv');
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {//HomePage 的狀態類別，用於管理狀態變化
  List<List<dynamic>> _data = [];
  @override
  void initState() { //初始化狀態，然後調用 _loadCSV() 方法
    super.initState();
    _loadCSV();
  }
  String? _imagePath;
  void deleteDataAtIndex(int index) {
    setState(() {
      _data.removeAt(index);
    });
  }
  void addNewDataAtIndex(String listData, String newOption, String newPrice, int ord, int index) {
    List<dynamic> newData = [ord, "", "", listData, newOption, newPrice, ""];
    setState(() {
      _data.insert(index, newData);
    });
  }
  Future<void> saveCsvToLocalDirectory() async {
    try {
      final String csvContent = const ListToCsvConverter().convert(_data);

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/new_data.csv');

      // Write the CSV content to the local directory
      await file.writeAsString(csvContent);

      print('CSV data saved to local directory: ${file.path}');
    } catch (e) {
      print('Error saving CSV data: $e');
    }
  }
  Future<void> _pickImage(int index) async {
    final pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera, // 您可以选择相册：ImageSource.gallery
    );

    if (pickedFile != null) {
      final imagePath = pickedFile.path;

      setState(() {
        _imagePath = imagePath;
        _data[index][6] = imagePath; // 将图像路径保存到_data[index][6]中
      });
    }
  }
  showAlertDialog(BuildContext context, String listData ,int ord,int index) {
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
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          child: Text("取消"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }
  showAlertDialog2(BuildContext context, String listData ,int ord,int index) {
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
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          child: Text("取消"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );


  }
/*
  void _loadCSV() async {
    final rawData = await rootBundle.loadString("assets/M1.csv");
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
    setState(() {
      _data = listData;
    });
  }
*/

  Future<void> _loadCSV() async {
    try {
      final File file = File('/data/user/0/com.example.foodapp/app_flutter/new_data.csv'); // Update the path to your CSV file
      if (await file.exists()) {
        final String rawData = await file.readAsString();
        final List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);

        setState(() {
          _data = listData;
        });
      } else {
        print('CSV file does not exist.');
      }
    } catch (e) {
      print('Error loading CSV file: $e');
    }
  }


  showAlertDialog3(BuildContext context, String listData ,int ord,int index) {
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
            addNewDataAtIndex(listData, newOption, '' , ord, index);
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          child: Text("取消"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
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
                  padding: EdgeInsets.only(top: 15, left: 10.0, bottom: 15),
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
                  if(_data[index][0] == 1)
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
                              Expanded( //新增圖片
                                child:
                                Row(
                                  children: [
                                    if(index ==0)
                                      if (_data[index][6] == ""&&index ==0)
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () async {
                                              final pickedFile = await ImagePicker().getImage(
                                                source: ImageSource.camera,
                                              );
                                              if (pickedFile != null) {
                                                final imagePath = pickedFile.path;
                                                setState(() {
                                                  _data[index][6] = imagePath;
                                                });
                                              }
                                            },
                                            child: const Icon(
                                              Icons.photo_camera,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                    if (_data[index][6] != ""&&index ==0)
                                      Expanded(
                                        child: Image.file(
                                          File(_data[index][6]),
                                          width: 100,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    if(index > 0)
                                      if(_data[index][3] != _data[index - 1][3]&&index > 0 )
                                        if (_data[index][6] == ""&&index > 0)
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () async {
                                                final pickedFile = await ImagePicker()
                                                    .getImage(
                                                  source: ImageSource.camera,
                                                );
                                                if (pickedFile != null) {
                                                  final imagePath = pickedFile
                                                      .path;

                                                  setState(() {
                                                    _data[index][6] =
                                                        imagePath;
                                                  });
                                                }
                                              },
                                              child: const Icon(
                                                Icons.photo_camera,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                    if (_data[index][6] != ""&&index > 0)
                                      Expanded(
                                        child: Image.file(
                                          File(_data[index][6]),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(//顯示第一欄  餐點名稱
                                child:
                                Row(
                                  children: [
                                    if(index ==0)
                                      Text(_data[index][3].toString()),
                                    if(index > 0)
                                      if(_data[index][3] != _data[index - 1][3])
                                        Text(_data[index][3].toString()),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(_data[index][4].toString()),
                                    if (_data.length-1>index)
                                      if(_data[index][3] != _data[index + 1][3])
                                        TextButton(
                                          onPressed: () {
                                            showAlertDialog(context, _data[index][3].toString(), 1, index+1);
                                          },
                                          child: const Icon(
                                              Icons.add_circle_outline_sharp,
                                              color: Colors.blue),
                                        ),
                                    if (_data.length-1 == index)
                                      TextButton(
                                        onPressed: () {
                                          showAlertDialog(context, _data[index][3].toString(), 1, index+1);
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
                                child: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(
                    onPressed: () {
                      int foundindex ;
                      for (foundindex = 0; foundindex < _data.length && _data[foundindex][0] == 1; foundindex++){foundindex++;}
                      showAlertDialog2(context, _data[foundindex][3].toString(), 1, foundindex-1);
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
                  if(_data[index][0] == 2)
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
                                    if(index ==0)
                                      Text(_data[index][3].toString()),
                                    if(index > 0)
                                      if(_data[index][3] != _data[index - 1][3])
                                        Text(_data[index][3].toString()),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(_data[index][4].toString()),
                                    if (_data.length-1>index)
                                      if(_data[index][3] != _data[index + 1][3])
                                        TextButton(
                                          onPressed: () {
                                            showAlertDialog3(context, _data[index][3].toString(), 2, index+1);
                                          },
                                          child: const Icon(
                                              Icons.add_circle_outline_sharp,
                                              color: Colors.blue),
                                        ),
                                    if (_data.length-1 == index)
                                      TextButton(
                                        onPressed: () {
                                          showAlertDialog3(context, _data[index][3].toString(), 2, index+1);
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
                                child: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(
                    onPressed: () {
                      int foundindex ;
                      for (foundindex = 0; foundindex < _data.length && _data[foundindex][0] == 2||foundindex < _data.length && _data[foundindex][0] == 1; foundindex++){foundindex++;}
                      //for (foundindex = 0; foundindex < _data.length && _data[foundindex][0] == 1; foundindex++){foundindex++;}
                      showAlertDialog2(context, _data[foundindex][3].toString(), 2, foundindex-1);
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
                  if(_data[index][0] == 3)
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

                                    if(index ==0)
                                      Text(_data[index][3].toString()),
                                    if(index > 0)
                                      if(_data[index][3] != _data[index - 1][3])
                                        Text(_data[index][3].toString()),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(_data[index][4].toString()),
                                    //todo  這邊超出去
                                    if (_data.length-2>index)
                                      if(_data[index][3] != _data[index + 1][3])
                                        TextButton(
                                          onPressed: () {
                                            showAlertDialog(context, _data[index][3].toString(), 3, index+1);
                                          },
                                          child: const Icon(
                                              Icons.add_circle_outline_sharp,
                                              color: Colors.blue),
                                        ),
                                    //todo  這邊超出去
                                    if (_data.length-2 == index)
                                      TextButton(
                                        onPressed: () {
                                          showAlertDialog(context, _data[index][3].toString(), 3, index+1);
                                        },
                                        child: const Icon(
                                            Icons.add_circle_outline_sharp,
                                            color: Colors.blue),
                                      ),
                                  ],
                                ),
                              ),
                              //if(index > 0)
                              // if(_data[index][3] != _data[index - 1][3])
                              Text(_data[index][5].toString()),
                              TextButton(
                                onPressed: () {
                                  deleteDataAtIndex(index);
                                },
                                child: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(
                    onPressed: () {
                      int foundindex = _data.length-2;
                      //for (foundindex = 0; foundindex < _data.length && _data[foundindex][0] == 1; foundindex++){foundindex++;}
                      showAlertDialog2(context, _data[foundindex][3].toString(), 3, foundindex+1);
                      // todo:新增資料
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
                        width: 250, // 调整这里的宽度值
                        child: FilledButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.all(16.0),
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            for (int cs = 0; cs < _data.length; cs++) {
                              _data[cs][2] = cs + 1;
                              //_data[cs][6] = "";
                              saveCsvToLocalDirectory();
                            }
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
/*
  Future<void> saveDataToCsv() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/new_data.csv');

      //final csvContent = ListToCsvConverter().convert(_data);
      final csvContent = const ListToCsvConverter().convert(_data);

      await file.writeAsString(csvContent);

      print('Data saved to ${file.path}');
    } catch (e) {
      print('Error saving data: $e');
    }
  }
   */
}