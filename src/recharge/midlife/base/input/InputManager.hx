/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package recharge.midlife.base.input;

typedef Axis = Array<Null<Input>>;

class InputManager {
  static var m_instance:InputManager;

  var m_axisList:Map<String, Axis>;
  var m_keyboardQueue:Array<String>;
  var _mousePosition:Vec2 = vec2(0, 0);

  function new() {
    m_axisList = new Map();
    m_keyboardQueue = new Array();
  }

  public static function getInstance():InputManager {
    if (m_instance == null)
      m_instance = new InputManager();

    return m_instance;
  }

  public function pushKey(k:String):Void {
    m_keyboardQueue.push(k);
  }

  public function popKey():Null<String> {
    return m_keyboardQueue.pop();
  }

  public function setInput(name:String, positive:Input, ?negative:Input) {
    trace("setting " + name);
    m_axisList[name] = [positive, negative];
  }

  public function getInput(name:String, index:Int = 0):Input {
    if (m_axisList.exists(name))
      return m_axisList[name][index];

    throw "Input " + name + " not found";
  }

  public function getAxis(name:String):Float {
    if (m_axisList.exists(name))
      return m_axisList[name][0].strength - m_axisList[name][1].strength;

    trace("WARNING: Input " + name + " not found");
    return 0.0;
  }

  public function update():Void {
    for (i in m_axisList.keys()) {
      m_axisList[i][0].update();

      if (m_axisList[i][1] == null)
        continue;
      m_axisList[i][1].update();
    }
    m_keyboardQueue = new Array();
  }
}
