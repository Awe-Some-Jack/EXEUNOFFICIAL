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
    }

    public static function play(toIn:Bool, duration:Float = 0.5, ?onComplete:Void->Void):Void
    {
        if (activeTween != null) activeTween.cancel();

        isTransitioning = true;

        var startVal:Float = toIn ? 0.0 : 1.0;
        var endVal:Float = toIn ? 1.0 : 0.0;

        shader.progress.value = [startVal];

        activeTween = FlxTween.num(startVal, endVal, duration,
            {
                ease: FlxEase.quadInOut,
                onComplete: function(t:FlxTween) {
                    shader.progress.value = [endVal];
                    activeTween = null;
                    isTransitioning = false;
                    if (onComplete != null) onComplete();
                }
            },
            function(v:Float) {
                shader.progress.value = [v];
            },
        );
    }

    public static function switchState(nextState:FlxState, duration:Float = 0.5):Void
    {
        if (isTransitioning) return;

        play(true, duration, function() {
            FlxG.switchState(nextState);
        });
    }

    public static function openSubState(subState:FlxSubState, duration:Float = 0.5, ?onFadeOut:Void->Void):Void
    {
        if (isTransitioning) return;

        play(true, duration, function() {
            if (onFadeOut != null) onFadeOut();
            FlxG.state.openSubState(subState);
            play(false, duration);
        });
    }

    public static function closeSubState(duration:Float = 0.5, ?onFadeOut:Void->Void):Void
    {
        if (isTransitioning) return;

        play(true, duration, function() {
            if (onFadeOut != null) onFadeOut();
            FlxG.state.closeSubState();
            play(false, duration);
        });
    }
}