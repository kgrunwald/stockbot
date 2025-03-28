import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final storage = new FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  Future<String> read(String key) {
    return storage.read(key: key);
  }
}
