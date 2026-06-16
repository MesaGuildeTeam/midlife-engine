package recharge.midlife.base;

#if sys
import sys.FileSystem;

import sys.io.File;
#end

import haxe.io.Bytes;

import haxe.Resource;

enum FileMode {
  READ;
  WRITE;
}

enum FileType {
  EMBEDDED;
  ASSET;
  EXTERNAL;
}

class FileStream {
  private var _mode:FileMode;
  private var _path:String;
  private var _type:FileType;

  private var _httpData:haxe.Http;
  public var isLoaded:Bool;

  public function new(mode:FileMode, ?path:String) {
    _mode = mode;
    isLoaded = false;
    _path = path != null ? path : "";
    if (path != null) {
      open(path);
    }
  }

  public function open(path:String):Bool {
    // Check if file is embedded
    var embedded = Resource.getBytes(path);
    if (embedded != null) {
      if (_mode == FileMode.WRITE)
        throw "Cannot open embedded file for writing: " + path;

      _type = FileType.EMBEDDED;
      _path = path;
      isLoaded = true;

      return true;
    }

    // Find file in local assets folder
    // If compiler target does not support sys, we will use HTTP requests instead
    // TODO:
    // - Implement alternative systems for non-sys targets
    #if sys
    if (FileSystem.exists("./" + path)) {
      if (_mode == FileMode.WRITE)
        throw "Cannot open asset file for writing: " + path;

      _type = FileType.ASSET;
      _path = path;
      isLoaded = true;
      return true;
    }
    #else
    var request = new haxe.Http("/" + path);
    trace("Sending GET request to", request.url);
    request.async = true;

    request.onBytes = function(_:Dynamic) {
      _type = FileType.ASSET;
      _path = path;
      _httpData = request;
      isLoaded = true;
    }

    request.request(false);
    #end

    return false;
  }

  public var fileName(get, null):String;

  private function get_fileName():String {
    var name:String = _path.substring(_path.lastIndexOf("/") + 1);
    return name;
  }

  public var fileDirectory(get, null):String;

  private function get_fileDirectory():String {
    // TODO: Implement path resolution logic

    var directory:String = _path.substring(0, _path.lastIndexOf("/"));
    return directory;
  }

  public function getDataString():String {
    if (_type == FileType.EMBEDDED)
      return Resource.getString(_path);

    #if sys
    if (_type == FileType.ASSET)
      return File.getContent("./" + _path);
    #else
    if (_type == FileType.ASSET)
      return _httpData.responseData;
    #end

    throw "ERROR: No file has been loaded into FileStream yet";
  }

  public function getDataBytes():Bytes {
    if (_type == FileType.EMBEDDED)
      return Resource.getBytes(_path);

    #if sys
    if (_type == FileType.ASSET)
      return File.getBytes("./" + _path);

    #else
    if (_type == FileType.ASSET)
      return _httpData.responseBytes;
    #end


    throw "ERROR: No file has been loaded into FileStream yet";
  }
}
