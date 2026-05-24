import 'package:flutter/material.dart';
import '../core/api/http_client.dart';
import '../localStorage/save.dart';
import 'loginPage.dart';

class AuthWrapper extends StatefulWidget {
  final bool isPreviousYear;
  const AuthWrapper({super.key, required this.isPreviousYear});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final Save _storageService = Save();
  bool _isLoading = true;
  Widget? _destinationPage;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final credentials = await _storageService.getCredentials();
    
    if (!mounted) return;

    if (credentials != null && credentials.code.isNotEmpty && credentials.pass.isNotEmpty) {
      final client = HttpClient();
      client.init(credentials.code, credentials.pass, widget.isPreviousYear);
      
      final response = await client.doLogin();
      
      if (!mounted) return;

      if (response != null && response['token'] != null) {
        setState(() {
          // TODO: Update MainPage once ApiService is refactored into features
          // _destinationPage = MainPage(studentCode: credentials.code);
          _isLoading = false;
        });
      } else {
        _navigateToLogin();
      }
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    setState(() {
      _destinationPage = const LoginPage();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return _destinationPage ?? const LoginPage();
  }
}
