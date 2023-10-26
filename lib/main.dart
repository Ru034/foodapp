import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sign_in.dart';
import 'log_in.dart';
import 'main2.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  final TextEditingController storeWallet = TextEditingController();
  final TextEditingController storePassword = TextEditingController();
  final TextEditingController contractAddress = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image or Color
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white],
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5,
                  ),
                ],
              ),
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '登入',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: contractAddress,
                    decoration: InputDecoration(
                      labelText: '合約位置',
                      prefixIcon: Icon(Icons.gps_fixed),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: storeWallet,
                    decoration: InputDecoration(
                      labelText: '錢包/帳號',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: storePassword,
                    decoration: InputDecoration(
                      labelText: '密碼',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context , MaterialPageRoute(builder: (context) =>main2()));
                    },
                    child: Text('登入'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context , MaterialPageRoute(builder: (context) =>sign_in()));
                    },
                    child: Text('註冊帳號'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}