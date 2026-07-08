import 'user_profile.dart';

class ConnectionStatus {
  final String userIdA;
  final String userIdB;
  final bool arePackmates;
  final int blockTier;
  final String? reportReason;
  final UserProfile? blockedUserProfile;

  bool get isBlocked => blockTier > 0;

  const ConnectionStatus({
    required this.userIdA,
    required this.userIdB,
    this.arePackmates = false,
    this.blockTier = 0,
    this.reportReason,
    this.blockedUserProfile,
  });

  ConnectionStatus copyWith({
    String? userIdA,
    String? userIdB,
    bool? arePackmates,
    int? blockTier,
    String? reportReason,
    UserProfile? blockedUserProfile,
  }) {
    return ConnectionStatus(
      userIdA: userIdA ?? this.userIdA,
      userIdB: userIdB ?? this.userIdB,
      arePackmates: arePackmates ?? this.arePackmates,
      blockTier: blockTier ?? this.blockTier,
      reportReason: reportReason ?? this.reportReason,
      blockedUserProfile: blockedUserProfile ?? this.blockedUserProfile,
    );
  }
}
