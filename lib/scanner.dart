import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Scanner extends StatefulWidget {
  final String ename;
  final String desc;
  final String date;
  final int eid;
  Scanner({Key ?key, required this.eid, required this.ename, required this.date, required this.desc}) : super(key: key);

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Second screen')),
      body: Center(
        child: Text(
          widget.date,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
