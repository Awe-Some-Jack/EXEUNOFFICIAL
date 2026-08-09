package backend;

@:build(backend.macros.ProtectedSongsChartMacro.build())
class ProtectedSongsChart 
{
    public static final enabled:Bool = #if final true #else false #end;

    public static function getSongRaw(songFolder:String, jsonInput:String):Null<String> 
    {
        if (!enabled) return null;

        final key = songFolder + "/" + jsonInput;
        final entry = songsMap.get(key);
        
        if (entry != null)
            return haxe.Resource.getString(entry.resName);
        return null;
    }
    
    public static function isTampered(songFolder:String, jsonInput:String, loadedPath:String):Bool 
    {
        #if sys
        if (!sys.FileSystem.exists(loadedPath)) return false;
        
        final content = Paths.getContent(loadedPath);
        final currentHash = haxe.crypto.Sha256.encode(content);
        
        final key = songFolder + "/" + jsonInput;
        final embedded = songsMap.get(key);
        
        return embedded != null && embedded.hash != currentHash;
        #else
        return false;
        #end
    }
}