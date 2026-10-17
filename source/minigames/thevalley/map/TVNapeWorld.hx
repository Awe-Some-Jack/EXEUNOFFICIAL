package minigames.thevalley.map;

import openfl.display.BitmapData;
import openfl.Assets;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.geom.MarchingSquares;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.geom.Ray;
import nape.callbacks.CbType;
import nape.callbacks.PreListener;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.InteractionType;
import flixel.FlxG;
import flixel.addons.nape.FlxNapeSpace;

// so this whole class reads the collsion straight outta a png. 
class TVNapeWorld
{
	public static inline var GRAVITY:Float = 1800.0;

	public static inline var ONE_WAY_STEP:Float = 8.0;

	public static var CB_PLATFORM:CbType = new CbType();
	public static var CB_DYNAMIC:CbType  = new CbType();

	public function new() {}

	public function init():Void
	{
		FlxNapeSpace.init();
		FlxNapeSpace.space.gravity.setxy(0, GRAVITY);
		FlxNapeSpace.velocityIterations = 10;
		FlxNapeSpace.positionIterations = 10;
		_setupPlatformListener();
	}

	public var partOffsets:Array<{ x:Float, y:Float }> = [];

	public function loadParts(basePath:String, count:Int):Void
	{
		for (i in 1...count + 1)
		{
			var hbPath = basePath + i + "/hitbox.webp";
			var bmd    = Paths.getBitmapData(hbPath);
			if (bmd == null)
			{
				trace('TVNapeWorld: hitbox not found: $hbPath');
				continue;
			}
			var off = (partOffsets.length >= i) ? partOffsets[i - 1] : { x: 0.0, y: 0.0 };
			_buildBodiesFromBitmap(bmd, off.x, off.y);
		}
	}

	function _setupPlatformListener():Void
	{
		var listener = new PreListener(
			InteractionType.COLLISION,
			CB_DYNAMIC,
			CB_PLATFORM,
			function(cb:PreCallback):Null<PreFlag>
			{
				final dynBody:Body = cast(cb.int1, Body);
				final dropUntil:Null<Float> = dynBody.userData.dropUntil;
				if (dropUntil != null && dropUntil > haxe.Timer.stamp()) return PreFlag.IGNORE;
				final arb = cb.arbiter;
				final platShape = arb.shape1.body == dynBody ? arb.shape2 : arb.shape1;

				final relVy = dynBody.velocity.y - platShape.body.velocity.y;

				final footY = dynBody.bounds.y + dynBody.bounds.height;
				final travel = Math.max(0, relVy) * FlxG.elapsed;

				if (footY - travel <= platShape.bounds.y + ONE_WAY_STEP)
					return PreFlag.ACCEPT;

				if (relVy < -15.0)
					return PreFlag.IGNORE;

				final orig = Vec2.get(dynBody.position.x, footY - 2.0 - travel);
				final down = Vec2.get(0, 1);
				final ray  = new Ray(orig, down);
				ray.maxDistance = 10.0 + travel;
				final res = FlxNapeSpace.space.rayCast(ray, false);
				orig.dispose();
				down.dispose();
				final standingOnPlatform = res != null && res.shape.body.cbTypes.has(CB_PLATFORM);
				if (res != null) res.dispose();

				return standingOnPlatform ? PreFlag.ACCEPT : PreFlag.IGNORE;
			},
			0,
			false
		);
		FlxNapeSpace.space.listeners.add(listener);
	}

	function _buildBodiesFromBitmap(bmd:BitmapData, offX:Float = 0, offY:Float = 0, fill:Bool = true):Void
	{
		var bw = bmd.width;
		var bh = bmd.height;
		var pixels = bmd.getVector(bmd.rect);
		var n = bw * bh;

		var solidPx    = new haxe.ds.Vector<Bool>(n);
		var platformPx = new haxe.ds.Vector<Bool>(n);
		var slopePx    = new haxe.ds.Vector<Bool>(n);

		for (i in 0...n)
		{
			var argb = pixels[i];
			var a    = (argb >> 24) & 0xFF;
			if (a < 30) continue;
			var r = (argb >> 16) & 0xFF;
			var g = (argb >>  8) & 0xFF;
			var b =  argb        & 0xFF;

			if (r > 200 && g < 30 && b < 30)        solidPx[i]    = true;
			else if (r < 30 && g > 200 && b < 30)   platformPx[i] = true;
			else if (r < 30 && g < 30  && b > 150)  slopePx[i]    = true;
		}

		// had to do this because the pngs are a bit too thin and im very lazy to fix it
		if (fill)
		{
			_fillDown(solidPx,    bw, bh, 6);
			_fillRight(solidPx,   bw, bh, 6);
			_fillLeft(solidPx,    bw, bh, 6);
			_fillDown(slopePx,    bw, bh, 4);
			_fillDown(platformPx, bw, bh, 3);
		}

		var bounds   = new AABB(0, 0, bw, bh);
		var cellsize = Vec2.get(2.0, 2.0);

		_makeBody(solidPx,    bw, bh, bounds, cellsize, new Material(0.0, 0.0, 0.0, 1.0, 0.0), null,        offX, offY);
		_makeBody(platformPx, bw, bh, bounds, cellsize, new Material(0.0, 0.0, 0.0, 1.0, 0.0), CB_PLATFORM, offX, offY);
		_makeBody(slopePx,    bw, bh, bounds, cellsize, new Material(0.0, 0.0, 0.0, 1.0, 0.0), null,        offX, offY);

		cellsize.dispose();
	}

	function _fillDown(px:haxe.ds.Vector<Bool>, bw:Int, bh:Int, fillAmt:Int):Void
	{
		var counters = new haxe.ds.Vector<Int>(bw);
		for (y in 0...bh)
		{
			for (x in 0...bw)
			{
				var i = y * bw + x;
				if (px[i]) counters[x] = fillAmt + 1;
				if (counters[x] > 0) { px[i] = true; counters[x]--; }
			}
		}
	}

	function _fillRight(px:haxe.ds.Vector<Bool>, bw:Int, bh:Int, fillAmt:Int):Void
	{
		var counters = new haxe.ds.Vector<Int>(bh);
		for (x in 0...bw)
		{
			for (y in 0...bh)
			{
				var i = y * bw + x;
				if (px[i]) counters[y] = fillAmt + 1;
				if (counters[y] > 0) { px[i] = true; counters[y]--; }
			}
		}
	}

	function _fillLeft(px:haxe.ds.Vector<Bool>, bw:Int, bh:Int, fillAmt:Int):Void
	{
		var counters = new haxe.ds.Vector<Int>(bh);
		var x = bw - 1;
		while (x >= 0)
		{
			for (y in 0...bh)
			{
				var i = y * bw + x;
				if (px[i]) counters[y] = fillAmt + 1;
				if (counters[y] > 0) { px[i] = true; counters[y]--; }
			}
			x--;
		}
	}

	function _makeBody(px:haxe.ds.Vector<Bool>, bw:Int, bh:Int, bounds:AABB, cellsize:Vec2, mat:Material, cbType:Null<CbType>, offX:Float = 0, offY:Float = 0):Void
	{
		var hasAny = false;
		for (i in 0...bw * bh) if (px[i]) { hasAny = true; break; }
		if (!hasAny) return;

		var iso = function(fx:Float, fy:Float):Float {
			var ix = Std.int(fx);
			var iy = Std.int(fy);
			if (ix < 0 || iy < 0 || ix >= bw || iy >= bh) return 1.0;
			return px[iy * bw + ix] ? -1.0 : 1.0;
		};

		var polys = MarchingSquares.run(iso, bounds, cellsize, 2, null, true, null);

		var body = new Body(BodyType.STATIC, Vec2.weak(offX, offY));

		if (cbType != null) body.cbTypes.add(cbType);

		for (gp in polys)
		{
			gp.simplify(3.0); 

			var decomp = gp.convexDecomposition();
			for (cp in decomp)
			{
				var shape = new Polygon(cp);
				shape.body = body;
			}
			gp.dispose();
		}

		mat.elasticity = 0.0;

		body.setShapeMaterials(mat);
		body.space = FlxNapeSpace.space;
	}

	public static function setBodyPos(body:Body, wx:Float, wy:Float):Void
	{
		body.position.setxy(wx, wy);
		body.velocity.setxy(0, 0);
		body.angularVel = 0;
	}
}