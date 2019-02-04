package;

/**
 * ...
 * @author Pierre Chamberlain
 */

@:native("CST")
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
	static var ARROW_PRECISION:Fixed = 20;
	static var ARROW_DAMAGE:Fixed = 5;
	
	static var COLOR_00_BLACK = 0;
	static var COLOR_01_BLUE_DARK = 1;
	static var COLOR_02_PURPLE = 2;
	static var COLOR_03_GREEN_DARK = 3;
	static var COLOR_04_BROWN = 4;
	static var COLOR_05_GRAY_DARK = 5;
	static var COLOR_06_GRAY_LITE = 6;
	static var COLOR_07_WHITE = 7;
	static var COLOR_08_RED = 8;
	static var COLOR_09_ORANGE = 9;
	static var COLOR_10_YELLOW = 10;
	static var COLOR_11_GREEN_LITE = 11;
	static var COLOR_12_BLUE_SKY = 12;
	static var COLOR_13_BLUE_GRAY = 13;
	static var COLOR_14_PINK = 14;
	static var COLOR_15_BEIGE_SKIN = 15;
}