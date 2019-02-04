package;

import Pico.*;
import screens.IScreen;
/**
 * ...
 * @author Pierre Chamberlain
 */
@:native("UTILS")
class MainUtils 
{
	static var _screen:IScreen;
	static var _mouseTimes = [-1,-1,-1];
	
	public static var mouseX:Fixed = 0;
	public static var mouseY:Fixed = 0;
	public static var mouseButtonMask:Int = 0;
	public static var frame = 0;
	public static var isFrameEven:Bool = false;
	
	public static function update() {
		frame += 1;
		isFrameEven = (frame % 2) == 0;
		
		updateMouseStatus();
	}
	
	private static function updateMouseStatus() {
		//Update the mouse details:
		poke(0x5F2D, 1);
		mouseX = stat(32);
		mouseY = stat(33);
		mouseButtonMask = cast( stat(34), Int );
		
		updateMouseButtonIndex(mouseButtonMask, 1, 0);
		updateMouseButtonIndex(mouseButtonMask, 2, 1);
		updateMouseButtonIndex(mouseButtonMask, 4, 2);
	}
	
	private static function updateMouseButtonIndex(stat:Fixed, maskId:Int, i:Int) {
		if ((mouseButtonMask & maskId) == 0) {
			if (_mouseTimes[i] >= 0) {
				_mouseTimes[i] = -frame;
			}
			return;
		}
		
		if (_mouseTimes[i] > 0) return;
		
		_mouseTimes[i] = frame;
	}
	
	public static function mouseDown(id:Int):Bool {
		return _mouseTimes[id] > 0;
	}
	
	public static function mousePressed(id:Int):Bool {
		return _mouseTimes[id] == frame;
	}
	
	public static function mouseReleased(id:Int):Bool {
		return _mouseTimes[id] == -frame;
	}
	
	public static function dist(x1:Fixed, y1:Fixed, x2:Fixed, y2:Fixed):Fixed {
		var xDiff = x2 - x1;
		var yDiff = y2 - y1;
		return xDiff * xDiff + yDiff * yDiff;
	}
	
	//////////////////////////////////////////
	
	public static function screenChange(scr:IScreen) {
		if (_screen!=null) {
			_screen.destroy();
		}
		
		_screen = scr;
		
		if (_screen==null) return;
		
		_screen.init();
	}
	
	public static function screenUpdate() {
		if (_screen==null) return;
		
		_screen.update();
	}
	
	public static function screenDraw() {
		if (_screen==null) return;
		
		_screen.draw();
	}
}