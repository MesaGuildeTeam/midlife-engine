/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package recharge.midlife.base;

/**
  The base class for all objects in the game.

  ## Usage 
  To create a new Node type, you must derive from this class and register it
  with the NodeFactory. This is done by calling the register function in the
  NodeFactory class. You are suggested to use the `@:keep` metadata to keep
  the class registered whenever the class is compiled or imported.

  ```haxe
  class MyNode extends Node {
      @:keep
      static var registry = NodeFactory.register(MyNode);
      public function new(name:String) {
          super(name);
      }
  }
  ```

  @warning When extending this class, you are advised to add children only in
  the `init()` method. Adding children in the constructor may lead to unexpected
  behavior. You are however free to extend the constructor to set up object
  variables and properties.

  @see `NodeFactory`
**/
class Node {
  @:keep
  static var registry = NodeFactory.register(Node);

  var _children:Map<String, Array<Node>>;
  var _parent:Node;

  public var name:String;

  var _enabled:Bool;

  public function new(name:String = "Node", ?params:Dynamic) {
    _children = new Map();
    _parent = null;
    _enabled = true;
    this.name = name;
  }

  /**
   * Adds a child node to this node.
   * 
   * > **Technical Details:**
   * >
   * > O(1) operation. If the name has not been used before, a new array is 
   * > created to hold the children with that name. If a child with the same
   * > name already exists, the child is added to the existing array to 
   * > allow multiple children with the same name.
   * 
   * @param child the node you want to add as a child
   * @return Node a reference to the added child node
   */
  public function addChild(child:Node):Node {
    var name = child.name;
    if (!_children.exists(name))
      _children[name] = new Array<Node>();

    if (_children[name].indexOf(child) != -1)
      throw("Node.addChild: Child " + name + " already exists");

    _children[name].push(child);
    child._parent = this;
    child.init();
    return child;
  }

  /**
   * Returns the first child node with the given name.
   * @param name 
   * @return Node
   */
  public inline function getChild(name:String):Node {
    return getChildren(name)[0];
  }

  /**
   * Returns all child nodes with the given name. If no name is provided,
   * all child nodes are returned.
   * 
   * > **Technical Details:**
   * > 
   * > O(n) operation worst case, as it may need to concatenate all child arrays.
   * > If a name is provided, O(1) operation to retrieve the existing array
   * 
   * @param name 
   * @return Array<Node>
   */
  public function getChildren(?name:String):Array<Node> {
    if (name != null)
      return _children[name];

    var allChildren:Array<Node> = [];
    for (name in _children.keys())
      allChildren = allChildren.concat(_children[name]);

    return allChildren;
  }

  public function removeChild(name:String, index:Int = 0):Void {
    _children[name].splice(index, 1);
  }

  public var enabled(get, set):Bool;

  public function get_enabled():Bool {
    return _enabled;
  }

  public function set_enabled(enabled:Bool):Bool {
    _enabled = enabled;

    if (_enabled)
      onEnable();
    else
      onDisable();

    return _enabled;
  }

  public var parent(get, never):Node;

  public function get_parent():Node {
    return _parent;
  }

  /**
   * The transformation matrix of this node. this matrix can not be overridden.
   */
  public var transform(get, never):Mat4;

  public function get_transform():Mat4 {
    return mat4(1.0);
  }

  public var globalPosition(get, never):Vec3;

  public function get_globalPosition():Vec3 {
    var position4:Vec4 = transform * vec4(0, 0, 0, 1);

    return position4.xyz;
  }

  // METHODS DESIGNED FOR INHERITANCE //

  public function init():Void {
    for (name in _children.keys()) {
      for (child in getChildren(name)) {
        child.init();
      }
    }
  }

  public function draw():Void {
    for (name in _children.keys()) {
      for (child in getChildren(name)) {
        child.draw();
      }
    }
  }

  public function update(dt:Float):Void {
    for (name in _children.keys()) {
      for (child in getChildren(name)) {
        child.update(dt);
      }
    }
  }

  public function onEnable():Void {
    for (name in _children.keys()) {
      for (child in getChildren(name)) {
        child.onEnable();
      }
    }
  }

  public function onDisable():Void {
    for (name in _children.keys()) {
      for (child in getChildren(name)) {
        child.onDisable();
      }
    }
  }
}
