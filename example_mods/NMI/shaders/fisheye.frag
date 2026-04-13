// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

const float PI = 3.1415926;

const float constraint = 0.35f;
float c = 0.0f;
uniform float amount;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;
    vec2 suv;
    
    // distort coef: MOVE MOUSE UP & DOWN
    c = ((0.50001 * (amount + 1.0)) - 0.5f) * 2.0 * PI * constraint;
    
    vec2 ndc = (uv - 0.5f) * 2.0f;
    float aspect = fragCoord.x / fragCoord.y;

    if (c >= 0.0f) {
        float h = c;
        float hd = tan(h);

        vec2 r = vec2(aspect, 1.0f);
        vec2 sndc = ndc * r;

        float dia = length(r);
        float rd = length(sndc) / dia;
        vec2 rp = normalize(sndc) / normalize(r);

        float beta = rd * h;
        vec2 proj = rp * tan(beta) / hd;
        suv = proj * 0.5f + 0.5f;
    } else {
        float dx, dy, rr, r2, theta;
        rr = sqrt(dot(ndc, ndc) * 0.25f);
        r2 = rr * (1.0f + c * (rr * rr));
        theta = atan(ndc.x * 0.5f, ndc.y * 0.5f);
        dx = sin(theta) * r2;
        dy = cos(theta) * r2;
        suv = vec2(dx, dy) + 0.5f;
    }
    
    vec4 col = texture(iChannel0, suv);
    
    fragColor = vec4(col.xyz, texture(iChannel0, fragCoord / iResolution.xy).a);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}