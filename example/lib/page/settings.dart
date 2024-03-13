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
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Parameters'),
                ContextForm(),
                Text('Keys'),
                KeyDerivation()
              ],
            ),
          ),
        ));
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
  final _polyModDegree = GlobalKey<FormFieldState>();
  final _scalar = GlobalKey<FormFieldState>();
  final _coeffMod = GlobalKey<FormFieldState>();
  final _plainMod = GlobalKey<FormFieldState>();
  final _secLevel = GlobalKey<FormFieldState>();

  bool isBatchingEnabled = true;
  bool isDefaultParams = false;

  void defaultContext() {
    String sch = globalSession.scheme;

    Map ctx = switch (sch) {
      'ckks' => ckks,
      // BFV / BGV
      _ => isBatchingEnabled ? batching : plainModulus
    };

    _polyModDegree.currentState?.setState(() {
      isDefaultParams
          ? _polyModDegree.currentState!
              .didChange(ctx['polyModDegree'].toString())
          : _polyModDegree.currentState!.didChange('');
    });
    _scalar.currentState?.setState(() {
      isDefaultParams
          ? _scalar.currentState!
              .didChange((log(ctx['encodeScalar']) / log(2)).toString())
          : _scalar.currentState!.didChange('');
    });
    _coeffMod.currentState?.setState(() {
      isDefaultParams
          ? _coeffMod.currentState!
            .didChange(ctx['qSizes'].toString())
          : _coeffMod.currentState!.didChange('');
    });
    _plainMod.currentState?.setState(() {
      isDefaultParams
          ? isBatchingEnabled
              ? _plainMod.currentState!
                .didChange(ctx['ptModBit'].toString())
              : _plainMod.currentState!
                .didChange(ctx['ptMod'].toString())
          : _plainMod.currentState!.didChange('');
    });
    _secLevel.currentState?.setState(() {
      isDefaultParams
          ? _secLevel.currentState!.didChange(ctx['secLevel'].toString())
          : _secLevel.currentState!.didChange('');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: WIDTH,
            child: CheckboxListTile(
                title: const Text('Use Default'),
                value: isDefaultParams,
                onChanged: (_) {
                  setState(() {
                    isDefaultParams = !isDefaultParams;
                  });
                  defaultContext();
                }),
          ),
          SizedBox(
            width: WIDTH, // Set the desired width value
            child: DropdownButtonFormField(
              value: globalSession.scheme,
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
                  isDefaultParams = false;
                  defaultContext();
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
                  enabled: !isDefaultParams,
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
              key: _polyModDegree,
              enabled: !isDefaultParams,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(hintText: "Poly Modulus Degree"),
              validator: (value) {
                if (isDefaultParams) return null;
                try {
                  int.parse(value!);
                } catch (e) {
                  return 'Invalid number';
                }
                return null;
              },
              onSaved: (newValue) =>
                  globalSession.ctx['polyModDegree'] = int.parse(newValue!),
            ),
          ),
          Visibility(
            visible: globalSession.scheme == 'ckks',
            child: SizedBox(
              width: WIDTH, // Set the desired width value
              child: TextFormField(
                key: _scalar,
                enabled: !isDefaultParams,
                decoration: const InputDecoration(
                    hintText: 'Encoder Scalar', prefixText: '2^'),
                validator: (value) {
                  if (isDefaultParams) return null;
                  try {
                    int.parse(value!);
                  } catch (e) {
                    return 'Invalid number';
                  }
                  return null;
                },
                onSaved: (newValue) => globalSession.ctx['encodeScalar'] =
                    pow(2, int.parse(newValue!)),
              ),
            ),
          ),
          Visibility(
            visible: globalSession.scheme == 'ckks',
            child: SizedBox(
              width: WIDTH, // Set the desired width value
              child: TextFormField(
                key: _coeffMod,
                enabled: !isDefaultParams,
                decoration:
                    const InputDecoration(hintText: 'Coeff Mod Bit Sizes'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (isDefaultParams) return null;
                  try {
                    value!.split(',').map(int.parse).toList();
                  } catch (e) {
                    return 'Invalid list';
                  }
                  return null;
                },
                onSaved: (value) => globalSession.ctx['qSizes'] =
                    value!.split(',').map(int.parse).toList(),
              ),
            ),
          ),
          Visibility(
            visible:
                globalSession.scheme == 'bfv' || globalSession.scheme == 'bgv',
            child: SizedBox(
              width: WIDTH, // Set the desired width value
              child: TextFormField(
                key: _plainMod,
                enabled: !isDefaultParams,
                decoration: InputDecoration(
                  hintText: isBatchingEnabled == true
                      ? "Plain Modulus Bit Size"
                      : "Plain Modulus Size",
                  // prefixText: "Plain Modulus Bit Size: "
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (!isDefaultParams) return null;
                  try {
                    int.parse(value!);
                  } catch (e) {
                    return 'Invalid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (isBatchingEnabled) {
                    globalSession.ctx['ptModBit'] = int.parse(value!);
                  } else {
                    globalSession.ctx['ptMod'] = int.parse(value!);
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
                key: _secLevel,
                enabled: !isDefaultParams,
                decoration: const InputDecoration(
                  hintText: 'Security Level',
                  // prefixText: "Security Level: "
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (isDefaultParams) return null;
                  try {
                    int.parse(value!);
                  } catch (e) {
                    return 'Invalid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  globalSession.ctx['secLevel'] = int.parse(value!);
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
                      Session(globalSession.scheme, globalSession.ctx);
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
      ),
    );
  }
}
