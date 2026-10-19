import 'package:flutter/material.dart';
import '../demo_store.dart';
import '../widgets/shared.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.store});
  final DemoStore store;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Reveal(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      LoopMark(size: 38),
                      SizedBox(width: 12),
                      Text(
                        'Loop Chat',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 62),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            PersonAvatar(
                              name: 'Abdul Ahad',
                              color: Color(0xFFCFE5DE),
                              online: true,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your people.\nOne little loop.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _bubble(
                            context,
                            'Hey, good to see you!',
                            true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _bubble(context, 'Let’s catch up!', false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    'Stay close.\nKeep it simple.',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'A little space for your everyday conversations.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacement(loopRoute(HomeScreen(store: store))),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(child: Text('Open Loop Chat')),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      'OFFLINE DEMO  •  NO SIGN-IN NEEDED',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _bubble(BuildContext context, String text, bool mine) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    decoration: BoxDecoration(
      color: mine
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: mine ? Theme.of(context).colorScheme.onPrimary : null,
      ),
    ),
  );
}
