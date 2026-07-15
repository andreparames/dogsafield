class Region {
  final String id;
  final String name;
  final double centerLatitude;
  final double centerLongitude;
  final double radiusKm;
  final bool isEnabled;

  const Region({
    required this.id,
    required this.name,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radiusKm,
    this.isEnabled = true,
  });
}
