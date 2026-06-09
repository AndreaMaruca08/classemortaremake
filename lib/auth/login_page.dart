import 'package:classemortaremake/core/api/http_client.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import '../localStorage/save.dart';
import 'credentials.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginPage({super.key, required this.onLoginSuccess});

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
    final code = _codeController.text.trim().toUpperCase();
    final password = _passwordController.text.trim();

    if (!_validateInputs(code, password)) return;

    setState(() => _isLoading = true);

    try {
      final client = HttpClient();
      client.init(code, password, false);
      final response = await client.doLogin();

      if (response == null) {
        if (mounted) {
          _showErrorAlert("Login Fallito", "Credenziali non valide. Riprova.");
        }
        return;
      }
      
      final creds = Credentials(
        code: code,
        pass: password,
        firstName: response['firstName'],
        lastName: response['lastName'],
      );
      
      await Save().addAccount(creds);

      if (mounted) {
        final userType = code.startsWith('S') ? "Studente" : "Genitore";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Accesso eseguito come: $userType")),
        );
        widget.onLoginSuccess();
      }
    } catch (e) {
      if (mounted) {
        _showErrorAlert("Errore di Connessione", "Impossibile raggiungere il server.");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateInputs(String code, String password) {
    if (code.isEmpty || password.isEmpty) {
      _showErrorAlert("Campi Obbligatori", "Inserisci sia il codice studente che la password.");
      return false;
    }

    if (!code.toUpperCase().startsWith('S') && !code.toUpperCase().startsWith('G')) {
      _showErrorAlert("Codice non valido", "Il codice studente deve iniziare con 'S' o 'G'.");
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
                    labelText: "Codice studente (es: S171...U)",
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
