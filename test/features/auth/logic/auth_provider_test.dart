import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:blog_forum_app/features/auth/data/auth_repository.dart';
import 'package:blog_forum_app/features/auth/logic/auth_provider.dart';
import 'package:blog_forum_app/features/profile/data/profile_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class FakeUser extends Fake implements User {
  @override
  String get id => 'test-user-id';
}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockProfileRepository mockProfileRepository;
  late AuthProvider authProvider;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockProfileRepository = MockProfileRepository();

    when(() => mockAuthRepository.currentUser).thenReturn(null);

    authProvider = AuthProvider(
      authRepository: mockAuthRepository,
      profileRepository: mockProfileRepository,
    );
  });

  group('login', () {
    test('sets currentUser and clears error on success', () async {
      final fakeUser = FakeUser();

      when(() => mockAuthRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {});
      when(() => mockAuthRepository.currentUser).thenReturn(fakeUser);

      await authProvider.login(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.errorMessage, isNull);
      expect(authProvider.isLoading, isFalse);
    });

    test('sets errorMessage and keeps currentUser null on failure', () async {
      when(() => mockAuthRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Invalid credentials'));

      await authProvider.login(
        email: 'wrong@example.com',
        password: 'wrongpass',
      );

      expect(authProvider.currentUser, isNull);
      expect(authProvider.errorMessage, isNotNull);
      expect(authProvider.isLoading, isFalse);
    });
  });

  group('logout', () {
    test('clears currentUser', () async {
      when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

      await authProvider.logout();

      expect(authProvider.currentUser, isNull);
    });
  });
}