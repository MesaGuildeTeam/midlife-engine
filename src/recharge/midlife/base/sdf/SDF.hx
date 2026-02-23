package recharge.midlife.base.sdf;

import recharge.midlife.base.Utils;

/**
 * A generic Signed Distance Field for computing basic shapes
 */
class SDFAbstract {
  var shapeType:SDFType = null;

  inline static var dt = 0.01;

  /**
   * Computes the distance before collision with an SDF
   * @param point the point to compute the SDF from
   * @return Float the distance from the SDF
   */
  public function computeDistance(point:Vec3):Float {
    return 0.0;
  }

  /**
   * Takes a point 
   */
  inline public function getClosestPoint(point:Vec3):Vec3 {
    var dist = computeDistance(point);
    var normal = getNormal(point);

    return point + normal * dist;
  }

  /**
   * Computes the normal vector of the SDF
   * 
   * If there is no pre-defined gradient function for the SDF type, the normal is approximated
   * @param point the position to compute the SDF at
   * @return Vec3 the normal vector computed
   */
  public function getNormal(point:Vec3):Vec3 {
    return normalize(vec3(computeDistance(point - vec3(dt, 0, 0))
      - computeDistance(point + vec3(dt, 0, 0)),
      computeDistance(point - vec3(0, dt, 0))
      - computeDistance(point + vec3(0, dt, 0)),
      computeDistance(point - vec3(0, 0, dt))
      - computeDistance(point + vec3(0, 0, dt)),));
  }

  public function getUV(point:Vec3):Vec2 {
    return vec2(0.0);
  }

  /**
   * Returns the bounding top left of the SDF
   * @return Vec3
   */
  public function getTopLeft():Vec3 {
    return vec3(0.0);
  }

  /**
   * Returns the bounding bottom right
   * @return Vec3
   */
  public function getBottomRight():Vec3 {
    return vec3(0.1);
  }
}

class SphereSDF extends SDFAbstract {
  var _pos:Vec3;
  var _radius:Float;

  public function new(diameter:Float, ?pos:Vec3) {
    _pos = pos != null ? pos : vec3(0, 0, 0);
    _radius = diameter / 2;
  }

  override public function getNormal(point:Vec3):Vec3 {
    return vec3(-(point - _pos) / length(point - _pos));
  }

  override public function getUV(point:Vec3):Vec2 {
    var angle:Float = Math.atan2(point.z, point.x);
    var normalAngle:Float = angle < 0 ? angle + 2 * Math.PI : angle;

    return vec2(-(Math.cos(normalAngle / (2 * _radius) + Math.PI / 2) - 1) / 2,
      -(Math.cos(Math.PI * point.y / (_radius * 2) + Math.PI / 2) - 1) / 2);
  }

  override public function computeDistance(point:Vec3) {
    return length(point - _pos) - _radius;
  }

  override public function getTopLeft():Vec3 {
    return _pos - vec3(_radius + 0.5);
  }

  override public function getBottomRight():Vec3 {
    return _pos + vec3(_radius + 0.5);
  }
}

class SDFUnion extends SDFAbstract {
  var _group:Array<SDF>;

  public function new(group:Array<SDF>) {
    _group = group;
  }

  override public function computeDistance(point:Vec3) {
    var currentMin:Float = 9999;
    for (i in _group) {
      currentMin = Math.min(currentMin, i.computeDistance(point));
    }

    return currentMin;
  }

  override public function getTopLeft() {
    var tl = vec3(0);

    for (i in _group) {
      var testTL = i.getTopLeft();
      tl.x = Math.min(tl.x, testTL.x);
      tl.y = Math.min(tl.y, testTL.y);
      tl.z = Math.min(tl.z, testTL.z);
    }

    return tl;
  }

  override public function getBottomRight() {
    var tl = vec3(0);

    for (i in _group) {
      var testTL = i.getBottomRight();
      tl.x = Math.max(tl.x, testTL.x);
      tl.y = Math.max(tl.y, testTL.y);
      tl.z = Math.max(tl.z, testTL.z);
    }

    return tl;
  }
}

class SDFSubtraction extends SDFAbstract {
  var _A:SDF;
  var _B:SDF;

  public function new(group:Array<SDF>) {
    _A = group[0];
    _B = group[1];
  }

  override public function computeDistance(point:Vec3) {
    return Math.max(_A.computeDistance(point), -_B.computeDistance(point));
  }

  override public function getUV(point:Vec3):Vec2 {
    return _A.getUV(point);
  }

  override public function getTopLeft():Vec3 {
    return _A.getTopLeft();
  }

  override public function getBottomRight():Vec3 {
    return _A.getBottomRight();
  }
}

class SDFIntersection extends SDFAbstract {
  var _A:SDF;
  var _B:SDF;

  public function new(group:Array<SDF>) {
    _A = group[0];
    _B = group[1];
  }

  override public function computeDistance(point:Vec3):Float {
    return Math.max(_A.computeDistance(point), _B.computeDistance(point));
  }

  override public function getUV(point:Vec3):Vec2 {
    return _A.getUV(point);
  }

  override public function getTopLeft():Vec3 {
    var tl = vec3(0);

    tl.x = Math.min(_A.getTopLeft().x, _B.getTopLeft().x);
    tl.y = Math.min(_A.getTopLeft().y, _B.getTopLeft().y);
    tl.z = Math.min(_A.getTopLeft().z, _B.getTopLeft().z);

    return tl;
  }

  override public function getBottomRight():Vec3 {
    var tl = vec3(0);

    tl.x = Math.min(_A.getBottomRight().x, _B.getBottomRight().x);
    tl.y = Math.min(_A.getBottomRight().y, _B.getBottomRight().y);
    tl.z = Math.min(_A.getBottomRight().z, _B.getBottomRight().z);

    return tl;
  }
}

/**
 * Takes an existing SDF, and translates it to a new position using a matrix generated by the class
 */
class SDFTransform extends SDFAbstract {
  var _shape:SDF;
  var _transform:Mat4;

  public function new(shape:SDFAbstract, ?offset:Vec3, ?scale:Vec3,
      ?rotation:Vec3) {
    _shape = shape;

    offset = offset != null ? offset : vec3(0);
    scale = scale != null ? scale : vec3(1);
    rotation = rotation != null ? rotation : vec3(0);

    _transform = Utils.genTransformMatrix(offset, scale, rotation);
  }

  override public function computeDistance(point:Vec3):Float {
    var newPoint:Vec4 = _transform.inverse() * vec4(point, 1.0);
    return _shape.computeDistance(newPoint.xyz);
  }

  // override public function getNormal(point:Vec3) {
  //   var newPoint:Vec4 = _transform.inverse() * vec4(point, 1.0);
  //   return _shape.getNormal(newPoint.xyz);
  // }

  override public function getTopLeft():Vec3 {
    var baseTL = _shape.getTopLeft();
    var newTL:Vec4 = _transform * vec4(baseTL, 1.0);

    return newTL.xyz;
  }

  override public function getBottomRight():Vec3 {
    var baseBR = _shape.getBottomRight();
    var newBR:Vec4 = _transform * vec4(baseBR, 1.0);

    return newBR.xyz;
  }
}

typedef SDF = SDFAbstract;
