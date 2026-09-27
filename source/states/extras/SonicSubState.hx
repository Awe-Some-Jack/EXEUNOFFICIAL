package states.extras;

class SonicSubState extends MusicBeatSubstate
{
    public var onBeforeClose:Void->Void;
    var _closing:Bool = false;

    override public function close():Void
    {
        if(_closing) return;
        
        _closing = true;
        final started = SonicRetroTransition.closeSubState(0.5, function() {
            if (onBeforeClose != null) onBeforeClose();

            _rawClose();
        });

        // transition was busy, let back work again instead of locking up
        if (!started) _closing = false;
    }

    private function _rawClose():Void
    {
        super.close();
    }
}