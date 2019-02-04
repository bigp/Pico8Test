package screens;

/**
 * @author Pierre Chamberlain
 */
@:native("S")
interface IScreen {
	dynamic function init():Void;
	dynamic function update():Void;
	dynamic function draw():Void;
	dynamic function destroy():Void;
}