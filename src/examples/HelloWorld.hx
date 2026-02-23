package examples;

import recharge.midlife.base.sdf.SDF;
import recharge.midlife.base.graphics.SurfaceNet;
import recharge.midlife.base.graphics.Mesh;
import recharge.midlife.base.graphics.Shapes;
import recharge.midlife.base.graphics.Renderer;
import recharge.midlife.base.graphics.Texture;
import recharge.midlife.base.Game;
import recharge.midlife.base.Node;
import recharge.midlife.base.NodeFactory;

class HelloWorld extends Node {
  @:keep
  static var registry = NodeFactory.register(HelloWorld);

  var time:Float = 0.0;
  var mesh:Mesh = new SurfaceNet(new SDFSubtraction([new SphereSDF(1), new SphereSDF(1,
    vec3(0.5))]));
  // var mesh:Mesh = new Cube();
  var texture:Texture = new Texture("assets/placeholder.png");

  var lightId:Null<Int>;
  var lightId2:Null<Int>;

  public function new(name:String, ?params:Dynamic) {
    super(name, params);
  }

  public override function draw():Void {
    lightId = Game.getInstance()
      .getScene()
      .lights.setLight(vec4(0, 1, -1, 0), vec4(1, 1, 1, 1), lightId);

    // lightId2 = Game.getInstance()
    //   .getScene()
    //   .lights.setLight(vec4(-0.5, -1, -2, 0), vec4(0, 1, 1, 3), lightId2);

    Game.getInstance().getRenderer().pushTexture(texture);
    Game.getInstance()
      .getRenderer()
      .queueMesh(mesh, vec3(0, 0, 10), vec3(1), vec3(0, time, 0));

    // Game.getInstance().getRenderer().queueMesh(mesh2, vec3(0, -2, 10), vec3(1), vec3(0));

    super.draw();
  }

  public override function update(dt:Float):Void {
    super.update(dt);
    time += dt * 8;
  }
}
