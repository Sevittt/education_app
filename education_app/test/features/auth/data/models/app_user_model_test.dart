import 'package:flutter_test/flutter_test.dart';
import 'package:sud_qollanma/features/auth/data/models/app_user_model.dart';
import 'package:sud_qollanma/features/auth/domain/entities/app_user.dart';

void main() {
  group('AppUserModel', () {
    const tUser = AppUserModel(
      id: '123',
      name: 'Test User',
      email: 'test@example.com',
      username: 'testuser',
      role: UserRole.xodim,
      xp: 100,
      level: 'Boshlang\'ich',
    );

    test('should be a subclass of AppUser entity', () async {
      expect(tUser, isA<AppUser>());
    });

    group('fromMap', () {
      test('should return a valid model from JSON map', () async {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'name': 'Test User',
          'email': 'test@example.com',
          'username': 'testuser',
          'role': 'xodim',
          'xp': 100,
          'level': 'Boshlang\'ich',
        };
        // act
        final result = AppUserModel.fromMap(jsonMap, '123');
        // assert
        expect(result.id, tUser.id);
        expect(result.name, tUser.name);
        expect(result.role, tUser.role);
      });

      test('should handle missing fields with defaults', () async {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'name': 'Test User',
        };
        // act
        final result = AppUserModel.fromMap(jsonMap, '123');
        // assert
        expect(result.role, UserRole.xodim); // Default role
        expect(result.xp, 0); // Default XP
      });

      test('should parse legacy roles correctly', () async {
        // arrange
        final Map<String, dynamic> jsonMapTeacher = {
          'name': 'Teacher User',
          'role': 'teacher',
        };
        // act
        final result = AppUserModel.fromMap(jsonMapTeacher, '123');
        // assert
        expect(result.role, UserRole.ekspert);
      });
    });

    group('toMap', () {
      test('should return a JSON map containing proper data', () async {
        // act
        final result = tUser.toMap();
        // assert
        expect(result['id'], '123');
        expect(result['name'], 'Test User');
        expect(result['role'], 'xodim');
      });
    });
  });
}
