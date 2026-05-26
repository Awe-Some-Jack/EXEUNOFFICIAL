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
	var userQuote:FlxText;
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
		var bg = new FlxSprite().loadGraphic(bmp);
		bg.screenCenter();
		bg.camera = popupCamera;
		add(bg);

		var iconPath:String = "assets/exe/extras/credits/missing_icon.png";
		if (selectedUser.icon != null && FileSystem.exists('assets/exe/extras/credits/${CreditsState.userSelected[0]}/${selectedUser.icon}.png')) iconPath = 'assets/exe/extras/credits/${CreditsState.userSelected[0]}/${selectedUser.icon}.png';
		var userIcon:FlxSprite = new FlxSprite(bg.x + 40, bg.y + 40).loadGraphic(iconPath);
		userIcon.camera = popupCamera;
		setImageSize(userIcon, 100, 100);
		add(userIcon);

		var userName:FlxText = new FlxText(0, 0, bg.width - 100, (selectedUser.name != null) ? selectedUser.name : "Unknown");
		userName.setFormat(Paths.font("vcr.ttf"), 76, 0xFFFFFFFF, LEFT, NONE);
		userName.setPosition(userIcon.x + userIcon.width + 25, userIcon.y + (userIcon.height - userName.height) / 2);
		userName.camera = popupCamera;
		add(userName);

		var separatorLine:FlxSprite = new FlxSprite(userIcon.x, userIcon.y + userIcon.height + 25).makeGraphic(Std.int(bg.width / 2 - 50), 10, 0xFFFFFFFF);
		separatorLine.camera = popupCamera;
		add(separatorLine);

		var userDescription:FlxText = new FlxText(userIcon.x, separatorLine.y + 50, bg.width / 2 - 50, (selectedUser.description != null) ? selectedUser.description : "No Description");
		userDescription.setFormat(Paths.font("vcr.ttf"), 46, 0xFFFFFFFF, CENTER, NONE);
		userDescription.camera = popupCamera;
		add(userDescription);

		quoteBG = new FlxCamera();
		quoteBG.bgColor = 0x66000000;
		quoteBG.setSize(Std.int(bg.width * 0.4), Std.int(bg.height * 0.6)); quoteBG.setPosition(bg.x + bg.width - quoteBG.width - 50, bg.y + bg.height - quoteBG.height - 50);
		FlxG.cameras.add(quoteBG, false);

		userQuote = new FlxText(5, 5, quoteBG.width - 10, (selectedUser.quote != null) ? selectedUser.quote : "No Quote");
		userQuote.setFormat(Paths.font("vcr.ttf"), 24, 0xFFFFFFFF, LEFT, NONE);
		userQuote.camera = quoteBG;
		add(userQuote);
	}
	
	override function update(elapsed:Float)
	{
		if (overlapCamera(quoteBG))
		{
			if (FlxG.mouse.wheel != 0)
			{
				quoteBG.scroll.y -= FlxG.mouse.wheel * 22;
				quoteBG.scroll.y = FlxMath.bound(quoteBG.scroll.y, 0, Math.max(0, userQuote.height - quoteBG.height + 10));
			}
		}

		if (controls.BACK)
		{
			close();
		}
		super.update(elapsed);
	}

	override function destroy()
	{
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
}