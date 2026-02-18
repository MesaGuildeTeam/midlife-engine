package recharge.midlife.base;

#if hl
typedef Game = recharge.midlife.hl.GameHL;
#elseif lua
typedef Game = recharge.midlife.love.GameLove;
#else
typedef Game = GameAbstract;
#end
