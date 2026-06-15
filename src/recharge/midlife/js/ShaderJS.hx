package recharge.midlife.js;

import js.html.webgl.GL2;
import js.html.webgl.Program;

import recharge.midlife.base.graphics.ShaderAbstract;
import recharge.midlife.base.FileStream;

class ShaderJS extends ShaderAbstract {

  var _jsShader: Program;

  static inline var stride:Int = 8 * 4;

  override function compileShader():Void {
    final GL = RendererJS.GL;

    var vScript = new FileStream(FileMode.READ, _vert).getDataString();
    var fScript = new FileStream(FileMode.READ, _frag).getDataString();

    // Compile Shaders

    var vShader = GL.createShader(GL2.VERTEX_SHADER);
    GL.shaderSource(vShader, vScript);
    GL.compileShader(vShader);

    if (!GL.getShaderParameter(vShader, GL2.COMPILE_STATUS))
      throw("ERROR: Vertex shader failed to compile\n"
        + GL.getShaderInfoLog(vShader));

    var fShader = GL.createShader(GL2.FRAGMENT_SHADER);
    GL.shaderSource(fShader, fScript);
    GL.compileShader(fShader);

    if (!GL.getShaderParameter(fShader, GL2.COMPILE_STATUS))
      throw("ERROR: Fragment shader failed to compile\n"
        + GL.getShaderInfoLog(fShader));

    // Create shader program
    var program = GL.createProgram();
    GL.attachShader(program, vShader);
    GL.attachShader(program, fShader);

    GL.linkProgram(program);

    if (!GL.getProgramParameter(program, GL2.LINK_STATUS))
      throw("ERROR: Shader Program failed to link\n"
        + GL.getProgramInfoLog(program));

    var atrPos = GL.getAttribLocation(program, "a_Position");
    var atrUV = GL.getAttribLocation(program, "a_UV");
    var atrNorm = GL.getAttribLocation(program, "a_Normal");

    if (atrPos != -1) {
      trace("Identified attribute a_Position");
      GL.enableVertexAttribArray(atrPos);
      GL.vertexAttribPointer(atrPos, 3, GL2.FLOAT, false, stride, 0);
    }

    if (atrUV != -1) {
      trace("Identified attribute a_UV");
      GL.enableVertexAttribArray(atrUV);
      GL.vertexAttribPointer(atrUV, 2, GL2.FLOAT, false, stride, 3 * 4);
    }

    if (atrNorm != -1) {
      trace("Identified attribute a_Normal");
      GL.enableVertexAttribArray(atrNorm);
      GL.vertexAttribPointer(atrNorm, 3, GL2.FLOAT, false, stride, 5 * 4);
    }

    _jsShader = program;

    trace("DEBUG: Created shader program with ID " + _program);
  }

  public function getShaderProgramJS():Program {
    if (_jsShader == null)
      compileShader();

    return _jsShader;
  }

  //static public var defaultShader = new ShaderJS();
}
