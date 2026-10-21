import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'mine': mine,
    'time': time.toIso8601String(),
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as String,
    text: json['text'] as String,
    mine: json['mine'] as bool,
    time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
  );
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

/// All state managed locally with SharedPreferences persistence.
class DemoStore extends ChangeNotifier {
  DemoStore() {
    _seed();
    _loadFromPrefs();
  }

  bool isLoggedIn = false;
  String phoneNumber = '';
  String countryCode = '';

  ThemeMode themeMode = ThemeMode.system;
  AppThemeColor accentColor = AppThemeColor.teal;
  bool simulateReplies = true;
  String name = 'Abu Huraira';
  String bio = 'Keeping good conversations going.';
  final List<Contact> contacts = [];
  final Map<String, Timer> _replyTimers = {};
  int _sequence = 0;
  String? _activeChat;

  bool get darkMode => themeMode == ThemeMode.dark;

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
        id: 'abdul',
        name: 'Abdul Ahad',
        bio: 'Building something good.',
        color: const Color(0xFFCFE5DE),
        online: true,
        favorite: true,
      ),
      Contact(
        id: 'Amna',
        name: 'Amna',
        bio: 'Chill',
        color: const Color(0xFFE8DDCF),
        online: true,
        favorite: true,
      ),
      Contact(
        id: 'hamza',
        name: 'Hamza ',
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
        'Nice. Let’s catch up after class.',
        'Sounds good! See you then.',
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

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      phoneNumber = prefs.getString('phone_number') ?? '';
      countryCode = prefs.getString('country_code') ?? '';

      final modeIndex = prefs.getInt('theme_mode');
      if (modeIndex != null &&
          modeIndex >= 0 &&
          modeIndex < ThemeMode.values.length) {
        themeMode = ThemeMode.values[modeIndex];
      }
      final accentIndex = prefs.getInt('accent_color');
      if (accentIndex != null &&
          accentIndex >= 0 &&
          accentIndex < AppThemeColor.values.length) {
        accentColor = AppThemeColor.values[accentIndex];
      }
      simulateReplies = prefs.getBool('simulate_replies') ?? simulateReplies;
      name = prefs.getString('user_name') ?? name;
      bio = prefs.getString('user_bio') ?? bio;

      final favorites = prefs.getStringList('favorites');
      if (favorites != null) {
        for (final c in contacts) {
          c.favorite = favorites.contains(c.id);
        }
      }

      for (final c in contacts) {
        final messagesJson = prefs.getString('messages_${c.id}');
        if (messagesJson != null) {
          final List<dynamic> decoded = jsonDecode(messagesJson);
          c.messages.clear();
          c.messages.addAll(
            decoded.map(
              (item) => Message.fromJson(item as Map<String, dynamic>),
            ),
          );
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', isLoggedIn);
      await prefs.setString('phone_number', phoneNumber);
      await prefs.setString('country_code', countryCode);
      await prefs.setInt('theme_mode', themeMode.index);
      await prefs.setInt('accent_color', accentColor.index);
      await prefs.setBool('simulate_replies', simulateReplies);
      await prefs.setString('user_name', name);
      await prefs.setString('user_bio', bio);
      await prefs.setStringList(
        'favorites',
        contacts.where((c) => c.favorite).map((c) => c.id).toList(),
      );
      for (final c in contacts) {
        final encoded = jsonEncode(c.messages.map((m) => m.toJson()).toList());
        await prefs.setString('messages_${c.id}', encoded);
      }
    } catch (_) {}
  }

  void login(String number, String code) {
    isLoggedIn = true;
    phoneNumber = number;
    countryCode = code;
    _saveToPrefs();
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    phoneNumber = '';
    countryCode = '';
    _saveToPrefs();
    notifyListeners();
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
    _saveToPrefs();
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
        _saveToPrefs();
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void deleteMessage(Contact contact, String messageId) {
    contact.messages.removeWhere((m) => m.id == messageId);
    _saveToPrefs();
    notifyListeners();
  }

  void toggleFavorite(Contact contact) {
    contact.favorite = !contact.favorite;
    _saveToPrefs();
    notifyListeners();
  }

  void setDarkMode(bool value) {
    setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    _saveToPrefs();
    notifyListeners();
  }

  void setAccentColor(AppThemeColor color) {
    accentColor = color;
    _saveToPrefs();
    notifyListeners();
  }

  void setSimulateReplies(bool value) {
    simulateReplies = value;
    if (!value) {
      _cancelTimers();
    }
    _saveToPrefs();
    notifyListeners();
  }

  void updateProfile(String newName, String newBio) {
    name = newName.trim().isEmpty ? name : newName.trim();
    bio = newBio.trim();
    _saveToPrefs();
    notifyListeners();
  }

  void clearChat(Contact contact) {
    _replyTimers.remove(contact.id)?.cancel();
    contact.messages.clear();
    contact.unread = 0;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> resetDemo() async {
    _cancelTimers();
    contacts.clear();
    _seed();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('favorites');
      for (final c in contacts) {
        await prefs.remove('messages_${c.id}');
      }
    } catch (_) {}
    _saveToPrefs();
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
