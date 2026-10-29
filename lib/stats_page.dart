import 'package:flutter/material.dart';
import 'package:virtual_companion/glass_card.dart';
import 'package:virtual_companion/logic_page.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _StatsPage();
  }
}

class _StatsPage extends State<StatsPage> {
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
              "Stats",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight(700),
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor: bgColor,
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),
                _liveStatsCard(
                  icon: Icons.food_bank,
                  iconColor: Colors.green,
                  label: "Hunger",
                  listenable: LogicPage.instance.hunger,
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),
                _liveStatsCard(
                  icon: Icons.bolt,
                  iconColor: const Color.fromRGBO(247, 208, 38, 1),
                  label: "Energy",
                  listenable: LogicPage.instance.energy,
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),
                _liveStatsCard(
                  icon: Icons.favorite,
                  iconColor: const Color.fromRGBO(179, 30, 92, 1),
                  label: "Happiness",
                  listenable: LogicPage.instance.happiness,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _liveStatsCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required ValueNotifier<double> listenable,
  }) {
    return ValueListenableBuilder(
      valueListenable: listenable,
      builder: (context, value, child) {
        return InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text(
                    "The current value is ${value.clamp(0.0, 100.0).round()}%",
                    style: const TextStyle(fontSize: 24),
                  ),
                );
              },
            );
          },
          child: GlassCard(
            widget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Icon(icon, color: iconColor, size: 56),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight(700),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${value.clamp(0.0, 100.0).round()}%",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight(700),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          child: LinearProgressIndicator(
                            value: value.clamp(0.0, 100.0) / 100.0,
                            minHeight: 14,
                            color: iconColor,
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
  }
}
