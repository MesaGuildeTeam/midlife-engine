import utest.Runner;

import utest.ui.Report;

class Tests {
  public static function main():Void {
    var testRunner = new Runner();
    testRunner.addCase(new tests.AnimatedTest());
    testRunner.addCase(new tests.FileStreamTest());
    testRunner.addCase(new tests.InputTest());
    testRunner.addCase(new tests.InputModeTest());
    testRunner.addCase(new tests.LightArrayTest());
    testRunner.addCase(new tests.MeshTest());
    testRunner.addCase(new tests.NodeTest());
    testRunner.addCase(new tests.PhysicsObjectTest());
    testRunner.addCase(new tests.SceneTest());
    testRunner.addCase(new tests.SDFTest());
    testRunner.addCase(new tests.UIButtonTest());
    testRunner.addCase(new tests.UILabelTest());
    testRunner.addCase(new tests.UIElementTest());
    testRunner.addCase(new tests.UtilsTests());
    testRunner.addCase(new tests.WorldTest());

    #if carpengine_coverage
    testRunner.run();
    instrument.coverage.Coverage.endCoverage();
    #else
    Report.create(testRunner);
    testRunner.run();
    #end
  }
}
