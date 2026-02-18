package tests;

import utest.Assert;

import recharge.midlife.base.input.Input;

class InputTest extends utest.Test {
  var testInput:Input;

  public function setupClass():Void {
    testInput = new Input();
  }

  public function testInitialCheck():Void {
    testInput.strength = 0.0;
    testInput.update();
    Assert.isFalse(testInput.isDown());
    Assert.isFalse(testInput.isPressed());
    Assert.isFalse(testInput.isReleased());
  }

  public function testInteraction():Void {
    // Press
    testInput.strength = 1.0;
    testInput.update();
    Assert.isTrue(testInput.isDown());
    Assert.isTrue(testInput.isPressed());
    Assert.isFalse(testInput.isReleased());

    // Hold
    testInput.update();
    Assert.isTrue(testInput.isDown());
    Assert.isFalse(testInput.isPressed());
    Assert.isFalse(testInput.isReleased());

    // Release
    testInput.strength = 0.0;
    testInput.update();
    Assert.isFalse(testInput.isDown());
    Assert.isFalse(testInput.isPressed());
    Assert.isTrue(testInput.isReleased());

    // Hold
    testInput.update();
    Assert.isFalse(testInput.isDown());
    Assert.isFalse(testInput.isPressed());
    Assert.isFalse(testInput.isReleased());
  }
}
