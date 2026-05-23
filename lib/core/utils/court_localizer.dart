import 'package:flutter/widgets.dart';
import 'package:sud_qollanma/core/data/uzbekistan_courts.dart';
import 'package:sud_qollanma/l10n/app_localizations.dart';

extension RegionInfoL10n on RegionInfo {
  String localizedName(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'uz') return name;

    if (locale == 'ru') {
      return _translateRegionToRu(name);
    }
    
    if (locale == 'en') {
      return _translateRegionToEn(name);
    }

    return name;
  }
}

extension CourtInfoL10n on CourtInfo {
  String localizedName(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'uz') return name;

    if (locale == 'ru') {
      return _translateCourtToRu(name);
    }
    
    if (locale == 'en') {
      return _translateCourtToEn(name);
    }

    return name;
  }
}

extension CourtTypeL10n on CourtType {
  String localizedDisplayName(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'uz') return displayName;

    if (locale == 'ru') {
      switch (this) {
        case CourtType.oliyVaViloyat: return 'Верховный и областные суды';
        case CourtType.jib: return 'Суды по уголовным делам';
        case CourtType.fib: return 'Суды по гражданским делам (FIB)';
        case CourtType.iqtisodiy: return 'Экономические суды';
      }
    }
    
    if (locale == 'en') {
      switch (this) {
        case CourtType.oliyVaViloyat: return 'Supreme and Regional Courts';
        case CourtType.jib: return 'Criminal Courts';
        case CourtType.fib: return 'Civil Courts (FIB)';
        case CourtType.iqtisodiy: return 'Economic Courts';
      }
    }

    return displayName;
  }
}

// ============================================================================
// TRANSLATION LOGIC
// ============================================================================

String _translateRegionToRu(String name) {
  if (name.contains("miqyosida")) return "На республиканском уровне";
  if (name.contains("Qoraqalpog'iston")) return "Республика Каракалпакстан";
  if (name.contains("Toshkent shahri")) return "Город Ташкент";
  
  String base = name.replaceAll(" viloyati", "");
  return "${_getRuAdjective(base)} область";
}

String _translateRegionToEn(String name) {
  if (name.contains("miqyosida")) return "Republic Level";
  if (name.contains("Qoraqalpog'iston")) return "Republic of Karakalpakstan";
  if (name.contains("Toshkent shahri")) return "Tashkent City";
  
  String base = name.replaceAll(" viloyati", "");
  return "$base Region";
}

String _translateCourtToRu(String name) {
  if (name.contains("Oliy sud")) return "Верховный суд Республики Узбекистан";
  if (name.contains("Qoraqalpog'iston Respublikasi sudi")) return "Суд Республики Каракалпакстан";

  // Types of courts
  if (name.contains("shahar sudi")) {
    String base = name.replaceAll(" shahar sudi", "");
    return "${_getRuAdjective(base)} городской суд по уголовным делам";
  }
  if (name.contains("tuman sudi")) {
    String base = name.replaceAll(" tuman sudi", "");
    return "${_getRuAdjective(base)} районный суд по уголовным делам";
  }
  if (name.contains("tumanlararo FIB sudi")) {
    String base = name.replaceAll(" tumanlararo FIB sudi", "");
    return "${_getRuAdjective(base)} межрайонный суд по гражданским делам";
  }
  if (name.contains("tuman FIB sudi")) {
    String base = name.replaceAll(" tuman FIB sudi", "");
    return "${_getRuAdjective(base)} районный суд по гражданским делам";
  }
  if (name.contains("tumanlararo iqtisodiy sudi")) {
    String base = name.replaceAll(" tumanlararo iqtisodiy sudi", "");
    return "${_getRuAdjective(base)} межрайонный экономический суд";
  }
  if (name.contains("viloyat sudi")) {
    String base = name.replaceAll(" viloyat sudi", "");
    return "${_getRuAdjective(base)} областной суд";
  }

  return name;
}

String _translateCourtToEn(String name) {
  if (name.contains("Oliy sud")) return "Supreme Court of the Republic of Uzbekistan";
  if (name.contains("Qoraqalpog'iston Respublikasi sudi")) return "Court of the Republic of Karakalpakstan";

  if (name.contains("shahar sudi")) {
    String base = name.replaceAll(" shahar sudi", "");
    return "$base City Criminal Court";
  }
  if (name.contains("tuman sudi")) {
    String base = name.replaceAll(" tuman sudi", "");
    return "$base District Criminal Court";
  }
  if (name.contains("tumanlararo FIB sudi")) {
    String base = name.replaceAll(" tumanlararo FIB sudi", "");
    return "$base Interdistrict Civil Court";
  }
  if (name.contains("tuman FIB sudi")) {
    String base = name.replaceAll(" tuman FIB sudi", "");
    return "$base District Civil Court";
  }
  if (name.contains("tumanlararo iqtisodiy sudi")) {
    String base = name.replaceAll(" tumanlararo iqtisodiy sudi", "");
    return "$base Interdistrict Economic Court";
  }
  if (name.contains("viloyat sudi")) {
    String base = name.replaceAll(" viloyat sudi", "");
    return "$base Regional Court";
  }

  return name;
}

// Morphological helper for Russian
String _getRuAdjective(String base) {
  const map = {
    "Andijon": "Андижанский",
    "Buxoro": "Бухарский",
    "Jizzax": "Джизакский",
    "Qashqadaryo": "Кашкадарьинский",
    "Navoiy": "Навоийский",
    "Namangan": "Наманганский",
    "Samarqand": "Самаркандский",
    "Sirdaryo": "Сырдарьинский",
    "Surxondaryo": "Сурхандарьинский",
    "Toshkent": "Ташкентский",
    "Farg'ona": "Ферганский",
    "Xorazm": "Хорезмский",
    
    // Some common districts
    "Mirzo Ulug'bek": "Мирзо-Улугбекский",
    "Yunusobod": "Юнусабадский",
    "Yakkasaroy": "Яккасарайский",
    "Mirobod": "Мирабадский",
    "Uchtepa": "Учтепинский",
    "Chilonzor": "Чиланзарский",
    "Olmazor": "Алмазарский",
    "Shayxontohur": "Шайхантахурский",
    "Sirg'ali": "Сергелийский",
    "Yashnobod": "Яшнабадский",
    "Bektemir": "Бектемирский",
    "Yangihayot": "Янгихаётский",

    // Default translation mapping if available
    "Nukus": "Нукусский",
    "Qarshi": "Каршинский",
    "Guliston": "Гулистанский",
    "Urganch": "Ургенчский",
    "Marg'ilon": "Маргиланский",
  };

  if (map.containsKey(base)) return map[base]!;
  
  // Basic fallback to transliteration + suffix if not explicitly mapped
  String tr = base
      .replaceAll("o'", "у")
      .replaceAll("g'", "г")
      .replaceAll("ch", "ч")
      .replaceAll("sh", "ш")
      .replaceAll("q", "к")
      .replaceAll("y", "й")
      .replaceAll("x", "х");
      
  return "$trский";
}
