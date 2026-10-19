import 'package:flutter/material.dart';
import '../demo_store.dart';
import '../widgets/shared.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.store, required this.contact});
  final DemoStore store;
  final Contact contact;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    if (_input.text.trim().isEmpty) return;
    widget.store.send(widget.contact, _input.text);
    _input.clear();
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    _focus.requestFocus();
  }

  Future<void> _clear() async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear conversation?'),
        content: const Text(
          'This removes the messages in this demo conversation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (clear == true) widget.store.clearChat(widget.contact);
  }

  void _info() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PersonAvatar(
              name: widget.contact.name,
              color: widget.contact.color,
              radius: 42,
              online: widget.contact.online,
            ),
            const SizedBox(height: 16),
            Text(
              widget.contact.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(widget.contact.bio, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            const Text(
              'Sample contact • All messages stay in this session.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) {
      final c = widget.contact;
      final colors = Theme.of(context).colorScheme;
      final messages = c.messages.reversed.toList();
      final typing = widget.store.isTyping(c);
      return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: InkWell(
            onTap: _info,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                PersonAvatar(
                  name: c.name,
                  color: c.color,
                  online: c.online,
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        typing
                            ? 'Typing a demo reply…'
                            : c.online
                            ? 'Online in demo'
                            : 'Sample contact',
                        style: TextStyle(fontSize: 11, color: colors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              tooltip: 'Conversation options',
              onSelected: (value) {
                if (value == 'favorite') widget.store.toggleFavorite(c);
                if (value == 'clear') _clear();
                if (value == 'info') _info();
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'info', child: const Text('Contact info')),
                PopupMenuItem(
                  value: 'favorite',
                  child: Text(
                    c.favorite ? 'Remove favorite' : 'Add to favorites',
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Text('Clear conversation'),
                ),
              ],
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: .35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Offline demo · ${widget.store.simulateReplies ? 'Replies are simulated' : 'Auto replies are off'}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: messages.isEmpty
                      ? const EmptyState(
                          title: 'Start a little conversation',
                          message:
                              'Say hello. Messages only live in this session.',
                        )
                      : ListView.builder(
                          controller: _scroll,
                          reverse: true,
                          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return Reveal(
                              key: ValueKey(message.id),
                              child: Align(
                                alignment: message.mine
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.sizeOf(context).width < 500
                                        ? MediaQuery.sizeOf(context).width * .78
                                        : 500,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    12,
                                    14,
                                    9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: message.mine
                                        ? colors.primary
                                        : colors.surfaceContainerHighest
                                              .withValues(alpha: .6),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: Radius.circular(
                                        message.mine ? 20 : 5,
                                      ),
                                      bottomRight: Radius.circular(
                                        message.mine ? 5 : 20,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        message.text,
                                        style: TextStyle(
                                          fontSize: 15,
                                          height: 1.45,
                                          color: message.mine
                                              ? colors.onPrimary
                                              : colors.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            timeLabel(message.time),
                                            style: TextStyle(
                                              fontSize: 9,
                                              color:
                                                  (message.mine
                                                          ? colors.onPrimary
                                                          : colors
                                                                .onSurfaceVariant)
                                                      .withValues(alpha: .7),
                                            ),
                                          ),
                                          if (message.mine) ...[
                                            const SizedBox(width: 5),
                                            Icon(
                                              Icons.check_rounded,
                                              size: 12,
                                              color: colors.onPrimary
                                                  .withValues(alpha: .7),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: typing
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.more_horiz_rounded,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${c.name.split(' ').first} is typing…',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            key: const Key('message-input'),
                            controller: _input,
                            focusNode: _focus,
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            decoration: const InputDecoration(
                              hintText: 'Write a message…',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _input,
                          builder: (context, value, _) => IconButton.filled(
                            key: const Key('send-message'),
                            tooltip: 'Send message',
                            onPressed: value.text.trim().isEmpty ? null : _send,
                            style: IconButton.styleFrom(
                              minimumSize: const Size(52, 54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: const Icon(Icons.arrow_upward_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
