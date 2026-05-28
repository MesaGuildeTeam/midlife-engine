package recharge.midlife.base.physics;

import recharge.midlife.base.physics.GameObject;
import recharge.midlife.base.sdf.SDF;
import recharge.midlife.base.Node;

class World extends HashedNode {
  @:keep
  static var registry = recharge.midlife.base.NodeFactory.register(World);

  public var gravity:Vec3;

  public function new(name:String = "World", ?params:Dynamic) {
    super(name, params);

    gravity = new Vec3(0, 0, 0);

    if (params != null) {
      if (params.gravity != null)
        gravity = params.gravity;
    }
  }

  public static function checkCollision(a:GameObject, b:GameObject):Float {
    var shapeA = new SDFTransform(a.shape, a.position, a.scale, a.rotation);
    var shapeB = new SDFTransform(b.shape, b.position, b.scale, b.rotation);

    var intersection = new SDFIntersection([shapeA, shapeB]);
    var center = (intersection.getTopLeft()
      + intersection.getBottomRight()) / 2;

    var surface = intersection.getClosestPoint(center);
    var depth = intersection.computeDistance(surface);
    return depth;
  }

  /**
   * Checks if there is an object at the given position.
   *
   * @param position The position to check.
   * @return The object at the position, or null if no object is found.
   */
  public function hasObjectAt(refObject:GameObject):GameObject {
    var hashes:Array<String> = _hashFunction(refObject);
    for (k in hashes) {
      var list:Array<Node> = getChildrenHash(k);
      if (list == null)
        continue;
      //trace(list, k);
      for (child in list) {
        if (!Std.isOfType(child, GameObject))
          continue;
        var go:GameObject = cast(child, GameObject);
        if (checkCollision(refObject, go) < 0.0)
          return go;
      }
    }
    return null;
  }

  var _dtCounter:Float = 0;

  override public function update(dt:Float):Void {
    super.update(dt);

    _dtCounter += dt;
    static var _dtStep:Float = 0.016 / 2; // 60 FPS
    var counter:Int = 4;

    #if sys
    static var threadLock:Bool = false;
    if (threadLock) return;

    sys.thread.Thread.create(() -> {
      threadLock = true;
    #end

    try {
    // This should run no more than 4 times max 240FPS
    while (_dtCounter >= _dtStep && counter > 0) {
      counter--;
      _dtCounter -= _dtStep;
      for (keys in getHashKeys())
        if (getChildrenHash(keys).length != 0)
          iteratePhysics(_dtStep, getChildrenHash(keys));
    }

    } catch(e) {
      trace(e.message);
    }

    #if sys
      threadLock = false;
    });
    #end
  }

  function iteratePhysics(dt:Float, children:Array<Node>):Void {
    var gameObjects:Array<GameObject> = [];

    for (child in children) {
      if (!Std.isOfType(child, GameObject))
        continue;
      gameObjects.push(cast(child, GameObject));
    }

    for (i in 0...gameObjects.length) {
      var childA:GameObject = gameObjects[i];

      var hasCollided:Bool = false;

      for (j in i...gameObjects.length) {
        if (i == j)
          continue;
        var childB:GameObject = gameObjects[j];

        // Perform Collision Check
        // TODO: Refactor this to use CCD instead of this discrete check
        var depth:Float = checkCollision(childA, childB);
        if (depth > 0)
          continue;

        hasCollided = true;

        // Compute Collisions
        var elasticity:Float = 0.8;
        computeNewVelocity(childA, childB, elasticity);

        // Call collision callbacks if available
        childA.onCollision(childB);
        childB.onCollision(childA);
      }

      if (!childA.isStatic)
        childA.computeKinematics(dt, hasCollided);
    }
  }

  /**
   * Computes the new velocity of two colliding objects after a collision.
   * @param childA The first object involved in the collision.
   * @param childB The second object involved in the collision.
   * @param elasticity The coefficient of restitution (bounciness) for the collision.
   * @param lookahead Whether this is a lookahead calculation (for visualization). In that case, only iterate childA.
   */
  public static function computeNewVelocity(childA:GameObject,
      childB:GameObject, elasticity:Float, lookahead:Bool = false):Void {
    var prevVelA = childA.velocity;

    var normalA = childA.shape.getNormal(childA.shape.getClosestPoint(childB.position
      - childA.position));
    var normalB = childB.shape.getNormal(childA.shape.getClosestPoint(childA.position
      - childB.position));
    if (childA.isStatic) {
      if (!lookahead)
        childB.velocity -= (1
          + elasticity) * dot(childB.velocity, normalA) * normalA;
    } else if (childB.isStatic) {
      childA.velocity -= (1
        + elasticity) * dot(childA.velocity, normalB) * normalB;
    } else {
      childA.velocity = ((childA.mass - elasticity * childB.mass) * prevVelA
        + (1
          + elasticity) * childB.mass * childB.velocity) / (childA.mass
          + childB.mass);
      if (!lookahead)
        childB.velocity = ((childB.mass
          - elasticity * childA.mass) * childB.velocity
          + (1
            + elasticity) * childA.mass * prevVelA) / (childA.mass +
            childB.mass);

      childA.velocity = length(childA.velocity) * -normalA;

      if (!lookahead)
        childB.velocity = length(childB.velocity) * -normalB;
    }

    // Minor separation to avoid seeping through
    var depth = checkCollision(childA, childB);
    depth = -depth + 0.01;
    if (!childA.isStatic)
      childA.position += normalB * depth * childA.mass / (childA.mass
        + childB.mass);

    if (!childB.isStatic && !lookahead)
      childB.position += normalA * depth * childB.mass / (childA.mass
        + childB.mass);
  }
}
