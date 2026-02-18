# Independence

One of the goals is for the game engine to be as target independent as
possible. However, there are modules that are designed to be used with the game
engine exclusively due to Haxe language limits or reliance on Hashlink.

Here is a table to identify the language independence

## Engine Base

Component | Independent | Description
-- | -- | --
Animated | Independent | _
FileStream | X | Uses `sys` module, but will make independent 
Game | *Practically* Independent | See graphics module 
Node | Independent | _
NodeFactory | Independent | _
Scene | Independent | _
Utils | Independent | _

## Graphics

Component | Dependency | Description
-- | -- | --
LightArray | Independent | _
MarchingCubeMesh | Independent | _
Mesh | Independent | _
Renderer | X | Requires `hlsdl` but falls back to abstract
Shader | X | Requires `hlsdl` but falls back to abstract
Shapes | Independent | _
Texture | X | Requires 'hlsdl' but falls back to abstract

## Input

Component | Dependency | Description
-- | -- | --
Input | Independent | _
InputManager | Independent | _
