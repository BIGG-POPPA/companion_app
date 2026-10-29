import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogicPage with WidgetsBindingObserver {
  static final LogicPage instance = LogicPage._internal();
  LogicPage._internal();

  ValueNotifier<String> petName = ValueNotifier("WIZZ");
  ValueNotifier<double> hunger = ValueNotifier(100);
  ValueNotifier<double> energy = ValueNotifier(100);
  ValueNotifier<double> happiness = ValueNotifier(100);
  ValueNotifier<String> currentMood = ValueNotifier("Happy 😸");
  ValueNotifier<double> decayFactor = ValueNotifier(1);
  ValueNotifier<bool> isSleeping = ValueNotifier(false);
  ValueNotifier<String> support = ValueNotifier("How do u feel today??🥺");

  Timer? _sleepTimer;
  Timer? _decayTimer;
  bool _isInitialized = false;

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? "default";
  DocumentReference<Map<String, dynamic>> get _petRef =>
      FirebaseFirestore.instance.collection("pets").doc(uid);
  CollectionReference<Map<String, dynamic>> get _logsRef => FirebaseFirestore
      .instance
      .collection("users")
      .doc(uid)
      .collection("logs");

  void init() {
    if (_isInitialized) return;
    _isInitialized = true;
    WidgetsBinding.instance.addObserver(this);
    _syncFromFirebase();
    _decayTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      hunger.value = (hunger.value - (1 * decayFactor.value)).clamp(0.0, 100.0);
      energy.value = (energy.value - (1 * decayFactor.value)).clamp(0.0, 100.0);
      _updateMood();
    });
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _decayTimer?.cancel();
    _sleepTimer?.cancel();
    _decayTimer = null;
    _sleepTimer = null;
    _isInitialized = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveToFirebase();
    } else if (state == AppLifecycleState.resumed) {
      _syncFromFirebase();
    }
  }

  Future<void> _syncFromFirebase() async {
    final snap = await _petRef.get();
    if (!snap.exists) return;
    final data = snap.data()!;
    if (data.containsKey('sleep_until') && data['sleep_until'] != null) {
      DateTime sleepUnitl = (data['sleep_until'] as Timestamp).toDate();
      int secondsLeft = sleepUnitl.difference(DateTime.now()).inSeconds;
      if (secondsLeft > 0) {
        _startSleepTimer(secondsLeft);
      } else {
        hunger.value = (hunger.value - 10).clamp(0.0, 100.0);
        energy.value = (energy.value + 30).clamp(0.0, 100.0);
        _petRef.set({
          'sleep_until': FieldValue.delete(),
        }, SetOptions(merge: true));
      }
    }
    final lastUpdatedValue = data['last_updated'];
    final lastUpdated = lastUpdatedValue is Timestamp
        ? lastUpdatedValue.toDate()
        : DateTime.now();
    int minutesPassed = DateTime.now().difference(lastUpdated).inMinutes;
    petName.value = data['pet_name'] ?? 'WIZZ';
    decayFactor.value = (data['decay_factor'] ?? 1).toDouble();

    hunger.value = ((data['hunger'] as num? ?? 100).toDouble() - minutesPassed)
        .clamp(0.0, 100.0);
    energy.value = ((data['energy'] as num? ?? 100).toDouble() - minutesPassed)
        .clamp(0.0, 100.0);
    happiness.value =
        ((data['happiness'] as num? ?? 100).toDouble() - minutesPassed).clamp(
          0.0,
          100.0,
        );
    _updateMood();
  }

  Future<void> _saveToFirebase() async {
    await _petRef.set({
      'hunger': hunger.value,
      'energy': energy.value,
      'happiness': happiness.value,
      'last_updated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> performAction(String Action) async {
    if (isSleeping.value) return;
    if (Action == 'feed') {
      hunger.value = (hunger.value + 20).clamp(0.0, 100.0);
      energy.value = (energy.value + 5).clamp(0.0, 100.0);
    } else if (Action == 'play') {
      happiness.value = (happiness.value + 20).clamp(0.0, 100.0);
      energy.value = (energy.value - 10).clamp(0.0, 100.0);
      hunger.value = (hunger.value - 15).clamp(0.0, 100.0);
    } else if (Action == 'rest') {
      DateTime wakeUpTime = DateTime.now().add(const Duration(seconds: 60));
      await _petRef.set({'sleep_until': wakeUpTime}, SetOptions(merge: true));
      _startSleepTimer(60);
      await _logsRef.add({
        'activity': "${petName.value} went to sleep 💤",
        'action': Action,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return;
    }
    _updateMood();
    await _saveToFirebase();
    await _logsRef.add({
      'activity': "${petName.value} action: $Action",
      'action': Action,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return;
  }

  void _updateMood() {
    if (isSleeping.value) return;
    if (hunger.value < 30 && energy.value < 30) {
      currentMood.value = "Sick 🤒";
    } else if (hunger.value < 40) {
      currentMood.value = "Hangry 😾";
    } else if (energy.value < 40) {
      currentMood.value = "Sleepy 😴";
    } else {
      currentMood.value = "Happy 😸";
    }
  }

  void updateSupport() async {
    final query = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("journal")
        .orderBy("created_at", descending: true)
        .limit(1);
    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final Timestamp? timestamp = doc["created_at"] as Timestamp?;
      if (timestamp != null) {
        final DateTime docDate = timestamp.toDate();
        final DateTime now = DateTime.now();
        if (docDate.year == now.year &&
            docDate.month == now.month &&
            docDate.day == now.day) {
          support.value = doc['mood'];
          return;
        }
      }
    } else {
      support.value = "How do u feel today??🥺";
    }
  }

  Future<void> changePetName(String newName) async {
    petName.value = newName;
    await _petRef.set({'pet_name': petName.value}, SetOptions(merge: true));
  }

  Future<void> changeDecayFactor(double newValue) async {
    decayFactor.value = newValue;
    await _petRef.set({
      'decay_factor': decayFactor.value,
    }, SetOptions(merge: true));
  }

  Future<void> resetProgress() async {
    final collection = _logsRef;
    final snapshot = await collection.get();
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    decayFactor.value = 1;
    happiness.value = 100.0;
    energy.value = 100.0;
    hunger.value = 100.0;
    await _petRef.set({
      'decay_factor': decayFactor.value,
      'happiness': 100.0,
      'hunger': 100.0,
      'energy': 100.0,
    });
  }

  void _startSleepTimer(int seconds) {
    isSleeping.value = true;
    _sleepTimer?.cancel();
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds--;
      if (seconds <= 0) {
        timer.cancel();
        isSleeping.value = false;
        hunger.value = (hunger.value - 10).clamp(0.0, 100.0);
        energy.value = (energy.value + 50).clamp(0.0, 100.0);
        _saveToFirebase();
        _petRef.set({
          'sleep_until': FieldValue.delete(),
        }, SetOptions(merge: true));
        _updateMood();
      } else {
        currentMood.value = "Sleeping.... ${seconds}s 💤";
      }
    });
  }

  Color getBgColor(String mood) {
    String m = mood.toLowerCase();
    if (m.contains("hangry")) return Colors.deepOrange.shade400;
    if (m.contains("sick")) return const Color.fromARGB(255, 24, 102, 94);
    if (m.contains("sleep")) return const Color.fromARGB(255, 43, 48, 73);
    return const Color.fromRGBO(234, 132, 174, 1);
  }
}
