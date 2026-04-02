#pragma header

uniform vec3 tint;
uniform bool invert;
uniform vec3 borderTint;
uniform float lowerBound;
uniform float upperBound;

void main() {
    vec4 textureColor = texture2D(bitmap, openfl_TextureCoordv);
    
    float gray = 0.21 * textureColor.r + 0.71 * textureColor.g + 0.07 * textureColor.b;
    float outColor = 0.;
    if(gray > upperBound){
        outColor = 1.;
    } else if(!(gray < lowerBound) && (upperBound - lowerBound) != 0) {
        outColor = (gray - lowerBound) / (upperBound - lowerBound);
    }

    if(invert){
        outColor = (1. - outColor);
    }

    gl_FragColor = vec4(mix(tint, borderTint, outColor) * textureColor.rgb, textureColor.a);
}