package recharge.midlife.hl;

import sdl.GL;

import recharge.midlife.base.graphics.ShaderAbstract;
import recharge.midlife.base.FileStream;

class ShaderHL extends ShaderAbstract {
  override function compileShader():Void {
    var vScript = new FileStream(FileMode.READ, _vert).getDataString();
    var fScript = new FileStream(FileMode.READ, _frag).getDataString();

    // Compile Shaders

    var vShader = GL.createShader(GL.VERTEX_SHADER);
    GL.shaderSource(vShader, vScript);
    GL.compileShader(vShader);

    if (!GL.getShaderParameter(vShader, GL.COMPILE_STATUS))
      throw("ERROR: Vertex shader failed to compile\n"
        + GL.getShaderInfoLog(vShader));

    var fShader = GL.createShader(GL.FRAGMENT_SHADER);
    GL.shaderSource(fShader, fScript);
    GL.compileShader(fShader);

    if (!GL.getShaderParameter(fShader, GL.COMPILE_STATUS))
      throw("ERROR: Fragment shader failed to compile\n"
        + GL.getShaderInfoLog(fShader));

    // Create shader program
    var program = GL.createProgram();
    GL.attachShader(program, vShader);
    GL.attachShader(program, fShader);

    GL.linkProgram(program);

    if (!GL.getProgramParameter(program, GL.LINK_STATUS))
      throw("ERROR: Shader Program failed to link\n"
        + GL.getProgramInfoLog(program));

    _program = cast(program, Int);

    trace("DEBUG: Created shader program with ID " + _program);
  }

  static public var defaultShader = new ShaderHL();
}
