var positions = {
    x: [],
    y: []
};

var sections:Array<Int> = [3968, 4032, 4096, 4160];
var section:Int = sections.shift();
var pattern:Array<Int> = [0, 4, 8, 12, 14, 18, 20, 24, 28, 32, 36, 40, 43, 46, 50, 52, 56, 60];
var intensity:Float = 1.5;
var prevScale:Float = 1;
var prevDownscroll:Bool = false;

function onStepHit() {
    if(game.isDead) {
        camHUD.angle = camGame.angle = 0;
        return;
    }

    switch(curStep) {
        case 3968:
            for(strum in playerStrums.members) {
                positions.x.push(strum.x);
                positions.y.push(strum.y);
                prevScale = strum.scale.x;
            }
            prevDownscroll = playerStrums.members[0].downScroll;
            
        case 4221: 
            for(i => strum in playerStrums.members) {
                FlxTween.tween(
                    strum, 
                    {x: positions.x[i], y: positions.y[i]}, 
                    (Conductor.stepCrochet / 1000) * 30,
                    {ease: FlxEase.expoInOut}
                );
                strum.downScroll = prevDownscroll;
            }

        case 4240:
            var separation:Int = 110;
            for(i => strum in opponentStrums.members) {
                strum.alpha = 0;
                strum.x = (FlxG.width / 2) + (separation / 2) - (((opponentStrums.members[i].width + (separation * 2)) * 4) / 2) + ((opponentStrums.members[i].width + separation * (i > 1 ? (i == 3 ? 2.33 : 3) : 1)) * i);
                strum.y = -100;
                FlxTween.tween(strum, {y: positions.y[i], alpha: 0.4}, 0.75, {ease: FlxEase.cubeOut, startDelay: 0.15 * i});
            }
    }
    
    if(curStep > section + pattern[pattern.length - 1]) section = sections.shift();
    for(n in pattern) 
        if(curStep == section + n) pattern2();
}

var ang:Bool = false;
function pattern2() {
    camHUD.angle = camGame.angle = (ang = !ang) ? -3 : 3;
    FlxTween.cancelTweensOf(camHUD);
    FlxTween.cancelTweensOf(camGame);
    FlxTween.tween(camHUD, {angle: 0}, (Conductor.stepCrochet / 1000) * 2.5);
    FlxTween.tween(camGame, {angle: 0}, (Conductor.stepCrochet / 1000) * 2.5);

    var y:Int = prevDownscroll ? FlxG.random.int(FlxG.height / 2, FlxG.height - playerStrums.members[0].height) : FlxG.random.int(0, FlxG.height / 2 - playerStrums.members[0].height);
    var prevX:Int = 0;
    for(i => strum in playerStrums.members) {
        var x = prevX = Math.min(i == 0 ? (prevX + FlxG.random.int(50, 500)) : (prevX + FlxG.random.int(50, 300)), FlxG.width - strum.width);
        strum.y = y;
        strum.x = x;
        if(y + strum.height / 2 > FlxG.height / 2) strum.downScroll = true;
        else strum.downScroll = false;
    }
}