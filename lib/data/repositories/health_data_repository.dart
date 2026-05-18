import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:health_track_app/domain/models/health_entry.dart';

class HealthDataSnapshot {
  const HealthDataSnapshot({
    required this.meals,
    required this.waterEntries,
    required this.workouts,
    required this.weightEntries,
  });

  const HealthDataSnapshot.empty()
    : meals = const [],
      waterEntries = const [],
      workouts = const [],
      weightEntries = const [];

  final List<MealEntry> meals;
  final List<WaterEntry> waterEntries;
  final List<WorkoutEntry> workouts;
  final List<WeightEntry> weightEntries;

  bool get isEmpty =>
      meals.isEmpty &&
      waterEntries.isEmpty &&
      workouts.isEmpty &&
      weightEntries.isEmpty;
}

class HealthDataRepository {
  HealthDataRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  final firebase_auth.FirebaseAuth? _firebaseAuth;
  final FirebaseFirestore? _firestore;

  firebase_auth.FirebaseAuth get _auth =>
      _firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  bool get canSync => Firebase.apps.isNotEmpty && _auth.currentUser != null;

  DocumentReference<Map<String, dynamic>> _userDoc() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const HealthDataSyncException('Sign in to sync health data.');
    }
    return _db.collection('users').doc(user.uid);
  }

  Future<HealthDataSnapshot> loadAll() async {
    if (!canSync) return const HealthDataSnapshot.empty();
    final userDoc = _userDoc();
    final results = await Future.wait([
      userDoc.collection('meals').orderBy('createdAt', descending: true).get(),
      userDoc.collection('water').orderBy('createdAt', descending: true).get(),
      userDoc
          .collection('workouts')
          .orderBy('createdAt', descending: true)
          .get(),
      userDoc.collection('weight').orderBy('createdAt', descending: true).get(),
    ]);

    return HealthDataSnapshot(
      meals: results[0].docs
          .map((doc) => MealEntry.fromJson(doc.data()))
          .toList(),
      waterEntries: results[1].docs
          .map((doc) => WaterEntry.fromJson(doc.data()))
          .toList(),
      workouts: results[2].docs
          .map((doc) => WorkoutEntry.fromJson(doc.data()))
          .toList(),
      weightEntries: results[3].docs
          .map((doc) => WeightEntry.fromJson(doc.data()))
          .toList(),
    );
  }

  Future<void> saveMeal(MealEntry meal) {
    return _setDocument('meals', meal.id, meal.toJson());
  }

  Future<void> deleteMeal(String mealId) {
    return _deleteDocument('meals', mealId);
  }

  Future<void> saveWater(WaterEntry entry) {
    return _setDocument('water', entry.id, entry.toJson());
  }

  Future<void> saveWorkout(WorkoutEntry workout) {
    return _setDocument('workouts', workout.id, workout.toJson());
  }

  Future<void> saveWeight(WeightEntry entry) {
    return _setDocument('weight', entry.id, entry.toJson());
  }

  Future<void> pushSnapshot(HealthDataSnapshot snapshot) async {
    if (!canSync) return;
    final batch = _db.batch();
    final userDoc = _userDoc();
    for (final meal in snapshot.meals) {
      batch.set(userDoc.collection('meals').doc(meal.id), meal.toJson());
    }
    for (final entry in snapshot.waterEntries) {
      batch.set(userDoc.collection('water').doc(entry.id), entry.toJson());
    }
    for (final workout in snapshot.workouts) {
      batch.set(
        userDoc.collection('workouts').doc(workout.id),
        workout.toJson(),
      );
    }
    for (final entry in snapshot.weightEntries) {
      batch.set(userDoc.collection('weight').doc(entry.id), entry.toJson());
    }
    await batch.commit();
  }

  Future<void> _setDocument(
    String collection,
    String id,
    Map<String, Object?> data,
  ) async {
    if (!canSync) return;
    await _userDoc().collection(collection).doc(id).set(data);
  }

  Future<void> _deleteDocument(String collection, String id) async {
    if (!canSync) return;
    await _userDoc().collection(collection).doc(id).delete();
  }
}

class HealthDataSyncException implements Exception {
  const HealthDataSyncException(this.message);

  final String message;

  @override
  String toString() => message;
}
