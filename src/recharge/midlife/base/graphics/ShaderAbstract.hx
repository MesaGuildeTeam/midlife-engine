/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package recharge.midlife.base.graphics;

class ShaderAbstract {
  var _frag:String;
  var _vert:String;
  var _program:Int;

  public function new(?fragment:String, ?vertex:String) {
    _frag = fragment == null ? "midlife/default.frag" : fragment;
    _vert = vertex == null ? "midlife/default.vert" : vertex;
    _program = 0;
  }

  function compileShader():Void {
    trace("WARNING: Shader compilation not implemented. Applying default values.");
    _program = 1;
  }

  public function getShaderProgram():Int {
    if (_program == 0)
      compileShader();

    return _program;
  }

  //public static var defaultShader:ShaderAbstract = new Shader();
  public static var defaultShader(get, never):ShaderAbstract;

  public static function get_defaultShader():ShaderAbstract {
    static var shader:Shader = new Shader();

    return cast shader;
  }
}
