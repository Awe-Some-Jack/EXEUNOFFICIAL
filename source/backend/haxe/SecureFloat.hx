package backend.haxe;

class SecureFloatData {
    public var value:Float;
    public var offset:Float;

    public inline function new(val:Float) {
        set(val);
    }

    public inline function set(val:Float):Void {
        offset = Math.random() * 1000000;
        value = val + offset;
    }

    public inline function get():Float {
        return value - offset;
    }
}

@:forward(get, set)
abstract SecureFloat(SecureFloatData) {
    
    public inline function new(initialValue:Float = 0.0) {
        this = new SecureFloatData(initialValue);
    }

    @:to
    public inline function toFloat():Float {
        return this.get();
    }

    @:from
    public static inline function fromFloat(value:Float):SecureFloat {
        return new SecureFloat(value);
    }

    @:op(A > B)  public inline function gt(v:Float):Bool return this.get() > v;
    @:op(A >= B) public inline function gte(v:Float):Bool return this.get() >= v;
    @:op(A < B)  public inline function lt(v:Float):Bool return this.get() < v;
    @:op(A <= B) public inline function lte(v:Float):Bool return this.get() <= v;
    @:op(A == B) public inline function eq(v:Float):Bool return this.get() == v;
    @:op(A != B) public inline function neq(v:Float):Bool return this.get() != v;

    @:op(A + B)  public inline function add(v:Float):Float return this.get() + v;
    @:op(A - B)  public inline function sub(v:Float):Float return this.get() - v;
    @:op(A * B)  public inline function mul(v:Float):Float return this.get() * v;
    @:op(A / B)  public inline function div(v:Float):Float return this.get() / v;
    @:op(A % B)  public inline function mod(v:Float):Float return this.get() % v;

    @:op(A += B)
    public inline function addEq(v:Float):SecureFloat {
        this.set(this.get() + v);
        return cast this;
    }

    @:op(A -= B)
    public inline function subEq(v:Float):SecureFloat {
        this.set(this.get() - v);
        return cast this;
    }

    @:op(A *= B)
    public inline function mulEq(v:Float):SecureFloat {
        this.set(this.get() * v);
        return cast this;
    }
    
    @:op(A /= B)
    public inline function divEq(v:Float):SecureFloat {
        this.set(this.get() / v);
        return cast this;
    }

    @:op(A++)
    public inline function postInc():Float {
        var current = this.get();
        this.set(current + 1);
        return current;
    }

    @:op(A--)
    public inline function postDec():Float {
        var current = this.get();
        this.set(current - 1);
        return current;
    }
}