import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'package:flutter/material.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'notice.dart';
import 'noticeboard_service.dart';
import 'widgets/notice_card.dart';

class NoticeboardPage extends StatefulWidget {
  const NoticeboardPage({super.key});

  @override
  State<NoticeboardPage> createState() => _NoticeboardPageState();
}

class _NoticeboardPageState extends State<NoticeboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final NoticeboardService _service = NoticeboardService();
  late Future<List<List<Notice>>> _noticeFuture;

  @override
  void initState() {
    super.initState();
    _noticeFuture = _service.fetchNoticeboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<List<List<Notice>>>(
              future: _noticeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Errore: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.every((list) => list.isEmpty)) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Nessuna notizia disponibile al momento.',
                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    ),
                  );
                }

                final circolari = snapshot.data![0];
                final variazioniOrario = snapshot.data![1];
                final variazioniAula = snapshot.data![2];
                final altro = snapshot.data![3];

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (variazioniOrario.isNotEmpty)
                        _buildHorizontalSection("Variazioni di orario", variazioniOrario),
                      if (variazioniAula.isNotEmpty)
                        _buildHorizontalSection("Variazioni di aula", variazioniAula),
                      if (circolari.isNotEmpty)
                        _buildHorizontalSection("Circolari", circolari),
                      if (altro.isNotEmpty)
                        _buildHorizontalSection("Altro", altro),
                      100.height,
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        PageTitle(text: "Notizie", scaffoldKey: _scaffoldKey),
        12.height,
      ],
    );
  }

  Widget _buildHorizontalSection(String title, List<Notice> notices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
          child: Text(
            "$title (${notices.length})",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: NoticeCard(notice: notices[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
