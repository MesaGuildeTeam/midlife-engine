package recharge.midlife.base.graphics;

class LightArray {
  var _positions:Array<Float>;
  var _color:Array<Float>;

  public function new() {
    _positions = new Array();
    _color = new Array();
  }

  public function setLight(position:Vec4, color:Vec4, ?id:Null<Int>):Int {
    if (id == null) {
      _positions.push(position.x);
      _positions.push(position.y);
      _positions.push(position.z);
      _positions.push(position.w);
      _color.push(color.x);
      _color.push(color.y);
      _color.push(color.z);
      _color.push(color.w);
      return Std.int(_positions.length / 4) - 1;
    }

    _positions[id * 3] = position.x;
    _positions[id * 3 + 1] = position.y;
    _positions[id * 3 + 2] = position.z;

    _color[id * 4] = color.x;
    _color[id * 4 + 1] = color.y;
    _color[id * 4 + 2] = color.z;
    _color[id * 4 + 3] = color.w;

    return id;
  }

  public function getLightPosArray():Array<Float> {
    return _positions;
  }

  public function getLightColorArray():Array<Float> {
    return _color;
  }

  public function clearLights():Void {
    _positions = new Array();
    _color = new Array();
  }

  public function removeLight(id:Int):Void {}

  public var length(get, never):Int;

  public function get_length():Int {
    return Std.int(_positions.length / 3);
  }
}
