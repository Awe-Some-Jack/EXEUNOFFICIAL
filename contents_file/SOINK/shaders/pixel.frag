#pragma header
uniform float pixelsize;

void main() {
    if (pixelsize <= 0.0) {
        gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv.xy);
    } else {
        vec2 size = openfl_TextureSize.xy / pixelsize;
        gl_FragColor = flixel_texture2D(bitmap, floor(openfl_TextureCoordv.xy * size) / size);
    }
}