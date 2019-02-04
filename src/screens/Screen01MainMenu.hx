package screens;

import Pico.*;

/**
 * ...
 * @author Pierre Chamberlain
 */
@:publicFields
@:native("MAINMENU")
class Screen01MainMenu implements IScreen {

	function new() {
		
	}
	
	/////////////////////////////////
	
	dynamic function init() {
		cls();
		print("Main Menu");
		print("PRESS A TO START");
	}
	
	dynamic function update() {
		if (btnp(0, 1)) {
			MainUtils.screenChange(new Screen02InGame());
		}
	}
	
	dynamic function draw() {
		
	}
	
	dynamic function destroy() {
		
	}
	
}