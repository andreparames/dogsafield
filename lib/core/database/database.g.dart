// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EventsTableTable extends EventsTable
    with TableInfo<$EventsTableTable, EventsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hostIdMeta = const VerificationMeta('hostId');
  @override
  late final GeneratedColumn<String> hostId = GeneratedColumn<String>(
    'host_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationNameMeta = const VerificationMeta(
    'locationName',
  );
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
    'location_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventDateMeta = const VerificationMeta(
    'eventDate',
  );
  @override
  late final GeneratedColumn<String> eventDate = GeneratedColumn<String>(
    'event_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxAttendeesMeta = const VerificationMeta(
    'maxAttendees',
  );
  @override
  late final GeneratedColumn<int> maxAttendees = GeneratedColumn<int>(
    'max_attendees',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whatToBringMeta = const VerificationMeta(
    'whatToBring',
  );
  @override
  late final GeneratedColumn<String> whatToBring = GeneratedColumn<String>(
    'what_to_bring',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amenityTagsMeta = const VerificationMeta(
    'amenityTags',
  );
  @override
  late final GeneratedColumn<String> amenityTags = GeneratedColumn<String>(
    'amenity_tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCancelledMeta = const VerificationMeta(
    'isCancelled',
  );
  @override
  late final GeneratedColumn<int> isCancelled = GeneratedColumn<int>(
    'is_cancelled',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hostId,
    type,
    title,
    description,
    locationName,
    latitude,
    longitude,
    eventDate,
    maxAttendees,
    whatToBring,
    amenityTags,
    isCancelled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('host_id')) {
      context.handle(
        _hostIdMeta,
        hostId.isAcceptableOrUnknown(data['host_id']!, _hostIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hostIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('location_name')) {
      context.handle(
        _locationNameMeta,
        locationName.isAcceptableOrUnknown(
          data['location_name']!,
          _locationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationNameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('event_date')) {
      context.handle(
        _eventDateMeta,
        eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta),
      );
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('max_attendees')) {
      context.handle(
        _maxAttendeesMeta,
        maxAttendees.isAcceptableOrUnknown(
          data['max_attendees']!,
          _maxAttendeesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_maxAttendeesMeta);
    }
    if (data.containsKey('what_to_bring')) {
      context.handle(
        _whatToBringMeta,
        whatToBring.isAcceptableOrUnknown(
          data['what_to_bring']!,
          _whatToBringMeta,
        ),
      );
    }
    if (data.containsKey('amenity_tags')) {
      context.handle(
        _amenityTagsMeta,
        amenityTags.isAcceptableOrUnknown(
          data['amenity_tags']!,
          _amenityTagsMeta,
        ),
      );
    }
    if (data.containsKey('is_cancelled')) {
      context.handle(
        _isCancelledMeta,
        isCancelled.isAcceptableOrUnknown(
          data['is_cancelled']!,
          _isCancelledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      hostId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}host_id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      locationName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}location_name'],
          )!,
      latitude:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}latitude'],
          )!,
      longitude:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}longitude'],
          )!,
      eventDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}event_date'],
          )!,
      maxAttendees:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}max_attendees'],
          )!,
      whatToBring: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}what_to_bring'],
      ),
      amenityTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amenity_tags'],
      ),
      isCancelled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_cancelled'],
      ),
    );
  }

  @override
  $EventsTableTable createAlias(String alias) {
    return $EventsTableTable(attachedDatabase, alias);
  }
}

class EventsTableData extends DataClass implements Insertable<EventsTableData> {
  final String id;
  final String hostId;
  final String type;
  final String title;
  final String? description;
  final String locationName;
  final double latitude;
  final double longitude;
  final String eventDate;
  final int maxAttendees;
  final String? whatToBring;
  final String? amenityTags;
  final int? isCancelled;
  const EventsTableData({
    required this.id,
    required this.hostId,
    required this.type,
    required this.title,
    this.description,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.eventDate,
    required this.maxAttendees,
    this.whatToBring,
    this.amenityTags,
    this.isCancelled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['host_id'] = Variable<String>(hostId);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['location_name'] = Variable<String>(locationName);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['event_date'] = Variable<String>(eventDate);
    map['max_attendees'] = Variable<int>(maxAttendees);
    if (!nullToAbsent || whatToBring != null) {
      map['what_to_bring'] = Variable<String>(whatToBring);
    }
    if (!nullToAbsent || amenityTags != null) {
      map['amenity_tags'] = Variable<String>(amenityTags);
    }
    if (!nullToAbsent || isCancelled != null) {
      map['is_cancelled'] = Variable<int>(isCancelled);
    }
    return map;
  }

  EventsTableCompanion toCompanion(bool nullToAbsent) {
    return EventsTableCompanion(
      id: Value(id),
      hostId: Value(hostId),
      type: Value(type),
      title: Value(title),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      locationName: Value(locationName),
      latitude: Value(latitude),
      longitude: Value(longitude),
      eventDate: Value(eventDate),
      maxAttendees: Value(maxAttendees),
      whatToBring:
          whatToBring == null && nullToAbsent
              ? const Value.absent()
              : Value(whatToBring),
      amenityTags:
          amenityTags == null && nullToAbsent
              ? const Value.absent()
              : Value(amenityTags),
      isCancelled:
          isCancelled == null && nullToAbsent
              ? const Value.absent()
              : Value(isCancelled),
    );
  }

  factory EventsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventsTableData(
      id: serializer.fromJson<String>(json['id']),
      hostId: serializer.fromJson<String>(json['hostId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      locationName: serializer.fromJson<String>(json['locationName']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      eventDate: serializer.fromJson<String>(json['eventDate']),
      maxAttendees: serializer.fromJson<int>(json['maxAttendees']),
      whatToBring: serializer.fromJson<String?>(json['whatToBring']),
      amenityTags: serializer.fromJson<String?>(json['amenityTags']),
      isCancelled: serializer.fromJson<int?>(json['isCancelled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hostId': serializer.toJson<String>(hostId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'locationName': serializer.toJson<String>(locationName),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'eventDate': serializer.toJson<String>(eventDate),
      'maxAttendees': serializer.toJson<int>(maxAttendees),
      'whatToBring': serializer.toJson<String?>(whatToBring),
      'amenityTags': serializer.toJson<String?>(amenityTags),
      'isCancelled': serializer.toJson<int?>(isCancelled),
    };
  }

  EventsTableData copyWith({
    String? id,
    String? hostId,
    String? type,
    String? title,
    Value<String?> description = const Value.absent(),
    String? locationName,
    double? latitude,
    double? longitude,
    String? eventDate,
    int? maxAttendees,
    Value<String?> whatToBring = const Value.absent(),
    Value<String?> amenityTags = const Value.absent(),
    Value<int?> isCancelled = const Value.absent(),
  }) => EventsTableData(
    id: id ?? this.id,
    hostId: hostId ?? this.hostId,
    type: type ?? this.type,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    locationName: locationName ?? this.locationName,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    eventDate: eventDate ?? this.eventDate,
    maxAttendees: maxAttendees ?? this.maxAttendees,
    whatToBring: whatToBring.present ? whatToBring.value : this.whatToBring,
    amenityTags: amenityTags.present ? amenityTags.value : this.amenityTags,
    isCancelled: isCancelled.present ? isCancelled.value : this.isCancelled,
  );
  EventsTableData copyWithCompanion(EventsTableCompanion data) {
    return EventsTableData(
      id: data.id.present ? data.id.value : this.id,
      hostId: data.hostId.present ? data.hostId.value : this.hostId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      locationName:
          data.locationName.present
              ? data.locationName.value
              : this.locationName,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      maxAttendees:
          data.maxAttendees.present
              ? data.maxAttendees.value
              : this.maxAttendees,
      whatToBring:
          data.whatToBring.present ? data.whatToBring.value : this.whatToBring,
      amenityTags:
          data.amenityTags.present ? data.amenityTags.value : this.amenityTags,
      isCancelled:
          data.isCancelled.present ? data.isCancelled.value : this.isCancelled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventsTableData(')
          ..write('id: $id, ')
          ..write('hostId: $hostId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('locationName: $locationName, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('eventDate: $eventDate, ')
          ..write('maxAttendees: $maxAttendees, ')
          ..write('whatToBring: $whatToBring, ')
          ..write('amenityTags: $amenityTags, ')
          ..write('isCancelled: $isCancelled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hostId,
    type,
    title,
    description,
    locationName,
    latitude,
    longitude,
    eventDate,
    maxAttendees,
    whatToBring,
    amenityTags,
    isCancelled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventsTableData &&
          other.id == this.id &&
          other.hostId == this.hostId &&
          other.type == this.type &&
          other.title == this.title &&
          other.description == this.description &&
          other.locationName == this.locationName &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.eventDate == this.eventDate &&
          other.maxAttendees == this.maxAttendees &&
          other.whatToBring == this.whatToBring &&
          other.amenityTags == this.amenityTags &&
          other.isCancelled == this.isCancelled);
}

class EventsTableCompanion extends UpdateCompanion<EventsTableData> {
  final Value<String> id;
  final Value<String> hostId;
  final Value<String> type;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> locationName;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> eventDate;
  final Value<int> maxAttendees;
  final Value<String?> whatToBring;
  final Value<String?> amenityTags;
  final Value<int?> isCancelled;
  final Value<int> rowid;
  const EventsTableCompanion({
    this.id = const Value.absent(),
    this.hostId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.locationName = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.maxAttendees = const Value.absent(),
    this.whatToBring = const Value.absent(),
    this.amenityTags = const Value.absent(),
    this.isCancelled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsTableCompanion.insert({
    required String id,
    required String hostId,
    required String type,
    required String title,
    this.description = const Value.absent(),
    required String locationName,
    required double latitude,
    required double longitude,
    required String eventDate,
    required int maxAttendees,
    this.whatToBring = const Value.absent(),
    this.amenityTags = const Value.absent(),
    this.isCancelled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hostId = Value(hostId),
       type = Value(type),
       title = Value(title),
       locationName = Value(locationName),
       latitude = Value(latitude),
       longitude = Value(longitude),
       eventDate = Value(eventDate),
       maxAttendees = Value(maxAttendees);
  static Insertable<EventsTableData> custom({
    Expression<String>? id,
    Expression<String>? hostId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? locationName,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? eventDate,
    Expression<int>? maxAttendees,
    Expression<String>? whatToBring,
    Expression<String>? amenityTags,
    Expression<int>? isCancelled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hostId != null) 'host_id': hostId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (locationName != null) 'location_name': locationName,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (eventDate != null) 'event_date': eventDate,
      if (maxAttendees != null) 'max_attendees': maxAttendees,
      if (whatToBring != null) 'what_to_bring': whatToBring,
      if (amenityTags != null) 'amenity_tags': amenityTags,
      if (isCancelled != null) 'is_cancelled': isCancelled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? hostId,
    Value<String>? type,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? locationName,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? eventDate,
    Value<int>? maxAttendees,
    Value<String?>? whatToBring,
    Value<String?>? amenityTags,
    Value<int?>? isCancelled,
    Value<int>? rowid,
  }) {
    return EventsTableCompanion(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      eventDate: eventDate ?? this.eventDate,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      whatToBring: whatToBring ?? this.whatToBring,
      amenityTags: amenityTags ?? this.amenityTags,
      isCancelled: isCancelled ?? this.isCancelled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hostId.present) {
      map['host_id'] = Variable<String>(hostId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<String>(eventDate.value);
    }
    if (maxAttendees.present) {
      map['max_attendees'] = Variable<int>(maxAttendees.value);
    }
    if (whatToBring.present) {
      map['what_to_bring'] = Variable<String>(whatToBring.value);
    }
    if (amenityTags.present) {
      map['amenity_tags'] = Variable<String>(amenityTags.value);
    }
    if (isCancelled.present) {
      map['is_cancelled'] = Variable<int>(isCancelled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsTableCompanion(')
          ..write('id: $id, ')
          ..write('hostId: $hostId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('locationName: $locationName, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('eventDate: $eventDate, ')
          ..write('maxAttendees: $maxAttendees, ')
          ..write('whatToBring: $whatToBring, ')
          ..write('amenityTags: $amenityTags, ')
          ..write('isCancelled: $isCancelled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTableTable extends ProfilesTable
    with TableInfo<$ProfilesTableTable, ProfilesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isVerifiedMeta = const VerificationMeta(
    'isVerified',
  );
  @override
  late final GeneratedColumn<int> isVerified = GeneratedColumn<int>(
    'is_verified',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trialRsvpsUsedMeta = const VerificationMeta(
    'trialRsvpsUsed',
  );
  @override
  late final GeneratedColumn<int> trialRsvpsUsed = GeneratedColumn<int>(
    'trial_rsvps_used',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFoundingPackMeta = const VerificationMeta(
    'isFoundingPack',
  );
  @override
  late final GeneratedColumn<int> isFoundingPack = GeneratedColumn<int>(
    'is_founding_pack',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSuspendedMeta = const VerificationMeta(
    'isSuspended',
  );
  @override
  late final GeneratedColumn<int> isSuspended = GeneratedColumn<int>(
    'is_suspended',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasSeenFieldIntroMeta = const VerificationMeta(
    'hasSeenFieldIntro',
  );
  @override
  late final GeneratedColumn<int> hasSeenFieldIntro = GeneratedColumn<int>(
    'has_seen_field_intro',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasSeenHostIntroMeta = const VerificationMeta(
    'hasSeenHostIntro',
  );
  @override
  late final GeneratedColumn<int> hasSeenHostIntro = GeneratedColumn<int>(
    'has_seen_host_intro',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _treatPolicyMeta = const VerificationMeta(
    'treatPolicy',
  );
  @override
  late final GeneratedColumn<String> treatPolicy = GeneratedColumn<String>(
    'treat_policy',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    displayName,
    photoUrl,
    isVerified,
    trialRsvpsUsed,
    isFoundingPack,
    isSuspended,
    hasSeenFieldIntro,
    hasSeenHostIntro,
    treatPolicy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfilesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('is_verified')) {
      context.handle(
        _isVerifiedMeta,
        isVerified.isAcceptableOrUnknown(data['is_verified']!, _isVerifiedMeta),
      );
    }
    if (data.containsKey('trial_rsvps_used')) {
      context.handle(
        _trialRsvpsUsedMeta,
        trialRsvpsUsed.isAcceptableOrUnknown(
          data['trial_rsvps_used']!,
          _trialRsvpsUsedMeta,
        ),
      );
    }
    if (data.containsKey('is_founding_pack')) {
      context.handle(
        _isFoundingPackMeta,
        isFoundingPack.isAcceptableOrUnknown(
          data['is_founding_pack']!,
          _isFoundingPackMeta,
        ),
      );
    }
    if (data.containsKey('is_suspended')) {
      context.handle(
        _isSuspendedMeta,
        isSuspended.isAcceptableOrUnknown(
          data['is_suspended']!,
          _isSuspendedMeta,
        ),
      );
    }
    if (data.containsKey('has_seen_field_intro')) {
      context.handle(
        _hasSeenFieldIntroMeta,
        hasSeenFieldIntro.isAcceptableOrUnknown(
          data['has_seen_field_intro']!,
          _hasSeenFieldIntroMeta,
        ),
      );
    }
    if (data.containsKey('has_seen_host_intro')) {
      context.handle(
        _hasSeenHostIntroMeta,
        hasSeenHostIntro.isAcceptableOrUnknown(
          data['has_seen_host_intro']!,
          _hasSeenHostIntroMeta,
        ),
      );
    }
    if (data.containsKey('treat_policy')) {
      context.handle(
        _treatPolicyMeta,
        treatPolicy.isAcceptableOrUnknown(
          data['treat_policy']!,
          _treatPolicyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfilesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfilesTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      email:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}email'],
          )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      isVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_verified'],
      ),
      trialRsvpsUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trial_rsvps_used'],
      ),
      isFoundingPack: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_founding_pack'],
      ),
      isSuspended: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_suspended'],
      ),
      hasSeenFieldIntro: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}has_seen_field_intro'],
      ),
      hasSeenHostIntro: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}has_seen_host_intro'],
      ),
      treatPolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treat_policy'],
      ),
    );
  }

  @override
  $ProfilesTableTable createAlias(String alias) {
    return $ProfilesTableTable(attachedDatabase, alias);
  }
}

class ProfilesTableData extends DataClass
    implements Insertable<ProfilesTableData> {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final int? isVerified;
  final int? trialRsvpsUsed;
  final int? isFoundingPack;
  final int? isSuspended;
  final int? hasSeenFieldIntro;
  final int? hasSeenHostIntro;
  final String? treatPolicy;
  const ProfilesTableData({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isVerified,
    this.trialRsvpsUsed,
    this.isFoundingPack,
    this.isSuspended,
    this.hasSeenFieldIntro,
    this.hasSeenHostIntro,
    this.treatPolicy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || isVerified != null) {
      map['is_verified'] = Variable<int>(isVerified);
    }
    if (!nullToAbsent || trialRsvpsUsed != null) {
      map['trial_rsvps_used'] = Variable<int>(trialRsvpsUsed);
    }
    if (!nullToAbsent || isFoundingPack != null) {
      map['is_founding_pack'] = Variable<int>(isFoundingPack);
    }
    if (!nullToAbsent || isSuspended != null) {
      map['is_suspended'] = Variable<int>(isSuspended);
    }
    if (!nullToAbsent || hasSeenFieldIntro != null) {
      map['has_seen_field_intro'] = Variable<int>(hasSeenFieldIntro);
    }
    if (!nullToAbsent || hasSeenHostIntro != null) {
      map['has_seen_host_intro'] = Variable<int>(hasSeenHostIntro);
    }
    if (!nullToAbsent || treatPolicy != null) {
      map['treat_policy'] = Variable<String>(treatPolicy);
    }
    return map;
  }

  ProfilesTableCompanion toCompanion(bool nullToAbsent) {
    return ProfilesTableCompanion(
      id: Value(id),
      email: Value(email),
      displayName:
          displayName == null && nullToAbsent
              ? const Value.absent()
              : Value(displayName),
      photoUrl:
          photoUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(photoUrl),
      isVerified:
          isVerified == null && nullToAbsent
              ? const Value.absent()
              : Value(isVerified),
      trialRsvpsUsed:
          trialRsvpsUsed == null && nullToAbsent
              ? const Value.absent()
              : Value(trialRsvpsUsed),
      isFoundingPack:
          isFoundingPack == null && nullToAbsent
              ? const Value.absent()
              : Value(isFoundingPack),
      isSuspended:
          isSuspended == null && nullToAbsent
              ? const Value.absent()
              : Value(isSuspended),
      hasSeenFieldIntro:
          hasSeenFieldIntro == null && nullToAbsent
              ? const Value.absent()
              : Value(hasSeenFieldIntro),
      hasSeenHostIntro:
          hasSeenHostIntro == null && nullToAbsent
              ? const Value.absent()
              : Value(hasSeenHostIntro),
      treatPolicy:
          treatPolicy == null && nullToAbsent
              ? const Value.absent()
              : Value(treatPolicy),
    );
  }

  factory ProfilesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfilesTableData(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      isVerified: serializer.fromJson<int?>(json['isVerified']),
      trialRsvpsUsed: serializer.fromJson<int?>(json['trialRsvpsUsed']),
      isFoundingPack: serializer.fromJson<int?>(json['isFoundingPack']),
      isSuspended: serializer.fromJson<int?>(json['isSuspended']),
      hasSeenFieldIntro: serializer.fromJson<int?>(json['hasSeenFieldIntro']),
      hasSeenHostIntro: serializer.fromJson<int?>(json['hasSeenHostIntro']),
      treatPolicy: serializer.fromJson<String?>(json['treatPolicy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'displayName': serializer.toJson<String?>(displayName),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'isVerified': serializer.toJson<int?>(isVerified),
      'trialRsvpsUsed': serializer.toJson<int?>(trialRsvpsUsed),
      'isFoundingPack': serializer.toJson<int?>(isFoundingPack),
      'isSuspended': serializer.toJson<int?>(isSuspended),
      'hasSeenFieldIntro': serializer.toJson<int?>(hasSeenFieldIntro),
      'hasSeenHostIntro': serializer.toJson<int?>(hasSeenHostIntro),
      'treatPolicy': serializer.toJson<String?>(treatPolicy),
    };
  }

  ProfilesTableData copyWith({
    String? id,
    String? email,
    Value<String?> displayName = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    Value<int?> isVerified = const Value.absent(),
    Value<int?> trialRsvpsUsed = const Value.absent(),
    Value<int?> isFoundingPack = const Value.absent(),
    Value<int?> isSuspended = const Value.absent(),
    Value<int?> hasSeenFieldIntro = const Value.absent(),
    Value<int?> hasSeenHostIntro = const Value.absent(),
    Value<String?> treatPolicy = const Value.absent(),
  }) => ProfilesTableData(
    id: id ?? this.id,
    email: email ?? this.email,
    displayName: displayName.present ? displayName.value : this.displayName,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    isVerified: isVerified.present ? isVerified.value : this.isVerified,
    trialRsvpsUsed:
        trialRsvpsUsed.present ? trialRsvpsUsed.value : this.trialRsvpsUsed,
    isFoundingPack:
        isFoundingPack.present ? isFoundingPack.value : this.isFoundingPack,
    isSuspended: isSuspended.present ? isSuspended.value : this.isSuspended,
    hasSeenFieldIntro:
        hasSeenFieldIntro.present
            ? hasSeenFieldIntro.value
            : this.hasSeenFieldIntro,
    hasSeenHostIntro:
        hasSeenHostIntro.present
            ? hasSeenHostIntro.value
            : this.hasSeenHostIntro,
    treatPolicy: treatPolicy.present ? treatPolicy.value : this.treatPolicy,
  );
  ProfilesTableData copyWithCompanion(ProfilesTableCompanion data) {
    return ProfilesTableData(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      isVerified:
          data.isVerified.present ? data.isVerified.value : this.isVerified,
      trialRsvpsUsed:
          data.trialRsvpsUsed.present
              ? data.trialRsvpsUsed.value
              : this.trialRsvpsUsed,
      isFoundingPack:
          data.isFoundingPack.present
              ? data.isFoundingPack.value
              : this.isFoundingPack,
      isSuspended:
          data.isSuspended.present ? data.isSuspended.value : this.isSuspended,
      hasSeenFieldIntro:
          data.hasSeenFieldIntro.present
              ? data.hasSeenFieldIntro.value
              : this.hasSeenFieldIntro,
      hasSeenHostIntro:
          data.hasSeenHostIntro.present
              ? data.hasSeenHostIntro.value
              : this.hasSeenHostIntro,
      treatPolicy:
          data.treatPolicy.present ? data.treatPolicy.value : this.treatPolicy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesTableData(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('isVerified: $isVerified, ')
          ..write('trialRsvpsUsed: $trialRsvpsUsed, ')
          ..write('isFoundingPack: $isFoundingPack, ')
          ..write('isSuspended: $isSuspended, ')
          ..write('hasSeenFieldIntro: $hasSeenFieldIntro, ')
          ..write('hasSeenHostIntro: $hasSeenHostIntro, ')
          ..write('treatPolicy: $treatPolicy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    displayName,
    photoUrl,
    isVerified,
    trialRsvpsUsed,
    isFoundingPack,
    isSuspended,
    hasSeenFieldIntro,
    hasSeenHostIntro,
    treatPolicy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfilesTableData &&
          other.id == this.id &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.photoUrl == this.photoUrl &&
          other.isVerified == this.isVerified &&
          other.trialRsvpsUsed == this.trialRsvpsUsed &&
          other.isFoundingPack == this.isFoundingPack &&
          other.isSuspended == this.isSuspended &&
          other.hasSeenFieldIntro == this.hasSeenFieldIntro &&
          other.hasSeenHostIntro == this.hasSeenHostIntro &&
          other.treatPolicy == this.treatPolicy);
}

class ProfilesTableCompanion extends UpdateCompanion<ProfilesTableData> {
  final Value<String> id;
  final Value<String> email;
  final Value<String?> displayName;
  final Value<String?> photoUrl;
  final Value<int?> isVerified;
  final Value<int?> trialRsvpsUsed;
  final Value<int?> isFoundingPack;
  final Value<int?> isSuspended;
  final Value<int?> hasSeenFieldIntro;
  final Value<int?> hasSeenHostIntro;
  final Value<String?> treatPolicy;
  final Value<int> rowid;
  const ProfilesTableCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.trialRsvpsUsed = const Value.absent(),
    this.isFoundingPack = const Value.absent(),
    this.isSuspended = const Value.absent(),
    this.hasSeenFieldIntro = const Value.absent(),
    this.hasSeenHostIntro = const Value.absent(),
    this.treatPolicy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesTableCompanion.insert({
    required String id,
    required String email,
    this.displayName = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.trialRsvpsUsed = const Value.absent(),
    this.isFoundingPack = const Value.absent(),
    this.isSuspended = const Value.absent(),
    this.hasSeenFieldIntro = const Value.absent(),
    this.hasSeenHostIntro = const Value.absent(),
    this.treatPolicy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email);
  static Insertable<ProfilesTableData> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<String>? photoUrl,
    Expression<int>? isVerified,
    Expression<int>? trialRsvpsUsed,
    Expression<int>? isFoundingPack,
    Expression<int>? isSuspended,
    Expression<int>? hasSeenFieldIntro,
    Expression<int>? hasSeenHostIntro,
    Expression<String>? treatPolicy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (isVerified != null) 'is_verified': isVerified,
      if (trialRsvpsUsed != null) 'trial_rsvps_used': trialRsvpsUsed,
      if (isFoundingPack != null) 'is_founding_pack': isFoundingPack,
      if (isSuspended != null) 'is_suspended': isSuspended,
      if (hasSeenFieldIntro != null) 'has_seen_field_intro': hasSeenFieldIntro,
      if (hasSeenHostIntro != null) 'has_seen_host_intro': hasSeenHostIntro,
      if (treatPolicy != null) 'treat_policy': treatPolicy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String?>? displayName,
    Value<String?>? photoUrl,
    Value<int?>? isVerified,
    Value<int?>? trialRsvpsUsed,
    Value<int?>? isFoundingPack,
    Value<int?>? isSuspended,
    Value<int?>? hasSeenFieldIntro,
    Value<int?>? hasSeenHostIntro,
    Value<String?>? treatPolicy,
    Value<int>? rowid,
  }) {
    return ProfilesTableCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      trialRsvpsUsed: trialRsvpsUsed ?? this.trialRsvpsUsed,
      isFoundingPack: isFoundingPack ?? this.isFoundingPack,
      isSuspended: isSuspended ?? this.isSuspended,
      hasSeenFieldIntro: hasSeenFieldIntro ?? this.hasSeenFieldIntro,
      hasSeenHostIntro: hasSeenHostIntro ?? this.hasSeenHostIntro,
      treatPolicy: treatPolicy ?? this.treatPolicy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (isVerified.present) {
      map['is_verified'] = Variable<int>(isVerified.value);
    }
    if (trialRsvpsUsed.present) {
      map['trial_rsvps_used'] = Variable<int>(trialRsvpsUsed.value);
    }
    if (isFoundingPack.present) {
      map['is_founding_pack'] = Variable<int>(isFoundingPack.value);
    }
    if (isSuspended.present) {
      map['is_suspended'] = Variable<int>(isSuspended.value);
    }
    if (hasSeenFieldIntro.present) {
      map['has_seen_field_intro'] = Variable<int>(hasSeenFieldIntro.value);
    }
    if (hasSeenHostIntro.present) {
      map['has_seen_host_intro'] = Variable<int>(hasSeenHostIntro.value);
    }
    if (treatPolicy.present) {
      map['treat_policy'] = Variable<String>(treatPolicy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesTableCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('isVerified: $isVerified, ')
          ..write('trialRsvpsUsed: $trialRsvpsUsed, ')
          ..write('isFoundingPack: $isFoundingPack, ')
          ..write('isSuspended: $isSuspended, ')
          ..write('hasSeenFieldIntro: $hasSeenFieldIntro, ')
          ..write('hasSeenHostIntro: $hasSeenHostIntro, ')
          ..write('treatPolicy: $treatPolicy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DogsTableTable extends DogsTable
    with TableInfo<$DogsTableTable, DogsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
    'breed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vibeMeta = const VerificationMeta('vibe');
  @override
  late final GeneratedColumn<String> vibe = GeneratedColumn<String>(
    'vibe',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _icebreakerAnswerMeta = const VerificationMeta(
    'icebreakerAnswer',
  );
  @override
  late final GeneratedColumn<String> icebreakerAnswer = GeneratedColumn<String>(
    'icebreaker_answer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    name,
    age,
    breed,
    vibe,
    icebreakerAnswer,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dogs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DogsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    }
    if (data.containsKey('breed')) {
      context.handle(
        _breedMeta,
        breed.isAcceptableOrUnknown(data['breed']!, _breedMeta),
      );
    }
    if (data.containsKey('vibe')) {
      context.handle(
        _vibeMeta,
        vibe.isAcceptableOrUnknown(data['vibe']!, _vibeMeta),
      );
    }
    if (data.containsKey('icebreaker_answer')) {
      context.handle(
        _icebreakerAnswerMeta,
        icebreakerAnswer.isAcceptableOrUnknown(
          data['icebreaker_answer']!,
          _icebreakerAnswerMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DogsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DogsTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      ownerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}owner_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      ),
      breed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breed'],
      ),
      vibe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vibe'],
      ),
      icebreakerAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icebreaker_answer'],
      ),
    );
  }

  @override
  $DogsTableTable createAlias(String alias) {
    return $DogsTableTable(attachedDatabase, alias);
  }
}

class DogsTableData extends DataClass implements Insertable<DogsTableData> {
  final String id;
  final String ownerId;
  final String name;
  final int? age;
  final String? breed;
  final String? vibe;
  final String? icebreakerAnswer;
  const DogsTableData({
    required this.id,
    required this.ownerId,
    required this.name,
    this.age,
    this.breed,
    this.vibe,
    this.icebreakerAnswer,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || breed != null) {
      map['breed'] = Variable<String>(breed);
    }
    if (!nullToAbsent || vibe != null) {
      map['vibe'] = Variable<String>(vibe);
    }
    if (!nullToAbsent || icebreakerAnswer != null) {
      map['icebreaker_answer'] = Variable<String>(icebreakerAnswer);
    }
    return map;
  }

  DogsTableCompanion toCompanion(bool nullToAbsent) {
    return DogsTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(name),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      breed:
          breed == null && nullToAbsent ? const Value.absent() : Value(breed),
      vibe: vibe == null && nullToAbsent ? const Value.absent() : Value(vibe),
      icebreakerAnswer:
          icebreakerAnswer == null && nullToAbsent
              ? const Value.absent()
              : Value(icebreakerAnswer),
    );
  }

  factory DogsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DogsTableData(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      age: serializer.fromJson<int?>(json['age']),
      breed: serializer.fromJson<String?>(json['breed']),
      vibe: serializer.fromJson<String?>(json['vibe']),
      icebreakerAnswer: serializer.fromJson<String?>(json['icebreakerAnswer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'age': serializer.toJson<int?>(age),
      'breed': serializer.toJson<String?>(breed),
      'vibe': serializer.toJson<String?>(vibe),
      'icebreakerAnswer': serializer.toJson<String?>(icebreakerAnswer),
    };
  }

  DogsTableData copyWith({
    String? id,
    String? ownerId,
    String? name,
    Value<int?> age = const Value.absent(),
    Value<String?> breed = const Value.absent(),
    Value<String?> vibe = const Value.absent(),
    Value<String?> icebreakerAnswer = const Value.absent(),
  }) => DogsTableData(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
    age: age.present ? age.value : this.age,
    breed: breed.present ? breed.value : this.breed,
    vibe: vibe.present ? vibe.value : this.vibe,
    icebreakerAnswer:
        icebreakerAnswer.present
            ? icebreakerAnswer.value
            : this.icebreakerAnswer,
  );
  DogsTableData copyWithCompanion(DogsTableCompanion data) {
    return DogsTableData(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      age: data.age.present ? data.age.value : this.age,
      breed: data.breed.present ? data.breed.value : this.breed,
      vibe: data.vibe.present ? data.vibe.value : this.vibe,
      icebreakerAnswer:
          data.icebreakerAnswer.present
              ? data.icebreakerAnswer.value
              : this.icebreakerAnswer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DogsTableData(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('breed: $breed, ')
          ..write('vibe: $vibe, ')
          ..write('icebreakerAnswer: $icebreakerAnswer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ownerId, name, age, breed, vibe, icebreakerAnswer);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DogsTableData &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.age == this.age &&
          other.breed == this.breed &&
          other.vibe == this.vibe &&
          other.icebreakerAnswer == this.icebreakerAnswer);
}

class DogsTableCompanion extends UpdateCompanion<DogsTableData> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<int?> age;
  final Value<String?> breed;
  final Value<String?> vibe;
  final Value<String?> icebreakerAnswer;
  final Value<int> rowid;
  const DogsTableCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.breed = const Value.absent(),
    this.vibe = const Value.absent(),
    this.icebreakerAnswer = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DogsTableCompanion.insert({
    required String id,
    required String ownerId,
    required String name,
    this.age = const Value.absent(),
    this.breed = const Value.absent(),
    this.vibe = const Value.absent(),
    this.icebreakerAnswer = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       name = Value(name);
  static Insertable<DogsTableData> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<int>? age,
    Expression<String>? breed,
    Expression<String>? vibe,
    Expression<String>? icebreakerAnswer,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (breed != null) 'breed': breed,
      if (vibe != null) 'vibe': vibe,
      if (icebreakerAnswer != null) 'icebreaker_answer': icebreakerAnswer,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DogsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? name,
    Value<int?>? age,
    Value<String?>? breed,
    Value<String?>? vibe,
    Value<String?>? icebreakerAnswer,
    Value<int>? rowid,
  }) {
    return DogsTableCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      age: age ?? this.age,
      breed: breed ?? this.breed,
      vibe: vibe ?? this.vibe,
      icebreakerAnswer: icebreakerAnswer ?? this.icebreakerAnswer,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (vibe.present) {
      map['vibe'] = Variable<String>(vibe.value);
    }
    if (icebreakerAnswer.present) {
      map['icebreaker_answer'] = Variable<String>(icebreakerAnswer.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DogsTableCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('breed: $breed, ')
          ..write('vibe: $vibe, ')
          ..write('icebreakerAnswer: $icebreakerAnswer, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttendanceTableTable extends AttendanceTable
    with TableInfo<$AttendanceTableTable, AttendanceTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [eventId, userId, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId, userId};
  @override
  AttendanceTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceTableData(
      eventId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}event_id'],
          )!,
      userId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}user_id'],
          )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
    );
  }

  @override
  $AttendanceTableTable createAlias(String alias) {
    return $AttendanceTableTable(attachedDatabase, alias);
  }
}

class AttendanceTableData extends DataClass
    implements Insertable<AttendanceTableData> {
  final String eventId;
  final String userId;
  final String? status;
  const AttendanceTableData({
    required this.eventId,
    required this.userId,
    this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    return map;
  }

  AttendanceTableCompanion toCompanion(bool nullToAbsent) {
    return AttendanceTableCompanion(
      eventId: Value(eventId),
      userId: Value(userId),
      status:
          status == null && nullToAbsent ? const Value.absent() : Value(status),
    );
  }

  factory AttendanceTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceTableData(
      eventId: serializer.fromJson<String>(json['eventId']),
      userId: serializer.fromJson<String>(json['userId']),
      status: serializer.fromJson<String?>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'userId': serializer.toJson<String>(userId),
      'status': serializer.toJson<String?>(status),
    };
  }

  AttendanceTableData copyWith({
    String? eventId,
    String? userId,
    Value<String?> status = const Value.absent(),
  }) => AttendanceTableData(
    eventId: eventId ?? this.eventId,
    userId: userId ?? this.userId,
    status: status.present ? status.value : this.status,
  );
  AttendanceTableData copyWithCompanion(AttendanceTableCompanion data) {
    return AttendanceTableData(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      userId: data.userId.present ? data.userId.value : this.userId,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceTableData(')
          ..write('eventId: $eventId, ')
          ..write('userId: $userId, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, userId, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceTableData &&
          other.eventId == this.eventId &&
          other.userId == this.userId &&
          other.status == this.status);
}

class AttendanceTableCompanion extends UpdateCompanion<AttendanceTableData> {
  final Value<String> eventId;
  final Value<String> userId;
  final Value<String?> status;
  final Value<int> rowid;
  const AttendanceTableCompanion({
    this.eventId = const Value.absent(),
    this.userId = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttendanceTableCompanion.insert({
    required String eventId,
    required String userId,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       userId = Value(userId);
  static Insertable<AttendanceTableData> custom({
    Expression<String>? eventId,
    Expression<String>? userId,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (userId != null) 'user_id': userId,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttendanceTableCompanion copyWith({
    Value<String>? eventId,
    Value<String>? userId,
    Value<String?>? status,
    Value<int>? rowid,
  }) {
    return AttendanceTableCompanion(
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceTableCompanion(')
          ..write('eventId: $eventId, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EventsTableTable eventsTable = $EventsTableTable(this);
  late final $ProfilesTableTable profilesTable = $ProfilesTableTable(this);
  late final $DogsTableTable dogsTable = $DogsTableTable(this);
  late final $AttendanceTableTable attendanceTable = $AttendanceTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    eventsTable,
    profilesTable,
    dogsTable,
    attendanceTable,
  ];
}

typedef $$EventsTableTableCreateCompanionBuilder =
    EventsTableCompanion Function({
      required String id,
      required String hostId,
      required String type,
      required String title,
      Value<String?> description,
      required String locationName,
      required double latitude,
      required double longitude,
      required String eventDate,
      required int maxAttendees,
      Value<String?> whatToBring,
      Value<String?> amenityTags,
      Value<int?> isCancelled,
      Value<int> rowid,
    });
typedef $$EventsTableTableUpdateCompanionBuilder =
    EventsTableCompanion Function({
      Value<String> id,
      Value<String> hostId,
      Value<String> type,
      Value<String> title,
      Value<String?> description,
      Value<String> locationName,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> eventDate,
      Value<int> maxAttendees,
      Value<String?> whatToBring,
      Value<String?> amenityTags,
      Value<int?> isCancelled,
      Value<int> rowid,
    });

class $$EventsTableTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTableTable> {
  $$EventsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hostId => $composableBuilder(
    column: $table.hostId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxAttendees => $composableBuilder(
    column: $table.maxAttendees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatToBring => $composableBuilder(
    column: $table.whatToBring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amenityTags => $composableBuilder(
    column: $table.amenityTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isCancelled => $composableBuilder(
    column: $table.isCancelled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTableTable> {
  $$EventsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hostId => $composableBuilder(
    column: $table.hostId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxAttendees => $composableBuilder(
    column: $table.maxAttendees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatToBring => $composableBuilder(
    column: $table.whatToBring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amenityTags => $composableBuilder(
    column: $table.amenityTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isCancelled => $composableBuilder(
    column: $table.isCancelled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTableTable> {
  $$EventsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get hostId =>
      $composableBuilder(column: $table.hostId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<int> get maxAttendees => $composableBuilder(
    column: $table.maxAttendees,
    builder: (column) => column,
  );

  GeneratedColumn<String> get whatToBring => $composableBuilder(
    column: $table.whatToBring,
    builder: (column) => column,
  );

  GeneratedColumn<String> get amenityTags => $composableBuilder(
    column: $table.amenityTags,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isCancelled => $composableBuilder(
    column: $table.isCancelled,
    builder: (column) => column,
  );
}

class $$EventsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTableTable,
          EventsTableData,
          $$EventsTableTableFilterComposer,
          $$EventsTableTableOrderingComposer,
          $$EventsTableTableAnnotationComposer,
          $$EventsTableTableCreateCompanionBuilder,
          $$EventsTableTableUpdateCompanionBuilder,
          (
            EventsTableData,
            BaseReferences<_$AppDatabase, $EventsTableTable, EventsTableData>,
          ),
          EventsTableData,
          PrefetchHooks Function()
        > {
  $$EventsTableTableTableManager(_$AppDatabase db, $EventsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$EventsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$EventsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$EventsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> hostId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> locationName = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> eventDate = const Value.absent(),
                Value<int> maxAttendees = const Value.absent(),
                Value<String?> whatToBring = const Value.absent(),
                Value<String?> amenityTags = const Value.absent(),
                Value<int?> isCancelled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsTableCompanion(
                id: id,
                hostId: hostId,
                type: type,
                title: title,
                description: description,
                locationName: locationName,
                latitude: latitude,
                longitude: longitude,
                eventDate: eventDate,
                maxAttendees: maxAttendees,
                whatToBring: whatToBring,
                amenityTags: amenityTags,
                isCancelled: isCancelled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String hostId,
                required String type,
                required String title,
                Value<String?> description = const Value.absent(),
                required String locationName,
                required double latitude,
                required double longitude,
                required String eventDate,
                required int maxAttendees,
                Value<String?> whatToBring = const Value.absent(),
                Value<String?> amenityTags = const Value.absent(),
                Value<int?> isCancelled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsTableCompanion.insert(
                id: id,
                hostId: hostId,
                type: type,
                title: title,
                description: description,
                locationName: locationName,
                latitude: latitude,
                longitude: longitude,
                eventDate: eventDate,
                maxAttendees: maxAttendees,
                whatToBring: whatToBring,
                amenityTags: amenityTags,
                isCancelled: isCancelled,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTableTable,
      EventsTableData,
      $$EventsTableTableFilterComposer,
      $$EventsTableTableOrderingComposer,
      $$EventsTableTableAnnotationComposer,
      $$EventsTableTableCreateCompanionBuilder,
      $$EventsTableTableUpdateCompanionBuilder,
      (
        EventsTableData,
        BaseReferences<_$AppDatabase, $EventsTableTable, EventsTableData>,
      ),
      EventsTableData,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableTableCreateCompanionBuilder =
    ProfilesTableCompanion Function({
      required String id,
      required String email,
      Value<String?> displayName,
      Value<String?> photoUrl,
      Value<int?> isVerified,
      Value<int?> trialRsvpsUsed,
      Value<int?> isFoundingPack,
      Value<int?> isSuspended,
      Value<int?> hasSeenFieldIntro,
      Value<int?> hasSeenHostIntro,
      Value<String?> treatPolicy,
      Value<int> rowid,
    });
typedef $$ProfilesTableTableUpdateCompanionBuilder =
    ProfilesTableCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String?> displayName,
      Value<String?> photoUrl,
      Value<int?> isVerified,
      Value<int?> trialRsvpsUsed,
      Value<int?> isFoundingPack,
      Value<int?> isSuspended,
      Value<int?> hasSeenFieldIntro,
      Value<int?> hasSeenHostIntro,
      Value<String?> treatPolicy,
      Value<int> rowid,
    });

class $$ProfilesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTableTable> {
  $$ProfilesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trialRsvpsUsed => $composableBuilder(
    column: $table.trialRsvpsUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isFoundingPack => $composableBuilder(
    column: $table.isFoundingPack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isSuspended => $composableBuilder(
    column: $table.isSuspended,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hasSeenFieldIntro => $composableBuilder(
    column: $table.hasSeenFieldIntro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hasSeenHostIntro => $composableBuilder(
    column: $table.hasSeenHostIntro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get treatPolicy => $composableBuilder(
    column: $table.treatPolicy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTableTable> {
  $$ProfilesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trialRsvpsUsed => $composableBuilder(
    column: $table.trialRsvpsUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isFoundingPack => $composableBuilder(
    column: $table.isFoundingPack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isSuspended => $composableBuilder(
    column: $table.isSuspended,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hasSeenFieldIntro => $composableBuilder(
    column: $table.hasSeenFieldIntro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hasSeenHostIntro => $composableBuilder(
    column: $table.hasSeenHostIntro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get treatPolicy => $composableBuilder(
    column: $table.treatPolicy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTableTable> {
  $$ProfilesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<int> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trialRsvpsUsed => $composableBuilder(
    column: $table.trialRsvpsUsed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isFoundingPack => $composableBuilder(
    column: $table.isFoundingPack,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isSuspended => $composableBuilder(
    column: $table.isSuspended,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hasSeenFieldIntro => $composableBuilder(
    column: $table.hasSeenFieldIntro,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hasSeenHostIntro => $composableBuilder(
    column: $table.hasSeenHostIntro,
    builder: (column) => column,
  );

  GeneratedColumn<String> get treatPolicy => $composableBuilder(
    column: $table.treatPolicy,
    builder: (column) => column,
  );
}

class $$ProfilesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTableTable,
          ProfilesTableData,
          $$ProfilesTableTableFilterComposer,
          $$ProfilesTableTableOrderingComposer,
          $$ProfilesTableTableAnnotationComposer,
          $$ProfilesTableTableCreateCompanionBuilder,
          $$ProfilesTableTableUpdateCompanionBuilder,
          (
            ProfilesTableData,
            BaseReferences<
              _$AppDatabase,
              $ProfilesTableTable,
              ProfilesTableData
            >,
          ),
          ProfilesTableData,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableTableManager(_$AppDatabase db, $ProfilesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ProfilesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$ProfilesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ProfilesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<int?> isVerified = const Value.absent(),
                Value<int?> trialRsvpsUsed = const Value.absent(),
                Value<int?> isFoundingPack = const Value.absent(),
                Value<int?> isSuspended = const Value.absent(),
                Value<int?> hasSeenFieldIntro = const Value.absent(),
                Value<int?> hasSeenHostIntro = const Value.absent(),
                Value<String?> treatPolicy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesTableCompanion(
                id: id,
                email: email,
                displayName: displayName,
                photoUrl: photoUrl,
                isVerified: isVerified,
                trialRsvpsUsed: trialRsvpsUsed,
                isFoundingPack: isFoundingPack,
                isSuspended: isSuspended,
                hasSeenFieldIntro: hasSeenFieldIntro,
                hasSeenHostIntro: hasSeenHostIntro,
                treatPolicy: treatPolicy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                Value<String?> displayName = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<int?> isVerified = const Value.absent(),
                Value<int?> trialRsvpsUsed = const Value.absent(),
                Value<int?> isFoundingPack = const Value.absent(),
                Value<int?> isSuspended = const Value.absent(),
                Value<int?> hasSeenFieldIntro = const Value.absent(),
                Value<int?> hasSeenHostIntro = const Value.absent(),
                Value<String?> treatPolicy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesTableCompanion.insert(
                id: id,
                email: email,
                displayName: displayName,
                photoUrl: photoUrl,
                isVerified: isVerified,
                trialRsvpsUsed: trialRsvpsUsed,
                isFoundingPack: isFoundingPack,
                isSuspended: isSuspended,
                hasSeenFieldIntro: hasSeenFieldIntro,
                hasSeenHostIntro: hasSeenHostIntro,
                treatPolicy: treatPolicy,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTableTable,
      ProfilesTableData,
      $$ProfilesTableTableFilterComposer,
      $$ProfilesTableTableOrderingComposer,
      $$ProfilesTableTableAnnotationComposer,
      $$ProfilesTableTableCreateCompanionBuilder,
      $$ProfilesTableTableUpdateCompanionBuilder,
      (
        ProfilesTableData,
        BaseReferences<_$AppDatabase, $ProfilesTableTable, ProfilesTableData>,
      ),
      ProfilesTableData,
      PrefetchHooks Function()
    >;
typedef $$DogsTableTableCreateCompanionBuilder =
    DogsTableCompanion Function({
      required String id,
      required String ownerId,
      required String name,
      Value<int?> age,
      Value<String?> breed,
      Value<String?> vibe,
      Value<String?> icebreakerAnswer,
      Value<int> rowid,
    });
typedef $$DogsTableTableUpdateCompanionBuilder =
    DogsTableCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> name,
      Value<int?> age,
      Value<String?> breed,
      Value<String?> vibe,
      Value<String?> icebreakerAnswer,
      Value<int> rowid,
    });

class $$DogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DogsTableTable> {
  $$DogsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vibe => $composableBuilder(
    column: $table.vibe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icebreakerAnswer => $composableBuilder(
    column: $table.icebreakerAnswer,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DogsTableTable> {
  $$DogsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vibe => $composableBuilder(
    column: $table.vibe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icebreakerAnswer => $composableBuilder(
    column: $table.icebreakerAnswer,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DogsTableTable> {
  $$DogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<String> get vibe =>
      $composableBuilder(column: $table.vibe, builder: (column) => column);

  GeneratedColumn<String> get icebreakerAnswer => $composableBuilder(
    column: $table.icebreakerAnswer,
    builder: (column) => column,
  );
}

class $$DogsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DogsTableTable,
          DogsTableData,
          $$DogsTableTableFilterComposer,
          $$DogsTableTableOrderingComposer,
          $$DogsTableTableAnnotationComposer,
          $$DogsTableTableCreateCompanionBuilder,
          $$DogsTableTableUpdateCompanionBuilder,
          (
            DogsTableData,
            BaseReferences<_$AppDatabase, $DogsTableTable, DogsTableData>,
          ),
          DogsTableData,
          PrefetchHooks Function()
        > {
  $$DogsTableTableTableManager(_$AppDatabase db, $DogsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$DogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$DogsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$DogsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<String?> breed = const Value.absent(),
                Value<String?> vibe = const Value.absent(),
                Value<String?> icebreakerAnswer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DogsTableCompanion(
                id: id,
                ownerId: ownerId,
                name: name,
                age: age,
                breed: breed,
                vibe: vibe,
                icebreakerAnswer: icebreakerAnswer,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String name,
                Value<int?> age = const Value.absent(),
                Value<String?> breed = const Value.absent(),
                Value<String?> vibe = const Value.absent(),
                Value<String?> icebreakerAnswer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DogsTableCompanion.insert(
                id: id,
                ownerId: ownerId,
                name: name,
                age: age,
                breed: breed,
                vibe: vibe,
                icebreakerAnswer: icebreakerAnswer,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DogsTableTable,
      DogsTableData,
      $$DogsTableTableFilterComposer,
      $$DogsTableTableOrderingComposer,
      $$DogsTableTableAnnotationComposer,
      $$DogsTableTableCreateCompanionBuilder,
      $$DogsTableTableUpdateCompanionBuilder,
      (
        DogsTableData,
        BaseReferences<_$AppDatabase, $DogsTableTable, DogsTableData>,
      ),
      DogsTableData,
      PrefetchHooks Function()
    >;
typedef $$AttendanceTableTableCreateCompanionBuilder =
    AttendanceTableCompanion Function({
      required String eventId,
      required String userId,
      Value<String?> status,
      Value<int> rowid,
    });
typedef $$AttendanceTableTableUpdateCompanionBuilder =
    AttendanceTableCompanion Function({
      Value<String> eventId,
      Value<String> userId,
      Value<String?> status,
      Value<int> rowid,
    });

class $$AttendanceTableTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceTableTable> {
  $$AttendanceTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttendanceTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceTableTable> {
  $$AttendanceTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendanceTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceTableTable> {
  $$AttendanceTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$AttendanceTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceTableTable,
          AttendanceTableData,
          $$AttendanceTableTableFilterComposer,
          $$AttendanceTableTableOrderingComposer,
          $$AttendanceTableTableAnnotationComposer,
          $$AttendanceTableTableCreateCompanionBuilder,
          $$AttendanceTableTableUpdateCompanionBuilder,
          (
            AttendanceTableData,
            BaseReferences<
              _$AppDatabase,
              $AttendanceTableTable,
              AttendanceTableData
            >,
          ),
          AttendanceTableData,
          PrefetchHooks Function()
        > {
  $$AttendanceTableTableTableManager(
    _$AppDatabase db,
    $AttendanceTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$AttendanceTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$AttendanceTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$AttendanceTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceTableCompanion(
                eventId: eventId,
                userId: userId,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String userId,
                Value<String?> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttendanceTableCompanion.insert(
                eventId: eventId,
                userId: userId,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttendanceTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceTableTable,
      AttendanceTableData,
      $$AttendanceTableTableFilterComposer,
      $$AttendanceTableTableOrderingComposer,
      $$AttendanceTableTableAnnotationComposer,
      $$AttendanceTableTableCreateCompanionBuilder,
      $$AttendanceTableTableUpdateCompanionBuilder,
      (
        AttendanceTableData,
        BaseReferences<
          _$AppDatabase,
          $AttendanceTableTable,
          AttendanceTableData
        >,
      ),
      AttendanceTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EventsTableTableTableManager get eventsTable =>
      $$EventsTableTableTableManager(_db, _db.eventsTable);
  $$ProfilesTableTableTableManager get profilesTable =>
      $$ProfilesTableTableTableManager(_db, _db.profilesTable);
  $$DogsTableTableTableManager get dogsTable =>
      $$DogsTableTableTableManager(_db, _db.dogsTable);
  $$AttendanceTableTableTableManager get attendanceTable =>
      $$AttendanceTableTableTableManager(_db, _db.attendanceTable);
}
