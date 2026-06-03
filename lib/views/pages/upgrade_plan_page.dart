import 'package:flutter/material.dart';

import '../widgets/glass_appbar.dart';
import '../widgets/glass_card_custom.dart';

class UpgradePlanPage extends StatelessWidget {
  const UpgradePlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlassAppBar(title: 'Upgrade Plan'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your plan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Upgrade to unlock premium productivity features.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),

            GlassCardCustom(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Icon(Icons.verified_user, color: Colors.black87),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Current Plan: Free',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    _PlanChip(label: 'Active'),
                  ],
                ),
              ),
            ),

            GlassCardCustom(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Expanded(
                          child: Text(
                            'Premium',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _PlanChip(label: 'Best Value'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          '5 JOD',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 6),
                        Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            '/ month',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _FeatureRow(text: 'Smart Assistant (FAQ, GPA, recommendations)'),
                    const _FeatureRow(text: 'Advanced personalization (themes, fonts)'),
                    const _FeatureRow(text: 'Offline access (cached schedule & materials metadata)'),
                    const _FeatureRow(text: 'Priority reminders & calendar digest'),
                    const _FeatureRow(text: 'UniGO Connect community add-ons'),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mockup: Upgrade action')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.6),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 6,
                          shadowColor: Colors.black26,
                        ),
                        child: const Text(
                          'Upgrade to Premium',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Cancel anytime • Mockup screen',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.45),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            const Text(
              'Free vs Premium (Quick Compare)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            GlassCardCustom(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    _CompareRow(feature: 'Course materials & announcements', free: true, premium: true),
                    _CompareRow(feature: 'Unified calendar & reminders', free: true, premium: true),
                    _CompareRow(feature: 'Smart Assistant', free: false, premium: true),
                    _CompareRow(feature: 'Offline access', free: false, premium: true),
                    _CompareRow(feature: 'Community hub add-ons', free: false, premium: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  final String label;
  const _PlanChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: Color(0xFF2E7D32)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String feature;
  final bool free;
  final bool premium;

  const _CompareRow({
    required this.feature,
    required this.free,
    required this.premium,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon(bool ok) => Icon(
          ok ? Icons.check : Icons.close,
          size: 18,
          color: ok ? const Color(0xFF2E7D32) : Colors.black38,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 32, child: Center(child: icon(free))),
          const SizedBox(width: 18),
          SizedBox(width: 32, child: Center(child: icon(premium))),
        ],
      ),
    );
  }
}
