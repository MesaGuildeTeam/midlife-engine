package recharge.midlife.base.ui;

import haxe.io.Input;

import recharge.midlife.base.ui.UILabel;
import recharge.midlife.base.input.InputManager;
import recharge.midlife.base.Utils;

class UIButton extends UIElement {
  @:keep
  static var registry = NodeFactory.register(UIButton);

  var _hovered:Bool = false;

  public var textObject:UILabel;

  public function new(name:String = "UIButton", ?params:Dynamic) {
    super(name, params);

    textObject = new UILabel(name + "_text", params);
    setText(params != null && params.text != null ? params.text : "Button");
  }

  public override function init():Void {
    super.init();
    addChild(textObject);
    textObject.setAnchor(TOP_LEFT);
  }

  var _callback:Void->Void;

  public var callback(never, set):Void->Void;

  function set_callback(callback:Void->Void):Void->Void {
    _callback = callback;
    return callback;
  }

  function click():Void {
    if (_callback != null)
      _callback();
  }

  public function setText(text:String):Void {
    dimensions = vec2(text.length * 8 + 16, 24);
    textObject.setText(text);
  }

  public override function draw() {
    Game.getInstance().getRenderer().pushShader(UIElement.uiShader);
    Game.getInstance()
      .getRenderer()
      .queueMesh(UIElement.uiPlane, vec3((getPosition()) * vec2(1, -1), -0.1),
        vec3(dimensions, 1));

    super.draw();
  }

  public override function update(dt:Float):Void {
    super.update(dt);

    var selected = InputManager.getInstance().getInput("ButtonA").isPressed();

    if (_hovered && selected) {
      click();
    }
  }
}
