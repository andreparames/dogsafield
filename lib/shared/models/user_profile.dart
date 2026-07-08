enum TreatPolicy { okToShare, askBeforeFeeding }

class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isVerified;
  final int trialRsvpsUsed;
  final bool isFoundingPack;
  final bool isSuspended;
  final bool hasSeenFieldIntro;
  final bool hasSeenHostIntro;
  final TreatPolicy? treatPolicy;

  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isVerified = false,
    this.trialRsvpsUsed = 0,
    this.isFoundingPack = false,
    this.isSuspended = false,
    this.hasSeenFieldIntro = false,
    this.hasSeenHostIntro = false,
    this.treatPolicy,
  });

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    bool? isVerified,
    int? trialRsvpsUsed,
    bool? isFoundingPack,
    bool? isSuspended,
    bool? hasSeenFieldIntro,
    bool? hasSeenHostIntro,
    TreatPolicy? treatPolicy,
  }) {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      trialRsvpsUsed: trialRsvpsUsed ?? this.trialRsvpsUsed,
      isFoundingPack: isFoundingPack ?? this.isFoundingPack,
      isSuspended: isSuspended ?? this.isSuspended,
      hasSeenFieldIntro: hasSeenFieldIntro ?? this.hasSeenFieldIntro,
      hasSeenHostIntro: hasSeenHostIntro ?? this.hasSeenHostIntro,
      treatPolicy: treatPolicy ?? this.treatPolicy,
    );
  }
}
