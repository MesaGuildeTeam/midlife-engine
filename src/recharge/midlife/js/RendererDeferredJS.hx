package recharge.midlife.js;

import js.html.webgl.GL2;
import js.html.webgl.Program;

import recharge.midlife.base.graphics.RendererAbstract.RenderInstruction;
import recharge.midlife.base.graphics.RendererAbstract;
import recharge.midlife.base.Scene;
import recharge.midlife.base.graphics.Texture;

class RendererDeferredJS extends RendererJS {
  var _buffer:FrameBufferJS;
  var _bufferShader:ShaderJS;

  static inline var stride:Int = 8 * 4;

  public function new() {
    super();

    if (RendererJS.GL == null)
      trace("WARNING: Uh... the webgl context is not recognized...");

    // Define framebuffer parameters
    _buffer = new FrameBufferJS(RendererJS.GL);
    _bufferShader = new ShaderJS('midlife/post.frag', 'midlife/post.vert');
  }

  public function getBuffer():FrameBufferJS {
    return _buffer;
  }

  override public function setBackgroundColor(color:Vec3):Void {
    _currentBG = color;
  }

  override function preRender(scene:Scene):Void {
    final GL = RendererJS.GL;
    // Enable depth testing for scene rendering
    GL.enable(GL2.DEPTH_TEST);

    GL.activeTexture(GL2.TEXTURE0); GL.bindTexture(GL2.TEXTURE_2D, null);
    GL.activeTexture(GL2.TEXTURE1); GL.bindTexture(GL2.TEXTURE_2D, null);
    GL.activeTexture(GL2.TEXTURE2); GL.bindTexture(GL2.TEXTURE_2D, null);
    GL.activeTexture(GL2.TEXTURE3); GL.bindTexture(GL2.TEXTURE_2D, null);

    // Bind framebuffer
    _buffer.bind();
    var dims = _buffer.getDimensions();
    GL.viewport(0, 0, cast dims.x, cast dims.y);
    GL.enable(GL2.DEPTH_TEST);
    GL.depthFunc(GL2.LESS);
    GL.depthMask(true);

    GL.enable(GL2.BLEND);
    GL.blendFunc(GL2.ONE, GL2.ONE_MINUS_SRC_ALPHA);
    GL.enable(GL2.CULL_FACE);
    GL.cullFace(GL2.BACK);

    var buffersArray:Array<Int> = [GL2.COLOR_ATTACHMENT0, 0x8CE1, 0x8CE2, 0x8CE3];
    GL.drawBuffers(buffersArray);

    GL.clearColor(_currentBG.x, _currentBG.y, _currentBG.z, 1);
    GL.clear(GL2.COLOR_BUFFER_BIT | GL2.DEPTH_BUFFER_BIT);
  }

  override function postRender(scene:Scene):Void {
    final GL = RendererJS.GL;
    // Unbind framebuffer
    _buffer.unbind();
    GL.viewport(0, 0, 320, 240);
    GL.clearColor(_currentBG.x, _currentBG.y, _currentBG.z, 1);
    GL.clear(GL2.COLOR_BUFFER_BIT);
    GL.clear(GL2.DEPTH_BUFFER_BIT);

    // use buffer shader
    var currentShader:Program = cast _bufferShader.getShaderProgramJS();
    GL.useProgram(currentShader);
    assignSceneUniforms(currentShader, scene);

    // camera just in case
    var camPos = GL.getUniformLocation(currentShader, "u_Camera");
    if (camPos != null) {
      var tfArray = new Array<Float>();
      var camMatrix = scene.camera != null ? scene.camera.transform.inverse() : mat4(1.0);
      camMatrix.copyIntoArray(tfArray, 0);
      var camMatrix32 = new js.lib.Float32Array(tfArray);
      GL.uniformMatrix4fv(camPos, false, camMatrix32,
        0, 16);
    }

    var uTex = GL.getUniformLocation(currentShader, "u_Texture");
    if (uTex != null) {
      GL.uniform1i(uTex, 0);
    }

    var uNormalTex = GL.getUniformLocation(currentShader, "u_NormalTexture");
    if (uNormalTex != null) {
      GL.uniform1i(uNormalTex, 1);
    }

    var uPositionTex = GL.getUniformLocation(currentShader,
      "u_PositionTexture");
    if (uPositionTex != null) {
      GL.uniform1i(uPositionTex, 2);
    }

    var uSpecularTex = GL.getUniformLocation(currentShader,
      "u_SpecularTexture");
    if (uSpecularTex != null) {
      GL.uniform1i(uSpecularTex, 3);
    }

    GL.activeTexture(GL2.TEXTURE0);
    GL.bindTexture(GL2.TEXTURE_2D, _buffer.colorTexture);
    GL.activeTexture(GL2.TEXTURE1);
    GL.bindTexture(GL2.TEXTURE_2D, _buffer.normalTexture);
    GL.activeTexture(GL2.TEXTURE2);
    GL.bindTexture(GL2.TEXTURE_2D, _buffer.positionTexture);
    GL.activeTexture(GL2.TEXTURE3);
    GL.bindTexture(GL2.TEXTURE_2D, _buffer.specularTexture);

    // draw fullscreen quad
    // 3d position
    // uv
    // normal
    var vertices:Array<Float> = [
      -1, -1, 0, 0, 0, 0, 0, 1,
       1, -1, 0, 1, 0, 0, 0, 1,
       1,  1, 0, 1, 1, 0, 0, 1,
      -1,  1, 0, 0, 1, 0, 0, 1,
    ];
    var vertices32 = new js.lib.Float32Array(vertices);
    var indices:Array<Int> = [0, 1, 2, 0, 2, 3];
    var indices16 = new js.lib.Uint16Array(indices);
    GL.bufferData(GL2.ARRAY_BUFFER, vertices32, GL2.DYNAMIC_DRAW);
    GL.bufferData(GL2.ELEMENT_ARRAY_BUFFER, indices16, GL2.DYNAMIC_DRAW);
    GL.drawElements(GL2.TRIANGLES, indices.length, GL2.UNSIGNED_SHORT, 0);

    // Prepare for UI rendering
    GL.disable(GL2.DEPTH_TEST);
  }
}
