import flixel.FlxSprite;

public class NPC extends FlxSprite {
    public var tag:String;
    public static var DEFAULT_BEATS_PER_BEATS:Int = 2;
    public var dancePerBeats:Int = DEFDAULT_BEATS_PER_BEATS;
    public var beatProgress:Int = -1;
    public var curState:String = "DANCE";
    public var NPC_STATES:Array<String> = [
        "DANCE",
        "STATIC",
        "ACTION",
    ];

    public function getIdByStateTag(t:String){
        var id = switch(t){
            case "DANCE":
                0;
            case "STATIC":
                1;
            case "ACTION":
                2;
            default:
                0;
        }
        return id;
    }

    public function getState(id:Int) {
        return NPC_STATS[id];
    }
    public var animTimer:Float = 2;

    public function new (tag:String, dancePerBeats:Int, initialState:String){
        super();

        this.tag = tag;
        this.dancePerBeats = dancePerBeats;
        this.curState = initialState; 
    }

    public function onBeatHit(beats:Int){
        beatProgress += beats;

        if (curState == "DANCE"){
            if (beats % 2 == 0){
                // danz danz danze
            }
        }
    }
}