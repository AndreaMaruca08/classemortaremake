import 'package:classemortaremake/core/api/http_client.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import '../localStorage/save.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final code = _codeController.text.trim();
    final password = _passwordController.text.trim();

    if (!_validateInputs(code, password)) return;

    setState(() => _isLoading = true);

    try {
      HttpClient().init(code, password, false);
      final response = await HttpClient().doLogin();

      if (response == null) {
        if (mounted) {
          _showErrorAlert("Login Failed", "Invalid credentials. Please try again.");
        }
        return;
      }

      await Save().saveStringList([code, password]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully logged in")),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorAlert("Connection Error", "Could not reach the server.");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateInputs(String code, String password) {
    if (code.isEmpty || password.isEmpty) {
      _showErrorAlert("Required Fields", "Please enter both student code and password.");
      return false;
    }

    if (!code.toUpperCase().startsWith('S') && !code.toUpperCase().startsWith('G')) {
      _showErrorAlert("Invalid Code", "The student code must start with 'S' or 'G'.");
      return false;
    }

    return true;
  }

  void _showErrorAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                24.height,
                Text(
                  "ClasseMorta",
                  style: context.textTheme.titleLarge?.copyWith(
                    fontSize: 50,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                8.height,
                Text(
                  "Il migliore registro elettronico",
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                64.height,
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: "Codice studente (ex: S171...U)",
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                ),
                20.height,
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleLogin(),
                ),
                48.height,
                AppButton(
                  text: "Accedi",
                  isLoading: _isLoading,
                  width: double.infinity,
                  height: 58,
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: Colors.white,
                  onPressed: _handleLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
