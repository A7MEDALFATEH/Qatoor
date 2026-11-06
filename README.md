# QATOOR — The Interactive Journey of a Crude Oil Drop

**رحلة قطرة النفط: من أعماق الأرض إلى السطح**

An original, standalone Godot 4 educational exhibition. Help Qatoor travel from the connected pores of reservoir rock, through drilling and well completion, up the production tubing, through phase separation, and onward to everyday petroleum-derived products. Arabic character dialogue accompanies an English exhibition interface.

## Open and run

1. Install **Godot 4.3 or newer**, standard edition; no .NET installation is needed.
2. In the Godot Project Manager, choose **Import** and select this folder's `project.godot`.
3. Allow the first asset import to finish, then press **F5** to run the project. To use **F6**, first open `scenes/main.tscn` so the whole experience is the current scene.

From a terminal, with Godot on the executable path:

```sh
godot --path .
```

The project includes its scripts, scenes, original procedural artwork, shaders, generated sound effects, and fonts. It does not require a previous project, external account, network connection, or recorded narration. The renderer uses Godot's GL Compatibility mode. The design viewport is 1920 × 1080; the initial window is 1280 × 720 and can be resized.

## Exhibition controls

Use the mouse or a touchscreen to press the large on-screen controls. The interactive journey waits at its decision points; drilling, the choke, camera framing, separator choices, and product selections visibly affect the scene. Incorrect separator and quiz answers offer hints and another attempt.

| Key | Action |
| --- | --- |
| **Esc** | Pause or resume |
| **F11** | Toggle fullscreen |
| **M** | Toggle sound |
| **D** | Show or hide engineering data |
| **R** | Restart the journey |

The header and pause/settings interface also provide exhibition controls. Engineering data starts hidden so the story remains central. Sound can be muted without interrupting the experience.

Choose **Start Journey** for audience participation, or **Watch the Movie** for a shared-scene cinematic demonstration lasting about three minutes. Automatic mode operates the story's controls and makes the correct educational choices. The finale offers restart, automatic replay, and a three-question knowledge quiz. Product animations return to product selection so visitors can explore all four routes.

## The journey

1. **Reservoir:** meet Qatoor inside connected oil-bearing rock pores.
2. **Drilling and completion:** rotate and advance the drill, circulate drilling fluid, then prepare the production pathway. Playback speed changes presentation speed, not a predicted drilling rate.
3. **Pressure challenge:** compare closed, partly open, and more open choke states.
4. **Production journey:** follow Qatoor upward; adjust the choke and camera zoom. Ghazi appears when the model permits free gas.
5. **Three-phase separator:** guide oil, gas, and water to their respective outlets.
6. **Refinery and products:** explore car fuel, aviation fuel, plastics, and asphalt through distinct animated sequences.
7. **Finale and quiz:** celebrate the completed journey and revisit the main scientific ideas.

## Editing the project

The main scene connects reusable story, character, camera, dialogue, interaction, audio, and engineering systems. Narrative content lives in `data/story_data.gd`. Character scenes are in `characters/`; their editable vector drawing and expressions live in `scripts/character_controller.gd`, with reusable AnimationPlayer tracks in `animations/character_motion.tres`. Environments are drawn in modular scene scripts, so illustrations can be replaced with imported artwork while retaining the story controls.

Arabic text uses bundled **Noto Sans Arabic** and Godot's advanced text shaping. Keep Arabic dialogue right-to-left when changing its layout. Font license files are included in `assets/fonts/`.

There is no required voice-over asset. For later Arabic recordings, add a `voice_tracks` dictionary to a stage in `data/story_data.gd`, mapping the exact spoken Arabic string to a `res://audio/your_recording.ogg` path. The story passes it through the dialogue layer automatically; absent files retain the animated text fallback. Sound effects and ambience are synthesized locally by `scripts/audio_manager.gd`.

## Scientific scope and validation

All numerical examples are labeled **Illustrative Educational Simulation**. This project is an educational narrative, not a validated field simulator or a well-design tool. See [`data/engineering_notes.md`](data/engineering_notes.md) for the equations, units, assumptions, and limitations.

Validated with Godot 4.6.3 using the full interactive and automatic journeys, scene/resource loading, pressure behavior, repeated input, quiz retries, and generated audio playback. All 18 character states were rendered with GL Compatibility; menu, chapters, Arabic dialogue, and quiz layouts were visually reviewed. See `VALIDATION.md` for the final results. Performance on the intended exhibition laptop has not been measured. Use Godot's normal export workflow and install matching export templates if a packaged Windows executable is needed.

To rerun the integration checks from a fresh copy:

```sh
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/run_checks.gd
```
