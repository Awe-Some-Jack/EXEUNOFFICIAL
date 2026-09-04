#pragma header

uniform float AMT; //0 - 1 glitch amount
uniform float SPEED; //0 - 1 speed
uniform float iTime;

// Wave parameters
uniform float wVel;
uniform float wIntensity;

//2D (returns 0 - 1)
float random2d(vec2 n) { 
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

void main()
{
    float time = floor(iTime * SPEED * 60.0);    
    vec2 uv = openfl_TextureCoordv;
    
    // Wave distortion
    uv += 0.01 * sin(vec2(0.5 * wVel) * (5.5 * iTime) + length(uv) * (10.0 * wIntensity));
    
    vec4 outCol = texture2D(bitmap, uv);
    
    if (outCol.a > 0.0) {
        float maxOffset = AMT * 0.5;
        float limit = 10.0 * AMT;
        
        float finalOffset = 0.0;
        bool hit = false;
        
        for (float i = 0.0; i < 10.0; i += 1.0) {
            if (i >= limit) break;
            
            float sliceY = random2d(vec2(time, 2345.0 + i));
            float sliceH = random2d(vec2(time, 9035.0 + i)) * 0.25;
            
            if (uv.y >= sliceY && uv.y < fract(sliceY + sliceH)) {
                finalOffset = mix(-maxOffset, maxOffset, random2d(vec2(time, 9625.0 + i)));
                hit = true;
            }
        }
        
        if (hit) {
            outCol = texture2D(bitmap, vec2(uv.x + finalOffset, uv.y));
        }
        
        // Channel glitch offset
        float rnd = random2d(vec2(time, 9545.0));
        float maxColOffset = AMT * 0.16666667;
        
        vec2 colOffset = vec2(
            mix(-maxColOffset, maxColOffset, random2d(vec2(time, 9545.0))), 
            mix(-maxColOffset, maxColOffset, random2d(vec2(time, 7205.0)))
        );
        
        if (rnd < 0.33) {
            outCol.r = texture2D(bitmap, uv + colOffset).r;
        } else if (rnd < 0.66) {
            outCol.g = texture2D(bitmap, uv + colOffset).g;
        } else {
            outCol.b = texture2D(bitmap, uv + colOffset).b;  
        }
    }
    
    gl_FragColor = outCol;
}