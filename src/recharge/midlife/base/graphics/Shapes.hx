/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package recharge.midlife.base.graphics;

import recharge.midlife.base.graphics.Mesh;

class Plane extends Mesh {
  public function new() {
    addQuad(new Vertex(vec3(-1, -1, 0) / 2, vec2(0, 1)),
      new Vertex(vec3(1, -1, 0) / 2, vec2(1, 1)),
      new Vertex(vec3(1, 1, 0) / 2, vec2(0, 0)),
      new Vertex(vec3(-1, 1, 0) / 2, vec2(1, 0)));
  }
}

class Cube extends Mesh {
  public function new() {
    // Front
    addQuad(new Vertex(new Vec3(-0.5, -0.5, -0.5), new Vec2(0, 1)),
      new Vertex(new Vec3(0.5, -0.5, -0.5), new Vec2(1, 1)),
      new Vertex(new Vec3(0.5, 0.5, -0.5), new Vec2(1, 0)),
      new Vertex(new Vec3(-0.5, 0.5, -0.5), new Vec2(0, 0)));

    // Back
    addQuad(new Vertex(new Vec3(-0.5, -0.5, 0.5), new Vec2(1, 1)),
      new Vertex(new Vec3(-0.5, 0.5, 0.5), new Vec2(1, 0)),
      new Vertex(new Vec3(0.5, 0.5, 0.5), new Vec2(0, 0)),
      new Vertex(new Vec3(0.5, -0.5, 0.5), new Vec2(0, 1)));

    // Left
    addQuad(new Vertex(new Vec3(-0.5, -0.5, -0.5), new Vec2(0, 1)),
      new Vertex(new Vec3(-0.5, 0.5, -0.5), new Vec2(0, 0)),
      new Vertex(new Vec3(-0.5, 0.5, 0.5), new Vec2(1, 0)),
      new Vertex(new Vec3(-0.5, -0.5, 0.5), new Vec2(1, 1)));

    // Right
    addQuad(new Vertex(new Vec3(0.5, 0.5, -0.5), new Vec2(0, 0)),
      new Vertex(new Vec3(0.5, -0.5, -0.5), new Vec2(0, 1)),
      new Vertex(new Vec3(0.5, -0.5, 0.5), new Vec2(1, 1)),
      new Vertex(new Vec3(0.5, 0.5, 0.5), new Vec2(1, 0)));

    // Bottom
    addQuad(new Vertex(new Vec3(-0.5, -0.5, -0.5), new Vec2(0, 1)),
      new Vertex(new Vec3(-0.5, -0.5, 0.5), new Vec2(1, 1)),
      new Vertex(new Vec3(0.5, -0.5, 0.5), new Vec2(1, 0)),
      new Vertex(new Vec3(0.5, -0.5, -0.5), new Vec2(0, 0)));

    // Top
    addQuad(new Vertex(new Vec3(-0.5, 0.5, -0.5), new Vec2(0, 1)),
      new Vertex(new Vec3(0.5, 0.5, -0.5), new Vec2(1, 1)),
      new Vertex(new Vec3(0.5, 0.5, 0.5), new Vec2(1, 0)),
      new Vertex(new Vec3(-0.5, 0.5, 0.5), new Vec2(0, 0)));
  }
}
