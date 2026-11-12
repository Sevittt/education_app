import 'package:cloud_functions/cloud_functions.dart';

/// Telegram'ni profilga ulash: server bir martalik kod va bot havolasini beradi
/// (Cloud Functions: createTelegramLinkCode). Kodni bot iste'mol qiladi va
/// users/{uid}.telegram_id ni yozadi.
class TelegramLinkRemoteDataSource {
  final FirebaseFunctions _functions;

  TelegramLinkRemoteDataSource({FirebaseFunctions? functions})
      : _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<Uri> createLinkUrl() async {
    final result = await _functions
        .httpsCallable('createTelegramLinkCode')
        .call<Map<String, dynamic>>();
    return Uri.parse(result.data['url'] as String);
  }
}
