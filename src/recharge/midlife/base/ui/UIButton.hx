package recharge.midlife.base.ui;

import recharge.midlife.base.ui.UILabel;
import recharge.midlife.base.input.InputManager;
import recharge.midlife.base.Utils;

class UIButton extends UIElement {
  @:keep
  static var registry = NodeFactory.register(UIButton);

  var _hovered:Bool = false;

  var _colorNormal:Vec4 = vec4(0.5, 0.5, 0.5, 1);
  var _colorHover:Vec4 = vec4(0.8, 0.8, 0.8, 1);

  public var textObject:UILabel;

  public function new(name:String = "UIButton", ?params:Dynamic) {
    super(name, params);

    textObject = new UILabel(name + "_text", params);
    setText(params != null && params.text != null ? params.text : "Button");
  }

  public override function init():Void {
    super.init();
    addChild(textObject);

    // Ideally we would want to just set anchor to center, but the box's center
    // is not the text center. See UIElement.uiPlane and graphics.Shapes.Plane for details.
    // TODO: MAKE THIS WORK PROPERLY
    textObject.setOffset(vec2(2, -2));
    // textObject.setAnchor(CENTER);
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
    _dimensions = vec2(text.length + 0.5, 1.5);
    textObject.setText(text);
  }

  public function focus():Void {
    _hovered = true;
  }

  public override function draw() {
    Game.getInstance().getRenderer().pushShader(UIElement.uiShader);
    Game.getInstance().getRenderer().pushDiffuseColor(_hovered ? _colorHover : _colorNormal);
    Game.getInstance()
      .getRenderer()
      .queueMesh(UIElement.uiPlane, vec3(getPosition() * vec2(1, -1), 0.1),
        vec3(_dimensions, 1), vec3(0));

    super.draw();
  }

  function findNextHoverable(direction:Vec2):UIButton {
    var neighbors = parent.getChildren();

    // 1 because the neighbor could be itself too
    if (neighbors.length == 1) return null;

    var bestNeighbor:Null<UIButton> = null;
    var bestDot = Math.POSITIVE_INFINITY;
    var bestAngle = Math.POSITIVE_INFINITY;

    for (neighbor in neighbors) {
      if (neighbor == this || !(Std.is(neighbor, UIButton))) continue;
      var castedNeighbor:UIButton = cast(neighbor, UIButton);

      var toNeighbor:Vec2 = castedNeighbor.getPosition() - getPosition();
      var dot = toNeighbor.length();
      var angle = Math.atan2(toNeighbor.y, toNeighbor.x) - Math.atan2(direction.y, direction.x);

      if (Math.abs(angle) >= Math.PI / 2) continue;
      if (bestAngle < angle && bestDot < dot) continue;
      bestDot = dot;
      bestAngle = angle;
      bestNeighbor = castedNeighbor;
    }

    return bestNeighbor;
  }

  public override function update(dt:Float):Void {
    super.update(dt);

    // Spatial Navigation using D-Pad
    var xAxis = InputManager.getInstance().getAxisImpulse("DPadX");
    var yAxis = -InputManager.getInstance().getAxisImpulse("DPadY");

    if ((xAxis != 0 || yAxis != 0) && _hovered) {
      var direction = vec2(xAxis, yAxis);
      var nextElement = findNextHoverable(direction);
      if (nextElement != null) {
        _hovered = false;
        nextElement.focus();
        InputManager.getInstance().flush();
      }
    }

    var selected = InputManager.getInstance().getInput("ButtonA").isPressed();

    if (_hovered && selected) {
      click();
    }
  }
}
