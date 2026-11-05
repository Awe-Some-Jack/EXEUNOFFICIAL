package options;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import openfl.events.TextEvent;

import lime.system.Clipboard;

import backend.GameJoltManager;

class ExeGameJoltState extends ExeBaseOptionsState
{
	static inline final ROW_Y0:Float = 290;
	static inline final ROW_Y1:Float = 370;
	static inline final ROW_Y2:Float = 450;
	static inline final TIMEOUT_THRESHOLD:Int = 30;

	var statusTxt:FlxText;
	var userLabel:FlxText;
	var tokenLabel:FlxText;
	var userValueTxt:FlxText;
	var tokenValueTxt:FlxText;

	var actionBG:FlxSprite;
	var actionValueTxt:FlxText;
	
	var syncBG:FlxSprite;
	var syncValueTxt:FlxText;

	var curRow:Int    = 0;
	var totalRows:Int = GameJoltManager.isLoggedIn() ? 4 : 3;
	var isTyping:Bool = false;
	var typingUser:Bool = true;

	var usernameInput:String = '';
	var tokenInput:String    = '';

	var _waitingLogin:Bool = false;
	var _waitingTimer:Float = 0;

	override public function create()
	{
		menuTitle = 'GAMEJOLT';
		usernameInput = GameJoltManager.getSavedUsername();
		tokenInput    = GameJoltManager.getSavedToken();

		super.create();

		titlebarTxt.text = menuTitle;

		FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, _onKey);
		FlxG.stage.addEventListener(TextEvent.TEXT_INPUT, _onTextInput);
	}

	override public function loadPage():Void
	{
		final lblSize = Language.scaledFontSize(ExeBaseOptionsState.FONT_SIZE);
		final font    = Paths.font(ExeBaseOptionsState.getLangFont());
		final offRight:Float = FlxG.width + 200;
		final boxBitmap = Paths.getBitmapData('assets/exe/options/propertyBG.webp');
		
		final labels = Language.getArray('gamejolt.labels', ['USERNAME', 'TOKEN', 'ACTION', 'TROPHIES']);

		if (statusTxt == null)
		{
			statusTxt = new FlxText(offRight, 180, 450, '', lblSize);
			statusTxt.setFormat(font, lblSize + 8, 0xFFFFDD00, RIGHT, OUTLINE, 0xFF000000);
			statusTxt.scrollFactor.set(0, 0);
			statusTxt.borderSize = 2.23;
			add(statusTxt);

			final rightPadding = 20;
			FlxTween.tween(statusTxt, {x: (FlxG.width - statusTxt.width)-rightPadding}, 0.45, {ease: FlxEase.quartOut});
		}

		for (i in 0...4)
		{
			final rowY = ROW_Y0 + i * (ROW_Y1 - ROW_Y0);

			final nameBG = new FlxSprite(offRight, rowY).loadGraphic(boxBitmap);
			nameBG.scale.set(ExeBaseOptionsState.NB_SCALE_X, ExeBaseOptionsState.NB_SCALE_Y);
			nameBG.updateHitbox();
			nameBG.scrollFactor.set(0, 0);
			nameBG.ID = i;
			add(nameBG); rightGroup.push(nameBG);

			final valBG = new FlxSprite(offRight, rowY).loadGraphic(boxBitmap);
			valBG.scale.set(ExeBaseOptionsState.VB_SCALE_X, ExeBaseOptionsState.VB_SCALE_Y);
			valBG.updateHitbox();
			valBG.scrollFactor.set(0, 0);
			valBG.ID = i;
			add(valBG); rightGroup.push(valBG);

			final nameTxt = new FlxText(offRight, rowY + 10, 300, labels[i], lblSize);
			nameTxt.setFormat(Paths.font(Language.fontOrCJK('vcr.ttf')), lblSize, FlxColor.WHITE, LEFT);
			nameTxt.scrollFactor.set(0, 0);
			nameTxt.ID = i;
			add(nameTxt); rightGroup.push(cast nameTxt);

			final valTxt = new FlxText(offRight, rowY + 10, (i > 1) ? -1 : 400, '', lblSize);
			valTxt.setFormat(Paths.font(Language.fontOrCJK('vcr.ttf')), lblSize, FlxColor.WHITE, LEFT);
			valTxt.scrollFactor.set(0, 0);
			valTxt.ID = i;
			add(valTxt); rightGroup.push(cast valTxt);

			if (i >= 2)
			{
				nameBG.visible = false;
				nameTxt.visible = false;
				valTxt.x = valBG.x + ((valBG.width - valTxt.width)/2);
				if (i == 3)
				{
					valBG.visible = GameJoltManager.isLoggedIn();
					valTxt.visible = GameJoltManager.isLoggedIn();
				}
			}

			optionGroups.push({nameBG: nameBG, valueBG: valBG, nameText: nameTxt, valueText: valTxt});
		}

		userLabel     = optionGroups[0].nameText;
		userValueTxt  = optionGroups[0].valueText;
		tokenLabel    = optionGroups[1].nameText;
		tokenValueTxt = optionGroups[1].valueText;
		actionBG      = optionGroups[2].valueBG;
		actionValueTxt= optionGroups[2].valueText;
		syncBG        = optionGroups[3].valueBG;
		syncValueTxt  = optionGroups[3].valueText;

		tokenLabel.text = labels[1];

		if (GameJoltManager.isLoggedIn())
			_setLoggedInView();
		else
			_setLoggedOutView();
	}

	function _setLoggedOutView():Void
	{
		final labels = Language.getArray('gamejolt.labels', ['USERNAME', 'TOKEN', 'ACTION', 'TROPHIES']);
		statusTxt.text     = Language.get('gamejolt.status.notloggedin', 'NOT LOGGED IN');
		statusTxt.color    = 0xFFFF6666;
		userLabel.text     = labels[0];
		userValueTxt.text  = usernameInput != '' ? usernameInput : '...';
		tokenLabel.text    = labels[1];
		tokenValueTxt.text = tokenInput != '' ? _maskToken(tokenInput) : '...';
		actionValueTxt.text   = Language.get('gamejolt.action.login', 'LOGIN');
		syncValueTxt.text     = '';
		syncValueTxt.visible = false;
		syncBG.visible = false;
		totalRows = 3;
	}

	function _setLoggedInView():Void
	{
		final labels = Language.getArray('gamejolt.labels', ['USERNAME', 'TOKEN', 'ACTION', 'TROPHIES']);
		statusTxt.text     = Language.getPhrase('gamejolt.status.loggedin', 'LOGGED IN: {1}', [GameJoltManager.getUsername()]);
		statusTxt.color    = 0xFFEBFF88;
		userLabel.text     = labels[0];
		userValueTxt.text  = GameJoltManager.getUsername();
		tokenLabel.text    = labels[1];
		tokenValueTxt.text = _maskToken(tokenInput);
		actionValueTxt.text   = Language.get('gamejolt.action.logout', 'LOGOUT');
		syncValueTxt.text     = Language.get('gamejolt.action.sync', 'SYNC TROPHIES');
		syncValueTxt.visible = true;
		syncBG.visible = true;
		totalRows = 4;
	}

	function _maskToken(t:String):String
	{
		return StringTools.rpad('', '*', t.length);
	}

	override public function getCurrentSelectionIndex():Int return curRow;

	var _typingBuf:String = '';
	var _pendingChars:Array<String> = [];
	var _typingTapArmed:Bool = false;

	function _onTextInput(e:TextEvent):Void
	{
		if (!isTyping) return;
		for (ch in e.text.split(''))
			_pendingChars.push(ch);
	}

	var syncStatusHoldingTime:Float = 3;

	override public function update(elapsed:Float)
	{
		if (isTyping)
		{
			_handleTyping();
			_updateTypingDisplay();
			return;
		}

		if(_waitingLogin)
		{
			if(_waitingTimer > TIMEOUT_THRESHOLD) 
			{
				_waitingTimer = 0;
				_waitingLogin = false;
				statusTxt.text  = Language.get('gamejolt.status.timeout', 'LOGIN FAILED — SERVER TOOK TOO LONG TO RESPOND');
				statusTxt.color = 0xFFFF6666;
			}
			else _waitingTimer += elapsed;
		}

		super.update(elapsed);
		
		if (introAnimating || backLock || _waitingLogin) { backLock = false; return; }

		if (statusTxt.text  == Language.get('gamejolt.status.synced', 'SYNCED!'))
		{
			if (syncStatusHoldingTime <= 0)
				statusTxt.text = Language.getPhrase('gamejolt.status.loggedin', 'LOGGED IN: {1}', [GameJoltManager.getUsername()]);

			syncStatusHoldingTime -= elapsed;
		}

		#if mobile
		if(pressHolding && deltaMouseY != 0 && cooldownTimer <= 0) 
		{
			if(deltaMouseY < -5) {
				curRow = (curRow - 1 + totalRows) % totalRows;
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(curRow>1);
			} else if(deltaMouseY > 5) {
				curRow = (curRow + 1 + totalRows) % totalRows;
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(curRow>1);
			}
		}
		#end

		if (controls.UI_UP_P || controls.UI_DOWN_P)
		{
			curRow = (curRow + (controls.UI_UP_P ? -1 : 1) + totalRows) % totalRows;
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection(curRow>1);
		}

		if (controls.ACCEPT #if mobile || (shortPress && !buttonOverlaps) #end)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			if (GameJoltManager.isLoggedIn())
			{
				if (curRow == 2)
				{
					GameJoltManager.logout();
					usernameInput = '';
					tokenInput    = '';
					_setLoggedOutView();
				}
				else if (curRow == 3)
				{
					statusTxt.text  = Language.get('gamejolt.status.syncing', 'SYNCING...');
					statusTxt.color = 0xFFFFDD00;
					GameJoltManager.syncAllTrophies();
					statusTxt.text  = Language.get('gamejolt.status.synced', 'SYNCED!');
					syncStatusHoldingTime = 3;
					statusTxt.color = 0xFF88FF88;
				}
			}
			else
			{
				if (curRow == 0)      { _startTyping(true); }
				else if (curRow == 1) { _startTyping(false); }
				else if (curRow == 2) _doLogin();
			}
		}

		if (controls.BACK #if mobile || backPressed #end) { FlxG.sound.play(Paths.sound('cancelMenu')); playOutro(); }
	}

	override public function playOutro()
	{
		if (statusTxt != null)
		{
			FlxTween.tween(statusTxt, {x: FlxG.width + 200}, 0.35, {ease: FlxEase.quartIn});
		}

		super.playOutro();
	}

	function _startTyping(user:Bool):Void
	{
		typingUser    = user;
		_typingBuf    = user ? usernameInput : tokenInput;
		_pendingChars = [];
		_typingTapArmed = false;
		isTyping      = true;
		FlxG.stage.window.textInputEnabled = true;
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function _stopTyping():Void
	{
		isTyping = false;
		FlxG.stage.window.textInputEnabled = false;
		_pendingChars = [];
	}

	function _handleTyping():Void
	{
		var tapped:Bool = false;
		#if mobile
		for (t in FlxG.touches.list)
		{
			if (t.justPressed) _typingTapArmed = true;
			if (t.justReleased && _typingTapArmed) tapped = true;
		}
		#end
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE || tapped)
		{
			_typingTapArmed = false;
			if (typingUser) usernameInput = _typingBuf;
			else            tokenInput    = _typingBuf;
			_stopTyping();
			if (typingUser) userValueTxt.text  = usernameInput != '' ? usernameInput : '...';
			else            tokenValueTxt.text = tokenInput != '' ? _maskToken(tokenInput) : '...';
			return;
		}

		if(isTyping && FlxG.keys.justPressed.V && FlxG.keys.pressed.CONTROL) 
			_typingBuf += Clipboard.text.trim();

		if (FlxG.keys.justPressed.BACKSPACE && _typingBuf.length > 0)
			_typingBuf = _typingBuf.substr(0, _typingBuf.length - 1);

		for (ch in _pendingChars)
			if (_typingBuf.length < 30) _typingBuf += ch;
		_pendingChars = [];
	}

	function _updateTypingDisplay():Void
	{
		final cursor = (Math.sin(Date.now().getTime() / 300) > 0) ? '|' : ' ';
		if (typingUser)
			userValueTxt.text = _typingBuf + cursor;
		else
			tokenValueTxt.text = _typingBuf + cursor;
	}

	function _doLogin():Void
	{
		if (usernameInput == '' || tokenInput == '')
		{
			statusTxt.text  = Language.get('gamejolt.status.empty', 'ENTER USERNAME AND TOKEN');
			statusTxt.color = 0xFFFF6666;
			return;
		}
		_waitingLogin   = true;
		statusTxt.text  = Language.get('gamejolt.status.connecting', 'CONNECTING...');
		statusTxt.color = 0xFFFFDD00;

		trace(usernameInput);
		// not this time friend
		// trace(tokenInput);

		GameJoltManager.login(usernameInput, tokenInput, function(ok:Bool) {
			_waitingLogin = false;
			if (ok) _setLoggedInView();
			else
			{
				statusTxt.text  = Language.get('gamejolt.status.failed', 'LOGIN FAILED — CHECK USERNAME/TOKEN');
				statusTxt.color = 0xFFFF6666;
			}
		});
	}

	function _onKey(e:openfl.events.KeyboardEvent):Void {}

	override public function destroy():Void
	{
		FlxG.stage.removeEventListener(openfl.events.KeyboardEvent.KEY_DOWN, _onKey);
		FlxG.stage.removeEventListener(TextEvent.TEXT_INPUT, _onTextInput);
		if (isTyping) FlxG.stage.window.textInputEnabled = false;
		super.destroy();
	}
}