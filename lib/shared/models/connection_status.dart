class ConnectionStatus {
  final String userIdA;
  final String userIdB;
  final bool arePackmates;
  final bool isBlocked;

  const ConnectionStatus({
    required this.userIdA,
    required this.userIdB,
    this.arePackmates = false,
    this.isBlocked = false,
  });
}
