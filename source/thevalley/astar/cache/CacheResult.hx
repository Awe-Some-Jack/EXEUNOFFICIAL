package thevalley.astar.cache;

enum abstract CacheResult(Int)
{
    /** The requested path was found in the cache. **/
    var Hit = 0;

    /** The requested path was not found in the cache. **/
    var Miss = 1;

    /** The requested path was found in the cache, and it is known to have to solution. **/
    var NoSolution = 2;

    /** The requested path was found in the cache, and it is known to have to solution, but it exceeds the max cost provided. **/
    var MaxCostExceeded = 3;
}
