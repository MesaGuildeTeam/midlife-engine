package recharge.midlife.js;

import js.Browser;
import js.html.CanvasElement;
import js.html.webgl.GL2;
import js.html.webgl.Buffer;
import js.html.webgl.VertexArrayObject;
import js.html.webgl.Program;
import js.html.webgl.Texture as GlTexture;


import recharge.midlife.base.graphics.RendererAbstract;
import recharge.midlife.base.graphics.Shader;
import recharge.midlife.base.graphics.Texture;

import recharge.midlife.base.Game;
import recharge.midlife.base.Scene;

class RendererJS extends RendererAbstract {
  var _vbo:Buffer;
  var _vao:VertexArrayObject;
  var _ebo:Buffer;

  var _currentBG:Vec3;

  public static var Canvas:CanvasElement;
  public static var GL:GL2;

  public function new() {
    super();

    Canvas = cast Browser.document.getElementById("midlife-canvas");
    GL = cast Canvas.getContext("webgl2", {
      alpha: false,
      antialias: false,
      colorSpace: "srgb",
      powerPreference: "high-performance"
    });

    // Setup Rendering Rules
    GL.enable(GL2.DEPTH_TEST);
    GL.depthFunc(GL2.LESS);
    //GL.depthMask(false);

    GL.enable(GL2.BLEND);
    //GL.blendFunc(GL.ONE, GL.ONE);
    GL.blendFuncSeparate(GL2.SRC_ALPHA, GL2.ONE_MINUS_SRC_ALPHA, GL2.ONE, GL2.ONE_MINUS_SRC_ALPHA);
    GL.enable(GL2.CULL_FACE);
    GL.cullFace(GL2.BACK);

    // Prepare buffers
    _vbo = GL.createBuffer();
    _vao = GL.createVertexArray();
    _ebo = GL.createBuffer();

    GL.bindBuffer(GL2.ARRAY_BUFFER, _vbo);
    GL.bindVertexArray(_vao);
    GL.bindBuffer(GL2.ELEMENT_ARRAY_BUFFER, _ebo);

    // GL.clearDepth(1.0);

    trace("DEBUG: Renderer Initialized");

    // Initialize Shader so we can get attribute locations
    var _currentShader = cast(recharge.midlife.base.graphics.ShaderAbstract.defaultShader, Shader).getShaderProgramJS();
    GL.useProgram(_currentShader);
    _currentBG = vec3(0.0);

    // Define vertex attribute space

    GL.clearColor(0, 0, 0, 1);
  }

  override public function setBackgroundColor(color:Vec3):Void {
    GL.clearColor(color.x, color.y, color.z, 1);
    _currentBG = color;
  }

  function assignSceneUniforms(shader:Program, scene:Scene) {
    var windowDimensions = GL.getUniformLocation(shader, "u_WindowDimensions");
    if (windowDimensions != null) {
      var v = new js.lib.Float32Array([Game.getInstance()
        .dimensions.x, Game.getInstance().dimensions.y, 0.0, 0.0]);
      GL.uniform4fv(windowDimensions, v, 0, 4);
    }

    var ambient = GL.getUniformLocation(shader, "u_Ambient");
    if (ambient != null) {
      var v = new js.lib.Float32Array([_currentBG.x, _currentBG.y, _currentBG.z, 0.0]);
      GL.uniform4fv(ambient, v, 0, 4);
    }

    // Point Lights
    var lightPos = GL.getUniformLocation(shader, "u_LightPos");
    if (lightPos != null) {
      var v = new js.lib.Float32Array(scene.lights.getLightPosArray());
      GL.uniform4fv(lightPos, v);
    }

    var lightColor = GL.getUniformLocation(shader, "u_LightColor");
    if (lightColor != null) {
      var v = new js.lib.Float32Array(scene.lights.getLightColorArray());
      GL.uniform4fv(lightColor, v);
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
      GL.uniformMatrix4fv(camPos, false, new js.lib.Float32Array(tfArray),
        0, 16);
    }
  }

  override public function preRender(scene:Scene):Void {
    GL.enable(GL2.DEPTH_TEST);
    GL.clear(GL2.COLOR_BUFFER_BIT | GL2.DEPTH_BUFFER_BIT);
  }

  override function postRender(scene:Scene):Void {
    GL.disable(GL2.DEPTH_TEST);
  }

  var currentShader:Shader = null;

  override function drawInstruction(instruction:RenderInstruction,
      scene:Scene) {
    var shader:Program = cast(instruction.shader, Shader).getShaderProgramJS();

    // TODO: Figure out this impulse condition to figure out how to optimize
    // Shader Switching

    // if (currentShader == null || currentShader != instruction.shader) {
    GL.useProgram(shader);
    currentShader = cast instruction.shader;
    assignSceneUniforms(shader, scene);
    // }

    // Material Uniforms
    var tfArray:Array<Float> = new Array();
    instruction.transformation.copyIntoArray(tfArray, 0);

    var tfUniform = GL.getUniformLocation(shader, "u_Transform");
    if (tfUniform != null)
      GL.uniformMatrix4fv(tfUniform, false, new js.lib.Float32Array(tfArray), 0, 16);

    // Textures
    var utUniform = GL.getUniformLocation(shader, "u_usesTexture");
    var tUniform = GL.getUniformLocation(shader, "u_Diffuse");
    var diffuse:Null<Texture> = instruction.textures.get(TextureSlot.Diffuse);
    if (diffuse != null && tUniform != null) {
      GL.uniform1i(tUniform, 0);
      GL.activeTexture(GL2.TEXTURE0);
      GL.bindTexture(GL2.TEXTURE_2D, diffuse.getTextureJS());

      if (utUniform != null)
        GL.uniform1i(utUniform, 1);

    } else {
      if (utUniform != null)
        GL.uniform1i(utUniform, 0);
    }

    var diffuse2:Null<Texture> = instruction.textures.get(TextureSlot.Diffuse2);
    tUniform = GL.getUniformLocation(shader, "u_Diffuse2");
    utUniform = GL.getUniformLocation(shader, "u_usesTexture2");
    if (diffuse2 != null && tUniform != null) {
      GL.uniform1i(tUniform, 1);
      GL.activeTexture(GL2.TEXTURE1);
      GL.bindTexture(GL2.TEXTURE_2D, diffuse2.getTextureJS());

      if (utUniform != null)
        GL.uniform1i(utUniform, 1);
    } else {
      if (utUniform != null)
        GL.uniform1i(utUniform, 0);
    }

    var specular:Null<Texture> = instruction.textures.get(TextureSlot.Specular);
    tUniform = GL.getUniformLocation(shader, "u_Specular");
    utUniform = GL.getUniformLocation(shader, "u_usesTexture3");
    if (specular != null && tUniform != null) {
      GL.uniform1i(tUniform, 2);
      GL.activeTexture(GL2.TEXTURE2);
      GL.bindTexture(GL2.TEXTURE_2D, specular.getTextureJS());

      if (utUniform != null)
        GL.uniform1i(utUniform, 1);
    } else {
      if (utUniform != null)
        GL.uniform1i(utUniform, 0);
    }

    var normal:Null<Texture> = instruction.textures.get(TextureSlot.Normal);
    tUniform = GL.getUniformLocation(shader, "u_Normal");
    utUniform = GL.getUniformLocation(shader, "u_usesTexture4");
    if (normal != null && tUniform != null) {
      GL.uniform1i(tUniform, 3);
      GL.activeTexture(GL2.TEXTURE3);
      GL.bindTexture(GL2.TEXTURE_2D, normal.getTextureJS());

      if (utUniform != null)
        GL.uniform1i(utUniform, 1);
    } else {
      if (utUniform != null)
        GL.uniform1i(utUniform, 0);
    }

    // Material Constants
    var udcUniform = GL.getUniformLocation(shader, "u_DiffuseColor");
    if (udcUniform != null) {
      var c = instruction.diffuseColor != null ? instruction.diffuseColor : vec4(1,
        1, 1, 1);
      var v = new js.lib.Float32Array([c.x, c.y, c.z, c.w]);
      GL.uniform4fv(udcUniform, v, 0, 4);
    }

    var usmUniform = GL.getUniformLocation(shader, "u_MaterialParams");
    if (usmUniform != null) {
      var v = new js.lib.Float32Array([instruction.shininess, 0.0, 0.0, 0.0]);
      GL.uniform4fv(usmUniform, v, 0, 4);
    }

    // Bind and draw mesh with shader
    var vb:Array<Float> = instruction.mesh.getVertices();
    var ib:Array<Int> = instruction.mesh.getIndices();

    var Float32Array = js.lib.Float32Array;
    var Uint16Array = js.lib.Uint16Array;

    var vb32 = Float32Array.from(vb);
    var ib16 = Uint16Array.from(ib);

    GL.bufferData(GL2.ARRAY_BUFFER, vb32, GL2.DYNAMIC_DRAW);
    GL.bufferData(GL2.ELEMENT_ARRAY_BUFFER, ib16, GL2.DYNAMIC_DRAW);

    GL.drawElements(GL2.TRIANGLES, ib16.length, GL2.UNSIGNED_SHORT, 0);
  }
}
