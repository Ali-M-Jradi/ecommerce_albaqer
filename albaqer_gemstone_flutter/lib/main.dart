import 'package:albaqer_gemstone_flutter/screens/tabs_screen.dart';
import 'package:albaqer_gemstone_flutter/database/init_sample_data.dart';
import 'package:albaqer_gemstone_flutter/services/data_manager.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database with sample data (fallback)
  await initializeSampleData();

  // Sync with backend to get real products
  print('🔄 Syncing with backend...');
  try {
    DataManager manager = DataManager();
    bool synced = await manager.syncWithBackend();
    if (synced) {
      print('✅ Backend sync successful!');
    } else {
      print('⚠️ Backend unavailable, using local data');
    }
  } catch (e) {
    print('⚠️ Sync error: $e - using local data');
  }

  runApp(const AlBaqerMain());
}

class AlBaqerMain extends StatelessWidget {
  const AlBaqerMain({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: TabsScreen());
  }
}
