// lib/main.dart

import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';  // এই line যোগ করুন

import 'providers/auth_provider.dart';
import 'core/di/service_locator.dart';  // আপনার service_locator
import 'core/services/database_service.dart';
import 'core/services/socket_service.dart';
import 'chat/providers/chat_provider.dart';
import 'chat/providers/message_provider.dart';
import 'chat/chat_screen.dart';

final GetIt getIt = GetIt.instance;  // GetIt instance

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized');
  } catch (e) {
    print('❌ Firebase error: $e');
  }

  // Initialize ServiceLocator
  try {
    final ServiceLocator serviceLocator = ServiceLocator();
    await serviceLocator.init();  // সব services initialize করুন
    print('✅ ServiceLocator initialized');

    // Services register করা আছে কিনা চেক করুন
    if (serviceLocator.isRegistered<DatabaseService>()) {
      print('✅ DatabaseService is registered');
    } else {
      print('❌ DatabaseService not registered');
    }

    if (serviceLocator.isRegistered<SocketService>()) {
      print('✅ SocketService is registered');
    } else {
      print('❌ SocketService not registered');
    }

  } catch (e) {
    print('❌ ServiceLocator error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: MaterialApp(
        title: 'LotChat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

// ... বাকি HomeScreen কোড
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LotChat'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (BuildContext context, AuthProvider auth, Widget? child) {
          if (auth.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (auth.isLoggedIn) {
            return _buildLoggedInUI(auth);
          }

          return _buildLoggedOutUI();
        },
      ),
    );
  }

  Widget _buildLoggedInUI(AuthProvider auth) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purple.shade100,
              child: Text(
                auth.currentUser?.name[0].toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${auth.currentUser?.name ?? 'User'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Role: ${auth.currentUser?.role.toString().split('.').last ?? ''}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.purple,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Go to Chat Screen Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const ChatScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.chat),
              label: const Text('Go to Chats'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedOutUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.chat_bubble_outline,
              size: 100,
              color: Colors.purple,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to LotChat',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Voice Chat & PK Battle App',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Choose a demo account to login:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            _buildDemoAccounts(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoAccounts() {
    final accounts = <Map<String, dynamic>><Map<String, dynamic>>[
      <String, dynamic>{'role': 'Admin', 'email': 'admin@test.com', 'password': 'admin123', 'color': Colors.red},
      <String, dynamic>{'role': 'Country Manager', 'email': 'manager@test.com', 'password': 'manager123', 'color': Colors.purple},
      <String, dynamic>{'role': 'Agency Owner', 'email': 'agency@test.com', 'password': 'agency123', 'color': Colors.blue},
      <String, dynamic>{'role': 'Coin Seller', 'email': 'seller@test.com', 'password': 'seller123', 'color': Colors.orange},
      <String, dynamic>{'role': 'Host', 'email': 'host@test.com', 'password': 'host123', 'color': Colors.pink},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: accounts.map((Map<String, dynamic> account) {
        return ElevatedButton(
          onPressed: () => _login(context, account['email'], account['password']),
          style: ElevatedButton.styleFrom(
            backgroundColor: account['color'],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(account['role']),
        );
      }).toList(),
    );
  }

  Future<void> _login(BuildContext context, String email, String password) async {
    final AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);

    final bool success = await auth.login(email, password);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Logged in as ${auth.currentUser?.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${auth.error ?? 'Login failed'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    final AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);

    await auth.logout();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('👋 Logged out successfully'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}