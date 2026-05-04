package recharge.midlife.base.ui;

import recharge.midlife.base.graphics.Texture;
import recharge.midlife.base.graphics.TextMesh;
import recharge.midlife.base.ui.UIElement;
import recharge.midlife.base.Game;

class UILabel extends UIElement {
  @:keep
  static var registry = NodeFactory.register(UILabel);

  var _text:String;
  var _mesh:TextMesh;

  static var _fontTexture:Texture = new Texture("midlife/default_font.png");

  public function new(name:String = "UILabel", ?params:Dynamic) {
    super(name, params);

    if (params != null) {
      setText(params.text == null ? "" : params.text);
    } else {
      setText("");
    }
  }

  public function setText(text:String):Void {
    _text = text;
    _dimensions = vec2(text.length, 1);
    _mesh = new TextMesh(text);
  }

  override public function draw():Void {
    Game.getInstance().getRenderer().toggleUIQueue();
    Game.getInstance().getRenderer().pushShader(UIElement.uiShader);
    Game.getInstance().getRenderer().pushTexture(_fontTexture);
    Game.getInstance()
      .getRenderer()
      .queueMesh(_mesh, vec3(getPosition() * vec2(1, -1), 0), vec3(1, 1, 1));

    super.draw();
  }
}
