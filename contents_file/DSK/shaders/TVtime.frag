// Shader by Kophy232, Remember to credit if use!
// Optimized by JustX

#pragma header
#define iResolution openfl_TextureSize
#define iChannel0 bitmap
#define texture flixel_texture2D
uniform float time;
uniform float desaturation;
uniform float sharpness;
uniform float brightness;
uniform float crtGammaEnabled;
uniform float lcdGammaEnabled;
uniform float crtGammaValue;
uniform float lcdGammaValue;
uniform float lightingEnabled;
uniform float lightingIntensity;
uniform float halationAmount;
uniform float halationPosition;
uniform float halationClone;
uniform float contrast;
uniform float horizontalGlitchAmount;
uniform float waveDistortion;
uniform float waveBarGlitch;
uniform float chromAblineal;
uniform float chromAbRadial;
uniform float pixelateAmount;
uniform float czoom;
uniform float cangle;
uniform float cx;
uniform float cy;
uniform float cwarph;
uniform float cwarpv;
uniform float cuwarph;
uniform float cuwarpv;
const vec3 LUMA = vec3(0.299, 0.587, 0.114);

float waveRand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float waveNoise(vec2 n) {
    const vec2 d = vec2(0.0, 1.0);
    const vec2 k = vec2(12.9898, 4.1414);
    vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
    vec4 h = fract(sin(vec4(dot(b, k), dot(b + d.yx, k), dot(b + d.xy, k), dot(b + d.yy, k))) * 43758.5453);
    return mix(mix(h.x, h.y, f.x), mix(h.z, h.w, f.x), f.y);
}

vec4 waveBarRender(vec2 uvLocal) {
    vec2 wrappedUV = 1.0 - abs(mod(uvLocal, 2.0) - 1.0);
    return texture(iChannel0, wrappedUV);
}

vec3 applyChromaticAberration(sampler2D tex, vec2 uv, float amount) {
    float offset = amount * 0.01;
    float r = texture(tex, uv + vec2(offset, 0.0)).r;
    float g = texture(tex, uv).g;
    float b = texture(tex, uv - vec2(offset, 0.0)).b;
    return vec3(r, g, b);
}

vec2 PincushionDistortion(in vec2 uv, float strength) {
    vec2 st = uv - 0.5;
    float uvA = atan(st.x, st.y);
    float uvD = dot(st, st);
    return 0.5 + vec2(sin(uvA), cos(uvA)) * sqrt(uvD) * (1.0 - strength * uvD);
}

vec3 applyChromaticAberrationRadial(sampler2D tex, in vec2 uv, float amount) {
    float rChannel = texture(tex, PincushionDistortion(uv, 0.3 * amount)).r;
    float gChannel = texture(tex, PincushionDistortion(uv, 0.15 * amount)).g;
    float bChannel = texture(tex, PincushionDistortion(uv, 0.075 * amount)).b;
    return vec3(rChannel, gChannel, bChannel);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 px = vec2(1.0) / iResolution.xy;
    vec2 uv = fragCoord * px;

    if (czoom != 1.0 || cangle != 0.0 || cx != 0.0 || cy != 0.0) {
        vec2 center = iResolution.xy * 0.5;
        vec2 centered = fragCoord - center;
        float aspectRatio = iResolution.x * px.y; // iResolution.x / iResolution.y
        
        vec2 normalized = centered * px.y;
        normalized.x += cx * aspectRatio;
        normalized.y += cy;
        normalized *= czoom;
        
        if (cangle != 0.0) {
            float angInRad = radians(cangle);
            float s = sin(angInRad);
            float c_ang = cos(angInRad);
            normalized = mat2(c_ang, -s, s, c_ang) * normalized;
        }
        
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

    if (inputUV.x < 0.0 || inputUV.x > 1.0 || inputUV.y < 0.0 || inputUV.y > 1.0)
    {
        fragColor = vec4(0.0);
    }
    else
    {
        if (waveDistortion > 0.0) {
            vec2 offsetUV = vec2(
                waveNoise(vec2(inputUV.x, inputUV.y + time * 0.1) * 50.0),
                waveNoise(vec2(inputUV.x + 13.1, inputUV.y + time * 0.1 + 7.3) * 50.0)
            );
            offsetUV = (offsetUV * 2.0 - 1.0) * 0.001 * waveDistortion * (1.0 + inputUV.y * 2.0);
            inputUV = clamp(inputUV + offsetUV, vec2(0.0), vec2(1.0));
        }

        vec4 tex = texture(iChannel0, inputUV);
        if (chromAblineal > 0.0) {
            tex.rgb = applyChromaticAberration(iChannel0, inputUV, chromAblineal);
        }
        if (chromAbRadial > 0.0) {
            tex.rgb = applyChromaticAberrationRadial(iChannel0, inputUV, chromAbRadial);
        }
        
        vec3 baseColor = tex.rgb;
        vec3 sharpBlur = (
            texture(iChannel0, inputUV + vec2( px.x, 0.0)).rgb +
            texture(iChannel0, inputUV + vec2(-px.x, 0.0)).rgb +
            texture(iChannel0, inputUV + vec2(0.0,  px.y)).rgb +
            texture(iChannel0, inputUV + vec2(0.0, -px.y)).rgb
        ) * 0.25;
        
        vec3 sharpColor = mix(sharpBlur, baseColor, 1.0 + sharpness);
        vec3 halation = vec3(0.0);
        float totalWeight = 0.0;
        
        if (halationAmount > 0.0 && halationPosition > 0.0) {
            float distance = 4.0;
            if (halationPosition == 1.0) {
                const int samples = 12;
                for (int i = 0; i < samples; i++) {
                    float angle = float(i) / float(samples) * 6.2831853;
                    vec2 sampleDir = vec2(cos(angle), sin(angle));
                    vec3 texSample = texture(iChannel0, inputUV + sampleDir * px * distance).rgb;
                    float lum = dot(texSample, LUMA);
                    float falloff = max(lum, 0.0); // 1.0 - 0.0 * (1.0 - lum) simplifies to 1.0, but keeping logic
                    halation += texSample * lum * falloff;
                    totalWeight += lum * falloff;
                }
            } else {
                vec2 dir = vec2(0.0);
                if (halationPosition == 2.0 || halationPosition == 5.0) dir = normalize(inputUV - 0.5);
                else if (halationPosition == 3.0) dir = vec2(1.0, 0.0);
                else if (halationPosition == 4.0) dir = vec2(0.0, 1.0);
                else if (halationPosition == 6.0) dir = vec2(-1.0, 0.0);
                else if (halationPosition == 7.0) dir = vec2(1.0, 0.0);
                else if (halationPosition == 8.0) dir = normalize(vec2(1.0, 1.0));
                else if (halationPosition == 9.0) dir = normalize(vec2(-1.0, 1.0));
                else if (halationPosition == 10.0) dir = normalize(vec2(1.0, -1.0));
                else if (halationPosition == 11.0) dir = normalize(vec2(-1.0, -1.0));
                
                int clones = int(max(1.0, halationClone));
                for (int i = 0; i < clones; i++) {
                    float t = clones > 1 ? float(i) / float(clones - 1) : 0.0;
                    vec3 texSample = texture(iChannel0, inputUV + dir * distance * t * px).rgb;
                    float lum = dot(texSample, LUMA);
                    if (lum >= 0.4) {
                        float falloff = max(lum, 0.0);
                        halation += texSample * lum * falloff;
                        totalWeight += lum * falloff;
                    }
                }
            }
            if (totalWeight > 0.0) halation /= totalWeight;
            sharpColor += mix(vec3(0.0), halation, 0.7) * halationAmount;
        }
        
        vec3 lighting = vec3(0.0);
        if (lightingEnabled > 0.5) {
            vec3 lightingBlur = (
                texture(iChannel0, inputUV + vec2(-px.x, -px.y)).rgb +
                texture(iChannel0, inputUV + vec2( px.x, -px.y)).rgb +
                texture(iChannel0, inputUV + vec2(-px.x,  px.y)).rgb +
                texture(iChannel0, inputUV + vec2( px.x,  px.y)).rgb
            ) * 0.25;
            float brightnessValue = dot(lightingBlur, LUMA);
            float glowMask = smoothstep(0.6, 1.0, brightnessValue);
            lighting = lightingBlur * glowMask * lightingIntensity;
        }
        
        vec3 finalColor = sharpColor * brightness + lighting;
        
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
        
        finalColor = mix(vec3(0.5), finalColor, contrast);
        if (desaturation > 0.0) {
            finalColor = mix(finalColor, vec3(dot(finalColor, LUMA)), desaturation);
        }

        fragColor = vec4(finalColor, tex.a);
    }
}
void main() {
    mainImage(gl_FragColor, openfl_TextureCoordv * openfl_TextureSize);
}