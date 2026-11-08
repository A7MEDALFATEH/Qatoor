# Validation

Validated on 6 November 2026 with **Godot 4.6.3**, standard edition.

- **116/116 automated integration checks passed.** The runner drives the real UI action signal, story controller, simulation, chapter transitions, and camera tweens.
- Completed the interactive journey from menu to finale, all four refinery products, the three-question quiz, and restart.
- Completed automatic playback through the same seven chapters and all four product animations.
- Ran the automatic film through the normal frame-driven controller and rendered the ending at approximately three minutes, including transitions and finale dialogue.
- Verified drilling start/pause/playback speed, completion, closed/partial/more-open choke behavior, insufficient natural-flow pressure, and pressure-dependent gas appearance.
- Verified correct and incorrect separator routing, quiz hints and first-attempt scoring, repeated-input protection, sound toggling, hidden engineering data, pause/resume, restart, and menu navigation.
- Rendered all 18 character states with GL Compatibility and inspected the main menu, all chapters, Arabic dialogue, quiz, settings, and pause layouts.
- Checked landscape window resizing with aspect-preserving scaling.
- Extracted the source into a clean directory, imported it without the development cache, and passed all 116 integration checks again.

The source distribution contains every required scene, script, animation, original procedural illustration, font, and generated-audio system. First import requires Godot; no network or earlier project is needed.

Run the checks:

```sh
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/run_checks.gd
```

Rendering was checked with Mesa software OpenGL in the development environment. Audio synthesis and playback resources were exercised with a dummy audio driver; speaker output and performance on the target exhibition laptop remain hardware checks. No Windows executable is included; open `project.godot` and press F5, or export using matching Godot templates.


## University Day update — 8 November 2026

Godot 4.6.3: **119/119 integration checks passed**, including the new marine route, all original routes, scientific model behavior, automatic playback, quiz and navigation. Rendered the new title and marine scene with GL Compatibility at 3840×2160. Twenty additional opening checks passed, covering all four student names, supervisor, label bounds, logo dimensions, and navigation into the original journey. Original engineering model, character scenes, and existing chapter scene resources were preserved.

The supplied Word document's university/college images were extracted without redrawing institutional marks. The user confirmed the first name is continuous and requested two additional students: Bahaa Khalid Abd-Allah and Zakaria Salah Al-Deen. Actual audio output and projector performance must be checked on the exhibition computer; automated playback uses a dummy audio device.
