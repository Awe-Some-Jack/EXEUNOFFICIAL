# dropecho/behavior_tree — manual

This isn't the original author's documentation — there isn't one. The upstream
repo ([github.com/dropecho/behavior-tree](https://github.com/dropecho/behavior-tree))
is archived, and its README is a single line: "EXAMPLES TO COME." That line
was never followed up. This file exists to fill that gap, based on actually
reading all 12 source files (now vendored under `thevalley.dropecho`).

## Core pieces

### `Node` (interface)

Everything in the tree is a `Node`. Two methods:

```haxe
interface Node {
    public function init(context:Blackboard):Void;
    public function execute():NODE_STATUS;
}
```

`init` is called once, top-down, when the tree is set up — it's how every
node in the tree gets a reference to the shared `Blackboard`. `execute` is
called every tick you want the tree to think.

### `NODE_STATUS` (enum)

Three values: `SUCCESS`, `FAILURE`, `RUNNING`. Every `execute()` call returns
one of these. `RUNNING` means "not done yet, call me again next tick" — it's
what makes multi-tick behaviors (a timed sequence, waiting on an animation,
etc.) possible at all.

### `Blackboard` (typedef)

```haxe
typedef Blackboard = Map<String, Dynamic>;
```

Just a string-keyed map. It's how nodes that don't otherwise know about each
other share data — e.g. one node stashes `"elapsed"` or a reference to the
acting object, and any other node in the tree can read it back by key. There's
no structure enforced beyond that; you decide what keys exist and what they
mean.

### `BehaviorTree`

The root wrapper. Holds one child `Node`, and is itself a `Node` (so a whole
tree can be nested as a child of a bigger tree, though that's rarely needed).

```haxe
var tree = new BehaviorTree(rootNode);
tree.init(new Blackboard());   // or pass null - it makes an empty one for you
tree.execute();                // call this every tick
```

## Composite nodes — combining children

Both composite nodes hold an **ordered list of children** and track *which
child they're currently on* via a `CurrentIterator` — this tracking is the
single most important thing to understand about this library, covered below.

### `SelectorNode` — OR logic ("try each until one works")

```haxe
new SelectorNode([nodeA, nodeB, nodeC]);
```

Each `execute()`:
- Runs the **current** child.
- Child returned `SUCCESS` → reset back to child 0, return `SUCCESS`.
- Child returned `FAILURE` → if there's a next child, advance to it and
  return `RUNNING` (that next child doesn't run *this* tick — it runs
  *next* tick); if there's no next child, reset to child 0 and return
  `FAILURE` (all children failed).
- Child returned `RUNNING` → don't advance, just return `RUNNING` (stay on
  this exact child next tick too).

In plain terms: it tries child 0 first, and only ever moves on to child 1
once child 0 has definitively failed. The first child to succeed wins, and
the selector resets to the start for the next time it's ticked from scratch.

### `SequenceNode` — AND logic ("run each in order, bail on first failure")

```haxe
new SequenceNode([nodeA, nodeB, nodeC]);
```

Each `execute()`:
- Runs the **current** child.
- If there's a next child AND the current one returned `SUCCESS` or
  `RUNNING`: return `RUNNING` either way (if it was `RUNNING`, stay on it;
  if it was `SUCCESS`, advance to the next child first, then return
  `RUNNING` — the newly-advanced child runs next tick, not this one).
- Otherwise (no next child, or the current one `FAILURE`d): reset to child 0
  and return whatever the current child's actual status was — `FAILURE` if
  it failed, or the last child's own `SUCCESS` if the whole sequence just
  finished clean.

In plain terms: every child has to succeed, in order, for the sequence to
succeed. The first failure fails the whole thing immediately.

### The gotcha: these are *resumable*, not *re-evaluated*

This is the one thing worth understanding before building anything real with
this library. A `SelectorNode`/`SequenceNode` does **not** re-check its
children from the top every tick. It remembers its position (`CurrentIterator`)
and only moves forward when a child resolves. While a child is `RUNNING`, the
composite just keeps re-ticking *that exact child* — it will never glance
back at an earlier sibling to see if it should take over instead, no matter
how many ticks go by.

That's exactly the right behavior for a **scripted sequence with a clear
start and end** — "wind up, then leap, then land" shouldn't get interrupted
partway through just because some earlier condition flickered true again for
a frame.

It's the *wrong* behavior for a **decision that has to be re-evaluated fresh
every single tick** — e.g. "is there a closer, higher-priority threat right
now?" A `SelectorNode` built to check that first, falling through to a lower
priority behavior when it's `RUNNING`, will get stuck on that lower-priority
branch forever once it's entered — it never checks back on the high-priority
one again, even the instant it becomes relevant.

If you need "always re-checked, every tick, top-down priority", write that
dispatch by hand as a plain `Node` (a chain of `if` statements calling
`.execute()` on whichever branch currently applies) instead of reaching for
`SelectorNode`. Composite nodes are for sequencing, not for reactive
per-frame decisions.

## Decorator nodes — modifying one child

All of these wrap exactly one child and change how its result is reported.

- **`InverterNode`** — flips `SUCCESS`↔`FAILURE`. `RUNNING` passes through
  unchanged.
- **`RepeaterNode`** — ticks the child and **always** returns `RUNNING`,
  forever, regardless of what the child returns. There's no "repeat N times"
  variant in this library — this one never stops on its own. Combine it with
  something else (an `InverterNode`, a condition checked elsewhere in the
  tree) if you need it to end.
- **`RepeatUntilNode`** — ticks the child; while it keeps returning `SUCCESS`
  or `RUNNING`, this returns `RUNNING` (i.e. it keeps re-running the child on
  success too, not just on running). The moment the child returns `FAILURE`,
  this returns `SUCCESS` and stops. So: "keep doing this until it fails."
- **`SucceederNode`** — ticks the child; passes `RUNNING` through as-is, but
  turns *any* resolved result (`SUCCESS` or `FAILURE`) into `SUCCESS`. Useful
  for folding an optional branch into a `SequenceNode` without letting its
  failure stop the sequence.

## A minimal worked example

```haxe
class IsHungry implements Node {
    public function new() {}
    public function init(ctx:Blackboard):Void {}
    public function execute():NODE_STATUS {
        var hunger:Float = context.get("hunger");
        return hunger > 50 ? NODE_STATUS.SUCCESS : NODE_STATUS.FAILURE;
    }
}

class Eat implements Node {
    public function new() {}
    public function init(ctx:Blackboard):Void {}
    public function execute():NODE_STATUS {
        // ... timed eating animation, return RUNNING while it plays ...
        return NODE_STATUS.SUCCESS; // once it's done
    }
}

var tree = new BehaviorTree(
    new SequenceNode([new IsHungry(), new Eat()])
);
tree.init(new Blackboard());
// tree.execute() every tick - the sequence only reaches Eat() once
// IsHungry() has actually succeeded that tick.
```

## Where this is actually used in this project

`thevalley/Monster.hx` builds a tree via `new BehaviorTree(new _BrainNode())`.
`_BrainNode` and `_TrackNode` are hand-written `Node` implementations, **not**
`SelectorNode`/`SequenceNode` — that was a deliberate choice, for exactly the
resumability reason explained above: the monster's top-level "chase vs.
investigate vs. track" decision has to be re-checked fresh every tick, which
a resumable composite node can't do. The composite/decorator nodes described
in this file aren't currently used anywhere in this project, but they're
vendored and ready if a genuinely sequential, scripted behavior ever needs
one.
