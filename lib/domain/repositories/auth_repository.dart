import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';

abstract class AuthRepository {

  /// Foydalanuvchini ro'yxatdan o'tkazish.
  ///
  /// Muvaffaqiyatli bo'lsa, [Right] ichida foydalanuvchi `ID`sini (String) qaytaradi.
  /// Xatolik bo'lsa, [Left] ichida [Failure] ob'ektini qaytaradi.
  ///
  /// [dartz] paketining `Either` tipi bizga ikki turdagi natijani (`xatolik` yoki `muvaffaqiyat`)
  /// bitta funksiyadan chiroyli qaytarishga yordam beradi.
  Future<Either<Failure, String>> register({
    required String email,
    required String username,
    required String password,
  });

// Hozircha faqat bittasini yozamiz. Keyinroq 'login', 'logout' kabi
// boshqa funksiyalarni shu yerga qo'shamiz.
// Future<Either<Failure, User>> login(String email, String password);
}