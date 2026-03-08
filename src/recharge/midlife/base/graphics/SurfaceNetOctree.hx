package recharge.midlife.base.graphics;

import VectorMath.log2;

import recharge.midlife.base.sdf.SDF;
import recharge.midlife.base.graphics.Mesh.Vertex;
import recharge.midlife.base.sdf.SDF;
import recharge.midlife.base.graphics.Mesh;

/**
 * A collection of samples organized in a Sparse Octree
 */
class SDFOctree {
  public var value:Bool;

  var _children:Array<SDFOctree>;

  public var topLeft:Vec3;
  public var bottomRight:Vec3;

  public function hasChildren():Bool {
    return _children != null;
  }

  public function traverse(callback:SDFOctree->Void):Void {
    // callback(this);
    // if (_children == null)
    //   return;
    // for (child in _children)
    //   child.traverse(callback);
    if (_children == null) {
      callback(this);
    } else {
      for (child in _children)
        child.traverse(callback);
    }
  }

  public function sample(point:Vec3):Bool {
    if (point.x < topLeft.x || point.x > bottomRight.x
      || point.y < topLeft.y || point.y > bottomRight.y
      || point.z < topLeft.z || point.z > bottomRight.z)
      return true;

    if (_children == null)
      return value;

    // var center = (topLeft + bottomRight) / 2;
    // var xi = point.x >= center.x ? 1 : 0;
    // var yi = point.y >= center.y ? 1 : 0;
    // var zi = point.z >= center.z ? 1 : 0;
    // return _children[zi * 4 + yi * 2 + xi].sample(point);
    for (child in _children)
      if (!child.sample(point))
        return false;

    return true;
  }

  public function new(sdf:SDF, layers:Int, ?tl:Vec3, ?br:Vec3) {
    topLeft = tl != null ? tl : sdf.getTopLeft();
    bottomRight = br != null ? br : sdf.getBottomRight();

    var center = (topLeft + bottomRight) / 2;
    var sample = sdf.computeDistance(center);
    var closestSurface = sdf.getClosestPoint(center);

    value = sample <= 0;

    if (layers <= 0)
      return;
    if (closestSurface.x < topLeft.x || closestSurface.x > bottomRight.x)
      return;
    if (closestSurface.y < topLeft.y || closestSurface.y > bottomRight.y)
      return;
    if (closestSurface.z < topLeft.z || closestSurface.z > bottomRight.z)
      return;

    _children = new Array<SDFOctree>();
    var shouldCollapse:Bool = true;
    // Subdivide into 8 children by splitting at the center point.
    // Each child gets one of the 8 octants formed by the three axis-aligned splits.
    for (zi in 0...2) {
      for (yi in 0...2) {
        for (xi in 0...2) {
          var childTL = new Vec3(xi == 0 ? topLeft.x : center.x,
            yi == 0 ? topLeft.y : center.y, zi == 0 ? topLeft.z : center.z);
          var childBR = new Vec3(xi == 0 ? center.x : bottomRight.x,
            yi == 0 ? center.y : bottomRight.y,
            zi == 0 ? center.z : bottomRight.z);

          var newOctree = new SDFOctree(sdf, layers - 1, childTL, childBR);
          _children.push(newOctree);

          if (newOctree.hasChildren() || newOctree.value != value)
            shouldCollapse = false;
        }
      }
    }

    if (shouldCollapse == true)
      _children = null;
  }
}

/**
 * Creates a new mesh based on an SDF using surface nets that can be used for graphical rendering
 */
class SurfaceNetOctree extends Mesh {
  /**
   * Takes the 4 corners of a voxel face and creates a quad for the mesh based on the SDF
   *
   * Each vertex is projected onto the surface of the SDF and given a normal and UV coordinate based on the SDF
   *
   * @param v1
   * @param v2
   * @param v3
   * @param v4
   * @param sdf
   */
  inline function createVoxelFace(v1:Vec3, v2:Vec3, v3:Vec3, v4:Vec3,
      sdf:SDF):Void {
    // Only for testing so we can see the actual voxels instead of the projected
    // vertices on the surface of the SDF
    #if test_voxels
    addQuad(new Vertex(v1, sdf.getUV(v1)), new Vertex(v2, sdf.getUV(v2)),
      new Vertex(v3, sdf.getUV(v3)), new Vertex(v4, sdf.getUV(v4)));
    #else
    var iv1:Vec3 = sdf.getClosestPoint(v1);
    var iv2:Vec3 = sdf.getClosestPoint(v2);
    var iv3:Vec3 = sdf.getClosestPoint(v3);
    var iv4:Vec3 = sdf.getClosestPoint(v4);

    addQuad(new Vertex(iv1, sdf.getUV(iv1), sdf.getNormal(iv1)),
      new Vertex(iv2, sdf.getUV(iv2), sdf.getNormal(iv2)),
      new Vertex(iv3, sdf.getUV(iv3), sdf.getNormal(iv3)),
      new Vertex(iv4, sdf.getUV(iv4), sdf.getNormal(iv4)));
    #end
  }

  inline function childIndex(x:Int, y:Int, z:Int) {
    return x + 2 * y + z * 4;
  }

  public function new(sdf:SDF, ?res:Float, ?tl:Vec3, ?br:Vec3) {
    res = res != null ? Math.log(res) / Math.log(2) : 3;

    var samples:SDFOctree = new SDFOctree(sdf, Std.int(res), tl, br);

    samples.traverse((cell:SDFOctree) -> {
      if (!cell.value || cell.hasChildren())
        return;

      // For each of the 6 face directions, check the neighbour within
      // this sibling group if it exists, otherwise fall back to the
      // node's own value as a boundary sentinel
      var tl = cell.topLeft;
      var br = cell.bottomRight;
      var center = (tl + br) / 2;
      var size = (br - tl) / 2;

      var frontVal = samples.sample(new Vec3(center.x, center.y,
        tl.z - size.z));
      var backVal = samples.sample(new Vec3(center.x, center.y, br.z + size.z));
      var leftVal = samples.sample(new Vec3(br.x + size.x, center.y, center.z));
      var rightVal = samples.sample(new Vec3(tl.x - size.x, center.y,
        center.z));
      var topVal = samples.sample(new Vec3(center.x, br.y + size.y, center.z));
      var bottomVal = samples.sample(new Vec3(center.x, tl.y - size.y,
        center.z));

      // -Z face (front): neighbour is zi-1
      if (!frontVal)
        createVoxelFace(vec3(tl.x, tl.y, tl.z), vec3(br.x, tl.y, tl.z),
          vec3(br.x, br.y, tl.z), vec3(tl.x, br.y, tl.z), sdf);

      // +Z face (back): neighbour is zi+1
      if (!backVal)
        createVoxelFace(vec3(br.x, tl.y, br.z), vec3(tl.x, tl.y, br.z),
          vec3(tl.x, br.y, br.z), vec3(br.x, br.y, br.z), sdf);

      // -X face (right): neighbour is xi-1
      if (!rightVal)
        createVoxelFace(vec3(tl.x, tl.y, tl.z), vec3(tl.x, br.y, tl.z),
          vec3(tl.x, br.y, br.z), vec3(tl.x, tl.y, br.z), sdf);

      // +X face (left): neighbour is xi+1
      if (!leftVal)
        createVoxelFace(vec3(br.x, br.y, tl.z), vec3(br.x, tl.y, tl.z),
          vec3(br.x, tl.y, br.z), vec3(br.x, br.y, br.z), sdf);

      // +Y face (top): neighbour is yi+1
      if (!topVal)
        createVoxelFace(vec3(tl.x, br.y, tl.z), vec3(br.x, br.y, tl.z),
          vec3(br.x, br.y, br.z), vec3(tl.x, br.y, br.z), sdf);

      // -Y face (bottom): neighbour is yi-1
      if (!bottomVal)
        createVoxelFace(vec3(tl.x, tl.y, tl.z), vec3(tl.x, tl.y, br.z),
          vec3(br.x, tl.y, br.z), vec3(br.x, tl.y, tl.z), sdf);
    });
  }
}
