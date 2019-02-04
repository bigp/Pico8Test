package;
import Pico.*;
import MainUtils;
import Player;
import screens.IScreen;
import screens.Screen01MainMenu;

class Main {
	static inline function main() {
		var mainmenu:IScreen = new Screen01MainMenu();
		
		onInit = function() {
			MainUtils.screenChange(mainmenu);
		}
		onUpdate = function() {
			MainUtils.screenUpdate();
		}
		onDraw = function() {
			MainUtils.screenDraw();
		}
	}
}