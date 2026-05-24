import 'package:flutter/material.dart';
import '../core/api/http_client.dart';
import '../localStorage/save.dart';
import '../home/home_page.dart';
import 'login_page.dart';

class AuthWrapper extends StatefulWidget {
  final bool isPreviousYear;
  const AuthWrapper({super.key, required this.isPreviousYear});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final Save _storageService = Save();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final credentials = await _storageService.getCredentials();

    if (credentials != null && credentials.code.isNotEmpty && credentials.pass.isNotEmpty) {
      final client = HttpClient();
      client.init(credentials.code, credentials.pass, widget.isPreviousYear);

      try {
        final response = await client.doLogin();
        if (mounted) {
          setState(() {
            _isAuthenticated = (response != null && response['token'] != null);
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isAuthenticated = false;
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    }
  }

  void _onLoginSuccess() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isAuthenticated) {
      return HomePage(studentCode: HttpClient().studentCode ?? '');
    }

    return LoginPage(onLoginSuccess: _onLoginSuccess);
  }
}
