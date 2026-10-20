#pragma header

#ifdef GL_ES
precision mediump float;
#define HP highp
#else
#define HP
#endif

uniform float binaryIntensity;
uniform float negativity;

#define texture flixel_texture2D

void main() {
    HP vec2 uv = openfl_TextureCoordv;

    HP float psize = 0.04 * binaryIntensity;
    HP float psq = 1.0 / psize;

    HP vec2 p = floor(uv * psq + 0.5) * psize;
    vec4 colSnap = texture2D(bitmap, p);

    float lum = pow(1.0 - dot(colSnap.rgb, vec3(0.3333333)), binaryIntensity);

    HP float qsize = psize * lum;
    HP vec2 q = floor(uv / qsize + 0.5) * qsize;

    HP vec2 r = (p - q) * lum + uv;
    vec4 mColor = texture(bitmap, r);

    vec4 inverted = vec4(1.0 - mColor.rgb, 1.0) * mColor.a;
    gl_FragColor = mix(mColor, inverted, negativity);
}
