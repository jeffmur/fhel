import 'package:flutter/material.dart';
import 'dart:math';
import '../globals.dart';

// ignore: constant_identifier_names
const double WIDTH = 200;

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Settings build');
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Container(
        width: double.infinity,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Parameters'),
            ContextForm(),
            Text('Keys'),
            KeyDerivation(),
          ],
        ),
      ),
    );
  }
}

// Create a Form widget.
class ContextForm extends StatefulWidget {
  const ContextForm({super.key});

  @override
  ParameterForm createState() {
    return ParameterForm();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class ParameterForm extends State<ContextForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  bool isBatchingEnabled = false;

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: WIDTH, // Set the desired width value
            child: DropdownButtonFormField(
              // value: 'bfv', // Set the default value to 'bfv'
              decoration: const InputDecoration(
                hintText: 'Scheme',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'bfv',
                  child: Text('BFV'),
                ),
                DropdownMenuItem(
                  value: 'bgv',
                  child: Text('BGV'),
                ),
                DropdownMenuItem(
                  value: 'ckks',
                  child: Text('CKKS'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  globalSession.setScheme(value!);
                });
              },
            ),
          ),
          Visibility(
            visible:
                globalSession.scheme == 'bfv' || globalSession.scheme == 'bgv',
            child: SizedBox(
              width: WIDTH,
              child: CheckboxListTile(
                  title: const Text('Batching'),
                  value: isBatchingEnabled,
                  onChanged: (value) {
                    setState(() {
                      isBatchingEnabled = !isBatchingEnabled;
                    });
                  }),
            ),
          ),
          SizedBox(
            width: WIDTH, // Set the desired width value
            child: TextFormField(
              // initialValue: globalSession.ctx['polyModDegree'].toString(),
              decoration: const InputDecoration(hintText: "Poly Modulus Degree"
                  // prefixText: 'Poly Modulus Degree: ',
                  ),
              validator: (value) {
                try {
                  int.parse(value!);
                } catch (e) {
                  return 'Invalid number';
                }
                return null;
              },
              onChanged: (value) {
                globalSession.ctx['polyModDegree'] = int.parse(value);
              },
            ),
          ),
          Visibility(
            visible: globalSession.scheme == 'ckks',
            child: SizedBox(
              width: WIDTH, // Set the desired width value
              child: TextFormField(
                decoration: const InputDecoration(
                    hintText: 'Encoder Scalar', prefixText: '2^'),
                validator: (value) {
                  try {
                    int.parse(value!);
                  } catch (e) {
                    return 'Invalid number';
                  }
                  return null;
                },
                onChanged: (value) {
                  globalSession.ctx['encodeScalar'] = pow(2, int.parse(value));
                },
              ),
            ),
          ),
          Visibility(
            visible: globalSession.scheme == 'ckks',
            child: SizedBox(
              width: WIDTH, // Set the desired width value
              child: TextFormField(
                decoration:
                    const InputDecoration(hintText: 'Coeff Mod Bit Sizes'),
                validator: (value) {
                  try {
                    value!.split(',').map(int.parse).toList();
                  } catch (e) {
                    return 'Invalid list';
                  }
                  return null;
                },
                onChanged: (value) {
                  globalSession.ctx['qSizes'] =
                      value.split(',').map(int.parse).toList();
                },
              ),
            ),
          ),
          Visibility(
            visible:
                globalSession.scheme == 'bfv' || globalSession.scheme == 'bgv',
            child: SizedBox(
              width: WIDTH, // Set the desired width value
              child: TextFormField(
                // initialValue: globalSession.ctx['ptModBit'].toString(),
                decoration: InputDecoration(
                  hintText: isBatchingEnabled == true
                      ? "Plain Modulus Bit Size"
                      : "Plain Modulus Size",
                  // prefixText: "Plain Modulus Bit Size: "
                ),
                validator: (value) {
                  try {
                    int.parse(value!);
                  } catch (e) {
                    return 'Invalid number';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (isBatchingEnabled) {
                    globalSession.ctx['ptModBit'] = int.parse(value);
                  } else {
                    globalSession.ctx['ptMod'] = int.parse(value);
                  }
                },
              ),
            ),
          ),
          Visibility(
            visible:
                globalSession.scheme == 'bfv' || globalSession.scheme == 'bgv',
            child: SizedBox(
              width: WIDTH, // Set the desired width value
              child: TextFormField(
                // initialValue: globalSession.ctx['secLevel'].toString(),
                decoration: const InputDecoration(
                  hintText: 'Security Level',
                  // prefixText: "Security Level: "
                ),
                validator: (value) {
                  try {
                    int.parse(value!);
                  } catch (e) {
                    return 'Invalid number';
                  }
                  return null;
                },
                onChanged: (value) {
                  globalSession.ctx['secLevel'] = int.parse(value);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  globalSession =
                      Session.init(globalSession.scheme, globalSession.ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(globalSession.ctxStatus)),
                  );
                }
              },
              child: const Text('Validate'),
            ),
          ),
        ],
      ),
    );
  }
}

// Create a Form widget.
class KeyDerivation extends StatefulWidget {
  const KeyDerivation({super.key});

  @override
  KeyDerivationState createState() {
    return KeyDerivationState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class KeyDerivationState extends State<KeyDerivation> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: WIDTH,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: const Text('Public Key'),
                    subtitle: Text(globalSession.publicKey),
                  ),
                  ListTile(
                    title: const Text('Secret Key'),
                    subtitle: Text(globalSession.secretKey),
                  ),
                  ListTile(
                    title: const Text('Relin Keys'),
                    subtitle: Text(globalSession.relinKeys),
                  ),
                ],
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                globalSession.fhe.genKeys();
                globalSession.fhe.genRelinKeys();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Keys generated')),
              );
            },
            child: const Text('Generate Keys'),
          ),
        ],
    ));
  }
}
