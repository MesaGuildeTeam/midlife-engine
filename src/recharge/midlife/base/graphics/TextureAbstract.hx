/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package recharge.midlife.base.graphics;

class TextureAbstract {
  var _texture:Int;
  var _dimensions:Vec2;

  public var _path:String;
  public var isTransparent:Bool = false;

  function loadTexture():Void {
    trace("WARNING: texture loading process is undefined. Will default to 0");
    _texture = 0;
    _dimensions = vec2(0, 0);
  }

  public function new(path:String) {
    _path = path;
  }

  public function getTexture():Int {
    if (_texture == 0)
      loadTexture();

    return _texture;
  }

  public var dimensions(get, never):Vec2;

  public function get_dimensions():Vec2 {
    if (_dimensions == null)
      loadTexture();

    return _dimensions;
  }
}
