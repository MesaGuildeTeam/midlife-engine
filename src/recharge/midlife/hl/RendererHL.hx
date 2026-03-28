package recharge.midlife.hl;

import haxe.io.Float32Array;
import haxe.io.UInt16Array;

import hl.Bytes;

import sdl.GL;

import recharge.midlife.base.graphics.RendererAbstract.RenderInstruction;
import recharge.midlife.base.graphics.RendererAbstract;
import recharge.midlife.base.Scene;
import recharge.midlife.base.graphics.Texture;

class RendererHL extends RendererAbstract {
  var _vbo:Buffer;
  var _vao:VertexArray;
  var _ebo:Buffer;

  var _currentBG:Vec3;

  static inline var stride:Int = 8 * 4;

  public function new() {
    super();

    // Setup Rendering Rules
    GL.enable(GL.DEPTH_TEST);
    GL.depthFunc(GL.LESS);
    GL.depthMask(true);

    GL.enable(GL.BLEND);
    GL.blendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
    GL.enable(GL.CULL_FACE);
    GL.cullFace(GL.BACK);

    // GL.polygonMode(GL.FRONT_AND_BACK, GL.LINE);
    GL.enable(GL.FRAMEBUFFER_SRGB);

    // Prepare buffers
    _vbo = GL.createBuffer();
    _vao = GL.createVertexArray();
    _ebo = GL.createBuffer();

    GL.bindBuffer(GL.ARRAY_BUFFER, _vbo);
    GL.bindVertexArray(_vao);
    GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, _ebo);

    // GL.clearDepth(1.0);

    trace("DEBUG: Renderer Initialized");

    // Initialize Shader so we can get attribute locations
    var _currentShader = cast ShaderHL.defaultShader.getShaderProgram();
    GL.useProgram(_currentShader);
    _currentBG = vec3(0.0);

    var atrPos = GL.getAttribLocation(_currentShader, "a_Position");
    var atrUV = GL.getAttribLocation(_currentShader, "a_UV");
    var atrNorm = GL.getAttribLocation(_currentShader, "a_Normal");

    if (atrPos != -1) {
      trace("Identified attribute a_Position");
      GL.enableVertexAttribArray(atrPos);
      GL.vertexAttribPointer(atrPos, 3, GL.FLOAT, false, stride, 0);
    }

    if (atrUV != -1) {
      trace("Identified attribute a_UV");
      GL.enableVertexAttribArray(atrUV);
      GL.vertexAttribPointer(atrUV, 2, GL.FLOAT, false, stride, 3 * 4);
    }

    if (atrNorm != -1) {
      trace("Identified attribute a_Normal");
      GL.enableVertexAttribArray(atrNorm);
      GL.vertexAttribPointer(atrNorm, 3, GL.FLOAT, false, stride, 5 * 4);
    }

    // Define vertex attribute space

    GL.clearColor(0, 0, 0, 1);
  }

  override public function setBackgroundColor(color:Vec3):Void {
    GL.clearColor(color.x, color.y, color.z, 1);
    _currentBG = color;
  }

  function assignSceneUniforms(shader:Program, scene:Scene) {
    var ambient = GL.getUniformLocation(shader, "u_Ambient");
    if (ambient != null) {
      var v = [_currentBG.x, _currentBG.y, _currentBG.z, 0.0];
      var v3 = Float32Array.fromArray(v).getData();
      GL.uniform4fv(ambient, Bytes.fromBytes(v3.bytes), 0, 1);
    }

    // Point Lights
    var lightPos = GL.getUniformLocation(shader, "u_LightPos");
    if (lightPos != null) {
      var v = Float32Array.fromArray(scene.lights.getLightPosArray()).getData();
      GL.uniform4fv(lightPos, Bytes.fromBytes(v.bytes), 0, scene.lights.length);
    }

    var lightColor = GL.getUniformLocation(shader, "u_LightColor");
    if (lightColor != null) {
      var v = Float32Array.fromArray(scene.lights.getLightColorArray())
        .getData();
      GL.uniform4fv(lightColor, Bytes.fromBytes(v.bytes), 0,
        scene.lights.length);
    }

    var lightCount = GL.getUniformLocation(shader, "u_LightCount");
    if (lightCount != null)
      GL.uniform1i(lightCount, scene.lights.length);

    // Camera matrix
    var camPos = GL.getUniformLocation(shader, "u_Camera");
    if (camPos != null) {
      var tfArray = new Array<Float>();
      var camMatrix = scene.camera != null ? scene.camera.transform.inverse() : mat4(1.0);
      camMatrix.copyIntoArray(tfArray, 0);
      var camMatrix32 = Float32Array.fromArray(tfArray).getData();
      GL.uniformMatrix4fv(camPos, false, Bytes.fromBytes(camMatrix32.bytes),
        0, 1);
    }
  }

  override function preRender(scene:Scene):Void {
    GL.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
  }

  override function drawInstruction(instruction:RenderInstruction,
      scene:Scene) {
    // Assign shader
    var currentShader:Program = cast instruction.shader.getShaderProgram();
    // trace("Using shader program ID " + currentShader);
    GL.useProgram(currentShader);

    // assign scene uniforms
    assignSceneUniforms(currentShader, scene);

    // Material Uniforms
    var tfArray:Array<Float> = new Array();
    instruction.transformation.copyIntoArray(tfArray, 0);
    var tf32 = Float32Array.fromArray(tfArray).getData();

    var tfUniform = GL.getUniformLocation(currentShader, "u_Transform");
    if (tfUniform != null)
      GL.uniformMatrix4fv(tfUniform, false, Bytes.fromBytes(tf32.bytes), 0, 1);

    // Textures
    var utUniform = GL.getUniformLocation(currentShader, "u_usesTexture");
    var diffuse:Null<Texture> = instruction.textures.get(TextureSlot.Diffuse);
    if (diffuse != null) {
      // trace("Use texture ID " + diffuse.getTexture());
      GL.activeTexture(GL.TEXTURE0);
      GL.bindTexture(GL.TEXTURE_2D, cast(diffuse.getTexture(), sdl.Texture));

      if (utUniform != null)
        GL.uniform1i(utUniform, 1);
    } else {
      if (utUniform != null)
        GL.uniform1i(utUniform, 0);
    }

    var udcUniform = GL.getUniformLocation(currentShader, "u_DiffuseColor");
    if (udcUniform != null) {
      var c = instruction.diffuseColor != null ? instruction.diffuseColor : vec4(1,
        1, 1, 1);
      var v = Float32Array.fromArray([c.x, c.y, c.z, c.w]).getData();
      GL.uniform4fv(udcUniform, Bytes.fromBytes(v.bytes), 0, 1);
    }

    var usmUniform = GL.getUniformLocation(currentShader, "u_MaterialParams");
    if (usmUniform != null) {
      var v = Float32Array.fromArray([instruction.shininess, 0.0, 0.0, 0.0])
        .getData();
      GL.uniform4fv(usmUniform, Bytes.fromBytes(v.bytes), 0, 1);
    }

    // Bind and draw mesh with shader
    var vb:Array<Float> = instruction.mesh.getVertices();
    var vb32 = Float32Array.fromArray(vb).getData();
    var ib:Array<Int> = instruction.mesh.getIndices();
    var ib16 = UInt16Array.fromArray(ib).getData();

    GL.bufferData(GL.ARRAY_BUFFER, vb32.byteLength,
      Bytes.fromBytes(vb32.bytes), GL.DYNAMIC_DRAW);
    GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, ib16.byteLength,
      Bytes.fromBytes(ib16.bytes), GL.DYNAMIC_DRAW);

    GL.drawElements(GL.TRIANGLES, ib.length, GL.UNSIGNED_SHORT, 0);
  }
}
