import 'package:flutter/material.dart';

import '../widgets/glass_appbar.dart';
import '../widgets/glass_card_custom.dart';
import '../widgets/glass_text_field.dart';

class UniGoConnectPage extends StatelessWidget {
  const UniGoConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlassAppBar(title: 'UniGO Connect'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Community Hub',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Connect with students, join groups, and share updates.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 14),

            const GlassTextField(
              hint: 'Search posts, groups, or people...',
              icon: Icons.search,
            ),
            const SizedBox(height: 10),

            GlassCardCustom(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.black.withValues(alpha: 0.08),
                      child: const Icon(Icons.person, color: Colors.black87),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Your Community Profile',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Customize your profile • Join groups • Post updates',
                            style: TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black45),
                  ],
                ),
              ),
            ),

            Row(
              children: const [
                Expanded(
                  child: _QuickTile(
                    icon: Icons.groups_rounded,
                    title: 'Groups',
                    subtitle: 'Find your people',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _QuickTile(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Trending',
                    subtitle: 'Hot topics today',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Text(
              'Feed',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),

            const _PostCard(
              name: 'Sara • Computer Science',
              time: '2h',
              text:
                  'Anyone has tips for the Database final? I’m organizing a quick study group tonight.',
              tags: ['#StudyGroup', '#DB'],
            ),
            const _PostCard(
              name: 'Omar • IT',
              time: '5h',
              text:
                  'Found a great resource for Flutter state management. Sharing it here for anyone working on mobile projects.',
              tags: ['#Flutter', '#MobileDev'],
            ),
            const _PostCard(
              name: 'UniGO Admin',
              time: '1d',
              text:
                  'New workshop this week: “CV & Interview Prep”. Check the calendar for details and register early.',
              tags: ['#Workshop', '#Career'],
              isOfficial: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _QuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCardCustom(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mockup: Open $title')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.06),
                child: Icon(icon, size: 18, color: Colors.black87),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String name;
  final String time;
  final String text;
  final List<String> tags;
  final bool isOfficial;

  const _PostCard({
    required this.name,
    required this.time,
    required this.text,
    required this.tags,
    this.isOfficial = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCardCustom(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.black.withValues(alpha: 0.06),
                  child: Icon(
                    isOfficial ? Icons.verified : Icons.person,
                    size: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map(
                    (t) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _Action(icon: Icons.thumb_up_alt_outlined, label: 'Like'),
                const SizedBox(width: 10),
                _Action(icon: Icons.mode_comment_outlined, label: 'Comment'),
                const SizedBox(width: 10),
                _Action(icon: Icons.share_outlined, label: 'Share'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border, color: Colors.black54),
                  onPressed: () {},
                  tooltip: 'Save',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Action({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: Colors.black54),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.black.withValues(alpha: 0.04),
      ),
    );
  }
}
