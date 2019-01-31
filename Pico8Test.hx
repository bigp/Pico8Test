package;
import Pico.*;
import com.pico8test.GameUtils;
import com.pico8test.Player;
import lua.Table;

class Pico8Test {
	static inline function main() {
		var mouseControl = true;
		
		var players:Collection<Player> = new Collection();
		players.add(new Player(0, mouseControl));
		players.add(new Player(1));
		
		onUpdate = function() {
			cls();
			
			GameUtils.update();
			
			for (player in all(players)) {
				player.update();
			}
		}
		
		onDraw = function() {
			for (player in all(players)) {
				player.draw();
			}
		}
	}
}