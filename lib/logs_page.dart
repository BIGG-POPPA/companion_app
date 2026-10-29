import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_companion/glass_card.dart';
import 'package:virtual_companion/logic_page.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});
  @override
  State<StatefulWidget> createState() {
    return _LogsPage();
  }
}

class _LogsPage extends State {
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? "default";

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LogicPage.instance.currentMood,
      builder: (context, mood, child) {
        final bgColor = LogicPage.instance.getBgColor(mood);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: bgColor,
            title: const Text(
              "Logs",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight(700),
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.delete_sweep,
                  color: Colors.white,
                  size: 30,
                ),
                tooltip: "Clear All Logs",
                onPressed: () async {
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: bgColor,
                      title: const Text(
                        "Clear All Logs?",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text(
                        "Are you sure you want to delete all activity logs? This action cannot be undone.",
                        style: TextStyle(color: Colors.white),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            "Delete All",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final logsCollection = FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('logs');

                    final snapshot = await logsCollection.get();
                    WriteBatch batch = FirebaseFirestore.instance.batch();

                    for (var doc in snapshot.docs) {
                      batch.delete(doc.reference);
                    }

                    await batch.commit();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("All logs cleared successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          backgroundColor: bgColor,
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .collection('logs')
                        .orderBy("timestamp", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No logs yet',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final doc = snapshot.data!.docs[index].data();
                          final Icon iconn;
                          if (doc['action'] == "feed") {
                            iconn = const Icon(
                              Icons.food_bank,
                              color: Colors.green,
                              size: 45,
                            );
                          } else if (doc['action'] == "rest") {
                            iconn = const Icon(
                              Icons.dark_mode,
                              color: Colors.blueGrey,
                              size: 45,
                            );
                          } else if (doc['action'] == "play") {
                            iconn = const Icon(
                              Icons.sports_football,
                              color: Colors.blue,
                              size: 45,
                            );
                          } else {
                            iconn = const Icon(
                              Icons.history,
                              color: Colors.grey,
                              size: 45,
                            );
                          }
                          return Dismissible(
                            key: ValueKey(snapshot.data!.docs[index].id),
                            onDismissed: (direction) {
                              snapshot.data!.docs[index].reference.delete();
                              setState(() {});
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                children: [
                                  GlassCard(
                                    widget: Row(
                                      children: [
                                        iconn,
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            "${doc['activity']}",
                                            softWrap: true,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
