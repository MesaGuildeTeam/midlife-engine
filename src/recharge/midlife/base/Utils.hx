/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package recharge.midlife.base;

class Utils {
  public static function rotateVec2(vec:Vec2, angle:Float):Vec2 {
    throw("TODO: rotate");
  }

  public static function rotateVec3(vec:Vec3, angle:Vec3):Vec3 {
    throw("TODO: rotate");
  }

  public static inline function pointInRect(point:Vec2, topLeft:Vec2,
      bottomRight:Vec2):Bool {
    return point.x >= topLeft.x
      && point.x <= bottomRight.x
      && point.y >= topLeft.y
      && point.y <= bottomRight.y;
  }

  public static function genTransformMatrix(offset:Vec3, scale:Vec3,
      rotation:Vec3):Mat4 {
    var m = mat4(1.0);
    var t = mat4(1.0);
    var s = mat4(1.0);
    var rx = mat4(1.0);
    var ry = mat4(1.0);
    var rz = mat4(1.0);

    s[0][0] = scale.x;
    s[1][1] = scale.y;
    s[2][2] = scale.z;

    t[3][0] = offset.x;
    t[3][1] = offset.y;
    t[3][2] = offset.z;

    rx[1][1] = Math.cos(rotation.x / 180.0 * Math.PI);
    rx[2][2] = Math.cos(rotation.x / 180.0 * Math.PI);
    rx[1][2] = Math.sin(rotation.x / 180.0 * Math.PI);
    rx[2][1] = -Math.sin(rotation.x / 180.0 * Math.PI);

    ry[0][0] = Math.cos(rotation.y / 180.0 * Math.PI);
    ry[2][2] = Math.cos(rotation.y / 180.0 * Math.PI);
    ry[0][2] = -Math.sin(rotation.y / 180.0 * Math.PI);
    ry[2][0] = Math.sin(rotation.y / 180.0 * Math.PI);

    rz[0][0] = Math.cos(rotation.z / 180.0 * Math.PI);
    rz[1][1] = Math.cos(rotation.z / 180.0 * Math.PI);
    rz[0][1] = Math.sin(rotation.z / 180.0 * Math.PI);
    rz[1][0] = -Math.sin(rotation.z / 180.0 * Math.PI);

    m = t * (rz * ry * rx) * s;

    return m;
  }
}
