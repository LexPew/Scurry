using System;
using System.Collections;
using System.Collections.Generic;
using Unity.AI.Navigation;
using UnityEngine;

[Serializable]
public struct Room
{
    public RectInt rect;

    public Vector2Int Center => new Vector2Int(rect.x + rect.width / 2, rect.y + rect.height / 2);

    public Room(RectInt r) { rect = r; }
}

//cardinal directions
public enum Directions
{
    North,
    East,
    South,
    West
}

//bitmask for 4 way cardinal direction
enum DirectionBitMask
{
    North = 1,
    East = 2,
    South = 4,
    West = 8
}

// Sewer tile topology classification.
enum TileType
{
    Straight = 0,
    Corner = 1,
    TJunction = 2,
    Crossroad = 3,
    Deadend = 4,
    Error = -1
}
public class LevelGen : MonoBehaviour
{
    // -------------------------------------------------------------
    //  ROOM + GRID CONFIGURATION
    // -------------------------------------------------------------
    [Header("Grid Settings")]
    [Tooltip("Logical grid dimensions in tiles.")]
    public int gridWidth = 100;
    public int gridHeight = 60;

    [Tooltip("World units per logical tile.")]
    public float cellSize = 20f;

    // -------------------------------------------------------------
    //  ROOM GENERATION
    // -------------------------------------------------------------
    [Header("Room Generation")]
    [Tooltip("Total number of rooms placed in the grid.")]
    public int numRooms = 12;

    [Tooltip("Maximum random placement attempts before fallback rules apply.")]
    public int maxPlacementAttempts = 250;

    [Tooltip("Minimum Chebyshev distance between room centers.")]
    public int roomSpacing = 1;

    // -------------------------------------------------------------
    //  CORRIDOR GENERATION
    // -------------------------------------------------------------
    [Header("Corridor Generation")]
    [Tooltip("Minimum straight run before allowing a turn in path.")]
    public int minTurnSpacing = 3;

    [Range(0f, 1f)]
    [Tooltip("Chance of generating an extra bend in corridor paths.")]
    public float zigzagChance = 0.45f;

    [Tooltip("If true, corridor attempts avoid adjacency & overlap.")]
    public bool avoidIntersections = true;

    [Tooltip("Attempts per corridor link before accepting overlap.")]
    public int maxPathAttempts = 6;

    // -------------------------------------------------------------
    //  ENTITY SPAWNING (Nests, Player)
    // -------------------------------------------------------------
    [Header("Spawning")]
    [SerializeField] private GameObject nestPrefab;
    [SerializeField]
    [Tooltip("How many nests to place in non-start rooms.")]
    private int nestCount = 5;

    [SerializeField]
    [Tooltip("Player prefab that spawns at the start room.")]
    private GameObject playerPrefab;

    // -------------------------------------------------------------
    //  SEEDING
    // -------------------------------------------------------------
    [Header("Random Seed (0 = fully random)")]
    public int seed = 0;


    // -------------------------------------------------------------
    //  GENERATED OUTPUT (Readonly in Inspector)
    // -------------------------------------------------------------
    [Header("Generated Data (Runtime)")]
    [Tooltip("Room containers (single-tile rooms).")]
    public List<Room> rooms = new List<Room>();

    [Tooltip("Tiles belonging to corridors only.")]
    public HashSet<Vector2Int> corridorTiles = new HashSet<Vector2Int>();

    [Tooltip("Union of room + corridor tiles.")]
    public HashSet<Vector2Int> floorTiles = new HashSet<Vector2Int>();


    // -------------------------------------------------------------
    //  PREFAB MAPPING
    // -------------------------------------------------------------
    [Header("Tile Prefabs")]
    [Tooltip("Index order: 0=Straight, 1=Corner, 2=T-Junction, 3=Crossroad, 4=Deadend")]
    public GameObject[] tilePrefabsByType = new GameObject[5];

    [Tooltip("Optional override for escape tile.")]
    public GameObject escapePrefab;


    [Tooltip("Native authored prefab unit size for auto-scaling to cellSize.")]
    public float prefabNativeSize = 20f;

    [Tooltip("Automatically scale prefabs to fill each grid cell.")]
    public bool scalePrefabsToCell = true;

    // -------------------------------------------------------------
    //  DEBUG / EXECUTION
    // -------------------------------------------------------------
    [Header("Debugging & Generation Control")]
    [Tooltip("Generated tile parent for organizational hierarchy.")]
    public Transform parentForTiles;

    [Tooltip("Draw gizmos for rooms, corridors, and floor tiles.")]
    public bool drawGizmos = true;

    [Tooltip("Automatically generate level on Awake().")]
    public bool autoGenerateOnStart = true;

    [Tooltip("Instantiate tile prefabs after generation.")]
    public bool instantiateOnGenerate = true;

    // -------------------------------------------------------------
    //  INTERNAL STATE
    // -------------------------------------------------------------
    [HideInInspector] public int escapeRoomIndex = -1;

    private System.Random rng;

    // 4?way cardinal offsets.
    private static readonly Vector2Int[] CardinalDirs = new[] { Vector2Int.up, Vector2Int.right, Vector2Int.down, Vector2Int.left };

    private void Awake()
    {
        if (autoGenerateOnStart)
        {
            Generate();
            NavMeshSurface surface = GetComponent<NavMeshSurface>();
            surface.BuildNavMesh();

            // Nest placement in non-start/goal rooms; avoids duplicates.
            List<int> usedRooms = new List<int>();
            for (int i = 0; i < nestCount; i++)
            {
                if (rooms.Count <= 2) break;
                int roomIndex = UnityEngine.Random.Range(1, rooms.Count - 1);
                while (usedRooms.Contains(roomIndex))
                    roomIndex = UnityEngine.Random.Range(1, rooms.Count - 1);

                usedRooms.Add(roomIndex);
                Vector2Int roomCenter = rooms[roomIndex].Center;
                Vector3 nestPos = new Vector3((roomCenter.x + 0.5f) * cellSize, 0f, (roomCenter.y + 0.5f) * cellSize);
                Instantiate(nestPrefab, nestPos, Quaternion.identity, transform);
            }

            // Player spawn over start tile.
            if (playerPrefab != null)
            {
                Vector3 spawnPos = GetEscapePosition();
                Instantiate(playerPrefab, spawnPos + Vector3.up * 2.0f, Quaternion.identity);
            }

            //spawn exit on start tile
            if (escapePrefab != null)
            {
                Vector3 spawnPos = GetEscapePosition();
                Instantiate(escapePrefab, spawnPos + new Vector3(0, 0, -2), Quaternion.identity);
            }
        }
    }

    public void Generate()
    {
        rng = seed == 0 ? new System.Random() : new System.Random(seed);
        rooms.Clear();
        corridorTiles.Clear();
        floorTiles.Clear();
        escapeRoomIndex = -1; //set to minus one before generation in case of re-generation


        PlaceRoomsAsSingleTiles();
        PlaceEscapeTile();
        ConnectRooms();
        StampRoomsAndCorridorsToFloor();

        if (instantiateOnGenerate)
            InstantiatePrefabs();
    }

    void PlaceRoomsAsSingleTiles()
    {
        int attempts = 0;
        while (rooms.Count < numRooms && attempts < maxPlacementAttempts)
        {
            attempts++;
            int x = rng.Next(1, Math.Max(2, gridWidth - 1));
            int y = rng.Next(1, Math.Max(2, gridHeight - 1));
            RectInt candidate = new RectInt(x, y, 1, 1);

            bool overlaps = false;
            foreach (var r in rooms)
            {
                int dx = Math.Abs(r.rect.x - candidate.x);
                int dy = Math.Abs(r.rect.y - candidate.y);
                if (Math.Max(dx, dy) <= roomSpacing)
                {
                    overlaps = true;
                    break;
                }
            }

            if (!overlaps)
                rooms.Add(new Room(candidate));
        }

        // Relaxed placement fallback.
        if (rooms.Count < numRooms)
        {
            int tries = 0;
            while (rooms.Count < numRooms && tries < maxPlacementAttempts * 2)
            {
                tries++;
                int x = rng.Next(1, Math.Max(2, gridWidth - 1));
                int y = rng.Next(1, Math.Max(2, gridHeight - 1));
                RectInt candidate = new RectInt(x, y, 1, 1);
                bool overlaps = false;
                foreach (var r in rooms)
                {
                    if (r.rect.Overlaps(candidate))
                    {
                        overlaps = true;
                        break;
                    }
                }
                if (!overlaps) rooms.Add(new Room(candidate));
            }
        }
    }

    void PlaceEscapeTile()
    {
        // pick a random room to be the escape room where the player spawns
        int escapeRoomIndex = rng.Next(0, rooms.Count);
        Room escapeRoom = rooms[escapeRoomIndex];
        Vector2Int escapePos = escapeRoom.Center;
        Vector3 worldPos = new Vector3(escapePos.x * cellSize, 0f, escapePos.y * cellSize);
        //assign ecape room index, instantiated later with rest of rooms;
        this.escapeRoomIndex = escapeRoomIndex;
    }

    void ConnectRooms()
    {
        var connectedPairs = new HashSet<(int, int)>();
        for (int i = 0; i < rooms.Count; i++)
        {
            for (int d = 0; d < 4; d++)
            {
                int j = FindNearestInDirection(i, (Directions)d);
                if (j >= 0 && j != i)
                {
                    var pair = i < j ? (i, j) : (j, i);
                    if (!connectedPairs.Contains(pair))
                    {
                        TryCreateCorridorBetweenRooms(i, j);
                        connectedPairs.Add(pair);
                    }
                }
            }
        }
    }

    // Finds closest room strictly in a given cardinal half-space.
    int FindNearestInDirection(int srcIndex, Directions dir)
    {
        Vector2Int center = rooms[srcIndex].Center;
        int bestIdx = -1;
        int bestDist = int.MaxValue;

        for (int i = 0; i < rooms.Count; i++)
        {
            if (i == srcIndex) continue;
            Vector2Int c = rooms[i].Center;
            int dx = c.x - center.x;
            int dy = c.y - center.y;

            bool candidate = dir switch
            {
                Directions.North => dy > 0,
                Directions.South => dy < 0,
                Directions.East => dx > 0,
                Directions.West => dx < 0,
                _ => false
            };
            if (!candidate) continue;

            int dist = Math.Abs(dx) + Math.Abs(dy);
            if (dist < bestDist)
            {
                bestDist = dist;
                bestIdx = i;
            }
        }
        return bestIdx;
    }

    // Generates corridor path variants; prefers non-overlapping unless final attempt.
    bool TryCreateCorridorBetweenRooms(int aIndex, int bIndex)
    {
        Vector2Int from = rooms[aIndex].Center;
        Vector2Int to = rooms[bIndex].Center;

        for (int attempt = 0; attempt < maxPathAttempts; attempt++)
        {
            var path = CreateZigZagPath(from, to, attempt);
            bool invalid = false;

            if (avoidIntersections)
            {
                foreach (var p in path)
                {
                    if (corridorTiles.Contains(p))
                    {
                        invalid = true;
                        break;
                    }
                }
                if (!invalid)
                {
                    foreach (var p in path)
                    {
                        if (p == from || p == to) continue;
                        foreach (var d in CardinalDirs)
                        {
                            if (corridorTiles.Contains(p + d))
                            {
                                invalid = true;
                                break;
                            }
                        }
                        if (invalid) break;
                    }
                }
            }

            if (!invalid || attempt == maxPathAttempts - 1)
            {
                foreach (var p in path) corridorTiles.Add(p);
                return true;
            }
        }
        return false;
    }

    // Produces an axis-aligned polyline with optional zig-zag; converts to inclusive tile list.
    List<Vector2Int> CreateZigZagPath(Vector2Int from, Vector2Int to, int attemptSeed = 0)
    {
        var localRng = new System.Random((seed == 0 ? Environment.TickCount : seed) + attemptSeed + from.x * 37 + from.y * 91);

        int dx = to.x - from.x;
        int dy = to.y - from.y;
        int absX = Math.Abs(dx);
        int absY = Math.Abs(dy);
        int sx = Math.Sign(dx);
        int sy = Math.Sign(dy);

        bool preferX = absX >= absY;
        if (localRng.NextDouble() < 0.5) preferX = !preferX;
        bool zigzag = localRng.NextDouble() < zigzagChance && (preferX ? absX : absY) >= minTurnSpacing * 2;

        var points = new List<Vector2Int> { from };

        if (!zigzag)
        {
            if (preferX)
            {
                Vector2Int mid = new Vector2Int(to.x, from.y);
                if (localRng.NextDouble() < 0.5) mid = new Vector2Int(from.x, to.y);
                points.Add(mid);
            }
            else
            {
                Vector2Int mid = new Vector2Int(from.x, to.y);
                if (localRng.NextDouble() < 0.5) mid = new Vector2Int(to.x, from.y);
                points.Add(mid);
            }
            points.Add(to);
        }
        else
        {
            if (preferX)
            {
                int min = Math.Max(1, minTurnSpacing);
                int max = Math.Max(min, absX - minTurnSpacing);
                int advance1 = min;
                if (max > min) advance1 = localRng.Next(min, max + 1);
                int x1 = from.x + sx * advance1;
                Vector2Int p1 = new Vector2Int(x1, from.y);
                Vector2Int p2 = new Vector2Int(x1, to.y);
                points.Add(p1);
                points.Add(p2);
                points.Add(to);
            }
            else
            {
                int min = Math.Max(1, minTurnSpacing);
                int max = Math.Max(min, absY - minTurnSpacing);
                int advance1 = min;
                if (max > min) advance1 = localRng.Next(min, max + 1);
                int y1 = from.y + sy * advance1;
                Vector2Int p1 = new Vector2Int(from.x, y1);
                Vector2Int p2 = new Vector2Int(to.x, y1);
                points.Add(p1);
                points.Add(p2);
                points.Add(to);
            }
        }

        var tiles = new List<Vector2Int>();
        for (int i = 0; i < points.Count - 1; i++)
        {
            Vector2Int pA = points[i];
            Vector2Int pB = points[i + 1];

            if (pA.x == pB.x)
            {
                int x = pA.x;
                int syLine = Math.Sign(pB.y - pA.y);
                int len = Math.Abs(pB.y - pA.y);
                for (int t = 0; t <= len; t++)
                    tiles.Add(new Vector2Int(x, pA.y + t * syLine));
            }
            else if (pA.y == pB.y)
            {
                int y = pA.y;
                int sxLine = Math.Sign(pB.x - pA.x);
                int len = Math.Abs(pB.x - pA.x);
                for (int t = 0; t <= len; t++)
                    tiles.Add(new Vector2Int(pA.x + t * sxLine, y));
            }
            else
            {
                Vector2Int cur = pA;
                while (cur != pB)
                {
                    if (cur.x != pB.x)
                        cur.x += Math.Sign(pB.x - cur.x);
                    else if (cur.y != pB.y)
                        cur.y += Math.Sign(pB.y - cur.y);
                    tiles.Add(cur);
                }
            }
        }
        return tiles;
    }

    // Adds all room cells and corridor cells to unified occupancy set.
    void StampRoomsAndCorridorsToFloor()
    {
        foreach (var r in rooms)
        {
            for (int x = r.rect.x; x < r.rect.x + r.rect.width; x++)
            {
                for (int y = r.rect.y; y < r.rect.y + r.rect.height; y++)
                    floorTiles.Add(new Vector2Int(x, y));
            }
        }
        foreach (var p in corridorTiles)
            floorTiles.Add(p);
    }

    // Manhattan distance utility.
    int ManhattanDistance(Vector2Int a, Vector2Int b)
    {
        return Math.Abs(a.x - b.x) + Math.Abs(a.y - b.y);
    }

    // Instantiates tile prefabs based on connectivity analysis; handles start/goal overrides.
    public void InstantiatePrefabs(bool clearParent = true)
    {
        if (parentForTiles == null)
        {
            parentForTiles = new GameObject("GeneratedTiles").transform;
            parentForTiles.SetParent(this.transform, false);
        }

#if UNITY_EDITOR
        if (clearParent)
        {
            for (int i = parentForTiles.childCount - 1; i >= 0; i--)
            {
#if UNITY_EDITOR
                DestroyImmediate(parentForTiles.GetChild(i).gameObject);
#else
                Destroy(parentForTiles.GetChild(i).gameObject);
#endif
            }
        }
#endif

        foreach (var v in floorTiles)
        {
            GameObject prefab = null;
            Vector3 worldPos = new Vector3((v.x + 0.5f) * cellSize, 0f, (v.y + 0.5f) * cellSize);
            Quaternion rotation = Quaternion.identity;

            int roomIndex = rooms.FindIndex(r => r.Center == v);

            if (prefab == null)
            {
                int roomConnections = 0;
                foreach (var dir in CardinalDirs)
                {
                    if (floorTiles.Contains(v + dir))
                        roomConnections++;
                }
                if (tilePrefabsByType != null)
                {
                    int type = (int)SelectRoomType(v, ref rotation, roomConnections);
                    prefab = type != -1 ? tilePrefabsByType[type] : null;
                }
            }
            InstantiateTilePrefab(v, prefab, worldPos, rotation);
        }
    }

    // Determines tile classification and required rotation from its connectivity.
    TileType SelectRoomType(Vector2Int v, ref Quaternion rotation, int roomConnections)
    {
        if (roomConnections == 1)
        {
            DirectionBitMask mask = GetConnectionMask(v);
            if (mask.HasFlag(DirectionBitMask.North))
                rotation = Quaternion.Euler(0f, 180f, 0f);
            else if (mask.HasFlag(DirectionBitMask.East))
                rotation = Quaternion.Euler(0f, -90f, 0f);
            else if (mask.HasFlag(DirectionBitMask.South))
                rotation = Quaternion.Euler(0f, 0f, 0f);
            else if (mask.HasFlag(DirectionBitMask.West))
                rotation = Quaternion.Euler(0f, 90f, 0f);
            return TileType.Deadend;
        }
        else if (roomConnections == 2)
        {
            DirectionBitMask mask = GetConnectionMask(v);
            bool north = mask.HasFlag(DirectionBitMask.North);
            bool south = mask.HasFlag(DirectionBitMask.South);
            bool east = mask.HasFlag(DirectionBitMask.East);
            bool west = mask.HasFlag(DirectionBitMask.West);

            if ((north && east) || (east && south) || (south && west) || (west && north))
            {
                if (north && east)
                    rotation = Quaternion.Euler(0f, -90f, 0f);
                else if (east && south)
                    rotation = Quaternion.Euler(0f, 0f, 0f);
                else if (south && west)
                    rotation = Quaternion.Euler(0f, 90f, 0f);
                else if (west && north)
                    rotation = Quaternion.Euler(0f, 180f, 0f);
                return TileType.Corner;
            }
            else
            {
                if (north && south)
                    rotation = Quaternion.Euler(0f, 0f, 0f);
                else if (east && west)
                    rotation = Quaternion.Euler(0f, 90f, 0f);
                return TileType.Straight;
            }
        }
        else if (roomConnections == 3)
        {
            DirectionBitMask mask = GetConnectionMask(v);
            if (!mask.HasFlag(DirectionBitMask.North))
                rotation = Quaternion.Euler(0f, 0f, 0f);
            else if (!mask.HasFlag(DirectionBitMask.East))
                rotation = Quaternion.Euler(0f, 90f, 0f);
            else if (!mask.HasFlag(DirectionBitMask.South))
                rotation = Quaternion.Euler(0f, 180f, 0f);
            else if (!mask.HasFlag(DirectionBitMask.West))
                rotation = Quaternion.Euler(0f, 270f, 0f);
            return TileType.TJunction;
        }
        else if (roomConnections == 4)
        {
            return TileType.Crossroad;
        }
        return TileType.Error;
    }

    // Instantiates a single tile, scaling if configured, naming for debug.
    private void InstantiateTilePrefab(Vector2Int v, GameObject prefab, Vector3 worldPos, Quaternion rotation)
    {
        if (prefab != null)
        {
            var go = Instantiate(prefab, worldPos, rotation, parentForTiles);
            if (scalePrefabsToCell && prefabNativeSize > 0f)
            {
                float scaleFactor = cellSize / prefabNativeSize;
                go.transform.localScale = Vector3.one * scaleFactor;
            }
            int mask = (int)GetConnectionMask(v);
            go.name = $"Sewer_{v.x}_{v.y}_m{mask}";
        }
    }

    // Builds bitmask of connected neighbors in four directions.
    DirectionBitMask GetConnectionMask(Vector2Int pos)
    {
        DirectionBitMask mask = 0;
        if (floorTiles.Contains(pos + Vector2Int.up)) mask |= DirectionBitMask.North;
        if (floorTiles.Contains(pos + Vector2Int.right)) mask |= DirectionBitMask.East;
        if (floorTiles.Contains(pos + Vector2Int.down)) mask |= DirectionBitMask.South;
        if (floorTiles.Contains(pos + Vector2Int.left)) mask |= DirectionBitMask.West;
        return mask;
    }

    //void OnDrawGizmosSelected()
    //{
    //    if (!drawGizmos) return;

    //    Gizmos.color = Color.green;
    //    if (rooms != null)
    //    {
    //        for (int i = 0; i < rooms.Count; i++)
    //        {
    //            var r = rooms[i].rect;
    //            Vector3 pos = new Vector3((r.x + 0.5f) * cellSize, 0f, (r.y + 0.5f) * cellSize);
    //            Vector3 size = new Vector3(r.width * cellSize, cellSize * 0.05f, r.height * cellSize);
    //            Gizmos.DrawWireCube(pos, size);

    //            if (i == startRoomIndex) Gizmos.color = Color.cyan;
    //            Gizmos.DrawSphere(new Vector3((rooms[i].Center.x + 0.5f) * cellSize, 0f, (rooms[i].Center.y + 0.5f) * cellSize), cellSize * 0.125f);
    //            if (i == startRoomIndex) Gizmos.color = Color.green;
    //        }
    //    }

    //    Gizmos.color = Color.yellow;
    //    if (corridorTiles != null)
    //    {
    //        foreach (var t in corridorTiles)
    //            Gizmos.DrawCube(new Vector3((t.x + 0.5f) * cellSize, 0f, (t.y + 0.5f) * cellSize), Vector3.one * cellSize * 0.9f);
    //    }

    //    Gizmos.color = Color.gray;
    //    if (floorTiles != null)
    //    {
    //        foreach (var t in floorTiles)
    //            Gizmos.DrawWireCube(new Vector3((t.x + 0.5f) * cellSize, 0f, (t.y + 0.5f) * cellSize), Vector3.one * cellSize * 0.9f);
    //    }
    //}

    //void OnValidate()
    //{
    //    gridWidth = Math.Max(3, gridWidth);
    //    gridHeight = Math.Max(3, gridHeight);
    //    numRooms = Math.Max(1, numRooms);
    //    maxPlacementAttempts = Math.Max(1, maxPlacementAttempts);
    //    minTurnSpacing = Math.Max(1, minTurnSpacing);
    //    maxPathAttempts = Math.Max(1, maxPathAttempts);
    //    roomSpacing = Math.Max(0, roomSpacing);

    //    cellSize = Mathf.Max(0.01f, cellSize);
    //    prefabNativeSize = Mathf.Max(0.01f, prefabNativeSize);
    //}

    // Returns world position of escape tile center
    public Vector3 GetEscapePosition()
    {
        Vector3 pos = new Vector3();
        if (escapeRoomIndex >= 0 && escapeRoomIndex < rooms.Count)
        {
            Vector2Int escapePos = rooms[escapeRoomIndex].Center;
            pos = new Vector3((escapePos.x + 0.5f) * cellSize, 0f, (escapePos.y + 0.5f) * cellSize);
        }
        return pos;
    }
}
