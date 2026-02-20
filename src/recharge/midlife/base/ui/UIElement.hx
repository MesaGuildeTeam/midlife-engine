package recharge.midlife.base.ui;

import recharge.midlife.base.Game;
import recharge.midlife.base.Node;
import recharge.midlife.base.NodeFactory;
import recharge.midlife.base.graphics.Shader;
import recharge.midlife.base.graphics.Mesh;
import recharge.midlife.base.graphics.Shapes;

enum Anchor {
  TOP_LEFT;
  TOP_CENTER;
  TOP_RIGHT;
  MIDDLE_LEFT;
  CENTER;
  MIDDLE_RIGHT;
  BOTTOM_LEFT;
  BOTTOM_CENTER;
  BOTTOM_RIGHT;
}

class UIElement extends Node {
  @:keep
  static var registry = NodeFactory.register(UIElement);

  static var uiShader:Shader = new Shader("midlife/ui.frag", "midlife/ui.vert");
  static var uiPlane:Mesh = new Plane(vec3(0.5, 0.5, 0.0));

  var _uiTag:String;
  var _uiClass:String;

  var _anchor:Anchor;
  var _dimensions:Vec2;
  var _offset:Vec2;

  public function new(name:String = "UIElement", ?params:Dynamic) {
    super(name, params);

    _uiTag = "div";
    _uiClass = "";

    if (params != null) {
      _anchor = params.anchor == null ? TOP_LEFT : params.anchor;
      _dimensions = params.dimensions == null ? vec2(8, 8) : params.dimensions;
      _offset = params.offset == null ? vec2(0, 0) : params.offset;
    } else {
      _anchor = TOP_LEFT;
      _dimensions = vec2(8, 8);
      _offset = vec2(0, 0);
    }
  }

  public function addTheme(theme:String):Void {
    throw("TODO: UIElement.addTheme");
  }

  public function setAnchor(anchor:Anchor):Void {
    _anchor = anchor;
  }

  public var dimensions(get, set):Vec2;

  public function set_dimensions(dimensions:Vec2):Vec2 {
    _dimensions = dimensions / 8;
    return dimensions;
  }

  public function get_dimensions():Vec2 {
    return _dimensions;
  }

  public function setOffset(position:Vec2):Void {
    _offset = position / 8;
  }

  /**
    Returns the top left of the element in the container.
  **/
  public function getPosition():Vec2 {
    var topLeft:Vec2 = vec2(0, 0);
    var containerSize:Vec2 = Game.getInstance().dimensions / 8;

    if (Std.isOfType(_parent, UIElement)) {
      containerSize = cast(_parent, UIElement).dimensions;
      topLeft = cast(_parent, UIElement).getPosition();
    }

    switch (_anchor) {
      case TOP_LEFT:
        return topLeft + _offset;
      case TOP_CENTER:
        return topLeft
          + vec2(containerSize.x / 2 - _dimensions.x / 2, 0)
          + _offset;
      case TOP_RIGHT:
        return topLeft
          + vec2(containerSize.x - _dimensions.x, 0)
          + vec2(-_offset.x, _offset.y);
      case MIDDLE_LEFT:
        return topLeft
          + vec2(0, containerSize.y / 2 - _dimensions.y / 2)
          + _offset;
      case CENTER:
        return topLeft + (containerSize - dimensions) / 2 + _offset;
      case MIDDLE_RIGHT:
        return topLeft
          + vec2(containerSize.x - _dimensions.x,
            containerSize.y / 2 - _dimensions.y / 2)
          + _offset;
      case BOTTOM_LEFT:
        return topLeft + vec2(0, containerSize.y - _dimensions.y) + _offset;
      case BOTTOM_CENTER:
        return topLeft
          + vec2(containerSize.x / 2 - _dimensions.x / 2,
            containerSize.y - _dimensions.y)
          + _offset;
      case BOTTOM_RIGHT:
        return topLeft + containerSize - _dimensions - _offset;
    }
  }
}
