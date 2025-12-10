using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KeyScript : MonoBehaviour
{
    //collectible key script
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Debug.Log("Player has collected the key!");
            //logic to add key to player's inventory here
            //destroy the key object
            Destroy(gameObject);
        }
    }

    // Update is called once per frame
    void Update()
    {
        //spin the key
        transform.Rotate(new Vector3(0, 50, 0) * Time.deltaTime);


    }
}
