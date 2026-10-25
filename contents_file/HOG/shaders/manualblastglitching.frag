#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
uniform float sort;
#define iChannel0 bitmap
#define texture flixel_texture2D

#define PI 3.14159265358979323846

// ============================================================
// CONFIGURACION DEL GLITCH
// ============================================================

const float DECIMATE_AMOUNT = 0.14;
const float DECIMATE_SPEED = 1.0;
const float DECIMATE_SCALE = 1.0;
const float DECIMATE_SEED = 123.45;

const float GLITCH_AMOUNT = 0.04;
const float GLITCH_SCALE = 2.0;
const float GLITCH_COLOR_SPLIT = 0.0;
const float GLITCH_SPEED = 2.0;

const float WOBBLE_STRENGTH = 0.01;
const float WOBBLE_SIZE = 1.5;
const float WOBBLE_SPEED = 6.0;

const float SLICE_AMOUNT = 0.0025;
const float SLICE_COUNT = 200.0;
const float SLICE_ANGLE = 0.0;
const float SLICE_VERT_SPEED = 5.0;
const float SLICE_HORIZ_SPEED = 15.0;

const float SHARPEN_AMOUNT = 0.11;
const float SHARPEN_SPREAD = 0.49;

// ============================================================
// CONFIGURACION DE PSEUDO
// ============================================================

const float maskLow = 0.6 - 0.7;
const float maskHigh = 0.6 + 0.7;

// ============================================================
// RUIDO
// ============================================================

float random2d(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float random1d(float n) {
    return fract(sin(n) * 43758.5453);
}

vec2 getRndOffset(vec2 uv, float time, float chunks, float st) {
    vec2 cell = floor(uv * chunks) / chunks;
    float nfield = pow(random2d(cell * 157.31 + floor(time * 30.0)), 3.0);

    vec2 off = vec2(
        random2d(cell * st),
        random2d(cell * st * 84.86)
    ) - 0.5;

    return off * (1.6 / chunks) * nfield;
}

// ============================================================
// DISTORSION MANUALBLASTGLITCHING
// ============================================================

vec2 getWarpedUV(vec2 uv) {
    vec2 p = uv;

    // DECIMATE
    float t = iTime * DECIMATE_SPEED * 2.0 + DECIMATE_SEED;
    float st = floor(t * 30.0);

    vec2 dUV = (p - 0.5) * (DECIMATE_SCALE * 2.0) + 0.5;
    vec2 d1 = getRndOffset(dUV, t, 10.0, st);
    vec2 d2 = getRndOffset(dUV, t, 25.0, st);

    p += mix(d1, d2, 0.5) * DECIMATE_AMOUNT * 2.0;

    // CELL GLITCH
    float scale2 = mix(0.1, 4.0, GLITCH_SCALE);
    float stepTime = floor(iTime * GLITCH_SPEED * 240.0);

    vec2 gp = fract((p - 0.5) * scale2 + 0.5);
    float cells = 6.0 * scale2;
    vec2 cell = floor(p * cells) / cells;

    float cellId = cell.x * cells + cell.y;
    float seed = random1d(stepTime + cellId);
    float sx = random1d(stepTime + 62.97) * 2.0 - 1.0;
    float sy = random1d(stepTime + 93.97) * 2.0 - 1.0;

    vec2 noiseUV = gp * seed * seed;
    vec2 normal = vec2(
        random2d(noiseUV),
        random2d(noiseUV + 17.31)
    ) - 0.5;

    p += normal * vec2(sx, sy) * (seed / 5.0) * GLITCH_AMOUNT;

    // WOBBLE
    vec2 wp = (p - 0.5) * 2.0;
    float pos = iTime * 6.28318530718 * WOBBLE_SPEED
              + 694.48
              + length(wp * WOBBLE_SIZE * 20.0);

    p += WOBBLE_STRENGTH * 0.05 * vec2(cos(pos), sin(pos));

    // HORIZONTAL SLICES
    float rad = SLICE_ANGLE * 0.01745329252;
    mat2 rot = mat2(
        cos(rad), -sin(rad),
        sin(rad),  cos(rad)
    );

    vec2 sp = rot * (p - 0.5) + 0.5;
    float slice = floor(sp.y * SLICE_COUNT);

    float shift = sin(iTime * SLICE_HORIZ_SPEED + slice * 2.3)
                * cos(iTime * SLICE_VERT_SPEED + slice * 1.1);

    p.x += shift * SLICE_AMOUNT;
    return p;
}

// ============================================================
// SHADER PRINCIPAL: PSEUDO + MANUALBLASTGLITCHING
// ============================================================

void main() {
    vec2 uv = openfl_TextureCoordv;
    vec4 original = texture(iChannel0, uv);

    // Transicion PSEUDO
    if (sort <= 0.0 || iTime < 0.0) {
        vec2 p = getWarpedUV(uv);
        vec4 color = texture(iChannel0, p);

        // Sharpen
        vec2 texel = 1.0 / openfl_TextureSize;
        vec2 off = texel * SHARPEN_SPREAD * 2.0;
        vec4 neighbors =
            texture(iChannel0, p + vec2(0.0, off.y)) +
            texture(iChannel0, p - vec2(0.0, off.y)) +
            texture(iChannel0, p + vec2(off.x, 0.0)) +
            texture(iChannel0, p - vec2(off.x, 0.0));
        neighbors *= 0.25;

        // Aberracion cromatica opcional
        if (GLITCH_COLOR_SPLIT > 0.0) {
            float t = floor(iTime * GLITCH_SPEED * 240.0);
            float angle = random2d(floor(p * 48.0) + t) * 2.0 * PI;
            vec2 chroma = GLITCH_AMOUNT * GLITCH_COLOR_SPLIT * 0.1
                        * vec2(cos(angle), sin(angle));
            color.r = texture(iChannel0, p + chroma).r;
            color.b = texture(iChannel0, p - chroma).b;
        }

        gl_FragColor = color + (color - neighbors) * (SHARPEN_AMOUNT * 5.0);
        return;
    }

    float blackMix = smoothstep(1.5, 2.5, sort);
    if (blackMix >= 1.0) {
        gl_FragColor = vec4(0.0);
        return;
    }

    float mask = smoothstep(maskLow, maskHigh,
                            (original.r + original.g + original.b) / 3.0);
    float turbulence = fract(sin(dot(vec2(uv.x), vec2(12.9, 78.2))) * 437.5);

    vec2 transitionUV = vec2(
        uv.x,
        uv.y + pow(sort, 2.0 + (sort * 2.0)) * mask * turbulence
    );
    vec2 sortUV = vec2(uv.x, 1.0 - clamp(sort / 2.6, 0.0, 1.0));

    // Aplicar la distorsion sobre las coordenadas de la transicion.
    vec2 transitionBaseUV = transitionUV.y > 1.0 ? sortUV : transitionUV;
    vec2 p = getWarpedUV(transitionBaseUV);

    vec4 color = texture(iChannel0, p);

    // Aberracion cromatica opcional
    if (GLITCH_COLOR_SPLIT > 0.0) {
        float t = floor(iTime * GLITCH_SPEED * 240.0);
        float angle = random2d(floor(p * 48.0) + t) * 2.0 * PI;
        vec2 chroma = GLITCH_AMOUNT * GLITCH_COLOR_SPLIT * 0.1
                    * vec2(cos(angle), sin(angle));
        color.r = texture(iChannel0, p + chroma).r;
        color.b = texture(iChannel0, p - chroma).b;
    }

    // Sharpen
    vec2 texel = 1.0 / openfl_TextureSize;
    vec2 off = texel * SHARPEN_SPREAD * 2.0;
    vec4 neighbors =
        texture(iChannel0, p + vec2(0.0, off.y)) +
        texture(iChannel0, p - vec2(0.0, off.y)) +
        texture(iChannel0, p + vec2(off.x, 0.0)) +
        texture(iChannel0, p - vec2(off.x, 0.0));
    neighbors *= 0.25;

    vec4 sharpened = color + (color - neighbors) * (SHARPEN_AMOUNT * 5.0);
    gl_FragColor = mix(sharpened, vec4(0.0), blackMix);
}
