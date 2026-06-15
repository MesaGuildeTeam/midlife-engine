/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package recharge.midlife.base.graphics;

import recharge.midlife.base.Scene;
import recharge.midlife.base.Game;

import haxe.ds.ArraySort;

import recharge.midlife.base.graphics.Shader;
import recharge.midlife.base.graphics.Texture;
import recharge.midlife.base.graphics.Mesh;
import recharge.midlife.base.graphics.Shapes;
import recharge.midlife.base.Utils;

class RenderInstruction {
  public var mode:String;

  public var mesh:Mesh;
  public var text:String;

  public var transformation:Mat4 = mat4(1.0);
  public var shader:ShaderAbstract;
  public var textures:Map<TextureSlot, Null<Texture>>;
  public var isTransparent:Bool = false;
  public var diffuseColor:Vec4 = vec4(1.0);
  public var shininess:Float = 0.0;
  public var shinePower:Float = 5.0;

  public function new() {
    textures = new Map();
    shader = ShaderAbstract.defaultShader;
  }

  public function getZ():Float {
    var scene = Game.getInstance().getScene();
    var cameraTf = scene.camera != null ? scene.camera.transform.inverse() : mat4(1.0);
    return (cameraTf * transformation * vec4(mesh.getCenter(), 1)).z;
  }
}

/**
 * An abstract renderer interface to give the game developer a workflow to work with
 */
class RendererAbstract {
  static var quadMesh:Mesh = new Plane();

  var _renderQueue:Array<RenderInstruction>;
  var _uiRenderQueue:Array<RenderInstruction>;
  var _constructingInstruction:RenderInstruction;
  var _useUITarget:Bool = false;

  public function new() {
    _renderQueue = new Array();
    _uiRenderQueue = new Array();
    _constructingInstruction = new RenderInstruction();
  }

  /**
   * Draws all queued meshes to the screen
   */
  public function flush(scene:Scene):Void {
    // Sort render queue first
    ArraySort.sort(_renderQueue, (a, b) -> {
      if (a.getZ() < b.getZ())
        return -1;
      return 1;
    });

    // Call pre-render hook
    //preRender(scene);

    // Iterate and clean
    for (i in _renderQueue)
      drawInstruction(i, scene);
    _renderQueue = new Array();

    // Call post-render hook
    postRender(scene);

    for (i in _uiRenderQueue)
      drawInstruction(i, scene);
    _uiRenderQueue = new Array();
  }

  /**
   * Pushes a shader to be used for rendering the next mesh
   * @param shader
   */
  public function pushShader(shader:Shader):Void {
    _constructingInstruction.shader = shader;
  }

  public function toggleUIQueue():Void {
    _useUITarget = !_useUITarget;
  }

  /**
   * Queues the rendering of a mesh with the specified transformation
   *
   * @param mesh the mesh to draw
   * @param pos the position to draw the mesh at in world space, defaults to (0,0,0)
   * @param scale the scale to draw the mesh at, defaults to (1,1,1)
   * @param rot the rotation to draw the mesh at, defaults to (0,0,0)
   */
  public function queueMesh(mesh:Mesh, ?pos:Vec3, ?scale:Vec3, ?rot:Vec3):Void {
    _constructingInstruction.mesh = mesh;

    // Generate Transformation
    pos = pos != null ? pos : vec3(0, 0, 0);
    scale = scale != null ? scale : vec3(1, 1, 1);
    rot = rot != null ? rot : vec3(0, 0, 0);
    var tform:Mat4 = Utils.genTransformMatrix(pos, scale, rot);
    _constructingInstruction.transformation = tform;

    // push instruction and prepare next instruction
    if (_useUITarget) {
      _uiRenderQueue.push(_constructingInstruction);
    } else {
      if (_constructingInstruction.isTransparent)
        _renderQueue.push(_constructingInstruction);
      else
      drawInstruction(_constructingInstruction, Game.getInstance().getScene());
    }

    _useUITarget = false;
    _constructingInstruction = new RenderInstruction();
  }

  public function pushTexture(texture:Texture,
      slot:TextureSlot = TextureSlot.Diffuse):Void {
    _constructingInstruction.isTransparent = _constructingInstruction.isTransparent ? true : texture.isTransparent;
    _constructingInstruction.textures.set(slot, texture);
  }

  public function pushDiffuseColor(color:Vec4) {
    _constructingInstruction.diffuseColor = color;
  }

  public function pushShininess(shininess:Float) {
    _constructingInstruction.shininess = shininess;
  }

  /**
   * simplified the queueing of a single sprite at a given position with a given rotation
   *
   * The sprite will be drawn at its native 1:1 size if given a distance of 10 units
   * @param sprite
   * @param pos
   * @param scale
   * @param rot
   */
  public function queueTexturedPlane(sprite:Texture, ?pos:Vec3,
      scale:Float = 1.0, ?rot:Vec3):Void {
    pushTexture(sprite);
    queueMesh(quadMesh, pos, vec3(sprite.dimensions, 1) * scale / 16.0, rot);
  }

  // OVERRIDABLE METHODS //

  /**
   * Sets the background color of the renderer
   *
   * @param color the color in RGB format
   */
  public function setBackgroundColor(color:Vec3):Void {
    trace("WARNING: setBackgroundColor not implemented");
  }

  /**
   * draws a mesh with its specified transformation and material
   *
   * @param instruction the specification of what and how to draw the mesh
   */
  function drawInstruction(instruction:RenderInstruction, scene:Scene):Void {
    trace("WARNING: drawInstruction not implemented for this target");
  }

  /**
   * Called before the render queue is processed
   * @param scene
   */
  public function preRender(scene:Scene):Void {
    // Default implementation does nothing
  }

  /**
   * Called after the render queue is processed
   * @param scene
   */
  public function postRender(scene:Scene):Void {
    // Default implementation does nothing
  }
}
