// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

// Paint.NET-like RGB Curves
// Adjust these values manually.

// Where the curve starts rising.
// 0.75 = approximately the curve shown in the screenshot.
float red   = 0.75;
float green = 0.75;
float blue  = 0.75;

// Controls how aggressively the curve rises.
// Lower = steeper.
// 0.18 is approximately the curve in the screenshot.
float redPower   = 0.18;
float greenPower = 0.18;
float bluePower  = 0.18;


float curve(float color, float threshold, float power)
{
    // Everything below the threshold becomes black.
    if (color <= threshold)
        return 0.0;

    // Remap threshold -> 0 and 1 -> 1
    float t = (color - threshold) / (1.0 - threshold);

    // Apply the curve
    return pow(t, power);
}


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    vec4 tex = texture(iChannel0, uv);

    float r = curve(tex.r, red, redPower);
    float g = curve(tex.g, green, greenPower);
    float b = curve(tex.b, blue, bluePower);

    fragColor = vec4(r,  g,  b, texture(iChannel0, fragCoord / iResolution.xy).a);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}