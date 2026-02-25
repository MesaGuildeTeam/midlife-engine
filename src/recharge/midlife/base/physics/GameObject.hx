package recharge.midlife.base.physics;

import recharge.midlife.base.Node;
import recharge.midlife.base.sdf.SDF;

class GameObject extends Node {
  @:keep
  static var registry = recharge.midlife.base.NodeFactory.register(GameObject);

  public var mass:Float;
  public var position:Vec3;
  public var rotation:Vec3;
  public var scale:Vec3;

  public var velocity:Vec3;
  public var acceleration:Vec3;

  public var isStatic:Bool;
  public var shape:SDF;

  var _dtCounter:Float = 0;
  static var _dtStep:Float = 0.016; // 60 FPS

  public function new(name:String = "GameObject", ?params:Dynamic) {
    super(name, params);

    mass = 10.0;
    position = new Vec3(0, 0, 0);
    rotation = new Vec3(0, 0, 0);
    scale = new Vec3(1, 1, 1);

    velocity = new Vec3(0, 0, 0);
    acceleration = new Vec3(0, 0, 0);
    isStatic = false;

    if (params != null) {
      if (params.mass != null)
        mass = params.mass;
      if (params.position != null)
        position = params.position;
      if (params.rotation != null)
        rotation = params.rotation;
      if (params.scale != null)
        scale = params.scale;
      if (params.isStatic != null)
        isStatic = params.isStatic;
    }
  }

  public function onCollision(obj:GameObject, ?preComputeNewVel:Bool):Void {}

  override public function init() {
    if (parent == null || !(parent is World))
      throw("GameObject must be added to a World node to be able to simulate physics.");

    super.init();
  }

  override public function update(dt:Float):Void {
    super.update(dt);

    _dtCounter += dt;

    while (_dtCounter >= _dtStep) {
      _dtCounter -= _dtStep;

      if (isStatic)
        return;

      var parentAsWorld:World = cast(parent, World);
      var accSum = acceleration + parentAsWorld.gravity;
      position += velocity * _dtStep + accSum * _dtStep * _dtStep / 2;
      velocity += accSum * _dtStep;
    }
  }
}
