/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package recharge.midlife.base.input;

class Input {
  private var m_isDown:Float;
  private var m_currentStrength:Float;

  private var m_isPressed:Bool;
  private var m_isReleased:Bool;

  private var _listener:Void->Float;

  public function new(?listener:Void->Float) {
    if (listener != null)
      this._listener = listener;
  }

  public function update():Void {
    if (this._listener != null)
      m_currentStrength = _listener();
    var isDown:Bool = m_currentStrength > 0.0;
    var wasDown:Bool = this.m_isDown > 0.0;

    this.m_isPressed = isDown && !this.m_isPressed && !wasDown;
    this.m_isReleased = !isDown && wasDown && !this.m_isReleased;
    this.m_isDown = m_currentStrength;
  }

  public function isPressed():Bool {
    return m_isPressed;
  }

  public function isReleased():Bool {
    return m_isReleased;
  }

  public function isDown():Bool {
    return m_isDown > 0.0;
  }

  public var strength(get, set):Float;

  function set_strength(value:Float):Float {
    if (value < 0.0 || value > 1.0)
      throw "Input strength cannot be less than 0 or greater than 1";

    return m_currentStrength = value;
  }

  function get_strength():Float {
    return m_isDown;
  }

  public function flush():Void {
    m_isPressed = false;
    m_isReleased = false;
    strength = 0.0;
  }
}
