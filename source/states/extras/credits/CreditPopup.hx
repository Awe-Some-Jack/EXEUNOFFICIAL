package states.extras.credits;

import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.GradientType;
import openfl.geom.Matrix;
import openfl.display.Shape;
import flixel.graphics.frames.FlxAtlasFrames;
import states.extras.credits.CreditsState;
import states.extras.credits.CreditsState.Credit;

class CreditPopup extends MusicBeatSubstate
{
	static inline final ICON_SIZE:Int    = 100;
	static inline final EXTRA_SIZE:Int   = 200;
	static inline final BORDER_SIZE:Int  = 16;
	static inline final CORNER_R:Int     = 100;

	var selectedUser:Credit;

	var popupCamera:FlxCamera;
	var quoteCam:FlxCamera;

	var bg:FlxSprite;
	var userIcon:FlxSprite;
	var userQuote:FlxText;
	var scrollBar:FlxSprite;
	var explosion:FlxSprite;

	var twitterBtn:FlxSprite;
	var youtubeBtn:FlxSprite;

	#if VIDEOS_ALLOWED
	var userVideo:hxvlc.flixel.FlxVideoSprite;
	var pauseBtn:FlxSprite;
	var videoPaused:Bool = false;
	#end

	var savedIconScale:Float = 1;
	var iconClickSpeed:Float  = 0;
	var canClick:Bool         = true;
	var pressingBtn:String    = '';

	override function create()
	{
		super.create();

		popupCamera = new FlxCamera();
		popupCamera.bgColor = 0x00000000;
		FlxG.cameras.add(popupCamera, false);

		selectedUser = CreditsState.credits.get(CreditsState.userSelected[0])[CreditsState.userSelected[1]];

		_buildBackground();
		_buildHeader();
		_buildDescription();
		_buildQuotePanel();
		_buildExplosion();
		_buildExtra();
		_buildSocialButtons();
		_animateIn();
	}

	function _buildBackground():Void
	{
		final w = Std.int(FlxG.width  - 100);
		final h = Std.int(FlxG.height - 100);

		final c1 = selectedUser.colors != null && selectedUser.colors.length > 0 ? selectedUser.colors[0] : [115, 14, 78];
		final c2 = selectedUser.colors != null && selectedUser.colors.length > 1 ? selectedUser.colors[1] : [169, 23, 30];

		final dim = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x88000000);
		dim.camera = popupCamera;
		dim.scrollFactor.set(0, 0);
		add(dim);

		final shape = new Shape();
		final matrix = new Matrix();
		matrix.createGradientBox(w, h, Math.PI / 2);
		shape.graphics.beginGradientFill(GradientType.LINEAR,
			[FlxColor.fromRGB(c1[0], c1[1], c1[2]), FlxColor.fromRGB(c2[0], c2[1], c2[2])],
			[1, 1], [0, 255], matrix);
		shape.graphics.drawRoundRect(0, 0, w, h, CORNER_R, CORNER_R);
		shape.graphics.endFill();

		final bmp = new BitmapData(w, h, true, 0x00000000);
		bmp.draw(shape);
		bg = new FlxSprite().loadGraphic(bmp);
		bg.screenCenter();
		bg.camera = popupCamera;

		final borderShape = new Shape();
		borderShape.graphics.lineStyle(BORDER_SIZE * 0.5, 0xFFFFFFFF, 0.12);
		borderShape.graphics.drawRoundRect(BORDER_SIZE * 0.25, BORDER_SIZE * 0.25,
			w - BORDER_SIZE * 0.5, h - BORDER_SIZE * 0.5, CORNER_R - BORDER_SIZE * 0.25, CORNER_R - BORDER_SIZE * 0.25);
		bmp.draw(borderShape);

		add(bg);
	}

	function _buildHeader():Void
	{
		final iconPath = _resolveAsset(
			'assets/exe/extras/credits/${CreditsState.userSelected[0]}/icons/${selectedUser.icon}.png',
			selectedUser.icon != null,
			'assets/exe/extras/credits/missing_icon.png');

		userIcon = new FlxSprite(bg.x + 40, bg.y + 40).loadGraphic(iconPath);
		userIcon.camera = popupCamera;
		_fitSprite(userIcon, ICON_SIZE, ICON_SIZE);
		savedIconScale = userIcon.scale.x;
		add(userIcon);

		final userName = new FlxText(0, 0, bg.width - 100, selectedUser.name ?? "Unknown");
		userName.setFormat(Paths.font("vcr.ttf"), 76, 0xFFFFFFFF, LEFT, OUTLINE, 0x55000000);
		userName.borderSize = 3;
		userName.setPosition(userIcon.x + userIcon.width + 25, userIcon.y + (userIcon.height - userName.height) / 2);
		userName.camera = popupCamera;
		add(userName);

		final flagPath = _resolveAsset(
			'assets/exe/extras/credits/countries/${selectedUser.nation}.png',
			selectedUser.nation != null,
			'assets/exe/extras/credits/missing_country.png');
		final flag = new FlxSprite().loadGraphic(flagPath);
		flag.setPosition(Std.int(userName.x + userName.textField.textWidth + 15),
			Std.int(userName.y + (userName.height - flag.height) / 2));
		flag.camera = popupCamera;
		add(flag);
	}

	function _buildDescription():Void
	{
		final sepW  = Std.int(bg.width / 2 - 50);
		final sepY  = userIcon.y + userIcon.height + 25;
		final sepX  = userIcon.x;

		final sepBmp = new BitmapData(sepW, 3, true, 0x00000000);
		for (x in 0...sepW)
		{
			final t = x / (sepW - 1);
			final a = Std.int(255 * (1.0 - Math.abs(t * 2 - 1)));
			sepBmp.setPixel32(x, 0, (a << 24) | 0xFFFFFF);
			sepBmp.setPixel32(x, 1, (a << 24) | 0xFFFFFF);
			sepBmp.setPixel32(x, 2, (Std.int(a * 0.4) << 24) | 0xFFFFFF);
		}
		final sep = new FlxSprite(sepX, sepY).loadGraphic(sepBmp);
		sep.camera = popupCamera;
		add(sep);

		final desc = new FlxText(sepX, sep.y + 22, sepW, selectedUser.description ?? "No Description");
		desc.setFormat(Paths.font("vcr.ttf"), 38, 0xFFFFFFFF, CENTER, OUTLINE, 0x66000000);
		desc.borderSize = 2;
		desc.camera = popupCamera;
		add(desc);
	}

	function _buildQuotePanel():Void
	{
		final qw = Std.int(bg.width  * 0.4);
		final qh = Std.int(bg.height * 0.6);
		final qx = bg.x + bg.width  - qw - 50;
		final qy = bg.y + bg.height - qh - 50;

		final panelBmp = new BitmapData(qw, qh, true, 0x00000000);
		panelBmp.fillRect(new openfl.geom.Rectangle(0, 0, qw, qh), 0x77000000);
		final panelSprite = new FlxSprite(qx, qy).loadGraphic(panelBmp);
		final panelShader = new shaders.RoundedBorderShader(14.0, 0.0, 0xFF000000);
		panelShader.setSize(qw, qh);
		panelSprite.shader  = panelShader;
		panelSprite.camera  = popupCamera;
		add(panelSprite);

		final borderBmp = new BitmapData(qw, qh, true, 0x00000000);
		final bShape = new Shape();
		bShape.graphics.lineStyle(1.5, 0xFFFFFFFF, 0.15);
		bShape.graphics.drawRoundRect(1, 1, qw - 2, qh - 2, 14, 14);
		borderBmp.draw(bShape);
		final borderSpr = new FlxSprite(qx, qy).loadGraphic(borderBmp);
		borderSpr.camera = popupCamera;
		add(borderSpr);

		quoteCam = new FlxCamera();
		quoteCam.bgColor = 0x00000000;
		quoteCam.setSize(qw - 10, qh - 10);
		quoteCam.setPosition(qx + 5, qy + 5);
		FlxG.cameras.add(quoteCam, false);

		userQuote = new FlxText(5, 5, quoteCam.width - 15, selectedUser.quote ?? "No Quote");
		userQuote.setFormat(Paths.font("vcr.ttf"), 24, 0xFFFFFFFF, LEFT, NONE);
		userQuote.camera = quoteCam;
		add(userQuote);

		final scrollBG = new FlxSprite(quoteCam.width - 5).makeGraphic(5, quoteCam.height, 0x44FFFFFF);
		scrollBG.camera = quoteCam;
		scrollBG.scrollFactor.set();
		add(scrollBG);

		final barH = Std.int(Math.max(40, (quoteCam.height / userQuote.height) * quoteCam.height));
		scrollBar = new FlxSprite(quoteCam.width - 5).makeGraphic(5, barH, 0xCCFFFFFF);
		scrollBar.visible = (userQuote.height - 10) > quoteCam.height;
		scrollBar.camera = quoteCam;
		scrollBar.scrollFactor.set();
		add(scrollBar);
	}

	function _buildExplosion():Void
	{
		explosion = new FlxSprite(userIcon.x - 50, userIcon.y - 100);
		explosion.frames = FlxAtlasFrames.fromSparrow('assets/exe/extras/credits/explosion.png', 'assets/exe/extras/credits/explosion.xml');
		explosion.animation.addByPrefix('idle', 'idle', 16, false);
		explosion.animation.play('idle');
		explosion.scale.set(3, 3);
		explosion.antialiasing = false;
		explosion.updateHitbox();
		explosion.alpha = 0;
		explosion.camera = popupCamera;
		add(explosion);
	}

	function _buildExtra():Void
	{
		if (selectedUser.extra == null) return;

		if (selectedUser.extra[0] == 'video')
		{
			final affectsMusic:Bool = selectedUser.extra[2] != true;
			if (affectsMusic)
			{
				FlxTween.cancelTweensOf(FlxG.sound.music);
				FlxTween.tween(FlxG.sound.music, {volume: 0.3}, 0.6);
			}

			#if VIDEOS_ALLOWED
			pauseBtn = new FlxSprite().loadGraphic('assets/exe/extras/credits/play.png');
			pauseBtn.alpha = 0;
			pauseBtn.camera = popupCamera;

			userVideo = new hxvlc.flixel.FlxVideoSprite(0, 0);
			userVideo.bitmap.onFormatSetup.add(() -> {
				_fitSprite(userVideo, EXTRA_SIZE, EXTRA_SIZE);
				userVideo.setPosition(
					bg.x + 40 + ((bg.width / 2 - 50) - userVideo.width) / 2,
					bg.y + bg.height - userVideo.height - 50);
				pauseBtn.setPosition(
					userVideo.x + (userVideo.width  - pauseBtn.width)  / 2,
					userVideo.y + (userVideo.height - pauseBtn.height) / 2);
			});
			userVideo.bitmap.onEndReached.add(_playVideo);
			userVideo.camera = popupCamera;
			add(userVideo);
			add(pauseBtn);
			_playVideo();
			#end
		}
		else if (selectedUser.extra[0] == 'image')
		{
			final img = new FlxSprite(0, 0).loadGraphic(
				'assets/exe/extras/credits/${CreditsState.userSelected[0]}/extra/${selectedUser.extra[1]}');
			_fitSprite(img, EXTRA_SIZE, EXTRA_SIZE);
			img.setPosition(
				bg.x + 40 + ((bg.width / 2 - 50) - img.width) / 2,
				bg.y + bg.height - img.height - 50);
			final imgShader = new shaders.RoundedBorderShader(10.0, 0.0, 0xFF000000);
			imgShader.setSize(img.frameWidth, img.frameHeight);
			img.shader = imgShader;
			img.camera = popupCamera;
			add(img);
		}
	}

	function _buildSocialButtons():Void
	{
		var socialY = quoteCam.y + quoteCam.height + 10;

		if (selectedUser.youtube != null)
		{
			youtubeBtn = new FlxSprite().loadGraphic('assets/exe/extras/credits/youtube.png');
			youtubeBtn.setPosition(quoteCam.x - youtubeBtn.width - 15, socialY - youtubeBtn.height);
			youtubeBtn.camera = popupCamera;
			youtubeBtn.color  = 0xFF686868;
			youtubeBtn.scale.set(0.9, 0.9);
			youtubeBtn.updateHitbox();
			add(youtubeBtn);
			socialY -= youtubeBtn.height + 10;
		}

		if (selectedUser.twitter != null)
		{
			twitterBtn = new FlxSprite().loadGraphic('assets/exe/extras/credits/twitter.png');
			twitterBtn.setPosition(quoteCam.x - twitterBtn.width - 15, socialY - twitterBtn.height);
			twitterBtn.camera = popupCamera;
			twitterBtn.color  = 0xFF686868;
			twitterBtn.scale.set(0.9, 0.9);
			twitterBtn.updateHitbox();
			add(twitterBtn);
		}
	}

	function _animateIn():Void
	{
		bg.scale.set(0.85, 0.85);
		bg.alpha = 0;
		FlxTween.tween(bg,       {alpha: 1},                                    0.25, {ease: FlxEase.quadOut});
		FlxTween.tween(bg.scale, {x: 1.0, y: 1.0},                             0.3,  {ease: FlxEase.backOut});
		popupCamera.alpha = 0;
		FlxTween.tween(popupCamera, {alpha: 1},                                 0.2,  {ease: FlxEase.quadOut});
	}

	override function update(elapsed:Float)
	{
		_updateQuoteScroll();
		_updateSocialButtons();
		_updateVideoClick();
		_updateIconClick(elapsed);
		_updateNavigation();
		super.update(elapsed);
	}

	function _updateQuoteScroll():Void
	{
		if (!_mouseOverCam(quoteCam) || FlxG.mouse.deltaWheel.y == 0) return;
		quoteCam.scroll.y -= FlxG.mouse.deltaWheel.y * 22;
		quoteCam.scroll.y  = FlxMath.bound(quoteCam.scroll.y, 0, Math.max(0, userQuote.height - quoteCam.height + 10));
		scrollBar.y = FlxMath.lerp(0, quoteCam.height - scrollBar.height,
			quoteCam.scroll.y / Math.max(1, userQuote.height - quoteCam.height + 10));
	}

	function _updateSocialButtons():Void
	{
		_handleSocialBtn(twitterBtn, 'twitter', selectedUser.twitter);
		_handleSocialBtn(youtubeBtn, 'youtube', selectedUser.youtube);
	}

	function _handleSocialBtn(btn:FlxSprite, id:String, url:String):Void
	{
		if (btn == null || url == null) return;
		final hovering = FlxG.mouse.overlaps(btn);

		if (pressingBtn == '')
		{
			if (hovering)
			{
				btn.color = 0xFFFFFFFF;
				FlxTween.cancelTweensOf(btn.scale);
				if (btn.scale.x < 1.0) FlxTween.tween(btn.scale, {x: 1.0, y: 1.0}, 0.12, {ease: FlxEase.backOut});
			}
			else
			{
				btn.color = 0xFF686868;
				FlxTween.cancelTweensOf(btn.scale);
				if (btn.scale.x > 0.9) FlxTween.tween(btn.scale, {x: 0.9, y: 0.9}, 0.1, {ease: FlxEase.quadOut});
			}
		}

		if (hovering && FlxG.mouse.justPressed)  { btn.color = 0xFFCCCCCC; pressingBtn = id; }
		if (FlxG.mouse.released && pressingBtn == id) { pressingBtn = ''; CoolUtil.browserLoad(url); }
	}

	function _updateVideoClick():Void
	{
		#if VIDEOS_ALLOWED
		if (userVideo == null || !FlxG.mouse.overlaps(userVideo) || !FlxG.mouse.justPressed) return;
		final affectsMusic:Bool = selectedUser.extra[2] != true;

		videoPaused = !videoPaused;
		if (videoPaused)
		{
			userVideo.pause();
			FlxTween.cancelTweensOf(pauseBtn); FlxTween.cancelTweensOf(pauseBtn.scale);
			pauseBtn.loadGraphic('assets/exe/extras/credits/pause.png');
			pauseBtn.scale.set(1, 1);
			pauseBtn.alpha = 1;
			if (affectsMusic) { FlxTween.cancelTweensOf(FlxG.sound.music); FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.6); }
		}
		else
		{
			userVideo.resume();
			pauseBtn.loadGraphic('assets/exe/extras/credits/play.png');
			FlxTween.tween(pauseBtn.scale, {x: 0, y: 0}, 0.3);
			FlxTween.tween(pauseBtn, {alpha: 0}, 0.3);
			if (affectsMusic) { FlxTween.cancelTweensOf(FlxG.sound.music); FlxTween.tween(FlxG.sound.music, {volume: 0.3}, 0.6); }
		}
		#end
	}

	function _updateIconClick(elapsed:Float):Void
	{
		if (iconClickSpeed > 0) iconClickSpeed -= elapsed * (2 + iconClickSpeed * 0.5);
		if (iconClickSpeed < 0) iconClickSpeed = 0;

		if (userIcon == null) return;

		final hovering = FlxG.mouse.overlaps(userIcon);
		if (canClick && hovering && userIcon.scale.x <= savedIconScale + 0.001)
		{
			FlxTween.cancelTweensOf(userIcon.scale);
			FlxTween.tween(userIcon.scale, {x: savedIconScale * 1.08, y: savedIconScale * 1.08}, 0.12, {ease: FlxEase.quadOut});
		}
		else if (canClick && !hovering && userIcon.scale.x > savedIconScale + 0.001 && iconClickSpeed == 0)
		{
			FlxTween.cancelTweensOf(userIcon.scale);
			FlxTween.tween(userIcon.scale, {x: savedIconScale, y: savedIconScale}, 0.15, {ease: FlxEase.quadOut});
		}

		if (!canClick || !FlxG.mouse.justPressed || !hovering) return;

		FlxTween.cancelTweensOf(userIcon); FlxTween.cancelTweensOf(userIcon.scale);
		userIcon.flipX = FlxG.random.bool();
		userIcon.angle = FlxG.random.float(-45, 45);
		userIcon.scale.set(
			FlxG.random.float(savedIconScale * 0.5, savedIconScale * 1.5),
			FlxG.random.float(savedIconScale * 0.5, savedIconScale * 1.5));
		FlxTween.tween(userIcon,       {angle: 0},                             0.3, {ease: FlxEase.backOut});
		FlxTween.tween(userIcon.scale, {x: savedIconScale, y: savedIconScale}, 0.3, {ease: FlxEase.backOut});
		FlxG.sound.play(Paths.sound('honksound'));
		iconClickSpeed++;

		if (iconClickSpeed > 10)
		{
			iconClickSpeed = 0;
			canClick = false;
			explosion.alpha = 1;
			explosion.animation.play('idle');
			userIcon.alpha = 0;
			FlxG.sound.play(Paths.sound('explosion'));
		}
	}

	function _updateNavigation():Void
	{
		if (controls.BACK) { _close(); return; }

		final list = CreditsState.credits.get(CreditsState.userSelected[0]);
		final len  = list != null ? list.length : 1;

		if (controls.UI_LEFT_P)  _navigateTo(FlxMath.wrap(Std.int(CreditsState.userSelected[1]) - 1, 0, len - 1));
		if (controls.UI_RIGHT_P) _navigateTo(FlxMath.wrap(Std.int(CreditsState.userSelected[1]) + 1, 0, len - 1));
	}

	function _navigateTo(index:Int):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		CreditsState.userSelected[1] = index;
		_close();
		new FlxTimer().start(0, (_) -> FlxG.state.openSubState(new CreditPopup()));
	}

	function _close():Void
	{
		if (pauseBtn != null) { FlxTween.cancelTweensOf(pauseBtn); FlxTween.cancelTweensOf(pauseBtn.scale); }
		if (userIcon != null) { FlxTween.cancelTweensOf(userIcon); FlxTween.cancelTweensOf(userIcon.scale); }
		close();
	}

	#if VIDEOS_ALLOWED
	function _playVideo():Void
	{
		final path = 'assets/exe/extras/credits/${CreditsState.userSelected[0]}/extra/${selectedUser.extra[1]}.mp4';
		if (userVideo.load(path))
			new FlxTimer().start(0.001, (_) -> { userVideo.play(); userVideo.bitmap.rate = 1.0; });
	}

	override function onFocus():Void
	{
		super.onFocus();
		if (videoPaused && userVideo != null) userVideo.resume();
	}

	override function onFocusLost():Void
	{
		super.onFocusLost();
		if (!videoPaused && userVideo != null) userVideo.pause();
	}
	#end

	function _fitSprite(s:FlxSprite, tw:Float, th:Float):Void
	{
		final scale = Math.max(tw / s.width, th / s.height);
		s.setGraphicSize(Math.floor(s.width * scale), Math.floor(s.height * scale));
		s.updateHitbox();
	}

	function _resolveAsset(preferred:String, condition:Bool, fallback:String):String
		return (condition && FileSystem.exists(preferred)) ? preferred : fallback;

	function _mouseOverCam(cam:FlxCamera):Bool
		return FlxG.mouse.viewX >= cam.x && FlxG.mouse.viewX <= cam.x + cam.width
			&& FlxG.mouse.viewY >= cam.y && FlxG.mouse.viewY <= cam.y + cam.height;

	override function destroy()
	{
		#if VIDEOS_ALLOWED
		if (userVideo != null) { userVideo.destroy(); userVideo = null; }
		#end
		FlxG.cameras.remove(quoteCam,    true);
		FlxG.cameras.remove(popupCamera, true);
		super.destroy();
	}
}
