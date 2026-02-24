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
 * Creates a new mesh based on an SDF using surface nets that can be used for graphical rendering
 */
class SurfaceNet extends Mesh {
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
    addQuad(new Vertex(v1, sdf.getUV(v1)),
      new Vertex(v2, sdf.getUV(v2)),
      new Vertex(v3, sdf.getUV(v3)),
      new Vertex(v4, sdf.getUV(v4)));
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

  public function new(sdf:SDF, ?res:Float) {
    var topLeft = sdf.getTopLeft();
    var totalDistance = sdf.getBottomRight() - topLeft;
    res = res != null ? res : 12;

    var dt:Vec3 = totalDistance / vec3(res);

    var sampleDistance:Map<String, Bool> = new Map();
    var sampleNormals:Map<String, Vec3> = new Map();

    // Sample Mesh
    for (z in 0...Std.int(res - 1)) {
      for (y in 0...Std.int(res - 1)) {
        for (x in 0...Std.int(res - 1)) {
          // sample corners
          var pos:Vec3 = topLeft + (totalDistance * vec3(x, y, z) / res);
          var posString:String = '${pos.x},${pos.y},${pos.z}';
          sampleDistance.set(posString, sdf.computeDistance(pos) < 0.0);
          var n_bfl = sdf.getNormal(pos);
        }
      }
    }

    // Dual Contouring-like Mesh Generation
    for (z in 0...Std.int(res - 1)) {
      for (y in 0...Std.int(res - 1)) {
        for (x in 0...Std.int(res - 1)) {
          var pos:Vec3 = topLeft + (totalDistance * vec3(x, y, z) / res);
          var front = pos + totalDistance * vec3(0, 0, -1) / res;
          var back = pos + totalDistance * vec3(0, 0, 1) / res;
          var left = pos + totalDistance * vec3(1, 0, 0) / res;
          var right = pos + totalDistance * vec3(-1, 0, 0) / res;
          var top = pos + totalDistance * vec3(0, 1, 0) / res;
          var bottom = pos + totalDistance * vec3(0, -1, 0) / res;

          if (sampleDistance.get('${pos.x},${pos.y},${pos.z}') == true
            && sampleDistance.get('${front.x},${front.y},${front.z}') == false) {
            createVoxelFace(pos
              + dt * vec3(-0.5, -0.5, -0.5),
              pos
              + dt * vec3(0.5, -0.5, -0.5),
              pos
              + dt * vec3(0.5, 0.5, -0.5),
              pos
              + dt * vec3(-0.5, 0.5, -0.5), sdf);
          }

          if (sampleDistance.get('${pos.x},${pos.y},${pos.z}') == true
            && sampleDistance.get('${back.x},${back.y},${back.z}') == false) {
            createVoxelFace(pos
              + dt * vec3(0.5, -0.5, 0.5),
              pos
              + dt * vec3(-0.5, -0.5, 0.5),
              pos
              + dt * vec3(-0.5, 0.5, 0.5), pos
              + dt * vec3(0.5, 0.5, 0.5),
              sdf);
          }

          if (sampleDistance.get('${pos.x},${pos.y},${pos.z}') == true
            && sampleDistance.get('${right.x},${right.y},${right.z}') == false) {
            createVoxelFace(pos
              + dt * vec3(-0.5, -0.5, -0.5),
              pos
              + dt * vec3(-0.5, 0.5, -0.5),
              pos
              + dt * vec3(-0.5, 0.5, 0.5),
              pos
              + dt * vec3(-0.5, -0.5, 0.5), sdf);
          }

          if (sampleDistance.get('${pos.x},${pos.y},${pos.z}') == true
            && sampleDistance.get('${left.x},${left.y},${left.z}') == false) {
            createVoxelFace(pos
              + dt * vec3(0.5, 0.5, -0.5),
              pos
              + dt * vec3(0.5, -0.5, -0.5),
              pos
              + dt * vec3(0.5, -0.5, 0.5), pos
              + dt * vec3(0.5, 0.5, 0.5),
              sdf);
          }

          if (sampleDistance.get('${pos.x},${pos.y},${pos.z}') == true
            && sampleDistance.get('${top.x},${top.y},${top.z}') == false) {
            createVoxelFace(pos
              + dt * vec3(-0.5, 0.5, -0.5),
              pos
              + dt * vec3(0.5, 0.5, -0.5), pos
              + dt * vec3(0.5, 0.5, 0.5),
              pos
              + dt * vec3(-0.5, 0.5, 0.5), sdf);
          }

          if (sampleDistance.get('${pos.x},${pos.y},${pos.z}') == true
            && sampleDistance.get('${bottom.x},${bottom.y},${bottom.z}') == false) {
            createVoxelFace(pos
              + dt * vec3(-0.5, -0.5, -0.5),
              pos
              + dt * vec3(-0.5, -0.5, 0.5),
              pos
              + dt * vec3(0.5, -0.5, 0.5),
              pos
              + dt * vec3(0.5, -0.5, -0.5), sdf);
          }
        }
      }
    }
  }
}
