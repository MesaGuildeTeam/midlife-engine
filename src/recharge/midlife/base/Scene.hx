package recharge.midlife.base;

import recharge.midlife.base.Node;
import recharge.midlife.base.graphics.LightArray;

/**
 * A contaienr class that stores the scene's information
 * 
 * You would use this to manage information such as lights and the camera
 * position of the scene.
 * 
 * if a camera is not specified, then the scene's camera transformation will
 * just use a identity matrix. Otherwise, the scene will use the transformation
 * specified by the camera.
 */
class Scene extends Node {
  public var lights:LightArray;

  /**
   * A public reference to the camera position of the scene. If this is null
   * then the scene will just use an identity transformation as the camera.
   * You can set this to any node
   */
  public var camera:Node;

  public function new(name:String = "Scene", ?params:Dynamic) {
    super(name, params);

    // Initialize scene lights
    lights = new LightArray();

    // If a specific scene file is mentioned in params, add all the nodes to this scene
    if (params == null)
      return;
    if (params.sceneFile == null)
      return;

    // TODO: Implement scene file loading
  }
}
