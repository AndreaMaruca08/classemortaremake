import 'package:flutter/material.dart';
import 'package:classemortaremake/core/api/http_client.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'package:classemortaremake/main.dart';
import '../localStorage/save.dart';
import '../auth/credentials.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _client = HttpClient();
  final _storage = Save();

  late double _gradeAnim;
  late double _trendChartAnim;
  late double _numbersChartAnim;
  late ThemeMode _themeMode;
  List<Credentials> _accounts = [];

  @override
  void initState() {
    super.initState();
    _gradeAnim = _client.settings.gradeAnimationMs.toDouble();
    _trendChartAnim = _client.settings.trendChartAnimationMs.toDouble();
    _numbersChartAnim = _client.settings.numbersChartAnimationMs.toDouble();
    _themeMode = _client.settings.themeMode;
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await _storage.getAllAccounts();
    setState(() {
      _accounts = accounts;
    });
  }

  Future<void> _switchAccount(Credentials creds) async {
    final oldCode = _client.studentCode;
    final oldPass = _client.password;
    final oldPrev = _client.isPreviousYear;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      _client.init(creds.code, creds.pass, false);
      final response = await _client.doLogin();

      if (response != null) {
        await _storage.setCurrentAccount(creds.code);
        if (mounted) {
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } else {
        _client.init(oldCode!, oldPass!, oldPrev);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Errore nel login. Credenziali non valide.')),
          );
        }
      }
    } catch (e) {
      _client.init(oldCode!, oldPass!, oldPrev);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore di connessione.')),
        );
      }
    }
  }

  Future<void> _removeAccount(String code) async {
    if (_client.studentCode == code) return;
    await _storage.removeAccount(code);
    _loadAccounts();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Disconnetti Account"),
        content: Text("Vuoi davvero rimuovere l'account di ${_client.firstName} da questo dispositivo?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annulla")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Disconnetti", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storage.logout();
      
      // Clear current session singleton
      _client.token = null;
      _client.studentCode = null;
      _client.password = null;
      _client.firstName = null;
      _client.lastName = null;
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }

  Future<void> _addNewAccount() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AddAccountOverlay(
          onSuccess: () {
            _loadAccounts();
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    _client.settings.gradeAnimationMs = _gradeAnim.toInt();
    _client.settings.trendChartAnimationMs = _trendChartAnim.toInt();
    _client.settings.numbersChartAnimationMs = _numbersChartAnim.toInt();
    _client.settings.themeMode = _themeMode;
    
    await _client.settings.saveSettings();
    themeNotifier.value = _themeMode;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impostazioni salvate correttamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          PageTitle(text: "Impostazioni", scaffoldKey: _scaffoldKey),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle("Account Salvati"),
                Card(
                  child: Column(
                    children: [
                      ..._accounts.map((acc) {
                        final isCurrent = _client.studentCode == acc.code;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isCurrent ? context.colorScheme.primary : Colors.grey[200],
                            child: Text(
                              acc.firstName?.substring(0, 1) ?? "?",
                              style: TextStyle(color: isCurrent ? Colors.white : Colors.black87),
                            ),
                          ),
                          title: Text("${acc.firstName ?? ''} ${acc.lastName ?? ''}"),
                          subtitle: Text(acc.code),
                          trailing: isCurrent 
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _removeAccount(acc.code),
                              ),
                          onTap: isCurrent ? null : () => _switchAccount(acc),
                        );
                      }),
                      ListTile(
                        leading: const Icon(Icons.add_circle_outline),
                        title: const Text("Aggiungi nuovo account"),
                        onTap: _addNewAccount,
                      ),
                      if (_client.studentCode != null && _accounts.length == 1)
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text("Disconnetti account attuale", style: TextStyle(color: Colors.red)),
                          onTap: _handleLogout,
                        ),
                    ],
                  ),
                ),
                24.height,
                _buildSectionTitle("Aspetto"),
                Card(
                  child: Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        title: const Text("Sistema"),
                        value: ThemeMode.system,
                        groupValue: _themeMode,
                        onChanged: (v) => setState(() => _themeMode = v!),
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text("Chiaro"),
                        value: ThemeMode.light,
                        groupValue: _themeMode,
                        onChanged: (v) => setState(() => _themeMode = v!),
                      ),
                      RadioListTile<ThemeMode>(
                        title: const Text("Scuro"),
                        value: ThemeMode.dark,
                        groupValue: _themeMode,
                        onChanged: (v) => setState(() => _themeMode = v!),
                      ),
                    ],
                  ),
                ),
                24.height,
                _buildSectionTitle("Animazioni (ms)"),
                _buildSliderCard(
                  "Cerchio Voti", 
                  _gradeAnim, 
                  (v) => setState(() => _gradeAnim = v),
                  min: 0, max: 3000
                ),
                12.height,
                _buildSliderCard(
                  "Grafico Andamento", 
                  _trendChartAnim, 
                  (v) => setState(() => _trendChartAnim = v),
                  min: 0, max: 3000
                ),
                12.height,
                _buildSliderCard(
                  "Grafico Distribuzione", 
                  _numbersChartAnim, 
                  (v) => setState(() => _numbersChartAnim = v),
                  min: 0, max: 3000
                ),
                32.height,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text("Salva Impostazioni"),
                  ),
                ),
                100.height,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildSliderCard(String label, double value, ValueChanged<double> onChanged, {double min = 0, double max = 3000}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("${value.toInt()} ms", style: TextStyle(color: context.colorScheme.primary, fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: 30,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAccountOverlay extends StatefulWidget {
  final VoidCallback onSuccess;
  const _AddAccountOverlay({required this.onSuccess});

  @override
  State<_AddAccountOverlay> createState() => _AddAccountOverlayState();
}

class _AddAccountOverlayState extends State<_AddAccountOverlay> {
  final _codeController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final code = _codeController.text.trim().toUpperCase();
    final pass = _passController.text.trim();

    if (code.isEmpty || pass.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final client = HttpClient();
      client.init(code, pass, false);
      final response = await client.doLogin();

      if (response != null) {
        final creds = Credentials(
          code: code,
          pass: pass,
          firstName: response['firstName'],
          lastName: response['lastName'],
        );
        await Save().addAccount(creds);
        widget.onSuccess();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Credenziali non valide')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore di connessione')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aggiungi Account")),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(labelText: "Codice Studente"),
              textCapitalization: TextCapitalization.characters,
            ),
            20.height,
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            32.height,
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text("Accedi e Aggiungi"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
