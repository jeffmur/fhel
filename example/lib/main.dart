import 'package:flutter/material.dart';
import 'dart:async';

import 'package:fhel/fhe.dart' as fhel;
import 'package:fhel/afhe/plaintext.dart' show Plaintext;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String ctxStatus;
  late int sumResult;
  late Future<int> sumAsyncResult;

  @override
  void initState() {
    super.initState();
    final fhe = fhel.FHE.withScheme('seal', 'bfv');
    ctxStatus =
        fhe.genContext({'polyModDegree': 4096, 'ptMod': 1024, 'secLevel': 128});
    fhe.genKeys();
    final pt_x = Plaintext.withValue(fhe.backend, '1');
    final ct_x = fhe.encrypt(pt_x);
    final pt_add = Plaintext.withValue(fhe.backend, '2');
    final ct_add = fhe.encrypt(pt_add);
    final ct_res = fhe.add(ct_x, ct_add);

    sumResult = int.parse(fhe.decrypt(ct_res).text);
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'FHE with SEAL and BFV Scheme',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text(
                  'add(1, 2) = $sumResult',
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
