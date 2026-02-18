package recharge.midlife.base;

class Animated<T> {
  var _frames:Array<T>;
  var _frameInterpolations:Array<Dynamic>;
  var _currentTime:Float = 0.0;

  var _frameTime:Array<Float>;
  var _totalTime:Float;

  var _loop:Bool;

  public function new(frames:Array<T>, frameTime:Array<Float>,
      frameInterpolations:Array<Dynamic>, loop:Bool = true) {
    this._frames = frames;
    this._frameInterpolations = frameInterpolations;
    this._frameTime = frameTime;
    this._loop = loop;

    _totalTime = 0.0;
    for (time in frameTime) {
      _totalTime += time;
    }
  }

  public function update(dt:Float):Void {
    _currentTime += dt;

    if (_loop) {
      _currentTime = _currentTime % _totalTime;
    } else if (_currentTime > _totalTime) {
      _currentTime = _totalTime;
    }
  }

  public var time(get, set):Float;

  public function get_time():Float {
    return _currentTime;
  }

  public function set_time(value:Float):Float {
    _currentTime = value;
    return _currentTime;
  }

  public var value(get, never):T;

  public function get_value():T {
    var accumulatedTime:Float = 0.0;
    var currentSlideIndex:Int = 0;

    // Accumulate time to find the current frame
    for (i in 0..._frames.length - 1) {
      if (_currentTime >= accumulatedTime)
        break;

      accumulatedTime += _frameTime[i];
      currentSlideIndex++;
    }

    if (currentSlideIndex >= _frames.length - 1) {
      return _frames[_frames.length - 1];
    }

    return _frames[currentSlideIndex];
  }
}
