package backend;

@:build(backend.macros.ProtectedSongsChartMacro.build())
class ProtectedSongsChart 
{
    public static function getSongRaw(songFolder:String, jsonInput:String):Null<String> 
    {
        final key = songFolder + "/" + jsonInput;
        final entry = songsMap.get(key);
        return entry != null ? entry.json : null;
    }
    
    public static function isTampered(songFolder:String, jsonInput:String, loadedPath:String):Bool 
    {
        #if sys
        if (!sys.FileSystem.exists(loadedPath)) return false;
        
        final content = sys.io.File.getContent(loadedPath);
        final currentHash = haxe.crypto.Sha256.encode(content);
        
        final key = songFolder + "/" + jsonInput;
        final embedded = songsMap.get(key);
        
        return embedded != null && embedded.hash != currentHash;
        #else
        return false;
        #end
    }
}