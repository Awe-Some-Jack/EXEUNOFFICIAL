// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

const float PI = 3.1415926;

const float constraint = 0.35;
float c = 0.0;
uniform float amount;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;
    vec2 suv;
    
    // distort coef: MOVE MOUSE UP & DOWN
    c = ((0.50001 * (amount + 1.0)) - 0.5) * 2.0 * PI * constraint;
    
    vec2 ndc = (uv - 0.5) * 2.0;
    float aspect = fragCoord.x / fragCoord.y;

    if (c >= 0.0) {
        float h = c;
        float hd = tan(h);

        vec2 r = vec2(aspect, 1.0);
        vec2 sndc = ndc * r;

        float dia = length(r);
        float rd = length(sndc) / dia;
        vec2 rp = normalize(sndc) / normalize(r);

        float beta = rd * h;
        vec2 proj = rp * tan(beta) / hd;
        suv = proj * 0.5 + 0.5;
    } else {
        vec2 centered = ndc * 0.5;
        suv = centered * (1.0 + c * dot(centered, centered)) + 0.5;
    }
    
    vec4 col = texture(iChannel0, suv);
    
    fragColor = vec4(col.xyz, texture(iChannel0, fragCoord / iResolution.xy).a);
}

void main() {
    mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}