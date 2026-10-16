// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
uniform float interval;

// end of ShadertoyToFlixel header

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;
    
    vec2 offsetStep = vec2(0.015, 0.015);
    int maxPopups = 50;
    
    float numPopups = floor(iTime / interval);
    numPopups = min(numPopups, float(maxPopups));
    
    vec4 finalColor = texture(iChannel0, uv);
    
    for (int i = 1; i <= maxPopups; i++) {
        if (float(i) > numPopups) break;
        
        vec2 currentOffset = offsetStep * float(i);
        
        vec2 copyUV = uv - currentOffset;
        
        if (copyUV.x >= 0.0 && copyUV.x <= 1.0 && copyUV.y >= 0.0 && copyUV.y <= 1.0) {
            vec4 copyColor = texture(iChannel0, copyUV);
            finalColor = copyColor;
        }
    }
    
    fragColor = finalColor;
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}