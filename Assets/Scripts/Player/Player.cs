using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.EventSystems;

public class Player : MonoBehaviour
{
    // Movement Settings
    [Header("Movement Settings")]
    public float walkSpeed = 6f;
    public float runSpeed = 12f;

    // Crouch Settings
    [Header("Crouch Settings")]
    public float defaultHeight = 2f;
    public float crouchHeight = 1f;
    public float crouchSpeed = 3f;

    // Camera Settings
    [Header("Camera Settings")]
    public float cameraZoom = 15f;
    public float minCameraZoom = 5f;
    public float maxCameraZoom = 25f;
    public float zoomStep = 1f;

    // Components
    private CharacterController characterController;
    private Camera playerCamera;

    // Booleans
    private bool canMove = true;

    // Movement Direction Vectors
    private Vector3 moveDirection = Vector3.zero;
    private Vector3 north = Vector3.forward;
    private Vector3 east = Vector3.right;

    // Start is called before the first frame update
    void Start()
    {
        characterController = GetComponent<CharacterController>();
        playerCamera = Camera.main;
    }

    // Update is called once per frame
    void Update()
    {
        // Setting up movement direction to be relative to world north/east
        Vector3 forward = new Vector3(north.x, 0f, north.z).normalized; //transform.TransformDirection(Vector3.forward);
        Vector3 right = new Vector3(east.x, 0f, east.z).normalized;

        // Uses the LeftShift as a bool to determine if the player is running
        bool isRunning = Input.GetKey(KeyCode.LeftShift);

        // Calculate movement direction based on input and whether the player can move
        float curSpeedX = canMove ? (isRunning ? runSpeed : walkSpeed) * Input.GetAxis("Vertical") : 0;
        float curSpeedY = canMove ? (isRunning ? runSpeed : walkSpeed) * Input.GetAxis("Horizontal") : 0;

        // Final movement direction vector
        moveDirection = (forward * curSpeedX) + (right * curSpeedY);

        // Crouching using left ctrl
        if (Input.GetKey(KeyCode.LeftControl) && canMove) 
        {
            // Change the height of the character controller
            characterController.height = crouchHeight;

            // Adjust speeds for crouching
            walkSpeed = crouchSpeed;
            runSpeed = crouchSpeed;

        }

        else
        {
            // Change the height of the character controller back to default
            characterController.height = defaultHeight;

            // Reset speeds back to normal
            walkSpeed = 6f;
            runSpeed = 12f;
        }

        // Camera Zooming with mouse scroll wheel
        float scrollDelta = Input.mouseScrollDelta.y;
        if (Mathf.Abs(scrollDelta) > 0f)
        {
            // Scroll up should reduce cameraZoom (zoom in), scroll down should increase (zoom out)
            cameraZoom -= scrollDelta * zoomStep;
            cameraZoom = Mathf.Clamp(cameraZoom, minCameraZoom, maxCameraZoom);
        }

        // Ray cast to find the point on the ground where the mouse is pointing
        Ray ray = playerCamera.ScreenPointToRay(Input.mousePosition);

        if (Physics.Raycast(ray, out RaycastHit hitInfo))
        {
            Vector3 lookPoint = hitInfo.point;
            lookPoint.y = transform.position.y; // Keep the y position the same as the player
            transform.LookAt(lookPoint);
        }

        // Move the player
        characterController.Move(moveDirection * Time.deltaTime);

        // Update camera position
        playerCamera.transform.position = characterController.transform.position + new Vector3(0, cameraZoom, 0);


    }
}
