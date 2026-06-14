package shaders;

import flixel.system.FlxAssets.FlxShader;

class RoundedBorderShader extends FlxShader
{
    @:glFragmentHeader('
        uniform float uRadius;
        uniform float uBorderWidth;
        uniform vec4 uBorderColor;
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
            vec4 col     = flixel_texture2D(bitmap, uv);

            vec2 pixelPos = (uv - 0.5) * uSize;
            vec2 boxHalf  = uSize * 0.5;

            float d = roundedBox(pixelPos, boxHalf, uRadius);

            if (d > 0.0) discard;

            gl_FragColor = col;
        }
    ')

    public function new(radius:Float = 8.0, borderWidth:Float = 3.0, borderColor:Int = 0xFF5C0010)
    {
        super();
        this.uRadius.value      = [radius];
        this.uBorderWidth.value = [borderWidth];
        final cr = ((borderColor >> 16) & 0xFF) / 255.0;
        final cg = ((borderColor >> 8)  & 0xFF) / 255.0;
        final cb = ( borderColor        & 0xFF) / 255.0;
        final ca = ((borderColor >> 24) & 0xFF) / 255.0;
        this.uBorderColor.value = [cr, cg, cb, ca];
        this.uSize.value        = [100.0, 56.0];
    }

    public function setSize(w:Float, h:Float):Void
    {
        this.uSize.value = [w, h];
    }
}
