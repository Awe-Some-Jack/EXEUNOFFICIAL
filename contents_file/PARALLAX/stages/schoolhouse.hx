package states.stages;

import backend.StageData;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import states.PlayState;
import flixel.util.FlxAxes;
import backend.MusicBeatState;
import flixel.tweens.FlxEase;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.system.scaleModes.RelativeScaleMode;
import flixel.system.scaleModes.RatioScaleMode;
import lime.app.Application as Application;
import flixel.util.FlxStringUtil;

using StringTools;

var hud1:FlxSprite;
var hud2:FlxSprite;
var bg1:FlxSprite;
var bg2:FlxSprite;

//-900, -200
// 0.35
var lastScreenX:Float = 0;
var separation:Int = 50;
var healthTxt:FlxText;

function onCreate() {
	bg1 = new FlxSprite(-350, -300).loadGraphic(Paths.image('bg/bg-phase1', 'PARALLAX'));
	bg1.scale.set(0.8, 0.8);
	bg1.antialiasing = false;
	bg1.updateHitbox();
	addBehindDad(bg1);

	bg2 = new FlxSprite(-350, -300).loadGraphic(Paths.image('bg/bg-phase2', 'PARALLAX'));
	bg2.scale.set(0.8, 0.8);
	bg2.alpha = 0.00001;
	bg2.antialiasing = false;
	bg2.updateHitbox();
	addBehindDad(bg2);

	hud1 = new FlxSprite(0, 0).loadGraphic(Paths.image('hud/schoolhouse_hud_normal', 'PARALLAX'));
	hud1.scale.set(1.5, 1.5);
	hud1.antialiasing = false;
	hud1.cameras = [camHUD];
	hud1.updateHitbox();
	hud1.screenCenter();
	add(hud1);

	hud2 = new FlxSprite(0, 0).loadGraphic(Paths.image('hud/schoolhouse_hud_melting', 'PARALLAX'));
	hud2.scale.set(1.5, 1.5);
	hud2.alpha = 0.00001;
	hud2.antialiasing = false;
	hud2.cameras = [camHUD];
	hud2.updateHitbox();
	hud2.screenCenter();
	add(hud2);

	black = new FlxSprite(-4000, -4000).makeGraphic(8000, 8000, 0xFF000000);
	black.alpha = 0;
	add(black);
}

function onCreatePost() {
	camZooming = false;
	camGame.pixelPerfectRender = camHUD.pixelPerfectRender = true;
	comboGroup.y += 100;

	healthTxt = new FlxText(0, 0, FlxG.width, "", 30);
	healthTxt.font = Paths.font("schoolhouse.ttf");
	healthTxt.cameras = [camHUD];
	healthTxt.screenCenter();
	healthTxt.scrollFactor.set();
	healthTxt.borderSize = 1;
	healthTxt.antialiasing = false;
	healthTxt.x += 50;
	healthTxt.y += 320;
	add(healthTxt);
	
	gfGroup.visible = boyfriendGroup.visible = false;
}

function onCountdownStarted() {
	for (i in 0...4) {
		opponentStrums.members[i].x = -1000;
		playerStrums.members[i].x = (FlxG.width / 2) + (separation / 2) - (((playerStrums.members[i].width + (separation * 2)) * 4) / 2) + ((playerStrums.members[i].width + separation * (i > 1 ? (i == 3 ? 2.33 : 3) : 1)) * i);
	}
}

function opponentNoteHit(note:Note):Void {
}

function onStepHit() {
	switch(curStep) {
		
	}
}

function goodNoteHitPre(note:Note):Void {
	boyfriend.idleSuffix = note.noteType == 'Alt Animation' ? '-alt' : '';
	boyfriend.recalculateDanceIdle();
}

function opponentNoteHitPre(note:Note):Void {
	
}

function onUpdate(elapsed:Float) {
	if(health <= 2)
		healthTxt.text = "Health: " + (health*100)/2 + "%";
	else
		healthTxt.text = "Health: 100%";
}

function updateScreenSize(targetW:Int, targetH:Int, ?force:Bool = false):Void {
    if(Application.current.window.display.bounds.width != lastScreenX || force) {
        var window = Application.current.window;
        var display = window.display;
        var screenW:Float = display.bounds.width;
        var screenH:Float = display.bounds.height;
        var screenX:Float = display.bounds.x;
        var screenY:Float = display.bounds.y;

        lastScreenX = screenW;

        var heights:Array<Int> = [1200, 960, 720, 480];

		if(targetW != 1280) {
			for(h in heights) {
				if(screenH - 70 >= h) {
					targetH = h;
					targetW = Math.floor(h * (4/3));
					break;
				}
			}
		}

        window.resizable = true;
        window.resize(targetW, targetH);

        var centerX = screenX + Math.floor((screenW - targetW) / 2);
        var centerY = screenY + Math.floor((screenH - targetH) / 2);

        window.x = Math.floor(centerX);
        window.y = Math.floor(centerY);
        window.resizable = targetW == 1280;

        FlxG.resizeWindow(targetW, targetH);
        FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode(true);

		window.focus();
    }
}

function onDestroy() {
	// updateScreenSize(1280, 720, true);
	trace("Resetting window size to 1280x720");
}