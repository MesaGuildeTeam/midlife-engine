package recharge.midlife.hl;

import recharge.midlife.base.Node;
import recharge.midlife.base.input.InputManager;
import recharge.midlife.base.input.Input;

import sdl.Sdl;
import sdl.Window;
import sdl.GL;
import sdl.Event;

import haxe.Timer;

class GameHL extends recharge.midlife.base.GameAbstract {
  static var InputParamMap:Map<Int, Float> = new Map();

  public static function getInstance():recharge.midlife.base.GameAbstract {
    if (recharge.midlife.base.GameAbstract._instance == null)
      recharge.midlife.base.GameAbstract._instance = new GameHL();

    return recharge.midlife.base.GameAbstract._instance;
  }

  function processKeyboard(strength:Float, keyCode:Int) {
    InputParamMap.set(keyCode, strength);
  }

  override public function run() {
    Sdl.init();
    Sdl.setGLOptions(3, 2, 24, 8, 1, 1);

    // Initialize Window and Renderer
    var title = haxe.macro.Compiler.getDefine("engine_gametitle");
    title = title != null ? title : "Heartbreak Engine";

    // Base Resolution: 320x240 like the PS1
    // Still recommend to play at 1280x960 or 640x480
    var window = new Window(title, 320, 240);
    window.renderTo();

    if (!GL.init()) {
      throw("OpenGL is unavailable");
    }
    _renderer = new RendererHL();

    // Populate InputManager
    InputManager.getInstance().setInput("DPadX", new Input(() -> {
      return InputParamMap.get(100);
    }), new Input(() -> {
      return InputParamMap.get(97);
    }));
    InputManager.getInstance().setInput("DPadY", new Input(() -> {
      return InputParamMap.get(119);
    }), new Input(() -> {
      return InputParamMap.get(115);
    }));

    InputManager.getInstance().setInput("ButtonA", new Input(() -> {
      return InputParamMap.get(32); 
    }));

    var currentTime = Timer.stamp();
    // Run Game Loop
    var running = true;
    while (running) {
      var previousTime = currentTime;
      Sdl.processEvents((event) -> {
        if (event.type == EventType.Quit) {
          running = false;
        }

        if (event.type == EventType.KeyDown) {
          processKeyboard(1.0, event.keyCode);
        }

        if (event.type == EventType.KeyUp) {
          processKeyboard(0.0, event.keyCode);
        }

        return true;
      });

      GL.viewport(0, 0, window.width, window.height);

      // Update and render the current scene
      currentTime = Timer.stamp();
      var dt = (currentTime - previousTime) * 2;
      this.updateScene(dt);

      this.drawScene();
      GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
      _renderer.flush(_currentScene);
      window.present();
    }

    window.destroy();
    Sdl.quit();
  }
}
