import 'package:drift/drift.dart';

class EventsTable extends Table {
  TextColumn get id => text()();
  TextColumn get hostId => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get locationName => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get eventDate => text()();
  IntColumn get maxAttendees => integer()();
  TextColumn get whatToBring => text().nullable()();
  TextColumn get amenityTags => text().nullable()();
  IntColumn get isCancelled => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ProfilesTable extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  IntColumn get isVerified => integer().nullable()();
  IntColumn get trialRsvpsUsed => integer().nullable()();
  IntColumn get isFoundingPack => integer().nullable()();
  IntColumn get isSuspended => integer().nullable()();
  IntColumn get hasSeenFieldIntro => integer().nullable()();
  IntColumn get hasSeenHostIntro => integer().nullable()();
  TextColumn get treatPolicy => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DogsTable extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get name => text()();
  IntColumn get age => integer().nullable()();
  TextColumn get breed => text().nullable()();
  TextColumn get vibe => text().nullable()();
  TextColumn get icebreakerAnswer => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AttendanceTable extends Table {
  TextColumn get eventId => text()();
  TextColumn get userId => text()();
  TextColumn get status => text().nullable()();

  @override
  Set<Column> get primaryKey => {eventId, userId};
}
