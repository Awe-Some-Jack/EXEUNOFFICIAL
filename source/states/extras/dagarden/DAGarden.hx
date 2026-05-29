package states.extras.dagarden;

import backend.MusicBeatState;
import backend.Controls;
import backend.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import states.extras.ExtrasMenu;

class DAGarden extends MusicBeatState
{
	private var fondo:FlxSprite;
	private var sprite1:FlxSprite;
	private var sprite2:FlxSprite;
	private var sprite3:FlxSprite;
	private var sprite4:FlxSprite;
	private var sprite6:FlxSprite;
	private var sprite7:FlxSprite;
	private var sprite8:FlxSprite;
	private var arrow:FlxSprite;
	private var spikes:FlxBackdrop;
	private var marcogris:FlxSprite;
	private var dagarden:FlxSprite;

	private var rotationTime:Float = 0.0;

	private var songs:DASongs;
	private var player:DAPlayer;
	private var sub:DASub;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		super.create();
		FlxG.autoPause = false;

		if (FlxG.sound.music != null) FlxG.sound.music.pause();

		_buildBackground();

		songs = new DASongs();
		songs.onSelect = _onSongSelected;
		add(songs);

		_buildForeground();

		player = new DAPlayer();
		add(player);

		sub = new DASub();
		add(sub);

		if (songs.songList.length > 0)
			_onSongSelected(0);

		Paths.clearUnusedMemory();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the DA Garden", null);
		#end
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		spikes.velocity.y = 50;
		rotationTime += elapsed;
		_updateDecorAngles();
		if (sub != null && player != null)
			sub.updateTime(player.currentTime());
		_handleInput();
	}

	override public function destroy():Void
	{
		if (player != null) player.stop();
		_cancelDecorTweens();

		fondo = null; marcogris = null; dagarden = null;
		arrow = null; spikes    = null; sub      = null;
		sprite1 = null; sprite2 = null; sprite3 = null;
		sprite4 = null; sprite6 = null; sprite7 = null; sprite8 = null;

		FlxG.autoPause = true;
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		super.destroy();
	}

	private function _buildBackground():Void
	{
		fondo   = _makeSprite(0,    0,   "fondo.png",  0.34);
		sprite1 = _makeSprite(560, 560,  "1.png",      0.25);
		sprite2 = _makeSprite(950, 580,  "2.png",      0.15);
		sprite3 = _makeSprite(1100, 50,  "3.png",      0.25);
		sprite4 = _makeSprite(540, 300,  "4.png",      0.25);
		sprite6 = _makeSprite(700, 800,  "6.png",      0.25);
		sprite7 = _makeSprite(550,  50,  "7.png",      0.25);
		sprite8 = _makeSprite(800,  50,  "8.png",      0.25);
		arrow   = _makeSprite(490,  90,  "arrow.png",  0.34);

		spikes = new FlxBackdrop("assets/exe/extras/dagarden/spikes.png", Y, 0, 0);
		spikes.setPosition(70, 87);
		spikes.scale.set(0.34, 0.34);
		spikes.updateHitbox();
		spikes.antialiasing = ClientPrefs.data.antialiasing;
		add(spikes);

		_setupDecorTweens();
	}

	private function _buildForeground():Void
	{
		marcogris = _makeSprite(0,  0,  "marcogris.png", 0.34);
		dagarden  = _makeSprite(70, 35, "dagarden.png",  0.34);
		FlxTween.tween(dagarden, {y: dagarden.y + 5}, 3.0, {ease: FlxEase.sineInOut, type: PINGPONG});
	}

	private function _makeSprite(x:Float, y:Float, file:String, scale:Float):FlxSprite
	{
		var s = new FlxSprite(x, y);
		s.loadGraphic(openfl.utils.Assets.getBitmapData("assets/exe/extras/dagarden/" + file));
		s.scale.set(scale, scale);
		s.updateHitbox();
		s.antialiasing = ClientPrefs.data.antialiasing;
		add(s);
		return s;
	}

	private function _setupDecorTweens():Void
	{
		_addFloat(sprite1,  20,   8, 3.2, 2.1);
		_addFloat(sprite2, -10,  18, 1.8, 3.5);
		_addFloat(sprite3,  25, -15, 2.9, 1.7);
		_addFloat(sprite4, -18,  22, 2.4, 3.1);
		_addFloat(sprite6,  12, -20, 3.6, 2.2);
		_addFloat(sprite7, -16,  14, 1.9, 2.8);
		_addFloat(sprite8,  28,  10, 3.3, 2.5);
		FlxTween.tween(arrow, {y: arrow.y - 10}, 1.5, {ease: FlxEase.sineInOut, type: PINGPONG});
	}

	private function _addFloat(s:FlxSprite, ox:Float, oy:Float, dx:Float, dy:Float):Void
	{
		FlxTween.tween(s, {x: s.x + ox}, dx, {ease: FlxEase.sineInOut, type: PINGPONG});
		FlxTween.tween(s, {y: s.y + oy}, dy, {ease: FlxEase.sineInOut, type: PINGPONG});
		FlxTween.tween(s, {alpha: 0.85}, 1.5, {ease: FlxEase.sineInOut, type: PINGPONG, startDelay: Math.random() * 2});
	}

	private function _updateDecorAngles():Void
	{
		sprite1.angle = Math.sin(rotationTime * 0.5) * 3;
		sprite3.angle = Math.cos(rotationTime * 0.7) * 4;
		sprite7.angle = Math.sin(rotationTime * 0.6) * 2;
		sprite8.angle = Math.cos(rotationTime * 0.8) * 3.5;
	}

	private function _cancelDecorTweens():Void
	{
		for (s in [sprite1, sprite2, sprite3, sprite4, sprite6, sprite7, sprite8, arrow, dagarden])
			if (s != null) FlxTween.cancelTweensOf(s);
	}

	private function _onSongSelected(index:Int):Void
	{
		if (index == songs.selectedIndex && (player.isPlaying || player.hasAudio()))
		{
			songs.selectIndex(index);
			return;
		}

		songs.selectIndex(index);
		player.setSongInfo(songs.selectedSong(), songs.selectedCredits());
		player.loadJumpscareFor(songs.selectedSong(), songs.selectedMod());
		sub.loadLyrics(songs.selectedSong(), songs.selectedMod());
		sub.reset();

		if (player.isPlaying) player.fadeOutAndStop();
		else player.stop();
	}

	private function _handleInput():Void
	{
		if (FlxG.keys.justPressed.P)
		{
			if (player.isPlaying) player.pause();
			else player.playAudio(songs.selectedSong(), songs.selectedMod());
		}

		if (FlxG.keys.justPressed.L) player.toggleLoop();
		if (FlxG.keys.justPressed.I) player.toggleVocals();
		if (FlxG.keys.justPressed.S) player.fadeOutAndStop();
		if (FlxG.keys.justPressed.A) player.seek(-DAPlayer.SEEK_SECONDS);
		if (FlxG.keys.justPressed.D) player.seek(DAPlayer.SEEK_SECONDS);

		if (Controls.instance.BACK)
		{
			player.restoreWindowTitle();
			player.stop();
			if (FlxG.sound.music != null) FlxG.sound.music.resume();
			FlxG.switchState(() -> new ExtrasMenu());
		}
	}
}
