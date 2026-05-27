package states.extras.credits;

import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.GradientType;
import openfl.geom.Matrix;
import openfl.display.Shape;

import states.extras.credits.CreditsState;
import states.extras.credits.CreditsState.Credit;

class CreditPopup extends MusicBeatSubstate
{
	var selectedUser:Credit;

	var popupCamera:FlxCamera;
	var quoteBG:FlxCamera;
	var bg:FlxSprite;
	var userQuote:FlxText;
	var scrollBar:FlxSprite;

	#if VIDEOS_ALLOWED
	var userVideo:hxvlc.flixel.FlxVideoSprite;
	#end
	var userImage:FlxSprite;

	var twitterSocial:FlxSprite;
	var youtubeSocial:FlxSprite;

	override function create()
	{
		super.create();

		popupCamera = new FlxCamera();
		popupCamera.bgColor = 0x66000000;
		FlxG.cameras.add(popupCamera, false);

		selectedUser = CreditsState.credits.get(CreditsState.userSelected[0])[CreditsState.userSelected[1]];

		var shape = new Shape();
		var matrix = new Matrix();
		matrix.createGradientBox(Std.int(FlxG.width - 100), Std.int(FlxG.height - 100), Math.PI / 2);
		var firstColor = (selectedUser.colors != null && selectedUser.colors.length > 0) ? selectedUser.colors[0] : [115, 14, 78];
		var secondColor = (selectedUser.colors != null && selectedUser.colors.length > 1 ) ? selectedUser.colors[1] : [169, 23, 30];
		shape.graphics.beginGradientFill(GradientType.LINEAR, [
				FlxColor.fromRGB(firstColor[0], firstColor[1], firstColor[2]),
				FlxColor.fromRGB(secondColor[0], secondColor[1], secondColor[2])
			], [1, 1], [0, 255], matrix);
		shape.graphics.drawRoundRect(0, 0, Std.int(FlxG.width - 100), Std.int(FlxG.height - 100), 100, 100);
		shape.graphics.endFill();
		var borderSize = 16;
		shape.graphics.lineStyle(borderSize, 0x2A000000, 0.5);
		shape.graphics.drawRoundRect(borderSize / 2, borderSize / 2, Std.int(FlxG.width - 100) - borderSize, Std.int(FlxG.height - 100) - borderSize, 100 - borderSize, 100 - borderSize);
		var bmp = new BitmapData(Std.int(FlxG.width - 100), Std.int(FlxG.height - 100), true, 0x00000000);
		bmp.draw(shape);
		bg = new FlxSprite().loadGraphic(bmp);
		bg.screenCenter();
		bg.camera = popupCamera;
		add(bg);

		var iconPath:String = "assets/exe/extras/credits/missing_icon.png";
		if (selectedUser.icon != null && FileSystem.exists('assets/exe/extras/credits/${CreditsState.userSelected[0]}/icons/${selectedUser.icon}.png')) iconPath = 'assets/exe/extras/credits/${CreditsState.userSelected[0]}/icons/${selectedUser.icon}.png';
		var userIcon:FlxSprite = new FlxSprite(bg.x + 40, bg.y + 40).loadGraphic(iconPath);
		userIcon.camera = popupCamera;
		setImageSize(userIcon, 100, 100);
		add(userIcon);

		var userName:FlxText = new FlxText(0, 0, bg.width - 100, (selectedUser.name != null) ? selectedUser.name : "Unknown");
		userName.setFormat(Paths.font("vcr.ttf"), 76, 0xFFFFFFFF, LEFT, NONE);
		userName.setPosition(userIcon.x + userIcon.width + 25, userIcon.y + (userIcon.height - userName.height) / 2);
		userName.camera = popupCamera;
		add(userName);

		var countryPath:String = "assets/exe/extras/credits/missing_country.png";
		if (selectedUser.nation != null && FileSystem.exists('assets/exe/extras/credits/countries/${selectedUser.nation}.png')) countryPath = 'assets/exe/extras/credits/countries/${selectedUser.nation}.png';
		var userCountry:FlxSprite = new FlxSprite().loadGraphic(countryPath);
		userCountry.setPosition(Std.int(userName.x + userName.textField.textWidth + 15), Std.int(userName.y + (userName.height - userCountry.height) / 2));
		userCountry.camera = popupCamera;
		add(userCountry);

		var separatorLine:FlxSprite = new FlxSprite(userIcon.x, userIcon.y + userIcon.height + 25).makeGraphic(Std.int(bg.width / 2 - 50), 10, 0xFFFFFFFF);
		separatorLine.camera = popupCamera;
		add(separatorLine);

		var userDescription:FlxText = new FlxText(userIcon.x, separatorLine.y + 50, bg.width / 2 - 50, (selectedUser.description != null) ? selectedUser.description : "No Description");
		userDescription.setFormat(Paths.font("vcr.ttf"), 38, 0xFFFFFFFF, CENTER, NONE);
		userDescription.camera = popupCamera;
		add(userDescription);

		quoteBG = new FlxCamera();
		quoteBG.bgColor = 0x66000000;
		quoteBG.setSize(Std.int(bg.width * 0.4), Std.int(bg.height * 0.6)); quoteBG.setPosition(bg.x + bg.width - quoteBG.width - 50, bg.y + bg.height - quoteBG.height - 50);
		FlxG.cameras.add(quoteBG, false);

		userQuote = new FlxText(5, 5, quoteBG.width - 15, (selectedUser.quote != null) ? selectedUser.quote : "No Quote");
		userQuote.setFormat(Paths.font("vcr.ttf"), 24, 0xFFFFFFFF, LEFT, NONE);
		userQuote.camera = quoteBG;
		add(userQuote);

		var scrollBarBG:FlxSprite = new FlxSprite(quoteBG.width - 5).makeGraphic(5, quoteBG.height, 0xFF525252);
		scrollBarBG.camera = quoteBG;
		scrollBarBG.scrollFactor.set();
		add(scrollBarBG);

		scrollBar = new FlxSprite(quoteBG.width - 5).makeGraphic(5, Std.int(Math.max(40, (quoteBG.height / userQuote.height) * quoteBG.height)), 0xFFFFFFFF);
		scrollBar.visible = false;
		if ((userQuote.height - 10) > quoteBG.height) scrollBar.visible = true;
		scrollBar.camera = quoteBG;
		scrollBar.scrollFactor.set();
		add(scrollBar);

		makeUserExtra();

		if (selectedUser.twitter != null)
		{
			twitterSocial = new FlxSprite().loadGraphic('assets/exe/extras/credits/twitter.png');
			twitterSocial.setPosition(quoteBG.x - twitterSocial.width - 15, quoteBG.y + quoteBG.height - twitterSocial.height);
			twitterSocial.camera = popupCamera;
			twitterSocial.color = 0xFF686868;
			add(twitterSocial);
		}

		if (selectedUser.youtube != null)
		{
			youtubeSocial = new FlxSprite().loadGraphic('assets/exe/extras/credits/youtube.png');
			youtubeSocial.setPosition(quoteBG.x - youtubeSocial.width - 15, quoteBG.y + quoteBG.height - youtubeSocial.height);
			youtubeSocial.camera = popupCamera;
			youtubeSocial.color = 0xFF686868;
			add(youtubeSocial);
			if (selectedUser.twitter != null) youtubeSocial.y = quoteBG.y + quoteBG.height - (youtubeSocial.height * 2) - 15;
		}
	}

	var pauseButton:FlxSprite;
	function makeUserExtra():Void
	{
		if (selectedUser.extra != null)
		{
			if (selectedUser.extra[0] == 'video')
			{
				if (selectedUser.extra[2] != true)
				{
					FlxTween.cancelTweensOf(FlxG.sound.music);
					FlxTween.tween(FlxG.sound.music, {volume: 0.3}, 0.6);
				}

				pauseButton = new FlxSprite().loadGraphic('assets/exe/extras/credits/play.png');
				pauseButton.alpha = 0;
				pauseButton.camera = popupCamera;
				
				#if VIDEOS_ALLOWED
				userVideo = new hxvlc.flixel.FlxVideoSprite(0, 0);
				userVideo.bitmap.onFormatSetup.add(() -> {
					setImageSize(userVideo, 200, 200);
					userVideo.setPosition(bg.x + 40 + ((bg.width / 2 - 50) - userVideo.width) / 2, bg.y + bg.height - userVideo.height - 50);
					pauseButton.setPosition(userVideo.x + (userVideo.width - pauseButton.width) / 2, userVideo.y + (userVideo.height - pauseButton.height) / 2);
				});
				userVideo.bitmap.onEndReached.add(() -> playMenuVideo());
				userVideo.camera = popupCamera;
				add(userVideo);
				playMenuVideo();
				#end

				add(pauseButton);
			}
			else if (selectedUser.extra[0] == 'image')
			{
				userImage = new FlxSprite(0, 0).loadGraphic('assets/exe/extras/credits/${CreditsState.userSelected[0]}/extra/${selectedUser.extra[1]}');
				setImageSize(userImage, 200, 200);
				userImage.setPosition(bg.x + 40 + ((bg.width / 2 - 50) - userImage.width) / 2, bg.y + bg.height - userImage.height - 50);
				userImage.camera = popupCamera;
				add(userImage);
			}
		}
	}

	#if VIDEOS_ALLOWED
	function playMenuVideo():Void
	{
		if (userVideo.load('assets/exe/extras/credits/${CreditsState.userSelected[0]}/extra/${selectedUser.extra[1]}.mp4'))
			new FlxTimer().start(0.001, (_) -> {
				userVideo.play();
				userVideo.bitmap.rate = 1.0;
			});
	}
	#end
	
	var videoPaused:Bool = false;
	var wasPressing:String = '';
	override function update(elapsed:Float)
	{
		if (overlapCamera(quoteBG))
		{
			if (FlxG.mouse.wheel != 0)
			{
				quoteBG.scroll.y -= FlxG.mouse.wheel * 22;
				quoteBG.scroll.y = FlxMath.bound(quoteBG.scroll.y, 0, Math.max(0, userQuote.height - quoteBG.height + 10));

				scrollBar.y = FlxMath.lerp(0, quoteBG.height - scrollBar.height, quoteBG.scroll.y / Math.max(0, userQuote.height - quoteBG.height + 10));
			}
		}

		if (selectedUser.twitter != null)
		{
			if (twitterSocial.color != 0xFF686868 && wasPressing == '') twitterSocial.color = 0xFF686868;
			if (FlxG.mouse.overlaps(twitterSocial) && twitterSocial.color != 0xFFADADAD && wasPressing == '') twitterSocial.color = 0xFFADADAD;
			if (FlxG.mouse.overlaps(twitterSocial) && FlxG.mouse.justPressed)
			{
				twitterSocial.color = 0xFFFFFFFF;
				wasPressing = 'twitter';
			}
			if (FlxG.mouse.released && wasPressing == 'twitter')
			{
				wasPressing = '';
				CoolUtil.browserLoad(selectedUser.twitter);
			}
		}
		if (selectedUser.youtube != null)
		{
			if (youtubeSocial.color != 0xFF686868 && wasPressing == '') youtubeSocial.color = 0xFF686868;
			if (FlxG.mouse.overlaps(youtubeSocial) && youtubeSocial.color != 0xFF969696 && wasPressing == '') youtubeSocial.color = 0xFF969696;
			if (FlxG.mouse.overlaps(youtubeSocial) && FlxG.mouse.justPressed)
			{
				youtubeSocial.color = 0xFFFFFFFF;
				wasPressing = 'youtube';
			}
			if (FlxG.mouse.released && wasPressing == 'youtube')
			{
				wasPressing = '';
				CoolUtil.browserLoad(selectedUser.youtube);
			}
		}

		if (selectedUser.extra != null && selectedUser.extra[0] == 'video' && userVideo != null)
		{
			#if VIDEOS_ALLOWED
			if (FlxG.mouse.overlaps(userVideo) && FlxG.mouse.justPressed)
			{
				if(!videoPaused)
				{
					videoPaused = true;
					userVideo.pause();
					FlxTween.cancelTweensOf(pauseButton); FlxTween.cancelTweensOf(pauseButton.scale);
					pauseButton.loadGraphic('assets/exe/extras/credits/pause.png');
					pauseButton.scale.set(1, 1);
					pauseButton.alpha = 1;

					if (selectedUser.extra[2] != true)
					{
						FlxTween.cancelTweensOf(FlxG.sound.music);
						FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.6);
					}
				}
				else if(videoPaused)
				{
					videoPaused = false;
					userVideo.resume();
					pauseButton.loadGraphic('assets/exe/extras/credits/play.png');
					FlxTween.tween(pauseButton.scale, {x: 0, y: 0}, 0.3);
					FlxTween.tween(pauseButton, {alpha: 0}, 0.3);

					if (selectedUser.extra[2] != true)
					{
						FlxTween.cancelTweensOf(FlxG.sound.music);
						FlxTween.tween(FlxG.sound.music, {volume: 0.3}, 0.6);
					}
				}
			}
			#end
		}

		if (controls.BACK) close();

		super.update(elapsed);
	}

	override function destroy()
	{
		if (selectedUser.extra != null && selectedUser.extra[0] == 'video')
		{
			#if VIDEOS_ALLOWED
			if (userVideo != null)
			{
				userVideo.destroy();
				userVideo = null;
			}
			#end
		}

		FlxG.cameras.remove(quoteBG, true);
		FlxG.cameras.remove(popupCamera, true);
		super.destroy();
	}

	function overlapCamera(cam:FlxCamera):Bool
		return FlxG.mouse.screenX >= cam.x && FlxG.mouse.screenX <= cam.x + cam.width && FlxG.mouse.screenY >= cam.y && FlxG.mouse.screenY <= cam.y + cam.height;

	function setImageSize(obj:FlxSprite, targetWidth:Float, targetHeight:Float, ?offset:Float = 1) {
		var scaleFactor:Float = Math.max(targetWidth / obj.width, targetHeight / obj.height);
		
		obj.setGraphicSize(Math.floor(obj.width * scaleFactor * offset), Math.floor(obj.height * scaleFactor * offset));
		obj.updateHitbox();
	}

	#if VIDEOS_ALLOWED
	override public function onFocus():Void
	{
		super.onFocus();
		if(videoPaused && userVideo != null) userVideo.resume();
	}

	override public function onFocusLost():Void
	{
		super.onFocusLost();
		if(!videoPaused && userVideo != null) userVideo.pause();
	}
	#end
}