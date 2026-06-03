import 'package:flutter/material.dart';

import '../widgets/glass_appbar.dart';
import '../widgets/glass_card_custom.dart';
import '../widgets/stat_card.dart';
import '../widgets/folder_card.dart';

class RewardsPointsPage extends StatelessWidget {
  const RewardsPointsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const int points = 1280;
    const int nextTierAt = 2000;
    final double progress = (points / nextTierAt).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlassAppBar(title: 'Rewards'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reward Points',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Earn points by staying active and on track.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),

            GlassCardCustom(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Points Balance',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            points.toString(),
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: const [
                              _Pill(label: 'Silver Member'),
                              SizedBox(width: 8),
                              _Pill(label: 'Top 12%'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 92,
                      height: 92,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.black12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF6C63FF),
                            ),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    const Text(
                      'Next Tier Progress',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.black12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$points / $nextTierAt points to reach Gold',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                StatCard(value: '12', label: 'Weekly Streak'),
                StatCard(value: '3', label: 'Badges'),
                StatCard(value: '450', label: 'Redeemed'),
              ],
            ),

            const SizedBox(height: 18),
            const Text(
              'Redeem Rewards',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            Row(
              children: const [
                Expanded(
                  child: FolderCard(
                    title: 'Campus Store',
                    assetPath: 'assets/DarkYellow.png',
                    isListView: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: FolderCard(
                    title: 'Cafeteria',
                    assetPath: 'assets/DarkGreen.png',
                    isListView: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            const _ActivityTile(
              icon: Icons.check_circle,
              title: 'Attended a workshop',
              subtitle: '+80 points • Today',
            ),
            const _ActivityTile(
              icon: Icons.calendar_month,
              title: 'Submitted assignment on time',
              subtitle: '+40 points • Yesterday',
            ),
            const _ActivityTile(
              icon: Icons.school,
              title: 'Completed semester milestone',
              subtitle: '+120 points • 3 days ago',
            ),
            const _ActivityTile(
              icon: Icons.redeem,
              title: 'Redeemed cafeteria voucher',
              subtitle: '-150 points • 1 week ago',
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCardCustom(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.06),
          child: Icon(icon, color: Colors.black87, size: 18),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
        trailing: const Icon(Icons.chevron_right, color: Colors.black45),
        onTap: () {},
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill({required this.label});

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
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
