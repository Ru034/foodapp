import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'menu.dart';
import 'sign_in.dart';
import 'log_in.dart';

bool isDarkMode = false;

class main2 extends StatelessWidget {
  final String contractAddress;
  const main2 ({Key? key,  required this.contractAddress}) : super(key: key);
  //main2(this.contractAddress);

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
      home: MyHomePage(contractAddress),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String contractAddress;
  const MyHomePage(this.contractAddress, {super.key});  //widget.contractAddress

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;//選擇NavigationBar的項目
  final screens = [
    const  menu(),
    const  menu(),
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
              selectedIcon: Icon(Icons.restaurant_menu),
              label: '更改菜單',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu),
              selectedIcon: Icon(Icons.restaurant_menu),
              label: '更改菜單',
            ),
          ],
        ),
      ),
    );
  }
}