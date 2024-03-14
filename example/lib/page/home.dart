import 'package:flutter/material.dart';
import 'bottom_bar.dart';
import 'settings.dart';

// Test pages
import 'package:fhel_example/test/hex_add.dart';

class HomePage extends StatelessWidget {
  final _tab1navigatorKey = GlobalKey<NavigatorState>();
  final _tab3navigatorKey = GlobalKey<NavigatorState>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentBottomBarScaffold(
      items: [
        PersistentTabItem(
          tab: const HexadecimalAddition(),
          icon: Icons.home,
          title: 'Home',
          navigatorkey: _tab1navigatorKey,
        ),
        PersistentTabItem(
          tab: const SettingsPage(),
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
                builder: (context) => const HexadecimalAddition(),
              ));
            },
          ),
        ],
      ),
    );
  }
}

class HexadecimalAddition extends StatefulWidget {
  const HexadecimalAddition({super.key});

  @override
  HexadecimalAdditionPage createState() {
    return HexadecimalAdditionPage();
  }
}

class HexadecimalAdditionPage extends State<HexadecimalAddition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hexadecimal Addition')),
      drawer: const TestSelection(),
      body: hexAdditionTest(context)
    );
  }
}
