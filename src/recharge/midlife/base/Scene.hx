package recharge.midlife.base;

import recharge.midlife.base.Node;
import recharge.midlife.base.graphics.LightArray;

class Scene extends Node {
  public var lights:LightArray;

  public function new(name:String = "Scene", ?params:Dynamic) {
    super(name, params);

    lights = new LightArray();
  }
}
