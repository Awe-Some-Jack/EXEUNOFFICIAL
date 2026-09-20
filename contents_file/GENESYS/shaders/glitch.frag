// https://www.shadertoy.com/view/XtyXzW

#pragma header

uniform float time;
uniform float prob;
uniform float intensityChromatic;
#define texture flixel_texture2D

// --------------------------------------------------------
// Glitch core
// --------------------------------------------------------

float rand(vec2 co){
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

const float glitchScale = 0.4;

vec2 glitchCoord(vec2 p, vec2 gridSize) {
    vec2 coord = floor(p / gridSize) * gridSize;
    coord += (gridSize * 0.5);
    return coord;
}

struct GlitchSeed {
    vec2 seed;
    float prob;
};
    
GlitchSeed glitchSeed(vec2 p, float speed) {
    float seedTime = floor(time * speed);
    vec2 seed = vec2(
        1.0 + mod(seedTime * 0.01, 100.0),
        1.0 + mod(seedTime, 100.0)
    ) * 0.01;
    seed += p; 
    return GlitchSeed(seed, prob);
}

float shouldApply(GlitchSeed seed) {
    float m1 = rand(seed.seed) * (1.5 - seed.prob) + seed.prob - 0.5;
    return floor(m1 * (0.5 + 0.5 * seed.prob) + 0.5);
}

// --------------------------------------------------------
// Glitch effects
// --------------------------------------------------------

vec4 swapCoords(vec2 seed, vec2 groupSize, vec2 subGrid, vec2 blockSize) {
    vec2 rand2 = vec2(rand(seed), rand(seed + 0.1));
    vec2 range = subGrid - (blockSize - 1.0);
    vec2 coord = floor(rand2 * range) / subGrid;
    
    vec2 bottomLeft = coord * groupSize;
    vec2 realBlockSize = (groupSize / subGrid) * blockSize;
    vec2 topRight = bottomLeft + realBlockSize;
    
    vec2 halfGroup = groupSize * 0.5;
    return vec4(bottomLeft - halfGroup, topRight - halfGroup);
}

vec2 isInBlock(vec2 pos, vec4 block) {
    vec2 s1 = step(block.xy, pos);
    vec2 s2 = step(pos, block.zw);
    return vec2((s1.x * s1.y * s2.x * s2.y) - 1.0);
}

vec2 moveDiff(vec2 pos, vec4 swapA, vec4 swapB) {
    vec2 diff = swapB.xy - swapA.xy;
    return diff * isInBlock(pos, swapA);
}

void swapBlocks(inout vec2 xy, vec2 groupSize, vec2 subGrid, vec2 blockSize, vec2 seed, float apply) {
    if (apply == 0.0) return;
    
    vec2 groupOffset = glitchCoord(xy, groupSize);
    vec2 pos = xy - groupOffset;
    
    vec4 swapA = swapCoords(seed * groupOffset, groupSize, subGrid, blockSize);
    vec4 swapB = swapCoords(seed * (groupOffset + 0.1), groupSize, subGrid, blockSize);
    
    pos += moveDiff(pos, swapA, swapB) * apply;
    pos += moveDiff(pos, swapB, swapA) * apply;
    
    xy = pos + groupOffset;
}

void staticNoise(inout vec2 p, vec2 groupSize, float grainSize, float contrast) {
    GlitchSeed seedA = glitchSeed(glitchCoord(p, groupSize), 5.0);
    seedA.prob *= 0.5;
    if (shouldApply(seedA) == 1.0) {
        GlitchSeed seedB = glitchSeed(glitchCoord(p, vec2(grainSize)), 5.0);
        vec2 offset = vec2(rand(seedB.seed), rand(seedB.seed + 0.1));
        offset = floor(offset * 2.0 - 0.5) * contrast;
        p += offset;
    }
}

// --------------------------------------------------------
// Glitch compositions
// --------------------------------------------------------

void glitchSwap(inout vec2 p) {
    float speed = 5.0;
    
    vec2 groupSize = vec2(0.6) * glitchScale;
    vec2 subGrid = vec2(2.0);
    vec2 blockSize = vec2(1.0);
    GlitchSeed seed = glitchSeed(glitchCoord(p, groupSize), speed);
    swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, shouldApply(seed));
    
    groupSize = vec2(0.8) * glitchScale;
    subGrid = vec2(3.0);
    seed = glitchSeed(glitchCoord(p, groupSize), speed);
    swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, shouldApply(seed));

    groupSize = vec2(0.2) * glitchScale;
    subGrid = vec2(6.0);
    seed = glitchSeed(glitchCoord(p, groupSize), speed);
    float applyBase = shouldApply(seed);
    if (applyBase > 0.0) {
        float combinedApply = applyBase * shouldApply(seed);
        swapBlocks(p, groupSize, subGrid, blockSize, seed.seed + 1.0, combinedApply);
        swapBlocks(p, groupSize, subGrid, blockSize, seed.seed + 2.0, combinedApply);
        swapBlocks(p, groupSize, subGrid, blockSize, seed.seed + 3.0, combinedApply);
        swapBlocks(p, groupSize, subGrid, blockSize, seed.seed + 4.0, combinedApply);
        swapBlocks(p, groupSize, subGrid, blockSize, seed.seed + 5.0, combinedApply);
    }
    
    groupSize = vec2(1.2, 0.2) * glitchScale;
    subGrid = vec2(9.0, 2.0);
    blockSize = vec2(3.0, 1.0);
    seed = glitchSeed(glitchCoord(p, groupSize), speed);
    swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, shouldApply(seed));
}

void glitchStatic(inout vec2 p) {
    staticNoise(p, vec2(0.5, 0.125) * glitchScale, 0.2 * glitchScale, 2.0);
}

void glitchColor(vec2 p, inout vec3 color) {
    vec2 groupSize = vec2(0.75, 0.125) * glitchScale;
    GlitchSeed seed = glitchSeed(glitchCoord(p, groupSize), 5.0);
    seed.prob *= 0.3;
    if (shouldApply(seed) == 1.0) color = vec3(0.0);
}

vec4 transverseChromatic(vec2 p) {
    if (intensityChromatic <= 0.0) return texture(bitmap, p);
    
    vec2 dist = p - 0.5;
    vec2 velocity = dist * dot(dist, dist) * intensityChromatic;
    
    float inverseSampleCount = 0.02; // 1.0 / 50.0
    vec2 incrementR = velocity * inverseSampleCount;
    vec2 incrementG = velocity * (2.0 * inverseSampleCount);
    vec2 incrementB = velocity * (4.0 * inverseSampleCount);
    
    vec3 accumulator = vec3(0.0);
    vec2 offsetR = vec2(0.0);
    vec2 offsetG = vec2(0.0);
    vec2 offsetB = vec2(0.0);
    
    for (int i = 0; i < 50; i++) {
        accumulator.r += texture(bitmap, p + offsetR).r; 
        accumulator.g += texture(bitmap, p + offsetG).g; 
        accumulator.b += texture(bitmap, p + offsetB).b;         
        offsetR -= incrementR;
        offsetG -= incrementG;
        offsetB -= incrementB;
    }
    return vec4(accumulator * inverseSampleCount, 1.0);
}

void main() {
    vec2 p = openfl_TextureCoordv.xy;
    
    glitchSwap(p);
    glitchStatic(p);

    vec3 color = transverseChromatic(p).rgb;
    glitchColor(p, color);

    gl_FragColor = vec4(color, 1.0);
}