import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hexcolor/hexcolor.dart';
import 'package:ktfadmin/profile.dart';
import 'package:ktfadmin/scanner.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}
class Eve {
  final String? name;
  final String? desct;
  final String? date;
  final int? eid;
  final int? price;
  final String? imgurl;
  const Eve({
    required this.name,
    required this.date,
    required this.desct,
    required this.eid,
    required this.imgurl,
    required this.price,
  });
  factory Eve.fromJson(Map<String, dynamic> json) {
    return Eve(
      name: json['name'],
      date: json['eventDate'],
      eid: json['eventID'],
      price: json['price'],
      imgurl: json['imageURL'],
      desct: json['description'],
    );
  }
}
class _HomeState extends State<Home> {
  @override
  void initState() {
    // this is called when the class is initialized or called for the first time
    super.initState();
    Future.delayed(const Duration(seconds: 0)).then((e) async {
      eventd = await fetchDat();
    });
  }
  late List<Map<String, dynamic>> eventd;
  Future<List<Map<String, dynamic>>> fetchDat() async {
    List<Map<String, dynamic>> _events = [];

    final response = await http.get(
      Uri.parse('https://ktf-backend.herokuapp.com/data/events'),
      headers: <String, String>{"content-type": "application/json"},
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print(response.statusCode);
      print(response.body);
      for (var i in jsonDecode(response.body)) {
        _events.add({
          "name": Eve.fromJson(i).name,
          "date": Eve.fromJson(i).date,
          "desc": Eve.fromJson(i).desct,
          "imgurl": Eve.fromJson(i).imgurl,
          "price": Eve.fromJson(i).price,
          "eid": Eve.fromJson(i).eid,
        });
      }
      return _events;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load data json');
    }
  }
  Future<bool> _onWillPop() async {
    return (await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to exit an App'),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(false), //<-- SEE HERE
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(), // <-- SEE HERE
            child: const Text('Yes'),
          ),
        ],
      ),
    )) ??
        false;
  }
  @override
  Widget build(BuildContext context) {
    double h(double height) {
      return MediaQuery.of(context).size.height * height;
    }

    double w(double width) {
      return MediaQuery.of(context).size.width * width;
    }
    return WillPopScope(onWillPop: _onWillPop, child: DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text("Events"),
              ),
              Tab(
                child: Text("Locate"),
              ),
              Tab(
                child: Text("My Counter"),
              ),
            ],
            indicatorColor: Colors.white,
          ),
          backgroundColor: Colors.black,
          title: Text("Admin",style: GoogleFonts.sora(color: Colors.white),),
          centerTitle: true,
          actions: [
            IconButton(onPressed: (){
              FirebaseAuth.instance.signOut().whenComplete(() => Navigator.pop(context));
            }, icon:const Icon(Icons.logout,color: Colors.white,))
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(onPressed: (){

        },
        backgroundColor: Colors.grey,child: const Icon(
          Icons.location_on,
          color: Colors.white,
        ),
        ),
        bottomNavigationBar: BottomAppBar(
            color: Colors.black,
            shape:const CircularNotchedRectangle(), //shape of notch
            notchMargin:
            6, //notch margin between floating button and bottom appbar
            child: SizedBox(
              height: h(0.078),
              child: Row(
                //children inside bottom appbar
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon:const Icon(
                      Icons.home,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext bs) =>const Home()));
                    },
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  IconButton(
                    icon:const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext bs) =>const Profile()));
                    },
                  ),
                ],
              ),
            )),
        body: SafeArea(child: TabBarView(
          children: [
            SingleChildScrollView(
              child:SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: FutureBuilder(
                    future: fetchDat(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.black,),
                        );
                      } else {
                        if (snap.hasError) {
                          return Text(snap.error.toString());
                        } else {
                          final events = snap.data as List<Map<String, dynamic>>;

                          return ListView.builder(
                            itemBuilder: (context, position) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  onTap:(){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                        builder: (context) => Scanner(eid: events[position]['eid'],
                                          ename: events[position]['name'],
                                          date: events[position]['date'],
                                          desc: events[position]['desc'],
                                        ),
                                    ));
                                  },
                                  tileColor: Colors.black,
                                  title: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: AutoSizeText(
                                      "${events[position]['name']}",
                                      style: GoogleFonts.sora(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 21),
                                    ),
                                  ),
                                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: AutoSizeText(
                                          "${events[position]['desc']}",
                                          style: GoogleFonts.sora(
                                              color: Colors.white, fontSize: 14),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: AutoSizeText(
                                          "${events[position]['date']}",
                                          style: GoogleFonts.sora(
                                              color: Colors.white, fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            itemCount: events.length,
                          );
                        }
                      }
                    }),
              ),
            ),
            SingleChildScrollView(),
            SingleChildScrollView(),
          ],
        )),
      ),
    ));
  }
}
