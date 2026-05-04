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

  static public var window:Window;

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
    window = new Window(title, 640, 480);
    window.renderTo();

    if (!GL.init()) {
      throw("OpenGL is unavailable");
    }

    #if midlife_deferred
    _renderer = new RendererDeferredHL();
    #else
    _renderer = new RendererHL();
    #end

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

    InputManager.getInstance().setInput("LeftShoulder", new Input(() -> {
      return InputParamMap.get(113);
    }));

    InputManager.getInstance().setInput("RightShoulder", new Input(() -> {
      return InputParamMap.get(101);
    }));

    InputManager.getInstance().setInput("Start", new Input(() -> {
      return InputParamMap.get(27);
    }));
    InputManager.getInstance().setInput("Select", new Input(() -> {
      return InputParamMap.get(8);
    }));

    InputManager.getInstance().setInput("ButtonA", new Input(() -> {
      return InputParamMap.get(106);
    }));
    InputManager.getInstance().setInput("ButtonB", new Input(() -> {
      return InputParamMap.get(107);
    }));
    InputManager.getInstance().setInput("ButtonX", new Input(() -> {
      return InputParamMap.get(117);
    }));
    InputManager.getInstance().setInput("ButtonY", new Input(() -> {
      return InputParamMap.get(105);
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

        if (event.state == sdl.WindowStateChange.Resize) {
          dimensions = vec2(window.width, window.height);

          #if midlife_deferred
          if (Std.isOfType(_renderer, RendererDeferredHL)) {
            var canvasSize = vec2(window.width, window.height);

            #if midlife_canvas_scaling
            while (canvasSize.x >= 640 || canvasSize.y >= 480) {
              canvasSize = canvasSize * 0.5;
            }
            #end

            _renderer.getBuffer().resize(cast canvasSize.x, cast canvasSize.y);
          }
          #end
        }

        if (event.type == EventType.KeyDown) {
          trace(event.keyCode);
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
      _renderer.flush(_currentScene);
      window.present();
    }

    window.destroy();
    Sdl.quit();
  }
}
