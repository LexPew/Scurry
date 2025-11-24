using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

public class Player : MonoBehaviour
{

    public bool HasInteracted { get; private set; }

    // Movement Settings
    [Header("Movement Settings")]
    public float walkSpeed = 6f;
    public float runSpeed = 12f;

    private float verticalVelocity = 0f;
    public float gravity = -20f;

    private float currentSpeed = 0f;
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
    [Header("Components")]
    private CharacterController characterController;
    private Camera playerCamera;
    [SerializeField] private Transform visualTransform;
    [SerializeField] private PlayerInput playerInput;


    // Booleans
    private bool canMove = true;


    // Start is called before the first frame update
    void Start()
    {
        characterController = GetComponent<CharacterController>();
        playerCamera = Camera.main;
    }

    // Update is called once per frame
    void Update()
    {
        if (!canMove) return;

        // Handle Movement Speed
        HandleMovementSpeed();

        // Handle Camera Zoom
        HandleZoom();

        // Handle Look Direction
        HandleLookDirection();


        // Move the player
        characterController.Move(CalculateMoveDirection() * Time.deltaTime);

        // Update camera position
        playerCamera.transform.position = characterController.transform.position + new Vector3(0, cameraZoom, 0);

        HasInteracted = Input.GetKeyDown(KeyCode.E);

    }

    Vector3 CalculateMoveDirection()
    {

        Vector3 forward = Vector3.forward;
        Vector3 right = Vector3.right;

        //Im using raw for snappier input response
        float vertical = playerInput.actions["Move"].ReadValue<Vector2>().y;
        float horizontal = playerInput.actions["Move"].ReadValue<Vector2>().x;
        Debug.Log("Vertical Input: " + vertical + " Horizontal Input: " + horizontal);
        Vector3 move = forward * vertical + right * horizontal;

        // Normalize only if diagonal
        if (move.sqrMagnitude > 1f)
            move = move.normalized;

        move *= currentSpeed;

        if (characterController.isGrounded)
        {
            verticalVelocity = -2f; //Small downward force to keep grounded
        }
        else
        {
            verticalVelocity += gravity * Time.deltaTime;
        }

        move.y = verticalVelocity;
        return move;
    }

    void HandleMovementSpeed()
    {
        // Determine current speed based on input
        if (playerInput.actions["Sprint"].IsPressed())
        {
            currentSpeed = runSpeed;
        }
        else if (playerInput.actions["Crouch"].IsPressed())
        {
            currentSpeed = crouchSpeed;
        }
        else
        {
            currentSpeed = walkSpeed;
        }
    }

    void HandleZoom()
    {
        // Camera Zooming with mouse scroll wheel
        float scrollDelta = Input.mouseScrollDelta.y;
        if (Mathf.Abs(scrollDelta) > 0f)
        {
            // Scroll up should reduce cameraZoom (zoom in), scroll down should increase (zoom out)
            cameraZoom -= scrollDelta * zoomStep;
            cameraZoom = Mathf.Clamp(cameraZoom, minCameraZoom, maxCameraZoom);
        }
    }

    void HandleLookDirection()
    {
        //Check if we are using a mouse or gamepad
        if (playerInput.currentControlScheme == "Gamepad")
        {
            Vector2 lookInput = playerInput.actions["Look"].ReadValue<Vector2>();
            if (lookInput.sqrMagnitude > 0.01f)
            {
                Vector3 lookDirection = new Vector3(lookInput.x, 0, lookInput.y).normalized;
                Quaternion targetRotation = Quaternion.LookRotation(lookDirection, Vector3.up);
                visualTransform.rotation = Quaternion.Slerp(visualTransform.rotation, targetRotation, 15f * Time.deltaTime);
            }

        }
        else
        {
            //Use mouse position to world space to find where the player is looking and rotate accordingly
            Ray mouseRay = playerCamera.ScreenPointToRay(Input.mousePosition);
            Plane groundPlane = new Plane(Vector3.up, Vector3.zero);
            if (groundPlane.Raycast(mouseRay, out float rayDistance))
            {
                Vector3 lookPoint = mouseRay.GetPoint(rayDistance);
                Vector3 lookDirection = (lookPoint - transform.position).normalized;
                lookDirection.y = 0; //Keep only horizontal rotation
                if (lookDirection.sqrMagnitude > 0.01f)
                {
                    Quaternion targetRotation = Quaternion.LookRotation(lookDirection, Vector3.up);
                    visualTransform.rotation = Quaternion.Slerp(visualTransform.rotation, targetRotation, 15f * Time.deltaTime);
                }
            }
        }

    }
}
