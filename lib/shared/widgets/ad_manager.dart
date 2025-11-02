import 'package:flutter/material.dart';

// This widget simulates a global Ad Manager (e.g., Google AdMob/Facebook Audience Network)
// It can display a small Banner Ad or trigger an Interstitial Ad (full-screen)
class AdManager extends StatefulWidget {
  final Widget child;
  final bool isProUser; // Flag to check Pro status

  const AdManager({
    super.key,
    required this.child,
    required this.isProUser,
  });

  // Public method to access and trigger the ad state logic
  static _AdManagerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_AdManagerState>();
  }

  @override
  State<AdManager> createState() => _AdManagerState();
}

class _AdManagerState extends State<AdManager> {
  int _chatCounter = 0;
  final int _adFrequency = 3; // Show ad after every 3 chat actions

  // Function to simulate showing an Interstitial Ad (full-screen)
  void showInterstitialAd() {
    // Pro users skip ads
    if (widget.isProUser) {
      return;
    }

    _chatCounter++;

    if (_chatCounter >= _adFrequency) {
      // Simulate showing a full-screen ad (using an AlertDialog)
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Advertisement'),
              content: const Text(
                'This is a full-screen ad (Interstitial Ad). Thank you for supporting us!',
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close Ad'),
                ),
              ],
            );
          },
        );
      });
      _chatCounter = 0; // Reset counter after showing the ad
    }
  }

  @override
  Widget build(BuildContext context) {
    // If Pro, return child directly (no ads)
    if (widget.isProUser) {
      return widget.child;
    }

    // Non-Pro user: Wrap content with a simulated Banner Ad at the top
    return Column(
      children: [
        // Simulated Banner Ad Placement
        Container(
          height: 50,
          width: double.infinity,
          color: Colors.yellow.shade100,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 5),
          child: const Text(
            'BANNER AD: Enjoying the app? Upgrade to Pro!',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
        // Important: Use Expanded to allow the main content (ChatPage) to fill remaining space
        Expanded(child: widget.child),
      ],
    );
  }
}