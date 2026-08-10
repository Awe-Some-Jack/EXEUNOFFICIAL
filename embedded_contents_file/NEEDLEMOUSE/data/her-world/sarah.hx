import objects.Character;

// Haxefied this script cuz ye

var sarah:Character;

function onCreatePost() {
	sarah = new Character(dad.x, dad.y - 300, 'sarah2');
	insert(members.indexOf(dadGroup) - 1, sarah);
	sarah.alpha = 0;
	FlxTween.tween(sarah, {y: sarah.y + 100}, 2.5, {ease: FlxEase.sineInOut, type: 4});
}

var sarahAppear:Bool = false;
var sarahSine:Float = 0;
function onUpdatePost(e) {
	sarah.animation.play(dad.animation.curAnim.name, true);
	sarah.animation.curAnim.curFrame = dad.animation.curAnim.curFrame;

	if (sarahAppear) {
		sarahSine = sarahSine + (e / 2);
		sarah.alpha = (((Math.sin(sarahSine) / 2) + 0.75) / 2) + 0.25;
	}
}

var strumPos = [];
function onEvent(n,v1) {
	if (n == 'sarahevent') {
		if (v1 == 'sarahappears') {
			FlxTween.tween(sarah, {alpha: 0.5}, Conductor.crochet / 250, {ease: FlxEase.cubeOut, onComplete: () -> sarahAppear = true});

			
			for( i => strum in opponentStrums.members ) {
				strumPos.push(strum.x);
				FlxTween.tween(strum, {x: strum.x + 50}, 2, {ease: FlxEase.sineInOut, type: 4, startDelay: 0.25 * i});
			}
		}
		
		if (v1 == 'sarahout') {
			FlxTween.tween(sarah, {alpha: 0}, Conductor.crochet / 250, {ease: FlxEase.cubeOut});
			sarahAppear = false;
			
			for( i => strum in opponentStrums.members ) {
				FlxTween.cancelTweensOf(strum);
				FlxTween.tween(strum, {x: strumPos[i]}, 2, {ease: FlxEase.sineOut});
			}
		}
	}
}