package;

import Pico.*;
import MainUtils;

/**
 * ...
 * @author Pierre Chamberlain
 */

@:native("P")
@:publicFields
class Player {

	var _x:Fixed = 0;
	var _y:Fixed = 0;
	var x:Fixed = 0;
	var y:Fixed = 0;
	var dirX:Int = 0;
	var dirY:Int = 0;
	var id:Int = 0;
	var speed:Int = 0;
	var walkCounter:Fixed = 0;
	var aimCounter:Fixed = 0;
	var spriteIndex:Int = 0;
	var useMouse:Bool;
	var isAiming:Bool;
	var wasAiming:Bool;
	var aimCharge:Fixed = 0;
	var aimX:Int = 0;
	var aimY:Int = 0;
	var numHeals:Int = 0;
	var health:Fixed = 0;
	var healthTemp:Fixed = 0;
	var isShooting:Bool;
	var arrows:Array<TArrow>;
	var arrowID:Int = 0;
	var arrowSpeed:Fixed = 0.3;
	var isAlive = true;
	var isInit = false;

	function new(id:Int) {
		this.id = id;

		_x = 128;
		_y = 128;
		x = 0;
		y = 0;
		walkCounter = 0;
		aimCounter = 0;
		spriteIndex = MainConst.SPRITE_PLAYER;
		isAiming = false;
		wasAiming = false;
		aimCharge = 0;
		aimX = 0;
		aimY = 0;
		numHeals = 3;
		health = 100;
		healthTemp = 100;
		isShooting = false;

		arrowID = 0;
		arrows = [];
		for(a in 0...MainConst.ARROW_COUNT) {
			arrows[a+1] = makeArrow();
		}
	}

	function makeArrow():TArrow {
		return {x:0, y:0, velX:0, velY:0, lifetime:0};
	}

	function update() {
		if (!isInit) {
			_x = x * MainConst.MOTION_SCALE;
			_y = y * MainConst.MOTION_SCALE;
			isInit = true;
		}
		healOverTime();
		updateMotion();
		forEach(arrows, updateArrow);
	}

	function draw() {
		if (!isAlive) return;
		
		if (isAiming) {
			if (aimCounter==0) pal(8, 9);
			drawSprite(spriteIndex + 3 + getWalkCounter());
		} else {
			drawSprite(spriteIndex + getWalkCounter());
		}

		pal();

		drawHealthBar();
		
		forEach(arrows, drawArrow);
	}

	//////////////////////////////////////////////////////

	function healOverTime() {
		if (health >= healthTemp) return;

		health += 1;
	}

	function updateMotion() {
		_x += dirX * speed;
		_y += dirY * speed;

		if (_x < 0) {
			_x = 0;
			dirX = 0;
		}

		if (_x > MainConst.MAX_X) {
			_x = MainConst.MAX_X;
			dirX = 0;
		}

		if (_y < 0) {
			_y = 0;
			dirY = 0;
		}

		if (_y > MainConst.MAX_Y) {
			_y = MainConst.MAX_Y;
			dirY = 0;
		}

		if (dirX == 0 && dirY == 0) {
			walkCounter = 0;
		} else {
			walkCounter += speed;
		}

		if (isAiming) {
			aimCharge = min(MainConst.AIM_CHARGE_MAX, aimCharge + 1);
			aimCounter += 1;
			aimCounter %= (MainConst.AIM_CHARGE_MAX - aimCharge) + 2;
		} else {
			aimCharge = 0;
			aimCounter = 0;
		}

		x = _x / MainConst.MOTION_SCALE;
		y = _y / MainConst.MOTION_SCALE;
	}

	function updateMouse() {
		if (!MainUtils.mouseDown(1) && isShooting) {
			isShooting = false;
		}

		if (!isShooting) {
			isAiming = MainUtils.mouseDown(1);
		}

		if (wasAiming != isAiming) {
			if (isAiming) sfx(0);
			else sfx(1);
		}

		wasAiming = isAiming;

		if (MainUtils.mousePressed(0)) {
			shoot();
			//if (isAiming) shoot();
			//else if (!isShooting) healUp();
		}
	}

	function healUp() {
		if (numHeals == 0) {
			sfx(2);
			return;
		}

		if (health >= 100) {
			sfx(3);
			return;
		}

		numHeals -= 1;

		healthTemp = min(100, healthTemp + MainConst.HEAL_AMOUNT);
		health = min(healthTemp, health + MainConst.HEAL_AMOUNT / 2);

		sfx(4);
	}

	function shoot() {
		isAiming = false;
		isShooting = true;
		
		var offset = MainConst.ARROW_OFFSET_FROM + MainConst.ARROW_OFFSET_TO;
		var angle:Fixed = atan2(MainUtils.mouseX - x, MainUtils.mouseY - y);
		var arrow:TArrow = arrows[arrowID+1];
		
		if (arrow.lifetime > 0) {
			sfx(3);
			return;
		}
		
		var speed = MainConst.ARROW_SPEED_MIN + arrowSpeed * aimCharge;
		
		arrow.x = x + MainConst.ARROW_OFFSET_FROM;
		arrow.y = y + MainConst.ARROW_OFFSET_FROM;
		arrow.velX = cos(angle) * speed;
		arrow.velY = sin(angle) * speed;
		arrow.lifetime = MainConst.ARROW_TIME;
		arrowID = (arrowID + 1) % MainConst.ARROW_COUNT;
		
		sfx(MainConst.SFX_SHOOT + MainUtils.frame % 3);
	}

	function checkInputs() {
		updateMouse();

		dirX = 0;
		dirY = 0;

		if (isAiming) speed = MainConst.SPEED_MIN;
		else speed = MainConst.SPEED_MAX;

		if (btn(0, id)) dirX -= 1;
		if (btn(1, id)) dirX += 1;
		if (btn(2, id)) dirY -= 1;
		if (btn(3, id)) dirY += 1;
	}

	function getWalkCounter():Fixed {
		return (walkCounter / MainConst.SPEED_MAX) % 3;
	}

	function drawHealthBar() {
		var barColor:Int = 11;
		if (health < 10) barColor = 8;
		line(x, y + 9, x + (health/15), y + 9, barColor);
	}

	function drawSprite(id:Fixed) {
		spr(id, x, y);
	}

	function drawMouse() {
		var offset:Fixed = 0;
		if (isAiming) {
			offset = 1 + ((MainUtils.frame/1.2) % 3);
		}

		spr(MainConst.SPRITE_CURSOR + offset, MainUtils.mouseX, MainUtils.mouseY);
	}
	
	//////////////////////////////////////
	
	function updateArrow(arrow:TArrow) {
		if (arrow.lifetime <= 0) return;
			
		arrow.lifetime -= 1;
		
		arrow.x += arrow.velX;
		arrow.y += arrow.velY;
		
		forEach( Main.players, function(player:Player) {
			if (!player.isAlive || player.id == this.id) {
				return;
			}
			
			var distSqr = MainUtils.dist(
			  arrow.x, arrow.y,
			  player.x + MainConst.ARROW_OFFSET_FROM, player.y + MainConst.ARROW_OFFSET_FROM
			);
			
			if (distSqr < MainConst.ARROW_PRECISION) {
				sfx(2);
				arrow.lifetime = -1;
				player.health -= MainConst.ARROW_DAMAGE * (abs(arrow.velX) + abs(arrow.velY));
				if (player.health < 0) {
					player.health = 0;
					player.isAlive = false;
					sfx(9 + flr(rand(3)));
				}
				player.healthTemp = player.health;
			}
		});
		
		if (arrow.lifetime == 0) {
			sfx(8);
		}
	}
	
	function drawArrow(arrow:TArrow) {
		if (arrow.lifetime <= 0) return;
		
		pset(arrow.x, arrow.y, 7);
	}
}

typedef TArrow = {
	x:Fixed,
	y:Fixed,
	velX:Fixed,
	velY:Fixed,
	lifetime:Fixed,
}