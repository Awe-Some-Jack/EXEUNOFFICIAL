package states.extras;

class SonicSubState extends MusicBeatSubstate
{
    public var onBeforeClose:Void->Void;
    var _closing:Bool = false;

    override public function close():Void
    {
        if(_closing) return;
        
        _closing = true;
        SonicRetroTransition.closeSubState(0.5, function() {
            if (onBeforeClose != null) onBeforeClose();
            
            _rawClose();
        });
    }

    private function _rawClose():Void
    {
        super.close();
    }
}