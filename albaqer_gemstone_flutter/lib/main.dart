import 'package:albaqer_gemstone_flutter/screens/tabs_screen.dart';
import 'package:albaqer_gemstone_flutter/screens/login_screen.dart';
import 'package:albaqer_gemstone_flutter/database/init_sample_data.dart';
import 'package:albaqer_gemstone_flutter/services/data_manager.dart';
import 'package:albaqer_gemstone_flutter/services/auth_service.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // EXPLAIN IN PRESENTATION: Using FutureBuilder to check authentication status
      // before deciding which screen to show
      home: FutureBuilder<bool>(
        // Check if user is already logged in by verifying stored token
        future: AuthService().isLoggedIn(),
        /// Builder function that receives the current [BuildContext] and an [AsyncSnapshot]
        /// containing the result of an asynchronous operation.
        ///
        /// This builder is typically used within widgets like [FutureBuilder] or [StreamBuilder]
        /// to construct the UI based on the state of the snapshot (waiting, done, error, etc.).
        ///
        /// Parameters:
        /// - [context]: The build context for the widget tree
        /// - [snapshot]: Contains the current state and data of the asynchronous operation
        builder: (context, snapshot) {
          // Show loading indicator while checking authentication
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // After checking, show appropriate screen:
          // - If logged in (token exists and valid): show TabsScreen (main app)
          // - If not logged in: show LoginScreen (authentication required)
          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? TabsScreen() : const LoginScreen();
        },
      ),
    );
  }
}
