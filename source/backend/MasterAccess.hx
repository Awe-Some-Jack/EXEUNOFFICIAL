package backend;

#if desktop
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxG;
import flixel.util.FlxSave;

class MasterAccess {
    public static var accessed:Bool = false;
    private static var initialized:Bool = false;

    public static function init() {
        if (initialized) return;
        initialized = true;

        #if desktop
        verifyKey(false);

        FlxG.signals.preUpdate.add(function() {
            if (FlxG.keys.justPressed.F10) {
                verifyKey(true); 
            }
        });
        #end
    }

    public static function verifyKey(resetCurrentState:Bool = false, unlockAll:Bool = true, createDebug:Bool = true) {
        #if desktop
        var keyPath = "UnofficialCrew.key";
        var altKeyPath = "assets/UnofficialCrew.key";
        
        if (FileSystem.exists(keyPath) || FileSystem.exists(altKeyPath)) {
            var justUnlocked = !accessed;
            accessed = true;
            unlockEverything();
            createDebugToolsFile();
            
            if (justUnlocked) {
                trace("'UnofficialCrew.key' founded, master mode active");
            }

            if (resetCurrentState) {
                FlxG.resetState();
            }
        } else {
            if (resetCurrentState) {
                trace("Not founded UnofficialCrew.key.");
            }
        }
        #end
    }

  public static function unlockEverything() {
        try {
            var save = new flixel.util.FlxSave();
            save.bind('savedSongs', CoolUtil.getSavePath());
            
            if (save.data.songs == null) {
                save.data.songs = [];
            }
            
            var unlocked:Array<String> = save.data.songs;

            var keepList = WeekData.weeksList;
            var keepLoaded = WeekData.weeksLoaded;
            WeekData.weeksLoaded = new Map<String, WeekData>();
            WeekData.reloadWeekFiles(false);
            var allWeeks = WeekData.weeksList;
            var allLoaded = WeekData.weeksLoaded;
            WeekData.weeksList = keepList;
            WeekData.weeksLoaded = keepLoaded;

            for (i in 0...allWeeks.length) {
                var weekName:String = allWeeks[i];
                var leWeek:WeekData = allLoaded.get(weekName);

                if (leWeek == null || leWeek.songs == null) continue;

                for (song in leWeek.songs) {
                    var sName:String = Paths.formatToSongPath(song[0]);
                    if (!unlocked.contains(sName)) {
                        unlocked.push(sName);
                    }
                }
            }

            var secretSongPath:String = Paths.formatToSongPath('shocker');
            if (!unlocked.contains(secretSongPath)) {
                unlocked.push(secretSongPath);
            }

            save.data.songs = unlocked;
            save.flush();
        } catch (e:Dynamic) {
            trace("Error unlocking all content: " + e);
        }
    }

    public static function createDebugToolsFile() {
        #if desktop
        var filePath = "assets/debug_tools.hx";
        var content:String = 
'var curSpeed:Float = 1;
var curBotplay:Bool = false;
var devControlBotplay:Bool = true;

function onUpdatePost(e){
    @:privateAccess
    if (FlxG.keys.justPressed.ONE && generatedMusic) {
        game.KillNotes();
        FlxG.sound?.music?.onComplete();
    }

    if (FlxG.keys.justPressed.TWO) curSpeed -= 0.1;
    if (FlxG.keys.justPressed.THREE) curSpeed = 1;
    if (FlxG.keys.justPressed.FOUR) curSpeed += 0.1;
    
    curSpeed = FlxMath.bound(curSpeed, 0.1, 2);

    game.playbackRate = FlxG.keys.pressed.FIVE ? 20 : curSpeed;

    if (FlxG.keys.justPressed.SIX) curBotplay = !curBotplay;
    if (devControlBotplay){
        game.cpuControlled = FlxG.keys.pressed.FIVE || curBotplay;
    } 
    
    if (FlxG.keys.justPressed.F1){
        setSongTime(Conductor.songPosition - 1000);
        clearNotesBefore(Conductor.songPosition);
    }
    if (FlxG.keys.justPressed.F2){
        setSongTime(Conductor.songPosition + 1000);
        clearNotesBefore(Conductor.songPosition);
    }
    if (FlxG.keys.justPressed.F4){
        game.KillNotes();
        FlxG.sound?.music?.stop();
        FlxG.sound.playMusic(Assets.getSound(\'assets/exe/music/menu.ogg\'));
        FlxG.switchState(new states.EXEMenu());
    }
    if (FlxG.keys.justPressed.F5){
        PlayState.nextReloadAll = true;
        FlxG.resetState();
    }
}

function destroy() {
    game.playbackRate = 1;
    FlxG.sound?.muted = false;
}';

        if (!FileSystem.exists(filePath)) {
            try {
                File.saveContent(filePath, content);
            } catch (e:Dynamic) {}
        }
        #end
    }

    public static function gameDebug() {}
}