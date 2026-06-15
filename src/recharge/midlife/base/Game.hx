package recharge.midlife.base;

#if hl
typedef Game = recharge.midlife.hl.GameHL;
#elseif js
typedef Game = recharge.midlife.js.GameJS;
#else
typedef Game = GameAbstract;
#end
