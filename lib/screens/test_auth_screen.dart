import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_profile.dart';

class TestAuthScreen extends StatefulWidget {
  const TestAuthScreen({super.key});

  @override
  State<TestAuthScreen> createState() => _TestAuthScreenState();
}

class _TestAuthScreenState extends State<TestAuthScreen> {
  final _emailController = TextEditingController(text: 'chutro@gmail.com');
  final _passwordController = TextEditingController(text: '123456');
  String _testResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testLogin,
                    child: const Text('Test Login'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _testFirebaseData,
                    child: const Text('Test Firebase'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testManualData,
              child: const Text('Test Manual Parse'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _testResult,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testLogin() async {
    final auth = context.read<AuthProvider>();

    setState(() {
      _testResult = 'Testing login...\n';
    });

    final success = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() {
      _testResult += 'Login result: $success\n';
      if (auth.errorMessage != null) {
        _testResult += 'Error: ${auth.errorMessage}\n';
      }
      _testResult += 'Current user: ${auth.currentUser?.email}\n';
      _testResult += 'Is online: ${auth.isOnline}\n';
      _testResult += 'Users count: ${auth.users.length}\n';
    });
  }

  void _testFirebaseData() async {
    final auth = context.read<AuthProvider>();

    setState(() {
      _testResult = 'Testing Firebase data...\n';
    });

    await auth.debugFirebaseStatus();
    await auth.refreshUsers();

    setState(() {
      _testResult += 'Firebase online: ${auth.isOnline}\n';
      _testResult += 'Users count: ${auth.users.length}\n';
      _testResult += '\nUsers found:\n';
      for (final user in auth.users) {
        _testResult += '- ${user.name} (${user.email}) - ${user.role.value}\n';
      }
    });
  }

  void _testManualData() {
    // Test with the exact data structure from Firebase screenshot
    final testData = {
      'user_1757071890576_1eqtb0s20': {
        'createdAt': '2025-09-05T11:31:30.576Z',
        'email': 'chutro@gmail.com',
        'id': 'user_1757071890576_1eqtb0s20',
        'name': 'chủ trọ',
        'password': '123456',
        'role': 'landlord',
        'status': 'active',
      },
    };

    setState(() {
      _testResult = 'Testing manual data parsing...\n';
    });

    try {
      final userData = Map<dynamic, dynamic>.from(testData.values.first);
      final user = UserProfile.fromMap(userData);

      setState(() {
        _testResult += 'Parsed successfully:\n';
        _testResult += 'ID: ${user.id}\n';
        _testResult += 'Email: ${user.email}\n';
        _testResult += 'Name: ${user.name}\n';
        _testResult += 'Role: ${user.role.value}\n';
        _testResult += 'Status: ${user.status}\n';
        _testResult += 'Password: ${user.password}\n';

        // Test login logic
        final email = 'chutro@gmail.com';
        final password = '123456';
        final match =
            user.email.toLowerCase() == email.toLowerCase() &&
            user.password == password;

        _testResult += '\nLogin test:\n';
        _testResult +=
            'Email match: ${user.email.toLowerCase() == email.toLowerCase()}\n';
        _testResult += 'Password match: ${user.password == password}\n';
        _testResult += 'Overall match: $match\n';
      });
    } catch (error) {
      setState(() {
        _testResult += 'Parse error: $error\n';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
