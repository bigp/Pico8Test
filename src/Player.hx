package;

import Pico.*;
import MainUtils;
import comp.Pos;
import screens.Screen02InGame;

/**
 * ...
 * @author Pierre Chamberlain
 */

class Player {

	public var pos:Pos;
	public var useMouse:Bool;
	public var isAlive = true;
	var walkCounter:Fixed = 0;
	var aimCounter:Fixed = 0;
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
	var isInit = false;

	public function new(id:Int) {
		pos = new Pos();
		pos._x = 128;
		pos._y = 128;
		pos.x = 0;
		pos.y = 0;
		pos.id = id;
		pos.spriteIndex = MainConst.SPRITE_PLAYER;
		
		isShooting = false;
		isAiming = false;
		wasAiming = false;
		aimCharge = 0;
		aimX = 0;
		aimY = 0;
		aimCounter = 0;
		walkCounter = 0;
		numHeals = 3;
		health = 100;
		healthTemp = 100;
		
		arrowID = 0;
		arrows = [];
		for(a in 0 ... MainConst.ARROW_COUNT) {
			arrows[a+1] = makeArrow();
		}
	}

	function makeArrow():TArrow {
		return {x:0, y:0, velX:0, velY:0, lifetime:0};
	}

	public function update() {
		if (!isAlive) return;
		if (!isInit) {
			pos._x = pos.x * MainConst.MOTION_SCALE;
			pos._y = pos.y * MainConst.MOTION_SCALE;
			isInit = true;
		}
		
		healOverTime();
		checkHealth();
		updateMotion();
		updateArrows();
	}

	public function draw() {
		if (!isAlive) return;
		
		if (useMouse) {
			pal(MainConst.COLOR_08_RED, MainConst.COLOR_14_PINK);
		}
		
		if (isAiming) {
			if (aimCounter==0) pal(MainConst.COLOR_08_RED, MainConst.COLOR_07_WHITE);
			drawSprite(pos.spriteIndex + 3 + getWalkCounter());
		} else {
			drawSprite(pos.spriteIndex + getWalkCounter());
		}

		pal();

		drawHealthBar();
		
		drawArrows();
	}

	//////////////////////////////////////////////////////

	function healOverTime() {
		if (health >= healthTemp) return;

		health += 1;
	}

	function updateMotion() {
		pos._x += pos.dirX * pos.speed;
		pos._y += pos.dirY * pos.speed;

		if (pos._x < 0) {
			pos._x = 0;
			pos.dirX = 0;
		}

		if (pos._x > MainConst.MAX_X) {
			pos._x = MainConst.MAX_X;
			pos.dirX = 0;
		}

		if (pos._y < 0) {
			pos._y = 0;
			pos.dirY = 0;
		}

		if (pos._y > MainConst.MAX_Y) {
			pos._y = MainConst.MAX_Y;
			pos.dirY = 0;
		}

		if (pos.dirX == 0 && pos.dirY == 0) {
			walkCounter = 0;
		} else {
			walkCounter += pos.speed;
		}

		if (isAiming) {
			aimCharge = min(MainConst.AIM_CHARGE_MAX, aimCharge + 1);
			aimCounter += 1;
			aimCounter %= (MainConst.AIM_CHARGE_MAX - aimCharge) + 2;
		} else {
			aimCharge = 0;
			aimCounter = 0;
		}

		pos.x = pos._x / MainConst.MOTION_SCALE;
		pos.y = pos._y / MainConst.MOTION_SCALE;
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
		var angle:Fixed = atan2(MainUtils.mouseX - pos.x, MainUtils.mouseY - pos.y);
		var arrow:TArrow = arrows[arrowID+1];
		
		if (arrow.lifetime > 0) {
			sfx(3);
			return;
		}
		
		var speed = MainConst.ARROW_SPEED_MIN + arrowSpeed * aimCharge;
		
		arrow.x = pos.x + MainConst.ARROW_OFFSET_FROM;
		arrow.y = pos.y + MainConst.ARROW_OFFSET_FROM;
		arrow.velX = cos(angle) * speed;
		arrow.velY = sin(angle) * speed;
		arrow.lifetime = MainConst.ARROW_TIME;
		arrowID = (arrowID + 1) % MainConst.ARROW_COUNT;
		
		sfx(MainConst.SFX_SHOOT + MainUtils.frame % 3);
	}

	public function checkInputs() {
		updateMouse();

		pos.dirX = 0;
		pos.dirY = 0;

		if (isAiming) pos.speed = MainConst.SPEED_MIN;
		else pos.speed = MainConst.SPEED_MAX;

		if (btn(0, pos.id)) pos.dirX -= 1;
		if (btn(1, pos.id)) pos.dirX += 1;
		if (btn(2, pos.id)) pos.dirY -= 1;
		if (btn(3, pos.id)) pos.dirY += 1;
		
		if (btnp(4, pos.id)) healthTemp = (health -= 10);
	}
	
	function checkHealth() {
		if (health < 0) {
			health = 0;
			isAlive = false;
			sfx(9 + flr(rand(3)));
		}
	}

	public function getWalkCounter():Fixed {
		return (walkCounter / MainConst.SPEED_MAX) % 3;
	}

	function drawHealthBar() {
		var barColor:Int = 11;
		if (health < 10) barColor = 8;
		line(pos.x, pos.y + 9, pos.x + (health/15), pos.y + 9, barColor);
	}

	function drawSprite(id:Fixed) {
		spr(id, pos.x, pos.y);
	}

	public function drawMouse() {
		var offset:Fixed = 0;
		if (isAiming) {
			offset = 1 + (aimCharge / MainConst.AIM_CHARGE_MAX) * 4;
		}

		spr(MainConst.SPRITE_CURSOR + offset, MainUtils.mouseX, MainUtils.mouseY);
	}
	
	//////////////////////////////////////
	
	function updateArrows() {
		forEach(arrows, function(arrow:TArrow) {
			print(arrow.lifetime);
			
			if (arrow.lifetime <= 0) return;
				
			arrow.lifetime -= 1;
			
			arrow.x += arrow.velX;
			arrow.y += arrow.velY;
			
			forEach( Screen02InGame.players, function(player:Player) {
				if (!player.isAlive || player.pos.id == this.pos.id) {
					return;
				}
				
				var distSqr = MainUtils.dist(
				  arrow.x, arrow.y,
				  player.pos.x + MainConst.ARROW_OFFSET_FROM, player.pos.y + MainConst.ARROW_OFFSET_FROM
				);
				
				if (distSqr < MainConst.ARROW_PRECISION) {
					sfx(2);
					arrow.lifetime = -1;
					player.health -= MainConst.ARROW_DAMAGE * (abs(arrow.velX) + abs(arrow.velY));
					player.checkHealth();
					player.healthTemp = player.health;
				}
			});
			
			if (arrow.lifetime == 0) {
				sfx(8);
			}
		});
	}
	
	function drawArrows() {
		forEach(arrows, function(arrow:TArrow) {
			if (arrow.lifetime <= 0) return;
		
			pset(arrow.x, arrow.y, 7);
		});
	}
}

typedef TArrow = {
	x:Fixed,
	y:Fixed,
	velX:Fixed,
	velY:Fixed,
	lifetime:Fixed,
}