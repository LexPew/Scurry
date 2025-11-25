using System.Collections.Generic;
using System;
using Unity.AI.Navigation;
using UnityEngine;

public enum Directions
{
    North,
    East,
    South,
    West
}

[Serializable]
public struct Room
{
    // Rooms are now one grid cell (1x1 RectInt). Keep RectInt for minimal API changes.
    public RectInt rect;
    public Vector2Int Center => new Vector2Int(rect.x + rect.width / 2, rect.y + rect.height / 2);

    public Room(RectInt r)
    {
        rect = r;
    }
}

public class LevelGen : MonoBehaviour
{
    [Header("Grid")]
    public int gridWidth = 100;
    public int gridHeight = 60;
    public float cellSize = 20f; // world units per grid cell (prefabs are currently 20 units square)

    [Header("Rooms")]
    public int numRooms = 12;
    public int maxPlacementAttempts = 250;
    public int roomSpacing = 1; // Chebyshev distance between single-tile rooms

    [Header("Corridors")]
    public int minTurnSpacing = 3; // minimum straight length between turns
    [Range(0f, 1f)]
    public float zigzagChance = 0.45f; // chance to introduce extra turns
    public bool avoidIntersections = true;
    public int maxPathAttempts = 6;

    //--- Nesting Logic --- // James
    [Header("Nests")]
    [SerializeField] private GameObject nestPrefab;
    [SerializeField] private int nestCount = 5;


    [Header("Player")]
    [SerializeField] private GameObject playerPrefab;

    [Header("Seed (0 => random)")]
    public int seed = 0;

    // Results
    public List<Room> rooms = new List<Room>();
    public HashSet<Vector2Int> corridorTiles = new HashSet<Vector2Int>();
    public HashSet<Vector2Int> floorTiles = new HashSet<Vector2Int>(); // now represents all occupied sewer grid tiles

    [Header("Prefabs (index by connection bitmask: N=1, E=2, S=4, W=8)")]
    [Tooltip("Provide a prefab for each connection mask (0..15). If a slot is empty, DefaultTilePrefab will be used.")]
    public GameObject[] tilePrefabsByConnection = new GameObject[16];
    //Better System for prefabs 5 instead of 16
    [Header("Prefabs (index by type)")]
    [Tooltip("Provide a prefab for each tile type (0=straight,1=corner,2=tjunction,3=crossroad,4=deadend). If a slot is empty, DefaultTilePrefab will be used.")]
    public GameObject[] tilePrefabsByType = new GameObject[5]; // 0=straight,1=corner,2=tjunction,3=crossroad,4=deadend ALL PREFABS FACE Z FORWARD BY DEFAULT
    public GameObject DefaultTilePrefab;
    public GameObject StartPrefab;
    public GameObject GoalPrefab;

    [Tooltip("Native square size (in world units) that prefabs were authored at. Used to auto-scale prefabs to `cellSize`.")]
    public float prefabNativeSize = 20f;
    public bool scalePrefabsToCell = true;

    [Header("Debug / Instantiation")]
    public Transform parentForTiles;
    public bool drawGizmos = true;
    public bool autoGenerateOnStart = true;
    public bool instantiateOnGenerate = true; // instantiate generated tiles automatically

    // Start and Goal indices
    public int startRoomIndex = -1;
    public int goalRoomIndex = -1;

    private System.Random rng;

    // Cardinal dirs for adjacency checks (N,E,S,W)
    private static readonly Vector2Int[] CardinalDirs = new[] { Vector2Int.up, Vector2Int.right, Vector2Int.down, Vector2Int.left };

    void Awake()
    {
        if (autoGenerateOnStart)
        {
            Generate();


            // Build NavMesh after generation
            NavMeshSurface surface = GetComponent<NavMeshSurface>();
            surface.BuildNavMesh();
            //Place nests
            List<int> usedRooms = new List<int>();
            for (int i = 0; i < nestCount; i++)
            {
                //Edge case: not enough rooms to place nests
                if (rooms.Count <= 2)
                    break;

                //Pick a random room that hasn't been used yet, never pick the start or goal room
                int roomIndex = UnityEngine.Random.Range(1, rooms.Count - 1);
                while (usedRooms.Contains(roomIndex))
                {
                    roomIndex = UnityEngine.Random.Range(1, rooms.Count - 1);
                }
                usedRooms.Add(roomIndex);
                Vector2Int roomCenter = rooms[roomIndex].Center;
                Vector3 nestPos = new Vector3((roomCenter.x + 0.5f) * cellSize, 0f, (roomCenter.y + 0.5f) * cellSize);
                Instantiate(nestPrefab, nestPos, Quaternion.identity, transform);
            }

            //Place Player at start position
            if (playerPrefab != null)
            {
                Vector3 startPos = GetStartPosition();
                Instantiate(playerPrefab, startPos + Vector3.up * 2.0f, Quaternion.identity);
            }
        }

    }

    public void Generate()
    {
        rng = seed == 0 ? new System.Random() : new System.Random(seed);
        rooms.Clear();
        corridorTiles.Clear();
        floorTiles.Clear();
        startRoomIndex = goalRoomIndex = -1;

        PlaceRoomsAsSingleTiles();
        PickStartAndGoal();
        ConnectRooms();
        StampRoomsAndCorridorsToFloor();

        // instantiate tiles automatically if requested
        if (instantiateOnGenerate)
            InstantiatePrefabs();
    }

    void PlaceRoomsAsSingleTiles()
    {
        // Rooms are placed as 1x1 rectangles (crossroads). Use roomSpacing to avoid clustering if desired.
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
                // Chebyshev distance check (includes diagonals) - if within roomSpacing then reject
                int dx = Math.Abs(r.rect.x - candidate.x);
                int dy = Math.Abs(r.rect.y - candidate.y);
                if (Math.Max(dx, dy) <= roomSpacing)
                {
                    overlaps = true;
                    break;
                }
            }

            if (!overlaps)
            {
                rooms.Add(new Room(candidate));

            }
        }

        // If not enough rooms, try a looser placement (best-effort)
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

    void PickStartAndGoal()
    {
        if (rooms.Count == 0) return;

        // Pick two rooms that are farthest apart (Manhattan)
        int bestA = 0, bestB = 0;
        int bestDist = -1;
        for (int i = 0; i < rooms.Count; i++)
        {
            for (int j = i + 1; j < rooms.Count; j++)
            {
                int d = ManhattanDistance(rooms[i].Center, rooms[j].Center);
                if (d > bestDist)
                {
                    bestDist = d;
                    bestA = i;
                    bestB = j;
                }
            }
        }

        startRoomIndex = bestA;
        goalRoomIndex = bestB;
    }

    void ConnectRooms()
    {
        // Attempt connections per-room per-cardinal direction to nearest neighbor.
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
                        // Create corridor between rooms[i] and rooms[j]
                        TryCreateCorridorBetweenRooms(i, j);
                        // Mark as attempted
                        connectedPairs.Add(pair);
                    }
                }
            }
        }
    }

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

    bool TryCreateCorridorBetweenRooms(int aIndex, int bIndex)
    {
        Vector2Int from = rooms[aIndex].Center;
        Vector2Int to = rooms[bIndex].Center;
        // Try several path generation attempts, prefer non-intersecting ones.
        for (int attempt = 0; attempt < maxPathAttempts; attempt++)
        {
            var path = CreateZigZagPath(from, to, attempt);
            bool invalid = false;

            if (avoidIntersections)
            {
                // 1) Reject any path that would overlap an existing corridor tile
                foreach (var p in path)
                {
                    if (corridorTiles.Contains(p))
                    {
                        invalid = true;
                        break;
                    }
                }

                // 2) Reject paths that would run adjacent (4-neighbor) to an existing corridor tile
                //    except at the two endpoints (we allow rooms to be adjacent to existing corridors).
                if (!invalid)
                {
                    foreach (var p in path)
                    {
                        if (p == from || p == to) continue; // endpoints may touch existing corridors (room connections)
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

    List<Vector2Int> CreateZigZagPath(Vector2Int from, Vector2Int to, int attemptSeed = 0)
    {
        // Create a path composed of straight segments (axis-aligned).
        var localRng = new System.Random((seed == 0 ? Environment.TickCount : seed) + attemptSeed + from.x * 37 + from.y * 91);

        int dx = to.x - from.x;
        int dy = to.y - from.y;
        int absX = Math.Abs(dx);
        int absY = Math.Abs(dy);
        int sx = Math.Sign(dx);
        int sy = Math.Sign(dy);

        // Decide primary axis (the larger delta) and whether we start with X or Y
        bool preferX = absX >= absY;
        // Sometimes flip to add variety
        if (localRng.NextDouble() < 0.5) preferX = !preferX;

        // With zigzagChance, split the primary axis into two segments so path goes primary -> secondary -> primary (2 turns).
        bool zigzag = localRng.NextDouble() < zigzagChance && (preferX ? absX : absY) >= minTurnSpacing * 2;

        var points = new List<Vector2Int>();
        points.Add(from);

        if (!zigzag)
        {
            // Single turn path (or straight if one delta is zero)
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
            // Zig-zag: split primary axis into two segments with a secondary segment in the middle.
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

        // Convert points into tile list (inclusive of endpoints, axis-aligned lines)
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
                {
                    tiles.Add(new Vector2Int(x, pA.y + t * syLine));
                }
            }
            else if (pA.y == pB.y)
            {
                int y = pA.y;
                int sxLine = Math.Sign(pB.x - pA.x);
                int len = Math.Abs(pB.x - pA.x);
                for (int t = 0; t <= len; t++)
                {
                    tiles.Add(new Vector2Int(pA.x + t * sxLine, y));
                }
            }
            else
            {
                // Guard: convert to Manhattan interpolation (shouldn't happen)
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

    void StampRoomsAndCorridorsToFloor()
    {
        // Mark room tiles (each room is 1x1)
        foreach (var r in rooms)
        {
            for (int x = r.rect.x; x < r.rect.x + r.rect.width; x++)
            {
                for (int y = r.rect.y; y < r.rect.y + r.rect.height; y++)
                {
                    floorTiles.Add(new Vector2Int(x, y));
                }
            }
        }

        // Add corridors into floor
        foreach (var p in corridorTiles) floorTiles.Add(p);
    }

    int ManhattanDistance(Vector2Int a, Vector2Int b)
    {
        return Math.Abs(a.x - b.x) + Math.Abs(a.y - b.y);
    }

    // Instantiate sewer tile prefabs based on connectivity bitmask (N=1, E=2, S=4, W=8).
    // Start/Goal prefab overrides the mapped prefab if provided.
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
            // Remove previously created children in editor/runtime for re-instantiation.
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
            // If this tile is the start or goal room, prefer those prefabs when assigned.
            int roomIndex = rooms.FindIndex(r => r.Center == v);
            if (roomIndex >= 0)
            {
                if (roomIndex == startRoomIndex && StartPrefab != null)
                    prefab = StartPrefab;
                else if (roomIndex == goalRoomIndex && GoalPrefab != null)
                    prefab = GoalPrefab;
            }

            //New system for prefabs ---James Munnis---
            if (prefab == null)
            {
                //This is a simple system based on number of connections
                int roomConnections = 0;
                //Loop through each direction around the tile and check for connections
                foreach (var dir in CardinalDirs)
                {
                    //Floor tiles hashset contains all occupied tiles (rooms + corridors)
                    if (floorTiles.Contains(v + dir))
                    {
                        roomConnections++;
                    }
                }

                //Use the room connections to determine the prefab type and also rotation for corners, t-junctions, and deadends
                if (tilePrefabsByType != null)
                {

                    //Deadend as there is only one connection
                    if (roomConnections == 1)
                    {
                        prefab = tilePrefabsByType[4];
                    }
                    //Straight connecting two rooms
                    else if (roomConnections == 2)
                    {
                        //Check if it's a corner or straight
                        int mask = GetConnectionMask(v);
                        if (mask == 3 || mask == 6 || mask == 9 || mask == 12) //Corners: NE, ES, SW, WN
                        {
                            prefab = tilePrefabsByType[1]; //Corner
                            //Determine rotation based on connection mask
                            if (mask == 3) //North And East
                            {
                                rotation = Quaternion.Euler(0f, -90f, 0f);
                            }
                            else if (mask == 6) //East And South
                            {
                                rotation = Quaternion.Euler(0f, 0f, 0f);
                            }
                            else if (mask == 9) //South And West
                            {
                                rotation = Quaternion.Euler(0f, -180, 0f);
                            }
                            else if (mask == 12) //West And North
                            {
                                rotation = Quaternion.Euler(0f, 90, 0f);
                            }
                        }
                        //Straight connection
                        else
                        {
                            prefab = tilePrefabsByType[0]; //Straight by default
                                                           //Figure out what rotation by default the prefab should face north forward 
                                                           //Determine rotation by default the prefabs open ends are z axis

                            if (mask == 15 - 5) //EW 0101
                            {
                                rotation = Quaternion.Euler(0f, 90f, 0f);
                            }
                        }
                    }
                    //T Section joining three rooms
                    else if (roomConnections == 3)
                    {
                        prefab = tilePrefabsByType[2];
                        //Determine rotation based on missing connection
                        int mask = GetConnectionMask(v);
                        if (mask == 7) //Missing West 1110
                        {
                            rotation = Quaternion.Euler(0f, -90f, 0f);
                        }
                        else if (mask == 11) //Missing South 1011
                        {
                            rotation = Quaternion.Euler(0f, -180f, 0f);
                        }
                        else if (mask == 13) //Missing East
                        {
                            rotation = Quaternion.Euler(0f, 90, 0f);
                        }
                        else if (mask == 14) //Missing North
                        {
                            rotation = Quaternion.Euler(0f, 0, 0f);
                        }
                    }
                    else if (roomConnections == 4)
                    {
                        prefab = tilePrefabsByType[3]; //Crossroad
                    }


                }


            }
            //Instantiate the prefab if assigned
            if (prefab != null)
            {
                var go = Instantiate(prefab, worldPos, rotation, parentForTiles);

                // optionally scale the prefab to match the configured cell size
                if (scalePrefabsToCell && prefabNativeSize > 0f)
                {
                    float scaleFactor = cellSize / prefabNativeSize;
                    go.transform.localScale = Vector3.one * scaleFactor;
                }

                int mask = GetConnectionMask(v);
                go.name = $"Sewer_{v.x}_{v.y}_m{mask}";
            }
        }
    }

    int GetConnectionMask(Vector2Int pos)
    {
        int mask = 0;
        // North = 1, East = 2, South = 4, West = 8
        if (floorTiles.Contains(pos + Vector2Int.up)) mask |= 1; //This returns a bitmask based on connections, this one for example checks north and returns 1 if connected aka fthe bits 0001
        if (floorTiles.Contains(pos + Vector2Int.right)) mask |= 2; //Bits 0010
        if (floorTiles.Contains(pos + Vector2Int.down)) mask |= 4; //Bits 0100
        if (floorTiles.Contains(pos + Vector2Int.left)) mask |= 8; //Bits 1000
        return mask;
    }

    void OnDrawGizmosSelected()
    {
        if (!drawGizmos) return;

        // Draw rooms (single-tile crossroads)
        Gizmos.color = Color.green;
        if (rooms != null)
        {
            for (int i = 0; i < rooms.Count; i++)
            {
                var r = rooms[i].rect;
                Vector3 pos = new Vector3((r.x + 0.5f) * cellSize, 0f, (r.y + 0.5f) * cellSize);
                Vector3 size = new Vector3(r.width * cellSize, cellSize * 0.05f, r.height * cellSize);
                Gizmos.DrawWireCube(pos, size);

                // start / goal markers
                if (i == startRoomIndex) Gizmos.color = Color.cyan;
                Gizmos.DrawSphere(new Vector3((rooms[i].Center.x + 0.5f) * cellSize, 0f, (rooms[i].Center.y + 0.5f) * cellSize), cellSize * 0.125f);
                if (i == startRoomIndex) Gizmos.color = Color.green;
            }
        }

        // Draw corridors / occupied tiles
        Gizmos.color = Color.yellow;
        if (corridorTiles != null)
        {
            foreach (var t in corridorTiles)
            {
                Gizmos.DrawCube(new Vector3((t.x + 0.5f) * cellSize, 0f, (t.y + 0.5f) * cellSize), Vector3.one * cellSize * 0.9f);
            }
        }

        // Draw floor / occupied tiles outlines
        Gizmos.color = Color.gray;
        if (floorTiles != null)
        {
            foreach (var t in floorTiles)
            {
                Gizmos.DrawWireCube(new Vector3((t.x + 0.5f) * cellSize, 0f, (t.y + 0.5f) * cellSize), Vector3.one * cellSize * 0.9f);
            }
        }
    }

    void OnValidate()
    {
        // Ensure the prefab array has 16 entries for the 4-bit connection masks.
        if (tilePrefabsByConnection == null || tilePrefabsByConnection.Length != 16)
        {
            var tmp = new GameObject[16];
            if (tilePrefabsByConnection != null)
            {
                Array.Copy(tilePrefabsByConnection, tmp, Math.Min(tilePrefabsByConnection.Length, tmp.Length));
            }
            tilePrefabsByConnection = tmp;
        }

        gridWidth = Math.Max(3, gridWidth);
        gridHeight = Math.Max(3, gridHeight);
        numRooms = Math.Max(1, numRooms);
        maxPlacementAttempts = Math.Max(1, maxPlacementAttempts);
        minTurnSpacing = Math.Max(1, minTurnSpacing);
        maxPathAttempts = Math.Max(1, maxPathAttempts);
        roomSpacing = Math.Max(0, roomSpacing);

        // Validate float sizes
        cellSize = Mathf.Max(0.01f, cellSize);
        prefabNativeSize = Mathf.Max(0.01f, prefabNativeSize);
    }

    //--- Getters --- // -- James Munnis
    public Vector3 GetStartPosition()
    {
        if (startRoomIndex >= 0 && startRoomIndex < rooms.Count)
        {
            Vector2Int center = rooms[startRoomIndex].Center;
            return new Vector3((center.x + 0.5f) * cellSize, 0f, (center.y + 0.5f) * cellSize);
        }
        else
        {
            return Vector3.zero;
        }
    }
}