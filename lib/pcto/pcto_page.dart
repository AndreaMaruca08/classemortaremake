import 'package:flutter/material.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:classemortaremake/core/widgets/drawer.dart';
import 'package:classemortaremake/core/widgets/title.dart';
import 'curriculum_data.dart';
import 'curriculum_service.dart';

class PctoPage extends StatefulWidget {
  const PctoPage({super.key});

  @override
  State<PctoPage> createState() => _PctoPageState();
}

class _PctoPageState extends State<PctoPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CurriculumService _service = CurriculumService();
  late Future<CurriculumData> _curriculumFuture;

  @override
  void initState() {
    super.initState();
    _curriculumFuture = _service.getCurriculum();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          PageTitle(text: "Percorso PCTO", scaffoldKey: _scaffoldKey),
          Expanded(
            child: FutureBuilder<CurriculumData>(
              future: _curriculumFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Errore: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text("Nessun dato PCTO trovato"));
                }

                final data = snapshot.data!;
                const int fixedTargetHours = 150;
                final isCompleted = data.totalAttendanceHours >= fixedTargetHours;
                final progress = (data.totalAttendanceHours / fixedTargetHours).clamp(0.0, 1.0);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(data, progress, isCompleted, fixedTargetHours),
                      24.height,
                      const Text(
                        "Esperienze Formative",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      16.height,
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.experiences.length,
                        separatorBuilder: (context, index) => 12.height,
                        itemBuilder: (context, index) {
                          return _ExperienceCard(experience: data.experiences[index]);
                        },
                      ),
                      80.height,
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

  Widget _buildSummaryCard(CurriculumData data, double progress, bool isCompleted, int targetHours) {
    final Color brightGreen = isCompleted ? const Color(0xFF00E676) : const Color(0xFFB2FF59);
    final Color accentColor = isCompleted ? const Color(0xFF00E676) : context.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: context.containerDecoration.copyWith(
        gradient: LinearGradient(
          colors: [
            context.colorScheme.surface,
            accentColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Ore Presenze Totali", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  4.height,
                  Text(
                    data.totalAttendanceHoursRaw,
                    style: TextStyle(
                      fontSize: 48, 
                      fontWeight: FontWeight.bold,
                      color: brightGreen,
                      shadows: [
                        Shadow(
                          color: brightGreen.withOpacity(isCompleted ? 0.8 : 0.4), 
                          blurRadius: isCompleted ? 20 : 8
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Icon(
                isCompleted ? Icons.verified : Icons.pending_actions,
                size: 56,
                color: brightGreen.withOpacity(0.8),
              ),
            ],
          ),
          20.height,
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.2),
            color: brightGreen,
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
          ),
          12.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Obiettivo: $targetHours ore",
                style: context.textTheme.bodySmall,
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: brightGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final Experience experience;

  const _ExperienceCard({required this.experience});

  @override
  Widget build(BuildContext context) {
    final progress = experience.experienceHours > 0 
        ? (experience.attendanceHours / experience.experienceHours).clamp(0.0, 1.0)
        : 0.0;
    
    final Color accentColor = progress >= 1.0 ? Colors.green : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: context.containerDecoration.copyWith(
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.business_center, color: accentColor, size: 20),
              12.width,
              Expanded(
                child: Text(
                  experience.locationName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHourInfo("Previste", experience.experienceHoursRaw),
              _buildHourInfo("Presenza", experience.attendanceHoursRaw, color: accentColor),
            ],
          ),
          12.height,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withOpacity(0.1),
              color: accentColor.withOpacity(0.5),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourInfo(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
