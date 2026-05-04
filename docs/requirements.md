# Overview

There are many game development frameworks that welcome lower level development
than game engines. The goal of this engine is while offering it's own interface,
allow for the ease of development through its own interface and wrappers, while
allowing developers to wrap the abstracts in the framework code the user is familar
with.

These are the following categories that should be implemented:

- Graphics interface compatible with games similar to Octopath Traveller
- Input system compatible with Controllers (ideally SNES size)
- Audio system that plays audio differentiating between Music and SFX
- A simple UI system
Offer compatibility with the RetroLib API but build natively to

## Graphics

- [x] Engine focuses primarily on planes and cubes.
- [x] If a more complex mesh is needed, the developers can work with basic shapes to compose more complex
- [x] You can use simple textures to cover a plane

### Render Pipeline

- [x] In order for a unit plane to be 1:1 with a 320x240 window, the z-position should equal 10
- [x] The following PBR parameters should be controllable:
  - [x] Diffuse
  - [x] First Diffuse can be color manipulated
  - [x] Diffuse 2 (NOT Color Manipulated)
  - [x] Specular
  - [x] Normal
- [x] There is controllable light and an option to add point lights if needed
- [x] The rendering pipeline knows how to differentiate between the following
  - [x] Environment Models
  - [x] UI Rendering

> To-Do: Consult with a 3D Artist what the standard maps are for a model and how color manipulation is usually used in development

### Window

- [x] Although resizable, a standard game viewport and window is 640x480px
- [x] Assuming no rotation or camera reconfiguration, if the object has a distance of 10 each unit should be 1 pixel at standard window size
- [ ] Graphics will scale as the window resizes keeping the ratio to the best of its ability
- [ ] UI should not be required to scale drastically

## UI

- [x] A UI System that is compatible with a controller first
  - [ ] Mouse functionality would be nice too
- [ ] The following should be implemented
  - [x] Labels
  - [x] Buttons
  - [ ] UI Images
  - [ ] Text Input Fields

## Input

- [x] Input manager itself is generic but can also read rising/falling edges of inputs
- [ ] The following inputs are pre-defined for the game engine
  - [x] D-pad
  - [x] A Button
  - [ ] B Button
  - [ ] X Button
  - [ ] Y Button
  - [ ] Shoulder Buttons
  - [ ] Pause

## Files

- [ ] File loading should be simplified by combining external and embedded file
reading into one class to read file data from
- [ ] You can read files with the following priority:
  - [x] Embedded Files
  - [x] Game Assets
  - [ ] Save Data
- [ ] you can only write to Save Data

## Editor

- [ ] The following tabs should be implemented with the following priority
  - [ ] Files Viewer
  - [ ] SDF Model Editor
  - [ ] Scene layout
  - [ ] Spritesheet Manager
  - [ ] Code Editor?
  - [ ] Project Config
- [ ] the editor should allow multiple people to work on a game in real time across devices
