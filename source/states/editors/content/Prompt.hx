package states.editors.content;

import flixel.util.FlxDestroyUtil;

class ExitConfirmationPrompt extends Prompt
{
	public function new(?finishCallback:Void->Void)
	{
		super('There\'s unsaved progress,\nare you sure you want to exit?', function()
		{
			FlxG.mouse.visible = false;
			MusicBeatState.switchState(new states.editors.MasterEditorMenu());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			if (finishCallback != null) finishCallback();
		}, 'Exit');
	}
}

class Prompt extends BasePrompt
{
	var yesFunction:Void->Void;
	var noFunction:Void->Void;
	var _yesTxt:String = 'OK';
	var _noTxt:String = 'Cancel';

	public function new(title:String, yesFunction:Void->Void, ?noFunction:Void->Void, ?yesTxt:String, ?noTxt:String)
	{
		if (yesTxt != null) this._yesTxt = yesTxt;
		if (noTxt != null) this._noTxt = noTxt;
		this.yesFunction = yesFunction;
		this.noFunction = noFunction;
		super(title, promptCreate);
	}

	function promptCreate(_)
	{
		var btnY = 390;

		var btnYes:PsychUIButton = new PsychUIButton(0, btnY, _yesTxt, function()
		{
			yesFunction();
			close();
		});
		btnYes.normalStyle.bgColor = FlxColor.RED;
		btnYes.normalStyle.textColor = FlxColor.WHITE;
		btnYes.screenCenter(X);
		btnYes.x -= 100;
		btnYes.cameras = cameras;
		add(btnYes);

		var btnNo:PsychUIButton = new PsychUIButton(0, btnY, _noTxt, close);
		btnNo.screenCenter(X);
		btnNo.x += 100;
		btnNo.cameras = cameras;
		add(btnNo);
	}

	override function close()
	{
		if (noFunction != null) noFunction();
		super.close();
	}
}

class BasePrompt extends MusicBeatSubstate
{
	var _sizeX:Float = 0;
	var _sizeY:Float = 0;
	var _title:String;

	public var onCreate:BasePrompt->Void;
	public var onUpdate:BasePrompt->Float->Void;

	public function new(sizeX:Float = 420, sizeY:Float = 160, title:String, ?onCreate:BasePrompt->Void, ?onUpdate:BasePrompt->Float->Void)
	{
		this._sizeX = sizeX;
		this._sizeY = sizeY;
		this._title = title;
		this.onCreate = onCreate;
		this.onUpdate = onUpdate;
		super();
	}

	public var bg:FlxSprite;
	public var titleText:FlxText;

	override function create()
	{
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.alpha = 0.8;
		bg.scale.set(_sizeX, _sizeY);
		bg.updateHitbox();
		bg.screenCenter();
		bg.cameras = cameras;
		add(bg);

		titleText = new FlxText(0, bg.y + 30, 400, _title, 16);
		titleText.screenCenter(X);
		titleText.alignment = CENTER;
		titleText.cameras = cameras;
		add(titleText);

		if (onCreate != null) onCreate(this);
		super.create();
	}

	var _blockInput:Float = 0.1;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		_blockInput = Math.max(0, _blockInput - elapsed);
		if (_blockInput <= 0 && FlxG.keys.justPressed.ESCAPE)
		{
			close();
			return;
		}

		if (onUpdate != null) onUpdate(this, elapsed);
	}

	override function destroy()
	{
		for (member in members) FlxDestroyUtil.destroy(member);
		super.destroy();
	}
}
