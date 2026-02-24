package examples;

import recharge.midlife.base.ui.UIElement;
import recharge.midlife.base.NodeFactory;
import recharge.midlife.base.Node;
import recharge.midlife.base.NodeFactory;
import recharge.midlife.base.ui.UIElement;
import recharge.midlife.base.ui.UILabel;
import recharge.midlife.base.ui.UIButton;

class UIExample extends Node {
  @:keep
  static var registry = NodeFactory.register(UIExample);

  public function new(name:String = "UIExample", ?params:Dynamic) {
    super(name, params);
  }

  public override function init():Void {
    var base:UIElement = NodeFactory.create("recharge.midlife.base.ui.UIElement",
      "BaseUI");

    base.dimensions = vec2(300, 200);
    base.setAnchor(CENTER);

    addChild(base);

    var label:UILabel = NodeFactory.create("recharge.midlife.base.ui.UILabel",
      "UILabel0", {
        text: "Test Label"
      });
    base.addChild(label);

    var button:UIButton = NodeFactory.create("recharge.midlife.base.ui.UIButton",
      "UIButton0", {
      text: "Click Me"
    });
    button.callback = () -> {
      trace("Button Clicked!");
    }
    button.focus();
    button.setAnchor(TOP_RIGHT);
    base.addChild(button);

    var button2:UIButton = NodeFactory.create("recharge.midlife.base.ui.UIButton",
      "UIButton1", {
      text: "Click Me"
    });
    button2.callback = () -> {
      trace("Button #2 Clicked!");
    }
    button2.setAnchor(TOP_RIGHT);
    button2.setOffset(vec2(0, 16));
    base.addChild(button2);
  }
}
