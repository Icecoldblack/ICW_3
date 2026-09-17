# Experiment Results

Evidence for the In-Class Activity 03 critical thinking questions. Each experiment
was applied to `lib/main.dart`, observed on an Android emulator (Pixel, API 37),
then reverted. The working app in `lib/main.dart` is the correct version; the
modified copies are kept here so the observations can be reproduced.

---

## A. Callback order (Question 2)

No code change was needed. The `debugPrint()` calls are already in
`lib/main.dart`, inside `onTapDown`, `onTapUp`, `onTapCancel` and the three
long-press handlers.

**Tap LOUNGE**

```
I/flutter ( 6120): onTapDown fired for LOUNGE
I/flutter ( 6120): onTapUp fired for LOUNGE
```

**Touch ROUNDS, drag the finger off the button, then lift**

```
I/flutter ( 6120): onTapDown fired for ROUNDS
I/flutter ( 6120): onTapCancel fired for ROUNDS
```

`onTapUp` never fires, so `widget.onPressed()` is never called and the counter
does not increment. The button still pops back out, because `onTapCancel` also
resets `isPressed` to false.

**Press and hold ESCALATE**

```
I/flutter ( 6120): onTapDown fired for ESCALATE
I/flutter ( 6120): onTapCancel fired for ESCALATE
I/flutter ( 6120): onLongPressStart charging ESCALATE
I/flutter ( 6120): onLongPress charge complete for ESCALATE
I/flutter ( 6120): onLongPressEnd released ESCALATE
```

The `onTapCancel` in the middle is the interesting part. Both a tap recognizer
and a long-press recognizer are competing in the gesture arena. Once the press
passes the long-press timeout, the long-press recognizer wins the arena and the
tap recognizer is cancelled, which is why a cancel arrives before the long-press
callbacks rather than an `onTapUp`.

---

## B. Lifted state bug (Question 1)

**Change:** `bool isPressed` moved out of `_TactileButtonState` and into
`_ControlDeckScreenState`, then passed back down to all five buttons as a prop
with a `ValueChanged<bool>` callback pushing changes up.

See `main_experiment_b_lifted_state.dart`.

**Observed:** pressing **one** button sinks **all five at once**. Holding LOUNGE
puts every button into its pressed state simultaneously: each icon and label
jumps to its own accent color at the same moment (LOUNGE amber, QUIET indigo,
ROUNDS green, ALERT red, ESCALATE orange), every icon shrinks from 46px to 40px,
and all five tiles collapse their shadows from the 8px elevated offsets to the
2px pressed offsets. The deck looks like five fingers pressed it at once.

Reproduced with a second button: holding QUIET alone produces the identical
all-five result, confirming it is not specific to LOUNGE.

See `experiment_b_all_five_sink.png` (only LOUNGE is being touched).

**Why:** one boolean now backs five widgets. `setState()` in the parent rebuilds
the whole dashboard subtree, and every `TactileButton` reads the same
`widget.isPressed`, so they cannot disagree about who is pressed. The pressed
flag is per-button data, so it belongs to the button. The shared values
(`totalTaps`, `powerLevel`, `systemStatus`) correctly stay in the parent because
the metrics card, banner, slider and progress bar all need to read them.

---

## C. Flipped light source (Question 3)

**Change:** in the unpressed `boxShadow` list only,
`Offset(8, 8)` to `Offset(-8, 8)` and `Offset(-8, -8)` to `Offset(8, -8)`.

See `main_experiment_c_flipped_light.dart`.

**Observed:** the implied light source moves from the top-left to the
**top-right**. The dark shadow now falls down and to the left, and the pale
highlight sits on the upper-right edge: a mirror image of the original.

**They still read as raised.** The depth illusion survives because the two
shadows remain *opposed*, dark on one corner and light on the opposite one. That
opposition, not the specific corner, is what makes the surface read as extruded.

Two things do get worse. The lighting no longer matches the real-world default of
an overhead light slightly to the left, so it feels subtly off. And the rest of
the screen was not flipped: the metrics card still casts its shadow downward with
`Offset(0, 5)`, so the deck is now internally inconsistent about where the light
comes from, which is more noticeable than the flip itself.

A button only reads as *sunken* when the offsets are inverted relative to each
other, which is exactly what the pressed state does: the dark shadow moves to the
top-left and the light to the bottom-right, at a much smaller 2px offset.

See `experiment_c_flipped_light.png`.
