import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'package:ocr_task_scheduler/pages/gallery_screen.dart';
import 'package:ocr_task_scheduler/theme/color.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? supportPath;
  RealtimeChannel? channel;
  bool connected = false;
  bool signOutLoading = false;
  Timer? timer;
  int seconds = 0;

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
    setState(() => seconds = 0);
  }

  Future<void> handleConnect() async {
    setState(() {
      if (!connected) {
        startTimer();
        // CONNECT → SUBSCRIBE
        channel = supabase
            .channel('task_lists_changes')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'task_lists',
              callback: (payload) async {
                final filePath = payload.newRecord['file_path'];
                final signedUrl = await getPrivateImageUrl(filePath);

                if (signedUrl != null) {
                  // Step 2: Save path
                  final savePath = await getMacDownloadsPath(
                    filePath.split('/').last,
                  );
                  // Step 3: Download
                  await downloadFile(signedUrl, savePath);
                }
              },
              // print('Got new data: ${payload.newRecord}');
            )
            .subscribe();

        print("Subscribed to realtime");
      } else {
        stopTimer();
        // DISCONNECT → UNSUBSCRIBE
        if (channel != null) {
          supabase.removeChannel(channel!);
          print("Unsubscribed from realtime");
          channel = null;
        }
      }

      connected = !connected;
    });
  }

  Future<String?> getPrivateImageUrl(String path) async {
    try {
      final String signedUrl = await supabase.storage
          .from("bexsys-ocr")
          .createSignedUrl(path, 60);
      return signedUrl;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> downloadFile(String url, String savePath) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
      print("Downloaded to: $savePath");
    } else {
      print("Download failed: ${response.statusCode}");
    }
  }

  Future<void> initPath() async {
    final dir = await getApplicationSupportDirectory();
    setState(() {
      supportPath = dir.path;
    });
  }

  Future<String> getMacDownloadsPath(String filename) async {
    final dir = await getApplicationSupportDirectory();
    return "${dir.path}/$filename";
  }

  String getWindowsDownloadsPath(String filename) {
    final home = Platform.environment['USERPROFILE'];
    return "$home\\Downloads\\$filename";
  }

  @override
  void initState() {
    super.initState();
    initPath();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatTime(int sec) {
    final hours = sec ~/ 3600;
    final minutes = (sec % 3600) ~/ 60;
    final secs = sec % 60;

    return "${hours.toString().padLeft(2, '0')} : "
        "${minutes.toString().padLeft(2, '0')} : "
        "${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    var mSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: connected ? AppColors.primary : Colors.red,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.secondary,
            backgroundImage: AssetImage("assets/icons/bexsys.png"),
          ),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "Task Scheduler",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            Text(
              "Inspired by Bexsys Co., Ltd.",
              style: TextStyle(fontSize: 11, color: Colors.white60),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedMoreHorizontal),
            onSelected: (value) {
              // user selected menu item value
              if (value == 'gallery') {
                // do something
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => GalleryScreen(),
                  ),
                );
              } else if (value == 'editPath') {
              } else if (value == 'signout') {
                // do something else
                showDialog(
                  context: context,
                  builder: (context) {
                    bool loading = false;

                    return StatefulBuilder(
                      builder: (context, setStateDialog) {
                        return AlertDialog(
                          title: const Text("Sign out"),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          content: const Text("Are you sure want to sign out?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            SizedBox(
                              width: 110,
                              child: ElevatedButton(
                                onPressed: () async {
                                  setStateDialog(() {
                                    loading = true;
                                  });

                                  await supabase.auth.signOut();

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context, '/signin');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: loading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text("Confirm"),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'gallery',
                child: Text('Gallery'),
              ),
              const PopupMenuItem<String>(
                value: 'editPath',
                child: Text('Edit Path'),
              ),
              const PopupMenuItem<String>(
                value: 'signout',
                child: Text('Sign out'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Top Half
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: mSize.height * 0.8,
              decoration: BoxDecoration(
                color: connected ? AppColors.primary : Colors.red,
              ),
            ),
          ),

          // Bottom Half
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: mSize.height * 0.6,
              color: Colors.grey.shade200,
            ),
          ),

          // Overlap Button
          Align(
            alignment: const Alignment(0, -0.4),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(1),
              child: IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true, // if touch close dialog
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        title: const Text(
                          "Power Options",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          connected
                              ? "Are you sure you want to turn off the system?"
                              : "Are you sure you want to connect the system?",
                        ),
                        actionsAlignment: MainAxisAlignment.end,
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              handleConnect();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: connected
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            child: Text(connected ? "Turn Off" : "Turn On"),
                          ),
                        ],
                      );
                    },
                  );
                },
                iconSize: 100,
                icon: Icon(
                  Icons.power_settings_new_rounded,
                  color: connected ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),

          Positioned(
            width: mSize.width,
            top: mSize.height / 2.3,
            child: Column(
              children: [
                Text(
                  connected ? "Connected" : "Disconnect",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                SizedBox(height: 20),
                Text(formatTime(seconds)),
                SizedBox(height: 20),
                Text(
                  "Your file has been saved to:",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                SizedBox(height: 10),
                Text(supportPath ?? "", textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
