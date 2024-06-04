// ignore_for_file: file_names

import 'package:equitystar/Notifications/notfication_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AddData.dart';
import 'Guidelines/AddGuidelines.dart';
import 'IPO/AddIPO.dart';
import 'IPO/IPOScreen.dart';
import 'IntraDay/IntraDayScreen.dart';
import 'LongTerm/LongTermScreen.dart';
import 'Provider.dart';
import 'ShortTerm/ShortTermScreen.dart';
import 'User/UsersScreen.dart';
import 'Guidelines/ViewGuidelinesScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Exit Equity Star?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            content: const Text(
              'Do you want to exit Equity Star?',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'No',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Yes',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "EQUITY STAR",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              // color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        drawer: Drawer(
          width: 220,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(color: CupertinoColors.systemBlue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 40,
                      backgroundImage:
                          AssetImage('assets/images/HomePageLogo.png'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_box),
                title: const Text("Add Stocks"),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AddData()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_chart_rounded),
                title: const Text("Add IPO"),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AddIPO()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.label_important),
                title: const Text("Add Guidelines"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddGuidelinesScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text("Add Notification"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Notifications(id: '')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text("Theme"),
                onTap: () {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () {},
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    "assets/images/HomePageLogo.png",
                    height: 100,
                    width: 100,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling for GridView
                  shrinkWrap:
                      true, // Wrap the GridView inside a SingleChildScrollView
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 20.0,
                  crossAxisSpacing: 20.0,
                  children: List.generate(6, (index) {
                    List<Map<String, dynamic>> cardData = [
                      {
                        "image": "assets/images/Intraday.png",
                        "text": "IntraDay",
                        "onTap": _openIntraDayScreen,
                      },
                      {
                        "image": "assets/images/ShortTerm.png",
                        "text": "Short Term",
                        "onTap": _openShortTermScreen,
                      },
                      {
                        "image": "assets/images/LongTerm.png",
                        "text": "Long Term",
                        "onTap": _openLongTermScreen,
                      },
                      {
                        "image": "assets/images/IPO.png",
                        "text": "IPO",
                        "onTap": _openIPOScreen,
                      },
                      {
                        "image": "assets/images/AllUsers.png",
                        "text": "All Users",
                        "onTap": _openUsersScreen,
                      },
                      {
                        "image": "assets/images/Guidelines.png",
                        "text": "Free Guidelines",
                        "onTap": _openGuidelinesScreen,
                      },
                    ];
                    return GestureDetector(
                      onTap: cardData[index]["onTap"],
                      child: Card(
                        color: CupertinoColors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              cardData[index]["image"],
                              width: 48.0,
                              height: 48.0,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              cardData[index]["text"],
                              style: const TextStyle(
                                  fontSize: 17.0,
                                  color: Colors.black,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openIntraDayScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const IntraDayScreen(),
    ));
  }

  void _openShortTermScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ShortTermScreen(),
    ));
  }

  void _openLongTermScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const LongTermScreen(),
    ));
  }

  void _openIPOScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const IPOScreen(),
    ));
  }

  void _openUsersScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const UserDetailsScreen(),
    ));
  }

  void _openGuidelinesScreen() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ViewGuidelinesScreen(),
    ));
  }
}
