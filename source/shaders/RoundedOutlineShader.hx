package shaders;

import flixel.system.FlxAssets.FlxShader;

class RoundedOutlineShader extends FlxShader
{
    @:glFragmentHeader('
        uniform float uRadius;
        uniform float uThickness;
        uniform vec4 uColor;
        uniform vec2 uSize;

        float roundedBox(vec2 p, vec2 b, float r)
        {
            vec2 q = abs(p) - b + r;
            return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
        }
    ')

    @:glFragmentSource('
        #pragma header

        void main()
        {
            vec2 uv      = openfl_TextureCoordv;
            vec2 pixelPos = (uv - 0.5) * uSize;
            vec2 boxHalf  = uSize * 0.5;

            float d = roundedBox(pixelPos, boxHalf, uRadius);

            if (d > 0.0) discard;

            float inner = roundedBox(pixelPos, boxHalf - uThickness, uRadius - uThickness);
            if (inner <= 0.0) discard;

            gl_FragColor = uColor;
        }
    ')

    public function new(radius:Float = 12.0, thickness:Float = 3.0, color:Int = 0xFF000000)
    {
        super();
        this.uRadius.value    = [radius];
        this.uThickness.value = [thickness];
        final a = ((color >> 24) & 0xFF) / 255.0;
        final r = ((color >> 16) & 0xFF) / 255.0;
        final g = ((color >> 8)  & 0xFF) / 255.0;
        final b = ( color        & 0xFF) / 255.0;
        this.uColor.value = [r, g, b, a];
        this.uSize.value  = [100.0, 100.0];
    }

    public function setSize(w:Float, h:Float):Void
    {
        this.uSize.value = [w, h];
    }
}
