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

  function checkCollision(a:GameObject, b:GameObject):Float {
    var shapeA = new SDFTransform(a.shape, a.position, a.scale, a.rotation);
    var shapeB = new SDFTransform(b.shape, b.position, b.scale, b.rotation);

    var intersection = new SDFIntersection([shapeA, shapeB]);
    var center = (intersection.getTopLeft()
      + intersection.getBottomRight()) / 2;

    var depth = intersection.computeDistance(center);
    return depth;
  }

  override public function update(dt:Float):Void {
    super.update(dt);

    var children = getChildren();
    for (i in 0...children.length) {
      if (!Std.isOfType(children[i], GameObject))
        continue;
      var childA:GameObject = cast(children[i], GameObject);

      for (j in i...children.length) {
        if (!Std.isOfType(children[j], GameObject))
          continue;
        if (i == j)
          continue;
        var childB:GameObject = cast(children[j], GameObject);

        // Perform Collision Check
        var depth:Float = checkCollision(childA, childB);
        if (depth > 0)
          continue;

        // Compute Collisions

        var elasticity:Float = 0.8;
        var prevVelA = childA.velocity;

        if (childA.isStatic) {
          childB.velocity = -elasticity * length(childB.velocity) * childA.shape.getNormal((childB.position
            - childA.position));
        } else if (childB.isStatic) {
          childA.velocity = -elasticity * length(childA.velocity) * childB.shape.getNormal((childA.position
            - childB.position));
        } else {
          childA.velocity = ((childA.mass - elasticity * childB.mass) * prevVelA
            + (1
              + elasticity) * childB.mass * childB.velocity) / (childA.mass
              + childB.mass);
          childB.velocity = ((childB.mass
            - elasticity * childA.mass) * childB.velocity
            + (1
              + elasticity) * childA.mass * prevVelA) / (childA.mass
              + childB.mass);

          childA.velocity = length(childA.velocity) * childB.shape.getNormal((childB.position
            - childA.position));
          childB.velocity = length(childB.velocity) * childB.shape.getNormal((childA.position
            - childB.position));
        }

        // Minor separation to avoid seeping through
        depth = -depth + 0.05;
        if (!childA.isStatic)
          childA.position -= childB.shape.getNormal((childA.position
            - childB.position)) * depth * childA.mass / (childA.mass
              + childB.mass);

        if (!childB.isStatic)
          childB.position -= childB.shape.getNormal((childB.position
            - childA.position)) * depth * childB.mass / (childA.mass
              + childB.mass);

        // Call collision callbacks if available
        childA.onCollision(childB);
        childB.onCollision(childA);
      }
    }
  }
}
