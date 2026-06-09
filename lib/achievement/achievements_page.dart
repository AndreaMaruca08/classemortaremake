import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'package:flutter/material.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/overview/overview_service.dart';
import 'package:classemortaremake/overview/models/overview_data.dart';
import '../localStorage/save.dart';
import 'achievement.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final OverviewService _overviewService = OverviewService();
  final Save _storage = Save();
  
  late Future<OverviewData?> _overviewFuture;
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _overviewFuture = _overviewService.fetchOverview();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await _storage.getFavoriteAchievements();
    setState(() {
      _favorites = favs;
    });
  }

  Future<void> _toggleFavorite(Achievement achievement) async {
    if (!achievement.reached) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Puoi aggiungere ai preferiti solo i trofei già sbloccati")),
      );
      return;
    }

    if (!_favorites.contains(achievement.title) && _favorites.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Puoi selezionare massimo 3 trofei preferiti")),
      );
      return;
    }
    
    await _storage.toggleFavoriteAchievement(achievement.title);
    await _loadFavorites();
  }

  Widget _buildHeader() {
    return Column(
      children: [
        PageTitle(text: "Trofei", scaffoldKey: _scaffoldKey),
        12.height,
      ],
    );
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
            child: FutureBuilder<OverviewData?>(
              future: _overviewFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return const Center(child: Text("Errore durante il caricamento"));
                }

                final achievements = snapshot.data!.achievements;
                final reached = achievements.where((a) => a.reached).toList();
                final notReached = achievements.where((a) => !a.reached).toList();

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: context.containerDecoration.copyWith(
                                color: context.colorScheme.primary.withValues(alpha: 0.1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStat("Sbloccati", "${reached.length}/${achievements.length}", context.colorScheme.secondary),
                                  _buildStat("Positivi", reached.where((a) => a.isPositive).length.toString(), Colors.green),
                                  _buildStat("Negativi", reached.where((a) => !a.isPositive).length.toString(), Colors.red),
                                ],
                              ),
                            ),
                            16.height,
                            const Text(
                              "Sbloccati",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const Text(
                              "Tocca la stella per aggiungere ai preferiti (max 3)",
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            12.height,
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.75,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final a = reached[index];
                            return _AchievementCard(
                              achievement: a,
                              isFavorite: _favorites.contains(a.title),
                              onFavoriteToggle: () => _toggleFavorite(a),
                            );
                          },
                          childCount: reached.length,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Text(
                          "Ancora da ottenere",
                          style: context.textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.75,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _AchievementCard(achievement: notReached[index], isLocked: true),
                          childCount: notReached.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isLocked;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const _AchievementCard({
    required this.achievement, 
    this.isLocked = false,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final Color typeColor = achievement.isPositive ? Colors.green : Colors.red;
    
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                achievement.display,
                12.width,
                Expanded(child: Text(achievement.title)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.description),
                16.height,
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: typeColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        achievement.isPositive ? "POSITIVO" : "NEGATIVO",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: typeColor),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      achievement.rarity.toString().split('.').last,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Chiudi")),
            ],
          ),
        );
      },
      child: Card(
        elevation: isLocked ? 0 : 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isLocked ? Colors.transparent : typeColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        color: context.colorScheme.surface,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: isLocked ? 0.3 : 1.0,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: double.infinity),
                    Icon(
                      achievement.display.icon,
                      color: achievement.display.color,
                      size: 32, // Dimensione fissa centrata
                    ),
                    8.height,
                    Text(
                      achievement.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 9,
                        color: isLocked ? Colors.grey : context.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            if (!isLocked && onFavoriteToggle != null)
              Positioned(
                top: -6,
                right: -6,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? Colors.orange : Colors.grey.withValues(alpha: 0.5),
                    size: 14,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ),
            if (isLocked)
              Icon(Icons.lock_outline, size: 20, color: Colors.grey.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
