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
		#if !sys
			throw("Hey! FNFM+ only compiles for desktop, not web or other sys.");
		#end
		super();

		#if desktop
		var settingsJson = CoolUtil.parseJson(Assets.getText("assets/data/options.json"));
		if(settingsJson.windowTitle != null) Application.current.window.title = settingsJson.windowTitle;
		#end

		addChild(new FlxGame(0, 0, TitleState, 1, 60, 120, settingsJson.skipSplash));

		#if !mobile
		addChild(new FPS(10, 3, 0xFFFFFF));
		#end
	}
}
