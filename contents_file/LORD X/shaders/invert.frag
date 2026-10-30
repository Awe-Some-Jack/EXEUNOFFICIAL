#pragma header

void main()
{
    vec4 camera = flixel_texture2D(bitmap, openfl_TextureCoordv);
    gl_FragColor = vec4((1.0 - camera.rgb) * camera.a, camera.a);
}

// https://www.shadertoy.com/view/dssXRl
