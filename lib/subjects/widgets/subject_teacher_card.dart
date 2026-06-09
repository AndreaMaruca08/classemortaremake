import 'package:flutter/material.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import '../subject_teacher.dart';

class SubjectTeacherCard extends StatelessWidget {
  final SubjectTeacher item;

  const SubjectTeacherCard({
    super.key,
    required this.item,
  });

  Color _getColor(String name) {
    if (name.isEmpty) return Colors.grey;
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }

    final List<Color> colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
      Colors.cyanAccent,
      Colors.amberAccent,
      Colors.indigoAccent,
      Colors.pinkAccent,
      Colors.deepOrangeAccent,
      Colors.lightGreenAccent,
      Colors.deepPurpleAccent,
      Colors.limeAccent,
      Colors.lightBlueAccent,
      const Color(0xFFE57373),
      const Color(0xFF81C784),
      const Color(0xFF64B5F6),
      const Color(0xFFFFB74D),
      const Color(0xFFBA68C8),
      const Color(0xFF4DB6AC),
      const Color(0xFF9575CD),
      const Color(0xFFAED581),
      const Color(0xFFFF8A65),
      const Color(0xFF4FC3F7),
      const Color(0xFFD4E157),
      const Color(0xFFFF7043),
      const Color(0xFF26A69A),
      const Color(0xFF5C6BC0),
      const Color(0xFFEC407A),
    ];
    
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(item.description);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: context.containerDecoration.copyWith(
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.2),
                radius: 14,
                child: Icon(Icons.book, color: color, size: 14),
              ),
              8.width,
              Expanded(
                child: Text(
                  item.description,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          12.height,
          ...item.teachers.map((teacher) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.withValues(alpha: 0.1),
                  radius: 10,
                  child: Text(
                    teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : "?",
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
                8.width,
                Expanded(
                  child: Text(
                    teacher.name,
                    style: context.textTheme.bodyMedium?.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
