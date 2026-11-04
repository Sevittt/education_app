// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NewsTableTable extends NewsTable
    with TableInfo<$NewsTableTable, NewsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NewsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _publicationDateMeta =
      const VerificationMeta('publicationDate');
  @override
  late final GeneratedColumn<DateTime> publicationDate =
      GeneratedColumn<DateTime>('publication_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, source, url, publicationDate, imageUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'news_table';
  @override
  VerificationContext validateIntegrity(Insertable<NewsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('publication_date')) {
      context.handle(
          _publicationDateMeta,
          publicationDate.isAcceptableOrUnknown(
              data['publication_date']!, _publicationDateMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NewsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NewsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      publicationDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}publication_date']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
    );
  }

  @override
  $NewsTableTable createAlias(String alias) {
    return $NewsTableTable(attachedDatabase, alias);
  }
}

class NewsTableData extends DataClass implements Insertable<NewsTableData> {
  final String id;
  final String title;
  final String source;
  final String url;
  final DateTime? publicationDate;
  final String? imageUrl;
  const NewsTableData(
      {required this.id,
      required this.title,
      required this.source,
      required this.url,
      this.publicationDate,
      this.imageUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['source'] = Variable<String>(source);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || publicationDate != null) {
      map['publication_date'] = Variable<DateTime>(publicationDate);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    return map;
  }

  NewsTableCompanion toCompanion(bool nullToAbsent) {
    return NewsTableCompanion(
      id: Value(id),
      title: Value(title),
      source: Value(source),
      url: Value(url),
      publicationDate: publicationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(publicationDate),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
    );
  }

  factory NewsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NewsTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      source: serializer.fromJson<String>(json['source']),
      url: serializer.fromJson<String>(json['url']),
      publicationDate: serializer.fromJson<DateTime?>(json['publicationDate']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'source': serializer.toJson<String>(source),
      'url': serializer.toJson<String>(url),
      'publicationDate': serializer.toJson<DateTime?>(publicationDate),
      'imageUrl': serializer.toJson<String?>(imageUrl),
    };
  }

  NewsTableData copyWith(
          {String? id,
          String? title,
          String? source,
          String? url,
          Value<DateTime?> publicationDate = const Value.absent(),
          Value<String?> imageUrl = const Value.absent()}) =>
      NewsTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        source: source ?? this.source,
        url: url ?? this.url,
        publicationDate: publicationDate.present
            ? publicationDate.value
            : this.publicationDate,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
      );
  NewsTableData copyWithCompanion(NewsTableCompanion data) {
    return NewsTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      source: data.source.present ? data.source.value : this.source,
      url: data.url.present ? data.url.value : this.url,
      publicationDate: data.publicationDate.present
          ? data.publicationDate.value
          : this.publicationDate,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NewsTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('source: $source, ')
          ..write('url: $url, ')
          ..write('publicationDate: $publicationDate, ')
          ..write('imageUrl: $imageUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, source, url, publicationDate, imageUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NewsTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.source == this.source &&
          other.url == this.url &&
          other.publicationDate == this.publicationDate &&
          other.imageUrl == this.imageUrl);
}

class NewsTableCompanion extends UpdateCompanion<NewsTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> source;
  final Value<String> url;
  final Value<DateTime?> publicationDate;
  final Value<String?> imageUrl;
  final Value<int> rowid;
  const NewsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.source = const Value.absent(),
    this.url = const Value.absent(),
    this.publicationDate = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NewsTableCompanion.insert({
    required String id,
    required String title,
    required String source,
    required String url,
    this.publicationDate = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        source = Value(source),
        url = Value(url);
  static Insertable<NewsTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? source,
    Expression<String>? url,
    Expression<DateTime>? publicationDate,
    Expression<String>? imageUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (source != null) 'source': source,
      if (url != null) 'url': url,
      if (publicationDate != null) 'publication_date': publicationDate,
      if (imageUrl != null) 'image_url': imageUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NewsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? source,
      Value<String>? url,
      Value<DateTime?>? publicationDate,
      Value<String?>? imageUrl,
      Value<int>? rowid}) {
    return NewsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      source: source ?? this.source,
      url: url ?? this.url,
      publicationDate: publicationDate ?? this.publicationDate,
      imageUrl: imageUrl ?? this.imageUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (publicationDate.present) {
      map['publication_date'] = Variable<DateTime>(publicationDate.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NewsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('source: $source, ')
          ..write('url: $url, ')
          ..write('publicationDate: $publicationDate, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxActionsTableTable extends OutboxActionsTable
    with TableInfo<$OutboxActionsTableTable, OutboxActionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxActionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityCollectionMeta =
      const VerificationMeta('entityCollection');
  @override
  late final GeneratedColumn<String> entityCollection = GeneratedColumn<String>(
      'entity_collection', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionTypeMeta =
      const VerificationMeta('actionType');
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
      'action_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityCollection,
        entityId,
        actionType,
        payloadJson,
        createdAt,
        retryCount,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_actions_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<OutboxActionsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_collection')) {
      context.handle(
          _entityCollectionMeta,
          entityCollection.isAcceptableOrUnknown(
              data['entity_collection']!, _entityCollectionMeta));
    } else if (isInserting) {
      context.missing(_entityCollectionMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action_type')) {
      context.handle(
          _actionTypeMeta,
          actionType.isAcceptableOrUnknown(
              data['action_type']!, _actionTypeMeta));
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxActionsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxActionsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityCollection: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}entity_collection'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      actionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_type'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $OutboxActionsTableTable createAlias(String alias) {
    return $OutboxActionsTableTable(attachedDatabase, alias);
  }
}

class OutboxActionsTableData extends DataClass
    implements Insertable<OutboxActionsTableData> {
  final int id;
  final String entityCollection;
  final String entityId;

  /// Amal turi matn ko'rinishida saqlanadi: 'create' | 'update' | 'delete'.
  final String actionType;
  final String payloadJson;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  const OutboxActionsTableData(
      {required this.id,
      required this.entityCollection,
      required this.entityId,
      required this.actionType,
      required this.payloadJson,
      required this.createdAt,
      required this.retryCount,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_collection'] = Variable<String>(entityCollection);
    map['entity_id'] = Variable<String>(entityId);
    map['action_type'] = Variable<String>(actionType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OutboxActionsTableCompanion toCompanion(bool nullToAbsent) {
    return OutboxActionsTableCompanion(
      id: Value(id),
      entityCollection: Value(entityCollection),
      entityId: Value(entityId),
      actionType: Value(actionType),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory OutboxActionsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxActionsTableData(
      id: serializer.fromJson<int>(json['id']),
      entityCollection: serializer.fromJson<String>(json['entityCollection']),
      entityId: serializer.fromJson<String>(json['entityId']),
      actionType: serializer.fromJson<String>(json['actionType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityCollection': serializer.toJson<String>(entityCollection),
      'entityId': serializer.toJson<String>(entityId),
      'actionType': serializer.toJson<String>(actionType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxActionsTableData copyWith(
          {int? id,
          String? entityCollection,
          String? entityId,
          String? actionType,
          String? payloadJson,
          DateTime? createdAt,
          int? retryCount,
          Value<String?> lastError = const Value.absent()}) =>
      OutboxActionsTableData(
        id: id ?? this.id,
        entityCollection: entityCollection ?? this.entityCollection,
        entityId: entityId ?? this.entityId,
        actionType: actionType ?? this.actionType,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  OutboxActionsTableData copyWithCompanion(OutboxActionsTableCompanion data) {
    return OutboxActionsTableData(
      id: data.id.present ? data.id.value : this.id,
      entityCollection: data.entityCollection.present
          ? data.entityCollection.value
          : this.entityCollection,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      actionType:
          data.actionType.present ? data.actionType.value : this.actionType,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxActionsTableData(')
          ..write('id: $id, ')
          ..write('entityCollection: $entityCollection, ')
          ..write('entityId: $entityId, ')
          ..write('actionType: $actionType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityCollection, entityId, actionType,
      payloadJson, createdAt, retryCount, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxActionsTableData &&
          other.id == this.id &&
          other.entityCollection == this.entityCollection &&
          other.entityId == this.entityId &&
          other.actionType == this.actionType &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class OutboxActionsTableCompanion
    extends UpdateCompanion<OutboxActionsTableData> {
  final Value<int> id;
  final Value<String> entityCollection;
  final Value<String> entityId;
  final Value<String> actionType;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  const OutboxActionsTableCompanion({
    this.id = const Value.absent(),
    this.entityCollection = const Value.absent(),
    this.entityId = const Value.absent(),
    this.actionType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  OutboxActionsTableCompanion.insert({
    this.id = const Value.absent(),
    required String entityCollection,
    required String entityId,
    required String actionType,
    required String payloadJson,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  })  : entityCollection = Value(entityCollection),
        entityId = Value(entityId),
        actionType = Value(actionType),
        payloadJson = Value(payloadJson),
        createdAt = Value(createdAt);
  static Insertable<OutboxActionsTableData> custom({
    Expression<int>? id,
    Expression<String>? entityCollection,
    Expression<String>? entityId,
    Expression<String>? actionType,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityCollection != null) 'entity_collection': entityCollection,
      if (entityId != null) 'entity_id': entityId,
      if (actionType != null) 'action_type': actionType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
    });
  }

  OutboxActionsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityCollection,
      Value<String>? entityId,
      Value<String>? actionType,
      Value<String>? payloadJson,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<String?>? lastError}) {
    return OutboxActionsTableCompanion(
      id: id ?? this.id,
      entityCollection: entityCollection ?? this.entityCollection,
      entityId: entityId ?? this.entityId,
      actionType: actionType ?? this.actionType,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityCollection.present) {
      map['entity_collection'] = Variable<String>(entityCollection.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxActionsTableCompanion(')
          ..write('id: $id, ')
          ..write('entityCollection: $entityCollection, ')
          ..write('entityId: $entityId, ')
          ..write('actionType: $actionType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $RagChunksTableTable extends RagChunksTable
    with TableInfo<$RagChunksTableTable, RagChunksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RagChunksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _moduleMeta = const VerificationMeta('module');
  @override
  late final GeneratedColumn<String> module = GeneratedColumn<String>(
      'module', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vectorJsonMeta =
      const VerificationMeta('vectorJson');
  @override
  late final GeneratedColumn<String> vectorJson = GeneratedColumn<String>(
      'vector_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourcePathMeta =
      const VerificationMeta('sourcePath');
  @override
  late final GeneratedColumn<String> sourcePath = GeneratedColumn<String>(
      'source_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, module, category, content, vectorJson, sourcePath, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rag_chunks_table';
  @override
  VerificationContext validateIntegrity(Insertable<RagChunksTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('module')) {
      context.handle(_moduleMeta,
          module.isAcceptableOrUnknown(data['module']!, _moduleMeta));
    } else if (isInserting) {
      context.missing(_moduleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('vector_json')) {
      context.handle(
          _vectorJsonMeta,
          vectorJson.isAcceptableOrUnknown(
              data['vector_json']!, _vectorJsonMeta));
    } else if (isInserting) {
      context.missing(_vectorJsonMeta);
    }
    if (data.containsKey('source_path')) {
      context.handle(
          _sourcePathMeta,
          sourcePath.isAcceptableOrUnknown(
              data['source_path']!, _sourcePathMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RagChunksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RagChunksTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      module: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}module'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      vectorJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vector_json'])!,
      sourcePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_path']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RagChunksTableTable createAlias(String alias) {
    return $RagChunksTableTable(attachedDatabase, alias);
  }
}

class RagChunksTableData extends DataClass
    implements Insertable<RagChunksTableData> {
  final String id;
  final String title;
  final String module;
  final String category;
  final String content;

  /// JSON massiv: List<double> (masalan 256 o'lchamli float massivi).
  final String vectorJson;
  final String? sourcePath;
  final DateTime updatedAt;
  const RagChunksTableData(
      {required this.id,
      required this.title,
      required this.module,
      required this.category,
      required this.content,
      required this.vectorJson,
      this.sourcePath,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['module'] = Variable<String>(module);
    map['category'] = Variable<String>(category);
    map['content'] = Variable<String>(content);
    map['vector_json'] = Variable<String>(vectorJson);
    if (!nullToAbsent || sourcePath != null) {
      map['source_path'] = Variable<String>(sourcePath);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RagChunksTableCompanion toCompanion(bool nullToAbsent) {
    return RagChunksTableCompanion(
      id: Value(id),
      title: Value(title),
      module: Value(module),
      category: Value(category),
      content: Value(content),
      vectorJson: Value(vectorJson),
      sourcePath: sourcePath == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePath),
      updatedAt: Value(updatedAt),
    );
  }

  factory RagChunksTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RagChunksTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      module: serializer.fromJson<String>(json['module']),
      category: serializer.fromJson<String>(json['category']),
      content: serializer.fromJson<String>(json['content']),
      vectorJson: serializer.fromJson<String>(json['vectorJson']),
      sourcePath: serializer.fromJson<String?>(json['sourcePath']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'module': serializer.toJson<String>(module),
      'category': serializer.toJson<String>(category),
      'content': serializer.toJson<String>(content),
      'vectorJson': serializer.toJson<String>(vectorJson),
      'sourcePath': serializer.toJson<String?>(sourcePath),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RagChunksTableData copyWith(
          {String? id,
          String? title,
          String? module,
          String? category,
          String? content,
          String? vectorJson,
          Value<String?> sourcePath = const Value.absent(),
          DateTime? updatedAt}) =>
      RagChunksTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        module: module ?? this.module,
        category: category ?? this.category,
        content: content ?? this.content,
        vectorJson: vectorJson ?? this.vectorJson,
        sourcePath: sourcePath.present ? sourcePath.value : this.sourcePath,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  RagChunksTableData copyWithCompanion(RagChunksTableCompanion data) {
    return RagChunksTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      module: data.module.present ? data.module.value : this.module,
      category: data.category.present ? data.category.value : this.category,
      content: data.content.present ? data.content.value : this.content,
      vectorJson:
          data.vectorJson.present ? data.vectorJson.value : this.vectorJson,
      sourcePath:
          data.sourcePath.present ? data.sourcePath.value : this.sourcePath,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RagChunksTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('module: $module, ')
          ..write('category: $category, ')
          ..write('content: $content, ')
          ..write('vectorJson: $vectorJson, ')
          ..write('sourcePath: $sourcePath, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, title, module, category, content, vectorJson, sourcePath, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RagChunksTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.module == this.module &&
          other.category == this.category &&
          other.content == this.content &&
          other.vectorJson == this.vectorJson &&
          other.sourcePath == this.sourcePath &&
          other.updatedAt == this.updatedAt);
}

class RagChunksTableCompanion extends UpdateCompanion<RagChunksTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> module;
  final Value<String> category;
  final Value<String> content;
  final Value<String> vectorJson;
  final Value<String?> sourcePath;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RagChunksTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.module = const Value.absent(),
    this.category = const Value.absent(),
    this.content = const Value.absent(),
    this.vectorJson = const Value.absent(),
    this.sourcePath = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RagChunksTableCompanion.insert({
    required String id,
    required String title,
    required String module,
    required String category,
    required String content,
    required String vectorJson,
    this.sourcePath = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        module = Value(module),
        category = Value(category),
        content = Value(content),
        vectorJson = Value(vectorJson),
        updatedAt = Value(updatedAt);
  static Insertable<RagChunksTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? module,
    Expression<String>? category,
    Expression<String>? content,
    Expression<String>? vectorJson,
    Expression<String>? sourcePath,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (module != null) 'module': module,
      if (category != null) 'category': category,
      if (content != null) 'content': content,
      if (vectorJson != null) 'vector_json': vectorJson,
      if (sourcePath != null) 'source_path': sourcePath,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RagChunksTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? module,
      Value<String>? category,
      Value<String>? content,
      Value<String>? vectorJson,
      Value<String?>? sourcePath,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return RagChunksTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      module: module ?? this.module,
      category: category ?? this.category,
      content: content ?? this.content,
      vectorJson: vectorJson ?? this.vectorJson,
      sourcePath: sourcePath ?? this.sourcePath,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (module.present) {
      map['module'] = Variable<String>(module.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (vectorJson.present) {
      map['vector_json'] = Variable<String>(vectorJson.value);
    }
    if (sourcePath.present) {
      map['source_path'] = Variable<String>(sourcePath.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RagChunksTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('module: $module, ')
          ..write('category: $category, ')
          ..write('content: $content, ')
          ..write('vectorJson: $vectorJson, ')
          ..write('sourcePath: $sourcePath, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NewsTableTable newsTable = $NewsTableTable(this);
  late final $OutboxActionsTableTable outboxActionsTable =
      $OutboxActionsTableTable(this);
  late final $RagChunksTableTable ragChunksTable = $RagChunksTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [newsTable, outboxActionsTable, ragChunksTable];
}

typedef $$NewsTableTableCreateCompanionBuilder = NewsTableCompanion Function({
  required String id,
  required String title,
  required String source,
  required String url,
  Value<DateTime?> publicationDate,
  Value<String?> imageUrl,
  Value<int> rowid,
});
typedef $$NewsTableTableUpdateCompanionBuilder = NewsTableCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> source,
  Value<String> url,
  Value<DateTime?> publicationDate,
  Value<String?> imageUrl,
  Value<int> rowid,
});

class $$NewsTableTableFilterComposer
    extends Composer<_$AppDatabase, $NewsTableTable> {
  $$NewsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get publicationDate => $composableBuilder(
      column: $table.publicationDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));
}

class $$NewsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NewsTableTable> {
  $$NewsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get publicationDate => $composableBuilder(
      column: $table.publicationDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));
}

class $$NewsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NewsTableTable> {
  $$NewsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<DateTime> get publicationDate => $composableBuilder(
      column: $table.publicationDate, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);
}

class $$NewsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NewsTableTable,
    NewsTableData,
    $$NewsTableTableFilterComposer,
    $$NewsTableTableOrderingComposer,
    $$NewsTableTableAnnotationComposer,
    $$NewsTableTableCreateCompanionBuilder,
    $$NewsTableTableUpdateCompanionBuilder,
    (
      NewsTableData,
      BaseReferences<_$AppDatabase, $NewsTableTable, NewsTableData>
    ),
    NewsTableData,
    PrefetchHooks Function()> {
  $$NewsTableTableTableManager(_$AppDatabase db, $NewsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NewsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NewsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NewsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<DateTime?> publicationDate = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NewsTableCompanion(
            id: id,
            title: title,
            source: source,
            url: url,
            publicationDate: publicationDate,
            imageUrl: imageUrl,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String source,
            required String url,
            Value<DateTime?> publicationDate = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NewsTableCompanion.insert(
            id: id,
            title: title,
            source: source,
            url: url,
            publicationDate: publicationDate,
            imageUrl: imageUrl,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NewsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NewsTableTable,
    NewsTableData,
    $$NewsTableTableFilterComposer,
    $$NewsTableTableOrderingComposer,
    $$NewsTableTableAnnotationComposer,
    $$NewsTableTableCreateCompanionBuilder,
    $$NewsTableTableUpdateCompanionBuilder,
    (
      NewsTableData,
      BaseReferences<_$AppDatabase, $NewsTableTable, NewsTableData>
    ),
    NewsTableData,
    PrefetchHooks Function()>;
typedef $$OutboxActionsTableTableCreateCompanionBuilder
    = OutboxActionsTableCompanion Function({
  Value<int> id,
  required String entityCollection,
  required String entityId,
  required String actionType,
  required String payloadJson,
  required DateTime createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
});
typedef $$OutboxActionsTableTableUpdateCompanionBuilder
    = OutboxActionsTableCompanion Function({
  Value<int> id,
  Value<String> entityCollection,
  Value<String> entityId,
  Value<String> actionType,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
});

class $$OutboxActionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxActionsTableTable> {
  $$OutboxActionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityCollection => $composableBuilder(
      column: $table.entityCollection,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$OutboxActionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxActionsTableTable> {
  $$OutboxActionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityCollection => $composableBuilder(
      column: $table.entityCollection,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$OutboxActionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxActionsTableTable> {
  $$OutboxActionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityCollection => $composableBuilder(
      column: $table.entityCollection, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxActionsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxActionsTableTable,
    OutboxActionsTableData,
    $$OutboxActionsTableTableFilterComposer,
    $$OutboxActionsTableTableOrderingComposer,
    $$OutboxActionsTableTableAnnotationComposer,
    $$OutboxActionsTableTableCreateCompanionBuilder,
    $$OutboxActionsTableTableUpdateCompanionBuilder,
    (
      OutboxActionsTableData,
      BaseReferences<_$AppDatabase, $OutboxActionsTableTable,
          OutboxActionsTableData>
    ),
    OutboxActionsTableData,
    PrefetchHooks Function()> {
  $$OutboxActionsTableTableTableManager(
      _$AppDatabase db, $OutboxActionsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxActionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxActionsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxActionsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entityCollection = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> actionType = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              OutboxActionsTableCompanion(
            id: id,
            entityCollection: entityCollection,
            entityId: entityId,
            actionType: actionType,
            payloadJson: payloadJson,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entityCollection,
            required String entityId,
            required String actionType,
            required String payloadJson,
            required DateTime createdAt,
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              OutboxActionsTableCompanion.insert(
            id: id,
            entityCollection: entityCollection,
            entityId: entityId,
            actionType: actionType,
            payloadJson: payloadJson,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxActionsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxActionsTableTable,
    OutboxActionsTableData,
    $$OutboxActionsTableTableFilterComposer,
    $$OutboxActionsTableTableOrderingComposer,
    $$OutboxActionsTableTableAnnotationComposer,
    $$OutboxActionsTableTableCreateCompanionBuilder,
    $$OutboxActionsTableTableUpdateCompanionBuilder,
    (
      OutboxActionsTableData,
      BaseReferences<_$AppDatabase, $OutboxActionsTableTable,
          OutboxActionsTableData>
    ),
    OutboxActionsTableData,
    PrefetchHooks Function()>;
typedef $$RagChunksTableTableCreateCompanionBuilder = RagChunksTableCompanion
    Function({
  required String id,
  required String title,
  required String module,
  required String category,
  required String content,
  required String vectorJson,
  Value<String?> sourcePath,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RagChunksTableTableUpdateCompanionBuilder = RagChunksTableCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> module,
  Value<String> category,
  Value<String> content,
  Value<String> vectorJson,
  Value<String?> sourcePath,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$RagChunksTableTableFilterComposer
    extends Composer<_$AppDatabase, $RagChunksTableTable> {
  $$RagChunksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get module => $composableBuilder(
      column: $table.module, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vectorJson => $composableBuilder(
      column: $table.vectorJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourcePath => $composableBuilder(
      column: $table.sourcePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$RagChunksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RagChunksTableTable> {
  $$RagChunksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get module => $composableBuilder(
      column: $table.module, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vectorJson => $composableBuilder(
      column: $table.vectorJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourcePath => $composableBuilder(
      column: $table.sourcePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$RagChunksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RagChunksTableTable> {
  $$RagChunksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get module =>
      $composableBuilder(column: $table.module, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get vectorJson => $composableBuilder(
      column: $table.vectorJson, builder: (column) => column);

  GeneratedColumn<String> get sourcePath => $composableBuilder(
      column: $table.sourcePath, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RagChunksTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RagChunksTableTable,
    RagChunksTableData,
    $$RagChunksTableTableFilterComposer,
    $$RagChunksTableTableOrderingComposer,
    $$RagChunksTableTableAnnotationComposer,
    $$RagChunksTableTableCreateCompanionBuilder,
    $$RagChunksTableTableUpdateCompanionBuilder,
    (
      RagChunksTableData,
      BaseReferences<_$AppDatabase, $RagChunksTableTable, RagChunksTableData>
    ),
    RagChunksTableData,
    PrefetchHooks Function()> {
  $$RagChunksTableTableTableManager(
      _$AppDatabase db, $RagChunksTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RagChunksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RagChunksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RagChunksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> module = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> vectorJson = const Value.absent(),
            Value<String?> sourcePath = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RagChunksTableCompanion(
            id: id,
            title: title,
            module: module,
            category: category,
            content: content,
            vectorJson: vectorJson,
            sourcePath: sourcePath,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String module,
            required String category,
            required String content,
            required String vectorJson,
            Value<String?> sourcePath = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RagChunksTableCompanion.insert(
            id: id,
            title: title,
            module: module,
            category: category,
            content: content,
            vectorJson: vectorJson,
            sourcePath: sourcePath,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RagChunksTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RagChunksTableTable,
    RagChunksTableData,
    $$RagChunksTableTableFilterComposer,
    $$RagChunksTableTableOrderingComposer,
    $$RagChunksTableTableAnnotationComposer,
    $$RagChunksTableTableCreateCompanionBuilder,
    $$RagChunksTableTableUpdateCompanionBuilder,
    (
      RagChunksTableData,
      BaseReferences<_$AppDatabase, $RagChunksTableTable, RagChunksTableData>
    ),
    RagChunksTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NewsTableTableTableManager get newsTable =>
      $$NewsTableTableTableManager(_db, _db.newsTable);
  $$OutboxActionsTableTableTableManager get outboxActionsTable =>
      $$OutboxActionsTableTableTableManager(_db, _db.outboxActionsTable);
  $$RagChunksTableTableTableManager get ragChunksTable =>
      $$RagChunksTableTableTableManager(_db, _db.ragChunksTable);
}
