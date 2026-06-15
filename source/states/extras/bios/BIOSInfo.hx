package states.extras.bios;

import flixel.*;
import flixel.util.FlxSpriteUtil;

class BIOSInfo
{
	var bios:BIOS;

	static inline final SCROLL_W:Int    = 8;
	static inline final SCROLL_PAD:Int  = 10; 

	public var bioBox:FlxSprite;
	public var bioTxt:FlxText;

	var boxCanva:FlxCamera;
	var helpCanva:FlxCamera;
	var bgThing:FlxSprite;
	var helpText:FlxText;

	var scrollTrack:FlxSprite;
	var scrollThumb:FlxSprite;

	var moveCounter:Float = 0;
	var moveTween:FlxTween;
	var canMove:Bool = true;
	
	public var boxX:Int   = 845;
	public var boxY:Int   = 36;
	public var boxW:Int   = 407;
	public var boxH:Int   = 642;

	static inline final PAD_X:Int     = 16;
	static inline final PAD_TOP:Int   = 13;
	static inline final PAD_RIGHT:Int = 80;

	public function new(parent:BIOS)
	{
		bios = parent;

		helpCanva = new FlxCamera();
		helpCanva.bgColor = 0x00000000;
		FlxG.cameras.add(helpCanva, false);

		_buildBox();

		final bc = bios.biosCharacter;
		bioTxt = new FlxText(PAD_X, PAD_TOP, boxW - PAD_X - PAD_RIGHT, bc.bios_list.length > 0 ? bc.bios_list[0] : '', 23);
		bioTxt.setFormat(Paths.font('smallass.TTF'), 23, FlxColor.WHITE, LEFT);
		bioTxt.antialiasing = ClientPrefs.data.antialiasing;
		bioTxt.scrollFactor.set();
		bioTxt.visible = true;
		bioTxt.cameras = [boxCanva];
		bios.add(bioTxt);

		_buildScrollbar();
		
		bgThing = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgThing.scrollFactor.set();
		bgThing.alpha   = 0.5;
		bgThing.visible = false;
		bgThing.cameras = [helpCanva];
		bios.add(bgThing);
		
		helpText = new FlxText(0, 0, 0);
		helpText.setFormat(Paths.font('NiseSegaSonic.TTF'), 30, FlxColor.WHITE, CENTER);
		helpText.scrollFactor.set();
		helpText.visible = false;
		helpText.cameras = [helpCanva];
		bios.add(helpText);
	}

	function _buildScrollbar():Void
	{
		if (scrollTrack != null) bios.remove(scrollTrack);
		if (scrollThumb != null) bios.remove(scrollThumb);

		final trackH = boxH - SCROLL_PAD * 2;
		final tx = boxX + boxW - SCROLL_W - SCROLL_PAD;
		final ty = boxY + SCROLL_PAD;
		
		scrollTrack = new FlxSprite(tx, ty).makeGraphic(SCROLL_W, trackH, 0x44FFFFFF);
		scrollTrack.scrollFactor.set();
		bios.add(scrollTrack);

		scrollThumb = new FlxSprite(tx, ty).makeGraphic(SCROLL_W, 40, FlxColor.WHITE);
		scrollThumb.scrollFactor.set();
		bios.add(scrollThumb);
	}

	function _buildBox():Void
	{
		if (boxCanva != null) FlxG.cameras.remove(boxCanva);
		if (bioBox   != null) bios.remove(bioBox);
		
		boxCanva = new FlxCamera(boxX, boxY, boxW, boxH);
		boxCanva.bgColor = 0x00000000;
		FlxG.cameras.add(boxCanva, false);

		bioBox = new FlxSprite(boxX, boxY);
		bioBox.makeGraphic(boxW, boxH, FlxColor.TRANSPARENT, true);
		FlxSpriteUtil.drawRect(bioBox, 0, 0, boxW, boxH, FlxColor.TRANSPARENT, {thickness: 7, color: FlxColor.WHITE});
		bioBox.scrollFactor.set();
		bios.add(bioBox);
	}

	public function resizeBox(nx:Int, ny:Int, nw:Int, nh:Int):Void
	{
		boxX = nx; boxY = ny; boxW = nw; boxH = nh;
		_buildBox();
		_buildScrollbar();
		
		if (bioTxt != null)
		{
			bioTxt.cameras = [boxCanva];
			bioTxt.fieldWidth = boxW - PAD_X - PAD_RIGHT;
			bioTxt.y = PAD_TOP;
		}
	}

	public function onCharChanged(index:Int):Void
	{
		bioTxt.text = bios.biosCharacter.bios_list[index];
		bioTxt.y    = PAD_TOP;
	}

	public function onVariantChanged(v:Dynamic):Void
	{
		bioTxt.text = (v.bio != null) ? Std.string(v.bio) : bios.biosCharacter.bios_list[bios.biosCharacter.curChar];
		bioTxt.y    = PAD_TOP;
	}

	public function resetScroll():Void
	{
		moveTween?.cancel(); 
		moveTween = null;
		moveCounter = 0;
		canMove     = true;
	}

	public function update(elapsed:Float):Void
	{
		final textTaller = bioTxt.visible && bioTxt.height > boxH;
		
		if (FlxG.mouse.deltaWheel.y != 0 && FlxG.mouse.overlaps(bioBox) && textTaller)
		{
			moveTween?.cancel();
			moveTween = null;
			moveCounter = 0;
			canMove     = true;
			bioTxt.y += FlxG.mouse.deltaWheel.y * 10;
			
			if (bioTxt.y > PAD_TOP)                 
				bioTxt.y = PAD_TOP;
			if (bioTxt.y < -(bioTxt.height - boxH)) 
				bioTxt.y = -(bioTxt.height - boxH);
		}

		if (scrollTrack != null && scrollThumb != null)
		{
			scrollTrack.visible = textTaller;
			scrollThumb.visible = textTaller;
			
			if (textTaller)
			{
				final trackH    = boxH - SCROLL_PAD * 2;
				final totalText = bioTxt.height - PAD_TOP;
				final ratio     = boxH / totalText;
				final thumbH    = Std.int(Math.max(20, trackH * ratio));
				
				if (scrollThumb.height != thumbH)
					scrollThumb.makeGraphic(SCROLL_W, thumbH, FlxColor.WHITE);

				final scrollRange = totalText - boxH;
				var scrollPos   = scrollRange > 0 ? (PAD_TOP - bioTxt.y) / scrollRange : 0;
				scrollPos = Math.max(0, Math.min(1, scrollPos));

				final thumbRange = trackH - thumbH;
				scrollThumb.y = scrollTrack.y + scrollPos * thumbRange;
			}
		}
	}

	public function clearCameras():Void
	{
		if (boxCanva != null) { FlxG.cameras.remove(boxCanva); boxCanva = null; }
		if (helpCanva != null) { FlxG.cameras.remove(helpCanva); helpCanva = null; }
	}

	public function destroy():Void
	{
		clearCameras();
		if (scrollTrack != null) bios.remove(scrollTrack);
		if (scrollThumb != null) bios.remove(scrollThumb);
	}
}