import openfl.filters.ShaderFilter;
import flixel.math.FlxMath;

var chrom = null;
var glitch = null;
var glitchTime:Float = 0;

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
    chrom = loadShader('ChromaticAbberation');
    glitch = loadShader('glitchChromatic');

    if (chrom != null) chrom.setFloat('amount', 0.0);
    if (glitch != null)
    {
        glitch.setFloat("iTime", 0);
        glitch.setFloat('GLITCH', 0.0);
    }

    var shaderFilters = [];
    if (glitch != null) shaderFilters.push(new ShaderFilter(glitch));
    if (chrom != null) shaderFilters.push(new ShaderFilter(chrom));
    camGame.filters = shaderFilters;
}

function onEvent(n, v1, v2){
    var split1 = v1.split(', ');
    var split2 = v2.split(', ');
    if (n == 'chromFlash' && chrom != null)
        FlxTween.num(split1[0], split1[1], split2[0], {ease: split2[1]}, (val:Float) -> chrom.setFloat("amount", val));
    if (n == 'glitchFlash' && glitch != null)
        FlxTween.num(split1[0], split1[1], split2[0], {ease: split2[1]}, (val:Float) -> glitch.setFloat("GLITCH", val));
}

function onUpdate(elapsed) {
    if (glitch == null) return;
    glitchTime += elapsed / 1000;
    glitch.setFloat("iTime", glitchTime);
}
