/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package recharge.midlife.base;

/**
  A static class that allows for the creation of Nodes via string names.

  The intended use of this is to call `NodeFactory.register(MyNode)` in the
  derived Node class and then call `NodeFactory.create("MyNode", "My Node")`
  to create a new instance of the Node.

  ```haxe
  class MyNode extends Node {
    static var registry = NodeFactory.register(MyNode);
    public function new(name:String) {
        super(name);
    }
  }
  ```

  @see `Node`
**/
class NodeFactory {
  static var registry:Map<String, Class<Node>> = new Map();

  /**
    Creates a new Node of the type specified by the string named after another string.

    when you create a new node, you must specify the whole path to the class.
    This includes the package name. For example, if you have a class called
    `MyNode` in the package `my.package.name`, you would call
    `NodeFactory.create("my.package.name.MyNode", "My Node")`.

    @param type The type of Node to create.
    @param name The name of the Node to create.
    @return The newly created Node.

    @throws String If no Node type is registered with the specified name
  **/
  public static function create(type:String, name:String,
      ?params:Dynamic):Dynamic {
    if (registry == null)
      throw("NodeFactory: No node types registered");
    if (!registry.exists(type))
      throw("NodeFactory: Node type not found: " + type);

    var newObject = Type.createInstance(registry[type], [name, params]);
    return newObject;
  }

  /**
    Registers a new Node type.

    Ideally, you would not call this function directly. Instead, you should
    derive the Node class and assign `reister` to this function.
        
    ```haxe
    class MyNode extends Node {
      @:keep
      static var registry = NodeFactory.register(MyNode);
      public function new(name:String) {
          super(name);
      }
    }
    ```

    @param nodeClass The class of the Node to register.
    @return True if the registration was successful.
  **/
  public static function register(nodeClass:Class<Node>):Bool {
    trace("DEBUG: NodeFactory registering " + Type.getClassName(nodeClass));
    var name = Type.getClassName(nodeClass);

    if (registry.exists(name)) {
      throw("DEBUG: NodeFactory Node class already registered: " + name);
      return false;
    }
    registry[name] = nodeClass;
    return true;
  }
}
