function onCreatePost()
    setSpriteShader('boyfriend', 'DropShadowShader')

    setShaderFloat('boyfriend', 'hue', 5)
    setShaderFloat('boyfriend', 'saturation', -60)
    setShaderFloat('boyfriend', 'brightness', -5)
    setShaderFloat('boyfriend', 'contrast', 5)

    setShaderFloat('boyfriend', 'ang', 0)
    setShaderFloat('boyfriend', 'dist', 0)
    setShaderFloat('boyfriend', 'str', 0)
    setShaderFloat('boyfriend', 'thr', 0)
    setShaderFloatArray('boyfriend', 'dropColor', {0,0,0})
    
    setSpriteShader('dad', 'DropShadowShader')

    setShaderFloat('dad', 'hue', 5)
    setShaderFloat('dad', 'saturation', -60)
    setShaderFloat('dad', 'brightness', -5)
    setShaderFloat('dad', 'contrast', 5)

    setShaderFloat('dad', 'ang', 0)
    setShaderFloat('dad', 'dist', 0)
    setShaderFloat('dad', 'str', 0)
    setShaderFloat('dad', 'thr', 0)
    setShaderFloatArray('dad', 'dropColor', {0,0,0})
end

function onEvent(n,v1)
    if n == 'yourselfEvents' then
        if v1 == 'abcdefghi' then
            removeSpriteShader('dad')
        end
    end
end