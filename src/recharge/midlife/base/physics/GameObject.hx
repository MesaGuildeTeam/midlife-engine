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

  public var _velocity:Vec3;
  public var _acceleration:Vec3;

  static inline var eps = 0.03;

  public var velocity(get, set):Vec3;
  public var acceleration(get, set):Vec3;

  public function get_velocity():Vec3 {
    return _velocity;
  }

  public function set_velocity(v:Vec3):Vec3 {
    _velocity = v;

    if (length(v) > 9.81)
      isResting = false;

    return _velocity;
  }

  public function get_acceleration():Vec3 {
    return _acceleration;
  }

  public function set_acceleration(a:Vec3):Vec3 {
    _acceleration = a;

    return _acceleration;
  }

  public var isStatic:Bool;

  public var isResting:Bool = false;

  var _restingCounter:Float = 0;

  public var shape:SDF;

  var _dtCounter:Float = 0;
  var _physicsReady:Bool = false;

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
    super.init();

    if (parent == null || !(parent is World))
      return
        trace("GameObject must be added to a World node to be able to simulate physics.");

    _physicsReady = true;
  }

  public override function get_transform():Mat4 {
    var thisMat = Utils.genTransformMatrix(position, scale, rotation);

    if (parent != null)
      return parent.get_transform() * thisMat;

    return thisMat;
  }

  override public function update(dt:Float):Void {
    super.update(dt);

    if (!_physicsReady)
      return;

    if (isStatic)
      return;

    _dtCounter += dt;

    if (_dtCounter <= _dtStep)
      return;

    _dtCounter = 0;

    var prevPos = position;

    var parentAsWorld:World = cast(parent, World);
    var accSum = acceleration + parentAsWorld.gravity;
    if (isResting) {
      velocity = vec3(0);
      acceleration = vec3(0);
      return;
    }

    position += velocity * _dtStep + accSum * _dtStep * _dtStep / 2;
    velocity += accSum * _dtStep;

    if (length(position - prevPos) > eps) {
      _restingCounter = 0;
      isResting = false;
    } else {
      _restingCounter++;
      isResting = _restingCounter > 120;
    }
  }
}
