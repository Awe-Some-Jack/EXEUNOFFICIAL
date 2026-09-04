#pragma header

uniform float iTime;
uniform float waveAmplitude; // Default: 0.05
uniform float waveFrequency; // Default: 20.0

// Simple Perlin Noise
vec2 n22 (vec2 p)
{
    vec3 a = fract(p.xyx * vec3(123.34, 234.34, 345.65));
    a += dot(a, a + 34.45);
    return fract(vec2(a.x * a.y, a.y * a.z));
}

vec2 get_gradient(vec2 pos)
{
    float angle = n22(pos).x * 6.283185;
    return vec2(cos(angle), sin(angle));
}

float perlin_noise(vec2 uv)
{
    vec2 cell_pos_in_grid = floor(uv);
    vec2 local_pos_in_cell = fract(uv);
    
    vec2 blend = smoothstep(0.0, 1.0, local_pos_in_cell);
    
    vec2 left_bottom = cell_pos_in_grid;
    vec2 right_bottom = cell_pos_in_grid + vec2(1.0, 0.0);
    vec2 left_top = cell_pos_in_grid + vec2(0.0, 1.0);
    vec2 right_top = cell_pos_in_grid + vec2(1.0, 1.0);
    
    float left_bottom_dot = dot(uv - left_bottom, get_gradient(left_bottom));
    float right_bottom_dot = dot(uv - right_bottom, get_gradient(right_bottom));
    float left_top_dot = dot(uv - left_top, get_gradient(left_top));
    float right_top_dot = dot(uv - right_top,  get_gradient(right_top));
    
    float noise_value = mix(
        mix(left_bottom_dot, right_bottom_dot, blend.x), 
        mix(left_top_dot, right_top_dot, blend.x), 
        blend.y
    );
   
    return 0.5 + 0.7142857 * noise_value;
}

void main()
{
    vec2 uv = openfl_TextureCoordv;
    
    float noiseVal = perlin_noise(uv * waveFrequency + iTime);
    vec2 offset = vec2(noiseVal) * waveAmplitude;
    
    gl_FragColor = texture2D(bitmap, uv + offset);
}