import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AES-256 shifrlash va qurilmaning xavfsiz chipida kalit saqlashni
/// boshqaruvchi yordamchi klass.
///
/// ZRU-547 27-1-moddasiga muvofiq nozik sud ma'lumotlarini (PII)
/// qurilmada himoyalash maqsadida ishlatiladi.
class EncryptionHelper {
  static EncryptionHelper? _instance;

  EncryptionHelper._internal();

  static EncryptionHelper get instance {
    _instance ??= EncryptionHelper._internal();
    return _instance!;
  }

  static const _keyAlias = 'sud_qollanma_aes_key_v1';
  static const _ivAlias = 'sud_qollanma_aes_iv_v1';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  enc.Encrypter? _encrypter;
  enc.IV? _iv;
  bool _isInitialized = false;

  /// Shifrlash xizmatini ishga tushiradi.
  /// Qurilmada kalit bo'lmasa avtomatik generatsiya qiladi va xavfsiz saqlaydi.
  /// [DriftDatabaseService.init] dan keyin chaqirilishi lozim.
  Future<void> init() async {
    if (_isInitialized) return;

    // AES kalitini yuklab olish yoki yangi yaratish
    String? base64Key = await _secureStorage.read(key: _keyAlias);
    if (base64Key == null) {
      final newKey = enc.Key.fromSecureRandom(32); // 256-bit
      base64Key = newKey.base64;
      await _secureStorage.write(key: _keyAlias, value: base64Key);
    }

    // IV ni yuklab olish yoki yangi yaratish
    String? base64Iv = await _secureStorage.read(key: _ivAlias);
    if (base64Iv == null) {
      final newIv = enc.IV.fromSecureRandom(16); // 128-bit
      base64Iv = newIv.base64;
      await _secureStorage.write(key: _ivAlias, value: base64Iv);
    }

    final key = enc.Key.fromBase64(base64Key);
    _iv = enc.IV.fromBase64(base64Iv);
    _encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    _isInitialized = true;
  }

  /// Berilgan matn [plainText] ni AES-256 CBC rejimida shifrlaydi.
  /// Natija Base64 formatidagi shifrlangan matn.
  String encrypt(String plainText) {
    _assertInitialized();
    return _encrypter!.encrypt(plainText, iv: _iv!).base64;
  }

  /// Shifrlangan Base64 matn [cipherText] ni qaytadan asl ko'rinimiga keltiradi.
  String decrypt(String cipherText) {
    _assertInitialized();
    return _encrypter!.decrypt(enc.Encrypted.fromBase64(cipherText), iv: _iv!);
  }

  void _assertInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'EncryptionHelper hali ishga tushirilmagan. '
        'Avval EncryptionHelper.instance.init() ni chaqiring.',
      );
    }
  }
}
