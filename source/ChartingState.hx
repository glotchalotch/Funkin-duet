package;

import flixel.addons.ui.FlxClickArea;
import flixel.addons.ui.FlxUIRadioGroup;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.FlxUIList;
import Section.SwagSection;
import Song.SwagSong;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import lime.system.System;
#if sys
import sys.io.File;
import haxe.io.Path;
import tjson.TJSON;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
#end

using StringTools;

class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;

	var _song:SwagSong;

	var typingShit:FlxInputText;
	var player1TextField:FlxInputText;
	var player2TextField:FlxInputText;
	var gfTextField:FlxInputText;
	var cutsceneTextField:FlxInputText;
	var uiTextField:FlxInputText;
	var stageTextField:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Int = 0;

	var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var stepsPerSection:Int = 16;

	var duetArr:Array<Dynamic> = []; // [character string, offset x, offset y, is sync]
	var duetArr2:Array<Dynamic> = [];
	var curSelectedNoteDuetList:FlxUIList;
	var duetEnableArr:Array<FlxUIInputText> = [];
	var prevSelectedNote:Array<Dynamic>;
	var numericStepperTextArr:Array<FlxUIInputText> = [];
	var numericStepperTextArr2:Array<FlxUIInputText> = [];
	var shouldDisableVolKeys:Bool = false;
	var bfCamOffsetStepper1:FlxUINumericStepper;
	var bfCamOffsetStepper2:FlxUINumericStepper;
	var bfCamOffsetStepperTextArr:Array<FlxUIInputText> = [new FlxUIInputText(0, 0, 30), new FlxUIInputText(0, 0, 30)];
	var enemyCamOffsetStepper1:FlxUINumericStepper;
	var enemyCamOffsetStepper2:FlxUINumericStepper;
	var enemyCamOffsetStepperTextArr:Array<FlxUIInputText> = [new FlxUIInputText(0, 0, 30), new FlxUIInputText(0, 0, 30)];
	var duetList:FlxUIList;
	var duetList2:FlxUIList;
	var offsetXList:FlxUIList;
	var offsetXList2:FlxUIList;
	var offsetYList:FlxUIList;
	var offsetYList2:FlxUIList;
	var syncCheckList:FlxUIList;
	var syncCheckList2:FlxUIList;
	var chartButtonList:FlxUIList;
	var chartButtonList2:FlxUIList;
	var curSubSongChar:String;
	var duetListAdd:FlxButton;
	var duetListRemove:FlxButton;
	var listTitleEnable:FlxUIText;
	var copyFromMainButton:FlxButton;
	var copyFromCharButton:FlxButton;
	var copyFromCharText:FlxUIInputText;

	override function create()
	{
		curSection = lastSection;

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);

		leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('dad');
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player1duets: [],
				player2: 'dad',
				stage: 'stage',
				gf: 'gf',
				isHey: false,
				speed: 1,
				isSpooky: false,
				isMoody: false,
				cutsceneType: "none",
				uiType: 'normal',
				bfCamOffset: [0, 0],
				player2duets: [],
				enemyCamOffset: [0, 0],
				timeSignature: [4, 4]
			};
		}

		if(_song.player1duets == null) _song.player1duets = [];
		if(_song.player2duets == null) _song.player2duets = [];
		if(_song.bfCamOffset == null) _song.bfCamOffset = [0, 0];
		if(_song.enemyCamOffset == null) _song.enemyCamOffset = [0, 0];
		if(_song.timeSignature == null) _song.timeSignature = [4, 4];

		FlxG.mouse.visible = true;
		//FlxG.save.bind('save1', 'bulbyVR');
		// i don't know why we need to rebind our save
		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1075, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Char", label: 'Char'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(425, 400);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addCharsUI();

		add(curRenderedNotes);
		add(curRenderedSustains);

		super.create();
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});
		var isSpookyCheck = new FlxUICheckBox(10, 280,null,null,"Is Spooky", 100);
		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		var radioGroup = new FlxUIRadioGroup(90, 65, ["radio_ts_3", "radio_ts_4"], ["3/4", "4/4"]);

		switch(_song.timeSignature[0]) {
			case 3:
				radioGroup.selectedId = "radio_ts_3";
			case 4:
				radioGroup.selectedId = "radio_ts_4";
		}

		var clearSongButton:FlxButton = new FlxButton(reloadSongJson.x + reloadSongJson.width + 10, saveButton.y, "Clear song", () -> clearSong());

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 1, 1, 1, 339, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';


		player1TextField = new FlxUIInputText(10, 100, 70, _song.player1, 8);
		player2TextField = new FlxUIInputText(80, 100, 70, _song.player2, 8);
		gfTextField = new FlxUIInputText(10, 120, 70, _song.gf, 8);
		stageTextField = new FlxUIInputText(80, 120, 70, _song.stage, 8);
		cutsceneTextField = new FlxUIInputText(80, 140, 70, _song.cutsceneType, 8);
		uiTextField = new FlxUIInputText(10, 140, 70, _song.uiType, 8);
		var isMoodyCheck = new FlxUICheckBox(10, 220, null, null, "Is Moody", 100);
		var isHeyCheck = new FlxUICheckBox(10, 250, null, null, "Is Hey", 100);
		isMoodyCheck.name = "isMoody";
		isHeyCheck.name = "isHey";
		isMoodyCheck.checked = _song.isMoody;
		isSpookyCheck.checked = _song.isSpooky;
		isHeyCheck.checked = _song.isHey;
		var curStage = _song.stage;
		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		var bfCamText = new FlxUIText(40, 305, 0, "BF Cam Offset");
		var bfCamText1 = new FlxUIText(10, 320, 0, "Offset X");
		bfCamOffsetStepper1 = new FlxUINumericStepper(10, 340, 0.01, 0, -999, 999, 2, 1, bfCamOffsetStepperTextArr[0]);
		bfCamOffsetStepper1.value = _song.bfCamOffset[0];
		bfCamOffsetStepper1.name = "bf_cam_offset_x";
		var bfCamText2 = new FlxUIText(80, 320, 0, "Offset Y");
		bfCamOffsetStepper2 = new FlxUINumericStepper(80, 340, 0.01, 0, -999, 999, 2, 1, bfCamOffsetStepperTextArr[1]);
		bfCamOffsetStepper2.value = _song.bfCamOffset[1];
		bfCamOffsetStepper2.name = "bf_cam_offset_y";

		var enemyCamText = new FlxUIText(175, 305, 0, "Enemy Cam Offset");
		var enemyCamText1 = new FlxUIText(160, 320, 0, "Offset X");
		enemyCamOffsetStepper1 = new FlxUINumericStepper(160, 340, 0.01, 0, -999, 999, 2, 1, enemyCamOffsetStepperTextArr[0]);
		enemyCamOffsetStepper1.value = _song.enemyCamOffset[0];
		enemyCamOffsetStepper1.name = "enemy_cam_offset_x";
		var enemyCamText2 = new FlxUIText(230, 320, 0, "Offset Y");
		enemyCamOffsetStepper2 = new FlxUINumericStepper(230, 340, 0.01, 0, -999, 999, 2, 1, enemyCamOffsetStepperTextArr[1]);
		enemyCamOffsetStepper2.value = _song.enemyCamOffset[1];
		enemyCamOffsetStepper2.name = "enemy_cam_offset_y";

		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(isMoodyCheck);
		tab_group_song.add(isSpookyCheck);
		tab_group_song.add(isHeyCheck);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(bfCamOffsetStepper1);
		tab_group_song.add(bfCamOffsetStepper2);
		tab_group_song.add(bfCamText1);
		tab_group_song.add(bfCamText2);
		tab_group_song.add(bfCamText);
		tab_group_song.add(enemyCamText);
		tab_group_song.add(enemyCamText1);
		tab_group_song.add(enemyCamText2);
		tab_group_song.add(enemyCamOffsetStepper1);
		tab_group_song.add(enemyCamOffsetStepper2);
		tab_group_song.add(radioGroup);
		tab_group_song.add(clearSongButton);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	function addCharsListValue(isInitial:Bool, forBF:Bool, ?gaming:Array<Dynamic>) {
		if(gaming == null) gaming = ["", 0, 0, true];
		var text = new FlxUIInputText(0, 0, 60, gaming[0]);
		text.name = forBF ? 'duet_chars_${duetArr.length}' : 'dad_duet_chars_${duetArr2.length}';
		var text1 = new FlxUIInputText(0, 0, 30);
		var stepper1 = new FlxUINumericStepper(0, 0, 0.01, 0, -999, 999, 2, 1, text1);
		text.resize(text.width, stepper1.height);
		forBF ? numericStepperTextArr.push(text1) : numericStepperTextArr2.push(text1);
		stepper1.value = gaming[1];
		stepper1.name = forBF ? 'duet_x_${duetArr.length}' : 'dad_duet_x_${duetArr2.length}';
		var text2 = new FlxUIInputText(0, 0, 30);
		forBF ? numericStepperTextArr.push(text2) : numericStepperTextArr2.push(text2);
		var stepper2 = new FlxUINumericStepper(0, 0, 0.01, 0, -999, 999, 2, 1, text2);
		stepper2.value = gaming[2];
		stepper2.name = forBF ? 'duet_y_${duetArr.length}' : 'dad_duet_y_${duetArr2.length}';
		forBF ? duetList.add(text) : duetList2.add(text);
		forBF ? offsetXList.add(stepper1) : offsetXList2.add(stepper1);
		forBF ? offsetYList.add(stepper2) : offsetYList2.add(stepper2);
		var checkbox = new FlxUICheckBox(0, 0, null, null, ""); //for some reason you have to have a label set even though it says it's nullable??
		checkbox.name = forBF ? 'duet_sync_check_${duetArr.length}' : 'dad_duet_sync_check_${duetArr2.length}';
		if(gaming[3] == null) gaming[3] = true;
		checkbox.checked = gaming[3];
		checkbox.button.resize(checkbox.box.width, checkbox.box.height);
		forBF ? syncCheckList.add(checkbox) : syncCheckList2.add(checkbox);
		var button = new FlxButton(0, 0, "Chart", () -> {
			subSongUI(text.text);
		});
		button.setSize(button.width, stepper1.height);
		forBF ? chartButtonList.add(button) : chartButtonList2.add(button);
		if(!isInitial) {
			if(forBF) _song.player1duets.push([text.text, stepper1.value, stepper2.value, checkbox.checked]);
			else _song.player2duets.push([text.text, stepper1.value, stepper2.value, checkbox.checked]);
			refreshChartButtons(forBF);
		}
		forBF ? duetArr.push([text, stepper1, stepper2, checkbox, button]) : duetArr2.push([text, stepper1, stepper2, checkbox, button]);
	}

	function refreshChartButtons(forBF:Bool) {
		// the list needs to be refreshed each time a list item is added :thumbsup:
		if(forBF) {
			for(i in 0...chartButtonList.members.length) {
				var check:FlxUICheckBox = cast syncCheckList.members[i];
				chartButtonList.members[i].visible = !check.checked;
			}
		} else {
			for(i in 0...chartButtonList2.members.length) {
				var check:FlxUICheckBox = cast syncCheckList2.members[i];
				chartButtonList2.members[i].visible = !check.checked;
			}
		}
	}

	function addCharsUI():Void
	{
		player1TextField = new FlxUIInputText(10, 10, 70, _song.player1, 8);
		player2TextField = new FlxUIInputText(80, 10, 70, _song.player2, 8);
		gfTextField = new FlxUIInputText(10, 30, 70, _song.gf, 8);
		stageTextField = new FlxUIInputText(80, 30, 70, _song.stage, 8);
		cutsceneTextField = new FlxUIInputText(80, 50, 70, _song.cutsceneType, 8);
		uiTextField = new FlxUIInputText(10, 50, 70, _song.uiType, 8);
		var curStage = _song.stage;

		var tab_group_char = new FlxUI(null, UI_box);
		tab_group_char.name = "Char";

		var listTitleDuet:FlxUIText = new FlxUIText(10, 70, 0, "BF Duet");
		var listTitleX:FlxUIText = new FlxUIText(80, 70, 0, "Offset X");
		var listTitleY:FlxUIText = new FlxUIText(150, 70, 0, "Offset Y");
		var listTitleDuet2:FlxUIText = new FlxUIText(10, 210, 0, "Enemy Duet");
		var listTitleX2:FlxUIText = new FlxUIText(80, 210, 0, "Offset X");
		var listTitleY2:FlxUIText = new FlxUIText(150, 210, 0, "Offset Y");
		var listTitleSync:FlxUIText = new FlxUIText(215, 70, 0, "Sync");
		var listTitleSync2:FlxUIText = new FlxUIText(215, 210, 0, "Sync");
		duetList = new FlxUIList(10, 90);
		duetList2 = new FlxUIList(10, 230);
		offsetXList = new FlxUIList(80, 90);
		offsetXList2 = new FlxUIList(80, 230);
		offsetYList = new FlxUIList(150, 90);
		offsetYList2 = new FlxUIList(150, 230);
		syncCheckList = new FlxUIList(220, 90);
		syncCheckList2 = new FlxUIList(220, 230);
		chartButtonList = new FlxUIList(250, 90);
		chartButtonList2 = new FlxUIList(250, 230);
		for(gaming in _song.player1duets) {
			addCharsListValue(true, true, gaming);
		}
		for(gaming in _song.player2duets) {
			addCharsListValue(true, false, gaming);
		}
		var duetListAdd:FlxButton = new FlxButton(250, 70, "Add", () -> {
			addCharsListValue(false, true);
		});
		var duetListRemove:FlxButton = new FlxButton(335, 70, "Remove", () -> {
			if(duetArr.length > 0) {
				duetList.remove(duetArr[duetArr.length - 1][0], true);
				offsetXList.remove(duetArr[duetArr.length - 1][1], true);
				offsetYList.remove(duetArr[duetArr.length - 1][2], true);
				syncCheckList.remove(duetArr[duetArr.length - 1][3], true);
				chartButtonList.remove(duetArr[duetArr.length - 1][4], true);
				_song.player1duets.pop();
				duetArr.pop();
				numericStepperTextArr.splice(numericStepperTextArr.length - 2, 2);
			}
		});
		var duetListAdd2:FlxButton = new FlxButton(250, 210, "Add", () -> {
			addCharsListValue(false, false);
		});
		var duetListRemove2:FlxButton = new FlxButton(335, 210, "Remove", () -> {
			if(duetArr2.length > 0) {
				duetList2.remove(duetArr2[duetArr2.length - 1][0], true);
				offsetXList2.remove(duetArr2[duetArr2.length - 1][1], true);
				offsetYList2.remove(duetArr2[duetArr2.length - 1][2], true);
				syncCheckList2.remove(duetArr2[duetArr2.length - 1][3], true);
				chartButtonList2.remove(duetArr2[duetArr2.length - 1][4], true);
				_song.player2duets.pop();
				duetArr2.pop();
				numericStepperTextArr2.splice(numericStepperTextArr2.length - 2, 2);
			}
		});

		var backToMainButton:FlxButton = new FlxButton(250, 50, "Main Chart", () -> subSongUI(null));

		tab_group_char.add(uiTextField);
		tab_group_char.add(cutsceneTextField);
		tab_group_char.add(stageTextField);
		tab_group_char.add(gfTextField);
		tab_group_char.add(player1TextField);
		tab_group_char.add(player2TextField);
		tab_group_char.add(listTitleDuet);
		tab_group_char.add(duetList);
		tab_group_char.add(duetListAdd);
		tab_group_char.add(duetListRemove);
		tab_group_char.add(listTitleX);
		tab_group_char.add(listTitleY);
		tab_group_char.add(offsetXList);
		tab_group_char.add(offsetYList);
		tab_group_char.add(duetList2);
		tab_group_char.add(offsetXList2);
		tab_group_char.add(offsetYList2);
		tab_group_char.add(listTitleDuet2);
		tab_group_char.add(listTitleX2);
		tab_group_char.add(listTitleY2);
		tab_group_char.add(duetListAdd2);
		tab_group_char.add(duetListRemove2);
		tab_group_char.add(syncCheckList);
		tab_group_char.add(syncCheckList2);
		tab_group_char.add(listTitleSync);
		tab_group_char.add(listTitleSync2);
		tab_group_char.add(chartButtonList);
		tab_group_char.add(chartButtonList2);
		tab_group_char.add(backToMainButton);

		UI_box.addGroup(tab_group_char);
		UI_box.scrollFactor.set();

		refreshChartButtons(true);
		refreshChartButtons(false);
	}

	var stepperLength:FlxUINumericStepper;
	var stepperAltAnim:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	// var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';
		stepperAltAnim = new FlxUINumericStepper(10, 200, 1, Conductor.bpm, 0, 999, 0);
		stepperAltAnim.value = 0;
		stepperAltAnim.name = 'alt_anim_number';
		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function()
		{
			if(curSubSongChar == null) {
				for (i in 0..._song.notes[curSection].sectionNotes.length)
				{
					var note = _song.notes[curSection].sectionNotes[i];
					note[1] = (note[1] + 4) % 8;
					_song.notes[curSection].sectionNotes[i] = note;
					updateGrid();
				}
			} else {
				var index:Int = findSubSongSectionIndex(curSubSongChar, curSection);
				for (i in 0..._song.notes[curSection].duetSectionNotes[index][1].length)
				{
					var note = _song.notes[curSection].duetSectionNotes[index][1][i];
					note[1] = (note[1] + 4) % 8;
					_song.notes[curSection].duetSectionNotes[index][1][i] = note;
					updateGrid();
				}
			}
			
		});

		copyFromMainButton = new FlxButton(110, 150, "Copy main", () -> copyFrom(null, Std.int(stepperCopy.value)));
		copyFromCharButton = new FlxButton(110, 170, "Copy char:", () -> copyFrom(copyFromCharText.text, Std.int(stepperCopy.value)));
		copyFromCharText = new FlxUIInputText(200, 175);

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		// check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alt Animation", 100);
		// check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		//tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		// tab_group_section.add(check_altAnim);
		tab_group_section.add(stepperAltAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);
		tab_group_section.add(copyFromMainButton);
		tab_group_section.add(copyFromCharButton);
		tab_group_section.add(copyFromCharText);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');

		listTitleEnable = new FlxUIText(10, 60, 0, "Toggle Duet Chars");
		var duetEnableList:FlxUIList = new FlxUIList(10, 100);
		curSelectedNoteDuetList = duetEnableList;
		duetListAdd = new FlxButton(10, 200, "Add", () -> {
			var text = new FlxUIInputText();
			text.name = 'duet_note_toggle_${duetEnableArr.length}';
			curSelectedNoteDuetList.add(text);
			duetEnableArr.push(text);
			if(curSelectedNote[3] == null) curSelectedNote[3] = [text.text];
			else curSelectedNote[3].push(text.text);
		});
		duetListRemove = new FlxButton(10, 230, "Remove", () -> {
			if(duetEnableArr.length > 0) {
				curSelectedNoteDuetList.remove(duetEnableArr[duetEnableArr.length - 1], true);
				duetEnableArr.pop();
				curSelectedNote[3].pop();
			}
		});

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);
		tab_group_note.add(listTitleEnable);
		tab_group_note.add(duetEnableList);
		tab_group_note.add(duetListAdd);
		tab_group_note.add(duetListRemove);

		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}
		#if sys
		FlxG.sound.playMusic(Sound.fromFile("assets/music/"+daSong+"_Inst"+TitleState.soundExt), 0.6);
		#else
		FlxG.sound.playMusic('assets/music/' + daSong + "_Inst" + TitleState.soundExt, 0.6);
		#end
		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		if (_song.needsVoices) {
			#if sys
			var vocalSound = Sound.fromFile("assets/music/"+daSong+"_Voices"+TitleState.soundExt);
			vocals = new FlxSound().loadEmbedded(vocalSound);
			#else
			vocals = new FlxSound().loadEmbedded("assets/music/" + daSong + "_Voices" + TitleState.soundExt);
			#end
			FlxG.sound.list.add(vocals);

		}

		FlxG.sound.music.pause();
		if (_song.needsVoices) {
			vocals.pause();
		}


		FlxG.sound.music.onComplete = function()
		{
			if (_song.needsVoices) {
				vocals.pause();
				vocals.time = 0;
			}

			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/*
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	function subSongUI(char:String) {
		curSubSongChar = char;
		updateGrid();
	}

	function findSubSongSectionIndex(char:String, section:Int):Int {
		if(_song.notes[section].duetSectionNotes == null) return -1;
		var filtered = _song.notes[section].duetSectionNotes.filter(f -> f[0] == char);
		if(filtered != null) return _song.notes[section].duetSectionNotes.indexOf(filtered[0]);
		else return -1;
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			if(check.name.startsWith("duet_sync_check_")) {
				var index:Int = Std.parseInt(check.name.split("_")[3]);
				_song.player1duets[index][3] = check.checked;
				var button:FlxButton = cast chartButtonList.members[index];
				button.visible = !check.checked;
			} else if(check.name.startsWith("dad_duet_sync_check_")) {
				var index = Std.parseInt(check.name.split("_")[4]);
				_song.player2duets[index][3] = check.checked;
				var button:FlxButton = cast chartButtonList2.members[index];
				button.visible = !check.checked;
			}
			if(check.getLabel() == null) return;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;

					updateHeads();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					// _song.notes[curSection].altAnim = check.checked;
				case "Is Moody":
					_song.isMoody = check.checked;
				case "Is Spooky":
					_song.isSpooky = check.checked;
				case "Is Hey":
					_song.isHey = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			}
			else if (wname == 'note_susLength')
			{
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			} else if (wname == 'alt_anim_number')
			{
				_song.notes[curSection].altAnimNum = Std.int(nums.value);
			} else if(wname.startsWith("duet_x_")) {
				_song.player1duets[Std.parseInt(wname.split("_")[2])][1] = nums.value;
			} else if(wname.startsWith("duet_y_")) {
				_song.player1duets[Std.parseInt(wname.split("_")[2])][2] = nums.value;
			} else if(wname == "bf_cam_offset_x") {
				_song.bfCamOffset[0] = nums.value;
			} else if(wname == "bf_cam_offset_y") {
				_song.bfCamOffset[1] = nums.value;
			} else if(wname.startsWith("dad_duet_x_")) {
				_song.player2duets[Std.parseInt(wname.split("_")[3])][1] = nums.value;
			} else if(wname.startsWith("dad_duet_y_")) {
				_song.player2duets[Std.parseInt(wname.split("_")[3])][2] = nums.value;
			} else if(wname == "enemy_cam_offset_x") {
				_song.enemyCamOffset[0] = nums.value;
			} else if(wname == "enemy_cam_offset_y") {
				_song.enemyCamOffset[1] = nums.value;
			}
		}
		else if(id == FlxUIInputText.CHANGE_EVENT) {
			var input:FlxUIInputText = cast sender;
			if(input.name.startsWith("duet_chars_")) {
				if(data != null) {
					_song.player1duets[Std.parseInt(input.name.split("_")[2])][0] = input.text;
				}
			} else if(input.name.startsWith("duet_note_toggle_")) {
				curSelectedNote[3][Std.parseInt(input.name.split("_")[3])] = input.text;
			} else if(input.name.startsWith("dad_duet_chars_")) {
				if(data != null) {
					_song.player2duets[Std.parseInt(input.name.split("_")[3])][0] = input.text;
				}
			}
		} else if(id == FlxUITabMenu.CLICK_EVENT) {
			var menu:FlxUITabMenu = cast sender;
			switch(menu.selected_tab_id) {
				case "Char":
					refreshChartButtons(true);
					refreshChartButtons(false);
				case "Note":
					if(curSubSongChar != null) {
						duetListAdd.visible = false;
						duetListRemove.visible = false;
						listTitleEnable.visible = false;
					} else {
						duetListAdd.visible = true;
						duetListRemove.visible = true;
						listTitleEnable.visible = true;
					}
				case "Section":
					if(curSubSongChar != null) {
						copyFromMainButton.visible = true;
						copyFromCharButton.visible = true;
						copyFromCharText.visible = true;
					} else {
						copyFromMainButton.visible = false;
						copyFromCharButton.visible = false;
						copyFromCharText.visible = false;
					}
			}
			if(menu.selected_tab_id == "Char") {
				
			}
		} else if(id == FlxUIRadioGroup.CLICK_EVENT) {
			var group:FlxUIRadioGroup = cast sender;
			switch(group.selectedId) {
				case "radio_ts_3":
					changeTimeSignature(3, 4);
				case "radio_ts_4":
					changeTimeSignature(4, 4);
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
	function lengthBpmBullshit():Float
	{
		if (_song.notes[curSection].changeBPM)
			return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
		else
			return _song.notes[curSection].lengthInSteps;
	}*/

	function sectionStartTime():Float
	{
		var daBPM:Int = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM) {
				daBPM = _song.notes[i].bpm;
			}
			daPos += _song.timeSignature[0] * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;
		_song.player1 = player1TextField.text;
		_song.player2 = player2TextField.text;
		_song.gf = gfTextField.text;
		_song.stage = stageTextField.text;
		_song.cutsceneType = cutsceneTextField.text;
		_song.uiType = uiTextField.text;
		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else
						{
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			if (_song.needsVoices) {
				vocals.stop();
			}
			FlxG.mouse.visible = false;
			shouldDisableVolKeys = false;
			FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
			FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
			FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
			FlxG.switchState(new PlayState());
		}

		if(shouldDisableVolKeys) {
			FlxG.sound.muteKeys = null;
			FlxG.sound.volumeDownKeys = null;
			FlxG.sound.volumeUpKeys = null;
		} else {
			FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
			FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
			FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}
		var shiftThing:Int = 1;
		var thingInFocus:Bool = false;
		for(gaming in duetEnableArr) {
			if(gaming.hasFocus) thingInFocus = true;
		}
		if(!thingInFocus) for(gaming in duetArr) {
			if(gaming[0].hasFocus) thingInFocus = true;
		}
		if(!thingInFocus) for(gaming in numericStepperTextArr) {
			if(gaming.hasFocus) thingInFocus = true;
		}
		if(!thingInFocus) if(bfCamOffsetStepperTextArr.filter(f -> f.hasFocus).length > 0) thingInFocus = true;
		if(!thingInFocus) if(enemyCamOffsetStepperTextArr.filter(f -> f.hasFocus).length > 0) thingInFocus = true;
		if(!thingInFocus) if(numericStepperTextArr2.filter(f -> f.hasFocus).length > 0) thingInFocus = true;
		if(!thingInFocus) if(duetArr2.filter(f -> f.hasFocus).length > 0) thingInFocus = true;
		if (!typingShit.hasFocus && !player1TextField.hasFocus && !player2TextField.hasFocus && !gfTextField.hasFocus && !stageTextField.hasFocus && !cutsceneTextField.hasFocus && !uiTextField.hasFocus && !thingInFocus)
		{
			if (FlxG.keys.justPressed.E)
				{
					changeNoteSustain(Conductor.stepCrochet);
				}
				if (FlxG.keys.justPressed.Q)
				{
					changeNoteSustain(-Conductor.stepCrochet);
				}
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					if (_song.needsVoices) {
						vocals.pause();
					}

				}
				else
				{
					if (_song.needsVoices) {
						vocals.play();
					}
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				if (_song.needsVoices) {
					vocals.pause();
				}


				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				if (_song.needsVoices) {
					vocals.time = FlxG.sound.music.time;
				}

			}
			if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
				changeSection(curSection + shiftThing);
			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
				changeSection(curSection - shiftThing);
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;
			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					FlxG.sound.music.pause();
					if (_song.needsVoices) {
						vocals.pause();
					}


					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;
					if (_song.needsVoices) {
						vocals.time = FlxG.sound.music.time;
					}

				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					FlxG.sound.music.pause();
					if (_song.needsVoices) {
						vocals.pause();
					}


					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;
					if (_song.needsVoices) {
						vocals.time = FlxG.sound.music.time;
					}

				}
			}
			shouldDisableVolKeys = false;
		} else shouldDisableVolKeys = true;

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */





		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection;
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		if (_song.needsVoices) {
			vocals.pause();
		}


		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}
		if (_song.needsVoices) {
			vocals.time = FlxG.sound.music.time;
		}

		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				if (_song.needsVoices) {
					vocals.pause();
				}


				/*var daNum:Int = 0;
				var daLength:Float = 0;
				while (daNum <= sec)
				{
					daLength += lengthBpmBullshit();
					daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				if (_song.needsVoices) {
					vocals.time = FlxG.sound.music.time;
				}

				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		if(curSubSongChar == null) {
			for (note in _song.notes[daSec - sectionNum].sectionNotes)
			{
				var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

				var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3] == null ? [] : note[3]];
				_song.notes[daSec].sectionNotes.push(copiedNote);
			}
		} else {
			var index:Int = findSubSongSectionIndex(curSubSongChar, curSection);
			for (note in cast(_song.notes[daSec - sectionNum].duetSectionNotes[index][1], Array<Dynamic>))
			{
				var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

				var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3] == null ? [] : note[3]];
				_song.notes[daSec].duetSectionNotes[index][1].push(copiedNote);
			}
		}
		
		updateGrid();
	}

	function copyFrom(char:String, ?sectionNum:Int = 1) {
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		var index:Int = findSubSongSectionIndex(curSubSongChar, curSection);
		if(char == null) {
			for (note in _song.notes[daSec - sectionNum].sectionNotes)
			{
				var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

				var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3] == null ? [] : note[3]];
				_song.notes[daSec].duetSectionNotes[index][1].push(copiedNote);
			}
		} else {
			var charIndex:Int = findSubSongSectionIndex(char, daSec - sectionNum);
			if(charIndex != -1) {
				for (note in cast(_song.notes[daSec - sectionNum].duetSectionNotes[charIndex][1], Array<Dynamic>))
				{
					var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

					var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3] == null ? [] : note[3]];
					_song.notes[daSec].duetSectionNotes[index][1].push(copiedNote);
				}
			}
			
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		// check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		// note that 0 implies regular anim and 1 implies default alt 
		if (sec.altAnimNum == null) {
			sec.altAnimNum == if (sec.altAnim) 1 else 0;
		}
		stepperAltAnim.value = sec.altAnimNum;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			leftIcon.setPosition(0, 100);
			rightIcon.setPosition(gridBG.width / 2, -100);
		}
		else
		{
			rightIcon.setPosition(0, 100);
			leftIcon.setPosition(gridBG.width / 2, -100);
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null) {
			stepperSusLength.value = curSelectedNote[2];
			if(prevSelectedNote != curSelectedNote) {
				if(curSelectedNote[3] == 0) curSelectedNote[3] = [];
				duetEnableArr.splice(0, duetEnableArr.length);
				curSelectedNoteDuetList.members.splice(0, curSelectedNoteDuetList.length);
				var casted:Array<String> = cast curSelectedNote[3];
				if(casted.length > 0) {
					for(gaming in casted) {
						var text:FlxUIInputText = new FlxUIInputText(0, 0, null, gaming);
						text.name = 'duet_note_toggle_${duetEnableArr.length}';
						curSelectedNoteDuetList.add(text);
						duetEnableArr.push(text);
					}
				}
			}
			
			prevSelectedNote = curSelectedNote;
		}
	}

	function updateGrid():Void
	{
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		var sectionInfo:Array<Dynamic>;
		if(curSubSongChar == null) sectionInfo = _song.notes[curSection].sectionNotes;
		else {
			var index:Int = findSubSongSectionIndex(curSubSongChar, curSection);
			if(index != -1) sectionInfo = _song.notes[curSection].duetSectionNotes[index][1];
			else {
				if(_song.notes[curSection].duetSectionNotes == null) _song.notes[curSection].duetSectionNotes = [];
				var arrSub:Array<Dynamic> = [];
				var arr:Array<Dynamic> = [curSubSongChar, arrSub];
				_song.notes[curSection].duetSectionNotes.push(arr);
				sectionInfo = _song.notes[curSection].duetSectionNotes[_song.notes[curSection].duetSectionNotes.length - 1][1];
			}
		}

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			//get last bpm
			var daBPM:Int = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];
			var note:Note = new Note(daStrumTime, daNoteInfo % 4);
			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

			curRenderedNotes.add(note);

			if (daSus > 0)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
				curRenderedSustains.add(sustainVis);
			}
		}
	}

	private function changeTimeSignature(top:Int, bottom:Int) {
		if((top != 3 && top != 4) || bottom != 4) return;
		_song.timeSignature = [top, bottom];
		for(section in _song.notes) {
			switch(top) {
				case 3:
					section.lengthInSteps = 12;
					stepsPerSection = 12;
				case 4:
					section.lengthInSteps = 16;
					stepsPerSection = 16;
			}
		}
		updateSectionUI();
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		lengthInSteps = stepsPerSection;
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			duetSectionNotes: [],
			typeOfSection: 0,
			altAnim: false,
			altAnimNum: 0
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;

		if(curSubSongChar == null) {
			for (i in _song.notes[curSection].sectionNotes)
			{
				if (i.strumTime == note.strumTime && i.noteData % 4 == note.noteData)
				{
					curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
				}

				swagNum += 1;
			}
		} else {
			var index = findSubSongSectionIndex(curSubSongChar, curSection);
			for (i in cast(_song.notes[curSection].duetSectionNotes[index][1], Array<Dynamic>))
				{
					if (i.strumTime == note.strumTime && i.noteData % 4 == note.noteData)
					{
						curSelectedNote = _song.notes[curSection].duetSectionNotes[index][1][swagNum];
					}
	
					swagNum += 1;
				}
		}
		

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		if(curSubSongChar == null) {
			for (i in _song.notes[curSection].sectionNotes)
			{
				if (i[0] == note.strumTime && i[1] % 4 == note.noteData)
				{
					FlxG.log.add('FOUND EVIL NUMBER');
					_song.notes[curSection].sectionNotes.remove(i);
				}
			}
		} else {
			var index = findSubSongSectionIndex(curSubSongChar, curSection);
			for (i in cast(_song.notes[curSection].duetSectionNotes[index][1], Array<Dynamic>))
			{
				if (i[0] == note.strumTime && i[1] % 4 == note.noteData)
				{
					FlxG.log.add('FOUND EVIL NUMBER');
					_song.notes[curSection].duetSectionNotes[index][1].remove(i);
				}
			}
		}
		

		updateGrid();
	}

	function clearSection():Void
	{
		if(curSubSongChar == null) _song.notes[curSection].sectionNotes = [];
		else {
			var index = findSubSongSectionIndex(curSubSongChar, curSection);
			if(index != -1) _song.notes[curSection].duetSectionNotes[index] = [];
		}

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
			_song.notes[daSection].duetSectionNotes = [];
		}

		updateGrid();
	}

	private function addNote():Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;
		if(curSubSongChar == null) {
			_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, []]);
			curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];
			if (FlxG.keys.pressed.CONTROL)
			{
				_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus, []]);
			}
		}
		else {
			var index = findSubSongSectionIndex(curSubSongChar, curSection);
			trace(_song.notes[curSection].duetSectionNotes[index][0]);
			if(index != -1) cast(_song.notes[curSection].duetSectionNotes[index][1], Array<Dynamic>).push([noteStrum, noteData, noteSus, []]);
			else _song.notes[curSection].duetSectionNotes.push([curSubSongChar, [[noteStrum, noteData, noteSus, []]]]);
			curSelectedNote = _song.notes[curSection].duetSectionNotes[index][1][_song.notes[curSection].duetSectionNotes[index][1].length + -1]; //if i put "- 1" it thinks it's a float and gives me a compile error. i love coding
			if (FlxG.keys.pressed.CONTROL)
			{
				cast(_song.notes[curSection].duetSectionNotes[index][1], Array<Dynamic>).push([noteStrum, (noteData + 4) % 8, noteSus, []]);
			}
		}


		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	/*
	function calculateSectionLengths(?sec:SwagSection):Int
	{
		var daLength:Int = 0;

		for (i in _song.notes)
		{
			var swagLength = i.lengthInSteps;

			if (i.typeOfSection == Section.COPYCAT)
				swagLength * 2;

			daLength += swagLength;

			if (sec != null && sec == i)
			{
				trace('swag loop??');
				break;
			}
		}

		return daLength;
	}*/

	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		for(s in _song.notes) {
			if(s.duetSectionNotes != null) {
				for (d in s.duetSectionNotes)
				{
					if (d[1].length == 0)
						s.duetSectionNotes.remove(d);
				}
				if(s.duetSectionNotes.length == 0) s.duetSectionNotes = null;
			}
		}
		var json = {
			"song": _song
		};

		var data:String = CoolUtil.stringifyJson(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
