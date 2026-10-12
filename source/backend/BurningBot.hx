package backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import flixel.math.FlxMath;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import states.EXETitle;
import states.EXEMenu;
import states.EXEFreeplay;

class BurningBot
{
    public static var active:Bool = false;

    public static var tensionElapsed:Float = 0.0;
    public static var approachPitch:Float = 0.65;

    public static function applyEerieAudio(elapsed:Float = 0):Void
    {
        tensionElapsed += elapsed;
        final progress = FlxMath.bound(tensionElapsed / 10.0, 0, 1);
        final pitch = FlxMath.lerp(1.0, 0.65, progress);

        #if FLX_PITCH
        FlxG.sound.list.forEach((sound:FlxSound) -> if (sound != null) sound.pitch = pitch);
        if (FlxG.sound.music != null) FlxG.sound.music.pitch = pitch;
        #end
    }

    public static function resetAudio():Void
    {
        tensionElapsed = 0.0;
        approachPitch = 0.65;

        #if FLX_PITCH
        FlxG.sound.list.forEach((sound:FlxSound) -> if (sound != null) sound.pitch = 1.0);
        if (FlxG.sound.music != null) FlxG.sound.music.pitch = 1.0;
        #end
    }

    public static function applyApproachPitch(elapsed:Float, targetProgress:Float):Void
    {
        final target = FlxMath.lerp(0.65, 0.02, FlxMath.bound(targetProgress, 0, 1));
        approachPitch = FlxMath.lerp(target, approachPitch, Math.exp(-elapsed * 3));

        #if FLX_PITCH
        FlxG.sound.list.forEach((sound:FlxSound) -> if (sound != null) sound.pitch = approachPitch);
        if (FlxG.sound.music != null) FlxG.sound.music.pitch = approachPitch;
        #end
    }

    public static function stopAllAudio():Void
    {
        FlxG.sound.list.forEach((sound:FlxSound) -> if (sound != null && sound.playing) sound.pause());
        if (FlxG.sound.music != null && FlxG.sound.music.playing) FlxG.sound.music.pause();
    }

    static var _titleTimer:Float = 0.0;

    public static function updateTitle(state:EXETitle, elapsed:Float):Void
    {
        applyEerieAudio(elapsed);

        _titleTimer += elapsed;
        if (_titleTimer >= 2.2)
        {
            _titleTimer = 0;
            state.confirmStart();
        }
    }

    static var _menuTimer:Float = 0.0;
    static var _menuMoving:Bool = false;

    public static function updateMenu(state:EXEMenu, elapsed:Float):Void
    {
        applyEerieAudio(elapsed);
        _menuTimer += elapsed;

        if (EXEMenu.selectedOptionIndex != 1)
        {
            if (_menuTimer >= (_menuMoving ? 0.65 : 1.0))
            {
                _menuTimer = 0;
                _menuMoving = true;
                final wrapped = ((1 - EXEMenu.selectedOptionIndex) % EXEMenu.TOTAL_OPTIONS + EXEMenu.TOTAL_OPTIONS) % EXEMenu.TOTAL_OPTIONS;
                final goUp = wrapped > Std.int(EXEMenu.TOTAL_OPTIONS / 2);
                state.changeSelection(goUp ? -1 : 1, goUp);
            }
        }
        else if (_menuTimer >= 1.0)
        {
            state.startBlink();
        }
    }

    public static var targetBox:Int = -1;
    public static var targetSong:Int = -1;

    static var _fpTimer:Float = 0.0;
    static var _fpPhase:Int = 0;

    static var _coverRevealing:Bool = false;
    static var _coverPlaying:Bool = false;
    static var _coverDone:Bool = false;
    static var _coverHoldTimer:Float = 0.0;

    static var _fadeAlpha:Float = 1.0;
    static var _fadeTarget:Float = 1.0;
    static var _fadeElapsed:Float = 0.0;
    static var _fadeDuration:Float = 6.0;

    public static var sceneCleared:Bool = false;
    public static var burningLocked:Bool = false;

    public static function resetFreeplayState():Void
    {
        targetBox = -1;
        targetSong = -1;
        _fpTimer = 0;
        _fpPhase = 0;
        _coverRevealing = false;
        _coverPlaying = false;
        _coverDone = false;
        _coverHoldTimer = 0;
        _fadeAlpha = 1.0;
        _fadeTarget = 1.0;
        _fadeElapsed = 0.0;
        _fadeDuration = 6.0;
        sceneCleared = false;
        burningLocked = false;
        _namesRevealing = false;
    }

    public static function updateFreeplay(state:EXEFreeplay, elapsed:Float):Void
    {
        applyEerieAudio(elapsed);

        if (_fpPhase >= 1 && _fpPhase < 4)
        {
            _fadeElapsed += elapsed;
            _fadeTarget = 1.0 - FlxMath.bound(_fadeElapsed / _fadeDuration, 0, 1);
        }

        applySceneFade(state, elapsed);
        _fpTimer += elapsed;

        switch (_fpPhase)
        {
            case 0:
                if (targetBox < 0)
                {
                    for (i in 0...state.songEntries.length)
                    {
                        for (j in 0...state.songEntries[i].songs.length)
                        {
                            if (state.songEntries[i].songs[j].songName == 'burning')
                            {
                                targetBox  = i;
                                targetSong = j;
                                break;
                            }
                        }
                        if (targetBox >= 0) break;
                    }
                    if (targetBox < 0)
                    {
                        active = false;
                        resetAudio();
                        return;
                    }

                    final boxSteps = (targetBox - EXEFreeplay.selectedBox + state.songEntries.length) % state.songEntries.length;
                    _fadeDuration = Math.max(3.0, boxSteps * 0.7 + 0.8 + targetSong * 0.7);
                }
                if (_fpTimer >= 1.0) { _fpTimer = 0; _fpPhase = 1; }

            case 1:
                applyApproachPitch(elapsed, 0.15);
                if (EXEFreeplay.selectedBox == targetBox) { _fpTimer = 0; _fpPhase = 2; }
                else if (_fpTimer >= 0.7)
                {
                    _fpTimer = 0;
                    state.changeSelection(FlxMath.wrap(EXEFreeplay.selectedBox + 1, 0, state.songEntries.length - 1));
                }

            case 2:
                applyApproachPitch(elapsed, 0.35);
                if (_fpTimer >= 0.8)
                {
                    _fpTimer = 0;
                    _fpPhase = 3;
                    state.enterSelectedBox();
                }

            case 3:
                applyApproachPitch(elapsed, 0.55);
                if (state.songSelector == targetSong)
                {
                    _fpTimer = 0;
                    _fpPhase = 4;
                    _fadeTarget = 0;
                    startCoverReveal(state);
                }
                else if (_fpTimer >= 0.7)
                {
                    _fpTimer = 0;
                    state.chooseSong(1);
                }

            case 4:
                updateCoverReveal(state, elapsed);
                if (_coverDone) _fpPhase = 5;

            default:
        }
    }

    public static function enforceSceneCleared(state:EXEFreeplay):Void
    {
        if (!sceneCleared) return;

        if (state.bgSonic != null) state.bgSonic.alpha = 0;
        if (state.bgChecker != null) state.bgChecker.alpha = 0;
        if (state.verticalLine != null) state.verticalLine.alpha = 0;
        if (state.degradado != null) state.degradado.alpha = 0;
        if (state.spikesUp != null) state.spikesUp.alpha = 0;

        if (state.scoreText != null) state.scoreText.alpha = 0;
        if (state.rankText != null) state.rankText.alpha = 0;

        state.exeTexts.forEach((t) -> t.alpha = 0);

        state.freeBoxes.forEach((box) -> if (box.ID != targetBox) box.alpha = 0);
        state.covers.forEach((cover) -> if (cover.ID != targetBox) cover.alpha = 0);

        state.staticScreens.forEach((ss) -> {
            if (ss.ID != targetBox) ss.alpha = 0;
            else ss.alpha = 0.18;
        });

        for (t in state.songTexts.members)
            if (t != null && !(_namesRevealing && t.ID == targetSong))
                t.alpha = (t.ID == targetSong) ? 1.0 : 0;
    }

    static function applySceneFade(state:EXEFreeplay, elapsed:Float):Void
    {
        _fadeAlpha = FlxMath.lerp(_fadeTarget, _fadeAlpha, Math.exp(-elapsed * 1.5));

        if (state.bgSonic != null) state.bgSonic.alpha = _fadeAlpha;
        if (state.bgChecker != null) state.bgChecker.alpha = _fadeAlpha * 0.10;
        if (state.verticalLine != null) state.verticalLine.alpha = _fadeAlpha;
        if (state.degradado != null) state.degradado.alpha = _fadeAlpha;
        if (state.spikesUp != null) state.spikesUp.alpha = _fadeAlpha;

        if (state.scoreText != null) state.scoreText.alpha = _fadeAlpha;
        if (state.rankText != null) state.rankText.alpha = _fadeAlpha;

        state.exeTexts.forEach((t) -> t.alpha = _fadeAlpha);

        state.freeBoxes.forEach((box) -> if (box.ID != targetBox) box.alpha = _fadeAlpha);
        state.covers.forEach((cover) -> if (cover.ID != targetBox) cover.alpha = _fadeAlpha);

        state.staticScreens.forEach((ss) -> {
            if (ss.ID != targetBox) ss.alpha = _fadeAlpha;
            else ss.alpha = 0.18;
        });

        final onTargetBox = (EXEFreeplay.selectedBox == targetBox);
        for (t in state.songTexts.members)
            if (t != null)
                t.alpha = (onTargetBox && t.ID == targetSong) ? 1.0 : _fadeAlpha;
    }

    public static function setCoverBlackFrame(cover:FlxSprite):Void
    {
        if (cover.animation.getByName('appear') == null)
        {
            cover.frames = FlxAtlasFrames.fromSparrow(Paths.getBitmapData('assets/exe/freeplayassets/covers/burning/burning.webp'), 'assets/exe/freeplayassets/covers/burning/burning.xml');
            cover.animation.addByPrefix('appear', 'burning appear', 6, false);
        }

        if (!_coverPlaying)
        {
            final anim = cover.animation.getByName('appear');
            cover.animation.frameIndex = anim.numFrames - 1;
        }
    }

    static function startCoverReveal(state:EXEFreeplay):Void
    {
        if (targetBox < 0 || targetBox >= state.covers.length) return;

        final cover = state.covers.members[targetBox];
        if (cover == null) return;

        setCoverBlackFrame(cover);
        state.positionCover(cover, state.staticScreens.members[targetBox], false);

        _coverRevealing = true;
        _coverPlaying = false;
        _coverDone = false;
        _coverHoldTimer = 0.0;
    }

    static function updateCoverReveal(state:EXEFreeplay, elapsed:Float):Void
    {
        if (!_coverRevealing || _coverDone) return;

        if (!_coverPlaying)
        {
            _coverHoldTimer += elapsed;
            applyApproachPitch(elapsed, 0.75 + 0.25 * FlxMath.bound(_coverHoldTimer / 2.0, 0, 1));

            if (_coverHoldTimer >= 2.0)
            {
                _coverPlaying = true;
                stopAllAudio();

                final cover = state.covers.members[targetBox];
                if (cover != null)
                {
                    cover.animation.finishCallback = (name:String) -> finishCoverReveal(state);
                    cover.animation.play('appear', true, true);
                    FlxG.sound.play(Paths.sound('eggmanmoving'));
                }
            }
        }
    }

    static var _namesRevealing:Bool = false;

    static function finishCoverReveal(state:EXEFreeplay):Void
    {
        _coverDone = true;

        final cover = state.covers.members[targetBox];
        if (cover != null)
        {
            cover.animation.finishCallback = null;

            final bmp = EXEFreeplay.loadRawBitmap('assets/exe/freeplayassets/covers/burning/burningidle.webp');
            if (bmp != null)
            {
                cover.loadGraphic(bmp);
                state.positionCover(cover, state.staticScreens.members[targetBox], false);
            }
        }

        active = false;
        sceneCleared = true;
        burningLocked = true;
        resetAudio();

        _namesRevealing = true;
        new FlxTimer().start(0.8, (_) -> revealNames(state));
    }

    static function revealNames(state:EXEFreeplay):Void
    {
        if (targetBox >= 0 && targetBox < state.songEntries.length)
            state.loadCharText(targetBox);

        final songs = state.getSongsForBox(targetBox);
        final spr = (targetSong >= 0 && targetSong < state.songTexts.length && targetSong < songs.length)
            ? state.songTexts.members[targetSong] : null;

        if (spr == null)
        {
            _namesRevealing = false;
            return;
        }

        FlxTween.tween(spr, {alpha: 0}, 0.15, {
            onComplete: (_) -> {
                spr.text = songs[targetSong].toUpperCase();
                FlxTween.tween(spr, {alpha: 1}, 0.35, {ease: FlxEase.circOut, onComplete: (_) -> _namesRevealing = false});
            }
        });
    }

    public static function fixInitialCover(state:EXEFreeplay):Void
    {
        for (i in 0...state.songEntries.length)
        {
            if (state.songEntries[i].songs.length == 0 || state.songEntries[i].songs[0].songName != 'burning') continue;

            final cover = state.covers.members[i];
            if (cover == null) continue;

            if (active)
                setCoverBlackFrame(cover);
            else
            {
                final bmp = EXEFreeplay.loadRawBitmap('assets/exe/freeplayassets/covers/burning/burningidle.webp');
                if (bmp != null) cover.loadGraphic(bmp);
            }

            cover.scale.set(0.35, 0.35);
            cover.updateHitbox();

            final ss = state.staticScreens.members[i];
            if (ss != null)
            {
                ss.setGraphicSize(Std.int(cover.width), Std.int(cover.height));
                ss.updateHitbox();
            }
        }
    }

    public static function applyLockIfNeeded(state:EXEFreeplay):Void
    {
        if (!burningLocked) return;
        if (targetBox < 0 || targetBox >= state.songEntries.length) return;

        EXEFreeplay.selectedBox = targetBox;
        state.songSelector = targetSong;
        state.choosingSong = true;

        state.updateSelection(false);
        state.loadCharText(targetBox);
        state.loadSongList(targetBox);
        state.scaleSongBox(true);
        state.updateSelectedCover(false);
    }

    public static function startBurningLaunch(state:EXEFreeplay, onComplete:()->Void):Void
    {
        final overlay = new FlxSprite();
        overlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        overlay.scrollFactor.set();
        overlay.alpha = 0;
        state.add(overlay);

        final cover = state.covers.members[targetBox];
        if (cover != null)
        {
            final mid = cover.getMidpoint();
            if (state.bgCam != null)
            {
                state.bgCam.focusOn(mid);
                FlxTween.tween(state.bgCam, {zoom: state.bgCam.zoom * 2.5}, 1.2, {ease: FlxEase.quadIn});
            }
            FlxG.camera.focusOn(mid);
            FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom * 2.5}, 1.2, {ease: FlxEase.quadIn});

            mid.put();
        }

        FlxTween.tween(overlay, {alpha: 1}, 1.2, {ease: FlxEase.quadIn, onComplete: (_) -> onComplete()});
    }
}
