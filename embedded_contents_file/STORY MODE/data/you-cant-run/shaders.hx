import openfl.filters.ShaderFilter;
import flixel.math.FlxMath;
import psychlua.LuaUtils;

var chrom = null;
var glitch = null;
var glitchTime:Float = 0;
var chromTween:FlxTween = null;
var glitchTween:FlxTween = null;

function loadShader(name:String)
{
    var source:String = null;
    try
    {
        source = Paths.getContent(Paths.shaderFragment(name));
    }
    catch (e:Dynamic)
    {
        debugPrint('shader "' + name + '" read failed: ' + e);
    }

    if (source == null || source.length < 1)
    {
        debugPrint('shader "' + name + '" source not found');
        return null;
    }

    return new ErrorHandledRuntimeShader(name, source);
}

function onCreate() {
    if (ClientPrefs.data.shaders)
    {

        chrom = loadShader('ChromaticAbberation');
        glitch = loadShader('glitchChromatic');
        
        if (chrom != null) chrom.setFloat('amount', 0.0);
        if (glitch != null)
        {
            glitch.setFloat("iTime", 0);
            glitch.setFloat('GLITCH', 0.0);
        }
        
        if (glitch != null) FilterPruner.add(camGame, glitch, 'GLITCH', 0);
        if (chrom != null) FilterPruner.add(camGame, chrom, 'amount', 0);
    }
}

function onEvent(n, v1, v2){
    var split1 = v1.split(', ');
    var split2 = v2.split(', ');
    if (ClientPrefs.data.shaders)
    {
        if (n == 'chromFlash' && chrom != null)
        {
            if (chromTween != null) chromTween.cancel();
            chromTween = FlxTween.num(Std.parseFloat(split1[0]), Std.parseFloat(split1[1]), Std.parseFloat(split2[0]), {ease: LuaUtils.getTweenEaseByString(split2.length > 1 ? split2[1] : '')}, (val:Float) -> chrom.setFloat("amount", val));
        }
        if (n == 'glitchFlash' && glitch != null)
        {
            if (glitchTween != null) glitchTween.cancel();
            glitchTween = FlxTween.num(Std.parseFloat(split1[0]), Std.parseFloat(split1[1]), Std.parseFloat(split2[0]), {ease: LuaUtils.getTweenEaseByString(split2.length > 1 ? split2[1] : '')}, (val:Float) -> glitch.setFloat("GLITCH", val));
        }
    }
}

function onUpdate(elapsed) {
    if (ClientPrefs.data.shaders)
    {
        if (glitch == null) return;
        glitchTime += elapsed / 1000;
        glitch.setFloat("iTime", glitchTime);
    }
}
