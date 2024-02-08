import 'package:flutter/material.dart';
import 'addition.dart' show addVector, addInt;

void main() {
  runApp(const MyApp());
}

int intX = 1234;
int intAdd = 2468;
List<int> vecX = [1, 2, 3, 4];
List<int> vecAdd = [2, 4, 6, 8];

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String ctxStatus;
  bool showIntResult = false;
  late int sumIntResult;
  bool showVecResult = false;
  late List<int> sumVecResult;
  late Map<String, int> intCtx;
  late Map<String, int> vecCtx;

  @override
  void initState() {
    super.initState();
    intCtx = {'polyModDegree': 4096, 'ptMod': 4096, 'secLevel': 128};
    sumIntResult = addInt(intCtx, intX, intAdd);

    vecCtx = {'polyModDegree': 4096, 'ptModBit': 20, 'secLevel': 128};
    sumVecResult = addVector(vecCtx, vecX, vecAdd);
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    const spacerLarge = SizedBox(height: 20);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FHEL using Microsoft SEAL'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const Text(
                  'BFV: Add Integers',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text(
                  '${intX.toString()} + ${intAdd.toString()}',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                Text(
                  "=> ${sumIntResult.toString()}",
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerLarge,
                const Text(
                  'BFV: Add List<int>',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text(
                  '${vecX.toString()} + ${vecAdd.toString()}',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                Text(
                  "=> ${sumVecResult.toString()}",
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
