package recharge.midlife.base.graphics;

import recharge.midlife.base.sdf.SDF;
import recharge.midlife.base.graphics.Mesh.Vertex;
import recharge.midlife.base.sdf.SDF;
import recharge.midlife.base.graphics.Mesh;

// This mesh generation algorithm has unfortunately been AI generated.
// It is officially our best mesh generation algorithm for now because it knows
// how to be precise with what data it needs to generate smooth SDFs, but it
// unfortunately needs refactoring to be human readable and maintainable.
//
// If we can do so, we should be able to optimize this algorithm to use
// Octree sampling when possible. Otherwise, I hope that this algorithm gets
// refactored sooner than later.
// - Roberto Selles

/**
 * Represents a single face in the 2D mask for a given slice.
 * `exists` means there's a boundary here, `flipped` tracks winding order.
 */
typedef MaskCell = {exists:Bool, flipped:Bool, normal:Vec3};

/**
 * Creates a new mesh based on an SDF using surface nets that can be used for graphical rendering
 */
class SurfaceNetGreedy extends Mesh {
  private static inline var DEFAULT_NORMAL_ERROR_THRESHOLD:Float = 0.001;
  private var _normalErrorThreshold:Float;
  /**
   * Compares two normal vectors to determine if they are similar enough
   * @param n1 First normal vector
   * @param n2 Second normal vector
   * @return True if normals are within error threshold
   */
  inline function normalsSimilar(n1:Vec3, n2:Vec3):Bool {
    var dot = VectorMath.dot(n1, n2);
    return dot >= (1.0 - _normalErrorThreshold);
  }

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

  /**
   * Builds a 2D mask for a slice at position `d` along the given axis.
   * axis: 0=X, 1=Y, 2=Z
   */
  function buildMask(samples:haxe.ds.Vector<Bool>, res:Int, axis:Int,
      d:Int, sdf:SDF, topLeft:Vec3, dt:Vec3):Array<MaskCell> {
    var mask:Array<MaskCell> = [];
    for (i in 0...res * res)
      mask.push({exists: false, flipped: false, normal: vec3(0, 0, 1)});

    for (v in 0...res) {
      for (u in 0...res) {
        // Map (axis, d, u, v) -> 3D indices
        var ix0:Int, iy0:Int, iz0:Int;
        var ix1:Int, iy1:Int, iz1:Int;
        switch (axis) {
          case 0: // Slicing along X
            ix0 = d;
            iy0 = u;
            iz0 = v;
            ix1 = d + 1;
            iy1 = u;
            iz1 = v;
          case 1: // Slicing along Y
            ix0 = u;
            iy0 = d;
            iz0 = v;
            ix1 = u;
            iy1 = d - 1;
            iz1 = v;
          default: // Slicing along Z
            ix0 = u;
            iy0 = v;
            iz0 = d;
            ix1 = u;
            iy1 = v;
            iz1 = d + 1;
        }

        // Clamp to valid range
        if (ix0 < 0
          || ix1 >= res
          || iy0 < 0
          || iy1 >= res
          || iz0 < 0
          || iz1 >= res)
          continue;

        var a = samples[iz0 * res * res + iy0 * res + ix0];
        var b = samples[iz1 * res * res + iy1 * res + ix1];

        var idx = v * res + u;
        if (a && !b) {
          // Calculate position for normal
          var pos:Vec3 = topLeft + dt * vec3(ix0, iy0, iz0);
          var normal = sdf.getNormal(pos);
          mask[idx] = {exists: true, flipped: false, normal: normal};
        } else if (!a && b) {
          // Calculate position for normal
          var pos:Vec3 = topLeft + dt * vec3(ix1, iy1, iz1);
          var normal = sdf.getNormal(pos);
          mask[idx] = {exists: true, flipped: true, normal: normal};
        }
      }
    }
    return mask;
  }

  /**
   * Greedily merges the mask into the minimum set of rectangles,
   * calling createVoxelFace for each merged quad.
   * axis: 0=X, 1=Y, 2=Z  |  d: slice position along that axis
   */
  function greedyMerge(mask:Array<MaskCell>, res:Int, axis:Int, d:Int,
      topLeft:Vec3, dt:Vec3, sdf:SDF):Void {
    var v = 0;
    while (v < res) {
      var u = 0;
      while (u < res) {
        var cell = mask[v * res + u];
        if (!cell.exists) {
          u++;
          continue;
        }

        // --- Expand width (u direction) ---
        var w = 1;
        while (u + w < res) {
          var next = mask[v * res + (u + w)];
          if (!next.exists || next.flipped != cell.flipped)
            break;
          if (!normalsSimilar(cell.normal, next.normal))
            break;
          w++;
        }

        // --- Expand height (v direction) ---
        var h = 1;
        var canExpand = true;
        while (canExpand && v + h < res) {
          for (du in 0...w) {
            var c = mask[(v + h) * res + (u + du)];
            if (!c.exists || c.flipped != cell.flipped) {
              canExpand = false;
              break;
            }
            if (!normalsSimilar(cell.normal, c.normal)) {
              canExpand = false;
              break;
            }
          }
          if (canExpand)
            h++;
        }

        // --- Emit quad ---
        // Convert (axis, d, u, v, w, h) back to world-space corners
        var v0:Vec3, v1:Vec3, v2:Vec3, v3:Vec3;
        // `d` is the slice, `u`/`v` are the 2D coords, offset by dt per unit
        var du:Vec3, dv:Vec3, dn:Vec3;
        switch (axis) {
          case 0: // X-axis slice: u=Y, v=Z
            du = vec3(0, dt.y, 0);
            dv = vec3(0, 0, dt.z);
            dn = vec3(dt.x * (d + 1), 0, 0);
          case 1: // Y-axis slice: u=X, v=Z
            du = vec3(dt.x, 0, 0);
            dv = vec3(0, 0, dt.z);
            dn = vec3(0, dt.y * (d), 0);
          default: // Z-axis slice: u=X, v=Y
            du = vec3(dt.x, 0, 0);
            dv = vec3(0, dt.y, 0);
            dn = vec3(0, 0, dt.z * (d + 1));
        }

        var origin:Vec3 = topLeft + dn + du * vec3(u) + dv * vec3(v);
        v0 = origin;
        v1 = origin + du * vec3(w);
        v2 = origin + du * vec3(w) + dv * vec3(h);
        v3 = origin + dv * vec3(h);

        if (cell.flipped)
          createVoxelFace(v0, v1, v2, v3, sdf);
        else
          createVoxelFace(v0, v3, v2, v1, sdf);

        // --- Clear consumed cells ---
        for (dh in 0...h)
          for (dw in 0...w)
            mask[(v + dh) * res + (u + dw)] = {exists: false, flipped: false, normal: vec3(0, 0, 1)};

        u += w;
      }
      v++;
    }
  }

  public function new(sdf:SDF, ?res:Int, ?tl:Vec3, ?br:Vec3) {
    var topLeft = tl != null ? tl : sdf.getTopLeft();
    var totalDistance = (br != null ? br : sdf.getBottomRight()) - topLeft;
    res = res != null ? res : 16;
    _normalErrorThreshold = DEFAULT_NORMAL_ERROR_THRESHOLD;

    var dt:Vec3 = totalDistance / vec3(res);

    var sampleDistance = new haxe.ds.Vector<Bool>(res * res * res);

    // Sample Mesh
    var canWrite:Bool = true;
    for (z in 0...Std.int(res - 1)) {
      for (y in 0...Std.int(res - 1)) {
        for (x in 0...Std.int(res - 1)) {
          // sample corners
          var pos:Vec3 = topLeft + (totalDistance * vec3(x, y, z) / res);
          var posString:Int = Std.int(z * res * res + y * res + x);

          sampleDistance[posString] = sdf.computeDistance(pos) < 0.0;
        }
      }
    }

    // Dual Contouring-like Mesh Generation
    // Greedy Meshed Generation
    for (axis in 0...3) {
      for (d in 0...res - 1) {
        var mask = buildMask(sampleDistance, res, axis, d, sdf, topLeft, dt);
        greedyMerge(mask, res, axis, d, topLeft, dt, sdf);
      }
    }
  }
}
