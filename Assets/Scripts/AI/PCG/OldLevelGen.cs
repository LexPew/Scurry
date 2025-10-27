//using System.Collections;
//using System.Collections.Generic;
//using System.Numerics;
//using UnityEditor;
//using UnityEngine;
//using Quaternion = UnityEngine.Quaternion;
//using Vector3 = UnityEngine.Vector3;


//public enum Directions
//{
//    North,
//    East,
//    South,
//    West
//}


//public class OldLevelGen : MonoBehaviour
//{


//    List<Vector3> gridPositions = new List<Vector3>();
//    //new method, get random positions on a grid, find corners, send drunkard to make paths between them with varying amounts of straights and turns. dont connect every point or points too close together, just some. then retroactively instantiate appropriate sewer pieces along the paths.




//    public int steps = 5;
//    public int gridSize = 20;
//    public int maxSewerSize = 20;
//    public int nodeCount = 5;
//    public GameObject sewerStraight;

//    List<Vector3> nodePositions = new List<Vector3>();

//    // Start is called before the first frame update
//    void Start()
//    {

//        //node position generation
//        for (int i = 0; i < nodeCount; i++)
//        {
//            Vector3 newNodePos = new Vector3(
//                Random.Range(-gridSize * maxSewerSize / 2, gridSize * maxSewerSize / 2),
//                0,
//                Random.Range(-gridSize * maxSewerSize / 2, gridSize * maxSewerSize / 2)
//                );
//            //snap to grid
//            newNodePos.x = Mathf.Round(newNodePos.x / gridSize) * gridSize;
//            newNodePos.z = Mathf.Round(newNodePos.z / gridSize) * gridSize;
//            //check if position is already taken
//            if (nodePositions.Contains(newNodePos))
//            {
//                i--;
//                continue;
//            }
//            nodePositions.Add(newNodePos);
//            Instantiate(sewerStraight, newNodePos, Quaternion.identity);
//        }

//        //sewer path generation between nodes
//        for (int i = 0; i < nodePositions.Count; i++)
//        {
//            for (int j = i + 1; j < nodePositions.Count; j++)
//            {
//                if (i == j) continue;
//                if (Vector3.Distance(nodePositions[i], nodePositions[j]) < gridSize * 2)
//                {
//                    //skip if nodes are too close together
//                    continue;
//                }
//                //if only a few nodes, connect all
//                if (nodeCount <= 4)
//                {
//                    SendDrunkard(nodePositions, i, j);
//                    continue;
//                }
//                //random chance to connect nodes
//                if (Random.value < 0.5f)
//                {
//                    SendDrunkard(nodePositions, i, j);
//                }
//            }
//        }




//        //    //New good list method
//        //    //add initial position at the script parents location
//        //    gridPositions.Add(transform.position);
//        //    for(int i = 0; i < steps; i++)
//        //    {
//        //        Vector3 newPos = gridPositions[gridPositions.Count - 1];

//        //        switch (randomDir())
//        //            {
//        //                case Directions.North:
//        //                    if (
//        //                        //check if upcoming position is already in list
//        //                        gridPositions.Contains(newPos + new Vector3(0, 0, gridSize))
//        //                        //or within one grid space of another position in the list
//        //                        || gridPositions.Contains(newPos + new Vector3(gridSize, 0, gridSize))
//        //                        || gridPositions.Contains(newPos + new Vector3(-gridSize, 0, gridSize))
//        //                        || gridPositions.Contains(newPos + new Vector3(0, 0, gridSize * 2))
//        //                        )
//        //                    {
//        //                        i--;
//        //                        continue;
//        //                    }

//        //                    newPos += new Vector3(0, 0, gridSize);

//        //                    break;
//        //                case Directions.East:
//        //                    if (
//        //                        gridPositions.Contains(newPos + new Vector3(gridSize, 0, 0))
//        //                        || gridPositions.Contains(newPos + new Vector3(gridSize, 0, gridSize))
//        //                        || gridPositions.Contains(newPos + new Vector3(gridSize, 0, -gridSize))
//        //                        || gridPositions.Contains(newPos + new Vector3(gridSize * 2, 0, 0))
//        //                        )
//        //                    {
//        //                        i--;
//        //                        continue;
//        //                    }
//        //                    newPos += new Vector3(gridSize, 0, 0);
//        //                    break;
//        //                case Directions.South:
//        //                    if (
//        //                        gridPositions.Contains(newPos + new Vector3(0, 0, -gridSize))
//        //                        || gridPositions.Contains(newPos + new Vector3(gridSize, 0, -gridSize))
//        //                        || gridPositions.Contains(newPos + new Vector3(-gridSize, 0, -gridSize))
//        //                        || gridPositions.Contains(newPos + new Vector3(0, 0, -gridSize * 2))
//        //                        )
//        //                    {
//        //                        i--;
//        //                        continue;
//        //                    }
//        //                    newPos += new Vector3(0, 0, -gridSize);
//        //                    break;
//        //                case Directions.West:
//        //                    if (
//        //                        gridPositions.Contains(newPos + new Vector3(-gridSize, 0, 0))
//        //                        || gridPositions.Contains(newPos + new Vector3(-gridSize, 0, gridSize))
//        //                        || gridPositions.Contains(newPos + new Vector3(-gridSize, 0, -gridSize))
//        //                        || gridPositions.Contains(newPos + new Vector3(-gridSize * 2, 0, 0))
//        //                        )
//        //                    {
//        //                        i--;
//        //                        continue;
//        //                    }
//        //                    newPos += new Vector3(-gridSize, 0, 0);
//        //                    break;
//        //            }
//        //        gridPositions.Add(newPos);
//        //        Instantiate(sewerStraight, newPos, Quaternion.identity);

//        //    }
//    }

//    // Update is called once per frame
//    void Update()
//    {

//    }

//    Directions randomDir()
//    {
//        Directions dir = (Directions)Random.Range(0, 4);

//        return dir;
//    }

//    // Pseudocode / Plan (detailed):
//    // 1. Inputs: nodePosList, indices p1/p2, optional maxSteps and straightChance
//    // 2. Compute startPos and endPos (both snapped to grid).
//    // 3. Determine an initial facing direction biased toward the end node (prefer axis with larger delta).
//    // 4. Keep a HashSet of visited positions (include start).
//    // 5. Loop up to maxSteps:
//    //    a. If current == end -> break (path complete).
//    //    b. Choose a move: straight, turn left, or turn right using straightChance weight.
//    //       - Probabilities: straight = straightChance, left = (1-straightChance)/2, right = same.
//    //       - Never choose a reverse/backwards direction.
//    //    c. Compute candidate next position for chosen direction.
//    //    d. If candidate is invalid (visited or would collide), try fallbacks in priority order:
//    //         straight -> left -> right -> (optionally greedy toward end).
//    //    e. If no valid candidate is found -> attempt a greedy step toward end (pick the direction that reduces Manhattan distance).
//    //    f. If still no valid move -> abort.
//    //    g. Add chosen candidate to visited, instantiate sewerStraight at candidate with rotation matching move direction.
//    //    h. Update current position and facing direction.
//    // 6. End with path either reaching end or stopping early.
//    // Notes:
//    // - Positions are grid-aligned multiples of gridSize; exact comparisons are safe.
//    // - Instantiation uses existing sewerStraight prefab; rotation is set to face the movement direction on the XZ plane.
//    // - Method uses default parameters for maxSteps and straightChance but they can be tuned when called.

//    private void SendDrunkard(List<Vector3> nodePosList, int p1, int p2, int maxSteps = 256, float straightChance = 0.6f)
//    {
//        //ensure positions are snapped to grid
//        Vector3 startPos = nodePosList[p1];
//        Vector3 endPos = nodePosList[p2];

//        startPos.x = Mathf.Round(startPos.x / gridSize) * gridSize;
//        startPos.z = Mathf.Round(startPos.z / gridSize) * gridSize;
//        endPos.x = Mathf.Round(endPos.x / gridSize) * gridSize;
//        endPos.z = Mathf.Round(endPos.z / gridSize) * gridSize;

//        //determine initial facing direction biased toward end node
//        Vector3 delta = endPos - startPos;
//        Directions facing;
//        if (Mathf.Abs(delta.x) > Mathf.Abs(delta.z))
//        {
//            facing = delta.x > 0 ? Directions.East : Directions.West;
//        }
//        else
//        {
//            facing = delta.z > 0 ? Directions.North : Directions.South;
//        }

//        HashSet<Vector3> visited = new HashSet<Vector3>();
//        visited.Add(startPos);
//        Vector3 currentPos = startPos;
//        for (int step = 0; step < maxSteps; step++)
//        {
//            if (currentPos == endPos)
//            {
//                break; // Path complete
//            }
//            // Choose move direction
//            Directions moveDir;
//            float roll = Random.value;
//            if (roll < straightChance)
//            {
//                moveDir = facing; // Straight
//            }
//            else if (roll < straightChance + (1 - straightChance) / 2)
//            {
//                //turn left
//                moveDir = facing switch
//                {
//                    Directions.North => Directions.West,
//                    Directions.East => Directions.North,
//                    Directions.South => Directions.East,
//                    Directions.West => Directions.South,
//                    _ => facing
//                };
//            }
//            else
//            {
//                //turn right
//                moveDir = facing switch
//                {
//                    Directions.North => Directions.East,
//                    Directions.East => Directions.South,
//                    Directions.South => Directions.West,
//                    Directions.West => Directions.North,
//                    _ => facing
//                };
//            }
//            // Compute candidate position
//            visited.Add(currentPos);
//            Vector3 candidatePos = currentPos;
//            switch (moveDir)
//            {
//                case Directions.North:
//                    candidatePos += new Vector3(0, 0, gridSize);
//                    break;
//                case Directions.East:
//                    candidatePos += new Vector3(gridSize, 0, 0);
//                    break;
//                case Directions.South:
//                    candidatePos += new Vector3(0, 0, -gridSize);
//                    break;
//                case Directions.West:
//                    candidatePos += new Vector3(-gridSize, 0, 0);
//                    break;
//            }
//            // Validate candidate
//            if (visited.Contains(candidatePos))
//            {
//                //try fallbacks
//                List<Directions> fallbacks = new List<Directions>();
//                fallbacks.Add(facing); //straight
//                //left
//                fallbacks.Add(facing switch
//                {
//                    Directions.North => Directions.West,
//                    Directions.East => Directions.North,
//                    Directions.South => Directions.East,
//                    Directions.West => Directions.South,
//                    _ => facing
//                });
//                //right
//                fallbacks.Add(facing switch
//                {
//                    Directions.North => Directions.East,
//                    Directions.East => Directions.South,
//                    Directions.South => Directions.West,
//                    Directions.West => Directions.North,
//                    _ => facing
//                });
//                bool foundValid = false;
//                foreach (var fbDir in fallbacks)
//                {
//                    Vector3 fbCandidate = currentPos;
//                    switch (fbDir)
//                    {
//                        case Directions.North:
//                            fbCandidate += new Vector3(0, 0, gridSize);
//                            break;
//                        case Directions.East:
//                            fbCandidate += new Vector3(gridSize, 0, 0);
//                            break;
//                        case Directions.South:
//                            fbCandidate += new Vector3(0, 0, -gridSize);
//                            break;
//                        case Directions.West:
//                            fbCandidate += new Vector3(-gridSize, 0, 0);
//                            break;
//                    }
//                    if (!visited.Contains(fbCandidate))
//                    {
//                        candidatePos = fbCandidate;
//                        moveDir = fbDir;
//                        foundValid = true;
//                        break;
//                    }
//                }
//                if (!foundValid)
//                {
//                    //attempt greedy step toward end
//                    List<Directions> greedyDirs = new List<Directions>();
//                    if (endPos.x > currentPos.x) greedyDirs.Add(Directions.East);
//                    if (endPos.x < currentPos.x) greedyDirs.Add(Directions.West);
//                    if (endPos.z > currentPos.z) greedyDirs.Add(Directions.North);
//                    if (endPos.z < currentPos.z) greedyDirs.Add(Directions.South);
//                    foundValid = false;
//                    foreach (var gDir in greedyDirs)
//                    {
//                        Vector3 gCandidate = currentPos;
//                        switch (gDir)
//                        {
//                            case Directions.North:
//                                gCandidate += new Vector3(0, 0, gridSize);
//                                break;
//                            case Directions.East:
//                                gCandidate += new Vector3(gridSize, 0, 0);
//                                break;
//                            case Directions.South:
//                                gCandidate += new Vector3(0, 0, -gridSize);
//                                break;
//                            case Directions.West:
//                                gCandidate += new Vector3(-gridSize, 0, 0);
//                                break;
//                        }
//                        if (!visited.Contains(gCandidate))
//                        {
//                            candidatePos = gCandidate;
//                            moveDir = gDir;
//                            foundValid = true;
//                            break;
//                        }
//                    }
//                    if (!foundValid)
//                    {
//                        Debug.Log("Drunkard path aborted: no valid moves available.");
//                        break; // Abort path
//                    }
//                }
//            }
//            // Instantiate sewer piece
//            Quaternion rotation = Quaternion.identity;
//            if (rotation != Quaternion.identity)
//            {
//                rotation = Quaternion.Inverse(rotation);
//            }
//            switch (moveDir)
//            {
//                case Directions.North:
//                    rotation = Quaternion.Euler(0, 0, 0);
//                    break;
//                case Directions.East:
//                    rotation = Quaternion.Euler(0, 90, 0);
//                    break;
//                case Directions.South:
//                    rotation = Quaternion.Euler(0, 180, 0);
//                    break;
//                case Directions.West:
//                    rotation = Quaternion.Euler(0, 270, 0);
//                    break;
//            }
//            Instantiate(sewerStraight, candidatePos, rotation);
//            //add to grid positions
//            gridPositions.Add(candidatePos);
//            // Update current position and facing
//            currentPos = candidatePos;
//            facing = moveDir;
//        }
//    }
//}
