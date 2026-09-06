#pragma header

#define PI 3.141592653589793
#define TWO_PI (PI*2.0)

uniform float brightness;
uniform float directions;
uniform int quality;
uniform float size;

void main(void) {
    vec2 uv = openfl_TextureCoordv.xy;
    vec4 color = flixel_texture2D(bitmap, uv);

    if (brightness == 1.0 && size == 0.0) {
        gl_FragColor = color;
        return;
    }

    vec4 bloom = color;
    float fQuality = float(quality);
    float stepSize = 1.0 / fQuality;
    
    vec2 sizeInv = size / openfl_TextureSize.yx; 
    float dStep = TWO_PI / directions;
    float maxApply = directions * fQuality;

    for (float d = 0.0; d < TWO_PI; d += dStep) {
        vec2 dir = vec2(sin(d), cos(d)) * sizeInv; 
        
        for (float i = stepSize; i <= 1.0; i += stepSize) {
            vec2 movement = dir * i;
            bloom += flixel_texture2D(bitmap, uv + movement);
            bloom *= mix(1.0, 1.0 - (i / fQuality), step(0.0, movement.x) + step(0.0, movement.y));
        }
    }

    float brightnessFactor = 1.0 - (1.0 / maxApply);
    bloom /= maxApply;
    
    float brightnessApply = brightness < 1.5 ? mix(1.5, 0.0, abs(1.0 - ((brightness - 1.0) * 2.0))) : brightness;
    gl_FragColor = color + ((bloom * brightnessFactor) * brightnessApply);
}