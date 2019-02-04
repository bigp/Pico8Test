package screens;

import Pico.*;
/**
 * ...
 * @author Pierre Chamberlain
 */
@:publicFields
@:native("INGAME")
class Screen02InGame implements IScreen {

	var player:Player;
	var player1:Player;
	var gameOverStatus:String = null;
	static var players:Collection<Player>;
	
	public function new() {
		player1 = new Player(1);
		player1.pos.x = 80;
		player1.useMouse = true;

		players = [
		 player1,
		 createRandomPlayer(),
		 createRandomPlayer(),
		 createRandomPlayer(),
		 createRandomPlayer()
		];
	}
	
	
	/* INTERFACE screens.IScreen */
	
	dynamic function init() {
		
	}
	
	dynamic function update() {
		cls();
		rectfill(0, 0, 128, 128, MainConst.COLOR_03_GREEN_DARK);
		
		MainUtils.update();

		player1.checkInputs();
		
		var numPlayersAlive:Int = 0;
		var playerAlive:Player = null;

		forEach(players, function(player:Player) {
			player.update();
			if (player.isAlive) {
				numPlayersAlive += 1;
				playerAlive = player;
			}
		});
		
		if (gameOverStatus==null && numPlayersAlive == 1) {
			if (playerAlive == player1) {
				gameOverStatus = "you won!";
				sfx(12);
			} else {
				gameOverStatus = "you lost!";
				sfx(13);
			}
		}
		
		if (gameOverStatus!=null && btnp(0, 1)) {
			MainUtils.screenChange(new Screen02InGame());
		}
	}
	
	dynamic function draw() {
		forEach(players, function(player:Player) {
			player.draw();
		});
		
		if (gameOverStatus != null) {
			print(gameOverStatus, 3, 65, MainConst.COLOR_00_BLACK);
			print(gameOverStatus, 2, 64, MainConst.COLOR_07_WHITE);
		}

		player1.drawMouse();
	}
	
	dynamic function destroy() {
		
	}
	
	////////////////////////////////////
	
	static function createRandomPlayer():Player {
		var player = new Player(0);
		player.pos.x = rand(127.0);
		player.pos.y = rand(127.0);
		
		return player;
	}
	
}