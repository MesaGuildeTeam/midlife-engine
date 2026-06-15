package recharge.midlife.js;

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

    this.updateScene(0.01);

    _renderer.preRender(_currentScene);
    this.drawScene();
    _renderer.flush(_currentScene);
    //window.present();

    js.Browser.window.setTimeout(gameLoop, 10);
  }

  public override function run():Void {
    _renderer = new Renderer();

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

    js.Browser.window.setTimeout(gameLoop, 10);
  }
}
