import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

final supabase = Supabase.instance.client;

class _GalleryScreenState extends State<GalleryScreen> {
  Future<void> handleReload() async {
    final res = await supabase.functions.invoke(
      "task-lists/task-lists-scheduler",
      method: HttpMethod.get,
    );

    print(res.data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01),
        ),
        backgroundColor: Colors.grey.shade400,
        title: Text("Gallery"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              handleReload();
            },
            icon: HugeIcon(icon: HugeIcons.strokeRoundedReload),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListView.separated(
          itemCount: 20,
          separatorBuilder: (context, index) => Divider(color: Colors.black12),
          itemBuilder: (BuildContext context, index) {
            return ListTile(
              leading: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.blue,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedImage01,
                    color: Colors.white,
                  ),
                ),
              ),
              title: Text("Lorem ipsum"),
              subtitle: Text(
                "C:\\OCR\\test.png",
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
              trailing: Text("12/05/2025"),
            );
          },
        ),
      ),
    );
  }
}
