import 'package:flutter/material.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:intl/intl.dart';
import '../didactic_item.dart';
import '../didactic_service.dart';

class DidacticCard extends StatelessWidget {
  final DidacticItem item;
  final bool horizontal;

  const DidacticCard({
    super.key,
    required this.item,
    this.horizontal = false,
  });

  Color _getTeacherColor(String name) {
    if (name.isEmpty) return Colors.grey;
    
    // Improved hashing to avoid collisions
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }

    final List<Color> colors = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF009688), // Teal
      const Color(0xFFE91E63), // Pink
      const Color(0xFF3F51B5), // Indigo
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFFC107), // Amber
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFFCDDC39), // Lime
      const Color(0xFF673AB7), // Deep Purple
    ];
    
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final teacherColor = _getTeacherColor(item.teacher);
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(item.date);

    return Container(
      width: horizontal ? 280 : double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: context.containerDecoration.copyWith(
        border: Border.all(color: teacherColor.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: teacherColor.withOpacity(0.2),
                radius: 14,
                child: Text(
                  item.teacher.isNotEmpty ? item.teacher[0].toUpperCase() : "?",
                  style: TextStyle(color: teacherColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              8.width,
              Expanded(
                child: Text(
                  item.teacher,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          8.height,
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: horizontal ? 3 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 12, color: Colors.grey),
                  4.width,
                  Text(
                    formattedDate,
                    style: context.textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                ],
              ),
              SizedBox(
                height: 32,
                width: 32,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: teacherColor.withOpacity(0.1),
                    foregroundColor: teacherColor,
                  ),
                  onPressed: () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Scaricamento: ${item.title}...')),
                      );
                      await DidacticService().downloadDidacticFile(item);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Errore: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.file_download, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
