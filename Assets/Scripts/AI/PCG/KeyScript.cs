using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KeyScript : MonoBehaviour
{
    //player reference
    public GameObject player;
    
    //collectible key script
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Debug.Log("Player has collected the key!");
            //add key to player's inventory 
            player.GetComponent<Player>().AddKey();
            //TODO: add key collection to ui and maybe play a sound effect
            //destroy the key object
            Destroy(gameObject);
        }
    }

    // Update is called once per frame
    void Update()
    {
        //spin the key in world space
        transform.Rotate(Vector3.up * Time.deltaTime * 50, Space.World);
    }

}
