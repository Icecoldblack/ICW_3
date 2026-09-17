import 'package:flutter/material.dart';

// ============================================================================
// IN-CLASS ACTIVITY 03 - THE CYBER-TACTILE CONTROL STUDIO
// Persona: "RA DUTY DECK" (a Resident Advisor's floor control console)
//
// Author: Uyiosa Nehikhuere
// Course: Mobile App Development (Flutter / Dart), Day 3
//
// WHAT WAS CUSTOMIZED FROM THE STARTER CODE
//   Milestone 1: all 4 TactileButton calls now use my own persona's icons,
//                labels, accent colors and status strings (RA floor duties).
//   Milestone 2: an 80% power threshold (isOverload) that shifts the screen
//                background to a warning tone, recolors the energy readout,
//                swaps the status banner to an ON CALL SURGE warning, and
//                drives a LinearProgressIndicator that turns red past 80%.
//   Extra credit: a 5th control, HOLD TO ESCALATE, that ignores a normal tap
//                and only fires after a long-press "charge" (onLongPress).
//   Evidence:    debugPrint() lines inside onTapDown / onTapUp / onTapCancel,
//                kept in the file on purpose because Critical Thinking
//                Question 2 asks for the printed callback order.
// ============================================================================

// ============================================================================
// 1. MAIN ENTRY POINT
// ============================================================================
// Summary: Every Flutter app starts here. runApp() takes your root widget and
// attaches it to the screen, kicking off the framework's build-and-render
// pipeline.
// Reference: https://api.flutter.dev/flutter/widgets/runApp.html
void main() {
  runApp(const TactileDeckApp());
}

// ============================================================================
// 2. ROOT APPLICATION WIDGET (Manages Global Theme State)
// ============================================================================
// Summary: A StatefulWidget that owns the single source of truth for light and
// dark mode. MaterialApp reads isDarkMode to pick a theme, and onToggleTheme
// lets the child screen flip it through a callback, so no data has to be
// passed back up the tree manually.
// Reference: https://docs.flutter.dev/cookbook/design/themes
class TactileDeckApp extends StatefulWidget {
  const TactileDeckApp({super.key});

  @override
  State<TactileDeckApp> createState() => _TactileDeckAppState();
}

class _TactileDeckAppState extends State<TactileDeckApp> {
  // Global theme toggle variable (carried over from Activity 02).
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Persona rename: this is my RA floor console, not a generic deck.
      title: 'RA Duty Deck',
      debugShowCheckedModeBanner: false,
      // Apply the Material 3 dark or light theme based on state.
      theme: isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: ControlDeckScreen(
        isDark: isDarkMode,
        // Callback function that lets the child widget toggle theme mode.
        onToggleTheme: () => setState(() => isDarkMode = !isDarkMode),
      ),
    );
  }
}

// ============================================================================
// 3. MAIN DASHBOARD SCREEN (Stateful Controller)
// ============================================================================
// Summary: The screen users actually see. Its State object holds totalTaps,
// powerLevel and systemStatus, and rebuilds the metrics card, status banner,
// buttons and slider every time setState() runs.
// Reference: https://api.flutter.dev/flutter/material/Scaffold-class.html
class ControlDeckScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  const ControlDeckScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<ControlDeckScreen> createState() => _ControlDeckScreenState();
}

class _ControlDeckScreenState extends State<ControlDeckScreen> {
  // --- Mutable State Variables (Day 3 core concept) ---
  int totalTaps = 0; // Increments on every button press.
  double powerLevel = 65.0; // Controlled by the interactive slider.
  String systemStatus = "ON DUTY"; // Displays the latest activated command.

  // MILESTONE 2 CONSTANT
  // The threshold the assignment asks for. Pulled out as a named constant so
  // the number appears exactly once instead of being buried in build().
  static const double overloadThreshold = 80.0;

  // Helper method that updates dashboard state when a control is activated.
  // Every state change lives inside setState() so Flutter knows to redraw.
  void _triggerAction(String actionName) {
    setState(() {
      totalTaps++;
      systemStatus = "$actionName ACTIVATED";
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- MILESTONE 2: INTERACTIVE FEEDBACK AT THE 80% THRESHOLD ---
    // One boolean drives every piece of overload feedback below, so the rule
    // is written once and the UI stays consistent.
    final bool isOverload = powerLevel > overloadThreshold;

    // Dynamic background color that adapts to the current theme AND to the
    // overload state. This is the single line from the starter code that
    // decides the background, now wrapped in the 80% check.
    final screenBg = isOverload
        ? (widget.isDark ? const Color(0xFF3A1712) : const Color(0xFFFBE6DF))
        : (widget.isDark ? const Color(0xFF1E1F29) : const Color(0xFFE0E5EC));

    final cardBg = widget.isDark ? const Color(0xFF282A36) : Colors.white;

    // The energy readout and the progress bar both turn warning-colored past
    // the threshold, so the overload is readable at a glance.
    final Color energyColor = isOverload ? Colors.orangeAccent : Colors.blueAccent;

    // AnimatedContainer is used for the background so the color shift fades in
    // over 300ms instead of snapping the instant the slider crosses 80%.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: screenBg,
      child: Scaffold(
        // Transparent so the animated background color above shows through.
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            "RA DUTY DECK",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 18,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            // Theme toggle button in the AppBar.
            IconButton(
              icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
              tooltip: 'Toggle Theme',
              onPressed: widget.onToggleTheme,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- TOP STATUS METRICS CARD ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(widget.isDark ? 0.3 : 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Total taps counter (persona wording: logged actions).
                    Column(
                      children: [
                        const Text(
                          "LOGGED ACTIONS",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$totalTaps",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Vertical divider line.
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    // Energy / power level indicator. MILESTONE 2: the color
                    // here follows isOverload instead of being hard coded.
                    Column(
                      children: [
                        const Text(
                          "FLOOR LOAD",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${powerLevel.toInt()}%",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: energyColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Live system status banner. MILESTONE 2: past the threshold the
              // banner stops reporting the last command and shows a warning
              // instead, so the overload cannot be missed.
              Text(
                isOverload
                    ? "STATUS: ON CALL SURGE, FLOOR LOAD OVER ${overloadThreshold.toInt()}%"
                    : "STATUS: $systemStatus",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  color: isOverload
                      ? Colors.orangeAccent
                      : (widget.isDark
                          ? Colors.tealAccent
                          : Colors.teal.shade700),
                ),
              ),
              const SizedBox(height: 28),

              // --- GRID OF TACTILE 3D BUTTONS (MILESTONE 1: MY PERSONA) ---
              // Four RA floor duties plus a fifth hold-only control.
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  // 1. Common area lighting.
                  TactileButton(
                    icon: Icons.lightbulb,
                    label: "LOUNGE",
                    accentColor: Colors.amber,
                    isDark: widget.isDark,
                    onPressed: () => _triggerAction("LOUNGE LIGHTS"),
                  ),
                  // 2. Quiet hours enforcement.
                  TactileButton(
                    icon: Icons.nightlight_round,
                    label: "QUIET",
                    accentColor: Colors.indigoAccent,
                    isDark: widget.isDark,
                    onPressed: () => _triggerAction("QUIET HOURS"),
                  ),
                  // 3. Nightly rounds check-in on both floors.
                  TactileButton(
                    icon: Icons.how_to_reg,
                    label: "ROUNDS",
                    accentColor: Colors.greenAccent,
                    isDark: widget.isDark,
                    onPressed: () => _triggerAction("FLOOR ROUNDS"),
                  ),
                  // 4. Broadcast an announcement to both floors.
                  TactileButton(
                    icon: Icons.campaign,
                    label: "ALERT",
                    accentColor: Colors.redAccent,
                    isDark: widget.isDark,
                    onPressed: () => _triggerAction("FLOOR ALERT"),
                  ),

                  // --- EXTRA CREDIT: 5TH CONTROL, LONG-PRESS CHARGE ---
                  // Escalating to the Residence Director is not something you
                  // want to fire on an accidental tap, so this control ignores
                  // a normal tap and only activates after the finger is held
                  // down long enough for GestureDetector's onLongPress.
                  TactileButton(
                    icon: Icons.support_agent,
                    label: "ESCALATE",
                    accentColor: Colors.orangeAccent,
                    isDark: widget.isDark,
                    holdToActivate: true, // Tap alone will not fire this.
                    onPressed: () => _triggerAction("RD ESCALATION"),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // --- INTERACTIVE CALIBRATION SLIDER ---
              Text(
                "Floor Load Calibration: ${powerLevel.toInt()}%",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Slider(
                value: powerLevel,
                min: 0,
                max: 100,
                // MILESTONE 2: the slider itself also turns warning-colored.
                activeColor: energyColor,
                inactiveColor: Colors.grey.withOpacity(0.3),
                // setState updates powerLevel immediately during the drag, so
                // every widget that reads isOverload re-evaluates live.
                onChanged: (newVal) => setState(() => powerLevel = newVal),
              ),

              // --- MILESTONE 2: DYNAMIC PROGRESS BAR ---
              // The second half of the required feedback. The bar fills with
              // powerLevel and flips from blue to red once the 80% threshold
              // is crossed.
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: powerLevel / 100, // LinearProgressIndicator wants 0..1
                  minHeight: 14,
                  backgroundColor: Colors.grey.withOpacity(0.25),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverload ? Colors.redAccent : Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Small caption that explains the threshold to the user.
              Text(
                isOverload
                    ? "Load above ${overloadThreshold.toInt()}%. Escalate to the RD on call."
                    : "Nominal load. Threshold is ${overloadThreshold.toInt()}%.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isOverload ? Colors.redAccent : Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 4. REUSABLE TACTILE 3D BUTTON WIDGET
// ============================================================================
// Summary: A self-contained StatefulWidget that tracks its own isPressed flag
// and uses GestureDetector plus two opposing BoxShadows to fake a physical
// push-button depress-and-release effect, with no external packages.
//
// holdToActivate (extra credit) switches the control from "fires on release"
// to "fires only after a long-press charge".
// Reference: https://api.flutter.dev/flutter/widgets/GestureDetector-class.html
class TactileButton extends StatefulWidget {
  final IconData icon; // Icon shown in the center.
  final String label; // Button title text.
  final Color accentColor; // Active glow color.
  final bool isDark; // Light or dark theme mode.
  final VoidCallback onPressed; // Action callback triggered on activation.
  final bool holdToActivate; // Extra credit: long-press instead of tap.

  const TactileButton({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.isDark,
    required this.onPressed,
    this.holdToActivate = false,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  // Local boolean state tracking whether this one button is being held down.
  // It stays local on purpose: see Critical Thinking Question 1. If it lived
  // in the parent, one shared flag would sink all five buttons at once.
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Determine dynamic background and shadow colors.
    final baseColor =
        widget.isDark ? const Color(0xFF222430) : const Color(0xFFE0E5EC);
    final darkShadow =
        widget.isDark ? Colors.black87 : const Color(0xFFA3B1C6);
    final lightShadow =
        widget.isDark ? const Color(0xFF2F3244) : Colors.white;

    return GestureDetector(
      // 1. User touches the button, so depress it.
      onTapDown: (_) {
        // Instrumentation for Critical Thinking Question 2.
        debugPrint("onTapDown fired for ${widget.label}");
        setState(() => isPressed = true);
      },
      // 2. User releases the button, so restore it and fire the callback.
      //    For a hold-to-activate control the visual pops back out but the
      //    action is deliberately NOT fired here.
      onTapUp: (_) {
        debugPrint("onTapUp fired for ${widget.label}");
        setState(() => isPressed = false);
        if (!widget.holdToActivate) {
          widget.onPressed();
        }
      },
      // 3. User slid the finger off or a scroll took over, so reset safely
      //    without firing the action.
      onTapCancel: () {
        debugPrint("onTapCancel fired for ${widget.label}");
        setState(() => isPressed = false);
      },

      // --- EXTRA CREDIT LONG-PRESS CHARGE ---
      // onLongPressStart keeps the button visually sunken while charging,
      // onLongPress is the moment the charge completes and the action fires,
      // and onLongPressEnd pops the button back out.
      onLongPressStart: widget.holdToActivate
          ? (_) {
              debugPrint("onLongPressStart charging ${widget.label}");
              setState(() => isPressed = true);
            }
          : null,
      onLongPress: widget.holdToActivate
          ? () {
              debugPrint("onLongPress charge complete for ${widget.label}");
              widget.onPressed();
            }
          : null,
      onLongPressEnd: widget.holdToActivate
          ? (_) {
              debugPrint("onLongPressEnd released ${widget.label}");
              setState(() => isPressed = false);
            }
          : null,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100), // Smooth 100ms spring.
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(24),
          // Dual opposing BoxShadows create the 3D neomorphic depth effect.
          boxShadow: isPressed
              ? [
                  // Pressed (sunken) shadow offsets: both collapse inward, so
                  // the contrast drops and the surface reads as pushed in.
                  BoxShadow(
                    color: darkShadow.withOpacity(0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: lightShadow.withOpacity(0.5),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  // Unpressed (elevated) offsets: dark shadow bottom-right,
                  // light highlight top-left, which puts the light source at
                  // the top-left and makes the button read as raised.
                  BoxShadow(
                    color: darkShadow.withOpacity(0.7),
                    offset: const Offset(-8, 8),
                    blurRadius: 16,
                  ),
                  BoxShadow(
                    color: lightShadow.withOpacity(0.9),
                    offset: const Offset(8, -8),
                    blurRadius: 16,
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dynamic icon that shrinks and takes the accent color on press.
            Icon(
              widget.icon,
              size: isPressed ? 40 : 46,
              color: isPressed
                  ? widget.accentColor
                  : (widget.isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 8),
            // Button label.
            Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.1,
                color: isPressed
                    ? widget.accentColor
                    : (widget.isDark ? Colors.white54 : Colors.black54),
              ),
            ),
            // Extra credit hint so the user knows a tap will not work here.
            if (widget.holdToActivate)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "HOLD",
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: widget.accentColor.withOpacity(0.9),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
