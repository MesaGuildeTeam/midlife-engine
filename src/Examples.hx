import recharge.midlife.base.input.Input;
import recharge.midlife.base.input.InputManager;
import recharge.midlife.base.Game;
import recharge.midlife.base.Node;
import recharge.midlife.base.Scene;
import recharge.midlife.base.NodeFactory;

import examples.HelloWorld;
import examples.UIExample;
import examples.PhysicsDemo;

class ExampleTraverser extends Scene {
  @:keep
  static var registry = NodeFactory.register(ExampleTraverser);

  var _examples:Array<String>;
  var _currentExample:String;
  var _exampleIndex:Int;

  public function new(name:String, ?params:Dynamic) {
    super(name, params);
    _examples = ["examples.HelloWorld", "examples.UIExample", "examples.PhysicsDemo"];
    _exampleIndex = 0;
  }

  function loadExample(name:String):Void {
    if (_currentExample != null)
      removeChild(_currentExample);

    trace("Loading example " + name);
    _currentExample = name;
    addChild(NodeFactory.create(_currentExample, _currentExample));
    
    // These are here because technically we never switch scenes
    lights.clearLights();
    camera = null;
  }

  public override function init():Void {
    // Initialize InputManager

    loadExample(_examples[0]);
  }

  public override function update(dt:Float):Void {
    super.update(dt);

    if (InputManager.getInstance().getInput("DPadX").isPressed()) {
      loadExample(_examples[(_exampleIndex + 1) % _examples.length]);
      _exampleIndex = (_exampleIndex + 1) % _examples.length;
    }

    if (InputManager.getInstance().getInput("DPadX", 1).isPressed()) {
      _exampleIndex = --_exampleIndex < 0 ? _examples.length
        - 1 : _exampleIndex;
      loadExample(_examples[_exampleIndex]);
    }
  }
}

class Examples {
  public static function main():Void {
    var game = new Game();
    game.run();
  }
}
