package backend;

import lime.utils.Assets;
import haxe.Json;
import openfl.utils.Assets as OpenFlAssets;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

typedef WeekFile =
{
    // JSON variables
    var songs:Array<Dynamic>;
    var weekCharacters:Array<String>;
    var weekBackground:String;
    var weekBefore:String;
    var storyName:String;
    var weekName:String;
    var startUnlocked:Bool;
    var hiddenUntilUnlocked:Bool;
    var hideStoryMode:Bool;
    var hideFreeplay:Bool;
    var difficulties:String;
    @:optional var bgColor:Array<Int>;
    @:optional var exeTitle:String;
    @:optional var exeCover:String;
    @:optional var exeLabel:String;
    @:optional var transitionShape:String;
}

class WeekData {
    public static var weeksLoaded:Map<String, WeekData> = new Map<String, WeekData>();
    public static var weeksList:Array<String> = [];
    public var folder:String = '';

    // JSON variables
    public var songs:Array<Dynamic>;
    public var weekCharacters:Array<String>;
    public var weekBackground:String;
    public var weekBefore:String;
    public var storyName:String;
    public var weekName:String;
    public var startUnlocked:Bool;
    public var hiddenUntilUnlocked:Bool;
    public var hideStoryMode:Bool;
    public var hideFreeplay:Bool;
    public var difficulties:String;
    public var bgColor:Array<Int>;
    public var exeTitle:String;
    public var exeCover:String;
    public var exeLabel:String;
    public var transitionShape:String;

    public var fileName:String;

    public static function createWeekFile():WeekFile {
        var weekFile:WeekFile = {
            songs: [["Bopeebo", "face", [146, 113, 253]], ["Fresh", "face", [146, 113, 253]], ["Dad Battle", "face", [146, 113, 253]]],
            weekCharacters: ['bf', 'bf', 'gf'],
            weekBackground: 'stage',
            weekBefore: 'tutorial',
            storyName: 'Your New Week',
            weekName: 'Custom Week',
            startUnlocked: true,
            hiddenUntilUnlocked: false,
            hideStoryMode: false,
            hideFreeplay: false,
            difficulties: ''
        };
        return weekFile;
    }

    public function new(weekFile:WeekFile, fileName:String) {
        for (field in Reflect.fields(weekFile))
            if(Reflect.fields(this).contains(field))
                Reflect.setProperty(this, field, Reflect.getProperty(weekFile, field));

        this.fileName = fileName;
    }

    public static function reloadWeekFiles(isStoryMode:Null<Bool> = false)
    {
        weeksList = [];
        weeksLoaded.clear();
        
        #if MODS_ALLOWED
        var directories:Array<String> = [Paths.mods(), Paths.getSharedPath()];
        var originalLength:Int = directories.length;

        for (mod in Mods.parseList().enabled)
            directories.push(Paths.mods(mod + '/'));
        #else
        var directories:Array<String> = [Paths.getSharedPath()];
        var originalLength:Int = directories.length;
        #end

        var sexList:Array<String> = CoolUtil.coolTextFile(Paths.getSharedPath('weeks/weekList.txt'));
        for (i in 0...sexList.length) {
            for (j in 0...directories.length) {
                var fileToCheck:String = directories[j] + 'weeks/' + sexList[i] + '.json';
                if(!weeksLoaded.exists(sexList[i])) {
                    var week:WeekFile = getWeekFile(fileToCheck);
                    if(week != null) {
                        var weekFile:WeekData = new WeekData(week, sexList[i]);

                        #if MODS_ALLOWED
                        if(j >= originalLength) {
                            weekFile.folder = directories[j].substring(Paths.mods().length, directories[j].length-1);
                        }
                        #end

                        if(weekFile != null) {
                            weeksLoaded.set(sexList[i], weekFile);
                            weeksList.push(sexList[i]);
                        }
                    }
                }
            }
        }

        for (i in 0...directories.length) {
            var directory:String = directories[i] + 'weeks/';

            var listPath:String = directory + 'weekList.txt';
            var rawList:String = null;
            rawList = Paths.getContent(listPath);

            if (rawList != null) {
                var listOfWeeks:Array<String> = rawList.split('\n');
                for (daWeek in listOfWeeks) {
                    daWeek = StringTools.trim(daWeek);
                    if (daWeek.length == 0) continue;

                    var path:String = directory + daWeek + '.json';
                    addWeek(daWeek, path, directories[i], i, originalLength);
                }
            }

            var directoryFiles:Array<String> = Paths.readDirectory(directory);
            for (file in directoryFiles) {
                if (file.endsWith('.json')) {
                    var weekName:String = file.substr(0, file.length - 5);
                    var path:String = haxe.io.Path.join([directory, file]);
                    addWeek(weekName, path, directories[i], i, originalLength);
                }
            }
        }
    }

    private static function addWeek(weekToCheck:String, path:String, directory:String, i:Int, originalLength:Int)
    {
        if(!weeksLoaded.exists(weekToCheck))
        {
            var week:WeekFile = getWeekFile(path);
            if(week != null)
            {
                var weekFile:WeekData = new WeekData(week, weekToCheck);
                if(i >= originalLength)
                {
                    #if MODS_ALLOWED
                    weekFile.folder = directory.substring(Paths.mods().length, directory.length-1);
                    #end
                }
                weeksLoaded.set(weekToCheck, weekFile);
                weeksList.push(weekToCheck);
            }
        }
    }

    private static function getWeekFile(path:String):WeekFile {
        var rawJson:String = null;
        rawJson = Paths.getContent(path);

        if(rawJson != null && rawJson.length > 0) {
            return cast tjson.TJSON.parse(rawJson);
        }
        return null;
    }

    // =====================================================================
    // FUNCTIONS YOU WILL PROBABLY NEVER NEED TO USE
    // =====================================================================

    public static function getWeekFileName():String {
        return weeksList[PlayState.storyWeek];
    }

    public static function getCurrentWeek():WeekData {
        return weeksLoaded.get(weeksList[PlayState.storyWeek]);
    }

    public static function setDirectoryFromWeek(?data:WeekData = null) {
        Mods.currentModDirectory = '';
        if(data != null && data.folder != null && data.folder.length > 0) {
            Mods.currentModDirectory = data.folder;
        }
    }
}