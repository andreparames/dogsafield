enum SocialVibe {
  loungeLizard,
  zoomieKing,
  socialLearner,
}

class Dog {
  final String id;
  final String name;
  final int? age;
  final String? breed;
  final SocialVibe? vibe;
  final String? icebreakerAnswer;

  const Dog({
    required this.id,
    required this.name,
    this.age,
    this.breed,
    this.vibe,
    this.icebreakerAnswer,
  });

  Dog copyWith({
    String? name,
    int? age,
    String? breed,
    SocialVibe? vibe,
    String? icebreakerAnswer,
  }) {
    return Dog(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      breed: breed ?? this.breed,
      vibe: vibe ?? this.vibe,
      icebreakerAnswer: icebreakerAnswer ?? this.icebreakerAnswer,
    );
  }
}
