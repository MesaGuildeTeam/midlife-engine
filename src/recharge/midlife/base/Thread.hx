package recharge.midlife.base;

import haxe.Constraints.Function;

/**
 * Drop in replacement for sys.thread.Lok
 *
 * Bypasses if sys is not available
 */
class Lock {
  #if sys
  var _lock:sys.thread.Lock;
  #end

  public function new() {
    #if sys
    _lock = new sys.thread.Lock();
    #end
  }

  public function wait() {
    #if sys
    _lock.wait();
    #end
  }

  public function release() {
    #if sys
    _lock.release();
    #end
  }
}

/**
   * @brief a drop-in wrapper for sys.thread.Thread
   *
   * Treats the function as a regular function if sys is not available
   */
class Thread {
  /**
   * @brief a drop-in wrapper for sys.thread.Thread.create
   *
   * Treats the function as a regular function if sys is not available
   */
  public static inline function create(f:Function):Void {
    #if sys
    sys.thread.Thread.create(function() {f();});
    #else
    f();
    #end
  }
}
