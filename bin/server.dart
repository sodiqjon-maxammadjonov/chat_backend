import 'package:chat_backend/server.dart';

void main(List<String> args) async {
  final server = Server();
  await server.start();

  // `ProcessSignal.sigint.watch().listen((_) async { ... });`  //serverni to'xtatganda resurslarni tozalash uchun

}