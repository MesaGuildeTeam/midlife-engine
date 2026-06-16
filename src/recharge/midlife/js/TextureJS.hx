package recharge.midlife.js;

import js.html.webgl.GL2;
import js.html.webgl.Texture;

import format.png.Reader;
import format.png.Tools;

import recharge.midlife.base.graphics.TextureAbstract;
import recharge.midlife.base.FileStream;

class TextureJS extends TextureAbstract {
  static var pathHash:Map<String, Texture> = new Map();

  var _textureJS:Texture;
  var file:FileStream;

  function getImageDimensions(bytes:haxe.io.Bytes):Vec2 {
    var width:Int = 0;
    var height:Int = 0;

    width = bytes.get(16) << 24 | bytes.get(17) << 16 | bytes.get(18) << 8 | bytes.get(19);
    height = bytes.get(20) << 24 | bytes.get(21) << 16 | bytes.get(22) << 8 | bytes.get(23);
    return vec2(width, height);
  }

  override function loadTexture():Void {
    var GL = RendererJS.GL;

    if (pathHash.exists(_path)) {
      _textureJS = pathHash.get(_path);
      return;
    }

    if (file == null)
      file = new FileStream(FileMode.READ, _path);
    if (file.isLoaded != true)
      return;

    var data:haxe.io.Bytes = file.getDataBytes();

    _dimensions = getImageDimensions(data);

    var reader = new Reader(new haxe.io.BytesInput(data));
    var pngData = reader.read();
    var pixelData = Tools.extract32(pngData);

    var jsTypedArray = new js.lib.Uint8Array(pixelData.getData());

    var texture = GL.createTexture();
    GL.bindTexture(GL2.TEXTURE_2D, texture);
    GL.texImage2D(GL2.TEXTURE_2D, 0, GL2.RGBA, Std.int(_dimensions.x), Std.int(_dimensions.y), 0, GL2.RGBA, GL2.UNSIGNED_BYTE, jsTypedArray);
    //GL.texImage2D(GL2.TEXTURE_2D, 0, GL2.RGBA, Std.int(_dimensions.x),
    //  Std.int(_dimensions.y), 0, GL2.RGBA, GL2.UNSIGNED_BYTE,
    //  js.lib.Uint8Array(pixelData));
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_MIN_FILTER, GL2.NEAREST);
    GL.texParameteri(GL2.TEXTURE_2D, GL2.TEXTURE_MAG_FILTER, GL2.NEAREST);

    _textureJS = texture;
    pathHash.set(_path, _textureJS);

    trace("DEBUG: Loaded texture " + _path);
  }

  public function getTextureJS():Texture {
    if (_textureJS == null)
      loadTexture();

    return _textureJS;
  }
}
