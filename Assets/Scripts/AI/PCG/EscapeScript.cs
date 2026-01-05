using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EscapeScript : MonoBehaviour
{
    public GameObject player;

    [Tooltip("Number of keys needed to escape (defaults to number spawned by LevelGen if 0)")]
    public int keysNeeded = 0;

    private void Start()
    {
        //get LevelGenerator object from scene
        GameObject LevelGen = GameObject.Find("LevelGenerator");

        //if keysNeeded is 0, get the number of keys spawned by LevelGen
        if (keysNeeded == 0)
        {
            LevelGen levelGenScript = LevelGen.GetComponent<LevelGen>();
            keysNeeded = levelGenScript.keyCount;
            Debug.Log("Keys needed to escape set to: " + keysNeeded);
        }
    }

    //script to handle winning the game by escaping
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            if (player.GetComponent<Player>().GetKeyCount() >= keysNeeded)
            {
                Debug.Log("Player has escaped! You win!");
                //TODO: Trigger win condition
            }
        }
    }
}
