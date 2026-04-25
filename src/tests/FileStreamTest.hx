package tests;

import utest.Assert;

import recharge.midlife.base.FileStream;

class FileStreamTest extends utest.Test {
    
    public function testGetFunctions(): Void {
        var testStream:FileStream = new FileStream(FileMode.READ, "./testDirectory/test.txt");
        
        var name:String = testStream.fileName;
        var path:String = testStream.fileDirectory;
        
        Assert.equals("test.txt", name);
        Assert.equals("./testDirectory", path);
    }
}