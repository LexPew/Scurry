using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.EventSystems;

public class Player : MonoBehaviour
{
    // Movement Settings
    public float walkSpeed = 6f;
    public float runSpeed = 12f;
    public float defaultHeight = 2f;
    public float crouchHeight = 1f;
    public float crouchSpeed = 3f;

    // Mouse Sensitivity
    public float horizontalLookSpeed = 2f;

    private Vector3 moveDirection = Vector3.zero;
    private CharacterController characterController;
    private bool canMove = true;
    private Camera playerCamera;

    // Start is called before the first frame update
    void Start()
    {
        characterController = GetComponent<CharacterController>();
        playerCamera = Camera.main;
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 forward = transform.TransformDirection(Vector3.forward);
        Vector3 right = transform.TransformDirection(Vector3.right);

        bool isRunning = Input.GetKey(KeyCode.LeftShift);
        float curSpeedX = canMove ? (isRunning ? runSpeed : walkSpeed) * Input.GetAxis("Vertical") : 0;
        float curSpeedY = canMove ? (isRunning ? runSpeed : walkSpeed) * Input.GetAxis("Horizontal") : 0;
        moveDirection = (forward * curSpeedX) + (right * curSpeedY);

        if (Input.GetKey(KeyCode.R) && canMove)
        {
            characterController.height = crouchHeight;
            walkSpeed = crouchSpeed;
            runSpeed = crouchSpeed;

        }
        else
        {
            characterController.height = defaultHeight;
            walkSpeed = 6f;
            runSpeed = 12f;
        }


        characterController.Move(moveDirection * Time.deltaTime);

        // Handle horizontal rotation
        float horizontal = horizontalLookSpeed * Input.GetAxis("Mouse X");

        // Rotate the player horizontally
        characterController.transform.Rotate(0, horizontal, 0);

        // Position the camera above the player and update it
        playerCamera.transform.position = characterController.transform.position + new Vector3(0,15f, 0);


    }
}
