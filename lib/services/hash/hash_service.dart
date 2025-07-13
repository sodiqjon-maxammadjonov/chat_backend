import 'package:crypt/crypt.dart';

class HashService {
  String hash(String password) {
    return Crypt.sha256(password).toString();
  }

  bool verify(String password, String hash) {
    return Crypt(hash).match(password);
  }
}