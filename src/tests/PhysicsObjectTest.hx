package tests;

import utest.Assert;

import recharge.midlife.base.physics.GameObject;
import recharge.midlife.base.physics.World;
import recharge.midlife.base.Utils;

class PhysicsObjectTest extends utest.Test {
  public function testFall():Void {
    var object = new GameObject("TestObject");
    var world = new World("TestWorld", {gravity: vec3(0, 9.81, 0)});

    world.addChild(object);

    world.update(1.0);
    Assert.equals(object.position.y, 4.905);
  }

  public function testGradualFall():Void {
    var object = new GameObject("TestObject");
    var world = new World("TestWorld", {gravity: vec3(0, 9.81, 0)});

    world.addChild(object);

    for (i in 0...10) {
      world.update(0.1);
    }

    trace("This assert might return unsuccessful due to arithmetic error...");
    trace("Here is the calculated error for reference: "
      + Math.abs(object.position.y - 4.905));
    Assert.equals(object.position.y, 4.905);
  }

  public function testStaticObject():Void {
    var object = new GameObject("TestObject", {isStatic: true});
    var world = new World("TestWorld", {gravity: vec3(0, 9.81, 0)});

    world.addChild(object);

    world.update(1.0);
    Assert.equals(object.position.y, 0);
  }
}
