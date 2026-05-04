/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package recharge.midlife.base;

import recharge.midlife.base.Scene;
import recharge.midlife.base.input.InputMode;
import recharge.midlife.base.input.InputManager;
import recharge.midlife.base.graphics.Renderer;
import recharge.midlife.base.Node;

class GameAbstract {
  var _currentScene:Scene;
  var _loadedScenes:Map<String, Scene>;
  var _renderer:Renderer;
  var _graphicsReady:Bool = false;

  var _inputMode:InputMode;

  static var _windowDimensions:Vec2 = vec2(640, 480);
  static var _instance:GameAbstract;

  /**
   * The default constructor, creates a new game instance with an initial scene
   * @param initialScene
   */
  public function new() {
    if (_instance != null)
      throw("Game instance already exists!");

    _loadedScenes = new Map();

    // Initialize Scene
    var className = haxe.macro.Compiler.getDefine("engine_initialscene");
    className = className != null ? className : "recharge.midlife.base.Node";
    var initialScene:Scene = Type.createInstance(Type.resolveClass(className),
      ["InitialScene"]);
    addScene(initialScene, initialScene.name);
    switchScene(initialScene.name);

    _instance = this;
  }

  @:keep
  public static function getInstance():GameAbstract {
    if (_instance == null)
      _instance = new Game();

    return _instance;
  }

  public function getRenderer():Renderer {
    if (_renderer == null)
      _renderer = new Renderer();
    return _renderer;
  }

  public function getScene():Scene {
    return _currentScene;
  }

  public function addScene(scene:Scene, name:String):Void {
    if (_loadedScenes.exists(name))
      trace("WARNING: Scene with name "
        + name
        + " already exists. Overwriting...");

    _loadedScenes[name] = scene;
    scene.init();
  }

  public function switchScene(name:String):Void {
    if (!_loadedScenes.exists(name))
      throw("Scene with name " + name + " does not exist");

    _currentScene = _loadedScenes[name];
  }

  public function unloadScene(name:String):Void {
    if (!_loadedScenes.exists(name))
      throw("Scene with name " + name + " does not exist");

    _loadedScenes.remove(name);
  }

  public function drawScene():Void {
    _currentScene.draw();
  }

  public function updateScene(dt:Float):Void {
    InputManager.getInstance().update();
    _currentScene.update(dt);
  }

  // Window Dimension Retrieval
  public var dimensions(get, set):Vec2;

  public function get_dimensions():Vec2 {
    if (_windowDimensions.x >= 640.0 && _windowDimensions.y >= 480.0) {
      return _windowDimensions / 2;
    }
    return _windowDimensions;
  }

  function set_dimensions(value:Vec2):Vec2 {
    _windowDimensions = value;
    trace("DEBUG: Window resized to " + _windowDimensions);
    return _windowDimensions;
  }

  public var inputMode(get, never):InputMode;

  function get_inputMode():InputMode {
    return _inputMode;
  }

  @:keep
  public function run():Void {
    throw("This is an abstract Game class. Please use a platform-specific implementation.");
  }
}
