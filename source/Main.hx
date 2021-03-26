package;

import openfl.Assets;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;
import lime.app.Application;

class Main extends Sprite
{
	public function new()
	{
		super();

		#if desktop
		var text:String = Assets.getText("assets/data/windowTitle.txt");
		if(text != null) Application.current.window.title = text;
		#end

		addChild(new FlxGame(0, 0, TitleState, 1, 60, 120, true));

		#if !mobile
		addChild(new FPS(10, 3, 0xFFFFFF));
		#end
	}
}
