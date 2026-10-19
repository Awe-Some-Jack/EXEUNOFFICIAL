#pragma header

uniform sampler2D texture;
uniform float scale;
uniform vec2 resol;
uniform vec2 size;
uniform float intensity;

void main() {
    vec2 uv = gl_FragCoord.xy / resol;
    
    vec2 uv2 = (uv - 0.5) * (resol / (size * scale)) + 0.5;
    vec4 bg = texture2D(bitmap, uv);

    if (uv2.x < 0.0 || uv2.y < 0.0 || uv2.x > 1.0 || uv2.y > 1.0) {
        gl_FragColor = bg;
        return;
    }

    vec4 mask = texture2D(texture, uv2);
    vec3 finalColor = mix(bg.rgb, 1.0 - (bg.rgb * intensity), mask.a * intensity);

    gl_FragColor = vec4(finalColor, bg.a);
}