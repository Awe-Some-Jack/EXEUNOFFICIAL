package states.extras.credits;

import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxGradient;
import flixel.FlxCamera;
import flixel.math.FlxMath;

import openfl.Assets;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;

import haxe.Json;

import states.extras.credits.CreditPopup;

typedef Credit = {
    var name:String;
    var icon:String;
    var description:String;
    @:optional var quote:String;
    @:optional var colors:Array<Array<Int>>;
    @:optional var nation:String;
    @:optional var youtube:String;
    @:optional var twitter:String;
    @:optional var extra:Array<Dynamic>;
}

private typedef Column = {
    var key:String;
    var label:String;
    var cam:FlxCamera;
    var list:FlxTypedGroup<FlxSprite>;
    var nameTexts:Array<FlxText>;
    var cardBgs:Array<FlxSprite>;
}

class CreditsState extends MusicBeatSubstate {
    public static var credits:Map<String, Array<Credit>> = [];
    public static var userSelected:Array<Dynamic> = ['unofficial', 0];

    static inline final SPACING:Int     = 10;
    static inline final ROW_H:Int       = 44;
    static inline final FONT_SIZE:Int   = 20;
    static inline final TITLE_SIZE:Int  = 28;
    static inline final CARD_PAD:Int    = 8;
    static inline final CARD_RADIUS:Float = 10.0;
    static inline final ICON_SIZE:Int   = 30;

    var columns:Array<Column> = [];
    var curColumn:Int = 0;
    var canSelect:Bool = false;

    var _hoveredCol:Int  = -1;
    var _hoveredRow:Int  = -1;

    override function create() {
        super.create();

        final extrasMenu = Std.downcast(FlxG.state, states.extras.ExtrasMenu);
        extrasMenu?._orphanPlayer?.pause();
        FlxG.sound.music?.pause();
        FlxG.sound.playMusic(Assets.getSound('assets/exe/music/credits.ogg'));

        final json:Dynamic = Json.parse(Assets.getText("assets/exe/extras/credits/credits.json"));
        for (cat in Reflect.fields(json)) {
            credits.set(cat, cast Reflect.field(json, cat));
        }

        add(FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [0xFF1a0a2e, 0xFF3d0d1f], 1, 90));
        add(_makeCheckers());

        final titleBg = new FlxSprite(0, 0).makeGraphic(FlxG.width, SPACING * 6, 0x44000000);
        add(titleBg);

        final title = new FlxText(0, 0, FlxG.width, "CREDITS")
            .setFormat(Paths.font("vcr.ttf"), TITLE_SIZE + 8, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
        title.borderSize = 3;
        title.y = (SPACING * 6 - title.height) * 0.5;
        add(title);

        final defs = [
            {key: 'unofficial', label: 'Unofficial Dev Team'},
            {key: 'original',   label: 'Original Team'},
            {key: 'external',   label: 'External Credits'},
        ];

        final colCount  = defs.length;
        final colW      = Std.int((FlxG.width - SPACING * (colCount + 1)) / colCount);
        final titleBarH = SPACING * 6;
        final topGap    = titleBarH + SPACING * 5;
        final botGap    = SPACING * 3;
        final colH      = FlxG.height - topGap - botGap;
        final camY      = topGap;
        final camPad    = 6;

        for (i in 0...colCount) {
            final def = defs[i];
            final camX = SPACING + i * (colW + SPACING);

            final colBg = new FlxSprite(camX, camY);
            colBg.makeGraphic(colW, colH, 0x00000000, true);
            colBg.pixels.fillRect(colBg.pixels.rect, 0x33000000);
            
            final bgShader = new shaders.RoundedBorderShader(16.0, 0.0, 0xFF000000);
            bgShader.setSize(colW, colH);
            colBg.shader = bgShader;
            colBg.alpha  = 0;
            add(colBg);

            final titleY = camY - SPACING * 3 - 4;
            final colTitle = new FlxText(camX, titleY, colW, def.label)
                .setFormat(Paths.font("vcr.ttf"), TITLE_SIZE, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
            colTitle.borderSize = 2;
            colTitle.alpha = 0;
            colTitle.y = titleY - colTitle.height * 0.5;
            add(colTitle);

            final cam = new FlxCamera();
            cam.bgColor = 0x00000000;
            FlxG.cameras.add(cam, false);
            cam.setSize(colW - camPad * 2, colH - camPad * 2);
            cam.setPosition(camX + camPad, camY + camPad);

            final list = new FlxTypedGroup<FlxSprite>();
            final nameTexts:Array<FlxText> = [];
            final cardBgs:Array<FlxSprite> = [];
            add(list);

            final entries = credits.get(def.key);
            if (entries != null) {
                for (j in 0...entries.length) {
                    final entry = entries[j];
                    final cardY = CARD_PAD + j * ROW_H;

                    final camInnerW = colW - camPad * 2;
                    final cardW     = camInnerW - CARD_PAD * 2;
                    
                    final card = new FlxSprite(CARD_PAD, cardY);
                    card.makeGraphic(cardW, ROW_H - 4, 0x00000000, true);
                    card.pixels.fillRect(card.pixels.rect, 0x22FFFFFF);
                    
                    final cardShader = new shaders.RoundedBorderShader(CARD_RADIUS, 0.0, 0xFF000000);
                    cardShader.setSize(cardW, ROW_H - 4);
                    card.shader = cardShader;
                    card.camera = cam;
                    list.add(card);
                    cardBgs.push(card);

                    final iconPath = 'assets/exe/extras/credits/${def.key}/icons/${entry.icon}.png';
                    final hasIcon  = entry.icon != null && sys.FileSystem.exists(iconPath);
                    var textOffX   = CARD_PAD * 2;

                    if (hasIcon) {
                        final icon = new FlxSprite(CARD_PAD * 2, cardY + (ROW_H - 4 - ICON_SIZE) * 0.5);
                        icon.loadGraphic(iconPath);
                        icon.setGraphicSize(ICON_SIZE, ICON_SIZE);
                        icon.updateHitbox();
                        icon.camera = cam;
                        
                        final iconShader = new shaders.RoundedBorderShader(ICON_SIZE * 0.5, 0.0, 0xFF000000);
                        iconShader.setSize(ICON_SIZE, ICON_SIZE);
                        icon.shader = iconShader;
                        list.add(icon);
                        textOffX = CARD_PAD * 2 + ICON_SIZE + CARD_PAD;
                    }

                    final textW = cardW - textOffX - CARD_PAD;
                    final text  = new FlxText(textOffX, cardY + (ROW_H - 4 - FONT_SIZE) * 0.5, textW, entry.name)
                        .setFormat(Paths.font("vcr.ttf"), FONT_SIZE, 0xFFFFFFFF, LEFT, NONE);
                    text.camera = cam;
                    list.add(text);
                    nameTexts.push(text);
                }
            }

            columns.push({key: def.key, label: def.label, cam: cam, list: list, nameTexts: nameTexts, cardBgs: cardBgs});

            final delay = i * 0.08;
            final finalY = camY;
            colBg.y    = camY - 40;
            colTitle.y = colTitle.y - 40;

            FlxTween.tween(colBg, {y: finalY, alpha: 1}, 0.5, {ease: FlxEase.expoOut, startDelay: delay});
            FlxTween.tween(colTitle, {y: titleY - colTitle.height * 0.5, alpha: 1}, 0.5, {ease: FlxEase.expoOut, startDelay: delay});
        }

        #if DISCORD_ALLOWED
        DiscordClient.changePresence("In the Credits Menu");
        #end
    }

    function _makeCheckers():FlxBackdrop {
        final tileSize = 32;
        final bmd = new openfl.display.BitmapData(tileSize * 2, tileSize * 2, true, 0x00000000);
        bmd.fillRect(new openfl.geom.Rectangle(0, 0, tileSize, tileSize), 0x08FFFFFF);
        bmd.fillRect(new openfl.geom.Rectangle(tileSize, tileSize, tileSize, tileSize), 0x08FFFFFF);
        
        final bd = new FlxBackdrop(bmd, XY, 0, 0);
        bd.velocity.set(15, 10);
        bd.alpha = 0.5;
        return bd;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (subState != null) return;

        if (controls.BACK) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxG.sound.music?.stop();
            final extrasMenu = Std.downcast(FlxG.state, states.extras.ExtrasMenu);
            extrasMenu?._orphanPlayer?.playAudio(
                states.extras.dagarden.DAGarden.currentSong,
                states.extras.dagarden.DAGarden.currentSongMod
            );
            close();
            return;
        }

        var newHoveredCol:Int = -1;
        var newHoveredRow:Int = -1;
        canSelect = false;

        for (ci in 0...columns.length) {
            final col = columns[ci];
            final cam = col.cam;

            if (!_mouseOverCam(cam)) continue;

            if (FlxG.mouse.deltaWheel.y != 0) {
                final entries = credits.get(col.key);
                final maxScroll = entries != null ? Math.max(0, entries.length * ROW_H - cam.height + CARD_PAD * 2) : 0;
                cam.scroll.y -= FlxG.mouse.deltaWheel.y * ROW_H;
                cam.scroll.y  = FlxMath.bound(cam.scroll.y, 0, maxScroll);
            }

            for (i in 0...col.cardBgs.length) {
                final cardBg = col.cardBgs[i];
                if (cardBg != null && FlxG.mouse.overlaps(cardBg, cam)) {
                    canSelect = true;
                    curColumn = ci;
                    newHoveredCol = ci;
                    newHoveredRow = i;
                    userSelected = [col.key, i];
                    break;
                }
            }
        }

        if (newHoveredCol != _hoveredCol || newHoveredRow != _hoveredRow) {
            if (_hoveredCol != -1 && _hoveredRow != -1)
                _highlightCard(columns[_hoveredCol], _hoveredRow, false);
            
            if (newHoveredCol != -1 && newHoveredRow != -1)
                _highlightCard(columns[newHoveredCol], newHoveredRow, true);

            _hoveredCol = newHoveredCol;
            _hoveredRow = newHoveredRow;
        }

        if ((controls.ACCEPT || FlxG.mouse.justPressed) && canSelect)
            openSubState(new CreditPopup());

		Mouse.cursor = canSelect ? MouseCursor.BUTTON : MouseCursor.ARROW;
    }

    function _highlightCard(col:Column, row:Int, on:Bool):Void {
        if (row < col.nameTexts.length && col.nameTexts[row] != null) {
            col.nameTexts[row].color = on ? 0xFFFFFF44 : 0xFFFFFFFF;
        }

        if (row >= col.cardBgs.length) return;
        final cardBg = col.cardBgs[row];
        if (cardBg == null) return;

        final fill = on ? 0x44FFFFFF : 0x22FFFFFF;
        cardBg.pixels.fillRect(cardBg.pixels.rect, fill);
        cardBg.dirty = true;
    }

    function _mouseOverCam(cam:FlxCamera):Bool {
        return FlxG.mouse.viewX >= cam.x && FlxG.mouse.viewX <= cam.x + cam.width
            && FlxG.mouse.viewY >= cam.y && FlxG.mouse.viewY <= cam.y + cam.height;
    }

    override function closeSubState() {
        if (FlxG.sound.music != null && FlxG.sound.music.volume < 1) {
            FlxTween.cancelTweensOf(FlxG.sound.music);
            FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.6);
        }
        super.closeSubState();
    }

    override function destroy() {
        for (col in columns) FlxG.cameras.remove(col.cam);
		Mouse.cursor = MouseCursor.ARROW;
        columns = null;
        super.destroy();
    }
}