// Shader by Kophy232, Remember to credit if use!

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

float waveRand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}
float waveNoise(vec2 n) {
    const vec2 d = vec2(0.0, 1.0);
    vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
    return mix(
        mix(waveRand(b), waveRand(b + d.yx), f.x),
        mix(waveRand(b + d.xy), waveRand(b + d.yy), f.x),
        f.y
    );
}
float waveBarRand(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}
vec4 waveBarRender(vec2 uvLocal) {
    if ((uvLocal.x > 1.0 || uvLocal.x < 0.0) && abs(mod(uvLocal.x, 2.0)) > 1.0)
        uvLocal.x = (0.0 - uvLocal.x) + 1.0;
    if ((uvLocal.y > 1.0 || uvLocal.y < 0.0) && abs(mod(uvLocal.y, 2.0)) > 1.0)
        uvLocal.y = (0.0 - uvLocal.y) + 1.0;
    return texture(iChannel0, vec2(abs(mod(uvLocal.x, 1.0)), abs(mod(uvLocal.y, 1.0))));
}
float waveBarNoise(vec2 p) {
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u * u * (3.0 - 2.0 * u);
    float res = mix(
        mix(waveBarRand(ip), waveBarRand(ip + vec2(1.0, 0.0)), u.x),
        mix(waveBarRand(ip + vec2(0.0, 1.0)), waveBarRand(ip + vec2(1.0, 1.0)), u.x),
        u.y
    );
    return res * res;
}
vec3 applyChromaticAberration(sampler2D tex, vec2 uv, float amount) {
    float rOffset = amount * 0.01;
    float bOffset = -amount * 0.01;
    float r = texture(tex, uv + vec2(rOffset, 0.0)).r;
    float g = texture(tex, uv).g;
    float b = texture(tex, uv + vec2(bOffset, 0.0)).b;
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
    vec2 uv = fragCoord / iResolution.xy;
    vec2 dc = abs(0.5 - uv);
    dc *= dc;
    if (czoom != 1.0 || cangle != 0.0 || cx != 0.0 || cy != 0.0) {
        vec2 pixelCoord = fragCoord;
        vec2 center = iResolution.xy * 0.5;
        vec2 centered = pixelCoord - center;
        float aspectRatio = iResolution.x / iResolution.y;
        vec2 normalized = centered / iResolution.y;
        normalized.x += cx * aspectRatio;
        normalized.y += cy;
        normalized *= czoom;
        float combinedAngle = cangle;
        if (combinedAngle != 0.0) {
            float angInRad = radians(combinedAngle);
            mat2 rotation = mat2(
                cos(angInRad), -sin(angInRad),
                sin(angInRad),  cos(angInRad)
            );
            normalized = rotation * normalized;
        }
        vec2 finalCoord = normalized * iResolution.y + center;
        uv = finalCoord / iResolution.xy;
        vec2 c = uv - 0.5;
        float r2 = dot(c, c);
        if (cuwarph != 0.0) {
            float r2 = c.x * c.x;
            c.x *= (1.0 + cuwarph * r2);
        }
        if (cuwarpv != 0.0) {
            float r2 = c.y * c.y;
            c.y *= (1.0 + cuwarpv * r2);
        }
        uv = c + 0.5;
        uv.x = mod(uv.x, 2.0);
        if (uv.x > 1.0) uv.x = 2.0 - uv.x;
        uv.y = mod(uv.y, 2.0);
        if (uv.y > 1.0) uv.y = 2.0 - uv.y;
    }
    if (cwarph != 0.0 || cwarpv != 0.0)
    {
        vec2 c = uv - 0.5;
        float r2 = dot(c, c);
        if (cwarph != 0.0) {
            float r2x = c.x * c.x;
            c.x *= (1.0 + cwarph * r2x);
        }
        if (cwarpv != 0.0) {
            float r2y = c.y * c.y;
            c.y *= (1.0 + cwarpv * r2y);
        }
        uv = c + 0.5;
        uv = clamp(uv, vec2(0.0), vec2(1.0));
    }
    vec2 inputUV = uv;
    if (horizontalGlitchAmount > 0.0) {
        float screenHeight = iResolution.y;
        float lineY = fragCoord.y;
        float lineIndex = floor(lineY);
        float noiseOffset = fract(sin(lineIndex * 12.9898 + time * 50.0) * 43758.5453) * 2.0 - 1.0;
        float edgeFactor = 1.0 - abs(2.0 * (lineY / screenHeight) - 1.0);
        float displacementPixels = noiseOffset * horizontalGlitchAmount * edgeFactor * 15.0;
        float displacementUV = displacementPixels / iResolution.x;
        inputUV = uv + vec2(displacementUV, 0.0);
        inputUV.x = clamp(inputUV.x, 0.0, 1.0);
    }
    if (pixelateAmount > 0.0) {
        vec2 pixelCoord = inputUV * iResolution.xy;
        float blockSize = max(1.0, min(iResolution.x, iResolution.y) * 0.01 * pixelateAmount);
        float blockX = floor(pixelCoord.x / blockSize) * blockSize;
        float blockY = floor(pixelCoord.y / blockSize) * blockSize;
        inputUV = vec2(blockX, blockY) / iResolution.xy;
        inputUV = clamp(inputUV, vec2(0.0), vec2(1.0));
    }

    if (inputUV.x < 0.0 || inputUV.x > 1.0 || inputUV.y < 0.0 || inputUV.y > 1.0)
    {
        fragColor = vec4(0.0);
    }
    else
    {
        vec2 px = vec2(1.0) / iResolution.xy;
        vec4 tex = texture(iChannel0, inputUV);
        if (chromAblineal > 0.0) {
            tex.rgb = applyChromaticAberration(iChannel0, inputUV, chromAblineal);
        }
        if (chromAbRadial > 0.0) {
            tex.rgb = applyChromaticAberrationRadial(iChannel0, inputUV, chromAbRadial);
        }
        if (waveDistortion > 0.0) {
            vec2 waveUV = inputUV;
            vec2 offsetUV = vec2(
                waveNoise(vec2(waveUV.x, waveUV.y + time * 0.1) * 50.0),
                waveNoise(vec2(waveUV.x + 13.1, waveUV.y + time * 0.1 + 7.3) * 50.0)
            );
            offsetUV -= vec2(0.5, 0.5);
            offsetUV *= 2.0;
            offsetUV *= 0.001 * waveDistortion;
            offsetUV *= (1.0 + waveUV.y * 2.0);
            vec2 distortedUV = waveUV + offsetUV;
            inputUV = clamp(distortedUV, vec2(0.0), vec2(1.0));
            tex = texture(iChannel0, inputUV);
            if (chromAblineal > 0.0) {
                tex.rgb = applyChromaticAberration(iChannel0, inputUV, chromAblineal);
            }
            if (chromAbRadial > 0.0) {
                tex.rgb = applyChromaticAberrationRadial(iChannel0, inputUV, chromAbRadial);
            }
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
            vec2 center = vec2(0.5);
            vec2 dir = vec2(0.0);
            float distance = 4.0;
            if (halationPosition == 1.0) {
                const int samples = 12;
                for (int i = 0; i < samples; i++) {
                    float angle = float(i) / float(samples) * 6.2831853;
                    vec2 sampleDir = vec2(cos(angle), sin(angle));
                    vec2 sampleUV = inputUV + sampleDir * px * distance;
                    vec3 texSample = texture(iChannel0, sampleUV).rgb;
                    float lum = dot(texSample, vec3(0.299, 0.587, 0.114));
                    float falloff = 1.0 - 0.0 * (1.0 - lum);
                    falloff = max(falloff, 0.0);
                    halation += texSample * lum * falloff;
                    totalWeight += lum * falloff;
                }
            } else {
                if (halationPosition == 2.0 || halationPosition == 5.0) {
                    dir = normalize(inputUV - center);
                } else if (halationPosition == 3.0) {
                    dir = vec2(1.0, 0.0);
                } else if (halationPosition == 4.0) {
                    dir = vec2(0.0, 1.0);
                } else if (halationPosition == 6.0) {
                    dir = vec2(-1.0, 0.0);
                } else if (halationPosition == 7.0) {
                    dir = vec2(1.0, 0.0);
                } else if (halationPosition == 8.0) {
                    dir = normalize(vec2(1.0, 1.0));
                } else if (halationPosition == 9.0) {
                    dir = normalize(vec2(-1.0, 1.0));
                } else if (halationPosition == 10.0) {
                    dir = normalize(vec2(1.0, -1.0));
                } else if (halationPosition == 11.0) {
                    dir = normalize(vec2(-1.0, -1.0));
                }
                int clones = int(halationClone);
                if (clones <= 0) clones = 1;
                for (int i = 0; i < clones; i++) {
                    float t = float(i) / float(clones - 1);
                    vec2 offsetVec = dir * distance * t * px;
                    vec2 sampleUV = inputUV + offsetVec;
                    vec3 texSample = texture(iChannel0, sampleUV).rgb;
                    float lum = dot(texSample, vec3(0.299, 0.587, 0.114));
                    if (lum >= 0.4) {
                        float falloff = 1.0 - 0.0 * (1.0 - lum);
                        falloff = max(falloff, 0.0);
                        halation += texSample * lum * falloff;
                        totalWeight += lum * falloff;
                    }
                }
            }
            if (totalWeight > 0.0) {
                halation /= totalWeight;
            }
            vec3 halationMix = mix(vec3(0.0), halation, 0.7);
            sharpColor += halationMix * halationAmount;
        }
        vec3 lighting = vec3(0.0);
        if (lightingEnabled > 0.5)
        {
            vec3 lightingBlur = (
                texture(iChannel0, inputUV + vec2(-px.x, -px.y)).rgb +
                texture(iChannel0, inputUV + vec2( px.x, -px.y)).rgb +
                texture(iChannel0, inputUV + vec2(-px.x,  px.y)).rgb +
                texture(iChannel0, inputUV + vec2( px.x,  px.y)).rgb
            ) * 0.25;
            float brightnessValue = dot(lightingBlur, vec3(0.299, 0.587, 0.114));
            float glowMask = smoothstep(0.6, 1.0, brightnessValue);
            lighting = lightingBlur * glowMask * lightingIntensity;
        }
        vec3 finalColor = sharpColor * brightness + lighting;
        if (waveBarGlitch > 0.0) {
            vec2 uvWB = inputUV;
            vec4 originalColor = waveBarRender(uvWB);
            uvWB.x += (waveBarNoise(vec2(uvWB.y, time)) - 0.5) * 0.005;
            uvWB.x += (waveBarNoise(vec2(uvWB.y * 1000.0, time * 10.0)) - 0.5) * 0.008;
            const float barC = 7.5;
            const float barSpeed = 3.5;
            const float barHeight = 0.06;
            float barWave = sin(uvWB.y * barC - (-time * barSpeed));
            float barMask = clamp((barWave - (1.0 - barHeight)) * waveBarNoise(vec2(time)), 0.0, 0.05);
            float barDistortion = (waveBarNoise(vec2(uvWB.y * 500.0, time * 15.0)) - 0.5) * 3.0;
            uvWB.x -= barMask * barDistortion;
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
        if (crtGammaEnabled > 0.5)
            finalColor = pow(finalColor, vec3(crtGammaValue));
        if (lcdGammaEnabled > 0.5)
            finalColor = pow(finalColor, vec3(1.0 / lcdGammaValue));
        finalColor = mix(vec3(0.5), finalColor, contrast);
        if (desaturation > 0.0) {
            float luminance = dot(finalColor, vec3(0.299, 0.587, 0.114));
            finalColor = mix(finalColor, vec3(luminance), desaturation);
        }

        fragColor = vec4(finalColor, tex.a);
    }
}
void main() {
    mainImage(gl_FragColor, openfl_TextureCoordv * openfl_TextureSize);
}