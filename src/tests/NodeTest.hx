package tests;

import utest.Assert;

import recharge.midlife.base.Node;
import recharge.midlife.base.NodeFactory;

class TestNode extends Node {
  static var registry = NodeFactory.register(TestNode);

  public var testString:String;

  public function new(name:String, ?params:Dynamic) {
    super(name, params);
    testString = "";
    if (params == null)
      testString = "default";

    testString = params.testParam;
  }
}

class NodeTest extends utest.Test {
  public function testNodeCreation():Void {
    var node = new Node("Test Node");
    Assert.equals("Test Node", node.name);
  }

  public function testNestedNodeCreation():Void {
    // Create parent and child
    var node = new Node("Test Node");
    var child = node.addChild(new Node("Child Node"));
    Assert.equals("Child Node", child.name);
    Assert.equals(node, child.parent);

    // test Node.getChild
    var childRef = node.getChild("Child Node");
    Assert.equals(child, childRef);

    // test Node.removeChild but make sure child still exists
    node.removeChild(child);
    Assert.equals(null, node.getChild("Child Node"));
    Assert.equals(child, childRef);
  }

  public function testMultipleChildren():Void {
    var node = new Node("Test Node");
    var child1 = node.addChild(new Node("Child Node 1"));
    var child2 = node.addChild(new Node("Child Node 2"));

    Assert.equals(2, node.getChildren().length);
    Assert.equals(child1, node.getChildren()[0]);
    Assert.equals(child2, node.getChildren()[1]);
  }

  public function testMultipleChildrenSameName():Void {
    var node = new Node("Test Node");
    var child1 = node.addChild(new Node("Child Node"));
    var child2 = node.addChild(new Node("Child Node"));

    Assert.equals(2, node.getChildren("Child Node").length);
    Assert.equals(child1, node.getChildren("Child Node")[0]);
    Assert.equals(child2, node.getChildren("Child Node")[1]);
    Assert.notEquals(child1, child2);

    // Remove child2
    node.removeChild(child2);
    Assert.equals(1, node.getChildren("Child Node").length);
    Assert.equals(child1, node.getChildren("Child Node")[0]);
  }

  public function testRegistry():Void {
    // Test default class
    var newObject = NodeFactory.create("mesaguilde.carpenter.engine.Node",
      "Test Node");
    Assert.isTrue(Std.isOfType(newObject, Node));
    Assert.equals(newObject.name, "Test Node");

    // Test custom class with params
    var newObject2 = NodeFactory.create("tests.TestNode", "Test Node",
      {testParam: "thisIsAParam"});
    Assert.isTrue(Std.isOfType(newObject2, TestNode));
    Assert.equals(newObject2.name, "Test Node");
    Assert.equals(newObject2.testString, "thisIsAParam");
  }
}
