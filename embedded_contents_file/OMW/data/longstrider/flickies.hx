final game:PlayState = PlayState.instance;

final colors:Array<String> = ['red', 'pink', 'orange', 'blue'];
final formation:Map<String, Array<Float>> = [
	'big_red' => [0, 8], 'big_pink' => [144, 0], 'big_orange' => [72, 56], 'big_blue' => [196, 56],
	'baby_red' => [44, 140], 'baby_pink' => [160, 132], 'baby_orange' => [104, 172], 'baby_blue' => [204, 172]
];
final birds:Dynamic = {};

var flock:Array<Dynamic> = [];
var nextFlock:Float = 0;
var phase:Float = 0;

function onCreatePost()
{
	final floor:FlxSprite = game.getLuaObject('floor');
	for (color in colors)
	{
		for (size in ['big', 'baby'])
		{
			final key:String = size + '_' + color;
			final bird:FlxSprite = new FlxSprite();
			bird.frames = Paths.getSparrowAtlas('longstrider/flickies');
			bird.animation.addByPrefix('fly', key, 10, true);
			bird.scale.set(4, 4);
			bird.updateHitbox();
			bird.antialiasing = false;
			bird.visible = false;
			insert(game.members.indexOf(floor), bird);
			Reflect.setField(birds, key, bird);
		}
	}
	nextFlock = FlxG.random.float(13, 16);
}

function spawnFlock()
{
	final cam:FlxCamera = game.camGame;
	final dir:Int = FlxG.random.bool(50) ? 1 : -1;
	final roll:Int = FlxG.random.int(1, 20);
	final sizes:Array<String> = roll <= 9 ? ['big'] : (roll <= 16 ? ['big', 'baby'] : ['baby']);
	final originX:Float = dir > 0 ? cam.viewLeft - 300 : cam.viewRight + 40;
	final originY:Float = FlxG.random.float(880, 1240) - (sizes[0] == 'baby' ? 132 : 0);
	final speed:Float = FlxG.random.float(150, 200);
	final frame:Int = FlxG.random.int(0, 8);
	phase = FlxG.random.float(0, Math.PI * 2);

	for (size in sizes)
	{
		for (color in colors)
		{
			final key:String = size + '_' + color;
			final bird:FlxSprite = Reflect.field(birds, key);
			final offset:Array<Float> = formation.get(key);
			final width:Float = size == 'big' ? 64 : 52;
			flock.push({
				bird: bird,
				dir: dir,
				speed: speed,
				x: originX + (dir > 0 ? offset[0] : 260 - offset[0] - width),
				y: originY + offset[1],
				time: 0.0
			});
			bird.flipX = dir < 0;
			bird.visible = true;
			bird.animation.play('fly', true, false, frame);
		}
	}
}

function onUpdate(elapsed:Float)
{
	final songTime:Float = Conductor.songPosition / 1000;
	if (flock.length == 0 && songTime >= nextFlock && songTime < 96 && game.camGame.alpha > 0) spawnFlock();
	if (flock.length == 0) return;

	final cam:FlxCamera = game.camGame;
	var i:Int = flock.length - 1;
	while (i >= 0)
	{
		final b:Dynamic = flock[i];
		b.time += elapsed;
		final x:Float = b.x + b.dir * b.speed * b.time;
		b.bird.x = x;
		b.bird.y = b.y + Math.sin(b.time * 2.6 + phase) * 12;
		final gone:Bool = (b.dir > 0 && x > cam.viewRight + 120) || (b.dir < 0 && x < cam.viewLeft - 300);
		if ((gone && b.time > 2) || b.time > 30)
		{
			b.bird.visible = false;
			flock.splice(i, 1);
		}
		i--;
	}
	if (flock.length == 0) nextFlock = songTime + FlxG.random.float(2, 5);
}
