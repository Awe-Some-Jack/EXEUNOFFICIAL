package states.extras;

class SonicSubState extends MusicBeatSubstate
{
    /**
     * Callback opcional que se ejecuta cuando la pantalla está 100% oscurecida antes de cerrar.
     */
    public var onBeforeClose:Void->Void;

    override public function close():Void
    {
        SonicRetroTransition.closeSubState(0.5, function() {
            if (onBeforeClose != null) onBeforeClose();
            
            // Llamamos al método auxiliar en lugar de super directamente
            _rawClose();
        });
    }

    /**
     * Método privado auxiliar para invocar el cierre nativo de FlxSubState.
     */
    private function _rawClose():Void
    {
        super.close();
    }
}