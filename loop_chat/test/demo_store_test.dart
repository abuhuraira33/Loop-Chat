import 'package:flutter_test/flutter_test.dart';
import 'package:loop_chat/demo_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'is_logged_in': true});
  });

  test(
    'local sends trim text, ignore blanks and become latest conversation',
    () {
      final store = DemoStore()..setSimulateReplies(false);
      addTearDown(store.dispose);
      final contact = store.contacts.last;
      store.send(contact, '  ');
      expect(contact.messages, isEmpty);
      store.send(contact, '  Hello Loop  ');
      expect(contact.messages.single.text, 'Hello Loop');
      expect(contact.messages.single.mine, isTrue);
      expect(store.chats.first, contact);
    },
  );

  testWidgets('simulated reply is cancelled by clear and reset', (
    tester,
  ) async {
    final store = DemoStore();
    addTearDown(store.dispose);
    final contact = store.contacts.first;
    store.send(contact, 'Hello');
    expect(store.isTyping(contact), isTrue);
    store.clearChat(contact);
    await tester.pump(const Duration(seconds: 2));
    expect(contact.messages, isEmpty);
    store.send(contact, 'Hello again');
    store.resetDemo();
    await tester.pump(const Duration(seconds: 2));
    expect(store.contacts.first.messages.length, 3);
    expect(store.isTyping(store.contacts.first), isFalse);
  });

  testWidgets('opening clears unread; closed chats gain unread on reply', (
    tester,
  ) async {
    final store = DemoStore();
    addTearDown(store.dispose);
    final contact = store.contacts.first;
    store.openChat(contact);
    expect(contact.unread, 0);
    store.send(contact, 'Hello');
    await tester.pump(const Duration(seconds: 2));
    expect(contact.unread, 0);
    store.closeChat(contact);
    store.send(contact, 'Later');
    await tester.pump(const Duration(seconds: 2));
    expect(contact.unread, 1);
  });

  test('reset restores favorites and messages but keeps profile and theme', () {
    final store = DemoStore();
    addTearDown(store.dispose);
    store.toggleFavorite(store.contacts.first);
    store.updateProfile('Ibad Rehman', 'Hello there');
    store.setDarkMode(true);
    store.resetDemo();
    expect(store.contacts.first.favorite, isTrue);
    expect(store.name, 'Ibad Rehman');
    expect(store.bio, 'Hello there');
    expect(store.darkMode, isTrue);
  });
}
