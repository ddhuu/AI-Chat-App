import 'package:flutter/material.dart';

class AdManager extends StatefulWidget {
  final Widget child;
  final bool isProUser;

  const AdManager({
    super.key,
    required this.child,
    required this.isProUser,
  });

  static _AdManagerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_AdManagerState>();
  }

  @override
  State<AdManager> createState() => _AdManagerState();
}

class _AdManagerState extends State<AdManager> {
  int _chatCounter = 0;
  final int _adFrequency = 5;

  void showInterstitialAd() {
    if (widget.isProUser) {
      return;
    }

    _chatCounter++;

    if (_chatCounter >= _adFrequency) {
      Future.delayed(Duration.zero, () {
        if (!mounted) return;
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
    return widget.child;
  }
}