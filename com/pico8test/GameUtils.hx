package com.pico8test;

import Pico.*;
/**
 * ...
 * @author Pierre Chamberlain
 */
@:publicFields
class GameUtils 
{
	static var mouseX:Fixed = 0;
	static var mouseY:Fixed = 0;
	static var mouseButtonMask:Int = 0;
	static var mouseTimes = [-1,-1,-1];
	static var frame = 0;
	static var isFrameEven:Bool = false;
	
	static function update() {
		frame += 1;
		isFrameEven = (frame % 2) == 0;
		
		updateMouseStatus();
		
		
	}
	
	private static function updateMouseStatus() {
		//Update the mouse details:
		poke(0x5F2D, 1);
		mouseX = stat(32);
		mouseY = stat(33);
		mouseButtonMask = cast( stat(34), Int);
		
		updateMouseButtonIndex(mouseButtonMask, 1, 0);
		updateMouseButtonIndex(mouseButtonMask, 2, 1);
		updateMouseButtonIndex(mouseButtonMask, 4, 2);
	}
	
	private static function updateMouseButtonIndex(stat:Fixed, maskId:Int, i:Int) {
		if ((mouseButtonMask & maskId) == 0) {
			if (mouseTimes[i] >= 0) {
				mouseTimes[i] = -frame;
			}
			return;
		}
		
		if (mouseTimes[i] > 0) return;
		
		mouseTimes[i] = frame;
	}
	
	static function mouseDown(id:Int):Bool {
		return mouseTimes[id] > 0;
	}
	
	static function mousePressed(id:Int):Bool {
		return mouseTimes[id] == frame;
	}
	
	static function mouseReleased(id:Int):Bool {
		return mouseTimes[id] == -frame;
	}
}