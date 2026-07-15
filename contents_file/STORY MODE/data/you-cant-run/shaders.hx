import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets;
import flixel.math.FlxMath;

var chrom:FlxRuntimeShader;
var glitch:FlxRuntimeShader;

var cameraShader:FlxCamera;


function onCreate() {
    chrom = new FlxRuntimeShader(Assets.getText(Paths.shaderFragment('ChromaticAbberation')));
    chrom.setFloat('amount', 0.0);

    glitch = new FlxRuntimeShader(Assets.getText(Paths.shaderFragment('glitchChromatic')));
    glitch.setFloat("iTime", 0);
    glitch.setFloat('GLITCH', 0.0);

    camGame.filters = [new ShaderFilter(glitch), new ShaderFilter(chrom)];
}

function onEvent(n, v1, v2){
    var split1 = v1.split(', ');
    var split2 = v2.split(', ');
    if (n == 'chromFlash')
        FlxTween.num(split1[0], split1[1], split2[0], {ease: split2[1]}, (val:Float) -> chrom.setFloat("amount", val));
    if (n == 'glitchFlash')
        FlxTween.num(split1[0], split1[1], split2[0], {ease: split2[1]}, (val:Float) -> glitch.setFloat("GLITCH", val));
}

var glitchTime:Float = 0; 
function onUpdate(elapsed) {
    glitchTime += elapsed / 1000; 
    glitch.setFloat("iTime", glitchTime); 
}