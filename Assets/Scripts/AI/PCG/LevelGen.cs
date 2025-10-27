using System.Collections;
using System.Collections.Generic;
using System.Numerics;
using UnityEditor;
using UnityEngine;
using Quaternion = UnityEngine.Quaternion;
using Vector3 = UnityEngine.Vector3;


public enum Directions
{
    North,
    East,
    South,
    West
}


public class LevelGen : MonoBehaviour
{


    List<Vector3> gridPositions = new List<Vector3>();
    //new method, get random positions on a grid, find corners, send drunkard to make paths between them with varying amounts of straights and turns. dont connect every point or points too close together, just some. then retroactively instantiate appropriate sewer pieces along the paths.

    // Grid parameters
    public float nodeSpacing = 1.0f; // Distance between nodes, multiplier of node size so the corridors fit neatly.
    public float nodeSize; //(Grid cell size) Size of each node, used to calculate spacing and positions.

    public int gridSizeX; // Grid dimension in X direction.
    public int gridSizeY; // Grid dimension in Y direction.
    public float nodeChance; // Chance of a node being present at each grid position (0 to 1).
    public int minNodes; // Minimum number of nodes to ensure connectivity.

    // Sewer piece prefabs, one for each amount of connections, oriented retroactively later.
    public GameObject sewerDeadEnd; // 1 connection
    public GameObject sewerCorner; // 2 connections, 90 degree turn
    public GameObject sewerStraight; // 2 connections, straight line
    public GameObject sewerTJunction; // 3 connections

    public GameObject sewerConnections;

    List<Vector3> nodePositions = new List<Vector3>();

    // Start is called before the first frame update
    void Start()
    {
        //Initialise node positions layed out in a grid, with a random chance for some to be empty,
        //so a grid of n x n size with a node chance of p and a min number of nodes m.
        //connections between nodes will be no more than 3 per node, and at least 1,
        //all nodes will need to be connected to the 'sewer' network, with some dead ends possible.


        nodeSpacing = nodeSize * nodeSpacing; // Ensure spacing matches node size for neat fitting
        
        // Generate grid positions with random node placement
        for (int i = 0; i < gridSizeX; i++)
        {
            for (int j = 0; j < gridSizeY; j++)
            {
                if (Random.value <= nodeChance)
                {
                    Vector3 nodePos = new Vector3(i * nodeSpacing, 0, j * nodeSpacing);
                    nodePositions.Add(nodePos);
                }
            }
        }

        // Ensure minimum number of nodes, and all nodes are connected at least once
        while (nodePositions.Count < minNodes)
        {
            int i = Random.Range(0, gridSizeX);
            int j = Random.Range(0, gridSizeY);
            Vector3 nodePos = new Vector3(i * nodeSpacing, 0, j * nodeSpacing);
            if (!nodePositions.Contains(nodePos))
            {
                nodePositions.Add(nodePos);
            }
            
        }





        // For debugging: visualize node positions
        foreach (Vector3 pos in nodePositions)
        {
            GameObject marker = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            marker.transform.position = pos;
            marker.transform.localScale = Vector3.one * (nodeSize / 2);
            marker.GetComponent<Renderer>().material.color = Color.red;
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    Directions randomDir()
    {
        Directions dir = (Directions)Random.Range(0, 4);

        return dir;
    }
}
