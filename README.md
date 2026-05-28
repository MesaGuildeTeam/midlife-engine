# Midlife Engine

A target independent game development framework/engine designed for 2D and 2.5D
games, especially for console. Code it once, build it for any platform.

## Features

- An API for developing games using Haxe with abstractions of a game engine
- Fundamental modules for Graphics, Input, Audio, UI, and Physics
  - These components can even be used outside the game engine if you wish to use other libraries*

> *please see the compatibility chart in docs/compatibility.md

## Basic Usage

Please make sure you have the following tools installed:

- Haxe/Haxelib
- Hashlink (for the hashlink target)

To start making games with the engine in its bare form, you add the package to
your game and install any other packages needed to make the engine work.

```
haxelib git midlife-engine https://github.com/lastwalkstudio/midlife-engine
haxelib install vector-math
haxelib install hlsdl
```

You will then need to create a .hx file that includes your static main, and an
example scene as demonstrated below:

```haxe
import recharge.midlife.base.Scene;

class ExampleScene extends Scene {
  // Follow documentation further to learn how to compose this
}

// Main.hx
import recharge.midlife.base.Game;

class Main {
  public static function main():Void {
    var game = new Game();
    game.run();
  }
}
```

When you are ready to compile the code for testing, you can create an hxml with the following:

```hxml
-L midlife-engine
# Include any other libraries you may need

-hl bin/hlboot.dat
--dce full

# Include your initial scene
ExampleScene
-D engine-initialscene=ExampleScene

# Configure game window and similar settings
-D engine-gametitle=Example Title

-p src
--main Main 
--cmd hl bin/hlboot.dat
```

## Developing

To work on the libary, you will need the following installed:

- Haxe/Haxelib
  - hmm

after setting everything up on your end and cloning the repo, you can run
`hmm install` to setup the packages

To unit test the code, run `haxe scripts/test.hxml` and to get a coverage 
report, you can use `haxe scripts/coverage.hxml`.

## Credits

Default Pixel Font: https://frostyfreeze.itch.io/pixel-bitmap-fonts-png-xml