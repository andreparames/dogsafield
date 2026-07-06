enum TreatPolicy { okToShare, askBeforeFeeding }

class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isVerified;
  final int trialRsvpsUsed;
  final bool isFoundingPack;
  final TreatPolicy? treatPolicy;

  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isVerified = false,
    this.trialRsvpsUsed = 0,
    this.isFoundingPack = false,
    this.treatPolicy,
  });

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    bool? isVerified,
    int? trialRsvpsUsed,
    bool? isFoundingPack,
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
      treatPolicy: treatPolicy ?? this.treatPolicy,
    );
  }
}
