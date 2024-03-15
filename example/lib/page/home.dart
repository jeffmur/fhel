import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'bottom_bar.dart';
import 'settings.dart';

// Test pages
import 'package:fhel_example/test/add_hex.dart';
import 'package:fhel_example/test/add_double.dart';
import 'package:fhel_example/test/add_list_int.dart';
import 'package:fhel_example/test/add_list_double.dart';

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
    final session = Provider.of<SessionChanges>(context);
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text('Hexadecimal Addition'),
            onTap: () {
              session.clearLogs();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const HexadecimalAddition(),
              ));
            },
          ),
          ListTile(
            title: const Text('Double Addition'),
            onTap: () {
              session.clearLogs();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const DoubleAddition(),
              ));
            },
          ),
          ListTile(
            title: const Text('List<int> Addition'),
            onTap: () {
              session.clearLogs();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ListIntAddition(),
              ));
            },
          ),
          ListTile(
            title: const Text('List<double> Addition'),
            onTap: () {
              session.clearLogs();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ListDoubleAddition(),
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
      body: hexAdd(context));
  }
}

class DoubleAddition extends StatefulWidget {
  const DoubleAddition({super.key});

  @override
  DoubleAdditionPage createState() {
    return DoubleAdditionPage();
  }
}

class DoubleAdditionPage extends State<DoubleAddition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Double Addition')),
      drawer: const TestSelection(),
      body: doubleAdd(context));
  }
}

class ListIntAddition extends StatefulWidget {
  const ListIntAddition({super.key});

  @override
  ListIntAdditionPage createState() {
    return ListIntAdditionPage();
  }
}

class ListIntAdditionPage extends State<ListIntAddition> {
  @override
  Widget build(BuildContext context) {
    // final session = Provider.of<SessionChanges>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('List<int> Addition')),
      drawer: const TestSelection(),
      body: listIntAdd(context));
  }
}

class ListDoubleAddition extends StatefulWidget {
  const ListDoubleAddition({super.key});

  @override
  ListDoubleAdditionPage createState() {
    return ListDoubleAdditionPage();
  }
}

class ListDoubleAdditionPage extends State<ListDoubleAddition> {
  @override
  Widget build(BuildContext context) {
    // final session = Provider.of<SessionChanges>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('List<double> Addition')),
      drawer: const TestSelection(),
      body: listDoubleAdd(context));
  }
}
