package options;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.events.TextEvent;
import backend.GameJoltManager;
import backend.Language;
import backend.Paths;
import lime.system.Clipboard;

using StringTools;
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
	var actionLabel:FlxText;
	var syncLabel:FlxText;

	var curRow:Int    = 0;
	var totalRows:Int = 3;
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

		if (statusTxt == null)
		{
			statusTxt = new FlxText(ExeBaseOptionsState.NB_X + 320, 220, 800, '', lblSize);
			statusTxt.setFormat(font, lblSize, 0xFFFFDD00, LEFT);
			statusTxt.scrollFactor.set(0, 0);
			statusTxt.x = offRight;
			add(statusTxt);
			rightGroup.push(cast statusTxt);
		}

		for (i in 0...3)
		{
			final rowY = ROW_Y0 + i * (ROW_Y1 - ROW_Y0);

			final nameBG = new FlxSprite().loadGraphic(boxBitmap);
			nameBG.scale.set(ExeBaseOptionsState.NB_SCALE_X, ExeBaseOptionsState.NB_SCALE_Y);
			nameBG.updateHitbox();
			nameBG.x = offRight; nameBG.y = rowY;
			nameBG.scrollFactor.set(0, 0);
			add(nameBG); rightGroup.push(nameBG);

			final valBG = new FlxSprite().loadGraphic(boxBitmap);
			valBG.scale.set(ExeBaseOptionsState.VB_SCALE_X, ExeBaseOptionsState.VB_SCALE_Y);
			valBG.updateHitbox();
			valBG.x = offRight; valBG.y = rowY;
			valBG.scrollFactor.set(0, 0);
			add(valBG); rightGroup.push(valBG);

			final nameTxt = new FlxText(offRight, rowY + 10, 300, ['USERNAME', 'TOKEN', 'ACTION'][i], lblSize);
			nameTxt.setFormat(Paths.font('vcr'), lblSize, FlxColor.WHITE, LEFT);
			nameTxt.scrollFactor.set(0, 0);
			add(nameTxt); rightGroup.push(cast nameTxt);

			final valTxt = new FlxText(offRight, rowY + 10, 400, '', lblSize);
			valTxt.setFormat(Paths.font('vcr'), lblSize, FlxColor.WHITE, LEFT);
			valTxt.scrollFactor.set(0, 0);
			add(valTxt); rightGroup.push(cast valTxt);

			optionGroups.push({nameBG: nameBG, valueBG: valBG, nameText: nameTxt, valueText: valTxt});
		}

		userLabel     = optionGroups[0].nameText;
		userValueTxt  = optionGroups[0].valueText;
		tokenLabel    = optionGroups[1].nameText;
		tokenValueTxt = optionGroups[1].valueText;
		actionLabel   = optionGroups[2].nameText;
		syncLabel     = optionGroups[2].valueText;

		tokenLabel.text = 'TOKEN';

		if (GameJoltManager.isLoggedIn())
			_setLoggedInView();
		else
			_setLoggedOutView();
	}

	function _setLoggedOutView():Void
	{
		statusTxt.text     = 'NOT LOGGED IN';
		statusTxt.color    = 0xFFFF6666;
		userLabel.text     = 'USERNAME';
		userValueTxt.text  = usernameInput != '' ? usernameInput : '...';
		tokenLabel.text    = 'TOKEN';
		tokenValueTxt.text = tokenInput != '' ? _maskToken(tokenInput) : '...';
		actionLabel.text   = 'LOGIN';
		syncLabel.text     = '';
	}

	function _setLoggedInView():Void
	{
		statusTxt.text     = 'LOGGED IN: ' + GameJoltManager.getUsername();
		statusTxt.color    = 0xFF88FF88;
		userLabel.text     = 'USERNAME';
		userValueTxt.text  = GameJoltManager.getUsername();
		tokenLabel.text    = 'TOKEN';
		tokenValueTxt.text = _maskToken(tokenInput);
		actionLabel.text   = 'LOGOUT';
		syncLabel.text     = 'SYNC TROPHIES';
	}

	function _maskToken(t:String):String
	{
		if (t.length <= 4) return '****';
		return t.substr(0, 2) + StringTools.rpad('', '*', t.length - 4) + t.substr(t.length - 2);
	}

	override public function getCurrentSelectionIndex():Int return curRow;

	var _typingBuf:String = '';
	var _pendingChars:Array<String> = [];

	function _onTextInput(e:TextEvent):Void
	{
		if (!isTyping) return;
		for (ch in e.text.split(''))
			_pendingChars.push(ch);
	}

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
				statusTxt.text  = 'LOGIN FAILED — SERVER TOOK TOO LONG TO RESPOND';
				statusTxt.color = 0xFFFF6666;
			}
			else _waitingTimer += elapsed;
		}

		super.update(elapsed);
		if (introAnimating || backLock || _waitingLogin) { backLock = false; return; }

		#if mobile
		if(pressHolding && deltaMouseY != 0 && cooldownTimer <= 0) {
			if(deltaMouseY < -5) {
				curRow = (curRow - 1 + totalRows) % totalRows;
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection();
			} else if(deltaMouseY > 5) {
				curRow = (curRow + 1 + totalRows) % totalRows;
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection();
			}
		}
		#end

		if (controls.UI_UP_P || controls.UI_DOWN_P)
		{
			curRow = (curRow + (controls.UI_UP_P ? -1 : 1) + totalRows) % totalRows;
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection();
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
				else if (curRow == 1)
				{
					statusTxt.text  = 'SYNCING...';
					statusTxt.color = 0xFFFFDD00;
					GameJoltManager.syncAllTrophies();
					statusTxt.text  = 'SYNCED!';
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

	function _startTyping(user:Bool):Void
	{
		typingUser    = user;
		_typingBuf    = user ? usernameInput : tokenInput;
		_pendingChars = [];
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
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE)
		{
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
			statusTxt.text  = 'ENTER USERNAME AND TOKEN';
			statusTxt.color = 0xFFFF6666;
			return;
		}
		_waitingLogin   = true;
		statusTxt.text  = 'CONNECTING...';
		statusTxt.color = 0xFFFFDD00;

		trace(usernameInput);
		trace(tokenInput);

		GameJoltManager.login(usernameInput, tokenInput, function(ok:Bool) {
			_waitingLogin = false;
			if (ok) _setLoggedInView();
			else
			{
				statusTxt.text  = 'LOGIN FAILED — CHECK USERNAME/TOKEN';
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
