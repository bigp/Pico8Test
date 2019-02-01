package;
import Pico.*;
import MainUtils;
import Player;

@:native("M")
@:publicFields
class Main {
	static var players:Collection<Player>;
	
	static inline function main() {
		var player:Player, player1:Player, player2:Player;

		player1 = new Player(1);
		player1.x = 80;
		player1.useMouse = true;

		players = [
		 player1,
		 createRandomPlayer(),
		 createRandomPlayer(),
		 createRandomPlayer(),
		 createRandomPlayer()
		];
		
		onInit = function() {
			cls();
		}
		
		onUpdate = function() {
			cls();
			rectfill(0, 0, 128, 128, MainConst.COLOR_GREEN_DARK);
			
			MainUtils.update();

			player1.checkInputs();

			forEach(players, function(player:Player) {
				player.update();
			});
		}

		onDraw = function() {
			//return;

			
			forEach(players, function(player:Player) {
				player.draw();
			});

			player1.drawMouse();
		}
		
		//players.add(spare);

		
	}
	
	static function createRandomPlayer():Player {
		var player = new Player(0);
		player.x = rand(127.0);
		player.y = rand(127.0);
		
		return player;
	}
}