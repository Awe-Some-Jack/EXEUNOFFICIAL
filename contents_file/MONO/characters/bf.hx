import shaders.ColorSwap;

function onCreatePost()
{
    var colorSwap:ColorSwap = new ColorSwap();
    colorSwap.hue = -1;
    colorSwap.brightness = -0.075;
    colorSwap.saturation = -1;

    boyfriend.shader = colorSwap.shader;
}