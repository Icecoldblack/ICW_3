# In-Class 03: the last 20 minutes on your machine

Everything that could be written for you is written. What is left needs a machine with Flutter and an emulator, which this session does not have. Work top to bottom.

## 1. Create the project and drop in the code

```bash
flutter create inclass_act03
cd inclass_act03
```

Replace `lib/main.dart` with the `main.dart` from this delivery, and put `README.md` in the project root next to `pubspec.yaml`.

```bash
flutter devices
flutter run
```

Press `r` for hot reload after any edit, `R` for a hot restart.

## 2. Sanity check the app (2 minutes)

- Tap LOUNGE. The button should sink, the LOGGED ACTIONS counter goes to 1, the banner reads `STATUS: LOUNGE LIGHTS ACTIVATED`.
- Tap QUIET, ROUNDS and ALERT. Each one sinks on its own, no other button moves. That is Milestone 1 working.
- Drag the slider past 80. The background shifts to the warning tone, the FLOOR LOAD number and slider turn orange, the banner flips to `ON CALL SURGE`, and the progress bar turns red. That is Milestone 2.
- Tap ESCALATE once quickly. Nothing should happen, by design. Now press and hold it for about a second. The counter increments and the banner reads `RD ESCALATION ACTIVATED`. That is the extra credit control.

## 3. Confirm the two experiments in your write-up (5 minutes)

The Word document says you ran these. Run them so that stays true. Both are quick and both are already reverted in the code you were given.

**Question 2, callback order.** The `debugPrint()` lines are already in `main.dart`. Just watch the terminal while you tap. You should see:

```
flutter: onTapDown fired for LOUNGE
flutter: onTapUp fired for LOUNGE
```

Then touch ROUNDS and slide your finger off before lifting:

```
flutter: onTapDown fired for ROUNDS
flutter: onTapCancel fired for ROUNDS
```

Then press and hold ESCALATE:

```
flutter: onTapDown fired for ESCALATE
flutter: onTapCancel fired for ESCALATE
flutter: onLongPressStart charging ESCALATE
flutter: onLongPress charge complete for ESCALATE
flutter: onLongPressEnd released ESCALATE
```

If any line differs on your machine, paste what you actually see into the document. That is the whole point of the evidence requirement.

**Question 1, the lifted state bug.** In `_TactileButtonState`, comment out `bool isPressed = false;` and instead add it to `_ControlDeckScreenState`, then in `TactileButton` read the parent's value. The fastest hack that shows the bug: in `_ControlDeckScreenState` add `bool isPressed = false;`, add `final bool isPressed;` to `TactileButton`, pass `isPressed: isPressed` to all five, and have the child call a parent callback. Hot restart, tap one button, and watch all five sink together. Then undo it with Ctrl+Z.

**Question 3, the flipped light source.** In the unpressed `boxShadow` list, change `Offset(8, 8)` to `Offset(-8, 8)` and `Offset(-8, -8)` to `Offset(8, -8)`, hot reload, look at the buttons, then undo.

## 4. Capture the two required screenshots

Run on the emulator, not Chrome, since the assignment asks for a phone emulator or simulator.

- Screenshot A, unpressed: the deck at rest with all five buttons elevated.
- Screenshot B, mid-press: hold a finger (click and hold with the mouse on the emulator) on LOUNGE so its shadows are collapsed and its icon is amber, and capture while still held.

On an Android emulator the camera icon in the side toolbar saves to your Desktop. On the iOS simulator use `Cmd + S`.

Name them `unpressed.png` and `pressed.png`, and put them in a `screenshots/` folder in the project so the README image links resolve on GitHub.

## 5. Push to a new public GitHub repo

```bash
cd inclass_act03
git init
git add .
git commit -m "In-Class Activity 03: RA Duty Deck, tactile control studio"
git branch -M main
git remote add origin https://github.com/<your-username>/inclass_act03.git
git push -u origin main
```

Create the empty public repo on github.com first, then run the remote and push lines. Confirm the README renders and both screenshots appear before you submit the link.

## 6. Upload to iCollege, In-Class 03 folder

All five items:

1. The GitHub repository URL
2. `main.dart`
3. `unpressed.png`
4. `pressed.png`
5. `ICA03_Critical_Thinking_Uyiosa_Nehikhuere.docx`

`README.md` is in the repo and is also worth attaching if the folder allows it.

Deadline is 8:00 PM today.

## Rubric coverage

| Line item | Points | Where it is satisfied |
|---|---|---|
| Milestone 1, custom icons, labels, accent colors on all buttons | 25 | Five personalized controls in the `Wrap`, none left as starter defaults |
| Milestone 2, feedback at the 80% threshold | 25 | `isOverload` drives background, readout color, slider color, banner text and a `LinearProgressIndicator` |
| Milestone 3, README template plus accurate description | 15 | `README.md`, template structure kept, features rewritten for the persona |
| Code comments and clean build | 15 | Every block and every customization commented, no leftover starter labels |
| Critical thinking, Q1 through Q4 | 20 | The Word document, each answer tied to real values from this build |
| Extra credit, 5th control with `onLongPress` | +5 | ESCALATE, `holdToActivate: true` |
| Extra credit, README Design Decisions write-up | +5 | Design Decisions section in `README.md` |
