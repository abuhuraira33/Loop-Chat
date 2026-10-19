import 'package:flutter/material.dart';
import '../demo_store.dart';
import '../widgets/shared.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});
  final DemoStore store;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  int _filter = 0;
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _selectTab(int value) => setState(() {
    _tab = value;
    _query = '';
    _search.clear();
  });

  Future<void> _openChat(Contact contact) async {
    widget.store.openChat(contact);
    await Navigator.of(
      context,
    ).push(loopRoute(ChatScreen(store: widget.store, contact: contact)));
    widget.store.closeChat(contact);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) {
      final wide = MediaQuery.sizeOf(context).width >= 760;
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (wide)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: NavigationRail(
                        leading: const Padding(
                          padding: EdgeInsets.only(bottom: 36),
                          child: LoopMark(size: 44),
                        ),
                        selectedIndex: _tab,
                        onDestinationSelected: _selectTab,
                        labelType: NavigationRailLabelType.all,
                        backgroundColor: Colors.transparent,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.chat_bubble_outline_rounded),
                            selectedIcon: Icon(Icons.chat_bubble_rounded),
                            label: Text('Chats'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.people_outline_rounded),
                            selectedIcon: Icon(Icons.people_rounded),
                            label: Text('People'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.tune_rounded),
                            label: Text('You'),
                          ),
                        ],
                      ),
                    ),
                  if (wide) const VerticalDivider(width: 1),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: Duration(
                        milliseconds: MediaQuery.disableAnimationsOf(context)
                            ? 0
                            : 220,
                      ),
                      child: _tab == 2
                          ? SettingsScreen(
                              key: const ValueKey('settings'),
                              store: widget.store,
                            )
                          : _conversationList(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: _tab,
                onDestinationSelected: _selectTab,
                destinations: [
                  NavigationDestination(
                    icon: Badge(
                      isLabelVisible: widget.store.unreadCount > 0,
                      label: Text('${widget.store.unreadCount}'),
                      child: const Icon(Icons.chat_bubble_outline_rounded),
                    ),
                    selectedIcon: const Icon(Icons.chat_bubble_rounded),
                    label: 'Chats',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.people_outline_rounded),
                    selectedIcon: Icon(Icons.people_rounded),
                    label: 'People',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.tune_rounded),
                    label: 'You',
                  ),
                ],
              ),
        floatingActionButton: _tab == 0
            ? FloatingActionButton.extended(
                onPressed: () => _selectTab(1),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('New chat'),
              )
            : null,
      );
    },
  );

  Widget _conversationList(BuildContext context) {
    final people = _tab == 1;
    final source = people ? widget.store.contacts : widget.store.chats;
    final contacts = source
        .where(
          (c) =>
              c.name.toLowerCase().contains(_query.toLowerCase()) &&
              (people ||
                  _filter == 0 ||
                  (_filter == 1 && c.unread > 0) ||
                  (_filter == 2 && c.favorite)),
        )
        .toList();
    final colors = Theme.of(context).colorScheme;
    return Column(
      key: ValueKey(_tab),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          child: Row(
            children: [
              if (MediaQuery.sizeOf(context).width < 760) ...[
                const LoopMark(size: 38),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      people ? 'Your people' : 'Loop Chat',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      people
                          ? 'A good conversation starts here.'
                          : 'Good conversations, all together.',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Your profile',
                onPressed: () => _selectTab(2),
                icon: PersonAvatar(
                  name: widget.store.name,
                  color: const Color(0xFFCFE5DE),
                  radius: 19,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
          child: TextField(
            key: const Key('search'),
            controller: _search,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: people ? 'Search people' : 'Search conversations',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () => setState(() {
                        _search.clear();
                        _query = '';
                      }),
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),
        if (!people)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
            child: Wrap(
              spacing: 8,
              children: [
                for (var i = 0; i < 3; i++)
                  ChoiceChip(
                    label: Text(['All chats', 'Unread', 'Favorites'][i]),
                    selected: _filter == i,
                    onSelected: (_) => setState(() => _filter = i),
                    showCheckmark: false,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Row(
            children: [
              Text(
                people ? 'CONTACTS' : 'MESSAGES',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 10,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${contacts.length}',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: contacts.isEmpty
              ? EmptyState(
                  title: _query.isNotEmpty
                      ? 'No matches'
                      : 'You’re all caught up',
                  message: _query.isNotEmpty
                      ? 'Try another name.'
                      : 'Try All chats or start a new conversation.',
                  icon: Icons.chat_bubble_outline_rounded,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                  itemCount: contacts.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return Reveal(
                      key: ValueKey(
                        '${people ? 'person' : 'chat'}-${contact.id}',
                      ),
                      child: Material(
                        color: contact.unread > 0 && !people
                            ? colors.primaryContainer.withValues(alpha: .24)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          leading: PersonAvatar(
                            name: contact.name,
                            color: contact.color,
                            online: contact.online,
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  contact.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: contact.unread > 0
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (contact.favorite)
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: colors.primary,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              people
                                  ? contact.bio
                                  : '${contact.messages.last.mine ? 'You: ' : ''}${contact.messages.last.text}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          trailing: people
                              ? IconButton(
                                  tooltip: contact.favorite
                                      ? 'Remove favorite'
                                      : 'Add favorite',
                                  onPressed: () =>
                                      widget.store.toggleFavorite(contact),
                                  icon: Icon(
                                    contact.favorite
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: colors.primary,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      timeLabel(contact.messages.last.time),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (contact.unread > 0)
                                      Badge(
                                        label: Text('${contact.unread}'),
                                        backgroundColor: colors.primary,
                                      )
                                    else
                                      Icon(
                                        Icons.done_all_rounded,
                                        size: 16,
                                        color: colors.primary,
                                      ),
                                  ],
                                ),
                          onTap: () => _openChat(contact),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
