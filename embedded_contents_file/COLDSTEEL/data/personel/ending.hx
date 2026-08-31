import nape.space.Space;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.geom.Vec2;
import nape.dynamics.InteractionFilter;

var space:Space = null;
var physics = [];
var physicsStarted = false;

var hudElements = [
    'iconBF',
    'iconOpp',
    'exeScoreTxt',
    'healthBG',
    'hbHealth',
    'hbHealth2',
    'separatorHealth',
    'hbBG'
];

function getHudObject(obj)
{
    var spr = game.getLuaObject(obj);

    if (spr == null)
        spr = Reflect.field(game, obj);

    return spr;
}

function addWall(x, y, w, h)
{
    var body = new Body(BodyType.STATIC);
    var shape = new Polygon(Polygon.box(w, h));

    shape.filter = new InteractionFilter(2, 1);

    body.shapes.add(shape);
    body.position.setxy(x, y);
    body.space = space;
}

function addPhysics(spr, customHitbox, size)
{
    if (spr == null)
        return;

    var w = spr.width * size;
    var h = spr.height * size;
    var ox = 0;
    var oy = 0;

    if (customHitbox != null)
    {
        w = customHitbox[2] * Math.abs(spr.scale.x);
        h = customHitbox[3] * Math.abs(spr.scale.y);

        ox = (customHitbox[0] + customHitbox[2] / 2 - spr.frameWidth / 2) * spr.scale.x;
        oy = (customHitbox[1] + customHitbox[3] / 2 - spr.frameHeight / 2) * spr.scale.y;
    }

    if (spr == getHudObject('exeScoreTxt'))
    {
        w = spr.textField.textWidth + 10;
        h = spr.textField.textHeight + 6;

        ox = 0;
        oy = 0;
    }

    var body = new Body(BodyType.DYNAMIC);

    var shape = new Polygon(
        Polygon.box(w, h),
        new Material(0.2, 0.8, 1, 1)
    );

    shape.filter = new InteractionFilter(1, 2);

    body.shapes.add(shape);

    body.position.setxy(
        spr.x + spr.width / 2 + ox,
        spr.y + spr.height / 2 + oy
    );

    body.rotation = spr.angle * Math.PI / 180;
    body.angularVel = FlxG.random.float(-2, 2);
    body.space = space;

    physics.push([spr, body, ox, oy]);
}

function initPhysics()
{
    space = new Space(new Vec2(0, 980));

    addWall(
        FlxG.width / 2,
        FlxG.height + 25,
        FlxG.width + 100,
        50
    );

    addWall(
        -25,
        FlxG.height / 2,
        50,
        FlxG.height + 100
    );

    addWall(
        FlxG.width + 25,
        FlxG.height / 2,
        50,
        FlxG.height + 100
    );

    for (obj in hudElements)
    {
        if (obj == 'healthBG')
            addPhysics(getHudObject(obj), [263, 119, 1489, 95], 1);
        else if (obj == 'iconBF' || obj == 'iconOpp')
            addPhysics(getHudObject(obj), null, 0.8);
        else
            addPhysics(getHudObject(obj), null, 1);
    }

    for (i in 0...8)
        addPhysics(game.strumLineNotes.members[i], null, 1);

    new FlxTimer().start(0.2, function(t)
    {
        for (data in physics)
        {
            for (shape in data[1].shapes)
                shape.filter = new InteractionFilter(1, 3);
        }
    });

    physicsStarted = true;
}

function onUpdatePost(elapsed)
{
    if (!physicsStarted && game.curStep >= 1976)
        initPhysics();

    if (!physicsStarted || space == null)
        return;

    space.step(elapsed);

    for (data in physics)
    {
        var spr = data[0];
        var body = data[1];
        var ox = data[2];
        var oy = data[3];

        if (spr == null || body == null)
            continue;

        var cos = Math.cos(body.rotation);
        var sin = Math.sin(body.rotation);

        spr.x =
            body.position.x
            - spr.width / 2
            - (ox * cos - oy * sin);

        spr.y =
            body.position.y
            - spr.height / 2
            - (ox * sin + oy * cos);

        spr.angle = body.rotation * 180 / Math.PI;
    }
}