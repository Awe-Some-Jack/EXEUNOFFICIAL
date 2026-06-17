import shaders.ColorSwap;

function onCreatePost()
{
    var colorSwap:ColorSwap = new ColorSwap();
    colorSwap.hue = -1;
    colorSwap.brightness = 0;
    colorSwap.saturation = -1;

    boyfriend.shader = colorSwap.shader;
    iconP2.shader = colorSwap.shader;
}