import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_companion/glass_card.dart';
import 'package:virtual_companion/logic_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingPage();
  }
}

class _SettingPage extends State {
  final TextEditingController PetController = TextEditingController();
  double _currentValue = 1;

  @override
  void initState() {
    super.initState();
    PetController.text = LogicPage.instance.petName.value;
    _currentValue = LogicPage.instance.decayFactor.value;
  }

  @override
  void dispose() {
    PetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LogicPage.instance.currentMood,
      builder: (context, mood, child) {
        final bgColor = LogicPage.instance.getBgColor(mood);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: bgColor,
            title: Text(
              "Setttings",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight(700),
                color: Colors.white,
              ),
            ),
          ),
          backgroundColor: bgColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: GlassCard(
              widget: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      children: [
                        Icon(Icons.edit, color: Colors.white),
                        Text(
                          "Edit ur pet's name",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            widget: TextFormField(
                              controller: PetController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GlassCard(
                            color: Color.fromRGBO(
                              127,
                              150,
                              255,
                              1,
                            ).withOpacity(0.2),
                            widget: TextButton(
                              onPressed: () {
                                String newName = PetController.text.trim();
                                if (newName.isNotEmpty) {
                                  LogicPage.instance.changePetName(newName);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("updated pet's name!"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                "Save",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight(700),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        "NEEDINESS (Difficulty): ${_currentValue.round()} decay",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Slider(
                      value: _currentValue,
                      min: 1,
                      max: 4,
                      label: _currentValue.round().toString(),
                      activeColor: Color.fromRGBO(127, 150, 255, 1),
                      divisions: 3,
                      onChanged: (double newValue) {
                        setState(() {
                          _currentValue = newValue;
                        });
                      },
                      onChangeEnd: (value) {
                        LogicPage.instance.changeDecayFactor(value);
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          Text(
                            "Chill AF",
                            style: TextStyle(color: Colors.white),
                          ),
                          Spacer(),
                          Text(
                            "Needy ASL",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        GlassCard(
                          color: Colors.red.withOpacity(0.4),
                          widget: TextButton(
                            onPressed: () {
                              LogicPage.instance.resetProgress();
                            },
                            child: Text(
                              "Reset progress",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight(700),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        GlassCard(
                          widget: TextButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                            },
                            child: Text(
                              "Sign out",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight(700),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
