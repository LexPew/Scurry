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
    //Dumb bad grid
    /*private int gridSize = 20;

    public GameObject sewerStraight;

    public Vector2 dPos = new Vector2(6,6);
    public int steps = 5;


    private int[,] grid = new int[11, 11]
    {
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    };*/

    //new good list


    List<Vector3> gridPositions = new List<Vector3>();


    public int steps = 5;
    public int gridSize = 20;
    public GameObject sewerStraight;


    // Start is called before the first frame update
    void Start()
    {


        //Dumb bad grid method
        /*for (int i = 0; i < steps; i++)
        {
            grid[(int)dPos.y, (int)dPos.x] = 1;

            Instantiate(sewerStraight, new Vector3((dPos.x) * gridSize, 0, (dPos.y) * gridSize), Quaternion.identity);

            switch (randomDir())
            {
                case Directions.North:
                    dPos += new Vector2(0, 1);
                    break;
                case Directions.East:
                    dPos += new Vector2(1, 0);
                    break;
                case Directions.South:
                    dPos += new Vector2(0, -1);
                    break;
                case Directions.West:
                    dPos += new Vector2(-1, 0);
                    break;

            }
        }*/

        //New good list method
        //add initial position at the script parents location
        gridPositions.Add(transform.position);
        for(int i = 0; i < steps; i++)
        {
            Vector3 newPos = gridPositions[gridPositions.Count - 1];

            switch (randomDir())
                {
                    case Directions.North:
                        if (
                            //check if upcoming position is already in list
                            gridPositions.Contains(newPos + new Vector3(0, 0, gridSize))
                            //or within one grid space of another position in the list
                            || gridPositions.Contains(newPos + new Vector3(gridSize, 0, gridSize))
                            || gridPositions.Contains(newPos + new Vector3(-gridSize, 0, gridSize))
                            || gridPositions.Contains(newPos + new Vector3(0, 0, gridSize * 2))
                            )
                        {
                            i--;
                            continue;
                        }

                        newPos += new Vector3(0, 0, gridSize);

                        break;
                    case Directions.East:
                        if (
                            gridPositions.Contains(newPos + new Vector3(gridSize, 0, 0))
                            || gridPositions.Contains(newPos + new Vector3(gridSize, 0, gridSize))
                            || gridPositions.Contains(newPos + new Vector3(gridSize, 0, -gridSize))
                            || gridPositions.Contains(newPos + new Vector3(gridSize * 2, 0, 0))
                            )
                        {
                            i--;
                            continue;
                        }
                        newPos += new Vector3(gridSize, 0, 0);
                        break;
                    case Directions.South:
                        if (
                            gridPositions.Contains(newPos + new Vector3(0, 0, -gridSize))
                            || gridPositions.Contains(newPos + new Vector3(gridSize, 0, -gridSize))
                            || gridPositions.Contains(newPos + new Vector3(-gridSize, 0, -gridSize))
                            || gridPositions.Contains(newPos + new Vector3(0, 0, -gridSize * 2))
                            )
                        {
                            i--;
                            continue;
                        }
                        newPos += new Vector3(0, 0, -gridSize);
                        break;
                    case Directions.West:
                        if (
                            gridPositions.Contains(newPos + new Vector3(-gridSize, 0, 0))
                            || gridPositions.Contains(newPos + new Vector3(-gridSize, 0, gridSize))
                            || gridPositions.Contains(newPos + new Vector3(-gridSize, 0, -gridSize))
                            || gridPositions.Contains(newPos + new Vector3(-gridSize * 2, 0, 0))
                            )
                        {
                            i--;
                            continue;
                        }
                        newPos += new Vector3(-gridSize, 0, 0);
                        break;
                }
            gridPositions.Add(newPos);
            Instantiate(sewerStraight, newPos, Quaternion.identity);

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
