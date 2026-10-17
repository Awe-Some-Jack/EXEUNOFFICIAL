package minigames;

import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxEase.EaseFunction;

enum abstract CameraMode(Int)
{
	var Follow = 0;
	var Shot = 1;
}

class Camera
{
	static inline final RELEASE_RATE:Float = 2.0;
	static inline final FRAME_RATE:Float = 2.5;

	public final baseZoom:Float;

	public var followRateX:Float = 1.8;
	public var followRateY:Float = 1.4;

	public var lookAhead:Float = 40.0;
	public var lookAheadRate:Float = 0.8;

	public var jumpRoom:Float = 48.0;

	public var maxLagDown:Float = 0;

	public var bottom:Null<Float> = null;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public var lookDelay:Float = 3.0;
	public var lookDistance:Float = 80.0;
	public var lookRate:Float = 1.5;

	public var mode(default, null):CameraMode = Shot;

	public var x(default, null):Float = 0;
	public var y(default, null):Float = 0;
	public var zoom(default, null):Float;

	final _cam:FlxCamera;
	final _target:CameraTarget;

	var _left:Null<Float> = null;
	var _right:Null<Float> = null;

	var _floorY:Float = 0;
	var _ahead:Float = 0;
	var _look:Float = 0;
	var _lookDir:Int = 0;
	var _lookTimer:Float = 0;
	var _frameOffset:Float = 0;
	var _cutFrames:Int = 0;

	var _zoomAsked:Bool = false;
	var _zoomBump:Float = 0;
	var _zoomRate:Float = 0;
	var _releaseRate:Float = RELEASE_RATE;
	var _frameX:Null<Float> = null;

	var _fromX:Float = 0;
	var _fromY:Float = 0;
	var _fromZoom:Float = 1;
	var _toX:Float = 0;
	var _toY:Float = 0;
	var _toZoom:Float = 1;
	var _shotTime:Float = 0;
	var _shotLength:Float = 0;
	var _shotEase:EaseFunction = FlxEase.smootherStepInOut;
	var _shotBounded:Bool = false;

	var _blendTime:Float = 0;
	var _blendLength:Float = 0;
	var _blendX:Float = 0;
	var _blendY:Float = 0;
	var _blendZoom:Float = 1;
	var _followX:Float = 0;
	var _followY:Float = 0;
	var _followZoom:Float = 1;

	public function new(cam:FlxCamera, target:CameraTarget, baseZoom:Float)
	{
		_cam = cam;
		_target = target;
		this.baseZoom = baseZoom;

		_cam.target = null;
		_cam.targetOffset.set(0, 0);
		_cam.setScrollBounds(null, null, null, null);

		x = target.cameraX();
		y = _floorY = target.cameraY();
		zoom = baseZoom;
		_apply();
	}

	public function setBounds(left:Float, right:Float):Void
	{
		_left = left;
		_right = right;
	}

	public function zoomIn(bump:Float, rate:Float = 2.0):Void
	{
		if (_zoomAsked && bump <= _zoomBump) return;
		_zoomAsked = true;
		_zoomBump = bump;
		_zoomRate = rate;
	}

	public inline function frame(x:Float):Void
	{
		_frameX = x;
	}

	public inline function cut():Void
	{
		_cutFrames = 2;
	}

	public inline function shake(intensity:Float, duration:Float):Void
	{
		_cam.shake(intensity, duration);
	}

	public function lookAt(x:Float, y:Float, zoom:Float, time:Float = 0, ?ease:EaseFunction, bounded:Bool = false):Void
	{
		_fromX = bounded ? _clampX(this.x, this.zoom) : this.x;
		_fromY = this.y;
		_fromZoom = this.zoom;
		_toX = x;
		_toY = y;
		_toZoom = zoom;
		_shotTime = 0;
		_shotLength = time;
		_shotEase = ease ?? FlxEase.smootherStepInOut;
		_shotBounded = bounded;
		_blendLength = 0;
		mode = Shot;
		if (time <= 0) _shot(0);
	}

	public function followTarget(blend:Float = 0):Void
	{
		if (mode == Follow) return;
		final shownX = _shotBounded ? _clampX(x, zoom) : x;
		mode = Follow;
		_floorY = _target.cameraY() + offsetY;
		_ahead = _look = _frameOffset = _lookTimer = 0;
		_lookDir = 0;
		_blendLength = blend;
		_blendTime = 0;
		if (blend <= 0) return;
		_blendX = _followX = shownX;
		_blendY = _followY = y;
		_blendZoom = _followZoom = zoom;
		_cutFrames = 1;
	}

	public function update(elapsed:Float):Void
	{
		if (mode == Follow && _blendTime < _blendLength)
		{
			x = _followX;
			y = _followY;
			zoom = _followZoom;
			_follow(elapsed);
			_followX = x;
			_followY = y;
			_followZoom = zoom;
			_blendTime += elapsed;
			final t = FlxEase.sineInOut(Math.min(1, _blendTime / _blendLength));
			x = _blendX + (x - _blendX) * t;
			y = _blendY + (y - _blendY) * t;
			zoom = _blendZoom + (zoom - _blendZoom) * t;
		}
		else if (mode == Follow) _follow(elapsed);
		else _shot(elapsed);

		_zoomAsked = false;
		_frameX = null;
		_apply();
	}

	function _follow(elapsed:Float):Void
	{
		final t = _target;
		final cut = _cutFrames > 0;
		if (cut)
		{
			_cutFrames--;
			_ahead = _look = _frameOffset = _lookTimer = 0;
		}
		final tx0 = t.cameraX();
		final px = tx0 + offsetX, py = t.cameraY() + offsetY;

		var ty:Float;
		if (cut || t.cameraGrounded())
		{
			_floorY = py;
			ty = py;
		}
		else if (py > _floorY) ty = py;
		else ty = Math.min(_floorY, py + jumpRoom);

		final c = Controls.instance;
		final dir = !t.cameraCanLook() ? 0 : c.UI_DOWN ? 1 : c.UI_UP ? -1 : 0;
		_lookTimer = dir != 0 && dir == _lookDir ? _lookTimer + elapsed : 0;
		_lookDir = dir;
		_look = _ease(_look, _lookTimer >= lookDelay ? dir * lookDistance : 0, lookRate, elapsed);

		final speed = Math.max(-1, Math.min(1, t.cameraSpeed()));
		_ahead = _ease(_ahead, speed * lookAhead, lookAheadRate, elapsed);

		_frameOffset = _ease(_frameOffset, _frameX != null ? (_frameX - tx0) * 0.5 : 0, FRAME_RATE, elapsed);

		var zoomTarget = baseZoom, zoomRate = _releaseRate;
		if (_zoomAsked)
		{
			zoomTarget += _zoomBump;
			zoomRate = _zoomRate;
			_releaseRate = _zoomRate > 0 ? _zoomRate : RELEASE_RATE;
		}
		zoom = cut || zoomRate <= 0 ? zoomTarget : _ease(zoom, zoomTarget, zoomRate, elapsed);

		final tx = _clampX(px + _ahead + _frameOffset, zoom);
		ty += _look;
		if (cut)
		{
			x = tx;
			y = ty;
		}
		else
		{
			x = _ease(x, tx, followRateX, elapsed);
			y = _ease(y, ty, followRateY, elapsed);
			if (maxLagDown > 0 && ty - y > maxLagDown) y = ty - maxLagDown;
		}
		if (bottom != null) y = Math.min(y, bottom - _cam.height / zoom * 0.5);
	}

	function _shot(elapsed:Float):Void
	{
		_shotTime = Math.min(_shotTime + elapsed, _shotLength);
		final t = _shotLength > 0 ? _shotEase(_shotTime / _shotLength) : 1.0;
		x = _fromX + (_toX - _fromX) * t;
		y = _fromY + (_toY - _fromY) * t;
		zoom = _fromZoom + (_toZoom - _fromZoom) * t;
	}

	function _apply():Void
	{
		final cx = mode == Follow || _shotBounded ? _clampX(x, zoom) : x;
		_cam.zoom = zoom;
		_cam.scroll.set(cx - _cam.width * 0.5, y - _cam.height * 0.5);
	}

	function _clampX(cx:Float, zoom:Float):Float
	{
		if (_left == null || _right == null) return cx;
		final half = _cam.width / zoom * 0.5;
		final lo = _left + half, hi = _right - half;
		return lo > hi ? (_left + _right) * 0.5 : Math.max(lo, Math.min(hi, cx));
	}

	static inline function _ease(from:Float, to:Float, rate:Float, elapsed:Float):Float
	{
		return from + (to - from) * (1.0 - Math.pow(0.01, elapsed * rate));
	}
}
