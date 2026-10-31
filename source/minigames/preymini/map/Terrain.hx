package minigames.preymini.map;

import flixel.addons.display.FlxBackdrop;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxAxes;
import haxe.io.Bytes;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

enum abstract TerrainKind(Int) from Int to Int
{
	var Empty    = 0;
	var Solid    = 1;
	var Platform = 2;
	var PathA    = 3;
	var PathB    = 4;
	var Switch   = 5;
	var LaneA    = 6;
	var LaneB    = 7;
}

class Terrain
{
	public final width:Int;
	public final height:Int;
	public final repeat:Bool;

	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;

	final _kinds:Bytes;
	final _sprites:Array<FlxSprite> = [];
	final _offsetsX:Array<Float> = [];
	final _offsetsY:Array<Float> = [];

	public static function load(hitboxKey:String, repeat:Bool):Terrain
	{
		final hitbox = read(hitboxKey);
		final terrain = new Terrain(hitbox, repeat);
		hitbox.dispose();
		return terrain;
	}

	public function new(hitbox:BitmapData, repeat:Bool)
	{
		width = hitbox.width;
		height = hitbox.height;
		this.repeat = repeat;
		_kinds = Bytes.alloc(width * height);
		final pixels = hitbox.getVector(hitbox.rect);
		for (i in 0...pixels.length) _kinds.set(i, classify(pixels[i]));
	}

	public function loadArt(key:String):FlxTypedGroup<FlxSprite>
	{
		return addArt(read(key));
	}

	public function addArt(art:BitmapData):FlxTypedGroup<FlxSprite>
	{
		final layer = new FlxTypedGroup<FlxSprite>();
		if (repeat)
		{
			_add(layer, new FlxBackdrop(art, FlxAxes.X), 0, 0);
			return layer;
		}

		final origin = new Point();
		var cx = 0;
		while (cx < art.width)
		{
			final w = Std.int(Math.min(2048, art.width - cx));
			final piece = new BitmapData(w, art.height, true, 0);
			piece.copyPixels(art, new Rectangle(cx, 0, w, art.height), origin);

			final used = piece.getColorBoundsRect(0xFF000000, 0, false);
			if (used.width > 0 && used.height > 0)
			{
				final cropped = new BitmapData(Std.int(used.width), Std.int(used.height), true, 0);
				cropped.copyPixels(piece, used, origin);
				_add(layer, new FlxSprite().loadGraphic(FlxGraphic.fromBitmapData(cropped)), (cx + used.x) * 6, used.y * 6);
			}
			piece.dispose();
			cx += w;
		}
		art.dispose();
		return layer;
	}

	public function addSprite(key:String, artX:Float, artY:Float):FlxSprite
	{
		return attach(new FlxSprite().loadGraphic(Paths.image(key)), artX, artY);
	}

	public function attach(sprite:FlxSprite, artX:Float, artY:Float):FlxSprite
	{
		_add(null, sprite, artX * 6, artY * 6);
		return sprite;
	}

	public inline function kind(cx:Int, cy:Int):TerrainKind
	{
		final wx = repeat ? _wrap(cx) : cx;
		return cy < 0 || cy >= height || wx < 0 || wx >= width ? Empty : _kinds.get(cy * width + wx);
	}

	inline function _wrap(cx:Int):Int
	{
		final wx = cx % width;
		return wx < 0 ? wx + width : wx;
	}

	public function fill(x0:Int, y0:Int, x1:Int, y1:Int, kind:TerrainKind):Void
	{
		for (cy in Std.int(Math.max(0, y0))...Std.int(Math.min(height, y1)))
			for (cx in Std.int(Math.max(0, x0))...Std.int(Math.min(width, x1)))
				_kinds.set(cy * width + cx, kind);
	}

	public inline function solidAt(cx:Int, cy:Int):Bool
	{
		final k = kind(cx, cy);
		return k != Empty && k != Switch && k != LaneA && k != LaneB;
	}

	public function topAt(cx:Int, fromY:Int = 0):Int
	{
		for (cy in Std.int(Math.max(0, fromY))...height)
			switch (kind(cx, cy))
			{
				case Solid | Platform | PathA: return cy;
				default:
			}
		return -1;
	}

	public inline function worldX(artX:Float):Float return x + artX * 6;
	public inline function worldY(artY:Float):Float return y + artY * 6;

	public static function classify(argb:Int):TerrainKind
	{
		if ((argb >>> 24) & 0xFF < 128) return Empty;
		final hi = (c:Int) -> c >= 160, lo = (c:Int) -> c < 100;
		final r = (argb >> 16) & 0xFF, g = (argb >> 8) & 0xFF, b = argb & 0xFF;
		if (hi(r) && hi(g) && hi(b)) return LaneB;
		if (lo(r) && hi(g) && hi(b)) return LaneA;
		if (hi(r) && hi(g) && lo(b)) return Switch;
		if (hi(r) && lo(g) && hi(b)) return PathB;
		if (hi(r) && lo(g) && lo(b)) return Solid;
		if (lo(r) && hi(g) && lo(b)) return Platform;
		if (lo(r) && lo(g) && hi(b)) return PathA;
		return Empty;
	}

	public static function read(key:String):BitmapData
	{
		final left = Paths.getBitmapData(Paths.getPath('images/$key.webp', IMAGE));
		final right = Paths.getBitmapData(Paths.getPath('images/${key}2.webp', IMAGE));
		if (left == null || right == null) return left;

		final full = new BitmapData(left.width + right.width, left.height, true, 0);
		full.copyPixels(left, left.rect, new Point());
		full.copyPixels(right, right.rect, new Point(left.width, 0));
		left.dispose();
		right.dispose();
		return full;
	}

	function _add(layer:FlxTypedGroup<FlxSprite>, sprite:FlxSprite, offsetX:Float, offsetY:Float):Void
	{
		sprite.antialiasing = false;
		sprite.scale.set(6, 6);
		sprite.updateHitbox();
		sprite.setPosition(x + offsetX, y + offsetY);
		if (layer != null) layer.add(sprite);
		_sprites.push(sprite);
		_offsetsX.push(offsetX);
		_offsetsY.push(offsetY);
	}

	function set_x(value:Float):Float
	{
		for (i in 0..._sprites.length) _sprites[i].x = value + _offsetsX[i];
		return x = value;
	}

	function set_y(value:Float):Float
	{
		for (i in 0..._sprites.length) _sprites[i].y = value + _offsetsY[i];
		return y = value;
	}
}
