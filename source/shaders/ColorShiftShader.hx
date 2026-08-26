package shaders;

import flixel.system.FlxAssets.FlxShader;

class ColorShiftShader extends FlxShader {
    @:glFragmentSource('
        #pragma header
        uniform float progress;

        void main() {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

            vec3 blueTint = vec3(color.r * 0.15, color.g * 0.45, color.b * 1.35);
            
            float toBlue = smoothstep(0.0, 0.5, progress);
            float toBlack = smoothstep(0.5, 1.0, progress);

            vec3 finalColor = mix(color.rgb, blueTint, toBlue);
            finalColor = mix(finalColor, vec3(0.0), toBlack);

            gl_FragColor = vec4(finalColor, color.a);
        }
    ')
    public function new() {
        super();
        progress.value = [0.0];
    }
}