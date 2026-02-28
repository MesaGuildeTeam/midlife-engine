/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package recharge.midlife.base.graphics;

class Vertex {
  public var position:Vec3;
  public var uv:Vec2;
  public var normal:Vec3;

  public function new(pos:Vec3, uv:Vec2, ?norm:Vec3) {
    this.position = pos;
    this.uv = uv;

    // This shouldn't be needed but the coverage tool doesn't like the statement below
    // due to "access to null object"
    #if carpengine_testmode
    #else
    normal = norm == null ? vec3(0, 0, 0) : norm;
    #end
  }

  public function calculateNormals(v2:Vertex, v3:Vertex):Void {
    var p1 = position;
    var p2 = v2.position;
    var p3 = v3.position;

    normal = normalize(cross(p2 - p1, p3 - p1));

    v2.normal = normal;
    v3.normal = normal;
  }
}

/**
 * An abstract mesh class that holds vertices and indices for rendering.
 */
@:expose("midlife.graphics.Mesh")
class Mesh {
  var _vertices:Array<Vertex> = new Array();
  var _indices:Array<Int> = new Array();

  var _verticesFloat:Array<Float>;

  public function addPoint(point:Vertex):Int {
    if (_verticesFloat != null)
      _verticesFloat = null;

    // Find the vertex first if it exists
    if (_vertices.indexOf(point) != -1) {
      _indices.push(_vertices.indexOf(point));
      return _vertices.indexOf(point);
    }

    // otherwise add it
    _vertices.push(point);
    _indices.push(_vertices.length - 1);
    return _vertices.length - 1;
  }

  public function addTriangle(a:Vertex, b:Vertex, c:Vertex):Void {
    var v1 = a;
    var v2 = b;
    var v3 = c;

    if (length(v1.normal) == 0 || length(v2.normal) == 0
      || length(v3.normal) == 0)
      v1.calculateNormals(v3, v2);

    var i1 = addPoint(v1);
    var i2 = addPoint(v2);
    var i3 = addPoint(v3);
  }

  public function addQuad(a:Vertex, b:Vertex, c:Vertex, d:Vertex):Void {
    addTriangle(a, b, c);
    addTriangle(a, c, d);
  }

  public function getVertices():Array<Float> {
    if (_verticesFloat == null) {
      _verticesFloat = new Array();
      for (v in _vertices) {
        _verticesFloat.push(v.position.x);
        _verticesFloat.push(v.position.y);
        _verticesFloat.push(v.position.z);
        _verticesFloat.push(v.uv.x);
        _verticesFloat.push(v.uv.y);
        _verticesFloat.push(v.normal.x);
        _verticesFloat.push(v.normal.y);
        _verticesFloat.push(v.normal.z);
      }
    }

    return _verticesFloat;
  }

  public function getIndices():Array<Int> {
    return _indices;
  }
}
