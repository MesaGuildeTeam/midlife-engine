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
- [ ] If a spritesheet is needed, there is an object that generates meshes based on a spritesheet

### Render Pipeline

- [x] In order for a unit plane to be 1:1 with a 320x240 window, the z-position should equal 10
- [ ] The following textures should be usable and/or optional. They should also be layered in this order:
  - [x] Diffuse
  - [ ] First Diffuse can be color manipulated
  - [ ] Diffuse 2 (NOT Color Manipulated)
  - [ ] Specular
  - [ ] Normal
- [x] There is a controllable light and an option to add point lights if needed
- [ ] The rendering pipeline knows how to differentiate between the following
  - [x] Environment Models
  - [ ] Environment Lines
  - [x] UI Rendering

> To-Do: Consult with a 3D Artist what the standard maps are for a model and how color manipulation is usually used in development

### Window

- [x] Although resizable, a standard game viewport and window is 640x480px
- [x] Assuming no rotation or camera reconfiguration, if the object has a distance of 10 each unit should be 1 pixel at standard window size
- [ ] Graphics will scale as the window resizes keeping the ratio to the best of its ability
- [ ] UI should not be required to scale

## UI

- [ ] A UI System that is compatible with not just a mouse, but navigatable with a controller too

## Input

- [ ] Using an InputManager, the game can access a standard set of inputs
- [x] Inputs entirely depend on predefined callbacks
- [ ] You will have to define functions that populate the input manager depending on the platform you are playing on

## Files

- [ ] File loading should be simplified by combining external and embedded file
reading into one class
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
