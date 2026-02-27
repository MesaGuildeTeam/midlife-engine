import utest.Runner;

import utest.ui.Report;

class Tests {
  public static function main():Void {
    var testRunner = new Runner();
    testRunner.addCase(new tests.NodeTest());
    testRunner.addCase(new tests.UtilsTests());
    testRunner.addCase(new tests.InputTest());
    testRunner.addCase(new tests.PhysicsObjectTest());
    testRunner.addCase(new tests.SDFTest());

    #if carpengine_coverage
    testRunner.run();
    instrument.coverage.Coverage.endCoverage();
    #else
    Report.create(testRunner);
    testRunner.run();
    #end
  }
}
