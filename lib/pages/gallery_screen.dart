import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ocr_task_scheduler/data/download_db.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class GalleryItem {
  final int id;
  final String fileName;
  final String localPath;
  final DateTime savedAt;

  GalleryItem({
    required this.id,
    required this.fileName,
    required this.localPath,
    required this.savedAt,
  });

  factory GalleryItem.fromMap(Map<String, dynamic> map) {
    DateTime dt;
    try {
      dt = DateTime.parse(map['saved_at'] as String).toLocal();
    } catch (_) {
      dt = DateTime.now();
    }

    return GalleryItem(
      id: map['id'] as int,
      fileName: map['file_name'] as String,
      localPath: map['local_path'] as String,
      savedAt: dt,
    );
  }
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<GalleryItem> items = [];
  bool loading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final raw = await DownloadDb.instance.getDownloadsRaw();
      final list = raw.map((m) => GalleryItem.fromMap(m)).toList();

      setState(() {
        items = list;
      });
    } catch (e, st) {
      print('❌ Error loading downloads from sqlite3: $e\n$st');
      setState(() {
        errorMessage = 'Load history failed: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  String _formatDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y\n$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final hasData = items.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01),
        ),
        backgroundColor: Colors.grey.shade400,
        title: const Text("Gallery"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loading ? null : _loadDownloads,
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const HugeIcon(icon: HugeIcons.strokeRoundedReload),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
        child: Column(
          children: [
            if (errorMessage != null) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            if (!hasData && !loading)
              const Expanded(
                child: Center(
                  child: Text(
                    "No downloaded files yet.",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.black12),
                  itemBuilder: (BuildContext context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.blue,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedImage01,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(
                        item.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            item.localPath,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Text(
                        _formatDateTime(item.savedAt),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
