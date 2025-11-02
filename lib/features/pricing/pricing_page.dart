import 'package:ai_chat_assistant/features/pricing/widgets/account_status.dart';
import 'package:ai_chat_assistant/features/pricing/widgets/pricing_card.dart';
import 'package:ai_chat_assistant/features/pricing/widgets/pricing_header.dart';
import 'package:ai_chat_assistant/features/pricing/widgets/monetization_ad_slot.dart';
import 'package:flutter/material.dart';
import '../../main.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {

  // Local state mirroring global state for UI updates
  bool _isPro = false;
  int _currentTokens = 50;

  @override
  void initState() {
    super.initState();
    // Initialize local state based on global state when the page opens
    _isPro = MyApp.of(context).isProUser;
    // Mock token count for Free users
    _currentTokens = _isPro ? 999999 : 50;
  }

  void _upgradeToPro() {
    // 1. Update local state
    setState(() {
      _isPro = true;
      _currentTokens = 999999; // Mock "Unlimited"
    });

    // 2. UPDATE GLOBAL STATE (in MyApp)
    MyApp.of(context).setIsProUser(true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upgrade successful! Welcome to Jarvis Pro!')),
    );
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> pricingCards = [
      // Free Plan Card
      PricingCard(
        title: 'Free',
        tag: 'Current',
        price: '0 VND',
        description: 'For new and basic users',
        features: const [
          '50 Tokens / day',
          'Access to GPT-4o mini',
          'Basic Chat History',
          'Contains Ads',
        ],
        isFeatured: false,
        buttonText: _isPro ? 'Activated' : 'Current Plan',
        onTap: null, // Always disabled
      ),

      // Pro Plan Card
      PricingCard(
        title: 'Jarvis Pro',
        tag: 'Recommended',
        price: '149.000 VND / month',
        description: 'Maximum power for productivity',
        features: const [
          'UNLIMITED Tokens',
          'All AI models (Gemini 1.5 Pro, GPT-4o)',
          'Create AI Agent & Workflows',
          'Q&A on Images & Files',
          'No Ads',
          'Priority Support',
        ],
        isFeatured: true,
        buttonText: _isPro ? 'Activated' : 'Upgrade Now',

        // Only allow upgrade if the user is not Pro
        onTap: _isPro ? null : _upgradeToPro,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade Account'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Account Status Bar
            AccountStatus(isPro: _isPro, currentTokens: _currentTokens),
            const SizedBox(height: 30),

            // 1. Header Widget
            const PricingHeader(),
            const SizedBox(height: 30),

            // 2. Responsive Layout
            LayoutBuilder(
              builder: (context, constraints) {
                const double breakpoint = 600;

                if (constraints.maxWidth > breakpoint) {
                  // Large screen: Row
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: pricingCards.map((card) =>
                          Expanded(child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: card,
                          ))
                      ).toList(),
                    ),
                  );
                } else {
                  // Small screen: Column
                  return Column(
                    children: [
                      ...pricingCards.map((card) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: card,
                      )),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 40),

            // 3. Monetization Ad Slot Widget
            const MonetizationAdSlot(),
          ],
        ),
      ),
    );
  }
}