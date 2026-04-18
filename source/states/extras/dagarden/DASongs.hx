package states.extras.dagarden;

import backend.Paths;
import backend.Mods;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import sys.FileSystem;

class DASongs extends FlxGroup
{
	static inline var BOX_X:Float         = 86.0;
	static inline var BOX_Y:Float         = 116.0;
	static inline var BOX_SPACING:Float   = 120.0;
	static inline var BOX_SCALE:Float     = 0.308;
	static inline var SELECT_OFFSET:Float = 18.0;
	static inline var SCROLL_LERP:Float   = 0.15;

	public var songList:Array<String>           = [];
	public var songMods:Array<String>           = [];
	public var songCredits:Array<Array<String>> = [];

	private var songBoxes:Array<FlxSprite>  = [];
	private var songCovers:Array<FlxSprite> = [];
	private var songLabels:Array<FlxText>   = [];
	private var songHasCover:Array<Bool>    = [];


	private var scrollY:Float      = 0.0;
	private var scrollTarget:Float = 0.0;

	public var selectedIndex:Int = -1;

	public var onSelect:Int->Void = null;

	public function new()
	{
		super();
		_loadAll();
		_buildBoxes();
	}

	public function selectIndex(index:Int):Void
	{
		if (index < 0 || index >= songBoxes.length) return;

		if (selectedIndex >= 0 && selectedIndex < songBoxes.length)
		{
			var prevSprite = songHasCover[selectedIndex] ? songCovers[selectedIndex] : songBoxes[selectedIndex];
			FlxTween.cancelTweensOf(prevSprite);
			FlxTween.cancelTweensOf(songLabels[selectedIndex]);
			FlxTween.tween(prevSprite,                {x: BOX_X},      0.15, {ease: FlxEase.quadOut});
			FlxTween.tween(songLabels[selectedIndex], {x: BOX_X + 10}, 0.15, {ease: FlxEase.quadOut});
		}

		selectedIndex = index;

		var curSprite = songHasCover[index] ? songCovers[index] : songBoxes[index];
		FlxTween.cancelTweensOf(curSprite);
		FlxTween.cancelTweensOf(songLabels[index]);
		FlxTween.tween(curSprite,          {x: BOX_X + SELECT_OFFSET},      0.2, {ease: FlxEase.quadOut});
		FlxTween.tween(songLabels[index],  {x: BOX_X + SELECT_OFFSET + 10}, 0.2, {ease: FlxEase.quadOut});
	}

	public inline function selectedSong():String
		return selectedIndex >= 0 ? songList[selectedIndex] : '';

	public inline function selectedMod():String
		return selectedIndex >= 0 ? songMods[selectedIndex] : '';

	public inline function selectedCredits():Array<String>
		return (selectedIndex >= 0 && selectedIndex < songCredits.length) ? songCredits[selectedIndex] : [];

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		_updateScroll(elapsed);
		_updateMouseClick();
	}

	private function _loadAll():Void
	{
		songList    = [];
		songMods    = [];
		songCredits = [];

		var seen = new haxe.ds.StringMap<Bool>();

		for (mod in Mods.parseList().enabled)
		{
			var dir = Paths.mods('$mod/songs');
			if (!FileSystem.exists(dir)) continue;
			try
			{
				for (song in FileSystem.readDirectory(dir))
				{
					if (seen.exists(song)) continue;
					if (!FileSystem.isDirectory('$dir/$song')) continue;
					seen.set(song, true);
					songList.push(song);
					songMods.push(mod);
				}
			}
			catch(_:Dynamic) {}
		}

		var globalDir = Paths.mods('songs');
		if (FileSystem.exists(globalDir))
		{
			try
			{
				for (song in FileSystem.readDirectory(globalDir))
				{
					if (seen.exists(song)) continue;
					if (!FileSystem.isDirectory('$globalDir/$song')) continue;
					seen.set(song, true);
					songList.push(song);
					songMods.push('');
				}
			}
			catch(_:Dynamic) {}
		}

		_applyOrder();

		for (i in 0...songList.length)
			songCredits.push(_readCredits(songList[i], songMods[i]));
	}

	private function _applyOrder():Void
	{
		var orderPath = 'assets/exe/dagarden_order.json';
		if (!FileSystem.exists(orderPath)) { _sortAlpha(); return; }

		try
		{
			var json:Dynamic        = haxe.Json.parse(sys.io.File.getContent(orderPath));
			var order:Array<String> = cast json.order;
			if (order == null || order.length == 0) { _sortAlpha(); return; }

			var posMap = new haxe.ds.StringMap<Int>();
			for (i in 0...order.length)
				posMap.set(order[i].toLowerCase(), i);

			var pairs:Array<{song:String, mod:String, pos:Int}> = [];
			for (i in 0...songList.length)
			{
				var pos = posMap.exists(songList[i].toLowerCase())
					? posMap.get(songList[i].toLowerCase())
					: order.length + i;
				pairs.push({song: songList[i], mod: songMods[i], pos: pos});
			}

			pairs.sort((a, b) -> a.pos - b.pos);
			songList = [for (p in pairs) p.song];
			songMods = [for (p in pairs) p.mod];
		}
		catch(_:Dynamic) { _sortAlpha(); }
	}

	private function _sortAlpha():Void
	{
		var pairs:Array<{song:String, mod:String}> = [];
		for (i in 0...songList.length)
			pairs.push({song: songList[i], mod: songMods[i]});
		pairs.sort((a, b) -> a.song.toLowerCase() < b.song.toLowerCase() ? -1 : 1);
		songList = [for (p in pairs) p.song];
		songMods = [for (p in pairs) p.mod];
	}

	private function _readCredits(song:String, mod:String):Array<String>
	{
		var paths = mod != ''
			? [Paths.mods('$mod/data/$song/credits.json'), Paths.mods('data/$song/credits.json')]
			: [Paths.mods('data/$song/credits.json')];

		for (p in paths)
		{
			if (!FileSystem.exists(p)) continue;
			try
			{
				var json:Dynamic = haxe.Json.parse(sys.io.File.getContent(p));
				if (json.composer == null) return [];
				if (Std.isOfType(json.composer, Array))
				{
					var arr:Array<String> = cast json.composer;
					return arr.filter(s -> s != null && s.length > 0);
				}
				var s = Std.string(json.composer);
				return s.length > 0 ? [s] : [];
			}
			catch(_:Dynamic) {}
		}
		return [];
	}

	private function _buildBoxes():Void
	{
		var bmp = openfl.utils.Assets.getBitmapData("assets/exe/extras/dagarden/gardenbox.png");

		for (i in 0...songList.length)
		{
			var yBase = BOX_Y + i * BOX_SPACING;

			var cover = _loadCover(songList[i], BOX_X, yBase);
			songCovers.push(cover);

			var bx = new FlxSprite(BOX_X, yBase);
			bx.loadGraphic(bmp);
			bx.scale.set(BOX_SCALE, BOX_SCALE);
			bx.updateHitbox();
			bx.antialiasing = ClientPrefs.data.antialiasing;
			bx.visible = !songHasCover[i];
			add(bx);
			songBoxes.push(bx);

			add(cover);

			var lbl = new FlxText(BOX_X + 10, yBase + 8, 300, songList[i].toUpperCase(), 14);
			lbl.setFormat(null, 14, FlxColor.WHITE, LEFT);
			lbl.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
			lbl.antialiasing = ClientPrefs.data.antialiasing;
			lbl.visible = !songHasCover[i];
			add(lbl);
			songLabels.push(lbl);
		}
	}

	private function _loadCover(song:String, boxX:Float, boxY:Float):FlxSprite
	{
		var cv = new FlxSprite(boxX, boxY);

		var path = 'assets/exe/extras/dagarden/cover/$song.png';
		if (sys.FileSystem.exists(path))
		{
			var bmp = openfl.utils.Assets.getBitmapData(path);
			if (bmp == null) bmp = openfl.display.BitmapData.fromFile(path);
			cv.loadGraphic(bmp);
			cv.scale.set(BOX_SCALE, BOX_SCALE);
			cv.updateHitbox();
			songHasCover.push(true);
		}
		else
		{
			cv.makeGraphic(1, 1, 0x00000000);
			songHasCover.push(false);
		}

		cv.antialiasing = ClientPrefs.data.antialiasing;
		return cv;
	}

	private function _updateScroll(elapsed:Float):Void
	{
		var wheel = FlxG.mouse.wheel;
		if (wheel != 0) scrollTarget -= wheel * BOX_SPACING;

		var maxScroll = Math.max(0.0, (songList.length - 1) * BOX_SPACING - (FlxG.height - BOX_Y - BOX_SPACING));
		scrollTarget = FlxMath.bound(scrollTarget, 0, maxScroll);
		scrollY      = FlxMath.lerp(scrollY, scrollTarget, SCROLL_LERP);

		for (i in 0...songBoxes.length)
		{
			var yPos = BOX_Y + i * BOX_SPACING - scrollY;
			songBoxes[i].y  = yPos;
			songCovers[i].y = yPos;
			songLabels[i].y = yPos + 8;

			var vis = yPos > BOX_Y - BOX_SPACING && yPos < FlxG.height;
			songBoxes[i].visible  = vis && !songHasCover[i];
			songCovers[i].visible = vis;
			songLabels[i].visible = vis && !songHasCover[i];
		}
	}

	private function _updateMouseClick():Void
	{
		if (!FlxG.mouse.justPressed) return;

		var mx = FlxG.mouse.x;
		var my = FlxG.mouse.y;

		for (i in 0...songBoxes.length)
		{
			var hit = songHasCover[i] ? songCovers[i] : songBoxes[i];
			if (!hit.visible) continue;
			if (mx < hit.x || mx > hit.x + hit.width)  continue;
			if (my < hit.y || my > hit.y + hit.height)  continue;

			if (onSelect != null) onSelect(i);
			selectIndex(i);
			break;
		}
	}

	override public function destroy():Void
	{
		if (songBoxes != null)  for (b in songBoxes)  FlxTween.cancelTweensOf(b);
		if (songLabels != null) for (l in songLabels) FlxTween.cancelTweensOf(l);
		songBoxes    = null;
		songCovers   = null;
		songLabels   = null;
		songHasCover = null;
		songList    = null;
		songMods    = null;
		songCredits = null;
		onSelect    = null;
		super.destroy();
	}
}
