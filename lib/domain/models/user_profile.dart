class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.avatarSeed,
  });

  factory UserProfile.demo() {
    return const UserProfile(
      uid: 'local-user',
      name: 'Vaidehi',
      email: 'vaidehi@example.com',
      gender: 'Female',
      age: 28,
      heightCm: 164,
      weightKg: 57.8,
      goal: 'Build a consistent wellness routine',
      avatarSeed: 'VH',
    );
  }

  factory UserProfile.fromJson(Map<String, Object?> json) {
    return UserProfile(
      uid: json['uid'] as String? ?? 'local-user',
      name: json['name'] as String? ?? 'Health User',
      email: json['email'] as String? ?? '',
      gender: json['gender'] as String? ?? 'Prefer not to say',
      age: json['age'] as int? ?? 28,
      heightCm: (json['heightCm'] as num? ?? 164).toDouble(),
      weightKg: (json['weightKg'] as num? ?? 58).toDouble(),
      goal: json['goal'] as String? ?? 'Stay active',
      avatarSeed: json['avatarSeed'] as String? ?? 'HU',
    );
  }

  final String uid;
  final String name;
  final String email;
  final String gender;
  final int age;
  final double heightCm;
  final double weightKg;
  final String goal;
  final String avatarSeed;

  double get bmi {
    final heightM = heightCm / 100;
    if (heightM <= 0) return 0;
    return weightKg / (heightM * heightM);
  }

  int get dailyCalorieTarget {
    final bmr = 10 * weightKg + 6.25 * heightCm - 5 * age;
    final adjusted = gender.toLowerCase() == 'male' ? bmr + 5 : bmr - 161;
    return (adjusted * 1.45).round();
  }

  int get dailyProteinTarget => (weightKg * 1.6).round();

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    String? goal,
    String? avatarSeed,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goal: goal ?? this.goal,
      avatarSeed: avatarSeed ?? this.avatarSeed,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'gender': gender,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'goal': goal,
      'avatarSeed': avatarSeed,
    };
  }
}
