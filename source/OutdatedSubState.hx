package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var ver = "v" + Application.current.meta.get('version');
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"HEY! You're running this game on mac or linux!\nThis is not a fully featured version\n Get a new operating system, idiot! ",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		txt.y -= 100;
		add(txt);
		var txt2:FlxText = new FlxText(0, 0, FlxG.width,
			"hi, this is glotch. i didn't write the above message and i'd like to formally apologize for the behavior of bulbyvr.\n\n unless youre on a mac lol\n\np.s. press enter to continue ",
			32);
		txt2.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt2.screenCenter();
		txt2.y += 100;
		add(txt2);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
