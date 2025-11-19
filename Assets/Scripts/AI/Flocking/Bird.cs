
using UnityEngine;

public class Bird : MonoBehaviour
{
    public BirdManager flockManager;

    [Header("Bird Settings")]
    [SerializeField] private float maxSpeed = 15.0f;


    private Vector3 velocity;

    void Start()
    {
        velocity = new Vector3(Random.Range(-1f, 1f), 0, Random.Range(-1f, 1f));

    }

    void Update()
    {
        // Calculate cohesion and separation forces
        Vector3 cohesionVelo = (Cohesion() - transform.position).normalized * flockManager.cohesionStrength;
        Vector3 separationVelo = Seperation().normalized * flockManager.separationStrength;
        Vector3 alignmentVelo = (Align() - transform.position).normalized * flockManager.alignStrength;
        Vector3 targetAcq = (flockManager.target - transform.position).normalized * flockManager.targetStrength;




        // Combine both
        velocity += cohesionVelo + separationVelo + alignmentVelo + targetAcq;

        //Apply force to avoid going off ground layer via raycasting the end position
        RaycastHit hitInfo;
        Vector3 projectedEndPos = transform.position + velocity * Time.deltaTime;
        if (!Physics.Raycast(projectedEndPos + Vector3.up * 10f, Vector3.down, out hitInfo, 50f, LayerMask.GetMask("Ground")))
        {
            //If no ground detected, apply a force away from the edge, if too far gone teleport to nearest ground
            Vector3 awayFromEdge = (transform.position - projectedEndPos).normalized;
            velocity += awayFromEdge * maxSpeed;

        
        }


        // Keep birds on flat plane (XZ only)
        velocity.y = 0;

        // Limit speed
        velocity = Vector3.ClampMagnitude(velocity, maxSpeed);

        Vector3 targetPos = (transform.position + velocity);
        Vector3 targetPosition = new Vector3(targetPos.x,
                                               transform.position.y,
                                               targetPos.z);


        Vector3 endPosition = transform.position + velocity * Time.deltaTime;
        RaycastHit hit;


        transform.LookAt(endPosition);

        // Move bird
        transform.position = endPosition;

        //Raycast on ground layer to find target position
        if (Physics.Raycast(transform.position + Vector3.up * 10f, Vector3.down, out hit, 50f, LayerMask.GetMask("Ground")))
        {
            Debug.DrawRay(transform.position + Vector3.up * 10f, Vector3.down * 50f, Color.red);
            Debug.Log("Hit");
            transform.position = hit.point;
        }


    }
    Vector3 Cohesion()
    {
        int closeBirdCount = 0;
        Vector3 sum = Vector3.zero;

        foreach (Bird bird in flockManager.birds)
        {
            if (bird != this &&
                Vector3.Distance(transform.position, bird.transform.position) < flockManager.perceptionRadius)
            {
                closeBirdCount++;
                sum += bird.transform.position;
            }
        }

        if (closeBirdCount > 0)
            sum /= closeBirdCount;

        return sum;
    }
    Vector3 Seperation()
    {
        int closeBirdCount = 0;
        Vector3 sum = Vector3.zero;

        foreach (Bird bird in flockManager.birds)
        {
            if (bird != this &&
                Vector3.Distance(transform.position, bird.transform.position) < flockManager.seperationDistance)
            {
                closeBirdCount++;
                Vector3 diff = transform.position - bird.transform.position;
                sum += diff.normalized / Vector3.Distance(transform.position, bird.transform.position);

            }
        }
        if (closeBirdCount > 0)
        {
            sum /= closeBirdCount;
        }

        return sum;
    }
    Vector3 Align()
    {
        int closeBirdCount = 0;
        Vector3 sum = Vector3.zero;
        foreach (Bird bird in flockManager.birds)
        {
            if (bird != this &&
                Vector3.Distance(transform.position, bird.transform.position) < flockManager.alignDistance)
            {
                closeBirdCount++;
                sum += (bird.velocity);

            }
        }
        if (closeBirdCount > 0)
        {
            sum /= closeBirdCount;
        }
        return sum;
    }
}
