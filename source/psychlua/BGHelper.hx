package psychlua;

import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import psychlua.LuaUtils;

import animate.FlxAnimate;

typedef BackgroundSprite =
{
	var path:String;
	var sprite:Dynamic;
	var orderNum:Int;
	@:optional var tag:String;
	@:optional var position:Array<Float>;
	@:optional var scale:Array<Dynamic>;
	@:optional var scroll:Array<Float>;
	@:optional var front:Bool; //deprecated, use `layer` instead!
	@:optional var layer:Dynamic;
	@:optional var visible:Bool;
	@:optional var alpha:Float;
	@:optional var lq:Bool;
	@:optional var flip:Array<Bool>;
	@:optional var color:FlxColor;
	@:optional var blend:String;
	@:optional var antialiasing:Bool;
	@:optional var animation:Array<Dynamic>;
	@:optional var camera:String;
	@:optional var backdrop:Array<Dynamic>;
	@:optional var isAtlas:Bool;
}

class BGHelper
{
	public static function makeBackground(background:Array<BackgroundSprite>)
	{
		var _orderNum:Int = 0;
		for (spriteDef in background)
		{
			_orderNum++;
			spriteDef.orderNum = _orderNum;
			if (spriteDef.lq == true && ClientPrefs.data.lowQuality) continue;

			var sprite:FlxSprite;
			if (spriteDef.backdrop != null)
			{
				sprite = new FlxBackdrop(Paths.image(spriteDef.path), FlxAxes.fromString(spriteDef.backdrop[0] ?? 'xy'), (spriteDef.backdrop[2] ?? [0, 0])[0], (spriteDef.backdrop[2] ?? [0, 0])[1]);
				sprite.setPosition((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
				sprite.velocity.set((spriteDef.backdrop[1] ?? [0, 0])[0], (spriteDef.backdrop[1] ?? [0, 0])[1]);

				if (spriteDef.animation != null)
				{
					sprite.frames = Paths.getSparrowAtlas(spriteDef.path);
					for (anim in spriteDef.animation)
					{
						if (anim.indices?.length > 0) sprite.animation.addByIndices(anim.name, anim.name, anim.indices, "", anim.fps ?? 24, anim.looped ?? false);
						else sprite.animation.addByPrefix(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false);
						sprite.animation.play(anim.name, true);
					}
				}
			}
			else
			{
				if (spriteDef.isAtlas)
				{
					var animSprite = new FlxAnimate((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);
					if (spriteDef.animation != null)
					{
						animSprite.animation = animSprite.anim;
						animSprite.frames = Paths.getAnimateAtlas(spriteDef.path);
						for (anim in spriteDef.animation)
						{
							if (anim.indices?.length > 0) animSprite.anim.addBySymbolIndices(anim.name, anim.name, anim.indices, anim.fps ?? 24, anim.looped ?? false);
							else animSprite.anim.addBySymbol(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false);
							animSprite.animation.play(anim.name, true);
						}
					}
					sprite = animSprite; //bruh
				}
				else
				{
					sprite = new FlxSprite((spriteDef.position ?? [0, 0])[0], (spriteDef.position ?? [0, 0])[1]);

					if (spriteDef.animation != null)
					{
						sprite.frames = Paths.getSparrowAtlas(spriteDef.path);
						for (anim in spriteDef.animation)
						{
							if (anim.indices?.length > 0) sprite.animation.addByIndices(anim.name, anim.name, anim.indices, "", anim.fps ?? 24, anim.looped ?? false);
							else sprite.animation.addByPrefix(anim.name, anim.name, anim.fps ?? 24, anim.looped ?? false);
							sprite.animation.play(anim.name, true);
						}
					}
					else sprite.loadGraphic(Paths.image(spriteDef.path));
				}
			}

			sprite.scrollFactor.set((spriteDef.scroll ?? [1, 1])[0], (spriteDef.scroll ?? [1, 1])[1]);
			sprite.scale.set((spriteDef.scale ?? [1, 1, true])[0], (spriteDef.scale ?? [1, 1, true])[1]);
			if (spriteDef.scale != null && (spriteDef.scale[2] == null || spriteDef.scale[2] == true)) sprite.updateHitbox();
			if (spriteDef.antialiasing != null) sprite.antialiasing = spriteDef.antialiasing;
			if (spriteDef.flip != null) {sprite.flipX = spriteDef.flip[0]; sprite.flipY = spriteDef.flip[1];}
			if (spriteDef.visible != null) sprite.visible = spriteDef.visible;
			if (spriteDef.alpha != null) sprite.alpha = spriteDef.alpha;
			if (spriteDef.color != null) sprite.color = spriteDef.color;
			if (spriteDef.camera != null) sprite.camera = LuaUtils.cameraFromString(spriteDef.camera);
			if (spriteDef.blend != null) sprite.blend = LuaUtils.blendModeFromString(spriteDef.blend);

			if (spriteDef.layer == null)
			{
				//deprecated, use `layer` instead!
				if (spriteDef.front != null) PlayState.instance.add(sprite);
				else PlayState.instance.insert(PlayState.instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
			}

			if (spriteDef.layer != null)
			{
				if (Type.typeof(spriteDef.layer) == TInt)
				{
					if (spriteDef.layer > -1) PlayState.instance.insert(spriteDef.layer, sprite);
				}
				else if (Std.isOfType(spriteDef.layer, String) && spriteDef.layer.length > 0)
				{
					final layer:String = Paths.formatToSongPath(spriteDef.layer);
					switch(layer)
					{
						case 'top':
							PlayState.instance.add(sprite);
						case 'behindbf' | 'behindboyfriend':
							PlayState.instance.insert(PlayState.instance.members.indexOf(PlayState.instance.boyfriendGroup), sprite);
						case 'behindgf' | 'behindgirlfriend':
							PlayState.instance.insert(PlayState.instance.members.indexOf(PlayState.instance.gfGroup), sprite);
						case 'behinddad' | 'behindopponent':
							PlayState.instance.insert(PlayState.instance.members.indexOf(PlayState.instance.dadGroup), sprite);
						default:
							PlayState.instance.insert(PlayState.instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), sprite);
					}
				}
			}

			spriteDef.sprite = sprite;
		}
	}
}