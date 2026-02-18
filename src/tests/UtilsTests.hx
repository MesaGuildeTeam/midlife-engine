package tests;

import utest.Assert;

import recharge.midlife.base.Utils;

class UtilsTests extends utest.Test {
  public function testRotate():Void {
    var vec = vec2(1, 1);
    var angle = Math.PI / 2;
    var rotated = Utils.rotateVec2(vec, angle);
    Assert.equals(0, rotated.x);
    Assert.equals(1, rotated.y);
  }
}
