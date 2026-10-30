#pragma header

vec2 curve(vec2 uv)
{
	uv = (uv - 0.5) * 2.2;
	uv.x *= 1.0 + uv.y * uv.y * 0.04;
	uv.y *= 1.0 + uv.x * uv.x * 0.0625;
	return uv * 0.46 + 0.5;
}

void main()
{
	vec2 uv = curve(openfl_TextureCoordv);

	vec4 center = flixel_texture2D(bitmap, uv);
	vec3 col = vec3(
		flixel_texture2D(bitmap, vec2(uv.x + 0.003, uv.y)).r,
		center.g,
		flixel_texture2D(bitmap, vec2(uv.x - 0.003, uv.y)).b
	);

	vec2 inside = step(0.0, uv) * (1.0 - step(1.0, uv));
	float shade = inside.x * inside.y * (0.5 + 8.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y)) * (0.9 + 0.1 * sin(uv.y * 700.0));

	gl_FragColor = vec4(col * shade * vec3(0.9405, 1.0395, 0.9405), center.a);
}
