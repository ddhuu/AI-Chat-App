import 'package:flutter/material.dart';
import 'prompt.dart';

class Conversation extends StatelessWidget {
  final VoidCallback? onPromptTap;

  const Conversation({super.key, this.onPromptTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: ListView(
          children: [
            const Text(
              "👋",
              style: TextStyle(fontSize: 36, color: Colors.yellow),
            ),
            const Text(
              "Hello, Good morning",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
            ),
            const Text("I'm Jarvis, your personal assistant"),
            const SizedBox(height: 32),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "You don't know what to say, use a prompt",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color.fromARGB(255, 100, 116, 139),
                        ),
                      ),
                      Text(
                        "View all...",
                        style: TextStyle(fontSize: 13, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    PromptItem(text: "Translate sentence", onTap: onPromptTap),
                    PromptItem(text: "Write an email", onTap: onPromptTap),
                    PromptItem(text: "Explain Flutter", onTap: onPromptTap),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
