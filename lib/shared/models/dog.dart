enum SocialVibe {
  loungeLizard,
  zoomieKing,
  socialLearner,
}

class Dog {
  final String id;
  final String ownerId;
  final String name;
  final int? age;
  final String? breed;
  final SocialVibe? vibe;
  final String? icebreakerAnswer;
  final String? photoUrl;

  const Dog({
    required this.id,
    required this.ownerId,
    required this.name,
    this.age,
    this.breed,
    this.vibe,
    this.icebreakerAnswer,
    this.photoUrl,
  });

  Dog copyWith({
    String? ownerId,
    String? name,
    int? age,
    String? breed,
    SocialVibe? vibe,
    String? icebreakerAnswer,
    String? photoUrl,
  }) {
    return Dog(
      id: id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      age: age ?? this.age,
      breed: breed ?? this.breed,
      vibe: vibe ?? this.vibe,
      icebreakerAnswer: icebreakerAnswer ?? this.icebreakerAnswer,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
