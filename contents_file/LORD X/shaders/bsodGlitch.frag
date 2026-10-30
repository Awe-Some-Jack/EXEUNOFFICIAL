#pragma header
uniform float uTime;
uniform float uIntensity;

float hash(vec2 p)
{
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void main()
{
    vec2 uv = openfl_TextureCoordv;
    float amount = clamp(uIntensity, 0.0, 1.0);
    float tick = floor(uTime * 20.0);

    float bands = floor(mix(10.0, 40.0, hash(vec2(tick, 1.0))));
    float band = floor(uv.y * bands);
    float bandNoise = hash(vec2(band, tick));
    float bandPick = hash(vec2(band, tick + 3.0));

    vec2 coord = uv;
    if (bandNoise > 1.0 - amount * 0.6)
        coord.x += (hash(vec2(band, tick + 5.0)) - 0.5) * 0.4 * amount;
    if (bandPick > 1.0 - amount * 0.12)
        coord.y = (band + hash(vec2(band, tick + 7.0))) / bands;

    vec2 cell = floor(uv * vec2(24.0, 14.0));
    if (hash(cell + vec2(tick * 1.7, tick)) > 1.0 - amount * 0.18)
        coord += (vec2(hash(cell + tick), hash(cell - tick)) - 0.5) * 0.2 * amount;

    if (hash(vec2(tick, 9.0)) > 1.0 - amount * 0.12)
        coord.y += (hash(vec2(tick, 4.0)) - 0.5) * amount;

    coord = fract(coord);
    float split = amount * (0.003 + 0.025 * hash(vec2(band, tick + 2.0)));

    vec4 center = flixel_texture2D(bitmap, coord);
    vec4 col = vec4(
        flixel_texture2D(bitmap, fract(coord + vec2(split, 0.0))).r,
        center.g,
        flixel_texture2D(bitmap, fract(coord - vec2(split, 0.0))).b,
        center.a
    );

    if (bandNoise > 1.0 - amount * 0.25)
    {
        float levels = mix(32.0, 4.0, amount);
        col.rgb = floor(col.rgb * levels + 0.5) / levels;
    }
    if (bandNoise > 1.0 - amount * 0.14)
        col.rgb = bandPick > 0.5 ? col.brg : col.gbr;
    if (bandNoise > 1.0 - amount * 0.05)
        col.rgb = col.a - col.rgb;

    float scan = 1.0 - amount * 0.18 * step(0.5, fract(uv.y * openfl_TextureSize.y * 0.5));
    float grain = (hash(uv * openfl_TextureSize + tick) - 0.5) * 0.18 * amount;
    col.rgb = clamp(col.rgb * scan + grain * col.a, 0.0, col.a);

    gl_FragColor = col;
}
