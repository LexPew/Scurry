using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//Allows for simple top-down camera control wad
public class SimpleCameraController : MonoBehaviour
{

    [SerializeField] private float panSpeed = 50f;
    [SerializeField] private float yawSpeed = 50f;
    [SerializeField] private float startHeight = 50f;
    void Start()
    {
        transform.position = new Vector3(0, startHeight, 0);
        transform.rotation = Quaternion.Euler(90, 0, 0);
    }

    // Update is called once per frame
    void Update()
    {
        //Move camera with WASD
        Vector2 moveDirection = new Vector2();
        if (Input.GetKey(KeyCode.W))
        {
            moveDirection.y += 1;
        }
        if (Input.GetKey(KeyCode.S))
        {
            moveDirection.y -= 1;
        }
        if(Input.GetKey(KeyCode.A))
        {
            moveDirection.x -= 1;
        }
        if(Input.GetKey(KeyCode.D))
        {
            moveDirection.x += 1;
        }
        Vector3 move = new Vector3(moveDirection.x, 0, moveDirection.y).normalized;
        transform.Translate(move * panSpeed * Time.deltaTime, Space.World);
        //Rotate camera with QE
        float yaw = 0;
        if(Input.GetKey(KeyCode.Q))
        {
            yaw -= 1;
        }
        if(Input.GetKey(KeyCode.E))
        {
            yaw += 1;
        }
        transform.Rotate(0, yaw * yawSpeed * Time.deltaTime, 0);

    }
}
