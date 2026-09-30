#pragma header

uniform float iTime;
uniform float rainIntensity;

#define ch_F vec2(2048263.0,1181728.0)
#define ch_A vec2(935188.0,780450.0)
#define ch_T vec2(2035777.0,33288.0)
#define ch_L vec2(1065220.0,133182.0)
#define ch_E vec2(2048263.0,1181758.0)
#define ch_R vec2(1983767.0,1198242.0)
#define ch_O vec2(935188.0,665756.0)

#define LX 8.0
#define LY 10.0

float rand(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453123);
}

float extractBit(float n, float b) {
    return floor(mod(floor(n / exp2(b)), 2.0));
}

float sprite(vec2 spr, vec2 p) {
    vec2 uv = floor(vec2(mod(p.x, LX), mod(p.y, LY)));
    if (uv.x < 0.0 || uv.y < 0.0 || uv.x >= 6.0 || uv.y >= 7.0) return 0.0;
    float bit = 6.0 - uv.x + uv.y * 6.0;
    return bit < 21.0 ? extractBit(spr.y, bit) : extractBit(spr.x, bit - 21.0);
}

vec2 getD(float d) {
    if (d == 0.0) return ch_F;
    if (d == 1.0) return ch_A;
    if (d == 2.0) return ch_T;
    if (d == 3.0) return ch_A;
    if (d == 4.0) return ch_L;
    if (d == 5.0) return ch_E;
    if (d == 6.0) return ch_R;
    if (d == 7.0) return ch_R;
    if (d == 8.0) return ch_O;
    if (d == 9.0) return ch_R;
    return vec2(0.0);
}

void main() {
    vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize;
    vec2 uv = vec2(fragCoord.x, openfl_TextureSize.y - fragCoord.y) / 2.0;
    vec2 block = floor(uv / vec2(LX, LY));

    float columnRandom = fract(sin(block.x * 127.1 + 311.7) * 43758.5453);
    if (columnRandom < 1.0 - rainIntensity) {
        gl_FragColor = vec4(0.0);
        return;
    }

    float columnSeed = rand(vec2(block.x, 1.234));
    float speed = 0.18 + columnSeed * 0.32;
    float rowCount = openfl_TextureSize.y / 2.0 / LY;
    float head = mod(iTime * speed * rowCount + columnSeed * rowCount, rowCount);
    float distanceFromHead = mod(head - block.y + rowCount, rowCount);

    float trailLength = 10.0 + rand(vec2(block.x, 7.31)) * 12.0;
    float visible = 1.0 - step(trailLength, distanceFromHead);
    float whiteHead = 1.0 - step(1.0, distanceFromHead);
    float redTrail = step(1.0, distanceFromHead) * visible;

    float fade = 1.0 - clamp((distanceFromHead - 1.0) / max(trailLength - 1.0, 1.0), 0.0, 1.0);
    fade *= fade;

    float charTime = floor(iTime * 8.0);
    float characterRandom = rand(block + vec2(charTime, charTime * 0.37));
    float glyph = sprite(getD(floor(characterRandom * 10.0)), uv);

    vec3 color = vec3(1.0) * whiteHead + vec3(1.0, 0.0, 0.0) * redTrail * fade;
    gl_FragColor = vec4(color * glyph, glyph);
}
