#pragma header

uniform float AMT;
uniform float SPEED;
uniform float iTime;

float random2d(vec2 n) {
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float randomRange(vec2 seed, float min, float max) {
	return min + random2d(seed) * (max - min);
}

float insideRange(float v, float bottom, float top) {
	return step(bottom, v) - step(top, v);
}

void main() {
	float time = floor(iTime * SPEED * 60.0);

	vec2 pos = openfl_TextureCoordv;

	vec4 outCol = texture2D(bitmap, pos);

	// RANDOM HORIZONTAL GLITCH SLICES
	float maxOffset = AMT / 2.0;

	for (float i = 0.0; i < 10.0; i += 1.0) {
		if (i >= 10.0 * AMT)
			break;

		float sliceY = random2d(vec2(time, 2345.0 + i));
		float sliceH = random2d(vec2(time, 9035.0 + i)) * 0.25;

		float hOffset = randomRange(vec2(time, 9625.0 + i), -maxOffset, maxOffset);

		vec2 uvOff = pos;
		uvOff.x += hOffset;

		if (insideRange(pos.y, sliceY, fract(sliceY + sliceH)) == 1.0) {
			outCol = texture2D(bitmap, uvOff);
		}
	}

	// RGB OFFSET
	float maxColOffset = AMT / 6.0;

	float rnd = random2d(vec2(time, 9545.0));

	vec2 colOffset = vec2(
		randomRange(vec2(time, 9545.0), -maxColOffset, maxColOffset),
		randomRange(vec2(time, 7205.0), -maxColOffset, maxColOffset)
	);

	if (rnd < 0.33) {
		outCol.r = texture2D(bitmap, pos + colOffset).r;
	} else if (rnd < 0.66) {
		outCol.g = texture2D(bitmap, pos + colOffset).g;
	} else {
		outCol.b = texture2D(bitmap, pos + colOffset).b;
	}

	gl_FragColor = outCol;
}
