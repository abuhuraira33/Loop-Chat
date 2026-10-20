import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../demo_store.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});
  final DemoStore store;

  Future<void> _editProfile(BuildContext context) async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => _ProfileEditor(name: store.name, bio: store.bio),
    );
    if (result != null) store.updateProfile(result.$1, result.$2);
  }

  Future<void> _reset(BuildContext context) async {
    final reset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset demo conversations?'),
        content: const Text(
          'This replaces your session messages and favorites with the original sample conversations. Your profile and theme stay as they are.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (reset == true) store.resetDemo();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Your corner',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'A little more you.',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: .4),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            children: [
              PersonAvatar(
                name: store.name,
                color: const Color(0xFFCFE5DE),
                radius: 38,
              ),
              const SizedBox(height: 14),
              Text(
                store.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(store.bio, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _editProfile(context),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit profile'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'PREFERENCES',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.dark_mode_outlined),
          title: const Text('Dark appearance'),
          subtitle: const Text('A softer glow after hours.'),
          value: store.darkMode,
          onChanged: (val) {
            HapticFeedback.lightImpact();
            store.setDarkMode(val);
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THEME ACCENT',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final colorOption in AppThemeColor.values)
                    ChoiceChip(
                      avatar: CircleAvatar(
                        backgroundColor: colorOption.color,
                        radius: 8,
                      ),
                      label: Text(colorOption.label),
                      selected: store.accentColor == colorOption,
                      onSelected: (_) {
                        HapticFeedback.lightImpact();
                        store.setAccentColor(colorOption);
                      },
                      showCheckmark: false,
                    ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.auto_awesome_outlined),
          title: const Text('Demo replies'),
          subtitle: const Text('Show an automatic sample reply.'),
          value: store.simulateReplies,
          onChanged: (val) {
            HapticFeedback.lightImpact();
            store.setSimulateReplies(val);
          },
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.restart_alt_rounded),
          title: const Text('Reset conversations'),
          subtitle: const Text('Start fresh with sample messages.'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => _reset(context),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outlineVariant),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  LoopMark(size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Loop Chat',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Spacer(),
                  Text('v1.0', style: TextStyle(fontSize: 11)),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'A simple UI prototype, made for good conversations. All people and messages are sample data.',
                style: TextStyle(
                  height: 1.6,
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileEditor extends StatefulWidget {
  const _ProfileEditor({required this.name, required this.bio});
  final String name;
  final String bio;
  @override
  State<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<_ProfileEditor> {
  late final _name = TextEditingController(text: widget.name);
  late final _bio = TextEditingController(text: widget.bio);
  final _form = GlobalKey<FormState>();
  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Make it yours'),
    content: SizedBox(
      width: 340,
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('profile-name'),
                controller: _name,
                maxLength: 32,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter a name.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('profile-bio'),
                controller: _bio,
                maxLength: 100,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'About you'),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            HapticFeedback.lightImpact();
            Navigator.pop(context, (_name.text, _bio.text));
          }
        },
        child: const Text('Save'),
      ),
    ],
  );
}
