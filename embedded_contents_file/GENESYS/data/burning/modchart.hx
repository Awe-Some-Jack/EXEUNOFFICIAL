var glitch:ErrorHandledRuntimeShader;
var notesPosition:Array<Array<Array<Float>>> = [[0,0],[0,0],[0,0],[0,0]];
var _savedDS:Bool = false;
function onCreatePost()
{
	if (ClientPrefs.data.shaders)
	{
		glitch = new ErrorHandledRuntimeShader('glitch', File.getContent('contents/GENESYS/shaders/glitch.frag'));
		game.camGame.filters = [new ShaderFilter(glitch)];
		//game.camHUD.filters = [new ShaderFilter(glitch)];
	}
}

var _hold:Float = 0;
function onUpdatePost(elapsed)
{
	if (_hold > 0)
	{
		_hold -= elapsed;

		for (i in 0...4) 
		{
			game.playerStrums.members[i].angle = FlxG.random.float(-1, 1) * _hold * 10;
		}
	}
	if (_hold <= 0)
	{
		for (i in 0...4)
		{
			if (game.playerStrums.members[i].angle != 0) game.playerStrums.members[i].angle = 0;
		}
	}
}

function onEvent(n, v1)
{
	if (n == 'genesysEvents')
	{
		switch(v1)
		{
			case 'save':
				for (i in 0...4)
				{
					notesPosition[i][0] = game.playerStrums.members[i].x;
					notesPosition[i][1] = game.playerStrums.members[i].y;
				}
				_savedDS = game.playerStrums.members[0].downScroll;
			case 'g':
				for (i in 0...4) 
				{
					final daStrum = game.playerStrums.members[i];
					daStrum.setPosition(
						FlxG.random.int(FlxG.width / 4 * i, FlxG.width / 4 * (i + 1) - daStrum.width),
						FlxG.random.int(0, FlxG.height - daStrum.height)
					);

					daStrum.downScroll = (daStrum.y > (FlxG.height / 2) - (daStrum.height / 2));
				}

				applyToNotes();
				_hold = 0.5;

				if (ClientPrefs.data.shaders)
				{
					glitch.setFloat('prob', 0.1);
					glitch.setFloat('time', FlxG.random.float(0,10));
				}
			case 'b':
				for (i in 0...4) 
				{
					final daStrum = game.playerStrums.members[i];
					daStrum.setPosition(notesPosition[i][0], notesPosition[i][1]);
					daStrum.downScroll = _savedDS;
				}
				applyToNotes();
				_hold = 0.5;

				if (ClientPrefs.data.shaders) glitch.setFloat('prob', 0);
		}
	}
}

function applyToNotes()
{
	for (i in 0...game.notes.length)
	{
		final daNote = game.notes.members[i];
		if (daNote.isSustainNote) daNote.flipY = game.playerStrums.members[daNote.noteData].downScroll;
	}

	for (i in 0...game.unspawnNotes.length)
	{
		final daNote = game.unspawnNotes[i];
		if (daNote.isSustainNote) daNote.flipY = game.playerStrums.members[daNote.noteData].downScroll;
	}
}