import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:store_menu/new_Order.dart';
import 'menu.dart';
import 'take_Order.dart';
import 'new_Order.dart';
import 'wallet.dart';
import 'setting.dart';
import 'sign_in.dart';
import 'log_in.dart';
import 'SQL.dart';

bool isDarkMode = false;

class main2 extends StatelessWidget {
  const main2({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyApp',
      theme: ThemeData(

        colorSchemeSeed: Colors.brown,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.brown,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;//選擇NavigationBar的項目
  final screens = [
    const  menu(),
    const  new_Order(),
    const  take_Order(),
    const  wallet(),
    const  setting(),
  ];//傳送至頁面的陣列

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: screens,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        child: NavigationBar(
          height: MediaQuery.of(context).size.height * 0.1,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,//只顯示選中項目的文字
          selectedIndex: index,
          animationDuration: const Duration(milliseconds: 500),
          onDestinationSelected: (index) => setState(() => this.index = index),//選定項目的結果
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu),
              //selectedIcon: Icon(Icons.restaurant_menu),
              label: '更改菜單',
            ),
            NavigationDestination(
              icon: Icon(Icons.doorbell_outlined),
              //selectedIcon: Icon(Icons.restaurant_menu),
              label: '新訂單',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_task),
              //selectedIcon: Icon(Icons.restaurant_menu),
              label: '已接訂單',
            ),
            NavigationDestination(
              icon: Icon(Icons.wallet),
              //selectedIcon: Icon(Icons.restaurant_menu),
              label: '錢包',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              //selectedIcon: Icon(Icons.restaurant_menu),
              label: '設定',
            ),

          ],
        ),
      ),
    );
  }
}