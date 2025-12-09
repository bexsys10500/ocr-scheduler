import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ocr_task_scheduler/utils/BlurredBackgroundBlob.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "lottie": "assets/lottie/chatbot.json",
      "title": "Welcome",
      "desc": "Turn your physical documents into digital files in seconds.",
    },
    {
      "lottie": "assets/lottie/ai-data-loading.json",
      "title": "AI Cloud",
      "desc":
          "Generate content with AI and securely save your files in the cloud for easy access.",
    },
    {
      "lottie": "assets/lottie/dashboard.json",
      "title": "SAP B1 Sync",
      "desc":
          "Securely sync your documents and access them inside SAP Business One.",
    },
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("welcome_seen", true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, "/signin");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlurredBackgroundBlob(),
          // PAGE VIEW
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight, // Fill full height
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                pages[index]["lottie"]!,
                                width: 300,
                                height: 300,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 30),
                              Text(
                                pages[index]["title"]!,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                pages[index]["desc"]!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // SKIP BUTTON
          Positioned(
            right: 20,
            top: 50,
            child: Visibility(
              visible: _currentPage != pages.length - 1,
              child: TextButton(onPressed: _finish, child: const Text("Skip")),
            ),
          ),

          // DOT INDICATOR + NEXT/START
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // DOTS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 12 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // NEXT / GET STARTED
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == pages.length - 1) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      _currentPage == pages.length - 1 ? "Get Started" : "Next",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
