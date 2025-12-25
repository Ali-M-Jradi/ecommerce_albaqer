import 'package:albaqer_gemstone_flutter/screens/tabs_screen.dart';
import 'package:albaqer_gemstone_flutter/database/init_sample_data.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSampleData();
  runApp(const AlBaqerMain());
}

class AlBaqerMain extends StatelessWidget {
  const AlBaqerMain({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: TabsScreen());
  }
}
