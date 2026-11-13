import 'package:flutter_test/flutter_test.dart';
import 'package:sud_qollanma/core/constants/app_colors.dart';
import 'package:sud_qollanma/core/theme/app_tokens.dart';

void main() {
  test('AppColors eski nomlari Figma tokenlari bilan bir xil', () {
    for (final (legacy, token) in AppColors.tokenPairs) {
      expect(legacy, token);
    }
  });

  test('qorongʻi tokenlarda brend ustidagi matn foni bilan bir xil emas', () {
    for (final t in [AppTokens.light, AppTokens.dark]) {
      expect(t.textOnBrand, isNot(t.brandPrimary));
      expect(t.textPrimary, isNot(t.bgSurface));
      expect(t.heroFg, isNot(t.heroBg));
    }
  });
}
