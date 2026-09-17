#  RA Duty Deck (Flutter)

A sleek, interactive 3D Neomorphic control deck built with Flutter & Dart, demonstrating advanced micro-interactions and state management. The persona for this build is a Resident Advisor's floor console: one screen that logs the five actions an RA actually repeats on a duty shift, with a live floor-load gauge that warns when the shift is getting heavy.

Built for In-Class Activity 03 (Day 3 of Flutter), extended from the provided starter code.

##  Features
- **3D Mechanical Duty Buttons**: LOUNGE, QUIET, ROUNDS and ALERT are physical push buttons built from dual opposing `BoxShadow` physics and `GestureDetector`, so each one visibly sinks under the finger and pops back out on release.
- **Hold to Escalate (long-press charge)**: a fifth control, ESCALATE, deliberately ignores a normal tap and only fires after a long-press charge completes, because paging the Residence Director should never happen on a misclick.
- **Live Duty State**: a running count of logged actions, a floor-load calibration slider, and a status banner that reports the last command that was activated.
- **80% Floor Load Warning**: crossing 80% on the slider shifts the whole background toward a warning tone, recolors the load readout and slider, flips the banner to an ON CALL SURGE warning, and turns the progress bar red.
- **Adaptive Theme System**: seamless switching between Dark Cyber Mode and Light Neomorphic Mode from the app bar.
- **Modular Component Design**: one reusable `TactileButton` custom widget drives all five controls, with a `holdToActivate` flag as the only difference between a tap control and a hold control.

##  Tech Stack
- **Framework**: Flutter (Material 3)
- **Language**: Dart
- **Key Widgets**: `StatefulWidget`, `GestureDetector`, `AnimatedContainer`, `Slider`, `LinearProgressIndicator`, `Wrap`

##  The Five Controls

| Control | Icon | Accent | Gesture | Status string |
|---|---|---|---|---|
| LOUNGE | `Icons.lightbulb` | `Colors.amber` | Tap | LOUNGE LIGHTS ACTIVATED |
| QUIET | `Icons.nightlight_round` | `Colors.indigoAccent` | Tap | QUIET HOURS ACTIVATED |
| ROUNDS | `Icons.how_to_reg` | `Colors.greenAccent` | Tap | FLOOR ROUNDS ACTIVATED |
| ALERT | `Icons.campaign` | `Colors.redAccent` | Tap | FLOOR ALERT ACTIVATED |
| ESCALATE | `Icons.support_agent` | `Colors.orangeAccent` | Long press | RD ESCALATION ACTIVATED |

##  Screenshots

| Unpressed (elevated) | Mid-press (sunken) |
|---|---|
| ![Unpressed](screenshots/unpressed.png) | ![Mid-press](screenshots/pressed.png) |

## Running It

```bash
flutter pub get
flutter devices
flutter run
```

Hot reload with `r` after an edit, or `R` for a hot restart when an initial state value changes.

##  Design Decisions

**Why an RA duty console instead of a spaceship.** I manage two floors as a Residential Advisor, so the four repeated actions were already obvious: turn the lounge lights on, set quiet hours, log nightly rounds, and push an announcement to both floors. Picking a persona I live in meant the labels, the icons and the status strings all wrote themselves, and the "floor load" gauge had a real meaning instead of being decorative.

**Why the threshold feedback is layered rather than a single color change.** The assignment only asks for one piece of feedback at 80%. I used four that all read from the same `isOverload` boolean: the background, the load readout color, the status banner text, and a `LinearProgressIndicator` that flips to red. The point is that the rule lives in exactly one place. `final bool isOverload = powerLevel > overloadThreshold;` is computed once at the top of `build()`, so there is no way for one widget to disagree with another about whether the deck is overloaded. The background sits inside an `AnimatedContainer` with a 300ms duration so the shift fades in instead of snapping, which makes the threshold feel like a dimmer rather than a light switch.

**Why the fifth control uses a long press.** Every other control is reversible. Escalating to the Residence Director is not, so it should cost the user something deliberate. `holdToActivate` makes `onTapUp` restore the button visually without calling `widget.onPressed()`, and the action moves to `onLongPress`. `onLongPressStart` and `onLongPressEnd` keep the sunken look accurate while the charge is building, and a small HOLD caption tells the user why their tap did nothing. That reuses the same widget rather than forking a second button class.

**Why `isPressed` stays inside `_TactileButtonState`.** Each button's pressed flag is the only thing it does not need to share. Keeping it local means a press rebuilds one 140x140 subtree instead of the whole dashboard, and it means five buttons cannot sink at once off a single shared boolean. The shared numbers, `totalTaps`, `powerLevel` and `systemStatus`, stay in the parent because the metrics card, the banner, the slider and the progress bar all read them.

**Why the debug prints are still in the file.** Critical Thinking Question 2 asks for the observed order of `onTapDown`, `onTapUp` and `onTapCancel`. The `debugPrint()` calls that produced that evidence were left in and labeled, rather than deleted, so the claim in the write-up can be reproduced by anyone who runs the project.

##  Project Structure

```
inclass_act03/
├── lib/
│   └── main.dart          # the whole app: theme root, dashboard, TactileButton
├── screenshots/
│   ├── unpressed.png
│   └── pressed.png
├── README.md
└── pubspec.yaml
```

##  Author

Uyiosa Nehikhuere, Computer Science, Georgia State University
