import 'dart:async';
import 'package:flutter/material.dart';

class Message {
  Message({
    required this.id,
    required this.text,
    required this.mine,
    DateTime? time,
  }) : time = time ?? DateTime.now();
  final String id;
  final String text;
  final bool mine;
  final DateTime time;
}

class Contact {
  Contact({
    required this.id,
    required this.name,
    required this.bio,
    required this.color,
    this.online = false,
    this.favorite = false,
  });
  final String id;
  final String name;
  final String bio;
  final Color color;
  final bool online;
  bool favorite;
  int unread = 0;
  final List<Message> messages = [];
}

/// All state is in memory. No authentication, storage, sockets, or network calls.
class DemoStore extends ChangeNotifier {
  DemoStore() {
    _seed();
  }

  bool darkMode = false;
  bool simulateReplies = true;
  String name = 'Abu Huraira';
  String bio = 'Keeping good conversations going.';
  final List<Contact> contacts = [];
  final Map<String, Timer> _replyTimers = {};
  int _sequence = 0;
  String? _activeChat;

  List<Contact> get chats {
    final result = contacts.where((c) => c.messages.isNotEmpty).toList();
    result.sort((a, b) => b.messages.last.time.compareTo(a.messages.last.time));
    return result;
  }

  int get unreadCount => contacts.fold(0, (sum, c) => sum + c.unread);
  bool isTyping(Contact contact) => _replyTimers.containsKey(contact.id);

  void _seed() {
    contacts.addAll([
      Contact(
        id: 'ahad',
        name: 'Abdul Ahad',
        bio: 'Building something good.',
        color: const Color(0xFFCFE5DE),
        online: true,
        favorite: true,
      ),
      Contact(
        id: 'sara',
        name: 'Sara Khan',
        bio: 'Design, coffee, repeat.',
        color: const Color(0xFFE8DDCF),
        online: true,
        favorite: true,
      ),
      Contact(
        id: 'hamza',
        name: 'Hamza Ali',
        bio: 'Always up for a match.',
        color: const Color(0xFFD9DEF0),
      ),
      Contact(
        id: 'ayesha',
        name: 'Ayesha Noor',
        bio: 'A little curious about everything.',
        color: const Color(0xFFF0DAD9),
      ),
      Contact(
        id: 'usman',
        name: 'Usman Ahmed',
        bio: 'One step at a time.',
        color: const Color(0xFFDFE9C8),
        online: true,
      ),
      Contact(
        id: 'zain',
        name: 'Zain Malik',
        bio: 'See you around.',
        color: const Color(0xFFDBE6EF),
      ),
    ]);
    final lines = [
      [
        'Hey! How is the new project going?',
        'Pretty well! Keeping the first version simple.',
        'Nice. Let’s catch up after class.',
      ],
      [
        'I tried a softer color palette for the screens.',
        'Love it. The layout feels much cleaner.',
        'I’ll bring the sketches tomorrow.',
      ],
      [
        'Nets this weekend?',
        'Yes! Saturday works for me.',
        'Perfect. See you at 5.',
      ],
      [
        'Did you finish the notes?',
        'Almost! Just the last topic left.',
        'Thanks, I’ll check them tonight.',
      ],
    ];
    for (var i = 0; i < lines.length; i++) {
      for (var j = 0; j < lines[i].length; j++) {
        contacts[i].messages.add(
          Message(
            id: 'seed-$i-$j',
            text: lines[i][j],
            mine: j == 1,
            time: DateTime.now().subtract(
              Duration(minutes: (i + 1) * 14 + (2 - j) * 3),
            ),
          ),
        );
      }
    }
    contacts[0].unread = 1;
    contacts[1].unread = 2;
  }

  void openChat(Contact contact) {
    _activeChat = contact.id;
    contact.unread = 0;
    notifyListeners();
  }

  void closeChat(Contact contact) {
    if (_activeChat == contact.id) {
      _activeChat = null;
    }
  }

  void send(Contact contact, String input) {
    final text = input.trim();
    if (text.isEmpty) return;
    contact.messages.add(
      Message(id: 'local-${_sequence++}', text: text, mine: true),
    );
    if (simulateReplies) {
      _replyTimers.remove(contact.id)?.cancel();
      _replyTimers[contact.id] = Timer(const Duration(milliseconds: 1400), () {
        _replyTimers.remove(contact.id);
        contact.messages.add(
          Message(
            id: 'local-${_sequence++}',
            text: 'Got it! Let’s keep in touch.',
            mine: false,
          ),
        );
        if (_activeChat != contact.id) contact.unread++;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void toggleFavorite(Contact contact) {
    contact.favorite = !contact.favorite;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    darkMode = value;
    notifyListeners();
  }

  void setSimulateReplies(bool value) {
    simulateReplies = value;
    if (!value) {
      _cancelTimers();
    }
    notifyListeners();
  }

  void updateProfile(String newName, String newBio) {
    name = newName.trim().isEmpty ? name : newName.trim();
    bio = newBio.trim();
    notifyListeners();
  }

  void clearChat(Contact contact) {
    _replyTimers.remove(contact.id)?.cancel();
    contact.messages.clear();
    contact.unread = 0;
    notifyListeners();
  }

  void resetDemo() {
    _cancelTimers();
    contacts.clear();
    _seed();
    notifyListeners();
  }

  void _cancelTimers() {
    for (final timer in _replyTimers.values) {
      timer.cancel();
    }
    _replyTimers.clear();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
