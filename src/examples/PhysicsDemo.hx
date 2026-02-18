package examples;

import recharge.midlife.base.physics.World;
import recharge.midlife.base.physics.GameObject;
import recharge.midlife.base.Game;
import recharge.midlife.base.graphics.Renderer;
import recharge.midlife.base.graphics.Shapes;
import recharge.midlife.base.graphics.Mesh;
import recharge.midlife.base.graphics.MarchingCubeMesh;
import recharge.midlife.base.sdf.SDF;

class PhysicsDemo extends World {
  @:keep
  static var registry = recharge.midlife.base.NodeFactory.register(PhysicsDemo);

  var Ball:GameObject;
  var Surface:GameObject;
  var Surface2:GameObject;
  var lightId:Int;
  static var BallMesh: Mesh = new MarchingCubeMesh(new SphereSDF(0.5));

  static var cube:Mesh = new Cube();

  public function new(name:String, ?params:Dynamic) {
    super(name, params);
    gravity = vec3(0, -9.81, 0);
    Ball = new GameObject("Ball", {position: vec3(0.25, 5, 10)});
    Surface = new GameObject("Surface",
      {position: vec3(0, 0, 10), scale: vec3(1), isStatic: true});

    Surface2 = new GameObject("Surface",
      {position: vec3(6, 0, 10), scale: vec3(1), isStatic: true});
  }

  public override function init() {
    super.init();

    Ball.shape = new SphereSDF(0.5);
    addChild(Ball);
    Surface.shape = new SphereSDF(0.5);
    addChild(Surface);

    Surface2.shape = new SphereSDF(0.5);
    addChild(Surface2);
  }

  public override function draw() {
    lightId = Game.getInstance()
      .getScene()
      .lights.setLight(vec4(0.5, 1, -2, 1), vec4(1, 1, 1, 3), lightId);

    var renderer:Renderer = Game.getInstance().getRenderer();
    renderer.setBackgroundColor(vec3(0.0, 0.1, 0.0));

    renderer.queueMesh(BallMesh, Ball.position + vec3(0, 0, 0), Ball.scale, Ball.rotation);
    renderer.queueMesh(BallMesh, Surface.position + vec3(0, 0, 0), Surface.scale, Surface.rotation);
    renderer.queueMesh(BallMesh, Surface2.position + vec3(0, 0, 0), Surface2.scale, Surface2.rotation);

    super.draw();
  }
}
