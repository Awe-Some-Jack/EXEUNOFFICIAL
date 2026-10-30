// Shader by Kophy232, Remember to credit if use!
// Optimized by JustX

#pragma header
#define iResolution openfl_TextureSize
#define iChannel0 bitmap
#define texture flixel_texture2D
uniform float time;
uniform float cangle;
uniform float brightness;
uniform float contrast;
uniform float desaturation;
uniform float sharpness;
uniform float crtGammaEnabled;
uniform float lcdGammaEnabled;
uniform float crtGammaValue;
uniform float lcdGammaValue;
uniform float lightingEnabled;
uniform float lightingIntensity;
uniform float halationAmount;
uniform float horizontalGlitchAmount;
uniform float waveDistortion;
uniform float waveBarGlitch;
uniform float chromAblineal;
uniform float chromAbRadial;
uniform float pixelateAmount;
uniform float czoom;
uniform float cx;
uniform float cy;
uniform float cwarph;
uniform float cwarpv;
uniform float cuwarph;
uniform float cuwarpv;
const vec3 LUMA = vec3(0.299, 0.587, 0.114);
const mat2 HALATION_TURN = mat2(0.8660254, 0.5, -0.5, 0.8660254);

mat2 camRotation;
float camGain;
float camBias;

vec4 cam(vec2 uv) {
    if (cangle != 0.0) {
        uv = camRotation * ((clamp(uv, 0.0, 1.0) - 0.5) * iResolution.xy) / iResolution.xy + 0.5;
        if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) return vec4(0.0);
    }
    vec4 color = texture(iChannel0, uv);
    return vec4(clamp(color.rgb * camGain + camBias, 0.0, 1.0), color.a);
}

float waveNoise(vec2 n) {
    const vec2 d = vec2(0.0, 1.0);
    const vec2 k = vec2(12.9898, 4.1414);
    vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
    vec4 h = fract(sin(vec4(dot(b, k), dot(b + d.yx, k), dot(b + d.xy, k), dot(b + d.yy, k))) * 43758.5453);
    return mix(mix(h.x, h.y, f.x), mix(h.z, h.w, f.x), f.y);
}

vec4 waveBarRender(vec2 uvLocal) {
    return cam(1.0 - abs(mod(uvLocal, 2.0) - 1.0));
}

vec3 applyChromaticAberration(vec4 center, vec2 uv, float amount) {
    vec2 offset = vec2(amount * 0.01, 0.0);
    return vec3(cam(uv + offset).r, center.g, cam(uv - offset).b);
}

vec2 PincushionDistortion(in vec2 uv, float strength) {
    vec2 st = uv - 0.5;
    return 0.5 + st * (1.0 - strength * dot(st, st));
}

vec3 applyChromaticAberrationRadial(in vec2 uv, float amount) {
    return vec3(
        cam(PincushionDistortion(uv, 0.3 * amount)).r,
        cam(PincushionDistortion(uv, 0.15 * amount)).g,
        cam(PincushionDistortion(uv, 0.075 * amount)).b
    );
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 px = vec2(1.0) / iResolution.xy;
    vec2 uv = fragCoord * px;

    camGain = brightness * contrast;
    camBias = 0.5 - 0.5 * contrast;
    if (cangle != 0.0) {
        float angInRad = radians(cangle);
        camRotation = mat2(cos(angInRad), -sin(angInRad), sin(angInRad), cos(angInRad));
    }

    if (czoom != 1.0 || cx != 0.0 || cy != 0.0) {
        vec2 center = iResolution.xy * 0.5;
        vec2 centered = fragCoord - center;
        float aspectRatio = iResolution.x * px.y; // iResolution.x / iResolution.y

        vec2 normalized = centered * px.y;
        normalized.x += cx * aspectRatio;
        normalized.y += cy;
        normalized *= czoom;

        uv = (normalized * iResolution.y + center) * px;
        vec2 c = uv - 0.5;
        vec2 r2 = c * c;

        if (cuwarph != 0.0) c.x *= (1.0 + cuwarph * r2.x);
        if (cuwarpv != 0.0) c.y *= (1.0 + cuwarpv * r2.y);

        uv = 1.0 - abs(mod(c + 0.5, 2.0) - 1.0);
    }

    if (cwarph != 0.0 || cwarpv != 0.0) {
        vec2 c = uv - 0.5;
        vec2 r2 = c * c;
        if (cwarph != 0.0) c.x *= (1.0 + cwarph * r2.x);
        if (cwarpv != 0.0) c.y *= (1.0 + cwarpv * r2.y);
        uv = clamp(c + 0.5, vec2(0.0), vec2(1.0));
    }

    vec2 inputUV = uv;

    if (horizontalGlitchAmount > 0.0) {
        float lineY = fragCoord.y;
        float noiseOffset = fract(sin(floor(lineY) * 12.9898 + time * 50.0) * 43758.5453) * 2.0 - 1.0;
        float edgeFactor = 1.0 - abs(2.0 * (lineY * px.y) - 1.0);
        float displacementUV = (noiseOffset * horizontalGlitchAmount * edgeFactor * 15.0) * px.x;
        inputUV.x = clamp(uv.x + displacementUV, 0.0, 1.0);
    }

    if (pixelateAmount > 0.0) {
        float blockSize = max(1.0, min(iResolution.x, iResolution.y) * 0.01 * pixelateAmount);
        inputUV = floor((inputUV * iResolution.xy) / blockSize) * blockSize * px;
        inputUV = clamp(inputUV, vec2(0.0), vec2(1.0));
    }

    if (inputUV.x < 0.0 || inputUV.x > 1.0 || inputUV.y < 0.0 || inputUV.y > 1.0) {
        fragColor = vec4(0.0);
        return;
    }

    if (waveDistortion > 0.0) {
        vec2 offsetUV = vec2(
            waveNoise(vec2(inputUV.x, inputUV.y + time * 0.1) * 50.0),
            waveNoise(vec2(inputUV.x + 13.1, inputUV.y + time * 0.1 + 7.3) * 50.0)
        );
        offsetUV = (offsetUV * 2.0 - 1.0) * 0.001 * waveDistortion * (1.0 + inputUV.y * 2.0);
        inputUV = clamp(inputUV + offsetUV, vec2(0.0), vec2(1.0));
    }

    vec4 tex = cam(inputUV);
    if (chromAbRadial > 0.0) {
        tex.rgb = applyChromaticAberrationRadial(inputUV, chromAbRadial);
    } else if (chromAblineal > 0.0) {
        tex.rgb = applyChromaticAberration(tex, inputUV, chromAblineal);
    }

    vec3 finalColor = tex.rgb;

    if (sharpness != 0.0) {
        vec3 sharpBlur = (
            cam(inputUV + vec2( px.x, 0.0)).rgb +
            cam(inputUV + vec2(-px.x, 0.0)).rgb +
            cam(inputUV + vec2(0.0,  px.y)).rgb +
            cam(inputUV + vec2(0.0, -px.y)).rgb
        ) * 0.25;
        finalColor = mix(sharpBlur, finalColor, 1.0 + sharpness);
    }

    if (halationAmount > 0.0) {
        vec3 halation = vec3(0.0);
        float totalWeight = 0.0;
        vec2 sampleDir = vec2(1.0, 0.0);
        vec2 sampleStep = px * 4.0;
        for (int i = 0; i < 12; i++) {
            vec3 texSample = cam(inputUV + sampleDir * sampleStep).rgb;
            float lum = dot(texSample, LUMA);
            halation += texSample * lum * lum;
            totalWeight += lum * lum;
            sampleDir = HALATION_TURN * sampleDir;
        }
        if (totalWeight > 0.0) halation /= totalWeight;
        finalColor += halation * 0.7 * halationAmount;
    }

    if (lightingEnabled > 0.5) {
        vec3 lightingBlur = (
            cam(inputUV + vec2(-px.x, -px.y)).rgb +
            cam(inputUV + vec2( px.x, -px.y)).rgb +
            cam(inputUV + vec2(-px.x,  px.y)).rgb +
            cam(inputUV + vec2( px.x,  px.y)).rgb
        ) * 0.25;
        float glowMask = smoothstep(0.6, 1.0, dot(lightingBlur, LUMA));
        finalColor += lightingBlur * glowMask * lightingIntensity;
    }

    if (waveBarGlitch > 0.0) {
        vec2 uvWB = inputUV;
        uvWB.x += (waveNoise(vec2(uvWB.y, time)) - 0.5) * 0.005;
        uvWB.x += (waveNoise(vec2(uvWB.y * 1000.0, time * 10.0)) - 0.5) * 0.008;
        float barWave = sin(uvWB.y * 7.5 + time * 3.5);
        if (barWave > 0.94) {
            float barMask = clamp((barWave - 0.94) * waveNoise(vec2(time)), 0.0, 0.05);
            float barDistortion = (waveNoise(vec2(uvWB.y * 500.0, time * 15.0)) - 0.5) * 3.0;
            uvWB.x -= barMask * barDistortion;
        }

        vec4 glitchColor = waveBarRender(uvWB);
        glitchColor.rgb *= 0.5;

        const float chromaStrength = 0.002;
        glitchColor.r += waveBarRender(uvWB + vec2(-1.0, 0.0) * chromaStrength).r * 0.25;
        glitchColor.g += waveBarRender(uvWB + vec2(-2.0, 0.0) * chromaStrength).g * 0.25;
        glitchColor.b += waveBarRender(uvWB + vec2(-3.0, 0.0) * chromaStrength).b * 0.25;
        glitchColor.r += waveBarRender(uvWB + vec2( 1.0, 0.0) * chromaStrength).r * 0.25;
        glitchColor.g += waveBarRender(uvWB + vec2( 2.0, 0.0) * chromaStrength).g * 0.25;
        glitchColor.b += waveBarRender(uvWB + vec2( 3.0, 0.0) * chromaStrength).b * 0.25;

        finalColor = mix(finalColor, glitchColor.rgb, waveBarGlitch);
    }

    if (crtGammaEnabled > 0.5) finalColor = pow(finalColor, vec3(crtGammaValue));
    if (lcdGammaEnabled > 0.5) finalColor = pow(finalColor, vec3(1.0 / lcdGammaValue));

    if (desaturation > 0.0) {
        finalColor = mix(finalColor, vec3(dot(finalColor, LUMA)), desaturation);
    }

    fragColor = vec4(finalColor, tex.a);
}
void main() {
    mainImage(gl_FragColor, openfl_TextureCoordv * openfl_TextureSize);
}
