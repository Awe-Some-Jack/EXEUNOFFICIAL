import flixel.addons.display.FlxRuntimeShader;
import flixel.FlxCamera;
import openfl.filters.ShaderFilter;

var camDark:FlxCamera;
var invertAlpha:FlxRuntimeShader;
var gradientGraphic:FlxSprite;
var gradient:FlxSprite;

var gradients:Array<GradientData> = [];
var _ID:Int = 0;

function onCreatePost()
{
    camDark = new FlxCamera(); camDark.bgColor = 0x0;
    FlxG.cameras.add(camDark, false);
    camDark.visible = false;

    invertAlpha = new FlxRuntimeShader(
        '#pragma header

        void main()
        {
            vec2 uv = openfl_TextureCoordv;
            
            vec4 color = texture2D(bitmap, uv);

            float colorAmount = (color.r + color.g + color.b) / 3.0;

            color.a = 1 - color.a;


            gl_FragColor = color;
        }'
    );

    camDark.filters = [new ShaderFilter(invertAlpha)];

    gradientGraphic = FlxG.bitmap.add(Paths.image('gradient'));

    gradient = new FlxSprite().loadGraphic(gradientGraphic);
    gradient.screenCenter();
    gradient.camera = camDark;
    gradient.color = 0xFF000000;
    gradient.scale.set(2.1, 2.1);
    game.add(gradient);
}

function onUpdate(e) 
{
    if(!camDark.visible) return;

    for(data in gradients)
    {
        if(!data.note.alive && data.sprite.alive) FlxTween.tween(data.sprite, {alpha: 0}, 0.2, {onComplete: _ -> data.sprite.kill()});

        if(!data.sprite.alive) continue;

        data.sprite.x = data.note.x + (data.note.width - data.sprite.width) / 2;
        data.sprite.y = data.note.y + (data.note.height - data.sprite.height) / 2;
    }
}

function opponentNoteHit(note)
{
    if(!camDark.visible) return;

    FlxTween.cancelTweensOf(gradient);
    gradient.alpha = 1;
    FlxTween.tween(gradient, {alpha: 0}, Conductor.stepCrochet / 500);

    switch(dad.animation.name)
    {
        case 'singLEFT': 
            gradient.setPosition(175, 25);
            gradient.color = 0xff6e2b58;
        case 'singDOWN': 
            gradient.setPosition(450, 70);
            gradient.color = 0xff008b8b;
        case 'singUP': 
            gradient.setPosition(270, 0);
            gradient.color = 0xff0a8a05;
        case 'singRIGHT': 
            gradient.setPosition(325, 10);
            gradient.color = 0xff881e22;
    }
}

function onSpawnNote(note:Note)
{
    if(!note.mustPress || note.isSustainNote || !camDark.visible) return;

    var grad:FlxSprite;
    for(data in gradients)
    {
        if(!data.sprite.alive) 
        {
            grad = data.sprite;
            grad.revive();
            grad.alpha = 1;
            grad.x = grad.y = -999;
            data.note = note;
            
            FlxTween.cancelTweensOf(grad); //just in case
            return;
        }
    }

    grad = new FlxSprite(-999, -999).loadGraphic(gradientGraphic);
    grad.camera = camDark;
    grad.color = 0xFF000000;
    game.add(grad);

    gradients.push({sprite: grad, note: note});
}

var inDark:Bool = false;
function onEvent(n,v1)
{
	if (n == 'sunshinEvent')
	{
		switch(v1)
		{
			case 'lightsOut':
                if(inDark) for (i in 0...4) playerStrums.members[i].alpha = 0;
                camDark.visible = !camDark.visible;
                inDark = !inDark;
        }
    }
}
typedef GradientData = 
{
    var sprite:FlxSprite;
    var note:Note;
}