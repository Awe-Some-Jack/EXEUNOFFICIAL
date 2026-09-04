case 'fadefinalxd':
				FlxTween.tween(camHUD, {alpha: 0}, 4);
				for (spr in starv) FlxTween.color(spr.sprite, 1, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(boyfriend, 3, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(dad, 3, 0xFFFFFFFF, 0xFF000000);
				FlxTween.color(vg, 3, 0xFFFFFFFF, 0xFF000000);
				FlxTween.tween(camHUD, {alpha: 0}, 3);