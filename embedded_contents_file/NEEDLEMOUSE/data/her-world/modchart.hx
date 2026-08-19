var positions = {
    x: [],
    y: []
};

var sections:Array<Int> = [3968, 4032, 4096, 4160];
var section:Int = sections.shift();
var pattern:Array<Int> = [0, 4, 8, 12, 14, 18, 20, 24, 28, 32, 36, 40, 43, 46, 50, 52, 56, 60];
var intensity:Float = 1.5;
var prevScale:Float = 1;

function onStepHit() {
    switch(curStep) {
        case 3968:
            for(strum in playerStrums.members) {
                positions.x.push(strum.x);
                positions.y.push(strum.y);
                prevScale = strum.scale.x;
            }
            
        case 4032: intensity = 1.1;
        case 4096: intensity = 1.4;
        case 4160: intensity = 1.2;
        case 4210: intensity = 1.4;
    }
    
    if(curStep > section + pattern[pattern.length - 1]) section = sections.shift();
    for(n in pattern) 
        if(curStep == section + n) pattern1();
}

function pattern1() {
    var amt = FlxG.random.int(10, 50) * intensity;
    for(i => strum in playerStrums.members) {
        var x = switch(i) {
            case 0: -amt;
            case 1: -amt * 0.4;
            case 2: amt * 0.4;
            case 3: amt;
        }

        strum.x += x;  strum.y += FlxG.random.int(-30, 30) * intensity; strum.angle = FlxG.random.int(-30, 30);
        strum.scale.set(prevScale * intensity, prevScale * intensity);
        FlxTween.cancelTweensOf(strum);
        FlxTween.tween(
            strum, 
            {x: positions.x[i], y: positions.y[i], angle: 0, "scale.x": prevScale, "scale.y": prevScale}, 
            curStep == 4220 ? (Conductor.stepCrochet / 1000) * 30 : (Conductor.stepCrochet / 1000) * 2,
            {ease: curStep == 4220 ? FlxEase.expoInOut : FlxEase.linear}
        );
    }
}