import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
import flixel.math.FlxMath;

var chrom:ShaderFilter;
var glitch:ShaderFilter;

var cameraShader:FlxCamera;


function onCreate() {
    chrom = game.createRuntimeShader('ChromaticAbberation');
    chrom.setFloat('amount', 0.0);

    glitch = game.createRuntimeShader('glitchChromatic');
    
    glitch.setFloat("iTime", 0);
    glitch.setFloat('GLITCH', 0.0);
    
    camGame.filters = [new ShaderFilter(glitch), new ShaderFilter(chrom)];
}

function onStepHit(){
    switch(curStep){
        case 520, 1176:
            //camGame.filters = [new ShaderFilter(glitch)];
            FlxTween.num(0, 1.2, 1.3, {ease:FlxEase.linear}, (val:Float) -> glitch.setFloat("GLITCH", val)); // 1. Valor primario. 2. Valor Final. 3. Tiempo de tween. 4. Fluides. 5. Definición de valor Y propiedad de lo que quieres tweenear. Puta madre Alv me pican los coocos.
        case 528, 1184:
            FlxTween.cancelTweensOf(glitch);
            FlxTween.num(1.2, 0, 1, {ease:FlxEase.smootherStepInOut}, (val:Float) -> glitch.setFloat("GLITCH", val));
        case 800:
            //camGame.filters = [new ShaderFilter(chrom)];
            FlxTween.num(0, 0.5, 0.9, {ease:FlxEase.smootherStepInOut}, (val:Float) -> chrom.setFloat("amount", val));
        case 1192:
            //camGame.filters = [new ShaderFilter(chrom)];
            FlxTween.num(0, 0.5, 0.9, {ease:FlxEase.smootherStepOut}, (val:Float) -> chrom.setFloat("amount", val));
        case 1464:
            FlxTween.num(0.5, 1.2, 0.9, {ease:FlxEase.linear}, (val:Float) -> chrom.setFloat("amount", val));
    }
}

var glitchTime:Float = 0; 
function onUpdate(elapsed) {
    glitchTime += elapsed / 1000; 
    glitch.setFloat("iTime", glitchTime); 
}