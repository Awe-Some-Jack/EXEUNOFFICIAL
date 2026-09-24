package states.extras;

class SonicSubState extends MusicBeatSubstate
{
    public var onBeforeClose:Void->Void;

    override public function close():Void
    {
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