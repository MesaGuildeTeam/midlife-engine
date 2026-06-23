package recharge.midlife.js;

import js.Browser;
import js.html.Event;

import haxe.Timer;

import recharge.midlife.base.input.InputManager;
import recharge.midlife.base.input.Input;
import recharge.midlife.base.GameAbstract;
import recharge.midlife.base.graphics.Renderer;

class GameJS extends GameAbstract {
  static var InputParamMap:Map<Int, Float> = new Map();

  public static function getInstance():GameAbstract {
    if (GameAbstract._instance == null)
      GameAbstract._instance = new GameJS();

    return GameAbstract._instance;
  }

  function gameLoop():Void {
    static var currentTime = Timer.stamp();
    static var previousTime = 0.0;

    previousTime = currentTime;
    currentTime = Timer.stamp();
    var dt = (currentTime - previousTime);

    this.updateScene(dt);

    _renderer.preRender(_currentScene);
    this.drawScene();
    _renderer.flush(_currentScene);

    js.Browser.window.setTimeout(gameLoop, 10);
  }

  public override function run():Void {
    #if midlife_deferred
    _renderer = new RendererDeferredJS();
    #else
    _renderer = new RendererJS();
    #end

    // Populate InputManager
    InputManager.getInstance().setInput("DPadX", new Input(() -> {
      return InputParamMap.get(100) != null ? InputParamMap.get(100) : 0.0;
    }), new Input(() -> {
      return InputParamMap.get(97) != null ? InputParamMap.get(97) : 0.0;
    }));
    InputManager.getInstance().setInput("DPadY", new Input(() -> {
      return InputParamMap.get(119) != null ? InputParamMap.get(119) : 0.0;
    }), new Input(() -> {
      return InputParamMap.get(115) != null ? InputParamMap.get(115) : 0.0;
    }));

    InputManager.getInstance().setInput("LeftShoulder", new Input(() -> {
      return InputParamMap.get(113) != null ? InputParamMap.get(113) : 0.0;
    }));

    InputManager.getInstance().setInput("RightShoulder", new Input(() -> {
      return InputParamMap.get(101) != null ? InputParamMap.get(101) : 0.0;
    }));

    InputManager.getInstance().setInput("Start", new Input(() -> {
      return InputParamMap.get(27) != null ? InputParamMap.get(27) : 0.0;
    }));
    InputManager.getInstance().setInput("Select", new Input(() -> {
      return InputParamMap.get(8) != null ? InputParamMap.get(8) : 0.0;
    }));

    InputManager.getInstance().setInput("ButtonA", new Input(() -> {
      return InputParamMap.get(106) != null ? InputParamMap.get(106) : 0.0;
    }));
    InputManager.getInstance().setInput("ButtonB", new Input(() -> {
      return InputParamMap.get(107) != null ? InputParamMap.get(107) : 0.0;
    }));
    InputManager.getInstance().setInput("ButtonX", new Input(() -> {
      return InputParamMap.get(117) != null ? InputParamMap.get(117) : 0.0;
    }));
    InputManager.getInstance().setInput("ButtonY", new Input(() -> {
      return InputParamMap.get(105) != null ? InputParamMap.get(105) : 0.0;
    }));

    Browser.window.addEventListener("keydown", function(event:Dynamic) {
      if (event.key.length == 1) {
        InputParamMap.set(event.key.charCodeAt(0), 1.0);
      } else {
        InputParamMap.set(event.keyCode, 1.0);
      }
    });

    Browser.window.addEventListener("keyup", function(event:Dynamic) {
      if (event.key.length == 1) {
        InputParamMap.set(event.key.charCodeAt(0), 0.0);
      } else {
        InputParamMap.set(event.keyCode, 0.0);
      }
    });

    Browser.window.addEventListener("resize", function(event:Dynamic) {
      resizeCanvas();
    });

    resizeCanvas();

    js.Browser.window.setTimeout(gameLoop, 10);
  }

  function resizeCanvas() {
    var canvas:Dynamic = cast Browser.document.getElementById("midlife-canvas");
    dimensions = vec2(Browser.window.innerWidth, Browser.window.innerHeight);
    canvas.width = Browser.window.innerWidth;
    canvas.height = Browser.window.innerHeight;

    #if midlife_deferred
      if (Std.isOfType(_renderer, RendererDeferredJS)) {

        #if midlife_canvas_scaling
        while (dimensions.x >= 640 || dimensions.y >= 480) {
          dimensions = dimensions * 0.5;
        }
        #end

        _renderer.getBuffer().resize(cast dimensions.x, cast dimensions.y);
      }
    #end
  }
}
