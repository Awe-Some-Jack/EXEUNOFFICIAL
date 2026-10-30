// Shader by Owk06
// Edited by Raimbowcore12

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
uniform float sort;
#define iChannel0 bitmap
#define texture flixel_texture2D

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 tex = texture(iChannel0, uv);

    // Mscara
    float mask_softness = 1.4;
    float mask_threshold = 0.6;

    float f = mask_softness / 2.0;
    float a = mask_threshold - f;
    float b = mask_threshold + f;
    float average = (tex.r + tex.g + tex.b) / 3.0;
    float mask = smoothstep(a, b, average);

    float sort_threshold = 1.0 - clamp(sort / 2.6, 0.0, 1.0);
    vec2 sort_uv = vec2(uv.x, sort_threshold);

    vec2 transition_uv = uv;
    float turbulence = fract(sin(dot(vec2(transition_uv.x), vec2(12.9, 78.2))) * 437.5);
    float displacement = pow(sort, 2.0 + (sort * 2.0)) * mask * turbulence;
    transition_uv.y += displacement;

    vec4 result = tex;
    if (displacement > 0.0) {
        if (transition_uv.y > 1.0) {
            result = texture(iChannel0, sort_uv);
        } else {
            result = texture(iChannel0, transition_uv);
        }
    }

    // Mezclar progresivamente con negro segn la intensidad del sort
    float black_mix = smoothstep(1.5, 2.5, sort);
    fragColor = mix(result, vec4(0.0), black_mix);
}


void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}