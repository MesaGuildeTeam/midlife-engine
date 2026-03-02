package tests;

import utest.Assert;

import recharge.midlife.base.sdf.SDF;

class SDFTest extends utest.Test {
  public function testSphereAndGradient() {
    var sdf = new SphereSDF(1);

    Assert.equals(sdf.computeDistance(vec3(0.4, 0, 0)) <= 0, true);
    Assert.equals(sdf.computeDistance(vec3(0.6, 0, 0)) >= 0, true);

    Assert.equals(sdf.computeDistance(vec3(-0.4, 0, 0)) <= 0, true);
    Assert.equals(sdf.computeDistance(vec3(-0.6, 0, 0)) >= 0, true);

    var normalPos = sdf.getNormal(vec3(0.5));
    var normalNeg = sdf.getNormal(vec3(-0.5));

    Assert.equals(normalPos.x > 0, true);
    Assert.equals(normalNeg.x < 0, true);
  }

  public function testBoxAndGradient() {
    var boxSDF = new BoxSDF(vec3(1));

    Assert.equals(boxSDF.computeDistance(vec3(0.4, 0, 0)) <= 0, true);
    Assert.equals(boxSDF.computeDistance(vec3(0.6, 0, 0)) >= 0, true);

    Assert.equals(boxSDF.computeDistance(vec3(-0.4, 0, 0)) <= 0, true);
    Assert.equals(boxSDF.computeDistance(vec3(-0.6, 0, 0)) >= 0, true);

    var normalPos = boxSDF.getNormal(vec3(0.5));
    var normalNeg = boxSDF.getNormal(vec3(-0.5));

    Assert.equals(normalPos.x > 0, true);
    Assert.equals(normalNeg.x < 0, true);
  }
}
