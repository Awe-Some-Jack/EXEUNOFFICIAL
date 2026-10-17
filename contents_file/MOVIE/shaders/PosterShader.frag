#pragma header

uniform float mode;
uniform vec4 uFrameBounds;
uniform float angOffset;
uniform vec3 rimColor;
uniform float rimWidth;
uniform float rimStrength;
uniform float glowWidth;
uniform float lightAng;
uniform float bodyLight;
uniform float thick;
uniform float hold;
uniform float pulse;
uniform float iTime;
uniform float amount;
uniform float split;
uniform float glitch;
uniform float vignette;
uniform float strength;
uniform float radius;

float alphaAt(vec2 uv)
{
	if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) return 0.0;
	return texture2D(bitmap, uv).a;
}

float lumaOf(vec4 c)
{
	return c.a > 0.0 ? dot(c.rgb / c.a, vec3(0.299, 0.587, 0.114)) : 0.0;
}

float ringOf(vec4 c)
{
	return c.a * smoothstep(0.8, 0.95, lumaOf(c));
}

float rnd(float x)
{
	return fract(sin(x * 91.3458) * 47453.5453);
}

vec4 character(vec2 uv, vec4 orig)
{
	vec4 src = texture2D(bitmap, uv);
	float a = src.a;
	vec2 px = 1.0 / openfl_TextureSize.xy;

	if (a > 0.0)
	{
		vec2 farStep = px * rimWidth;
		float open[12];
		float openSum = 0.0;
		for (int i = 0; i < 12; i++)
		{
			float t = float(i) * 0.52359878;
			float o = 1.0 - alphaAt(uv + vec2(cos(t), sin(t)) * farStep);
			open[i] = o;
			openSum += o;
		}

		float inner = 0.0;
		float facing = 0.0;
		if (openSum > 0.0)
		{
			vec2 light = vec2(cos(lightAng + angOffset), -sin(lightAng + angOffset));
			for (int i = 0; i < 12; i++)
			{
				float t = float(i) * 0.52359878;
				vec2 d = vec2(cos(t), sin(t));
				float e = max(1.0 - alphaAt(uv + d * farStep * 0.35), open[i] * 0.55);
				inner += e;
				facing += e * max(dot(d, light), 0.0);
			}
			inner /= 12.0;
			facing /= 6.0;
		}

		float luma = dot(src.rgb / a, vec3(0.299, 0.587, 0.114));
		float flicker = 0.88 + 0.24 * fract(sin(dot(floor(uv * openfl_TextureSize.xy / 5.0) + floor(iTime * 16.0), vec2(12.9898, 78.233))) * 43758.5453);
		float rim = clamp(inner * 1.35 + facing * 1.1, 0.0, 1.0) * rimStrength * (1.0 + pulse * 0.8) * flicker;
		vec3 body = vec3(0.010, 0.012, 0.020) + rimColor * luma * bodyLight * (1.0 + pulse * 0.5);
		float rc = min(rim, 1.0);
		vec3 neon = rimColor * rim + vec3(1.0) * rc * rc * rc * 0.6;
		return vec4((body + neon) * a, a);
	}

	vec2 nearStep = px * glowWidth * 0.5;
	float outer = 0.0;
	for (int i = 0; i < 8; i++)
	{
		float t = float(i) * 0.78539816 + 0.39269908;
		vec2 d = vec2(cos(t), sin(t)) * nearStep;
		outer += alphaAt(uv + d) + alphaAt(uv + d * 2.0) * 0.6;
	}
	float halo = clamp(outer / 12.8, 0.0, 1.0) * (0.45 + pulse * 0.55);
	return vec4(rimColor * halo, halo * 0.85);
}

vec4 note(vec2 uv, vec4 orig)
{
	vec4 src = texture2D(bitmap, uv);
	if (src.a <= 0.0) return orig;

	float a = src.a;
	float l = lumaOf(src);
	float ring = smoothstep(0.8, 0.95, l);
	float outline = 1.0 - smoothstep(0.2, 0.32, l);
	vec2 px = thick / openfl_TextureSize.xy;
	vec2 axis = hold > 0.5 ? vec2(1.0, 0.0) : vec2(1.0, 1.0);

	float oNear = 0.0;
	float line = ring;
	for (int i = 0; i < 8; i++)
	{
		float t = float(i) * 0.78539816;
		vec2 d = vec2(cos(t), sin(t)) * axis * px;
		if (outline > 0.0) oNear = max(oNear, 1.0 - texture2D(bitmap, uv + d).a);
		if (line < 1.0) line = max(line, max(ringOf(texture2D(bitmap, uv + d * 0.25)), ringOf(texture2D(bitmap, uv + d * 0.55))));
	}

	float o = oNear * outline;
	vec3 col = (mix(rimColor, vec3(1.0), 0.7) * o + min(rimColor * 1.4, vec3(1.0)) * line * (1.0 - o)) * (1.0 + pulse * 0.6);
	return vec4(col * a, a);
}

vec4 screen(vec2 uv)
{
	if (split + glitch + vignette <= 0.001) return texture2D(bitmap, uv);

	float band = floor(uv.y * 28.0);
	float frame = floor(iTime * 24.0);
	float n = rnd(band + frame * 7.0);
	uv.x += step(0.78, n) * (n - 0.78) / 0.22 * glitch * 0.045 * (rnd(band * 3.1 + frame) > 0.5 ? 1.0 : -1.0);

	vec2 c = uv - 0.5;
	vec2 off = c * (split + glitch * 6.0) / openfl_TextureSize.xy * 2.0;
	vec4 g = texture2D(bitmap, uv);
	vec4 col = vec4(texture2D(bitmap, uv + off).r, g.g, texture2D(bitmap, uv - off).b, g.a);
	col.rgb *= mix(1.0, 1.0 - smoothstep(0.3, 0.95, length(c * vec2(1.0, 0.85))), vignette);
	return col;
}

vec4 hudGlow(vec2 uv)
{
	vec4 base = texture2D(bitmap, uv);
	if (strength <= 0.001) return base;

	vec2 px = radius / openfl_TextureSize.xy;
	vec3 glow = vec3(0.0);
	for (int i = 0; i < 8; i++)
	{
		float t = float(i) * 0.78539816;
		vec2 d = vec2(cos(t), sin(t)) * px;
		vec4 s1 = texture2D(bitmap, uv + d * 0.4);
		vec4 s2 = texture2D(bitmap, uv + d);
		glow += s1.rgb * smoothstep(0.3, 0.7, max(s1.r, max(s1.g, s1.b))) * 0.6;
		glow += s2.rgb * smoothstep(0.3, 0.7, max(s2.r, max(s2.g, s2.b))) * 0.4;
	}
	glow = glow / 8.0 * strength;
	return vec4(base.rgb + glow, clamp(base.a + max(glow.r, max(glow.g, glow.b)), 0.0, 1.0));
}

void main()
{
	vec2 uv = openfl_TextureCoordv;

	if (mode > 2.5)
	{
		gl_FragColor = hudGlow(uv);
		return;
	}
	if (mode > 1.5)
	{
		gl_FragColor = screen(uv);
		return;
	}

	vec4 orig = flixel_texture2D(bitmap, uv);
	if (amount <= 0.001 || uFrameBounds.z < -1.0)
	{
		gl_FragColor = orig;
		return;
	}

	vec4 styled = mode > 0.5 ? note(uv, orig) : character(uv, orig);
	gl_FragColor = mix(orig, styled * openfl_Alphav, amount);
}
