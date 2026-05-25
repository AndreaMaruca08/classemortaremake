import 'package:flutter/material.dart';
import 'package:classemortaremake/core/extension/spacing_extension.dart';
import 'package:classemortaremake/core/extension/theme_extension.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../notice.dart';
import '../noticeboard_service.dart';

class NoticeCard extends StatefulWidget {
  final Notice notice;

  const NoticeCard({super.key, required this.notice});

  @override
  State<NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<NoticeCard> {
  final NoticeboardService _service = NoticeboardService();
  String? _content;
  bool _isLoading = false;

  Future<void> _fetchContent() async {
    if (_content != null) {
      setState(() => _content = null); // Toggle off if already showing
      return;
    }

    setState(() => _isLoading = true);
    try {
      final content = await _service.readNoticeContent(
        widget.notice.documentId,
        widget.notice.eventCode,
      );
      if (mounted) {
        setState(() {
          _content = content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _content = "Errore nel caricamento: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Fixed width for horizontal scrolling
      padding: const EdgeInsets.all(16),
      decoration: context.containerDecoration,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.notice.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!widget.notice.isRead)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            8.height,
            Text(
              "Inserito il ${widget.notice.insertionDate}",
              style: context.textTheme.bodySmall,
            ),
            4.height,
            Text(
              widget.notice.isRead ? "Letta" : "Non Letta",
              style: TextStyle(
                color: widget.notice.isRead ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.notice.attachments.isNotEmpty) ...[
              12.height,
              const Divider(),
              ...widget.notice.attachments.map((attach) => InkWell(
                onTap: () async {
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Scaricamento in corso: ${attach.fileName}...')),
                    );
                    await _service.openNoticeFile(
                      widget.notice.documentId,
                      widget.notice.eventCode,
                      attach.attachNum,
                      attach.fileName,
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Errore nell\'apertura del file: $e')),
                      );
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, size: 16, color: Colors.blue),
                      8.width,
                      Expanded(
                        child: Text(
                          attach.fileName,
                          style: const TextStyle(fontSize: 12, color: Colors.blue),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],
            if (!widget.notice.hasFile || widget.notice.attachments.isEmpty) ...[
              12.height,
              if (_isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                ))
              else
                TextButton.icon(
                  onPressed: _fetchContent,
                  icon: Icon(_content == null ? Icons.read_more : Icons.expand_less, size: 18),
                  label: Text(_content == null ? "Leggi contenuto" : "Chiudi"),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30)),
                ),
              if (_content != null) ...[
                8.height,
                HtmlWidget(
                  _content!,
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
