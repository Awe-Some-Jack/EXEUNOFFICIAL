#pragma header

uniform float contrast;

void main()
{
	vec4 color = texture2D(bitmap, openfl_TextureCoordv);
	color.rgb = (color.rgb - 0.5) * (1.0 + contrast) + 0.5;
	gl_FragColor = color;
}
