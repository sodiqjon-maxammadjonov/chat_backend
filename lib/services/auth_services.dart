import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../utils/jwt_helper.dart';
import '../utils/passwort_helper.dart';
import 'database_service.dart';

class AuthService {
  static final _uuid = Uuid();

  static Future<Map<String, dynamic>> register(UserRegistration userReg) async {
    try {
      // Check if user already exists
      final existingUser = await DatabaseService.getUserByUsernameOrEmail(
          userReg.username, userReg.email
      );

      if (existingUser != null) {
        return {
          'success': false,
          'message': 'Username yoki email allaqachon mavjud'
        };
      }

      // Hash password
      final hashedPassword = PasswordHelper.hashPassword(userReg.password);

      // Create user
      final user = User(
        id: _uuid.v4(),
        username: userReg.username,
        email: userReg.email,
        displayName: userReg.displayName ?? userReg.username,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      await DatabaseService.createUser(user, hashedPassword);

      // Generate JWT token
      final token = JwtHelper.generateToken(user.id);

      return {
        'success': true,
        'message': 'Muvaffaqiyatli ro\'yxatdan o\'tdi',
        'data': {
          'user': user.toJson(),
          'token': token
        }
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Ro\'yxatdan o\'tishda xatolik: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> login(UserLogin userLogin) async {
    try {
      // Find user
      final user = await DatabaseService.getUserByUsernameOrEmail(
          userLogin.usernameOrEmail, userLogin.usernameOrEmail
      );

      if (user == null) {
        return {
          'success': false,
          'message': 'Username yoki email topilmadi'
        };
      }

      // Check password
      final storedPassword = await DatabaseService.getUserPassword(user.id);
      if (!PasswordHelper.verifyPassword(userLogin.password, storedPassword)) {
        return {
          'success': false,
          'message': 'Noto\'g\'ri parol'
        };
      }

      // Update last seen
      await DatabaseService.updateUserLastSeen(user.id);

      // Generate JWT token
      final token = JwtHelper.generateToken(user.id);

      return {
        'success': true,
        'message': 'Muvaffaqiyatli kirildi',
        'data': {
          'user': user.toJson(),
          'token': token
        }
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Kirishda xatolik: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final user = await DatabaseService.getUserById(userId);

      if (user == null) {
        return {
          'success': false,
          'message': 'User topilmadi'
        };
      }

      return {
        'success': true,
        'data': {'user': user.toJson()}
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Profil olishda xatolik: $e'
      };
    }
  }
}