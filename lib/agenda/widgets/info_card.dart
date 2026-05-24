import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../info.dart';

class InfoCard extends StatefulWidget {
  final Info info;
  final VoidCallback? onStatusChanged;

  const InfoCard({super.key, required this.info, this.onStatusChanged});

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _loadDoneStatus();
  }

  Future<void> _loadDoneStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isDone = prefs.getBool(widget.info.storageKey) ?? false;
      });
    }
  }

  Future<void> _toggleDone(bool? value) async {
    if (value == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(widget.info.storageKey, value);
    if (mounted) {
      setState(() => _isDone = value);
    }
    if (widget.onStatusChanged != null) {
      widget.onStatusChanged!();
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.info.description));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Testo copiato negli appunti"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Color _getDeadlineColor(String dataFine) {
    try {
      DateTime today = DateTime.now();
      DateTime deadline = DateTime.parse(dataFine.substring(0, 19));
      DateTime deadlineDay =
          DateTime.parse(dataFine.substring(0, 10));
      int diffDays = deadlineDay
          .difference(DateTime(today.year, today.month, today.day))
          .inDays;

      if (deadline.isBefore(today)) {
        return today.hour < deadline.hour ? Colors.red : Colors.grey;
      }
      if (diffDays == 0) return Colors.red;
      if (diffDays == 1) return Colors.orange;
      if (diffDays <= 3) return Colors.amber;
      return Colors.green;
    } catch (e) {
      return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deadlineColor = _getDeadlineColor(widget.info.endDate);
    final backgroundColor = deadlineColor.withOpacity(0.3);

    return Opacity(
      opacity: _isDone ? 0.6 : 1.0,
      child: Container(
        width: 330,
        height: 230,
        padding: const EdgeInsets.all(16.0),
        decoration: context.containerDecoration.copyWith(
          color: backgroundColor,
          border: Border.all(color: deadlineColor.withOpacity(0.7), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.info.subject == "Non specificata"
                        ? widget.info.teacherName
                        : widget.info.subject,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: _isDone ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  onPressed: _copyToClipboard,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(),
                  tooltip: "Copia testo",
                ),
                IconButton(
                  icon: const Icon(Icons.call, size: 18),
                  onPressed: () => _askChatGPT(),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(),
                  tooltip: "Chiama chatgpt per aiuto",
                ),
                Checkbox(
                  value: _isDone,
                  onChanged: _toggleDone,
                  activeColor: deadlineColor,
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14),
                4.width,
                Text(widget.info.time, style: context.textTheme.bodySmall),
              ],
            ),
            if (widget.info.subject != "Non specificata") ...[
              4.height,
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14),
                  4.width,
                  Expanded(
                    child: Text(
                      widget.info.teacherName,
                      style: context.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.info.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    decoration: _isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
  void _askChatGPT() async {
    final subject = widget.info.subject == "null" ? widget.info.teacherName : widget.info.subject;

    final prompt = Uri.encodeComponent("Aiutami a risolvere questo compito di $subject: ${widget.info.description}");
    final url = Uri.parse("https://chatgpt.com/?q=$prompt");

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        print("Impossibile aprire l'URL: $url");
      }
    } catch (e) {
      print("Errore durante il lancio dell'URL: $e");
    }
  }


}
