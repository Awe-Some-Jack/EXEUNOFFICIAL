// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

// Paint.NET-like RGB Curves
// Adjust these values manually.

// Where the curve starts rising.
// 0.75 = approximately the curve shown in the screenshot.
const float red   = 0.75;
const float green = 0.75;
const float blue  = 0.75;

// Controls how aggressively the curve rises.
// Lower = steeper.
// 0.18 is approximately the curve in the screenshot.
const float redPower   = 0.18;
const float greenPower = 0.18;
const float bluePower  = 0.18;

const vec3 threshold = vec3(red, green, blue);
const vec3 power = vec3(redPower, greenPower, bluePower);

void main()
{
    vec4 tex = flixel_texture2D(bitmap, openfl_TextureCoordv);
    vec3 t = max((tex.rgb - threshold) / (1.0 - threshold), 0.0);
    gl_FragColor = vec4(pow(t, power), tex.a);
}
