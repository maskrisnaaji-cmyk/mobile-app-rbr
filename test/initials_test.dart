import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/services/user_session.dart';

void main() {
  group('UserSession parseInitials Tests', () {
    test('single word username parses first 2 uppercase characters (e.g. n4yaaa -> N4)', () {
      expect(UserSession.parseInitials('n4yaaa'), equals('N4'));
      expect(UserSession.parseInitials('admin'), equals('AD'));
      expect(UserSession.parseInitials('n4'), equals('N4'));
      expect(UserSession.parseInitials('x'), equals('X'));
    });

    test('multi-word names parse first char of each word', () {
      expect(UserSession.parseInitials('Pengguna Google'), equals('PG'));
      expect(UserSession.parseInitials('Ratna Anindita'), equals('RA'));
      expect(UserSession.parseInitials('Aris Widiatmoko'), equals('AW'));
      expect(UserSession.parseInitials('John Doe'), equals('JD'));
    });

    test('handles empty or null with fallback', () {
      expect(UserSession.parseInitials(''), equals('RA'));
      expect(UserSession.parseInitials(null), equals('RA'));
      expect(UserSession.parseInitials('   '), equals('RA'));
    });
  });
}

