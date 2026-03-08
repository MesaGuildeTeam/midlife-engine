package recharge.midlife.base.graphics;

import recharge.midlife.base.sdf.SDF;
import recharge.midlife.base.graphics.Mesh.Vertex;
import recharge.midlife.base.sdf.SDF;
import recharge.midlife.base.graphics.Mesh;

// This mesh generation algorithm is very naive at the moment. Although the mesh
// is very precise in shape, the first optimization that should be taken is to
// find how to reduce the vertex count by merging adjacent faces together.
//
// The goal would be to replace the sampling step with an octree-based structure.
// This may potentially get more expensive to generate, but would allow for much
// more efficient meshes and would be necessary for larger SDFs.
//
// This is not a priority at the moment for the game prototype, but maps may get
// more expensive to render as the game grows, so this is something to keep in
// mind for the future.
// - Roberto Selles

/**
 * Represents a single face in the 2D mask for a given slice.
 * `exists` means there's a boundary here, `flipped` tracks winding order.
 */
typedef MaskCell = {exists:Bool, flipped:Bool};

/**
 * Creates a new mesh based on an SDF using surface nets that can be used for graphical rendering
 */
class SurfaceNetGreedy extends Mesh {
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
      d:Int):Array<MaskCell> {
    var mask:Array<MaskCell> = [];
    for (i in 0...res * res)
      mask.push({exists: false, flipped: false});

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
          mask[idx] = {exists: true, flipped: false};
        } else if (!a && b) {
          mask[idx] = {exists: true, flipped: true};
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
            mask[(v + dh) * res + (u + dw)] = {exists: false, flipped: false};

        u += w;
      }
      v++;
    }
  }

  public function new(sdf:SDF, ?res:Int, ?tl:Vec3, ?br:Vec3) {
    var topLeft = tl != null ? tl : sdf.getTopLeft();
    var totalDistance = (br != null ? br : sdf.getBottomRight()) - topLeft;
    res = res != null ? res : 16;

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
        var mask = buildMask(sampleDistance, res, axis, d);
        greedyMerge(mask, res, axis, d, topLeft, dt, sdf);
      }
    }
  }
}

typedef SurfaceNet = SurfaceNetGreedy;
