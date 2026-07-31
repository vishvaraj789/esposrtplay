class TeamMember {
  final String playerName;
  final String playerUid;
  final String role;
  final bool isCaptain;

  TeamMember({
    required this.playerName,
    required this.playerUid,
    required this.role,
    this.isCaptain = false,
  });

  TeamMember copyWith({
    String? playerName,
    String? playerUid,
    String? role,
    bool? isCaptain,
  }) {
    return TeamMember(
      playerName: playerName ?? this.playerName,
      playerUid: playerUid ?? this.playerUid,
      role: role ?? this.role,
      isCaptain: isCaptain ?? this.isCaptain,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'playerUid': playerUid,
      'role': role,
      'isCaptain': isCaptain,
    };
  }

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      playerName: json['playerName'] ?? '',
      playerUid: json['playerUid'] ?? '',
      role: json['role'] ?? '',
      isCaptain: json['isCaptain'] ?? false,
    );
  }
}