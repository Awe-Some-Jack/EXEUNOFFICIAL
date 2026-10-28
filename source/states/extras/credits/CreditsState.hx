package states.extras.credits;

import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import flixel.FlxCamera;

import openfl.display.BitmapData;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;
import haxe.Json;

#if VIDEOS_ALLOWED
import objects.VideoSprite;
#end

using StringTools;

typedef Credit = {
	var name:String;
	var icon:String;
	var description:String;
	@:optional var quote:String;
	@:optional var colors:Array<Array<Int>>;
	@:optional var nation:String;
	@:optional var twitter:String;
	@:optional var youtube:String;
	@:optional var discord:String;
	@:optional var kofi:String;
	@:optional var extra:Array<Dynamic>;
}

class CreditsState extends SonicSubState
{
	public static var credits:Map<String, Array<Credit>> = [];
	public static var userSelected:Array<Dynamic> = ['unofficial', 0];

	var columns:Array<{key:String, cam:FlxCamera, nameTexts:Array<FlxText>, cardBgs:Array<FlxSprite>}> = [];
	var hoveredCol:Int = -1;
	var hoveredRow:Int = -1;
	var canSelect:Bool  = false;

	override function create()
	{
		super.create();

		FlxG.mouse.visible = true;

		final json:Dynamic = Json.parse(Assets.getText("assets/exe/extras/credits/credits.json"));
		for (cat in Reflect.fields(json)) credits.set(cat, cast Reflect.field(json, cat));

		add(FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFF1a0a2e, 0xFF3d0d1f], 1, 90));
		final ts = 32; final cbmd = new openfl.display.BitmapData(ts*2, ts*2, true, 0x00000000);
		cbmd.fillRect(new openfl.geom.Rectangle(0,0,ts,ts), 0x08FFFFFF); cbmd.fillRect(new openfl.geom.Rectangle(ts,ts,ts,ts), 0x08FFFFFF);
		final bd = new FlxBackdrop(cbmd, XY, 0, 0); bd.velocity.set(15, 10); bd.alpha = 0.5; add(bd);

		final titleBg = new FlxSprite(0, 0).makeGraphic(FlxG.width, 60, 0x44000000); add(titleBg);
		final title = new FlxText(0, 0, FlxG.width, Language.getArray('extras.menu.credits', ['CREDITS', ''])[0]).setFormat(Paths.font(Language.fontOrCJK("vcr.ttf")), Language.cjkSize(28 + 8), 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		title.borderSize = Language.cjkBorder(3); title.y = (60 - title.height) * 0.5; add(title);

		final defs = [
			{key:'unofficial', label: Language.get('extras.credits.unofficial', 'Unofficial Dev Team')},
			{key:'original',   label: Language.get('extras.credits.original',   'Original Team')},
			{key:'external',   label: Language.get('extras.credits.external',   'External Credits')}
		];
		final colW  = Std.int((FlxG.width - 10 * (defs.length + 1)) / defs.length);
		final camY  = 60 + 50;
		final colH  = FlxG.height - camY - 30;
		final camPad= 6;

		for (i in 0...defs.length)
		{
			final def = defs[i]; final camX = 10 + i * (colW + 10);

			final colBg = new FlxSprite(camX, camY).makeGraphic(colW, colH, 0x00000000, true);
			colBg.pixels.fillRect(colBg.pixels.rect, 0x33000000);
			final csh = new shaders.RoundedBorderShader(16.0, 0.0, 0xFF000000); csh.setSize(colW, colH); colBg.shader = csh;
			colBg.alpha = 0; add(colBg);

			final titleY = camY - 30 - 4;
			final colTitle = new FlxText(camX, titleY, colW, def.label).setFormat(Paths.font(Language.fontOrCJK("vcr.ttf")), Language.cjkSize(28), 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
			colTitle.borderSize = Language.cjkBorder(2); colTitle.alpha = 0; colTitle.y = titleY - colTitle.height * 0.5; add(colTitle);

			final cam = new FlxCamera(); cam.bgColor = 0x00000000; FlxG.cameras.add(cam, false);
			cam.setSize(colW - camPad*2, colH - camPad*2); cam.setPosition(camX + camPad, camY + camPad);

			final nameTexts:Array<FlxText> = []; final cardBgs:Array<FlxSprite> = [];
			final entries = credits.get(def.key);
			if (entries != null) for (j in 0...entries.length)
			{
				final entry = entries[j]; final cardY = 8 + j * 44;
				final cardW = colW - camPad*2 - 8*2;

				final card = new FlxSprite(8, cardY).makeGraphic(cardW, 44-4, 0x00000000, true);
				card.pixels.fillRect(card.pixels.rect, 0x22FFFFFF);

				final csh2 = new shaders.RoundedBorderShader(10.0, 0.0, 0xFF000000); csh2.setSize(cardW, 44-4); card.shader = csh2;
				card.camera = cam; add(card); cardBgs.push(card);

				var iconPath:String = null;
				if (entry.icon != null)
				{
					final basePath = 'extras/credits/${def.key}/icons/${entry.icon}';
					for (ext in Paths.IMAGE_EXTS)
					{
						final testPath = '$basePath.$ext';
						if (Paths.fileExists(testPath, true, "exe"))
						{
							iconPath = Paths.getPath(testPath, "exe", false);
							break;
						}
					}
				}

				var textOffX = 8 * 2;
				if (iconPath != null)
				{
					final ic = new FlxSprite(8*2, cardY + (44-4-30)*0.5).loadGraphic(Paths.getBitmapData(iconPath));
					ic.setGraphicSize(30, 30); ic.updateHitbox();
					final ish = new shaders.RoundedBorderShader(30*0.5, 0.0, 0xFF000000); ish.setSize(30, 30); ic.shader = ish;
					ic.camera = cam; add(ic); textOffX = 8*2 + 30 + 8;
				}

				final txt = new FlxText(textOffX, cardY + (44-4-20)*0.5, cardW - textOffX - 8, entry.name)
					.setFormat(Paths.font(Language.fontOrCJK("vcr.ttf")), Language.cjkSize(20), 0xFFFFFFFF, LEFT, NONE);
				txt.camera = cam; add(txt); nameTexts.push(txt);
}

			columns.push({key: def.key, cam: cam, nameTexts: nameTexts, cardBgs: cardBgs});

			final delay = i * 0.08;
			colBg.y -= 40; colTitle.y -= 40;
			FlxTween.tween(colBg,    {y: camY,                              alpha: 1}, 0.5, {ease: FlxEase.expoOut, startDelay: delay});
			FlxTween.tween(colTitle, {y: titleY - colTitle.height * 0.5,    alpha: 1}, 0.5, {ease: FlxEase.expoOut, startDelay: delay});
		}

		#if DISCORD_ALLOWED DiscordClient.changePresence("In the Credits Menu"); #end

		#if mobile createBackButton(FlxG.width - 245, FlxG.height - 240); #end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (subState != null) return;

		if (controls.BACK && !_closing #if mobile || backPressed #end)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxTween.cancelTweensOf(FlxG.sound.music); FlxTween.tween(FlxG.sound.music, {volume:1}, 0.6);
			close(); return;
		}

		var newCol = -1; var newRow = -1; canSelect = false;

		for (ci in 0...columns.length)
		{
			final col = columns[ci]; final cam = col.cam;
			if (!overCam(cam)) continue;

			if (FlxG.mouse.deltaWheel.y != 0 #if mobile || deltaMouseY != 0 && pressHolding #end)
			{
				final entries = credits.get(col.key);
				final maxScroll = entries != null ? Math.max(0, entries.length * 44 - cam.height + 8 * 2) : 0;
				cam.scroll.y = FlxMath.bound(cam.scroll.y - #if !mobile FlxG.mouse.deltaWheel.y * 44 #else deltaMouseY #end, 0, maxScroll);
			}

			for (i in 0...col.cardBgs.length)
			{
				if (col.cardBgs[i] != null && FlxG.mouse.overlaps(col.cardBgs[i], cam))
					{ canSelect = true; newCol = ci; newRow = i; userSelected = [col.key, i]; break; }
			}
		}

		if (newCol != hoveredCol || newRow != hoveredRow)
		{
			if (hoveredCol != -1 && hoveredRow != -1) highlight(columns[hoveredCol], hoveredRow, false);
			if (newCol     != -1 && newRow     != -1) highlight(columns[newCol],     newRow,     true);
			hoveredCol = newCol; hoveredRow = newRow;
		}

		if ((controls.ACCEPT || #if !mobile FlxG.mouse.justPressed #else shortPress #end) && canSelect) openSubState(new CreditPopup());
		Mouse.cursor = canSelect ? MouseCursor.BUTTON : MouseCursor.ARROW;
	}

	function highlight(col:{nameTexts:Array<FlxText>, cardBgs:Array<FlxSprite>}, row:Int, on:Bool):Void
	{
		if (row < col.nameTexts.length && col.nameTexts[row] != null) col.nameTexts[row].color = on ? 0xFFFFFF44 : 0xFFFFFFFF;
		if (row >= col.cardBgs.length || col.cardBgs[row] == null) return;
		col.cardBgs[row].pixels.fillRect(col.cardBgs[row].pixels.rect, on ? 0x44FFFFFF : 0x22FFFFFF);
		col.cardBgs[row].dirty = true;
	}

	inline function overCam(cam:FlxCamera):Bool
		return FlxG.mouse.viewX >= cam.x && FlxG.mouse.viewX <= cam.x + cam.width
			&& FlxG.mouse.viewY >= cam.y && FlxG.mouse.viewY <= cam.y + cam.height;

	override function closeSubState()
	{
		if (FlxG.sound.music != null && FlxG.sound.music.volume < 1) { FlxTween.cancelTweensOf(FlxG.sound.music); FlxTween.tween(FlxG.sound.music, {volume:1}, 0.6); }
		super.closeSubState();
	}

	override function destroy()
	{
		FlxG.mouse.visible = false;

		for (col in columns) 
			FlxG.cameras.remove(col.cam);
		
		columns = null;
		super.destroy();
	}
}


private class CreditPopup extends MusicBeatSubstate
{
	var user:Credit;
	var popCam:FlxCamera;
	var quoteCam:FlxCamera;
	var bg:FlxSprite;
	var userIcon:FlxSprite;
	var userQuote:FlxText;
	var scrollBar:FlxSprite;
	var explosion:FlxSprite;
	var socialButtons:Array<{id:String, btn:FlxSprite, url:String}> = [];

	#if VIDEOS_ALLOWED
	var userVideo:VideoSprite;
	var pauseBtn:FlxSprite;
	var videoPaused:Bool = false;
	#end

	var savedIconScale:Float = 1;
	var iconClickSpeed:Float = 0;
	var canClick:Bool = true;
	var pressingBtn:String = '';

	var createdIcon:Bool = false;

	override function create()
	{
		super.create();
		popCam = new FlxCamera(); popCam.bgColor = 0x00000000; FlxG.cameras.add(popCam, false);
		user = CreditsState.credits.get(CreditsState.userSelected[0])[CreditsState.userSelected[1]];
		buildBackground(); buildHeader(); buildDescription();
		buildQuotePanel(); buildExplosion(); buildExtra(); buildSocialButtons();
		bg.scale.set(0.85, 0.85); bg.alpha = 0;
		FlxTween.tween(bg,       {alpha: 1},       0.25, {ease: FlxEase.quadOut});
		FlxTween.tween(bg.scale, {x: 1.0, y: 1.0}, 0.3,  {ease: FlxEase.backOut});
		popCam.alpha = 0; FlxTween.tween(popCam, {alpha: 1}, 0.2, {ease: FlxEase.quadOut});
		#if mobile
		createBackButton(FlxG.width - 245, FlxG.height - 710);
		backButton.camera = popCam;
		#end
	}

	function buildBackground():Void
	{
		final w = FlxG.width - 100; final h = FlxG.height - 100;
		final c1 = user.colors != null && user.colors.length > 0 ? user.colors[0] : [115, 14, 78];
		final c2 = user.colors != null && user.colors.length > 1 ? user.colors[1] : [169, 23, 30];

		final dim = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x88000000);
		dim.camera = popCam; dim.scrollFactor.set(0, 0); add(dim);

		final m = new openfl.geom.Matrix(); m.createGradientBox(w, h, Math.PI / 2);
		final sh = new openfl.display.Shape();
		sh.graphics.beginGradientFill(openfl.display.GradientType.LINEAR, [FlxColor.fromRGB(c1[0],c1[1],c1[2]), FlxColor.fromRGB(c2[0],c2[1],c2[2])], [1,1], [0,255], m);
		sh.graphics.drawRoundRect(0, 0, w, h, 100, 100); sh.graphics.endFill();
		final bmp = new BitmapData(w, h, true, 0x00000000); bmp.draw(sh);
		final bsh = new openfl.display.Shape();
		bsh.graphics.lineStyle(8, 0xFFFFFFFF, 0.12); bsh.graphics.drawRoundRect(4, 4, w-8, h-8, 92, 92);
		bmp.draw(bsh);
		bg = new FlxSprite().loadGraphic(bmp); bg.screenCenter(); bg.camera = popCam; add(bg);
	}

	var dax:Float = 0; var day:Float = 100;
	function buildHeader():Void
	{
		function resolveImagePath(basePath:String, param:Dynamic, fallback:String):String
		{
			if (param != null)
			{
				for (ext in Paths.IMAGE_EXTS)
				{
					final path = basePath + '.' + ext;
					if (Paths.fileExists(path, true, "exe")) return Paths.getPath(path, "exe", false);
				}
			}
			return fallback;
		}

		final col = CreditsState.userSelected[0];
		
		final iconBase = 'extras/credits/icons/${user.icon}';
		final iconPath = resolveImagePath(iconBase, user.icon, 'assets/exe/extras/credits/missing_icon.webp');
		if (!iconPath.contains('missing_icon'))
		{
			userIcon = new FlxSprite(bg.x + 40, bg.y + 40).loadGraphic(Paths.getBitmapData(iconPath));
			userIcon.camera = popCam; fit(userIcon, 100, 100); savedIconScale = userIcon.scale.x; add(userIcon);
			createdIcon = true;
		}

		if (userIcon != null) dax = userIcon.width;
		if (userIcon != null) day = userIcon.height;
		final nm = new FlxText(0, 0, bg.width - 100, user.name ?? "Unknown");
		nm.setFormat(Paths.font(Language.fontOrCJK("vcr.ttf")), Language.cjkSize(76), (user.name == 'Divide' ? 0xFFFDFD51 : 0xFFFFFFFF), LEFT, OUTLINE, 0x55000000);
		nm.borderSize = Language.cjkBorder(3); nm.setPosition((bg.x + 40) + dax + 25, (bg.y + 40) + (day - nm.height) / 2);
		nm.camera = popCam; add(nm);

		final flagBase = 'extras/credits/countries/${user.nation}';
		final flagPath = resolveImagePath(flagBase, user.nation, 'assets/exe/extras/credits/missing_country.webp');
		if (!flagPath.contains('missing_country'))
		{    
			final flag = new FlxSprite().loadGraphic(Paths.getBitmapData(flagPath));
			flag.setPosition(Std.int(nm.x + nm.textField.textWidth + 15), Std.int(nm.y + (nm.height - flag.height) / 2));
			flag.camera = popCam; add(flag);
		}
	}

	function buildDescription():Void
	{
		final sepW = Std.int(bg.width / 2 - 50);
		final sepY = (bg.y + 40) + day + 25;
		final sepX = (bg.x + 40);
		final sbmp = new BitmapData(sepW, 3, true, 0x00000000);
		for (px in 0...sepW)
		{
			final a = Std.int(255 * (1.0 - Math.abs(px / (sepW - 1) * 2 - 1)));
			sbmp.setPixel32(px, 0, (a << 24) | 0xFFFFFF); sbmp.setPixel32(px, 1, (a << 24) | 0xFFFFFF);
			sbmp.setPixel32(px, 2, (Std.int(a * 0.4) << 24) | 0xFFFFFF);
		}
		final sep = new FlxSprite(sepX, sepY).loadGraphic(sbmp); sep.camera = popCam; add(sep);
		final desc = new FlxText(sepX, sep.y + 22, sepW, user.description ?? "No Description");
		desc.setFormat(Paths.font(Language.fontOrCJK("vcr.ttf")), Language.cjkSize(38), 0xFFFFFFFF, CENTER, OUTLINE, 0x66000000);
		desc.borderSize = Language.cjkBorder(2); desc.camera = popCam; add(desc);
	}

	function buildQuotePanel():Void
	{
		final qw = Std.int(bg.width * 0.4); final qh = Std.int(bg.height * 0.6);
		final qx = bg.x + bg.width - qw - 50; final qy = bg.y + bg.height - qh - 50;

		final pbmp = new BitmapData(qw, qh, true, 0x00000000); pbmp.fillRect(pbmp.rect, 0x77000000);
		final ps = new FlxSprite(qx, qy).loadGraphic(pbmp);
		final psh = new shaders.RoundedBorderShader(14.0, 0.0, 0xFF000000); psh.setSize(qw, qh); ps.shader = psh;
		ps.camera = popCam; add(ps);

		final bbmp = new BitmapData(qw, qh, true, 0x00000000);
		final bsh = new openfl.display.Shape(); bsh.graphics.lineStyle(1.5, 0xFFFFFFFF, 0.15); bsh.graphics.drawRoundRect(1,1,qw-2,qh-2,14,14);
		bbmp.draw(bsh);
		final bs = new FlxSprite(qx, qy).loadGraphic(bbmp); bs.camera = popCam; add(bs);

		quoteCam = new FlxCamera(); quoteCam.bgColor = 0x00000000;
		quoteCam.setSize(qw - 10, qh - 10); quoteCam.setPosition(qx + 5, qy + 5);
		FlxG.cameras.add(quoteCam, false);

		userQuote = new FlxText(5, 5, quoteCam.width - 15, user.quote ?? "No Quote");
		userQuote.setFormat(Paths.font(Language.fontOrCJK("vcr.ttf")), Language.cjkSize(24), 0xFFFFFFFF, LEFT, NONE);
		userQuote.camera = quoteCam; add(userQuote);

		final sbg = new FlxSprite(quoteCam.width - 5).makeGraphic(5, quoteCam.height, 0x44FFFFFF);
		sbg.camera = quoteCam; sbg.scrollFactor.set(); add(sbg);

		final barH = Std.int(Math.max(40, (quoteCam.height / userQuote.height) * quoteCam.height));
		scrollBar = new FlxSprite(quoteCam.width - 5).makeGraphic(5, barH, 0xCCFFFFFF);
		scrollBar.visible = (userQuote.height - 10) > quoteCam.height;
		scrollBar.camera = quoteCam; scrollBar.scrollFactor.set(); add(scrollBar);
	}

	function buildExplosion():Void
	{
		if (!createdIcon) return;
		var exp:String = 'explosion';
		if (user.name.toLowerCase() == 'vn2' ) exp = 'lava';
		explosion = new FlxSprite(userIcon.x - (exp == 'lava' ? 80 : 50), userIcon.y - (exp == 'lava' ? 80 : 100));
		explosion.frames = flixel.graphics.frames.FlxAtlasFrames.fromSparrow(Paths.getBitmapData('assets/exe/extras/credits/$exp.webp'), 'assets/exe/extras/credits/$exp.xml');
		explosion.animation.addByPrefix('idle', 'idle', 16, false);
		explosion.animation.play('idle');
		explosion.scale.set((exp == 'lava' ? 0.5 : 3), (exp == 'lava' ? 0.5 : 3)); explosion.antialiasing = false; explosion.updateHitbox();
		explosion.alpha = 0; explosion.camera = popCam; add(explosion);
	}

	function buildExtra():Void
	{
		if (user.extra == null) return;

		final col = CreditsState.userSelected[0];
		if (user.extra[0] == 'video')
		{
			final affectsMusic:Bool = user.extra[2] != true;
			if (affectsMusic) { FlxTween.cancelTweensOf(FlxG.sound.music); FlxTween.tween(FlxG.sound.music, {volume: 0.3}, 0.6); }

			#if VIDEOS_ALLOWED
			pauseBtn = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/extras/credits/play.webp'));
			pauseBtn.alpha = 0; pauseBtn.camera = popCam;

			userVideo = new VideoSprite(0, 0, false);
			userVideo.onFormat(() -> {
				fit(userVideo.video, 200, 200);
				userVideo.setPosition(bg.x + 40 + ((bg.width / 2 - 50) - userVideo.video.width) / 2, bg.y + bg.height - userVideo.video.height - 50);
				pauseBtn.setPosition(userVideo.x + (userVideo.video.width - pauseBtn.width) / 2, userVideo.y + (userVideo.video.height - pauseBtn.height) / 2);
			});
			userVideo.camera = popCam;
			add(userVideo); add(pauseBtn);

			for (ext in Paths.VIDEO_EXTS) 
			{
				if (userVideo.loadVideo('assets/exe/extras/credits/extra/${user.extra[1]}.$ext', [VideoSprite.ARG_LOOPING])) 
					userVideo.playDelayed();
			}
			#end
		}
		else if (user.extra[0] == 'image')
		{
			final img = new FlxSprite(0, 0).loadGraphic(Paths.getBitmapData('assets/exe/extras/credits/extra/${user.extra[1]}'));
			fit(img, 200, 200);
			img.setPosition(bg.x + 40 + ((bg.width / 2 - 50) - img.width) / 2, bg.y + bg.height - img.height - 50);
			final ish = new shaders.RoundedBorderShader(10.0, 0.0, 0xFF000000); ish.setSize(img.frameWidth, img.frameHeight); img.shader = ish;
			img.camera = popCam; add(img);
		}
	}

	function buildSocialButtons():Void
	{
		final socials = [
			{id: 'youtube', url: user.youtube},
			{id: 'twitter', url: user.twitter},
			{id: 'discord', url: user.discord},
			{id: 'kofi', url: user.kofi}
		];

		var sy = quoteCam.y + quoteCam.height + 10;

		for (social in socials)
		{
			if (social.url == null || social.url == '') continue;

			final btn = new FlxSprite().loadGraphic(Paths.getBitmapData('assets/exe/extras/credits/${social.id}.webp'));
			btn.setPosition(quoteCam.x - btn.width - 15, sy - btn.height);
			btn.camera = popCam;
			btn.color = 0xFF686868;
			btn.scale.set(0.9, 0.9);
			btn.updateHitbox();
			add(btn);

			socialButtons.push({id: social.id, btn: btn, url: social.url});

			sy -= btn.height + 10;
		}
	}

	override function update(elapsed:Float)
	{
		updateQuoteScroll();
		updateSocialButtons();
		updateVideoClick();
		updateIconClick(elapsed);
		updateNavigation();
		super.update(elapsed);

		var hovering = false;
		if (createdIcon) hovering = FlxG.mouse.overlaps(userIcon) && canClick;
		for (social in socialButtons) if (social.btn != null && FlxG.mouse.overlaps(social.btn)) { hovering = true; break; }
		#if VIDEOS_ALLOWED if (userVideo != null && FlxG.mouse.overlaps(userVideo.video)) hovering = true; #end
		Mouse.cursor = hovering ? MouseCursor.BUTTON : MouseCursor.ARROW;
	}

	function updateQuoteScroll():Void
	{
		if (!overCam(quoteCam)) return;
		
		if (FlxG.mouse.deltaWheel.y != 0 #if mobile || deltaMouseY != 0 && pressHolding #end)
		{
			quoteCam.scroll.y = FlxMath.bound(quoteCam.scroll.y - #if !mobile FlxG.mouse.deltaWheel.y * 22 #else deltaMouseY #end, 0, Math.max(0, userQuote.height - quoteCam.height + 10));
			scrollBar.y = FlxMath.lerp(0, quoteCam.height - scrollBar.height, quoteCam.scroll.y / Math.max(1, userQuote.height - quoteCam.height + 10));
		}
	}

	function updateSocialButtons():Void
	{
		for (social in socialButtons)
			if (social.id == 'discord')
				handlePopupBtn(social.btn, social.id, social.url);
			else
				handleBtn(social.btn, social.id, social.url);
	}

	function handleBtn(btn:FlxSprite, id:String, url:String):Void
	{
		if (btn == null || url == null) return;
		final over = FlxG.mouse.overlaps(btn);
		if (pressingBtn == '')
		{
			FlxTween.cancelTweensOf(btn.scale);
			btn.color = over ? 0xFFFFFFFF : 0xFF686868;
			FlxTween.tween(btn.scale, over ? {x:1.0,y:1.0} : {x:0.9,y:0.9}, over ? 0.12 : 0.1, {ease: over ? FlxEase.backOut : FlxEase.quadOut});
		}
		if (over && FlxG.mouse.justPressed) { btn.color = 0xFFCCCCCC; pressingBtn = id; }
		if (FlxG.mouse.released && pressingBtn == id) { pressingBtn = ''; CoolUtil.browserLoad(url); }
	}

	function handlePopupBtn(btn:FlxSprite, id:String, url:String):Void
	{
		if (btn == null) return;
		final over = FlxG.mouse.overlaps(btn);
		if (pressingBtn == '')
		{
			FlxTween.cancelTweensOf(btn.scale);
			btn.color = over ? 0xFFFFFFFF : 0xFF686868;
			FlxTween.tween(btn.scale, over ? {x:1.0, y:1.0} : {x:0.9, y:0.9}, over ? 0.12 : 0.1, {ease: over ? FlxEase.backOut : FlxEase.quadOut});
		}
		if (over && FlxG.mouse.justPressed) { btn.color = 0xFFCCCCCC; pressingBtn = id; }
		if (FlxG.mouse.released && pressingBtn == id) {
			pressingBtn = '';
			
			#if VIDEOS_ALLOWED
			final wasVideoPlaying = userVideo != null && userVideo.isPlaying();
			if (userVideo != null) userVideo.pause();
			openSubState(new SocialPopup(url, user.colors, userVideo, wasVideoPlaying));
			#else
			openSubState(new SocialPopup(url, user.colors));
			#end
		}
	}

	function updateVideoClick():Void
	{
		#if VIDEOS_ALLOWED
		if (userVideo == null || !FlxG.mouse.overlaps(userVideo.video) || !FlxG.mouse.justPressed) return;
		final affectsMusic:Bool = user.extra[2] != true;
		videoPaused = !videoPaused;
		if (videoPaused)
		{
			userVideo.pause();
			FlxTween.cancelTweensOf(pauseBtn); FlxTween.cancelTweensOf(pauseBtn.scale);
			pauseBtn.loadGraphic(Paths.getBitmapData('assets/exe/extras/credits/pause.webp'));
			pauseBtn.scale.set(1,1); pauseBtn.alpha = 1;
			if (affectsMusic) { FlxTween.cancelTweensOf(FlxG.sound.music); FlxTween.tween(FlxG.sound.music, {volume:1}, 0.6); }
		}
		else
		{
			userVideo.resume();
			pauseBtn.loadGraphic(Paths.getBitmapData('assets/exe/extras/credits/play.webp'));
			FlxTween.tween(pauseBtn.scale, {x:0,y:0}, 0.3);
			FlxTween.tween(pauseBtn, {alpha:0}, 0.3);
			if (affectsMusic) { FlxTween.cancelTweensOf(FlxG.sound.music); FlxTween.tween(FlxG.sound.music, {volume:0.3}, 0.6); }
		}
		#end
	}

	function updateIconClick(elapsed:Float):Void
	{
		if (iconClickSpeed > 0) { iconClickSpeed -= elapsed * (2 + iconClickSpeed * 0.5); if (iconClickSpeed < 0) iconClickSpeed = 0; }
		if (userIcon == null) return;

		final over = FlxG.mouse.overlaps(userIcon);
		if (canClick)
		{
			FlxTween.cancelTweensOf(userIcon.scale);
			FlxTween.tween(userIcon.scale, over ? {x:savedIconScale*1.08,y:savedIconScale*1.08} : {x:savedIconScale,y:savedIconScale}, over ? 0.12 : 0.15, {ease: FlxEase.quadOut});
		}

		if (!canClick || !FlxG.mouse.justPressed || !over) return;

		FlxTween.cancelTweensOf(userIcon); FlxTween.cancelTweensOf(userIcon.scale);

		userIcon.flipX = FlxG.random.bool();
		userIcon.angle = FlxG.random.float(-45, 45);
		userIcon.scale.set(FlxG.random.float(savedIconScale * 0.5, savedIconScale * 1.5), FlxG.random.float(savedIconScale * 0.5, savedIconScale * 1.5));

		FlxTween.tween(userIcon, {angle:0}, 0.3, {ease:FlxEase.backOut});
		FlxTween.tween(userIcon.scale, {x:savedIconScale,y:savedIconScale}, 0.3, {ease:FlxEase.backOut});

		FlxG.sound.play(Paths.sound('honksound'));

		iconClickSpeed++;
		if (iconClickSpeed > 10)
		{
			iconClickSpeed = 0; canClick = false;
			explosion.alpha = 1; explosion.animation.play('idle');
			userIcon.alpha = 0; FlxG.sound.play(Paths.sound('explosion'));

			backend.EXEAchievements.unlock('mehead');
			backend.EXEAchievements.save();
		}
	}

	function updateNavigation():Void
	{
		if (controls.BACK #if mobile || backPressed #end) { doClose(); return; }
		
		final len = CreditsState.credits.get(CreditsState.userSelected[0])?.length ?? 1;
		if (controls.UI_LEFT_P)  navTo(FlxMath.wrap(Std.int(CreditsState.userSelected[1]) - 1, 0, len - 1));
		if (controls.UI_RIGHT_P) navTo(FlxMath.wrap(Std.int(CreditsState.userSelected[1]) + 1, 0, len - 1));
	}

	function navTo(i:Int):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		CreditsState.userSelected[1] = i; doClose();
		new FlxTimer().start(0, (_) -> FlxG.state.openSubState(new CreditPopup()));
	}

	function doClose():Void
	{
		Mouse.cursor = MouseCursor.ARROW;
		FlxTween.cancelTweensOf(bg); FlxTween.cancelTweensOf(bg.scale);
		FlxTween.cancelTweensOf(popCam);
		if (pauseBtn != null) { FlxTween.cancelTweensOf(pauseBtn); FlxTween.cancelTweensOf(pauseBtn.scale); }
		if (userIcon != null) { FlxTween.cancelTweensOf(userIcon);  FlxTween.cancelTweensOf(userIcon.scale); }
		close();
	}

	inline function fit(s:FlxSprite, tw:Float, th:Float):Void
	{
		final sc = Math.max(tw / s.width, th / s.height);
		s.setGraphicSize(Math.floor(s.width * sc), Math.floor(s.height * sc)); s.updateHitbox();
	}

	inline function overCam(cam:FlxCamera):Bool
		return FlxG.mouse.viewX >= cam.x && FlxG.mouse.viewX <= cam.x + cam.width
			&& FlxG.mouse.viewY >= cam.y && FlxG.mouse.viewY <= cam.y + cam.height;

	override function destroy()
	{
		#if VIDEOS_ALLOWED if (userVideo != null) { userVideo.destroy(); userVideo = null; } #end
		FlxG.cameras.remove(quoteCam, true); FlxG.cameras.remove(popCam, true);
		super.destroy();
	}
}

private class SocialPopup extends MusicBeatSubstate
{
	var popupCam:FlxCamera;

	#if VIDEOS_ALLOWED
	var video:VideoSprite;
	var wasVideoPlaying:Bool;
	#end

	public function new(username:String, colors:Array<Array<Int>> #if VIDEOS_ALLOWED, ?video:VideoSprite, wasVideoPlaying:Bool = false #end)
	{
		super();

		#if VIDEOS_ALLOWED
		this.video = video;
		this.wasVideoPlaying = wasVideoPlaying;
		#end

		popupCam = new FlxCamera();
		popupCam.bgColor = 0x00000000;
		FlxG.cameras.add(popupCam, false);

		final dim = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x88000000);
		dim.camera = popupCam;
		dim.scrollFactor.set();
		add(dim);

		final w = 400;
		final h = 110;
		final x = (FlxG.width - w) / 2;
		final y = (FlxG.height - h) / 2;

		final c1 = colors != null && colors.length > 0 ? colors[0] : [115, 14, 78];
		final c2 = colors != null && colors.length > 1 ? colors[1] : [169, 23, 30];

		final m = new openfl.geom.Matrix();
		m.createGradientBox(w, h, Math.PI / 2);
		final sh = new openfl.display.Shape();
		sh.graphics.beginGradientFill(openfl.display.GradientType.LINEAR, [FlxColor.fromRGB(c1[0], c1[1], c1[2]), FlxColor.fromRGB(c2[0], c2[1], c2[2])], [1, 1], [0, 255], m);
		sh.graphics.drawRoundRect(0, 0, w, h, 32, 32);
		sh.graphics.endFill();
		final bmp = new BitmapData(w, h, true, 0x00000000);
		bmp.draw(sh);
		final bsh = new openfl.display.Shape();
		bsh.graphics.lineStyle(8, 0xFFFFFFFF, 0.12);
		bsh.graphics.drawRoundRect(4, 4, w - 8, h - 8, 24, 24);
		bmp.draw(bsh);
		final bg = new FlxSprite(x, y).loadGraphic(bmp);
		bg.camera = popupCam;
		add(bg);

		final text = new FlxText(x + 20, y, w - 40, '@' + username);
		text.setFormat(Paths.font(Language.fontOrCJK("vcr.ttf")), Language.cjkSize(28), FlxColor.WHITE, CENTER, OUTLINE, 0x55000000);
		text.borderSize = Language.cjkBorder(2);
		text.y = y + (h - text.height) / 2;
		text.camera = popupCam;
		add(text);
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK) { close(); return; }
		super.update(elapsed);
	}

	override function destroy()
	{
		FlxG.cameras.remove(popupCam, true);
		popupCam = null;

		#if VIDEOS_ALLOWED
		if (video != null && wasVideoPlaying)
			video.resume();
		#end

		super.destroy();
	}
}