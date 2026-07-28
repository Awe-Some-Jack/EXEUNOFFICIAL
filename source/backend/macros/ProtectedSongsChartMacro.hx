package backend.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class ProtectedSongsChartMacro 
{
    public static function build():Array<Field> 
    {
        final fields = Context.getBuildFields();
        final mapExpr = buildMapExpr();
        
        final field:Field = {
            name: "songsMap",
            doc: null,
            meta: [],
            access: [APublic, AStatic],
            kind: FVar(macro : haxe.ds.StringMap<{resName:String, hash:String}>, mapExpr),
            pos: Context.currentPos()
        };
        fields.push(field);
        return fields;
    }

    static function buildMapExpr():Expr 
    {
        final mapAssignments:Array<Expr> = [];
        final directoriesToScan = ["assets/shared/data/"];
        
        #if sys
        if (FileSystem.exists("contents_file")) 
        {
            for (mod in FileSystem.readDirectory("contents_file")) 
            {
                final modDataPath = "contents_file/" + mod + "/data/";
                if (FileSystem.exists(modDataPath) && FileSystem.isDirectory(modDataPath)) 
                    directoriesToScan.push(modDataPath);
            }
        }
        
        for (basePath in directoriesToScan) 
        {
            if (!FileSystem.exists(basePath)) continue;
            
            for (folder in FileSystem.readDirectory(basePath)) 
            {
                final songPath = basePath + folder + "/";
                if (!FileSystem.isDirectory(songPath)) continue;
                
                for (file in FileSystem.readDirectory(songPath)) 
                {
                    if (!file.endsWith(".json")) continue;
                    
                    final fullPath = songPath + file;
                    final content = File.getContent(fullPath);
                    final hash = haxe.crypto.Sha256.encode(content);
                    final songKey = file.substr(0, file.length - 5);
                    final fullKey = folder + "/" + songKey;
                    
                    final resName = "chart_res_" + fullKey;
                    Context.addResource(resName, haxe.io.Bytes.ofString(content));
                    
                    mapAssignments.push(macro map.set($v{fullKey}, {resName: $v{resName}, hash: $v{hash}}));
                }
            }
        }
        #end
        
        return macro {
            var map = new haxe.ds.StringMap<{resName:String, hash:String}>();
            $b{mapAssignments};
            map;
        };
    }
}