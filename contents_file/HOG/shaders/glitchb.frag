#pragma header
#define TILE_SIZE 32.0

uniform float iTime;
uniform vec2 iResolution;
uniform float Amount;

/* ---------- util ---------- */

float rand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 posterize(vec3 c, float steps) {
    return floor(c * steps) / steps;
}

/* ---------- main ---------- */

void main() {
    vec2 uv = openfl_TextureCoordv;

    if (Amount <= 0.0) {
        gl_FragColor = flixel_texture2D(bitmap, uv);
        return;
    }

    /* --- tile index --- */
    float tileY = floor(uv.y * iResolution.y / TILE_SIZE);
    float tileX = floor(uv.x * iResolution.x / TILE_SIZE);

    /* --- stepped time (NO wave) --- */
    float t = floor(iTime * 24.0);

    /* --- per-tile random --- */
    float shiftx = rand(vec2(tileY, t));
    float shifty = rand(vec2(tileX + 17.0, t));

    vec2 pixel = 1.0 / iResolution;

    /* --- tile glitch offset --- */
    vec2 glitch = (pixel - pixel / 2.0)
        * vec2(shiftx, shifty)
        * (40.0 + 80.0 * Amount)
        * Amount;

    vec4 col = flixel_texture2D(bitmap, uv + glitch);

    /* --- hard posterize preserved --- */
    float steps = max(4.0, floor(256.0 * (1.0 - Amount) + 4.0));
    col.rgb = posterize(col.rgb, steps);

    gl_FragColor = col;
}