import 'package:flutter/material.dart';
import '../core/api/http_client.dart';
import '../core/services/external_site_service.dart';
import '../overview/overview_service.dart';
import '../overview/models/overview_data.dart';

class HomePage extends StatefulWidget {
  final String studentCode;

  const HomePage({super.key, required this.studentCode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final OverviewService _overviewService = OverviewService();
  final ExternalSiteService _externalSiteService = ExternalSiteService();
  final HttpClient _client = HttpClient();
  
  late Future<OverviewData?> _overviewFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _overviewFuture = _overviewService.fetchOverview();
    });
  }

  Future<void> _handleRefresh() async {
    _loadData();
    await _overviewFuture;
  }

  Future<void> _openRegistryWeb() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _externalSiteService.launchRegistryWeb();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore apertura: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagina principale'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Navigator.push to SettingsPage
            },
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: FutureBuilder<OverviewData?>(
          future: _overviewFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const Center(child: Text("Errore durante il caricamento dei dati"));
            }

            final data = snapshot.data!;

            // Logic for notifications or other background processing can go here
            // e.g. _checkNewGrades(data.grades);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_client.isPreviousYear)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "ANNO PRECEDENTE",
                        style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold),
                      ),
                    ),
                  
                  // Welcome message
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Buongiorno ${_client.firstName ?? ''} ${_client.lastName ?? ''}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // TODO: UI Components will use 'data' object
                  // data.achievements
                  // data.averages
                  // data.grades
                  // data.lessons (Lessons of today)
                  // data.homeworks, tests, agendaItems
                  // data.absences, delays, exits
                  // data.disciplinaryNotes, annotations
                  
                  // Example of a button that was in the original logic
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: _openRegistryWeb,
                      child: const Text("Apri Registro Web"),
                    ),
                  ),

                  const SizedBox(height: 100), // Spacing at bottom
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
