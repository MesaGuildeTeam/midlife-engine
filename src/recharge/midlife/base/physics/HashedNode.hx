package recharge.midlife.base.physics;

import recharge.midlife.base.Node;
import recharge.midlife.base.Game;

/*
 * @brief A node that organizes its childeren based on a grouping function instead
 * of its name.
 *
 * Although the architecture is generalized, this class is used to accelerate
 * the physics detections in the world node.
 */
 class HashedNode extends Node {
   var _hashFunction:Node->Array<String>; // now returns multiple keys
   var _hashedChildren:Map<String, Array<Node>>;
   var _nodeKeys:Map<Node, Array<String>>; // tracks which buckets each node is in

   public function getHashKeys():Iterator<String> {
     return _hashedChildren.keys();
   }

   public function getChildrenHash(hash:String):Array<Node> {
     return _hashedChildren[hash];
   }

   public function new(name:String, ?params:Dynamic) {
     super(name, params);

     _hashedChildren = new Map();
     _nodeKeys = new Map();

     _hashFunction = (node:Node) -> {
       if (!Std.isOfType(node, GameObject))
         return ["GenericNode"];

       var go:GameObject = cast(node, GameObject);

       if (go.shape == null)
         return ["GenericNode"];

      var cellSize:Int = 8;

       // Get AABB in local space, offset by world position
       var topLeft     = go.shape.getTopLeft()     + go.position;
       var bottomRight = go.shape.getBottomRight() + go.position;

       var minCX:Int = Math.floor(topLeft.x     / cellSize);
       var maxCX:Int = Math.floor(bottomRight.x / cellSize);
       var minCZ:Int = Math.floor(topLeft.z     / cellSize);
       var maxCZ:Int = Math.floor(bottomRight.z / cellSize);

       var keys:Array<String> = [];
       for (cx in minCX...maxCX + 1)
         for (cz in minCZ...maxCZ + 1)
           keys.push('${cx}_${cz}');

       return keys;
     };

     if (params != null)
       if (params.hashFunction != null)
         _hashFunction = params.hashFunction;
   }

   public override function addChild(child:Node):Node {
     var keys = _hashFunction(child);
     _nodeKeys[child] = keys;

     for (key in keys) {
       if (!_hashedChildren.exists(key))
         _hashedChildren[key] = [];
       if (_hashedChildren[key].indexOf(child) == -1)
         _hashedChildren[key].push(child);
     }

     return super.addChild(child);
   }

   public override function removeChild(obj:Node):Void {
     _removeFromBuckets(obj);
     _nodeKeys.remove(obj);
     super.removeChild(obj);
   }

   function _removeFromBuckets(obj:Node):Void {
     var keys = _nodeKeys[obj];
     if (keys == null) return;
     for (key in keys) {
       var bucket = _hashedChildren[key];
       if (bucket != null) {
         var i = bucket.indexOf(obj);
         if (i != -1) bucket.splice(i, 1);
       }
     }
   }

   public override function update(dt:Float):Void {
     for (node in _nodeKeys.keys()) {
       if (!node.enabled) continue;
       node.update(dt);

       var oldKeys = _nodeKeys[node];
       var newKeys = _hashFunction(node);

       // Only rehash if the occupied cell set actually changed
       if (!_keysMatch(oldKeys, newKeys)) {
         _removeFromBuckets(node);
         _nodeKeys[node] = newKeys;
         for (key in newKeys) {
           if (!_hashedChildren.exists(key))
             _hashedChildren[key] = [];
           _hashedChildren[key].push(node);
         }
       }
     }
   }

   function _keysMatch(a:Array<String>, b:Array<String>):Bool {
     if (a.length != b.length) return false;
     for (k in a)
       if (b.indexOf(k) == -1) return false;
     return true;
   }

   // Returns all unique candidates that share any bucket with the given node
   public function getCandidates(node:Node):Array<Node> {
     var seen = new Map<Node, Bool>();
     var results:Array<Node> = [];
     var keys = _nodeKeys[node];
     if (keys == null) return results;

     for (key in keys)
       for (candidate in _hashedChildren[key])
         if (candidate != node && !seen.exists(candidate)) {
           seen[candidate] = true;
           results.push(candidate);
         }

     return results;
   }
 }
