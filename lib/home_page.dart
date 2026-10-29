import 'package:flutter/material.dart';
import 'package:virtual_companion/glass_card.dart';
import 'package:virtual_companion/logic_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LogicPage.instance.currentMood,
      builder: (context, mood, child) {
        final bgColor = LogicPage.instance.getBgColor(mood);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: bgColor,
            title: const Text(
              "Home",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),
                ValueListenableBuilder(
                  valueListenable: LogicPage.instance.support,
                  builder: (context, support, child) {
                    String supportline;
                    if (support.contains("Great")) {
                      supportline =
                          "Your energy is off the charts today! Pawsome! 🐾";
                    } else if (support.contains("Good")) {
                      supportline = "Keep that good energy going! 🌟";
                    } else if (support.contains("Okay")) {
                      supportline =
                          "Just coasting today? I'll keep you company. 🐈";
                    } else if (support.contains("Rough")) {
                      supportline =
                          "Sending you virtual headbutts and purrs! 🐾";
                    } else {
                      supportline = "How was ur day today??🥺";
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GlassCard(
                        padding: const EdgeInsets.all(24),
                        widget: Text(
                          supportline,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight(700),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                _catImageForMood(mood),
                const Spacer(flex: 1),
                ValueListenableBuilder<String>(
                  valueListenable: LogicPage.instance.petName,
                  builder: (context, value, child) {
                    return Text(
                      value,
                      style: TextStyle(
                        fontSize: 50,
                        color: Colors.white,
                        fontWeight: FontWeight(700),
                      ),
                    );
                  },
                ),
                ValueListenableBuilder<String>(
                  valueListenable: LogicPage.instance.currentMood,
                  builder: (context, value, child) {
                    return GlassCard(
                      padding: const EdgeInsets.all(24),
                      widget: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: LogicPage.instance.isSleeping,
                    builder: (context, isSleeping, child) {
                      Color? cardColor = isSleeping ? Colors.grey : null;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GlassCard(
                              color: cardColor,
                              widget: IconButton(
                                onPressed: isSleeping
                                    ? null
                                    : () {
                                        LogicPage.instance.performAction(
                                          "feed",
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Center(
                                              child: Text(
                                                "Fed ${LogicPage.instance.petName.value}",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight(700),
                                                ),
                                              ),
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                icon: Icon(
                                  Icons.food_bank_outlined,
                                  color: Colors.green,
                                  size: 45,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GlassCard(
                              color: cardColor,
                              widget: IconButton(
                                onPressed: isSleeping
                                    ? null
                                    : () {
                                        LogicPage.instance.performAction(
                                          "rest",
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Center(
                                              child: Text(
                                                "Put ${LogicPage.instance.petName.value} to sleep",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight(700),
                                                ),
                                              ),
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                icon: Icon(
                                  Icons.dark_mode,
                                  color: Colors.blueGrey,
                                  size: 45,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GlassCard(
                              color: cardColor,
                              widget: IconButton(
                                onPressed: isSleeping
                                    ? null
                                    : () {
                                        LogicPage.instance.performAction(
                                          "play",
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Center(
                                              child: Text(
                                                "Played with ${LogicPage.instance.petName.value}",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight(700),
                                                ),
                                              ),
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                icon: Icon(
                                  Icons.sports_football,
                                  color: Colors.blue,
                                  size: 45,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const Spacer(flex: 5),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _catImageForMood(String mood) {
    final newMood = mood.toLowerCase();
    if (newMood.contains("happy")) {
      return Image.asset("assets/happy_cat.png", height: 350);
    } else if (newMood.contains("hangry")) {
      return Image.asset("assets/hangry_cat.png", height: 350);
    } else if (newMood.contains("sick")) {
      return Image.asset("assets/sick_cat.png", height: 350);
    } else if (newMood.contains("sleepy")) {
      return Image.asset("assets/sleepy_cat.png", height: 350);
    } else if (newMood.contains("sleeping")) {
      return Image.asset("assets/sleeping_cat.png", height: 350);
    }
    return Image.asset("assets/happy_cat.png", height: 350);
  }
}
