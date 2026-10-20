import 'package:flutter/material.dart';
import '../theme.dart';

class LoopMark extends StatelessWidget {
  const LoopMark({super.key, this.size = 60});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(size * .32),
    ),
    child: Icon(
      Icons.all_inclusive_rounded,
      color: Theme.of(context).colorScheme.onPrimary,
      size: size * .65,
    ),
  );
}

class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.name,
    required this.color,
    this.online = false,
    this.radius = 26,
  });
  final String name;
  final Color color;
  final bool online;
  final double radius;
  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0])
        .join();
    final primary = Theme.of(context).colorScheme.primary;
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: color,
          child: Text(
            initials.toUpperCase(),
            style: TextStyle(
              color: LoopTheme.ink,
              fontWeight: FontWeight.w700,
              fontSize: radius * .6,
            ),
          ),
        ),
        if (online)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: reduced ? 0 : 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

Route<T> loopRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 300),
  reverseTransitionDuration: const Duration(milliseconds: 240),
  pageBuilder: (context, animation, secondaryAnimation) => page,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(.06, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  },
);

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.forum_outlined,
  });
  final String title;
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

String timeLabel(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);
  final clock =
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  if (diff.inSeconds < 60) {
    return 'Just now';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  } else if (now.year == time.year &&
      now.month == time.month &&
      now.day == time.day) {
    return clock;
  } else if (now.year == time.year &&
      now.month == time.month &&
      now.day - time.day == 1) {
    return 'Yesterday $clock';
  } else {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[time.month - 1]} ${time.day}, $clock';
  }
}
