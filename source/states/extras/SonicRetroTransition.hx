package states.extras;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import openfl.filters.ShaderFilter;
import shaders.ColorShiftShader;

class SonicRetroTransition
{
    public static var shader:ColorShiftShader = new ColorShiftShader();
    private static var activeTween:FlxTween;
    public static var isTransitioning:Bool = false;

    public static function init():Void
    {
        FlxG.camera.filters = [new ShaderFilter(shader)];
        shader.progress.value = [0.0];

        activeTween = null;
        isTransitioning = false;
    }

    public static function play(toIn:Bool, duration:Float = 0.5, ?onComplete:Void->Void):Void
    {
        tweenProgress(toIn ? 0.0 : 1.0, toIn ? 1.0 : 0.0, duration, onComplete);
    }

    public static function switchState(nextState:FlxState, duration:Float = 0.5):Bool
    {
        return cover(duration, false, function() {
            FlxG.switchState(nextState);
        });
    }

    public static function openSubState(subState:FlxSubState, duration:Float = 0.5, ?onFadeOut:Void->Void):Bool
    {
        return cover(duration, true, function() {
            if (onFadeOut != null) onFadeOut();
            FlxG.state.openSubState(subState);
        });
    }

    public static function closeSubState(duration:Float = 0.5, ?onFadeOut:Void->Void):Bool
    {
        return cover(duration, true, function() {
            if (onFadeOut != null) onFadeOut();
            FlxG.state.closeSubState();
        });
    }

    static function cover(duration:Float, fadeBack:Bool, action:Void->Void):Bool
    {
        if (isTransitioning) return false;

        isTransitioning = true;

        final from:Float = shader.progress.value != null ? shader.progress.value[0] : 0.0;
        tweenProgress(from, 1.0, Math.max(duration * (1.0 - from), 0.01), function() {
            isTransitioning = false;
            action();
            if (fadeBack) play(false, duration);
        });
        return true;
    }

    static function tweenProgress(startVal:Float, endVal:Float, duration:Float, ?onComplete:Void->Void):Void
    {
        if (activeTween != null && activeTween.active) activeTween.cancel();

        shader.progress.value = [startVal];

        activeTween = FlxTween.num(startVal, endVal, duration,
            {
                ease: FlxEase.quadInOut,
                onComplete: function(t:FlxTween) {
                    shader.progress.value = [endVal];
                    activeTween = null;
                    if (onComplete != null) onComplete();
                }
            },
            function(v:Float) {
                shader.progress.value = [v];
            },
        );
    }
}
