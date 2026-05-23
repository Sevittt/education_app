// AUTO-GENERATED from sud-ro'yxat.xlsx — DO NOT EDIT MANUALLY
// 15 hudud, 303+ sud O'zbekiston bo'yicha

enum CourtType {
  /// Oliy sud, Viloyat sudlari, Qoraqalpog'iston Respublikasi sudi
  oliyVaViloyat,
  /// Jinoyat ishlari bo'yicha tuman va shahar sudlari
  jib,
  /// Fuqarolik ishlari bo'yicha tumanlararo sudlar
  fib,
  /// Tumanlararo iqtisodiy sudlar
  iqtisodiy,
}

extension CourtTypeExtension on CourtType {
  String get displayName {
    switch (this) {
      case CourtType.oliyVaViloyat: return 'Oliy va Viloyat sudlari';
      case CourtType.jib: return 'Jinoyat ishlari bo\'yicha sudlar (JIB)';
      case CourtType.fib: return 'Fuqarolik ishlari bo\'yicha sudlar (FIB)';
      case CourtType.iqtisodiy: return 'Iqtisodiy sudlar';
    }
  }

  String get icon {
    switch (this) {
      case CourtType.oliyVaViloyat: return '🏛️';
      case CourtType.jib: return '⚖️';
      case CourtType.fib: return '📋';
      case CourtType.iqtisodiy: return '💼';
    }
  }

  String get id {
    switch (this) {
      case CourtType.oliyVaViloyat: return 'oliyVaViloyat';
      case CourtType.jib: return 'jib';
      case CourtType.fib: return 'fib';
      case CourtType.iqtisodiy: return 'iqtisodiy';
    }
  }

  static CourtType fromId(String id) {
    return CourtType.values.firstWhere(
      (t) => t.id == id,
      orElse: () => CourtType.jib,
    );
  }
}

class CourtInfo {
  final String id;
  final String name;
  final String regionId;
  final CourtType type;

  const CourtInfo({
    required this.id,
    required this.name,
    required this.regionId,
    required this.type,
  });
}

class RegionInfo {
  final String id;
  final String name;
  final List<CourtInfo> courts;

  const RegionInfo({
    required this.id,
    required this.name,
    required this.courts,
  });

  List<CourtType> get availableTypes {
    final types = <CourtType>{};
    for (final c in courts) {
      types.add(c.type);
    }
    return CourtType.values.where((t) => types.contains(t)).toList();
  }

  List<CourtInfo> courtsByType(CourtType type) =>
      courts.where((c) => c.type == type).toList();
}

class UzbekistanCourts {
  static const List<RegionInfo> regions = [
    RegionInfo(
      id: 'respublika_miqyosida',
      name: 'Respublika miqyosida',
      courts: [
        CourtInfo(
          id: 'oliy_sud',
          name: 'Oliy sud (JIB, FIB, Iqtisodiy va Ma\'muriy ishlar bo\'yicha sudlov hay\'atlari mavjud)',
          regionId: 'respublika_miqyosida',
          type: CourtType.oliyVaViloyat,
        ),
      ],
    ),
    RegionInfo(
      id: 'qoraqalpogiston_respublikasi',
      name: 'Qoraqalpog\'iston Respublikasi',
      courts: [
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_viloyat_sudi',
          name: 'Qoraqalpog\'iston Respublikasi sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.oliyVaViloyat,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_nukus_shahar_sudi',
          name: 'Nukus shahar sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_amudaryo_tuman_sudi',
          name: 'Amudaryo tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_beruniy_tuman_sudi',
          name: 'Beruniy tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_kegeyli_tuman_sudi',
          name: 'Kegeyli tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_qonlikol_tuman_sudi',
          name: 'Qonliko\'l tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_qoraozak_tuman_sudi',
          name: 'Qorao\'zak tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_qongirot_tuman_sudi',
          name: 'Qo\'ng\'irot tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_moynoq_tuman_sudi',
          name: 'Mo\'ynoq tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_nukus_tuman_sudi',
          name: 'Nukus tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_taxtakopir_tuman_sudi',
          name: 'Taxtako\'pir tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_tortkol_tuman_sudi',
          name: 'To\'rtko\'l tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_xojayli_tuman_sudi',
          name: 'Xo\'jayli tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_chimboy_tuman_sudi',
          name: 'Chimboy tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_shumanay_tuman_sudi',
          name: 'Shumanay tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_ellikqala_tuman_sudi',
          name: 'Ellikqal\'a tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_taxiatosh_tuman_sudi',
          name: 'Taxiatosh tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_bozatov_tuman_sudi',
          name: 'Bo\'zatov tuman sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_fib_tla_beruniy',
          name: 'Beruniy tumanlararo FIB sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_fib_tla_qongirot',
          name: 'Qo\'ng\'irot tumanlararo FIB sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_fib_tla_nukus',
          name: 'Nukus tumanlararo FIB sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_fib_tla_chimboy',
          name: 'Chimboy tumanlararo FIB sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_fib_t_amudaryo',
          name: 'Amudaryo tuman FIB sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'qoraqalpogiston_respublikasi_iqtisodiy_sudi',
          name: 'Nukus tumanlararo iqtisodiy sudi',
          regionId: 'qoraqalpogiston_respublikasi',
          type: CourtType.iqtisodiy,
        ),
      ],
    ),
    RegionInfo(
      id: 'andijon_viloyati',
      name: 'Andijon viloyati',
      courts: [
        CourtInfo(
          id: 'andijon_viloyati_viloyat_sudi',
          name: 'Andijon viloyat sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.oliyVaViloyat,
        ),
        CourtInfo(
          id: 'andijon_viloyati_andijon_shahar_sudi',
          name: 'Andijon shahar sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_xonobod_shahar_sudi',
          name: 'Xonobod shahar sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_andijon_tuman_sudi',
          name: 'Andijon tuman sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_asaka_tuman_sudi',
          name: 'Asaka tuman sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_baliqchi_tuman_sudi',
          name: 'Baliqchi tuman sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_boston_tuman_sudi',
          name: 'Bo\'ston tuman sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_buloqboshi_tuman_sudi',
          name: 'Buloqboshi tuman sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_jalaquduq_tuman_sudi',
          name: 'Jalaquduq tuman sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_izboskan_tuman_sudi',
          name: 'Izboskan tuman sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_qorgontepa_tuman_sudi',
          name: 'Qo\'rg\'ontepa tuman sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_marhamat_tuman_sudi',
          name: 'Marhamat tuman sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_oltinkol_tuman_sudi',
          name: 'Oltinko\'l tuman sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_paxtaobod_tuman_sudi',
          name: 'Paxtaobod tuman sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_ulugnor_tuman_sudi',
          name: 'Ulug\'nor tuman sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_xojaobod_tuman_sudi',
          name: 'Xo\'jaobod tuman sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_shaxrixon_tuman_sudi',
          name: 'Shaxrixon tuman sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_fib_tla_andijon',
          name: 'Andijon tumanlararo FIB sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_fib_tla_asaka',
          name: 'Asaka tumanlararo FIB sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_fib_tla_boston',
          name: 'Bo\'ston tumanlararo FIB sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_fib_tla_izboskan',
          name: 'Izboskan tumanlararo FIB sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_fib_tla_qorgontepa',
          name: 'Qo\'rg\'ontepa tumanlararo FIB sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_fib_tla_xojaobod',
          name: 'Xo\'jaobod tumanlararo FIB sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'andijon_viloyati_iqtisodiy_sudi',
          name: 'Andijon tumanlararo iqtisodiy sudi',
          regionId: 'andijon_viloyati',
          type: CourtType.iqtisodiy,
        ),
      ],
    ),
    RegionInfo(
      id: 'buxoro_viloyati',
      name: 'Buxoro viloyati',
      courts: [
        CourtInfo(
          id: 'buxoro_viloyati_viloyat_sudi',
          name: 'Buxoro viloyat sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.oliyVaViloyat,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_buxoro_shahar_sudi',
          name: 'Buxoro shahar sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_kogon_shahar_sudi',
          name: 'Kogon shahar sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_buxoro_tuman_sudi',
          name: 'Buxoro tuman sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_vobkent_tuman_sudi',
          name: 'Vobkent tuman sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_gijduvon_tuman_sudi',
          name: 'G\'ijduvon tuman sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_jondor_tuman_sudi',
          name: 'Jondor tuman sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_kogon_tuman_sudi',
          name: 'Kogon tuman sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_qorakol_tuman_sudi',
          name: 'Qorako\'l tuman sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_qorovulbozor_tuman_sudi',
          name: 'Qorovulbozor tuman sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_olot_tuman_sudi',
          name: 'Olot tuman sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_peshku_tuman_sudi',
          name: 'Peshku tuman sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_romitan_tuman_sudi',
          name: 'Romitan tuman sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_shofirkon_tuman_sudi',
          name: 'Shofirkon tuman sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_fib_tla_buxoro',
          name: 'Buxoro tumanlararo FIB sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_fib_tla_gijduvon',
          name: 'G\'ijduvon tumanlararo FIB sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_fib_tla_kogon',
          name: 'Kogon tumanlararo FIB sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_fib_tla_qorakol',
          name: 'Qorako\'l tumanlararo FIB sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_fib_tla_peshku',
          name: 'Peshku tumanlararo FIB sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_fib_tla_romitan',
          name: 'Romitan tumanlararo FIB sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'buxoro_viloyati_iqtisodiy_sudi',
          name: 'Buxoro tumanlararo iqtisodiy sudi',
          regionId: 'buxoro_viloyati',
          type: CourtType.iqtisodiy,
        ),
      ],
    ),
    RegionInfo(
      id: 'jizzax_viloyati',
      name: 'Jizzax viloyati',
      courts: [
        CourtInfo(
          id: 'jizzax_viloyati_viloyat_sudi',
          name: 'Jizzax viloyat sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.oliyVaViloyat,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_jizzax_shahar_sudi',
          name: 'Jizzax shahar sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_arnasoy_tuman_sudi',
          name: 'Arnasoy tuman sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_baxmal_tuman_sudi',
          name: 'Baxmal tuman sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_gallaorol_tuman_sudi',
          name: 'G\'allaorol tuman sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_dostlik_tuman_sudi',
          name: 'Do\'stlik tuman sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_sharof_rashidov_tuman_sudi',
          name: 'Sharof Rashidov tuman sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_zarbdor_tuman_sudi',
          name: 'Zarbdor tuman sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_zafarobod_tuman_sudi',
          name: 'Zafarobod tuman sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_zomin_tuman_sudi',
          name: 'Zomin tuman sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_mirzachol_tuman_sudi',
          name: 'Mirzacho\'l tuman sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_paxtakor_tuman_sudi',
          name: 'Paxtakor tuman sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_forish_tuman_sudi',
          name: 'Forish tuman sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_yangiobod_tuman_sudi',
          name: 'Yangiobod tuman sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_fib_tla_gallaorol',
          name: 'G\'allaorol tumanlararo FIB sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_fib_tla_dostlik',
          name: 'Do\'stlik tumanlararo FIB sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_fib_tla_jizzax',
          name: 'Jizzax tumanlararo FIB sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_fib_tla_zarbdor',
          name: 'Zarbdor tumanlararo FIB sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_fib_t_forish',
          name: 'Forish tuman FIB sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_fib_t_paxtakor',
          name: 'Paxtakor tuman FIB sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'jizzax_viloyati_iqtisodiy_sudi',
          name: 'Jizzax tumanlararo iqtisodiy sudi',
          regionId: 'jizzax_viloyati',
          type: CourtType.iqtisodiy,
        ),
      ],
    ),
    RegionInfo(
      id: 'qashqadaryo_viloyati',
      name: 'Qashqadaryo viloyati',
      courts: [
        CourtInfo(
          id: 'qashqadaryo_viloyati_viloyat_sudi',
          name: 'Qashqadaryo viloyat sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.oliyVaViloyat,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_qarshi_shahar_sudi',
          name: 'Qarshi shahar sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_shahrisabz_shahar_sudi',
          name: 'Shahrisabz shahar sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_guzor_tuman_sudi',
          name: 'G\'uzor tuman sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_dehqonobod_tuman_sudi',
          name: 'Dehqonobod tuman sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_kasbi_tuman_sudi',
          name: 'Kasbi tuman sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_kitob_tuman_sudi',
          name: 'Kitob tuman sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_koson_tuman_sudi',
          name: 'Koson tuman sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_qamashi_tuman_sudi',
          name: 'Qamashi tuman sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_qarshi_tuman_sudi',
          name: 'Qarshi tuman sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_mirishkor_tuman_sudi',
          name: 'Mirishkor tuman sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_muborak_tuman_sudi',
          name: 'Muborak tuman sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_nishon_tuman_sudi',
          name: 'Nishon tuman sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_chiroqchi_tuman_sudi',
          name: 'Chiroqchi tuman sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_kokdala_tuman_sudi',
          name: 'Ko\'kdala tuman sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_shahrisabz_tuman_sudi',
          name: 'Shahrisabz tuman sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_yakkabog_tuman_sudi',
          name: 'Yakkabog\' tuman sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_fib_tla_guzor',
          name: 'G\'uzor tumanlararo FIB sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_fib_tla_qarshi',
          name: 'Qarshi tumanlararo FIB sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_fib_tla_koson',
          name: 'Koson tumanlararo FIB sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_fib_tla_kasbi',
          name: 'Kasbi tumanlararo FIB sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_fib_tla_chiroqchi',
          name: 'Chiroqchi tumanlararo FIB sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_fib_tla_shahrisabz',
          name: 'Shahrisabz tumanlararo FIB sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_fib_tla_yakkabog',
          name: 'Yakkabog\' tumanlararo FIB sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'qashqadaryo_viloyati_iqtisodiy_sudi',
          name: 'Qarshi tumanlararo iqtisodiy sudi',
          regionId: 'qashqadaryo_viloyati',
          type: CourtType.iqtisodiy,
        ),
      ],
    ),
    RegionInfo(
      id: 'navoiy_viloyati',
      name: 'Navoiy viloyati',
      courts: [
        CourtInfo(
          id: 'navoiy_viloyati_viloyat_sudi',
          name: 'Navoiy viloyat sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.oliyVaViloyat,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_navoiy_shahar_sudi',
          name: 'Navoiy shahar sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_zarafshon_shahar_sudi',
          name: 'Zarafshon shahar sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_karmana_tuman_sudi',
          name: 'Karmana tuman sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_konimex_tuman_sudi',
          name: 'Konimex tuman sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_qiziltepa_tuman_sudi',
          name: 'Qiziltepa tuman sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_navbahor_tuman_sudi',
          name: 'Navbahor tuman sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_nurota_tuman_sudi',
          name: 'Nurota tuman sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_tomdi_tuman_sudi',
          name: 'Tomdi tuman sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_uchquduq_tuman_sudi',
          name: 'Uchquduq tuman sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_xatirchi_tuman_sudi',
          name: 'Xatirchi tuman sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_fib_tla_zarafshon',
          name: 'Zarafshon tumanlararo FIB sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_fib_tla_karmana',
          name: 'Karmana tumanlararo FIB sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_fib_tla_navbahor',
          name: 'Navbahor tumanlararo FIB sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_fib_t_uchquduq',
          name: 'Uchquduq tuman FIB sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_fib_t_xatirchi',
          name: 'Xatirchi tuman FIB sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'navoiy_viloyati_iqtisodiy_sudi',
          name: 'Navoiy tumanlararo iqtisodiy sudi',
          regionId: 'navoiy_viloyati',
          type: CourtType.iqtisodiy,
        ),
      ],
    ),
    RegionInfo(
      id: 'namangan_viloyati',
      name: 'Namangan viloyati',
      courts: [
        CourtInfo(
          id: 'namangan_viloyati_viloyat_sudi',
          name: 'Namangan viloyat sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.oliyVaViloyat,
        ),
        CourtInfo(
          id: 'namangan_viloyati_namangan_shahar_sudi',
          name: 'Namangan shahar sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_kosonsoy_tuman_sudi',
          name: 'Kosonsoy tuman sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_mingbuloq_tuman_sudi',
          name: 'Mingbuloq tuman sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_namangan_tuman_sudi',
          name: 'Namangan tuman sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_norin_tuman_sudi',
          name: 'Norin tuman sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_pop_tuman_sudi',
          name: 'Pop tuman sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_toraqorgon_tuman_sudi',
          name: 'To\'raqo\'rg\'on tuman sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_uychi_tuman_sudi',
          name: 'Uychi tuman sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_uchqorgon_tuman_sudi',
          name: 'Uchqo\'rg\'on tuman sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_chortoq_tuman_sudi',
          name: 'Chortoq tuman sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_chust_tuman_sudi',
          name: 'Chust tuman sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_yangiqorgon_tuman_sudi',
          name: 'Yangiqo\'rg\'on tuman sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_fib_tla_namangan',
          name: 'Namangan tumanlararo FIB sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_fib_tla_uchqorgon',
          name: 'Uchqo\'rg\'on tumanlararo FIB sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_fib_tla_chust',
          name: 'Chust tumanlararo FIB sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_fib_tla_yangiqorgon',
          name: 'Yangiqo\'rg\'on tumanlararo FIB sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'namangan_viloyati_iqtisodiy_sudi',
          name: 'Namangan tumanlararo iqtisodiy sudi',
          regionId: 'namangan_viloyati',
          type: CourtType.iqtisodiy,
        ),
      ],
    ),
    RegionInfo(
      id: 'samarqand_viloyati',
      name: 'Samarqand viloyati',
      courts: [
        CourtInfo(
          id: 'samarqand_viloyati_viloyat_sudi',
          name: 'Samarqand viloyat sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.oliyVaViloyat,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_samarqand_shahar_sudi',
          name: 'Samarqand shahar sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_kattaqorgon_shahar_sudi',
          name: 'Kattaqo\'rg\'on shahar sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_bulungur_tuman_sudi',
          name: 'Bulung\'ur tuman sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_jomboy_tuman_sudi',
          name: 'Jomboy tuman sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_ishtixon_tuman_sudi',
          name: 'Ishtixon tuman sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_kattaqorgon_tuman_sudi',
          name: 'Kattaqo\'rg\'on tuman sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_qoshrabot_tuman_sudi',
          name: 'Qo\'shrabot tuman sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_narpay_tuman_sudi',
          name: 'Narpay tuman sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_nurobod_tuman_sudi',
          name: 'Nurobod tuman sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_oqdaryo_tuman_sudi',
          name: 'Oqdaryo tuman sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_payariq_tuman_sudi',
          name: 'Payariq tuman sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_pastdargom_tuman_sudi',
          name: 'Pastdarg\'om tuman sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_paxtachi_tuman_sudi',
          name: 'Paxtachi tuman sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_samarqand_tuman_sudi',
          name: 'Samarqand tuman sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_tayloq_tuman_sudi',
          name: 'Tayloq tuman sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_urgut_tuman_sudi',
          name: 'Urgut tuman sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_fib_tla_jomboy',
          name: 'Jomboy tumanlararo FIB sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_fib_tla_ishtixon',
          name: 'Ishtixon tumanlararo FIB sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_fib_tla_kattaqorgon',
          name: 'Kattaqo\'rg\'on tumanlararo FIB sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_fib_tla_tayloq',
          name: 'Tayloq tumanlararo FIB sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_fib_tla_payariq',
          name: 'Payariq tumanlararo FIB sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_fib_sh_samarqand_sh',
          name: 'Samarqand sh. shahar FIB sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_fib_t_pastdargom',
          name: 'Pastdarg\'om tuman FIB sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_fib_t_nurobod',
          name: 'Nurobod tuman FIB sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_fib_t_urgut',
          name: 'Urgut tuman FIB sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'samarqand_viloyati_iqtisodiy_sudi',
          name: 'Samarqand tumanlararo iqtisodiy sudi',
          regionId: 'samarqand_viloyati',
          type: CourtType.iqtisodiy,
        ),
      ],
    ),
    RegionInfo(
      id: 'surxondaryo_viloyati',
      name: 'Surxondaryo viloyati',
      courts: [
        CourtInfo(
          id: 'surxondaryo_viloyati_viloyat_sudi',
          name: 'Surxondaryo viloyat sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.oliyVaViloyat,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_termiz_shahar_sudi',
          name: 'Termiz shahar sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_angor_tuman_sudi',
          name: 'Angor tuman sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_boysun_tuman_sudi',
          name: 'Boysun tuman sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_denov_tuman_sudi',
          name: 'Denov tuman sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_jarqorgon_tuman_sudi',
          name: 'Jarqo\'rg\'on tuman sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_qiziriq_tuman_sudi',
          name: 'Qiziriq tuman sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_qumqorgon_tuman_sudi',
          name: 'Qumqo\'rg\'on tuman sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_muzrabot_tuman_sudi',
          name: 'Muzrabot tuman sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_oltinsoy_tuman_sudi',
          name: 'Oltinsoy tuman sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_sariosiyo_tuman_sudi',
          name: 'Sariosiyo tuman sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_termiz_tuman_sudi',
          name: 'Termiz tuman sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_uzun_tuman_sudi',
          name: 'Uzun tuman sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_sherobod_tuman_sudi',
          name: 'Sherobod tuman sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_shorchi_tuman_sudi',
          name: 'Sho\'rchi tuman sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_bandixon_tuman_sudi',
          name: 'Bandixon tuman sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_fib_tla_denov',
          name: 'Denov tumanlararo FIB sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_fib_tla_qumqorgon',
          name: 'Qumqo\'rg\'on tumanlararo FIB sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_fib_tla_sariosiyo',
          name: 'Sariosiyo tumanlararo FIB sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_fib_tla_termiz',
          name: 'Termiz tumanlararo FIB sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_fib_tla_sherobod',
          name: 'Sherobod tumanlararo FIB sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_fib_t_boysun',
          name: 'Boysun tuman FIB sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'surxondaryo_viloyati_iqtisodiy_sudi',
          name: 'Termiz tumanlararo iqtisodiy sudi',
          regionId: 'surxondaryo_viloyati',
          type: CourtType.iqtisodiy,
        ),
      ],
    ),
    RegionInfo(
      id: 'sirdaryo_viloyati',
      name: 'Sirdaryo viloyati',
      courts: [
        CourtInfo(
          id: 'sirdaryo_viloyati_viloyat_sudi',
          name: 'Sirdaryo viloyat sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.oliyVaViloyat,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_guliston_shahar_sudi',
          name: 'Guliston shahar sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_shirin_shahar_sudi',
          name: 'Shirin shahar sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_yangiyer_shahar_sudi',
          name: 'Yangiyer shahar sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_boyovut_tuman_sudi',
          name: 'Boyovut tuman sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_guliston_tuman_sudi',
          name: 'Guliston tuman sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_mirzaobod_tuman_sudi',
          name: 'Mirzaobod tuman sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_oqoltin_tuman_sudi',
          name: 'Oqoltin tuman sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_sayxunobod_tuman_sudi',
          name: 'Sayxunobod tuman sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_sardoba_tuman_sudi',
          name: 'Sardoba tuman sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_sirdaryo_tuman_sudi',
          name: 'Sirdaryo tuman sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_xovos_tuman_sudi',
          name: 'Xovos tuman sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_fib_tla_oqoltin',
          name: 'Oqoltin tumanlararo FIB sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_fib_tla_boyovut',
          name: 'Boyovut tumanlararo FIB sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_fib_tla_guliston',
          name: 'Guliston tumanlararo FIB sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_fib_tla_sirdaryo',
          name: 'Sirdaryo tumanlararo FIB sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'sirdaryo_viloyati_iqtisodiy_sudi',
          name: 'Guliston tumanlararo iqtisodiy sudi',
          regionId: 'sirdaryo_viloyati',
          type: CourtType.iqtisodiy,
        ),
      ],
    ),
    RegionInfo(
      id: 'fargona_viloyati',
      name: 'Farg\'ona viloyati',
      courts: [
        CourtInfo(
          id: 'fargona_viloyati_viloyat_sudi',
          name: 'Farg\'ona viloyat sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.oliyVaViloyat,
        ),
        CourtInfo(
          id: 'fargona_viloyati_fargona_shahar_sudi',
          name: 'Farg\'ona shahar sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_quvasoy_shahar_sudi',
          name: 'Quvasoy shahar sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_qoqon_shahar_sudi',
          name: 'Qo\'qon shahar sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_margilon_shahar_sudi',
          name: 'Marg\'ilon shahar sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_beshariq_tuman_sudi',
          name: 'Beshariq tuman sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_bagdod_tuman_sudi',
          name: 'Bag\'dod tuman sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_buvayda_tuman_sudi',
          name: 'Buvayda tuman sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_dangara_tuman_sudi',
          name: 'Dang\'ara tuman sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_yozyovon_tuman_sudi',
          name: 'Yozyovon tuman sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_quva_tuman_sudi',
          name: 'Quva tuman sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_qoshtepa_tuman_sudi',
          name: 'Qo\'shtepa tuman sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_oltiariq_tuman_sudi',
          name: 'Oltiariq tuman sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_rishton_tuman_sudi',
          name: 'Rishton tuman sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_sox_tuman_sudi',
          name: 'So\'x tuman sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_toshloq_tuman_sudi',
          name: 'Toshloq tuman sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_ozbekiston_tuman_sudi',
          name: 'O\'zbekiston tuman sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_uchkoprik_tuman_sudi',
          name: 'Uchko\'prik tuman sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_fargona_tuman_sudi',
          name: 'Farg\'ona tuman sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_furqat_tuman_sudi',
          name: 'Furqat tuman sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_fib_tla_qoqon',
          name: 'Qo\'qon tumanlararo FIB sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_fib_tla_margilon',
          name: 'Marg\'ilon tumanlararo FIB sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_fib_tla_rishton',
          name: 'Rishton tumanlararo FIB sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_fib_tla_ozbekiston',
          name: 'O\'zbekiston tumanlararo FIB sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_fib_tla_fargona',
          name: 'Farg\'ona tumanlararo FIB sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_fib_t_sox',
          name: 'So\'x tuman FIB sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'fargona_viloyati_iqtisodiy_sudi',
          name: 'Farg\'ona tumanlararo iqtisodiy sudi',
          regionId: 'fargona_viloyati',
          type: CourtType.iqtisodiy,
        ),
      ],
    ),
    RegionInfo(
      id: 'xorazm_viloyati',
      name: 'Xorazm viloyati',
      courts: [
        CourtInfo(
          id: 'xorazm_viloyati_viloyat_sudi',
          name: 'Xorazm viloyat sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.oliyVaViloyat,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_urganch_shahar_sudi',
          name: 'Urganch shahar sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_xiva_shahar_sudi',
          name: 'Xiva shahar sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_bogot_tuman_sudi',
          name: 'Bog\'ot tuman sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_gurlan_tuman_sudi',
          name: 'Gurlan tuman sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_qoshkopir_tuman_sudi',
          name: 'Qo\'shko\'pir tuman sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_urganch_tuman_sudi',
          name: 'Urganch tuman sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_xiva_tuman_sudi',
          name: 'Xiva tuman sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_xonqa_tuman_sudi',
          name: 'Xonqa tuman sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_hazorasp_tuman_sudi',
          name: 'Hazorasp tuman sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_shovot_tuman_sudi',
          name: 'Shovot tuman sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_yangiariq_tuman_sudi',
          name: 'Yangiariq tuman sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_yangibozor_tuman_sudi',
          name: 'Yangibozor tuman sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_tuproqqala_tuman_sudi',
          name: 'Tuproqqal\'a tuman sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_fib_tla_bogot',
          name: 'Bog\'ot tumanlararo FIB sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_fib_tla_urganch',
          name: 'Urganch tumanlararo FIB sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_fib_tla_shovot',
          name: 'Shovot tumanlararo FIB sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'xorazm_viloyati_iqtisodiy_sudi',
          name: 'Urganch tumanlararo iqtisodiy sudi',
          regionId: 'xorazm_viloyati',
          type: CourtType.iqtisodiy,
        ),
      ],
    ),
    RegionInfo(
      id: 'toshkent_viloyati',
      name: 'Toshkent viloyati',
      courts: [
        CourtInfo(
          id: 'toshkent_viloyati_viloyat_sudi',
          name: 'Toshkent viloyat sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.oliyVaViloyat,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_angren_shahar_sudi',
          name: 'Angren shahar sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_bekobod_shahar_sudi',
          name: 'Bekobod shahar sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_nurafshon_shahar_sudi',
          name: 'Nurafshon shahar sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_olmaliq_shahar_sudi',
          name: 'Olmaliq shahar sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_ohangaron_shahar_sudi',
          name: 'Ohangaron shahar sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_chirchiq_shahar_sudi',
          name: 'Chirchiq shahar sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_yangiyol_shahar_sudi',
          name: 'Yangiyo\'l shahar sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_bekobod_tuman_sudi',
          name: 'Bekobod tuman sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_boka_tuman_sudi',
          name: 'Bo\'ka tuman sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_bostonliq_tuman_sudi',
          name: 'Bo\'stonliq tuman sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_zangiota_tuman_sudi',
          name: 'Zangiota tuman sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_qibray_tuman_sudi',
          name: 'Qibray tuman sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_quyichirchiq_tuman_sudi',
          name: 'Quyichirchiq tuman sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_oqqorgon_tuman_sudi',
          name: 'Oqqo\'rg\'on tuman sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_ohangaron_tuman_sudi',
          name: 'Ohangaron tuman sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_parkent_tuman_sudi',
          name: 'Parkent tuman sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_piskent_tuman_sudi',
          name: 'Piskent tuman sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_toshkent_tuman_sudi',
          name: 'Toshkent tuman sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_ortachirchiq_tuman_sudi',
          name: 'O\'rtachirchiq tuman sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_chinoz_tuman_sudi',
          name: 'Chinoz tuman sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_yuqorichirchiq_tuman_sudi',
          name: 'Yuqorichirchiq tuman sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_yangiyol_tuman_sudi',
          name: 'Yangiyo\'l tuman sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_fib_tla_ohangaron',
          name: 'Ohangaron tumanlararo FIB sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_fib_tla_bekobod',
          name: 'Bekobod tumanlararo FIB sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_fib_tla_zangiota',
          name: 'Zangiota tumanlararo FIB sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_fib_tla_quyichirchiq',
          name: 'Quyichirchiq tumanlararo FIB sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_fib_tla_ortachirchiq',
          name: 'O\'rtachirchiq tumanlararo FIB sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_fib_tla_chirchiq',
          name: 'Chirchiq tumanlararo FIB sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_fib_tla_yuqorichirchiq',
          name: 'Yuqorichirchiq tumanlararo FIB sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_fib_tla_yangiyol',
          name: 'Yangiyo\'l tumanlararo FIB sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'toshkent_viloyati_iqtisodiy_sudi',
          name: 'Nurafshon tumanlararo iqtisodiy sudi',
          regionId: 'toshkent_viloyati',
          type: CourtType.iqtisodiy,
        ),
      ],
    ),
    RegionInfo(
      id: 'toshkent_shahri',
      name: 'Toshkent shahri',
      courts: [
        CourtInfo(
          id: 'toshkent_shahri_viloyat_sudi',
          name: 'Toshkent shahar sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.oliyVaViloyat,
        ),
        CourtInfo(
          id: 'toshkent_shahri_bektemir_tuman_sudi',
          name: 'Bektemir tuman sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_mirzo_ulugbek_tuman_sudi',
          name: 'Mirzo Ulug\'bek tuman sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_mirobod_tuman_sudi',
          name: 'Mirobod tuman sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_olmazor_tuman_sudi',
          name: 'Olmazor tuman sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_sirgali_tuman_sudi',
          name: 'Sirg\'ali tuman sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_uchtepa_tuman_sudi',
          name: 'Uchtepa tuman sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_chilonzor_tuman_sudi',
          name: 'Chilonzor tuman sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_shayxontohur_tuman_sudi',
          name: 'Shayxontohur tuman sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_yunusobod_tuman_sudi',
          name: 'Yunusobod tuman sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_yakkasaroy_tuman_sudi',
          name: 'Yakkasaroy tuman sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_yashnobod_tuman_sudi',
          name: 'Yashnobod tuman sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_yangihayot_tuman_sudi',
          name: 'Yangihayot tuman sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.jib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_fib_tla_mirobod',
          name: 'Mirobod tumanlararo FIB sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_fib_tla_mirzo_ulugbek',
          name: 'Mirzo Ulug\'bek tumanlararo FIB sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_fib_tla_uchtepa',
          name: 'Uchtepa tumanlararo FIB sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_fib_tla_shayxontohur',
          name: 'Shayxontohur tumanlararo FIB sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_fib_tla_yakkasaroy',
          name: 'Yakkasaroy tumanlararo FIB sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.fib,
        ),
        CourtInfo(
          id: 'toshkent_shahri_iqtisodiy_sudi',
          name: 'Toshkent tumanlararo iqtisodiy sudi',
          regionId: 'toshkent_shahri',
          type: CourtType.iqtisodiy,
        ),
      ],
    ),
  ];

  static RegionInfo? findRegionById(String id) {
    try {
      return regions.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  static CourtInfo? findCourtById(String id) {
    for (final r in regions) {
      try {
        return r.courts.firstWhere((c) => c.id == id);
      } catch (_) {}
    }
    return null;
  }

  static List<CourtInfo> getCourtsByRegionAndType(
      String regionId, CourtType type) {
    final region = findRegionById(regionId);
    if (region == null) return [];
    return region.courtsByType(type);
  }
}