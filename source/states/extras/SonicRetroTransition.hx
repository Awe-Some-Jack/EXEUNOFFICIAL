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

    /**
     * Aplica el shader a la cámara principal. Llama a esto en el create() de tus States.
     */
    public static function init():Void
    {
        FlxG.camera.filters = [new ShaderFilter(shader)];
        shader.progress.value = [0.0];
    }

    /**
     * Ejecuta el fade retro en pasos discretos.
     * @param toIn true = Fade Out hacia azul/negro | false = Fade In revelando la pantalla
     */
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

    /**
     * Cambia de FlxState ejecutando la transición completa.
     */
    public static function switchState(nextState:FlxState, duration:Float = 0.5):Void
    {
        if (isTransitioning) return;

        play(true, duration, function() {
            FlxG.switchState(nextState);
        });
    }

    /**
     * Abre un SubState coordinando el fade out e in.
     */
    public static function openSubState(subState:FlxSubState, duration:Float = 0.5, ?onFadeOut:Void->Void):Void
    {
        if (isTransitioning) return;

        play(true, duration, function() {
            if (onFadeOut != null) onFadeOut();
            FlxG.state.openSubState(subState);
            play(false, duration);
        });
    }

    /**
     * Cierra el SubState actual coordinando el fade out e in.
     */
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