package recharge.midlife.base.graphics;

import recharge.midlife.base.graphics.Mesh.Vertex;
import recharge.midlife.base.sdf.SDF;
import recharge.midlife.base.graphics.Mesh;

/**
 * Takes an SDF and creates a mesh to be rendered in game
 */
class MarchingCubeMesh extends Mesh {
  public function new(sdf:SDF, ?res:Vec3) {
    var topLeft = sdf.getTopLeft();
    var totalDistance = sdf.getBottomRight() - topLeft;
    res = res != null ? res : vec3(32);

    var dt:Vec3 = totalDistance / res;

    var sampleDistance:Map<String, Bool> = new Map();
    var sampleNormals:Map<String, Vec3> = new Map();

    // Sample Mesh
    for (z in 0...Std.int(res.x - 1)) {
      for (y in 0...Std.int(res.y - 1)) {
        for (x in 0...Std.int(res.z - 1)) {
          // sample corners
          var pos:Vec3 = topLeft + (totalDistance * vec3(x, y, z) / res);
          var posString:String = '${pos.x},${pos.y},${pos.z}';
          sampleDistance.set(posString, sdf.computeDistance(pos) < 0.0);
          var n_bfl = sdf.getNormal(pos);
        }
      }
    }

    // Dual Contouring Mesh Generation
    for (z in 0...Std.int(res.x - 1)) {
      for (y in 0...Std.int(res.y - 1)) {
        for (x in 0...Std.int(res.z - 1)) {
          var pos:Vec3 = topLeft + (totalDistance * vec3(x, y, z) / res);
          var front = pos + totalDistance * vec3(0, 0, -1) / res;
          var back = pos + totalDistance * vec3(0, 0, 1) / res;
          var left = pos + totalDistance * vec3(1, 0, 0) / res;
          var right = pos + totalDistance * vec3(-1, 0, 0) / res;
          var top = pos + totalDistance * vec3(0, 1, 0) / res;
          var bottom = pos + totalDistance * vec3(0, -1, 0) / res;

          if (sampleDistance.get('${pos.x},${pos.y},${pos.z}') == true
            && sampleDistance.get('${front.x},${front.y},${front.z}') == false) {
            addQuad(new Vertex(pos + dt * vec3(-0.5),
              sdf.getUV(pos + dt * vec3(-0.5)),
              sdf.getNormal(pos + dt * vec3(-0.5))),
              new Vertex(pos + dt * vec3(0.5, -0.5, -0.5),
                sdf.getUV(pos + dt * vec3(0.5, -0.5, -0.5)),
                sdf.getNormal(pos + dt * vec3(0.5, -0.5, -0.5))),
              new Vertex(pos + dt * vec3(0.5, 0.5, -0.5),
                sdf.getUV(pos + dt * vec3(0.5, 0.5, -0.5)),
                sdf.getNormal(pos + dt * vec3(0.5, 0.5, -0.5))),
              new Vertex(pos + dt * vec3(-0.5, 0.5, -0.5),
                sdf.getUV(pos + dt * vec3(-0.5, 0.5, -0.5)),
                sdf.getNormal(pos + dt * vec3(-0.5, 0.5, -0.5))));
          }

          if (sampleDistance.get('${pos.x},${pos.y},${pos.z}') == true
            && sampleDistance.get('${back.x},${back.y},${back.z}') == false) {
            addQuad(new Vertex(pos + dt * vec3(0.5, -0.5, 0.5),
              sdf.getUV(pos + dt * vec3(0.5, -0.5, 0.5)),
              sdf.getNormal(pos + dt * vec3(0.5, -0.5, 0.5))),
              new Vertex(pos + dt * vec3(-0.5, -0.5, 0.5),
                sdf.getUV(pos + dt * vec3(-0.5, -0.5, 0.5)),
                sdf.getNormal(pos + dt * vec3(-0.5, -0.5, 0.5))),
              new Vertex(pos + dt * vec3(-0.5, 0.5, 0.5),
                sdf.getUV(pos + dt * vec3(-0.5, 0.5, 0.5)),
                sdf.getNormal(pos + dt * vec3(-0.5, 0.5, 0.5))),
              new Vertex(pos + dt * vec3(0.5, 0.5, 0.5),
                sdf.getUV(pos + dt * vec3(0.5, 0.5, 0.5)),
                sdf.getNormal(pos + dt * vec3(0.5, 0.5, 0.5))));
          }

          if (sampleDistance.get('${pos.x},${pos.y},${pos.z}') == true
            && sampleDistance.get('${right.x},${right.y},${right.z}') == false) {
            addQuad(new Vertex(pos + dt * vec3(-0.5, -0.5, -0.5),
              sdf.getUV(pos + dt * vec3(-0.5)),
              sdf.getNormal(pos + dt * vec3(-0.5, -0.5, -0.5))),
              new Vertex(pos + dt * vec3(-0.5, 0.5, -0.5),
                sdf.getUV(pos + dt * vec3(-0.5, 0.5, -0.5)),
                sdf.getNormal(pos + dt * vec3(-0.5, 0.5, -0.5))),
              new Vertex(pos + dt * vec3(-0.5, 0.5, 0.5),
                sdf.getUV(pos + dt * vec3(-0.5, 0.5, 0.5)),
                sdf.getNormal(pos + dt * vec3(-0.5, 0.5, 0.5))),
              new Vertex(pos + dt * vec3(-0.5, -0.5, 0.5),
                sdf.getUV(pos + dt * vec3(-0.5, -0.5, 0.5)),
                sdf.getNormal(pos + dt * vec3(-0.5, -0.5, 0.5))));
          }

          if (sampleDistance.get('${pos.x},${pos.y},${pos.z}') == true
            && sampleDistance.get('${left.x},${left.y},${left.z}') == false) {
            addQuad(new Vertex(pos + dt * vec3(0.5, 0.5, -0.5),
              sdf.getUV(pos + dt * vec3(0.5, 0.5, -0.5)),
              sdf.getNormal(pos + dt * vec3(0.5, 0.5, -0.5))),
              new Vertex(pos + dt * vec3(0.5, -0.5, -0.5),
                sdf.getUV(pos + dt * vec3(0.5, -0.5, -0.5)),
                sdf.getNormal(pos + dt * vec3(0.5, -0.5, -0.5))),
              new Vertex(pos + dt * vec3(0.5, -0.5, 0.5),
                sdf.getUV(pos + dt * vec3(0.5, -0.5, 0.5)),
                sdf.getNormal(pos + dt * vec3(0.5, -0.5, 0.5))),
              new Vertex(pos + dt * vec3(0.5, 0.5, 0.5),
                sdf.getUV(pos + dt * vec3(0.5, 0.5, 0.5)),
                sdf.getNormal(pos + dt * vec3(0.5, 0.5, 0.5))),);
          }

          if (sampleDistance.get('${pos.x},${pos.y},${pos.z}') == true
            && sampleDistance.get('${top.x},${top.y},${top.z}') == false) {
            addQuad(new Vertex(pos + dt * vec3(-0.5, 0.5, -0.5),
              sdf.getUV(pos + dt * vec3(-0.5, 0.5, -0.5)),
              sdf.getNormal(pos + dt * vec3(-0.5, 0.5, -0.5))),
              new Vertex(pos + dt * vec3(0.5, 0.5, -0.5),
                sdf.getUV(pos + dt * vec3(0.5, 0.5, -0.5)),
                sdf.getNormal(pos + dt * vec3(0.5, 0.5, -0.5))),
              new Vertex(pos + dt * vec3(0.5, 0.5, 0.5),
                sdf.getUV(pos + dt * vec3(0.5, 0.5, 0.5)),
                sdf.getNormal(pos + dt * vec3(0.5, 0.5, 0.5))),
              new Vertex(pos + dt * vec3(-0.5, 0.5, 0.5),
                sdf.getUV(pos + dt * vec3(-0.5, 0.5, 0.5)),
                sdf.getNormal(pos + dt * vec3(-0.5, 0.5, 0.5))),);
          }

          if (sampleDistance.get('${pos.x},${pos.y},${pos.z}') == true
            && sampleDistance.get('${bottom.x},${bottom.y},${bottom.z}') == false) {
            addQuad(new Vertex(pos + dt * vec3(-0.5, -0.5, -0.5),
              sdf.getUV(pos + dt * vec3(-0.5)),
              sdf.getNormal(pos + dt * vec3(-0.5, -0.5, -0.5))),
              new Vertex(pos + dt * vec3(-0.5, -0.5, 0.5),
                sdf.getUV(pos + dt * vec3(-0.5, -0.5, 0.5)),
                sdf.getNormal(pos + dt * vec3(-0.5, -0.5, 0.5))),
              new Vertex(pos + dt * vec3(0.5, -0.5, 0.5),
                sdf.getUV(pos + dt * vec3(0.5, -0.5, 0.5)),
                sdf.getNormal(pos + dt * vec3(0.5, -0.5, 0.5))),
              new Vertex(pos + dt * vec3(0.5, -0.5, -0.5),
                sdf.getUV(pos + dt * vec3(0.5, -0.5, -0.5)),
                sdf.getNormal(pos + dt * vec3(0.5, -0.5, -0.5))),);
          }
        }
      }
    }
  }
}
