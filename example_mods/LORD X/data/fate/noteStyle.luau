local updateTimer = 0

function onCreatePost()
    initLuaShader('outline')

    runHaxeCode([[
        import shaders.ErrorHandledShader.ErrorHandledRuntimeShader;

        var arr = parentLua.runtimeShaders.get('outline');
        if (arr != null) {
            var frag = arr[0];
            var vert = arr[1];
            var white = new Array();
            white.push(1.0); white.push(1.0); white.push(1.0); white.push(1.0);
            for (strum in game.opponentStrums.members) {
                if (strum == null) continue;
                strum.useRGBShader = false;
                var sh = new ErrorHandledRuntimeShader('outline', frag, vert);
                strum.shader = sh;
                strum.color = 0xFF000000;
                sh.setFloat('thickness', 4.0);
                sh.setFloatArray('outlineColor', white);
            }
            for (strum in game.playerStrums.members) {
                if (strum == null) continue;
                strum.useRGBShader = false;
                var sh = new ErrorHandledRuntimeShader('outline', frag, vert);
                strum.shader = sh;
                strum.color = 0xFF000000;
                sh.setFloat('thickness', 4.0);
                sh.setFloatArray('outlineColor', white);
            }
        }
        return;
    ]])
end

function onUpdate(elapsed)
    updateTimer = updateTimer + elapsed
    if updateTimer < 0.05 then return end
    updateTimer = 0

    runHaxeCode([[
        import shaders.ErrorHandledShader.ErrorHandledRuntimeShader;
        var arr = parentLua.runtimeShaders.get('outline');
        if (arr == null) return;
        var frag = arr[0];
        var vert = arr[1];
        var white = new Array();
        white.push(1.0); white.push(1.0); white.push(1.0); white.push(1.0);

        for (note in game.notes.members) {
            if (note == null) continue;
            if (Std.isOfType(note.shader, ErrorHandledRuntimeShader)) continue;
            var sh = new ErrorHandledRuntimeShader('outline', frag, vert);
            note.shader = sh;
            note.color = 0xFF000000;
            sh.setFloat('thickness', 4.0);
            sh.setFloatArray('outlineColor', white);
            for (piece in note.tail) {
                if (piece == null) continue;
                if (Std.isOfType(piece.shader, ErrorHandledRuntimeShader)) continue;
                var sh2 = new ErrorHandledRuntimeShader('outline', frag, vert);
                piece.shader = sh2;
                piece.color = 0xFF000000;
                sh2.setFloat('thickness', 4.0);
                sh2.setFloatArray('outlineColor', white);
            }
        }
        return;
    ]])
end
