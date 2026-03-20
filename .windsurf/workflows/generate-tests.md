---
trigger: generate-tests
description: Generate test files for classes that do not have tests yet
---

details:
  language: "haxe"
  framework: "utest"
  testsLocation: "src/tests/"
  sourceFolder: "src/recharge/midlife/base"
  commands:
    test: "haxe scripts/test.hxml"
    coverage: "haxe scripts/coverage.hxml"
  classPath: "src"
  minimumTests: 3
constraints:
  - "Do not write integration tests"
  - "If a class has a warning trace, do not write tests for it"
  - "Only write tests that are in the specified source folder"
  - "Ignore testing parameters that are not marked public. If it does not specify, assume it is private"
instructions:
  - "1. Find all classes in the specified source folder and see if there is a test in the tests folder"
  - "2. If there is no test, generate a test file with the same name but in src/tests/."
  - "2a. If the class is mentioned in the tests folder, do not generate a test for it."
  - "3. Use utest framework to write functional unit tests with the mentioned structure. DO NOT WRITE INTEGRATION TESTS"
  - "4. Compare the class and the test file to compare viability of tests." 
  - "4a. If any tests are not viable, only re-attempt twice. Otherwise, report the failure and move on."
  - "5. include the full test class full path in src/Tests.hx"
  - "5a. you will add the following line along with other tests: `testRunner.addCase(new tests.[TEST_CLASS]());`"
  - "5b. If you can, order the tests in alphabetical order"
  - "5c. If the test class is already included, do not include it again."
  - "6. report all the test files that were generated"
task: "Generate test files with the utest framework"
structure: |
  package tests;

  import utest.Assert;
  import recharge.midlife.base.[FILE_NAME];

  class [FILE_NAME]Test extends utest.Test {
    // optional: add setup/teardown methods and test dependencies
    public function setupClass():Void {
      // optional: initialize test dependencies
    }
    
    public function teardownClass():Void {
      // optional: clean up test resources
    }
    
    // test example structure
    public function test[BEHAVIOR_NAME]():Void {
      // arrange
      // act
      // assert
    }

    // test additional methods as needed
    public function test[BEHAVIOR_NAME]():Void {
      // arrange
      // act
      // assert
    }
  }