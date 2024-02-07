import 'package:flutter/material.dart';
import 'package:fhel/fhe.dart' as fhel;

void main() {
  runApp(const MyApp());
}

String listToString(List<int> list) {
  String result = '[';
  for (int i = 0; i < list.length; i++) {
    result += list[i].toString();
    if (i < list.length - 1) result += ", ";
  }
  return "$result]";
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String ctxStatus;
  late List<int> sumResult;
  // late Future<int> sumAsyncResult;

  @override
  void initState() {
    super.initState();
    final fhe = fhel.FHE.withScheme('seal', 'bfv');
    ctxStatus = fhe
        .genContext({'polyModDegree': 4096, 'ptModBit': 20, 'secLevel': 128});
    fhe.genKeys();

    List<int> x = [1, 2, 3, 4];
    final pt_x = fhe.encodeVecInt(x);
    final ct_x = fhe.encrypt(pt_x);

    List<int> add = [2, 4, 6, 8];
    final pt_add = fhe.encodeVecInt(add);
    final ct_add = fhe.encrypt(pt_add);

    final ct_res = fhe.add(ct_x, ct_add);
    final pt_res = fhe.decrypt(ct_res);

    sumResult = fhe.decodeVecInt(pt_res, x.length);
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
                  'add(${[1, 2, 3, 4].toString()}, ${[2, 4, 6, 8].toString()})',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                Text("=> ${sumResult.toString()}", style: textStyle, textAlign: TextAlign.center,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
