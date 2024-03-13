import 'package:provider/provider.dart';
import 'package:fhel_example/page/utils.dart';
import 'package:flutter/material.dart';
import 'package:fhel_example/addition.dart';
import 'package:fhel_example/globals.dart';
import 'user_input.dart';
import 'bottom_bar.dart';
import 'settings.dart';

class HomePage extends StatelessWidget {
  final _tab1navigatorKey = GlobalKey<NavigatorState>();
  final _tab3navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return PersistentBottomBarScaffold(
      items: [
        PersistentTabItem(
          tab: HexadecimalAddition(),
          icon: Icons.home,
          title: 'Home',
          navigatorkey: _tab1navigatorKey,
        ),
        PersistentTabItem(
          tab: SettingsPage(),
          icon: Icons.settings,
          title: 'Settings',
          navigatorkey: _tab3navigatorKey,
        ),
      ],
    );
  }
}

class TestSelection extends StatelessWidget {
  const TestSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text('Hexadecimal Addition'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HexadecimalAddition(),
              ));
            },
          ),
        ],
      ),
    );
  }
}

// Create a Form widget.
class HexadecimalAddition extends StatefulWidget {
  const HexadecimalAddition({super.key});

  @override
  HexadecimalAdditionWidget createState() {
    return HexadecimalAdditionWidget();
  }
}

class HexadecimalAdditionWidget extends State<HexadecimalAddition> {
  final _x = GlobalKey<FormFieldState>();
  final _y = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionChanges>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Hexadecimal Addition')),
      drawer: TestSelection(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Addition of two hexadecimal numbers'),
            ),
            PromptNumber('x', _x),
            PromptNumber('y', _y),
            ButtonBar(
              children: [
                ElevatedButton(
                  onPressed: () {
                    final x = parseForUnsafeInt(_x.currentState?.value);
                    final y = parseForUnsafeInt(_y.currentState?.value);
                    final expected = x + y;
                    final actual = addAsHex(session.fhe, x, y);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: int.tryParse(actual) == expected
                            ? Text('Correct: $actual')
                            : Text(actual),
                      ),
                    );
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
