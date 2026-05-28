package recharge.midlife.base.physics;

import recharge.midlife.base.physics.GameObject;
import recharge.midlife.base.sdf.SDF;
import recharge.midlife.base.Node;

class World extends Node {
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
    var children = getChildren();
    for (child in children) {
      if (!Std.isOfType(child, GameObject))
        continue;
      var gameObject:GameObject = cast(child, GameObject);
      if (checkCollision(refObject, gameObject) < 0.0) {
        return gameObject;
      }
    }
    return null;
  }

  var _dtCounter:Float = 0;

  override public function update(dt:Float):Void {
    super.update(dt);

    _dtCounter += dt;
    static var _dtStep:Float = 0.016 / 2; // 60 FPS

    while (_dtCounter >= _dtStep) {
      _dtCounter -= _dtStep;
      iteratePhysics(_dtStep);
    }
  }

  function iteratePhysics(dt:Float):Void {
    var gameObjects:Array<GameObject> = [];

    for (child in getChildren()) {
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
