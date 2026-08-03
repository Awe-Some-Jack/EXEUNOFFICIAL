package backend.haxe;

class SecureIntData {
    public var value:Int;
    public var key:Int;

    public inline function new(val:Int) {
        set(val);
    }

    public inline function set(val:Int):Void {
        key = Std.random(0x7FFFFFFF);
        value = val ^ key;
    }

    public inline function get():Int {
        return value ^ key;
    }
}

@:forward(get, set)
abstract SecureInt(SecureIntData) {
    
    public inline function new(initialValue:Int = 0) {
        this = new SecureIntData(initialValue);
    }

    @:to
    public inline function toInt():Int {
        return this.get();
    }

    @:from
    public static inline function fromInt(value:Int):SecureInt {
        return new SecureInt(value);
    }

    @:op(A += B)
    public inline function addEq(v:Int):SecureInt {
        this.set(this.get() + v);
        return cast this;
    }

    @:op(A -= B)
    public inline function subEq(v:Int):SecureInt {
        this.set(this.get() - v);
        return cast this;
    }

    @:op(A *= B)
    public inline function mulEq(v:Int):SecureInt {
        this.set(this.get() * v);
        return cast this;
    }

    @:op(A++)
    public inline function postInc():Int {
        var current = this.get();
        this.set(current + 1);
        return current;
    }

    @:op(A--)
    public inline function postDec():Int {
        var current = this.get();
        this.set(current - 1);
        return current;
    }
}