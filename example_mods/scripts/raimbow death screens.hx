var deathSongs:Array<String> = ["too-slow", "you-cant-run"];
function onGameOverStart() {

    setSongGameOver();
}

function setSongGameOver() {
    switch(songName){
        case "too-slow":
            characterName = "too-slow-death";
            trace('yes this is too slow');
    }
}