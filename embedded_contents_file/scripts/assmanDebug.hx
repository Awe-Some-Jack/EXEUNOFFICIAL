var botplayfichgerald:Bool = false;

function onCreate(){
    if (!game.cpuControlled) botplayfichgerald = true;
}

function onUpdate(elapsed:Float) {
    if (FlxG.keys.justPressed.F5) {
        FlxG.resetState();
    }

    if (FlxG.keys.justPressed.F4){
        FlxG?.sound?.music?.stop();
        vocals?.stop();
        opponentVocals?.stop();
        FlxG.switchState(new states.EXEMenu());
    }

    if (FlxG.keys.justPressed.TWO || FlxG.keys.justPressed.FOUR){
        FlxG.timeScale = game.playbackRate += (FlxG.keys.justPressed.TWO ? -0.1 : 1);
    }
    if (FlxG.keys.justPressed.THREE){
        FlxG.timeScale = game.playbackRate = 1;
    }

    if (game.playBackRate <= 0.2){
        game.playBackRate = 0.2;
    }else if (game.playBackRate >= 5){
        game.playBackRate = 5;
    }

    if (FlxG.keys.pressed.FIVE){
        FlxG.timeScale = game.playbackRate = 5;
        if (botplayfichgerald) game.cpuControlled = true;
        game.botplayTxt.visible = game.cpuControlled;
    }else if (FlxG.keys.justReleased.FIVE){
        FlxG.timeScale = game.playbackRate = 1;
        if (botplayfichgerald) game.cpuControlled = false;
        game.botplayTxt.visible = game.cpuControlled;
    }

    if (FlxG.keys.justPressed.SIX) {
        game.cpuControlled = !game.cpuControlled;
        game.botplayTxt.visible = game.cpuControlled;
        botplayfichgerald = game.cpuControlled;
    }
} 