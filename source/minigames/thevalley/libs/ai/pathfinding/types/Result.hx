package minigames.thevalley.libs.ai.pathfinding.types;

enum abstract Result(Int)
{
    /** Default value for no result. This should not be returned. */
    var None = 0;

    /** The path was found. */
    var Solved = 1;

    /** The search completed without finding a path. */
    var NoSolution = 2;

    /** The goal point was the same as the given starting point. */
    var StartEndSame = 3;

    /** The maximum cost provided was exceeded; i.e. the goal node was not found nearby. */
    var MaxCostExceeded = 4;

    var MaxIterationsExceeded = 5;

    var Partial = 6;

    public function toString(): String
    {
        return switch (this)
        {
            case 1: "Solved";
            case 2: "NoSolution";
            case 3: "StartEndSame";
            case 4: "MaxCostExceeded";
            case 5: "MaxIterationsExceeded";
            case 6: "Partial";
            default: "None";
        }
    }
}
