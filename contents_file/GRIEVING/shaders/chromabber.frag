#pragma header

        uniform float amount;

    vec2 PincushionDistortion(in vec2 uv, float strength) 
    {
	    vec2 st = uv - 0.5;
        return 0.5 + st * (1.0 - strength * dot(st, st));
    }

    vec3 ChromaticAbberation(sampler2D tex, in vec2 uv) 
    {
	    float rChannel = texture2D(tex, PincushionDistortion(uv, 0.3 * amount)).r;
        float gChannel = texture2D(tex, PincushionDistortion(uv, 0.15 * amount)).g;
        float bChannel = texture2D(tex, PincushionDistortion(uv, 0.075 * amount)).b;
        vec3 retColor = vec3(rChannel, gChannel, bChannel);
        return retColor;
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        vec3 col = ChromaticAbberation(bitmap, uv);
    
        gl_FragColor = vec4(col, texture2D(bitmap,uv).a);
    }