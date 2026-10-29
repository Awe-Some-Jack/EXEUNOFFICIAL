import flixel.FlxSprite;

public class NPC extends FlxSprite {
    public var tag:String;
    public static var DEFAULT_BEATS_PER_BEATS:Int = 2;
    public var dancePerBeats:Int = DEFDAULT_BEATS_PER_BEATS;
    public var beatProgress:Int = -1;

    // for now, default states are DANCE, STATIC, ACTION
    public var curState:String = "DANCE";
   
    public var animTimer:Float = 2;

    public function new (tag:String, dancePerBeats:Int, initialState:String){
        super();

        this.tag = tag;
        this.dancePerBeats = dancePerBeats;
        this.curState = initialState; 
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        animTimer -= elapsed;
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