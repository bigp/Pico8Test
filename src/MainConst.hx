package;

/**
 * ...
 * @author Pierre Chamberlain
 */

@:native("")
@:publicFields
class MainConst 
{
	static var MOTION_SCALE:Fixed = 2;
	static var SFX_SHOOT = 5;
	static var SPRITE_PLAYER:Int = 1;
	static var SPRITE_CURSOR:Int = 7;
	static var AIM_CHARGE_MAX:Fixed = 10;
	static var AIM_RATE_MIN:Fixed = 10;
	static var SPEED_MIN:Int = 1;
	static var SPEED_MAX:Int = 3;
	static var HEAL_AMOUNT:Int = 20;
	static var SIZE:Int = 16;
	static var MAX_X:Int = 256 - SIZE;
	static var MAX_Y:Int = 250 - SIZE;
	static var ARROW_COUNT:Int = 2;
	static var ARROW_TIME:Fixed = 20;
	static var ARROW_SPEED_MIN:Fixed = 2;
	static var ARROW_OFFSET_FROM:Int = 4;
	static var ARROW_OFFSET_TO:Int = 4;
	static var ARROW_PRECISION:Fixed = 30;
	static var ARROW_DAMAGE:Fixed = 5;
	
	static var COLOR_GREEN_DARK = 3;
	static var COLOR_GREEN_LITE = 11;
	static var COLOR_BLUE_DARK = 1;
	static var COLOR_BLUE_LITE = 12;
}