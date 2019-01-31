package com.pico8test;

import Pico.*;
import com.pico8test.GameUtils;
/**
 * ...
 * @author Pierre Chamberlain
 */

@:publicFields
class Player 
{
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
	
	var id = 0;
	var x = 128;
	var y = 128;
	var xFinal = 0;
	var yFinal = 0;
	var speed = 1;
	var dirX = 0;
	var dirY = 0;
	var walkCounter:Fixed = 0;
	var aimCounter:Fixed = 0;
	var spriteIndex:Int = SPRITE_PLAYER;
	var useMouse:Bool = false;
	var isAiming:Bool = false;
	var wasAiming:Bool = false;
	var aimCharge:Fixed = 0;
	var aimX:Int = 0;
	var aimY:Int = 0;
	var numHeals:Int = 3;
	var health:Fixed = 100;
	var healthTemp:Fixed = 100;
	var isShooting:Bool = false;
	
	function new(id:Int, useMouse:Bool=false) {
		this.id = id;
		this.useMouse = useMouse;
	}
	
	function update() {
		if (useMouse) updateMouse();
		
		healOverTime();
		checkInputs();
	}
	
	function healOverTime() {
		if (health >= healthTemp) return;
		
		health += 1;
	}
	
	function updateMouse() {
		if (!GameUtils.mouseDown(1) && isShooting) {
			isShooting = false;
		}
		
		if(!isShooting) {
			isAiming = GameUtils.mouseDown(1);
		}
		
		if (wasAiming != isAiming) {
			if (isAiming) sfx(0);
			else sfx(1);
		}
		
		wasAiming = isAiming;
		
		if (GameUtils.mousePressed(0)) {
			if (isAiming) shoot();
			else if(!isShooting) healUp();
		}
	}
	
	function healUp() 
	{
		if (numHeals == 0) {
			sfx(2);
			return;
		}
		
		if (health >= 100) {
			sfx(3);
			return;
		}
		
		numHeals -= 1;
		
		healthTemp = min(100, healthTemp + HEAL_AMOUNT);
		health = min(healthTemp, health + HEAL_AMOUNT / 2);
		
		sfx(4);
	}
	
	function shoot() {
		sfx(SFX_SHOOT + GameUtils.frame % 3);
		isAiming = false;
		isShooting = true;
	}
	
	function checkInputs() {
		dirX = 0;
		dirY = 0;
		
		if (isAiming) speed = SPEED_MIN;
		else speed = SPEED_MAX;
		
		if (btn(0, id)) dirX -= 1;
		if (btn(1, id)) dirX += 1;
		if (btn(2, id)) dirY -= 1;
		if (btn(3, id)) dirY += 1;
		
		x += dirX * speed;
		y += dirY * speed;
		
		if (x < 0) {
			x = 0;
			dirX = 0;
		}
		if (x > MAX_X) {
			x = MAX_X;
			dirX = 0;
		}
		if (y < 0) {
			y = 0;
			dirY = 0;
		}
		if (y > MAX_Y) {
			y = MAX_Y;
			dirY = 0;
		}
		
		if (dirX == 0 && dirY == 0) {
			walkCounter = 0;
		} else {
			walkCounter += speed;
		}
		
		if (isAiming) {
			aimCharge = min(AIM_CHARGE_MAX, aimCharge + 1);
			aimCounter += 1;
			aimCounter %= (AIM_CHARGE_MAX - aimCharge) + 2;
		} else {
			aimCharge = 0;
			aimCounter = 0;
		}
		
		xFinal = x >> 1;
		yFinal = y >> 1;
	}
	
	function getWalkCounter():Fixed {
		return (walkCounter / SPEED_MAX) % 3;
	}
	
	function draw() {
		if (isAiming) {
			if (aimCounter==0) pal(8, 9);
			drawSprite(spriteIndex + 3 + getWalkCounter());
		} else {
			drawSprite(spriteIndex + getWalkCounter());
		}
		
		pal();
		
		if (useMouse) {
			var offset:Fixed = 0;
			if (isAiming) offset = 1 + ((GameUtils.frame/1.2) % 3);
			
			spr(SPRITE_CURSOR + offset, GameUtils.mouseX, GameUtils.mouseY);
		}
		
		
		drawHealthBar();
	}
	
	function drawHealthBar() 
	{
		var barColor:Int = 11;
		if (health < 10) barColor = 8;
		line(xFinal, yFinal + 9, xFinal + (health/15), yFinal + 9, barColor);
	}
	
	function drawSprite(id:Fixed) {
		spr(id, xFinal, yFinal);
	}
	
}