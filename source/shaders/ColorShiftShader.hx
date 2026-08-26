package shaders;

import flixel.system.FlxAssets.FlxShader;

class ColorShiftShader extends FlxShader {
    @:glFragmentSource('
        #pragma header
        uniform float progress;

        void main() {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
            
            float steps = 5.0;
            float p = floor(progress * steps) / steps;
            
            vec3 blueTint = vec3(color.r * 0.1, color.g * 0.4, color.b * 1.3);
            vec3 finalColor = mix(color.rgb, blueTint, p);
            
            finalColor *= (1.0 - p);
            
            gl_FragColor = vec4(finalColor, color.a);
        }
    ')
    public function new() {
        super();
        progress.value = [0.0];
    }
}