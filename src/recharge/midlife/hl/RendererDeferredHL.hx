package recharge.midlife.hl;

import haxe.io.Float32Array;
import haxe.io.UInt16Array;

import hl.Bytes;

import sdl.GL;

import recharge.midlife.base.graphics.RendererAbstract.RenderInstruction;
import recharge.midlife.base.graphics.RendererAbstract;
import recharge.midlife.base.Scene;
import recharge.midlife.base.graphics.Texture;

class RendererDeferredHL extends RendererHL {

  var _buffer:FrameBufferHL;
  var _bufferShader:ShaderHL;

  static inline var stride:Int = 8 * 4;

  public function new() {
    super();

    // Define framebuffer parameters 
    _buffer = new FrameBufferHL();
    _bufferShader = new ShaderHL('midlife/post.frag', 'midlife/post.vert');
  }

  override public function setBackgroundColor(color:Vec3):Void {
    _currentBG = color;
  }

  override function preRender(scene:Scene):Void {
    // Bind framebuffer
    _buffer.bind();
    GL.viewport(0, 0, 320, 240);
    GL.enable(GL.DEPTH_TEST);
    GL.depthFunc(GL.LESS);

    GL.enable(GL.BLEND);
    GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
    GL.enable(GL.CULL_FACE);
    GL.cullFace(GL.BACK);

    var buffersArray = haxe.io.UInt32Array.fromArray([GL.COLOR_ATTACHMENT0, 0x8CE1, 0x8CE2]).getData();
    GL.drawBuffers(3, Bytes.fromBytes(buffersArray.bytes));
    
    GL.clearColor(_currentBG.x, _currentBG.y, _currentBG.z, 1);
    GL.clear(GL.COLOR_BUFFER_BIT);
    GL.clear(GL.DEPTH_BUFFER_BIT);
  }
  
  override function postRender(scene:Scene):Void {
    // Unbind framebuffer
    _buffer.unbind();
    GL.viewport(0, 0, GameHL.window.width, GameHL.window.height);
    GL.clearColor(_currentBG.x, _currentBG.y, _currentBG.z, 1);
    GL.clear(GL.COLOR_BUFFER_BIT);
    GL.clear(GL.DEPTH_BUFFER_BIT);

    // use buffer shader
    var currentShader:Program = cast _bufferShader.getShaderProgram();
    GL.useProgram(currentShader);

    // camera just in case
    var camPos = GL.getUniformLocation(currentShader, "u_Camera");
    if (camPos != null) {
      var tfArray = new Array<Float>();
      var camMatrix = scene.camera != null ? scene.camera.transform.inverse() : mat4(1.0);
      camMatrix.copyIntoArray(tfArray, 0);
      var camMatrix32 = Float32Array.fromArray(tfArray).getData();
      GL.uniformMatrix4fv(camPos, false, Bytes.fromBytes(camMatrix32.bytes),
        0, 1);
    }

    var uTex = GL.getUniformLocation(currentShader, "u_Texture");
    if (uTex != null) {
      GL.uniform1i(uTex, 0);
    }
    
    var uNormalTex = GL.getUniformLocation(currentShader, "u_NormalTexture");
    if (uNormalTex != null) {
      GL.uniform1i(uNormalTex, 1);
    }
    
    var uPositionTex = GL.getUniformLocation(currentShader, "u_PositionTexture");
    if (uPositionTex != null) {
      GL.uniform1i(uPositionTex, 2);
    }

    GL.activeTexture(GL.TEXTURE0);
    GL.bindTexture(GL.TEXTURE_2D, _buffer.colorTexture);
    GL.activeTexture(GL.TEXTURE1);
    GL.bindTexture(GL.TEXTURE_2D, _buffer.normalTexture);
    GL.activeTexture(GL.TEXTURE2);
    GL.bindTexture(GL.TEXTURE_2D, _buffer.positionTexture);

    // draw fullscreen quad
    // 3d position
    // uv
    // normal
    var vertices: Array<Float> = [
      -1, -1, 0, 0, 0, 0, 0, 1, 
      1, -1, 0, 1, 0, 0, 0, 1, 
      1, 1, 0, 1, 1, 0, 0, 1, 
      -1, 1, 0, 0, 1, 0, 0, 1,
    ];
    var vertices32 = Float32Array.fromArray(vertices).getData();
    var indices: Array<Int> = [0, 1, 2, 0, 2, 3];
    var indices16 = UInt16Array.fromArray(indices).getData();
    GL.bufferData(GL.ARRAY_BUFFER, vertices32.byteLength, Bytes.fromBytes(vertices32.bytes), GL.DYNAMIC_DRAW);
    GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices16.byteLength, Bytes.fromBytes(indices16.bytes), GL.DYNAMIC_DRAW);
    GL.drawElements(GL.TRIANGLES, indices.length, GL.UNSIGNED_SHORT, 0);
  }
}
