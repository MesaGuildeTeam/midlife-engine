package recharge.midlife.hl;

import hl.Bytes;
import hl.Format;

import sdl.GL;

import format.png.Reader;

import recharge.midlife.base.graphics.TextureAbstract;
import recharge.midlife.base.FileStream;

class TextureHL extends TextureAbstract {
  static var pathHash:Map<String, Int> = new Map<String, Int>();

  function getImageDimensions(bytes:haxe.io.Bytes):Vec2 {
    var width:Int = 0;
    var height:Int = 0;

    width = bytes.get(16) << 24 | bytes.get(17) << 16 | bytes.get(18) << 8 | bytes.get(19);
    height = bytes.get(20) << 24 | bytes.get(21) << 16 | bytes.get(22) << 8 | bytes.get(23);
    return vec2(width, height);
  }

  override function loadTexture():Void {
    if (pathHash.exists(_path)) {
      _texture = pathHash.get(_path);
      return;
    }

    var file = new FileStream(FileMode.READ, _path);
    var data:haxe.io.Bytes = file.getDataBytes();

    _dimensions = getImageDimensions(data);

    var pixelData = haxe.io.Bytes.alloc(Std.int(_dimensions.x) * Std.int(_dimensions.y) * 4);

    Format.decodePNG(Bytes.fromBytes(data), data.length, pixelData,
      Std.int(_dimensions.x), Std.int(_dimensions.y), 0, PixelFormat.RGBA, 0);

    var texture = GL.createTexture();
    GL.bindTexture(GL.TEXTURE_2D, texture);
    GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, Std.int(_dimensions.x),
      Std.int(_dimensions.y), 0, GL.RGBA, GL.UNSIGNED_BYTE,
      Bytes.fromBytes(pixelData));
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
    GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);

    _texture = cast(texture, Int);
    pathHash.set(_path, _texture);

    trace("DEBUG: Loaded texture " + _path + " with ID " + _texture);
  }
}
