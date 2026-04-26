package backend.ui;

import flixel.FlxObject;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flash.events.KeyboardEvent;
import lime.system.Clipboard;

// ─── Shared typedef ──────────────────────────────────────────────────────────

typedef UIStyleData = {
	var bgColor:FlxColor;
	var textColor:FlxColor;
	var bgAlpha:Float;
}

// ─── PsychUIEventHandler / PsychUIEvent ──────────────────────────────────────

class PsychUIEventHandler
{
	public static function event(id:String, sender:Dynamic)
	{
		var state:Dynamic = cast FlxG.state;
		if (state == null) return;

		while (state.subState != null)
			state = cast state.subState;

		if (state != null && state.UIEvent != null)
			state.UIEvent(id, sender);
	}
}

interface PsychUIEvent {
	public function UIEvent(id:String, sender:Dynamic):Void;
}

// ─── PsychUITab ──────────────────────────────────────────────────────────────

class PsychUITab extends FlxSprite
{
	public var name(default, set):String;
	public var text:FlxText;
	public var menu:FlxSpriteGroup = new FlxSpriteGroup();

	public function new(name:String)
	{
		super();
		makeGraphic(1, 1, FlxColor.WHITE);
		color = FlxColor.BLACK;
		alpha = 0.6;

		@:bypassAccessor this.name = name;
		text = new FlxText(0, 0, 100, name);
		text.alignment = CENTER;
	}

	override function draw()
	{
		super.draw();

		if (visible && text != null && text.exists && text.visible)
		{
			text.x = x;
			text.y = y + height / 2 - text.height / 2;
			text.draw();
		}
	}

	override function destroy()
	{
		text = FlxDestroyUtil.destroy(text);
		menu = FlxDestroyUtil.destroy(menu);
		super.destroy();
	}

	public function updateMenu(parent:PsychUIBox, elapsed:Float)
	{
		if (menu != null && menu.exists && menu.active)
		{
			menu.scrollFactor.set(parent.scrollFactor.x, parent.scrollFactor.y);
			menu.update(elapsed);
		}
	}

	public function drawMenu(parent:PsychUIBox)
	{
		if (menu != null && menu.exists && menu.visible)
		{
			menu.x = parent.x;
			menu.y = parent.y + parent.tabHeight;
			menu.draw();
		}
	}

	public function resize(width:Int, height:Int)
	{
		setGraphicSize(width, height);
		updateHitbox();
		text.fieldWidth = width;
	}

	function set_name(v:String)
	{
		text.text = v;
		return (name = v);
	}

	override function set_cameras(v:Array<FlxCamera>)
	{
		text.cameras = v;
		menu.cameras = v;
		return super.set_cameras(v);
	}

	override function set_camera(v:FlxCamera)
	{
		text.camera = v;
		menu.camera = v;
		return super.set_camera(v);
	}
}

// ─── PsychUIBox ──────────────────────────────────────────────────────────────

class PsychUIBox extends FlxSpriteGroup
{
	public static final CLICK_EVENT    = "uibox_click";
	public static final MINIMIZE_EVENT = "uibox_minimize";
	public static final DRAG_EVENT     = "uibox_drag";
	public static final DROP_EVENT     = "uibox_drop";
	public var tabs(default, null):Array<PsychUITab> = [];

	public var selectedTab(default, set):PsychUITab   = null;
	public var selectedIndex(default, set):Int         = -1;
	public var selectedName(default, set):String       = null;

	public var bg:FlxSprite;

	public var selectedStyle:UIStyleData   = { bgColor: FlxColor.WHITE, textColor: FlxColor.BLACK, bgAlpha: 1 };
	public var hoverStyle:UIStyleData      = { bgColor: FlxColor.WHITE, textColor: FlxColor.BLACK, bgAlpha: 0.6 };
	public var unselectedStyle:UIStyleData = { bgColor: FlxColor.BLACK, textColor: FlxColor.WHITE, bgAlpha: 0.6 };

	public var canMove:Bool = true;
	public var canMinimize(default, set):Bool    = true;
	public var isMinimized(default, set):Bool    = false;
	public var minimizeOnFocusLost:Bool          = false;

	public function new(x:Float, y:Float, width:Int, height:Int, tabs:Array<String> = null)
	{
		super(x, y);

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		bg.color = FlxColor.BLACK;
		bg.alpha = 0.6;
		add(bg);

		if (tabs != null)
		{
			for (tab in tabs)
			{
				var createdTab:PsychUITab = new PsychUITab(tab);
				this.tabs.push(createdTab);
				add(createdTab);
			}
		}

		resize(width, height);
		selectedIndex = 0;
		forceCheckNext = true;
	}

	var _draggingPos:FlxPoint;
	var _draggingPoint:FlxPoint;
	var _pressedBox:Bool   = false;
	var _draggingBox:Bool  = false;
	var _lastTab:PsychUITab;
	var _lastClick:Float   = 0;

	public var forceCheckNext:Bool      = false;
	public var broadcastBoxEvents:Bool  = true;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		_lastClick += elapsed;
		if (!FlxG.mouse.released && _draggingBox && canMove)
		{
			var newPoint:FlxPoint = FlxG.mouse.getPositionInCameraView(camera);
			setPosition(_draggingPos.x - (_draggingPoint.x - newPoint.x), _draggingPos.y - (_draggingPoint.y - newPoint.y));
		}
		else
		{
			var wasDragging:Bool = _draggingBox;
			_draggingPos  = null;
			_draggingPoint = null;
			_draggingBox  = false;
			if (FlxG.mouse.released)
			{
				if (_pressedBox) forceCheckNext = true;
				_pressedBox = false;
			}
			if (wasDragging && broadcastBoxEvents) PsychUIEventHandler.event(DROP_EVENT, this);
		}

		for (tab in tabs)
		{
			tab.scrollFactor.set(scrollFactor.x, scrollFactor.y);
			tab.text.scrollFactor.set(scrollFactor.x, scrollFactor.y);
		}

		var _ignoreTabUpdate:Bool = false;
		if (forceCheckNext || FlxG.mouse.justMoved || FlxG.mouse.justPressed || FlxG.mouse.justReleased)
		{
			forceCheckNext = false;
			for (tab in tabs)
			{
				if (FlxG.mouse.overlaps(tab, camera))
				{
					tab.color = hoverStyle.bgColor;
					tab.alpha = hoverStyle.bgAlpha;
					tab.text.color = hoverStyle.textColor;

					if (FlxG.mouse.justPressed)
						_pressedBox = true;

					if (!_draggingBox && canMove && _pressedBox && FlxG.mouse.pressed
						&& (Math.abs(FlxG.mouse.deltaScreenX) > 1 || Math.abs(FlxG.mouse.deltaScreenY) > 1))
					{
						_draggingPos   = FlxPoint.weak(x, y);
						_draggingPoint = FlxG.mouse.getPositionInCameraView(camera);
						_draggingBox   = true;
						if (broadcastBoxEvents) PsychUIEventHandler.event(DRAG_EVENT, this);
					}

					if (FlxG.mouse.justReleased && canMinimize && _lastClick < 0.15 && selectedTab == tab && _lastTab == selectedTab)
					{
						_ignoreTabUpdate = true;
						isMinimized = !isMinimized;
						_lastClick = 0;
					}

					if (FlxG.mouse.justPressed)
					{
						if (selectedTab != tab)
						{
							isMinimized      = false;
							_ignoreTabUpdate = true;
						}
						_lastTab    = selectedTab;
						selectedTab = tab;
						_lastClick  = 0;
						if (broadcastBoxEvents) PsychUIEventHandler.event(CLICK_EVENT, this);
					}
					else if (selectedTab != tab) continue;
				}

				var style:UIStyleData = (selectedTab == tab) ? selectedStyle : unselectedStyle;
				tab.color       = style.bgColor;
				tab.alpha       = style.bgAlpha;
				tab.text.color  = style.textColor;
			}
		}

		if (_ignoreTabUpdate)
		{
			if (broadcastBoxEvents)
				PsychUIEventHandler.event(MINIMIZE_EVENT, this);
		}
		else if (selectedTab != null && !isMinimized)
			selectedTab.updateMenu(this, elapsed);

		if (minimizeOnFocusLost && FlxG.mouse.justPressed && !isMinimized && !FlxG.mouse.overlaps(bg, camera))
		{
			isMinimized = true;
			if (broadcastBoxEvents)
				PsychUIEventHandler.event(MINIMIZE_EVENT, this);
		}
	}

	override function set_cameras(v:Array<FlxCamera>)
	{
		for (tab in tabs) tab.cameras = v;
		return super.set_cameras(v);
	}

	override function set_camera(v:FlxCamera)
	{
		for (tab in tabs) tab.camera = v;
		return super.set_camera(v);
	}

	override function draw()
	{
		super.draw();

		if (selectedTab != null && !isMinimized)
			selectedTab.drawMenu(this);
	}

	override function destroy()
	{
		tabs        = null;
		selectedTab = null;
		super.destroy();
	}

	public function addTab(name:String)
	{
		var createdTab:PsychUITab = new PsychUITab(name);
		tabs.push(createdTab);
		add(createdTab);
		updateTabs();

		if (selectedTab == null)
			selectedTab = createdTab;
	}

	public var tabHeight:Int = 20;
	public function updateTabs()
	{
		var wid:Int = Std.int(bg.width / tabs.length);
		for (num => tab in tabs)
		{
			tab.x = x + wid * num;
			tab.resize(wid, tabHeight);
			tab.cameras = cameras;
		}
	}

	var _originalHeight:Int = 0;
	public function resize(width:Int, height:Int)
	{
		_originalHeight = height;
		bg.setGraphicSize(width, height);
		bg.updateHitbox();
		updateTabs();
	}

	private function set_selectedTab(v:PsychUITab)
	{
		if (v != null)
		{
			@:bypassAccessor selectedName  = v.name;
			@:bypassAccessor selectedIndex = tabs.indexOf(v);
		}
		else
		{
			@:bypassAccessor selectedName  = null;
			@:bypassAccessor selectedIndex = -1;
		}
		return (selectedTab = v);
	}

	private function set_selectedName(v:String)
	{
		if (v == null || v.trim().length < 1) selectedTab = null;

		for (tab in tabs)
		{
			if (tab.name == v)
			{
				selectedTab = tab;
				return v;
			}
		}
		return null;
	}

	private function set_selectedIndex(v:Int)
	{
		v = Std.int(Math.max(Math.min(v, tabs.length - 1), -1));
		if (v > -1) selectedTab = tabs[v];
		else selectedTab = null;
		return v;
	}

	public function getTab(name:String)
	{
		for (tab in tabs)
			if (tab.name == name)
				return tab;

		return null;
	}

	function set_canMinimize(v:Bool)
	{
		isMinimized = false;
		return (canMinimize = v);
	}

	function set_isMinimized(v:Bool)
	{
		if (!v)
		{
			bg.scale.y = _originalHeight;
			bg.updateHitbox();
		}
		else
		{
			bg.scale.y = tabHeight + 20;
			bg.updateHitbox();
			selectedTab = null;
		}
		return (isMinimized = v);
	}
}

// ─── PsychUIButton ───────────────────────────────────────────────────────────

class PsychUIButton extends FlxSpriteGroup
{
	public static final CLICK_EVENT = 'button_click';

	public var name:String;
	public var label(default, set):String;
	public var bg:FlxSprite;
	public var text:FlxText;

	public var onChangeState:String->Void;
	public var onClick:Void->Void;

	public var clickStyle:UIStyleData  = { bgColor: FlxColor.BLACK,   textColor: FlxColor.WHITE, bgAlpha: 1 };
	public var hoverStyle:UIStyleData  = { bgColor: FlxColor.WHITE,   textColor: FlxColor.BLACK, bgAlpha: 1 };
	public var normalStyle:UIStyleData = { bgColor: 0xFFAAAAAA,       textColor: FlxColor.BLACK, bgAlpha: 1 };

	public function new(x:Float = 0, y:Float = 0, label:String = '', ?onClick:Void->Void = null, ?wid:Int = 80, ?hei:Int = 20)
	{
		super(x, y);
		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		add(bg);
		bg.color = 0xFFAAAAAA;
		bg.alpha = 0.6;

		text = new FlxText(0, 0, 1, '');
		text.alignment = CENTER;
		add(text);
		resize(wid, hei);
		this.label = label;

		this.onClick = onClick;
		forceCheckNext = true;
	}

	public var isClicked:Bool          = false;
	public var forceCheckNext:Bool     = false;
	public var broadcastButtonEvent:Bool = true;
	var _firstFrame:Bool = true;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (_firstFrame)
		{
			bg.color  = normalStyle.bgColor;
			bg.alpha  = normalStyle.bgAlpha;
			text.color = normalStyle.textColor;
			_firstFrame = false;
		}

		if (isClicked && FlxG.mouse.released)
		{
			forceCheckNext = true;
			isClicked      = false;
		}

		if (forceCheckNext || FlxG.mouse.justMoved || FlxG.mouse.justPressed)
		{
			var overlapped:Bool = (FlxG.mouse.overlaps(bg, camera));

			forceCheckNext = false;

			if (!isClicked)
			{
				var style:UIStyleData = overlapped ? hoverStyle : normalStyle;
				bg.color   = style.bgColor;
				bg.alpha   = style.bgAlpha;
				text.color = style.textColor;
			}

			if (overlapped && FlxG.mouse.justPressed)
			{
				isClicked  = true;
				bg.color   = clickStyle.bgColor;
				bg.alpha   = clickStyle.bgAlpha;
				text.color = clickStyle.textColor;
				if (onClick != null) onClick();
				if (broadcastButtonEvent) PsychUIEventHandler.event(CLICK_EVENT, this);
			}
		}
	}

	public function resize(width:Int, height:Int)
	{
		bg.setGraphicSize(width, height);
		bg.updateHitbox();
		text.fieldWidth = width;
		text.x = bg.x;
		text.y = bg.y + height / 2 - text.height / 2;
	}

	function set_label(v:String)
	{
		if (text != null && text.exists) text.text = v;
		return (label = v);
	}
}

// ─── PsychUICheckBox ─────────────────────────────────────────────────────────

class PsychUICheckBox extends FlxSpriteGroup
{
	public static final CLICK_EVENT = 'checkbox_click';

	public var name:String;
	public var box:FlxSprite;
	public var text:FlxText;
	public var label(get, set):String;

	public var checked(default, set):Bool = false;
	public var onClick:Void->Void         = null;

	public function new(x:Float, y:Float, label:String, ?textWid:Int = 100, ?callback:Void->Void)
	{
		super(x, y);

		box = new FlxSprite();
		boxGraphic();
		add(box);

		text = new FlxText(box.width + 4, 0, textWid, label);
		text.y += box.height / 2 - text.height / 2;
		add(text);

		this.onClick = callback;
	}

	public function boxGraphic()
	{
		box.loadGraphic(Paths.image('psych-ui/checkbox', 'embed'), true, 16, 16);
		box.animation.add('false', [0]);
		box.animation.add('true', [1]);
		box.animation.play('false');
	}

	public var broadcastCheckBoxEvent:Bool = true;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed)
		{
			var screenPos:FlxPoint = getScreenPosition(null, camera);
			var mousePos:FlxPoint  = FlxG.mouse.getPositionInCameraView(camera);
			if ((mousePos.x >= screenPos.x && mousePos.x < screenPos.x + width) &&
				(mousePos.y >= screenPos.y && mousePos.y < screenPos.y + height))
			{
				checked = !checked;
				if (onClick != null) onClick();
				if (broadcastCheckBoxEvent) PsychUIEventHandler.event(CLICK_EVENT, this);
			}
		}
	}

	function set_checked(v:Any)
	{
		var v:Bool = (v != null && v != false);
		box.animation.play(Std.string(v));
		return (checked = v);
	}

	function get_label():String   return text.text;
	function set_label(v:String):String return (text.text = v);
}

// ─── PsychUISlider ───────────────────────────────────────────────────────────

class PsychUISlider extends FlxSpriteGroup
{
	public static final CHANGE_EVENT = "slider_change";
	public var bar:FlxSprite;
	public var minText:FlxText;
	public var maxText:FlxText;
	public var valueText:FlxText;
	public var handle:FlxSprite;
	public var label(get, set):String;
	public var labelText:FlxText;

	public var value(default, set):Float    = 0;
	public var onChange:Float->Void;
	public var min(default, set):Float      = -999;
	public var max(default, set):Float      = 999;
	public var decimals(default, set):Int   = 2;

	public function new(x:Float = 0, y:Float = 0, callback:Float->Void, def:Float = 0, min:Float = -999, max:Float = 999,
		wid:Float = 200, mainColor:FlxColor = FlxColor.WHITE, handleColor:FlxColor = 0xFFAAAAAA)
	{
		super(x, y);
		this.onChange = callback;

		bar = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		bar.scale.set(wid, 5);
		bar.updateHitbox();
		bar.color = mainColor;
		add(bar);

		minText   = new FlxText(0, 0, 80, '', 8);
		minText.alignment = CENTER;
		minText.color = mainColor;
		add(minText);

		maxText   = new FlxText(0, 0, 80, '', 8);
		maxText.alignment = CENTER;
		maxText.color = mainColor;
		add(maxText);

		valueText = new FlxText(0, 0, 80, '', 8);
		valueText.alignment = CENTER;
		valueText.color = handleColor;
		add(valueText);

		labelText = new FlxText(0, 0, wid, '', 8);
		labelText.alignment = CENTER;
		add(labelText);

		handle = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		handle.scale.set(5, 15);
		handle.updateHitbox();
		handle.color = handleColor;
		add(handle);

		this.min   = min;
		this.max   = max;
		this.value = def;
		_updatePositions();
		forceNextUpdate = true;
	}

	public var movingHandle:Bool       = false;
	public var forceNextUpdate:Bool    = false;
	public var broadcastSliderEvent:Bool = true;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justMoved || FlxG.mouse.justPressed || forceNextUpdate)
		{
			forceNextUpdate = false;
			if (FlxG.mouse.justPressed && (FlxG.mouse.overlaps(bar, camera) || FlxG.mouse.overlaps(handle, camera)))
				movingHandle = true;

			if (movingHandle)
			{
				var lastValue:Float = FlxMath.roundDecimal(value, decimals);
				value = Math.max(min, Math.min(max, FlxMath.remapToRange(FlxG.mouse.getPositionInCameraView(camera).x, bar.x, bar.x + bar.width, min, max)));
				if (this.onChange != null && lastValue != value)
				{
					this.onChange(FlxMath.roundDecimal(value, decimals));
					if (broadcastSliderEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
				}
			}
		}

		if (FlxG.mouse.released)
			movingHandle = false;
	}

	function _updatePositions()
	{
		minText.x   = bar.x - minText.width / 2;
		maxText.x   = bar.x + bar.width - maxText.width / 2;
		valueText.x = bar.x + bar.width / 2 - valueText.width / 2;

		labelText.x = bar.x + bar.width / 2 - labelText.width / 2;
		if (label.length > 0) bar.y = labelText.y + 24;

		minText.y = maxText.y = valueText.y = bar.y + 12;

		_updateHandleX();
		handle.y = bar.y + bar.height / 2 - handle.height / 2;
	}

	function _updateHandleX()
		handle.x = bar.x - handle.width / 2 + FlxMath.remapToRange(FlxMath.roundDecimal(value, decimals), min, max, 0, bar.width);

	function set_decimals(v:Int)
	{
		decimals = v;
		minText.text   = Std.string(FlxMath.roundDecimal(min, decimals));
		maxText.text   = Std.string(FlxMath.roundDecimal(max, decimals));
		valueText.text = Std.string(FlxMath.roundDecimal(value, decimals));
		if (this.onChange != null) this.onChange(FlxMath.roundDecimal(value, decimals));
		_updatePositions();
		return decimals;
	}

	function set_min(v:Float)
	{
		if (v > max) max = v;
		min = v;
		minText.text = Std.string(FlxMath.roundDecimal(min, decimals));
		_updateHandleX();
		return min;
	}

	function set_max(v:Float)
	{
		if (v < min) min = v;
		max = v;
		maxText.text = Std.string(FlxMath.roundDecimal(max, decimals));
		_updateHandleX();
		return max;
	}

	function set_value(v:Float)
	{
		value = Math.max(min, Math.min(max, v));
		valueText.text = Std.string(FlxMath.roundDecimal(value, decimals));
		_updateHandleX();
		return value;
	}

	function set_label(v:String)
	{
		labelText.text = v;
		_updatePositions();
		return labelText.text;
	}

	function get_label() return labelText.text;
}

// ─── PsychUIRadioGroup / PsychUIRadioItem ────────────────────────────────────

class PsychUIRadioGroup extends FlxSpriteGroup
{
	public static final CLICK_EVENT = 'radiogroup_click';

	public var labels(default, set):Array<String>         = [];
	public var radios:Array<PsychUIRadioItem>              = [];

	public var space(default, set):Float                  = 25;
	public var textWidth(default, set):Int                = 100;
	public var maxItems(default, set):Int                 = 0;

	public var stackHorizontal(default, set):Bool         = false;

	public var checked(default, set):Int                  = -1;
	public var checkedRadio(default, set):PsychUIRadioItem;

	public var arrowUp:FlxSprite;
	public var arrowDown:FlxSprite;

	public var onClick:Void->Void;

	var _hitbox:FlxObject;
	public function new(x:Float, y:Float, labels:Array<String>, space:Float = 25, maxItems:Int = 0, ?isHorizontal:Bool = false, ?textWidth:Int = 100)
	{
		super(x, y);

		_hitbox = new FlxObject();

		arrowUp = new FlxSprite().loadGraphic(Paths.image('psych-ui/arrow_up', 'embed'), true, 24, 18);
		arrowUp.animation.add('normal', [0]);
		arrowUp.animation.add('press',  [1]);
		arrowUp.animation.play('normal');
		arrowUp.visible = false;

		arrowDown = new FlxSprite().loadGraphic(Paths.image('psych-ui/arrow_down', 'embed'), true, 24, 18);
		arrowDown.animation.add('normal', [0]);
		arrowDown.animation.add('press',  [1]);
		arrowDown.animation.play('normal');
		arrowDown.visible = false;

		this.space     = space;
		this.textWidth = textWidth;
		@:bypassAccessor if (labels != null) this.labels = labels;
		@:bypassAccessor this.stackHorizontal             = isHorizontal;
		this.maxItems = maxItems;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		_hitbox.x      = x;
		_hitbox.y      = y;
		_hitbox.width  = width;
		_hitbox.height = height;
		if (maxItems > 0 && maxItems < labels.length && FlxG.mouse.wheel != 0 && FlxG.mouse.overlaps(_hitbox, camera))
			curScroll -= FlxG.mouse.wheel;

		var baseY:Float = y + radios.length * space;
		if (stackHorizontal) baseY = y + 25;

		var hasArrowUp:Bool   = false;
		var hasArrowDown:Bool = false;
		if (arrowDown != null && arrowDown.exists && arrowDown.active)
		{
			arrowDown.x = x;
			arrowDown.y = baseY;
			hasArrowDown = true;
		}

		if (arrowUp != null && arrowUp.exists && arrowUp.active)
		{
			arrowUp.x = x;
			arrowUp.y = baseY;
			hasArrowUp = true;
			if (hasArrowDown) arrowDown.x += arrowUp.width + 8;
		}

		if (FlxG.mouse.justPressed)
		{
			if (hasArrowUp && maxItems > 0 && curScroll > 0 && FlxG.mouse.overlaps(arrowUp, camera))
			{
				curScroll--;
				arrowUp.animation.play('press');
			}
			else if (hasArrowDown && maxItems > 0 && curScroll < (labels.length - maxItems) && FlxG.mouse.overlaps(arrowDown, camera))
			{
				curScroll++;
				arrowDown.animation.play('press');
			}
		}
		else if (FlxG.mouse.released)
		{
			if (hasArrowUp   && arrowUp.animation.curAnim   != null && arrowUp.animation.curAnim.name   != 'normal') arrowUp.animation.play('normal');
			if (hasArrowDown && arrowDown.animation.curAnim != null && arrowDown.animation.curAnim.name != 'normal') arrowDown.animation.play('normal');
		}
	}

	override function draw()
	{
		super.draw();

		if (arrowUp   != null && arrowUp.exists   && arrowUp.active)   arrowUp.draw();
		if (arrowDown != null && arrowDown.exists  && arrowDown.active) arrowDown.draw();
	}

	override function destroy()
	{
		_hitbox   = FlxDestroyUtil.destroy(_hitbox);
		arrowUp   = FlxDestroyUtil.destroy(arrowUp);
		arrowDown = FlxDestroyUtil.destroy(arrowDown);
		super.destroy();
	}

	public var curScroll(default, set):Int = 0;
	function set_curScroll(v:Int)
	{
		var lastScroll:Int = curScroll;
		if (maxItems > 0 && labels.length > maxItems)
		{
			curScroll = Std.int(FlxMath.bound(v, 0, labels.length - maxItems));
			if (arrowUp   != null && arrowUp.exists)   { arrowUp.visible   = arrowUp.active   = true; arrowUp.alpha   = (curScroll != 0)                        ? 1 : 0.4; }
			if (arrowDown != null && arrowDown.exists)  { arrowDown.visible = arrowDown.active = true; arrowDown.alpha = (curScroll != (labels.length - maxItems)) ? 1 : 0.4; }
		}
		else
		{
			curScroll = 0;
			if (arrowUp   != null && arrowUp.exists)   { arrowUp.visible   = arrowUp.active   = false; arrowUp.alpha   = 1; }
			if (arrowDown != null && arrowDown.exists)  { arrowDown.visible = arrowDown.active = false; arrowDown.alpha = 1; }
		}
		if (curScroll != lastScroll)
		{
			checked += (lastScroll - curScroll);
			updateRadioItems();
		}
		return curScroll;
	}

	function set_stackHorizontal(v:Bool)
	{
		stackHorizontal = v;
		updateRadioItems();
		return stackHorizontal;
	}

	function set_checked(v:Int)
	{
		checked = Std.int(FlxMath.bound(v, -1, Math.min(labels.length - 1, radios.length - 1)));
		@:bypassAccessor checkedRadio = null;
		for (num => radio in radios)
		{
			radio.checked = (num == checked);
			if (num == checked) @:bypassAccessor checkedRadio = radio;
		}
		return checked;
	}

	function set_labels(v:Array<String>)
	{
		labels = v;
		updateRadioItems();
		set_checked(checked);
		set_curScroll(curScroll);
		return labels;
	}

	function set_checkedRadio(v:PsychUIRadioItem)
	{
		checkedRadio = null;
		@:bypassAccessor checked = -1;
		for (num => radio in radios)
		{
			radio.checked = (v == radio);
			if (v == radio)
			{
				checkedRadio = radio;
				@:bypassAccessor checked = num;
			}
		}
		return checkedRadio;
	}

	function set_space(v:Float)
	{
		space = v;
		for (num => radio in radios)
		{
			if (!stackHorizontal) radio.y = y + num * space;
			else                  radio.x = x + num * (textWidth + space);
		}
		return space;
	}

	function set_textWidth(v:Int)
	{
		textWidth = v;
		for (num => radio in radios)
			radio.text.fieldWidth = textWidth;
		return textWidth;
	}

	function set_maxItems(v:Int)
	{
		maxItems = v;
		set_curScroll(curScroll);
		updateRadioItems();
		return maxItems;
	}

	public function updateRadioItems()
	{
		if (maxItems > 0)
		{
			for (radio in radios) radio.kill();
			radios = [];
			for (i in 0...maxItems)
			{
				var rad = _addNewRadio();
				if (i >= labels.length) rad.visible = rad.active = false;
			}
		}
		else
		{
			while (radios.length > labels.length) { radios[radios.length - 1].kill(); radios.pop(); }
			while (radios.length < labels.length) _addNewRadio();
		}

		for (num => radio in radios)
		{
			radio.visible = radio.active = (num < labels.length || labels.length > maxItems);
			radio.label   = labels[num + curScroll] != null ? labels[num + curScroll] : '';
			if (!stackHorizontal) { radio.x = x; radio.y = y + num * space; }
			else                  { radio.x = x + num * (textWidth + space); radio.y = y; }
		}
	}

	override function set_cameras(v:Array<FlxCamera>)
	{
		if (arrowUp   != null && arrowUp.exists)   arrowUp.cameras   = v;
		if (arrowDown != null && arrowDown.exists)  arrowDown.cameras = v;
		return super.set_cameras(v);
	}

	override function set_camera(v:FlxCamera)
	{
		if (arrowUp   != null && arrowUp.exists)   arrowUp.camera   = v;
		if (arrowDown != null && arrowDown.exists)  arrowDown.camera = v;
		return super.set_camera(v);
	}

	public var broadcastRadioGroupEvent:Bool = true;
	function _addNewRadio()
	{
		var radio:PsychUIRadioItem = cast recycle(PsychUIRadioItem);
		radio.onClick = function() {
			checkedRadio = radio;
			if (onClick != null) onClick();
			if (broadcastRadioGroupEvent) PsychUIEventHandler.event(CLICK_EVENT, this);
		};
		radio.visible = radio.active = true;
		radio.text.fieldWidth = textWidth;
		radios.push(radio);
		return insert(0, radio);
	}
}

class PsychUIRadioItem extends PsychUICheckBox
{
	public function new(x:Float, y:Float, label:String, textWid:Int = 100)
	{
		super(x, y, label, textWid);
		broadcastCheckBoxEvent = false;
	}

	override function boxGraphic()
	{
		box.loadGraphic(Paths.image('psych-ui/radio', 'embed'), true, 16, 16);
		box.animation.add('false', [0]);
		box.animation.add('true',  [1]);
		box.animation.play('false');
	}
}

// ─── PsychUIInputText ────────────────────────────────────────────────────────

enum abstract AccentCode(Int) from Int from UInt to Int to UInt
{
	var NONE       = -1;
	var GRAVE      = 0;
	var ACUTE      = 1;
	var CIRCUMFLEX = 2;
	var TILDE      = 3;
}

enum abstract FilterMode(Int) from Int from UInt to Int to UInt
{
	var NO_FILTER:Int         = 0;
	var ONLY_ALPHA:Int        = 1;
	var ONLY_NUMERIC:Int      = 2;
	var ONLY_ALPHANUMERIC:Int = 3;
	var ONLY_HEXADECIMAL:Int  = 4;
	var CUSTOM_FILTER:Int     = 5;
}

enum abstract CaseMode(Int) from Int from UInt to Int to UInt
{
	var ALL_CASES:Int  = 0;
	var UPPER_CASE:Int = 1;
	var LOWER_CASE:Int = 2;
}

class PsychUIInputText extends FlxSpriteGroup
{
	public static final CHANGE_EVENT = "inputtext_change";

	static final KEY_TILDE = 126;
	static final KEY_ACUTE = 180;

	public static var focusOn(default, set):PsychUIInputText = null;

	public var name:String;
	public var bg:FlxSprite;
	public var behindText:FlxSprite;
	public var selection:FlxSprite;
	public var textObj:FlxText;
	public var caret:FlxSprite;
	public var onChange:String->String->Void;

	public var fieldWidth(default, set):Int            = 0;
	public var maxLength(default, set):Int             = 0;
	public var passwordMask(default, set):Bool         = false;
	public var text(default, set):String               = null;

	public var forceCase(default, set):CaseMode        = ALL_CASES;
	public var filterMode(default, set):FilterMode     = NO_FILTER;
	public var customFilterPattern(default, set):EReg;

	public var selectedFormat:FlxTextFormat = new FlxTextFormat(FlxColor.WHITE);

	public function new(x:Float = 0, y:Float = 0, wid:Int = 100, ?text:String = '', size:Int = 8)
	{
		super(x, y);
		this.bg         = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		this.behindText = new FlxSprite(1, 1).makeGraphic(1, 1, FlxColor.WHITE);
		this.selection  = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		this.textObj    = new FlxText(1, 1, Math.max(1, wid - 2), '', size);
		this.caret      = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		add(this.bg);
		add(this.behindText);
		add(this.selection);
		add(this.textObj);
		add(this.caret);

		this.textObj.color = FlxColor.BLACK;
		this.textObj.textField.selectable = false;
		this.textObj.textField.wordWrap   = false;
		this.textObj.textField.multiline  = false;
		this.selection.color = FlxColor.BLUE;

		@:bypassAccessor fieldWidth = wid;
		setGraphicSize(wid + 2, this.textObj.height + 2);
		updateHitbox();
		this.text = text;

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	public var selectIndex:Int             = -1;
	public var caretIndex(default, set):Int = -1;
	var _caretTime:Float = 0;

	var _nextAccent:AccentCode = NONE;
	public var inInsertMode:Bool = false;
	function onKeyDown(e:KeyboardEvent)
	{
		if (focusOn != this) return;

		var keyCode:Int  = e.keyCode;
		var charCode:Int = e.charCode;
		var flxKey:FlxKey = cast keyCode;

		switch (keyCode)
		{
			case 231: charCode = e.shiftKey ? 0xC7 : 0xE7;
		}

		if (e.controlKey)
		{
			switch (flxKey)
			{
				case A:
					selectIndex = Std.int(Math.min(0, text.length - 1));
					caretIndex  = text.length;

				case X, C:
					if (caretIndex >= 0 && selectIndex != 0 && caretIndex != selectIndex)
					{
						Clipboard.text = text.substring(caretIndex, selectIndex);
						if (flxKey == X) deleteSelection();
					}

				case V:
					if (Clipboard.text == null) return;
					if (selectIndex > -1 && selectIndex != caretIndex) deleteSelection();
					var lastText = text;
					text = text.substring(0, caretIndex) + Clipboard.text + text.substring(caretIndex);
					caretIndex += Clipboard.text.length;
					if (onChange != null) onChange(lastText, text);
					if (broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);

				case BACKSPACE:
					if (selectIndex < 0 || selectIndex == caretIndex)
					{
						var lastText   = text;
						var deletedText:String = text.substr(0, Std.int(Math.max(0, caretIndex - 1)));
						var space:Int  = deletedText.lastIndexOf(' ');
						if (space > -1 && space != caretIndex - 1)
						{
							var start:String = deletedText.substring(0, space + 1);
							var end:String   = text.substring(caretIndex);
							caretIndex -= Std.int(Math.max(0, text.length - (start.length + end.length)));
							text = start + end;
						}
						else
						{
							text       = text.substring(caretIndex);
							caretIndex = 0;
						}
						selectIndex = -1;
						if (onChange != null) onChange(lastText, text);
						if (broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
					}
					else deleteSelection();

				case DELETE:
					if (selectIndex < 0 || selectIndex == caretIndex)
					{
						var deletedText:String = text.substring(caretIndex);
						var spc:Int  = 0;
						var space:Int = deletedText.indexOf(' ');
						while (deletedText.substr(spc, 1) == ' ') { spc++; space = deletedText.substr(spc).indexOf(' '); }
						var lastText = text;
						if (space > -1) text = text.substr(0, caretIndex) + text.substring(caretIndex + space + spc);
						else            text = text.substr(0, caretIndex);
						if (onChange != null) onChange(lastText, text);
						if (broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
					}
					else deleteSelection();

				case LEFT:
					if (caretIndex > 0)
					{
						do
						{
							caretIndex--;
							var a:String = text.substr(caretIndex - 1, 1);
							var b:String = text.substr(caretIndex, 1);
							if (a == ' ' && b != ' ') break;
						}
						while (caretIndex > 0);
					}

				case RIGHT:
					if (caretIndex < text.length)
					{
						do
						{
							caretIndex++;
							var a:String = text.substr(caretIndex - 1, 1);
							var b:String = text.substr(caretIndex, 1);
							if (a != ' ' && b == ' ') break;
						}
						while (caretIndex < text.length);
					}

				default:
			}
			updateCaret();
			return;
		}

		static final ignored:Array<FlxKey> = [SHIFT, CONTROL, ESCAPE];
		if (ignored.contains(flxKey)) return;

		var lastAccent = _nextAccent;
		switch (keyCode)
		{
			case KEY_TILDE: _nextAccent = !e.shiftKey ? TILDE : CIRCUMFLEX; if (lastAccent == NONE) return;
			case KEY_ACUTE: _nextAccent = !e.shiftKey ? ACUTE : GRAVE;      if (lastAccent == NONE) return;
			default:        lastAccent  = NONE;
		}

		switch (flxKey)
		{
			case LEFT:
				if (!FlxG.keys.pressed.SHIFT) selectIndex = -1;
				else if (selectIndex == -1)   selectIndex = caretIndex;
				caretIndex = Std.int(Math.max(0, caretIndex - 1));

			case RIGHT:
				if (!FlxG.keys.pressed.SHIFT) selectIndex = -1;
				else if (selectIndex == -1)   selectIndex = caretIndex;
				caretIndex = Std.int(Math.min(text.length, caretIndex + 1));

			case HOME:
				if (!FlxG.keys.pressed.SHIFT) selectIndex = -1;
				else if (selectIndex == -1)   selectIndex = caretIndex;
				caretIndex = 0;

			case END:
				if (!FlxG.keys.pressed.SHIFT) selectIndex = -1;
				else if (selectIndex == -1)   selectIndex = caretIndex;
				caretIndex = text.length;

			case INSERT:
				inInsertMode = !inInsertMode;

			case BACKSPACE:
				if (caretIndex <= 0) return;
				if (selectIndex > -1 && selectIndex != caretIndex)
					deleteSelection();
				else
				{
					var lastText = text;
					text = text.substring(0, caretIndex - 1) + text.substring(caretIndex);
					caretIndex--;
					if (onChange != null) onChange(lastText, text);
					if (broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
				}
				_nextAccent = NONE;

			case DELETE:
				if (selectIndex > -1 && selectIndex != caretIndex) { deleteSelection(); updateCaret(); return; }
				if (caretIndex >= text.length) return;
				var lastText = text;
				if (caretIndex < 1) text = text.substr(1);
				else                text = text.substring(0, caretIndex) + text.substring(caretIndex + 1);
				if (caretIndex >= text.length) caretIndex = text.length;
				if (onChange != null) onChange(lastText, text);
				if (broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);

			case SPACE:
				if (_nextAccent != NONE) _typeLetter(getAccentCharCode(_nextAccent));
				else _typeLetter(charCode);
				_nextAccent = NONE;

			case A, O:
				var grave:Int = 0x0; var capital:Int = 0x0;
				switch (flxKey) { case A: grave = 0xC0; capital = 0x41; case O: grave = 0xD2; capital = 0x4f; default: }
				if (_nextAccent != NONE) charCode += grave - capital + _nextAccent;
				_typeLetter(charCode);
				_nextAccent = NONE;

			case E, I, U:
				var grave:Int = 0x0; var capital:Int = 0x0;
				switch (flxKey) { case E: grave = 0xC8; capital = 0x45; case I: grave = 0xCC; capital = 0x49; case U: grave = 0xD9; capital = 0x55; default: }
				if (_nextAccent == GRAVE || _nextAccent == ACUTE || _nextAccent == CIRCUMFLEX) charCode += grave - capital + _nextAccent;
				else if (_nextAccent == TILDE) _typeLetter(getAccentCharCode(_nextAccent));
				_typeLetter(charCode);
				_nextAccent = NONE;

			case N:
				if (_nextAccent == TILDE) charCode += 0xD1 - 0x4E;
				else _typeLetter(getAccentCharCode(_nextAccent));
				_typeLetter(charCode);
				_nextAccent = NONE;

			case ESCAPE:
				focusOn = null;

			case ENTER:
				onPressEnter(e);

			default:
				if (charCode < 1)
					if ((charCode = getAccentCharCode(_nextAccent)) < 1)
						return;
				if (lastAccent != NONE)      _typeLetter(getAccentCharCode(lastAccent));
				else if (_nextAccent != NONE) _typeLetter(getAccentCharCode(_nextAccent));
				_typeLetter(charCode);
				_nextAccent = NONE;
		}
		updateCaret();
	}

	public dynamic function onPressEnter(e:KeyboardEvent)
		focusOn = null;

	public var unfocus:Void->Void;
	public static function set_focusOn(v:PsychUIInputText)
	{
		if (focusOn != null && focusOn != v && focusOn.exists)
		{
			if (focusOn.unfocus != null) focusOn.unfocus();
			focusOn.resetCaret();
		}
		return (focusOn = v);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(behindText, camera))
			{
				if (!FlxG.keys.pressed.SHIFT) selectIndex = -1;
				else if (selectIndex == -1)   selectIndex = caretIndex;
				focusOn    = this;
				caretIndex = 0;
				var lastBound:Float  = 0;
				var textObjX:Float   = textObj.getScreenPosition(camera).x;
				var mousePosX:Float  = FlxG.mouse.getScreenPosition(camera).x;
				var txtX:Float       = textObjX - textObj.textField.scrollH;

				for (i => bound in _boundaries)
				{
					if (mousePosX >= txtX + (bound - lastBound) / 2)
					{
						caretIndex = i + 1;
						txtX      += bound - lastBound;
						lastBound  = bound;
					}
					else break;
				}
				updateCaret();
			}
			else if (focusOn == this)
				focusOn = null;
		}

		if (focusOn == this)
		{
			_caretTime = (_caretTime + elapsed) % 1;
			if (textObj != null && textObj.exists)
			{
				var drewSelection:Bool = false;
				if (selection != null && selection.exists)
				{
					if (selectIndex != -1 && selectIndex != caretIndex)
					{
						selection.visible = true;
						drewSelection     = true;
					}
					else selection.visible = false;
				}

				if (caret != null && caret.exists)
				{
					if (!drewSelection && _caretTime < 0.5 && caret.x >= textObj.x)
					{
						caret.visible = true;
						caret.color   = textObj.color;
					}
					else caret.visible = false;
				}
			}
		}
		else
		{
			_caretTime   = 0;
			inInsertMode = false;
			if (selection != null && selection.exists) selection.visible = false;
			if (caret     != null && caret.exists)     caret.visible     = false;
		}
	}

	public function resetCaret()
	{
		selectIndex = -1;
		caretIndex  = 0;
		updateCaret();
	}

	public function updateCaret()
	{
		if (textObj == null || !textObj.exists) return;

		var textField = textObj.textField;
		textField.setSelection(caretIndex, caretIndex);
		_caretTime = 0;
		if (caret != null && caret.exists)
		{
			caret.y = textObj.y + 2;
			caret.x = textObj.x + 1 - textObj.textField.scrollH;
			if (caretIndex > 0)
				caret.x += _boundaries[Std.int(Math.max(0, Math.min(_boundaries.length - 1, caretIndex - 1)))];
		}

		if (selection != null && selection.exists)
		{
			selection.y = textObj.y + 2;
			selection.x = textObj.x + 1 - textObj.textField.scrollH;
			if (selectIndex > 0)
				selection.x += _boundaries[Std.int(Math.max(0, Math.min(_boundaries.length - 1, selectIndex - 1)))];

			selection.scale.y = textField.textHeight;
			selection.scale.x = caret.x - selection.x;
			if (selection.scale.x < 0)
			{
				selection.scale.x = Math.abs(selection.scale.x);
				selection.x      -= selection.scale.x;
			}

			if (selection.x < textObj.x)
			{
				var diff:Float = textObj.x - selection.x;
				selection.x      += diff;
				selection.scale.x -= diff;
			}
			if (selection.x + selection.scale.x > textObj.x + textObj.width)
				selection.scale.x += (textObj.x + textObj.width - selection.x - selection.scale.x);

			selection.updateHitbox();

			if (text.length > 0)
			{
				textObj.removeFormat(selectedFormat);
				if (selectIndex != -1 && selectIndex != caretIndex)
				{
					textObj.addFormat(selectedFormat,
						caretIndex < selectIndex ? caretIndex : selectIndex,
						caretIndex < selectIndex ? selectIndex : caretIndex);
				}
			}
		}
		else if (text.length > 0) textObj.removeFormat(selectedFormat);
	}

	function deleteSelection()
	{
		var lastText:String = text;
		if (selectIndex > caretIndex)
			text = text.substring(0, caretIndex) + text.substring(selectIndex);
		else
		{
			text       = text.substring(0, selectIndex) + text.substring(caretIndex);
			caretIndex = selectIndex;
		}
		selectIndex = -1;
		if (onChange != null) onChange(lastText, text);
		if (broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
	}

	override public function destroy()
	{
		_boundaries = null;
		if (focusOn == this) focusOn = null;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		super.destroy();
	}

	function set_caretIndex(v:Int)
	{
		caretIndex = v;
		updateCaret();
		return v;
	}

	override public function setGraphicSize(width:Float = 0, height:Float = 0)
	{
		super.setGraphicSize(width, height);
		bg.setGraphicSize(width, height);
		behindText.setGraphicSize(width - 2, height - 2);
		if (textObj != null && textObj.exists)
		{
			textObj.scale.x = 1;
			textObj.scale.y = 1;
			if (caret != null && caret.exists) caret.setGraphicSize(1, textObj.height - 4);
		}
	}

	override public function updateHitbox()
	{
		super.updateHitbox();
		bg.updateHitbox();
		behindText.updateHitbox();
		if (textObj != null && textObj.exists)
		{
			textObj.updateHitbox();
			if (caret != null && caret.exists) caret.updateHitbox();
		}
	}

	function set_fieldWidth(v:Int)
	{
		textObj.fieldWidth               = Math.max(1, v - 2);
		textObj.textField.selectable     = false;
		textObj.textField.wordWrap       = false;
		textObj.textField.multiline      = false;
		return (fieldWidth = v);
	}

	function set_maxLength(v:Int)
	{
		var lastText = text;
		v = Std.int(Math.max(0, v));
		if (v > 0 && text.length > v) text = text.substr(0, v);
		if (onChange != null) onChange(lastText, text);
		if (broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
		return (maxLength = v);
	}

	function set_passwordMask(v:Bool)
	{
		passwordMask = v;
		text = text;
		return passwordMask;
	}

	var _boundaries:Array<Float> = [];
	function set_text(v:String)
	{
		for (i in 0..._boundaries.length) _boundaries.pop();
		v = filter(v);

		textObj.text = '';
		if (v != null && v.length > 0)
		{
			if (v.length > 1)
			{
				for (i in 0...v.length)
				{
					var toPrint:String = v.substr(i, 1);
					if (toPrint == '\n') toPrint = ' ';
					textObj.textField.appendText(!passwordMask ? toPrint : '*');
					_boundaries.push(textObj.textField.textWidth);
				}
			}
			else
			{
				textObj.text = !passwordMask ? v : '*';
				_boundaries.push(textObj.textField.textWidth);
			}
		}
		text = v;
		updateCaret();
		return v;
	}

	public static function getAccentCharCode(accent:AccentCode)
	{
		switch (accent)
		{
			case TILDE:      return 0x7E;
			case CIRCUMFLEX: return 0x5E;
			case ACUTE:      return 0xB4;
			case GRAVE:      return 0x60;
			default:         return 0x0;
		}
	}

	public var broadcastInputTextEvent:Bool = true;
	function _typeLetter(charCode:Int)
	{
		if (charCode < 1) return;

		if (selectIndex > -1 && selectIndex != caretIndex) deleteSelection();

		var letter:String = String.fromCharCode(charCode);
		letter = filter(letter);
		if (letter.length > 0 && (maxLength == 0 || (text.length + letter.length) <= maxLength))
		{
			var lastText = text;
			if (!inInsertMode) text = text.substring(0, caretIndex) + letter + text.substring(caretIndex);
			else               text = text.substring(0, caretIndex) + letter + text.substring(caretIndex + 1);
			caretIndex += letter.length;
			if (onChange != null) onChange(lastText, text);
			if (broadcastInputTextEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
		}
		_caretTime = 0;
	}

	function set_forceCase(v:CaseMode)
	{
		forceCase = v;
		text      = filter(text);
		return forceCase;
	}

	function set_filterMode(v:FilterMode)
	{
		filterMode = v;
		text       = filter(text);
		return filterMode;
	}

	function set_customFilterPattern(cfp:EReg)
	{
		customFilterPattern = cfp;
		filterMode          = CUSTOM_FILTER;
		return customFilterPattern;
	}

	private function filter(text:String):String
	{
		switch (forceCase)
		{
			case UPPER_CASE: text = text.toUpperCase();
			case LOWER_CASE: text = text.toLowerCase();
			default:
		}

		if (filterMode != NO_FILTER)
		{
			var pattern:EReg;
			switch (filterMode)
			{
				case ONLY_ALPHA:        pattern = ~/[^a-zA-Z]*/g;
				case ONLY_NUMERIC:      pattern = ~/[^0-9]*/g;
				case ONLY_ALPHANUMERIC: pattern = ~/[^a-zA-Z0-9]*/g;
				case ONLY_HEXADECIMAL:  pattern = ~/[^a-fA-F0-9]*/g;
				case CUSTOM_FILTER:     pattern = customFilterPattern;
				default: throw new flash.errors.Error("FlxInputText: Unknown filterMode (" + filterMode + ")");
			}
			text = pattern.replace(text, "");
		}
		return text;
	}
}

// ─── PsychUIDropDownMenu / PsychUIDropDownItem ────────────────────────────────

class PsychUIDropDownMenu extends PsychUIInputText
{
	public static final CLICK_EVENT = "dropdown_click";

	public var list(default, set):Array<String> = [];
	public var button:FlxSprite;
	public var onSelect:Int->String->Void;

	public var selectedIndex(default, set):Int    = -1;
	public var selectedLabel(default, set):String = null;

	var _curFilter:Array<String>;
	var _itemWidth:Float = 0;
	public function new(x:Float, y:Float, list:Array<String>, callback:Int->String->Void, ?width:Float = 100)
	{
		super(x, y);
		if (list == null) list = [];

		_itemWidth = width - 2;
		setGraphicSize(width, 20);
		updateHitbox();
		textObj.y += 2;

		button = new FlxSprite(behindText.width + 1, 0).loadGraphic(Paths.image('psych-ui/dropdown_button', 'embed'), true, 20, 20);
		button.animation.add('normal',  [0], false);
		button.animation.add('pressed', [1], false);
		button.animation.play('normal', true);
		add(button);

		onSelect = callback;

		onChange = function(old:String, cur:String)
		{
			if (old != cur)
			{
				_curFilter = this.list.filter(function(str:String) return str.startsWith(cur));
				showDropDown(true, 0, _curFilter);
			}
		}
		unfocus = function()
		{
			showDropDownClickFix();
			showDropDown(false);
		}

		for (option in list) addOption(option);

		selectedIndex = 0;
		showDropDown(false);
	}

	function set_selectedIndex(v:Int)
	{
		selectedIndex = v;
		if (selectedIndex < 0 || selectedIndex >= list.length) selectedIndex = -1;
		@:bypassAccessor selectedLabel = list[selectedIndex];
		text = (selectedLabel != null) ? selectedLabel : '';
		return selectedIndex;
	}

	function set_selectedLabel(v:String)
	{
		var id:Int = list.indexOf(v);
		if (id >= 0)
		{
			@:bypassAccessor selectedIndex = id;
			selectedLabel = v;
			text          = selectedLabel;
		}
		else
		{
			@:bypassAccessor selectedIndex = -1;
			selectedLabel = null;
			text          = '';
		}
		return selectedLabel;
	}

	var _items:Array<PsychUIDropDownItem> = [];
	public var curScroll:Int = 0;
	override function update(elapsed:Float)
	{
		var lastFocus = PsychUIInputText.focusOn;
		super.update(elapsed);
		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(button, camera))
			{
				button.animation.play('pressed', true);
				if (lastFocus != this)
					PsychUIInputText.focusOn = this;
				else if (PsychUIInputText.focusOn == this)
					PsychUIInputText.focusOn = null;
			}
		}
		else if (FlxG.mouse.released && button.animation.curAnim != null && button.animation.curAnim.name != 'normal')
			button.animation.play('normal', true);

		if (lastFocus != PsychUIInputText.focusOn)
			showDropDown(PsychUIInputText.focusOn == this);
		else if (PsychUIInputText.focusOn == this)
		{
			var wheel:Int = FlxG.mouse.wheel;
			if (FlxG.keys.justPressed.UP)   wheel++;
			if (FlxG.keys.justPressed.DOWN)  wheel--;
			if (wheel != 0) showDropDown(true, curScroll - wheel, _curFilter);
		}
	}

	private function showDropDownClickFix()
	{
		if (FlxG.mouse.justPressed)
		{
			for (item in _items)
				if (item != null && item.active && item.visible)
					item.update(0);
		}
	}

	public function showDropDown(vis:Bool = true, scroll:Int = 0, onlyAllowed:Array<String> = null)
	{
		if (!vis)
		{
			text       = selectedLabel;
			_curFilter = null;
		}

		curScroll = Std.int(Math.max(0, Math.min(onlyAllowed != null ? (onlyAllowed.length - 1) : (list.length - 1), scroll)));
		if (vis)
		{
			var n:Int = 0;
			for (item in _items)
			{
				if (onlyAllowed != null)
				{
					if (onlyAllowed.contains(item.label)) { item.active = item.visible = (n >= curScroll); n++; }
					else                                   item.active = item.visible = false;
				}
				else
				{
					item.active = item.visible = (n >= curScroll);
					n++;
				}
			}

			var txtY:Float = behindText.y + behindText.height + 1;
			for (num => item in _items)
			{
				if (!item.visible) continue;
				item.x = behindText.x;
				item.y = txtY;
				txtY  += item.height;
				item.forceNextUpdate = true;
			}
			bg.scale.y = txtY - behindText.y + 2;
			bg.updateHitbox();
		}
		else
		{
			for (item in _items) item.active = item.visible = false;
			bg.scale.y = 20;
			bg.updateHitbox();
		}
	}

	public var broadcastDropDownEvent:Bool = true;
	function clickedOn(num:Int, label:String)
	{
		selectedIndex = num;
		showDropDown(false);
		if (onSelect != null) onSelect(num, label);
		if (broadcastDropDownEvent) PsychUIEventHandler.event(CLICK_EVENT, this);
	}

	function addOption(option:String)
	{
		@:bypassAccessor list.push(option);
		var curID:Int = list.length - 1;
		var item:PsychUIDropDownItem = cast recycle(PsychUIDropDownItem, () -> new PsychUIDropDownItem(1, 1, this._itemWidth), true);
		item.cameras = cameras;
		item.label   = option;
		item.visible = item.active = false;
		item.onClick = function() clickedOn(curID, option);
		item.forceNextUpdate = true;
		_items.push(item);
		insert(1, item);
	}

	function set_list(v:Array<String>)
	{
		var selected:String = selectedLabel;
		showDropDown(false);

		for (item in _items) item.kill();

		_items = [];
		list   = [];
		for (option in v) addOption(option);

		if (selectedLabel != null) selectedLabel = selected;
		return v;
	}
}

class PsychUIDropDownItem extends FlxSpriteGroup
{
	public var hoverStyle:UIStyleData  = { bgColor: 0xFF0066FF,    textColor: FlxColor.WHITE, bgAlpha: 1 };
	public var normalStyle:UIStyleData = { bgColor: FlxColor.WHITE, textColor: FlxColor.BLACK, bgAlpha: 1 };

	public var bg:FlxSprite;
	public var text:FlxText;
	public function new(x:Float = 0, y:Float = 0, width:Float = 100)
	{
		super(x, y);

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
		bg.setGraphicSize(width, 20);
		bg.updateHitbox();
		add(bg);

		text = new FlxText(0, 0, width, 8);
		text.color = FlxColor.BLACK;
		add(text);
	}

	public var onClick:Void->Void;
	public var forceNextUpdate:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.mouse.justMoved || FlxG.mouse.justPressed || forceNextUpdate)
		{
			var overlapped:Bool = (FlxG.mouse.overlaps(bg, camera));
			var style = overlapped ? hoverStyle : normalStyle;
			bg.color   = style.bgColor;
			text.color = style.textColor;
			bg.alpha   = style.bgAlpha;
			forceNextUpdate = false;

			if (overlapped && FlxG.mouse.justPressed) onClick();
		}

		text.x = bg.x;
		text.y = bg.y + bg.height / 2 - text.height / 2;
	}

	public var label(default, set):String;
	function set_label(v:String)
	{
		label      = v;
		text.text  = v;
		bg.scale.y = text.height + 6;
		bg.updateHitbox();
		return v;
	}
}

// ─── PsychUINumericStepper ───────────────────────────────────────────────────

class PsychUINumericStepper extends PsychUIInputText
{
	public static final CHANGE_EVENT = "numericstepper_change";

	public var step:Float = 0;
	public var min(default, set):Float          = 0;
	public var max(default, set):Float          = 0;
	public var decimals(default, set):Int       = 0;
	public var isPercent(default, set):Bool     = false;
	public var buttonPlus:FlxSprite;
	public var buttonMinus:FlxSprite;

	public var onValueChange:Void->Void;
	public var value(default, set):Float;
	public function new(x:Float = 0, y:Float = 0, step:Float = 1, defValue:Float = 0, min:Float = -999, max:Float = 999,
		decimals:Int = 0, ?wid:Int = 60, ?isPercent:Bool = false)
	{
		super(x, y, wid, '');
		fieldWidth = Std.int(behindText.width + 2);
		@:bypassAccessor this.decimals  = decimals;
		@:bypassAccessor this.isPercent = isPercent;
		@:bypassAccessor this.min       = min;
		@:bypassAccessor this.max       = max;
		this.step = step;
		_updateFilter();

		buttonPlus = new FlxSprite(fieldWidth).loadGraphic(Paths.image('psych-ui/stepper_plus', 'embed'), true, 16, 16);
		buttonPlus.animation.add('normal',  [0], false);
		buttonPlus.animation.add('pressed', [1], false);
		buttonPlus.animation.play('normal');
		add(buttonPlus);

		buttonMinus = new FlxSprite(fieldWidth + buttonPlus.width).loadGraphic(Paths.image('psych-ui/stepper_minus', 'embed'), true, 16, 16);
		buttonMinus.animation.add('normal',  [0], false);
		buttonMinus.animation.add('pressed', [1], false);
		buttonMinus.animation.play('normal');
		add(buttonMinus);

		unfocus = function()
		{
			_updateValue();
			_internalOnChange();
		}
		value = defValue;
	}

	var _holdTimer:Float  = 0;
	var _holdRepeat:Float = 0;
	var _holdDir:Int      = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed)
		{
			if (buttonPlus != null && buttonPlus.exists && FlxG.mouse.overlaps(buttonPlus, camera))
			{
				buttonPlus.animation.play('pressed');
				value     += step;
				_internalOnChange();
				_holdDir    = 1;
				_holdTimer  = 0;
				_holdRepeat = 0;
			}
			else if (buttonMinus != null && buttonMinus.exists && FlxG.mouse.overlaps(buttonMinus, camera))
			{
				buttonMinus.animation.play('pressed');
				value     -= step;
				_internalOnChange();
				_holdDir    = -1;
				_holdTimer  = 0;
				_holdRepeat = 0;
			}
		}
		else if (FlxG.mouse.pressed && _holdDir != 0)
		{
			var btn = (_holdDir > 0) ? buttonPlus : buttonMinus;
			if (btn != null && btn.exists && FlxG.mouse.overlaps(btn, camera))
			{
				_holdTimer  += elapsed;
				var interval:Float = if (_holdTimer < 1.0) 0.15 else if (_holdTimer < 2.0) 0.08 else 0.04;
				_holdRepeat += elapsed;
				if (_holdRepeat >= interval && _holdTimer >= 0.5)
				{
					_holdRepeat -= interval;
					value       += step * _holdDir;
					_internalOnChange();
				}
			}
			else _holdDir = 0;
		}
		else if (FlxG.mouse.released)
		{
			_holdDir = 0;
			if (buttonPlus  != null && buttonPlus.exists  && buttonPlus.animation.curAnim  != null && buttonPlus.animation.curAnim.name  != 'normal') buttonPlus.animation.play('normal');
			if (buttonMinus != null && buttonMinus.exists && buttonMinus.animation.curAnim != null && buttonMinus.animation.curAnim.name != 'normal') buttonMinus.animation.play('normal');
		}
	}

	function set_value(v:Float)
	{
		value = Math.max(min, Math.min(max, v));
		text  = Std.string(isPercent ? (value * 100) : value);
		_updateValue();
		return value;
	}

	function set_min(v:Float)
	{
		min = v;
		@:bypassAccessor if (min > max) max = min;
		_updateFilter();
		_updateValue();
		return min;
	}

	function set_max(v:Float)
	{
		max = v;
		@:bypassAccessor if (max < min) min = max;
		_updateFilter();
		_updateValue();
		return max;
	}

	function set_decimals(v:Int)
	{
		decimals = v;
		_updateFilter();
		return decimals;
	}

	function set_isPercent(v:Bool)
	{
		var changed:Bool = (isPercent != v);
		isPercent = v;
		_updateFilter();
		if (changed) { text = Std.string(value * 100); _updateValue(); }
		return isPercent;
	}

	function _updateValue()
	{
		var txt:String = text.replace('%', '');
		if (txt.indexOf('-') > 0) txt.replace('-', '');

		while (txt.indexOf('.') > -1 && txt.indexOf('.') != txt.lastIndexOf('.'))
		{
			var lastId = txt.lastIndexOf('.');
			txt = txt.substr(0, lastId) + txt.substring(lastId + 1);
		}

		var val:Float = Std.parseFloat(txt);
		if (Math.isNaN(val)) val = 0;

		if (isPercent) val /= 100;
		if (val < min) val = min;
		else if (val > max) val = max;
		val = FlxMath.roundDecimal(val, decimals);
		@:bypassAccessor value = val;

		if (isPercent) { text = Std.string(val * 100); text += '%'; }
		else             text = Std.string(val);

		if (caretIndex > text.length)  caretIndex  = text.length;
		if (selectIndex > text.length) selectIndex = text.length;
	}

	function _updateFilter()
	{
		if (min < 0)
		{
			if (decimals > 0) customFilterPattern = isPercent ? ~/[^0-9.%\-]*/g : ~/[^0-9.\-]*/g;
			else              customFilterPattern = isPercent ? ~/[^0-9%\-]*/g  : ~/[^0-9\-]*/g;
		}
		else
		{
			if (decimals > 0) customFilterPattern = isPercent ? ~/[^0-9.%]*/g : ~/[^0-9.]*/g;
			else              customFilterPattern = isPercent ? ~/[^0-9%]*/g  : ~/[^0-9]*/g;
		}
	}

	public var broadcastStepperEvent:Bool = true;
	function _internalOnChange()
	{
		if (onValueChange != null) onValueChange();
		if (broadcastStepperEvent) PsychUIEventHandler.event(CHANGE_EVENT, this);
	}

	override function setGraphicSize(width:Float = 0, height:Float = 0)
	{
		super.setGraphicSize(width, height);
		behindText.setGraphicSize(width - 32, height - 2);
	}
}
