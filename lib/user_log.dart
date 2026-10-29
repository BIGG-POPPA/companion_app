import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:virtual_companion/glass_card.dart';
import 'package:virtual_companion/logic_page.dart';

class UserLog extends StatefulWidget {
  const UserLog({super.key});
  @override
  State<UserLog> createState() {
    return _UserLog();
  }
}

class _UserLog extends State<UserLog> {
  final TextEditingController journalController = TextEditingController();
  @override
  void dispose() {
    journalController.dispose();
    super.dispose();
  }

  String _userMood = "Okay 😐";
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LogicPage.instance.currentMood,
      builder: (context, mood, child) {
        final bgColor = LogicPage.instance.getBgColor(mood);
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            title: Text(
              "My Journal",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight(700),
                color: Colors.white,
              ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "How are you feeling today??",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight(700),
                  ),
                ),
              ),

              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth < 380 ? 2 : 4;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 8) / columns;
                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _moodButton("😢", "Rough", "Rough 😢", width),
                      _moodButton("😐", "Okay", "Okay 😐", width),
                      _moodButton("🙂", "Good", "Good 🙂", width),
                      _moodButton("🤩", "Great", "Great 🤩", width),
                    ],
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: GlassCard(
                  widget: Column(
                    children: [
                      TextFormField(
                        controller: journalController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText:
                              "Jot your thoughts down... ${LogicPage.instance.petName.value.trim()} is listening",
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          String Log = journalController.text.trim();
                          if (Log.isNotEmpty) {
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(LogicPage.instance.uid)
                                .collection("journal")
                                .doc()
                                .set({
                                  "mood": _userMood,
                                  "log": Log,
                                  "created_at": FieldValue.serverTimestamp(),
                                });
                            journalController.clear();
                            LogicPage.instance.updateSupport();
                          }
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight(700),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Recent Check-ins",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight(700),
                  ),
                ),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(LogicPage.instance.uid)
                      .collection("journal")
                      .orderBy("created_at", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LinearProgressIndicator();
                    } else if (!snapshot.hasData) {
                      return Text("No Data!!");
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final Map<String, dynamic> doc = snapshot
                              .data!
                              .docs[index]
                              .data();
                          Timestamp? timestamp =
                              doc['created_at'] as Timestamp?;
                          DateTime dateTime =
                              timestamp?.toDate() ?? DateTime.now();
                          final date = DateFormat("d").format(dateTime);
                          final month = DateFormat("MMM").format(dateTime);
                          return Column(
                            children: [
                              Dismissible(
                                key: ValueKey(index),
                                onDismissed: (direction) {
                                  snapshot.data!.docs[index].reference.delete();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GlassCard(
                                    widget: Row(
                                      children: [
                                        GlassCard(
                                          widget: Column(
                                            children: [
                                              Text(
                                                date,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight(700),
                                                ),
                                              ),
                                              Text(
                                                month,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight(700),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Text(
                                                "Felt ${doc["mood"]}",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight(700),
                                                ),
                                              ),
                                              Text(
                                                doc["log"],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight(700),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _moodButton(String emoji, String label, String mood, double width) {
    return SizedBox(
      width: width,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        widget: TextButton(
          onPressed: () => setState(() => _userMood = mood),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
