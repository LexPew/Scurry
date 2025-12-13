
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.AI;
public class Rat : MonoBehaviour
{
    public SwarmManager swarmManager;

    [Header("Rat Settings")]
    [SerializeField] private Transform visualTransform;
    [SerializeField] private float maxSpeed = 22.0f; 
    [SerializeField] private float maxDistanceFromSwarmAgent = 60.0f; 
    [SerializeField] private float rotationSpeed = 9.0f;    // Allows smoother turning
    [SerializeField] private float wallDetectDistance = 10.0f;
    [SerializeField] private LayerMask wallMask;
    private Vector3 velocity;

    void Start()
    {
        //Set velocity to a random initial value
        velocity = new Vector3(Random.Range(-1.0f, 1.0f), 0, Random.Range(-1.0f, 1.0f)).normalized * (maxSpeed * 0.5f);
    }
    void Update()
    {
        //--- Flocking Calculations ---

        Vector3 cohesionForce = (Cohesion() - transform.position).normalized;
        Vector3 separationForce = Seperation().normalized;
        Vector3 alignForce = Align().normalized;
        Vector3 targetForce = (swarmManager.swarmAgent.transform.position - transform.position).normalized;
        Vector3 wallAvoidanceForce = WallAvoidance();
        //--- Steering and Movement ---
        Vector3 steerForce = Vector3.zero;
        steerForce += cohesionForce * swarmManager.currentBehaviour.cohesionStrength;
        steerForce += separationForce * swarmManager.currentBehaviour.separationStrength;
        steerForce += alignForce * swarmManager.currentBehaviour.alignStrength;
        steerForce += targetForce * swarmManager.currentBehaviour.targetStrength;
        //Wall avoidance is absolute to prevent collisions so we must multiply it by the combined magnitude of the other forces to keep balance
        float combinedForceMagnitude = steerForce.magnitude;
        steerForce += wallAvoidanceForce * (combinedForceMagnitude * 6.0f);


        //--- Velocity Update ---
        velocity += steerForce * Time.deltaTime;
        velocity = Vector3.ClampMagnitude(velocity, maxSpeed);
        velocity.y = 0; //Keep on ground plane
        //--- Rotation ---
        Quaternion proposedRot = Quaternion.LookRotation(velocity.normalized, Vector3.up);
        proposedRot = Quaternion.Euler(0, proposedRot.eulerAngles.y, 0); //Keep only y rotation
        transform.rotation = Quaternion.Slerp(transform.rotation, proposedRot, rotationSpeed * Time.deltaTime);

        //--- Position Update ---
        transform.position = transform.position + velocity * Time.deltaTime;

        //--- Position Validation ---
        //We check if we are within the NavMesh bounds, if not we snap back to the nearest point on the mesh.
        NavMeshHit hit;
        if (!NavMesh.SamplePosition(transform.position, out hit, 5.0f, NavMesh.AllAreas))
        {
            NavMesh.SamplePosition(transform.position, out hit, 100.0f, NavMesh.AllAreas);
            transform.position = hit.position;
        }

        //Check we arent too far from the target if we are sample a new position near the target and teleport there
        float distanceFromTarget = Vector3.Distance(transform.position, swarmManager.swarmAgent.transform.position);
        if(distanceFromTarget > maxDistanceFromSwarmAgent)
        {
            Vector3 randomDirection = UnityEngine.Random.insideUnitSphere * (maxDistanceFromSwarmAgent * 0.5f);
            randomDirection.y = 0f; // keep on ground plane
            randomDirection += swarmManager.swarmAgent.transform.position;

            NavMeshHit navHit;
            float maxSampleDistance = 10.0f; // small so we don't snap to far edges
            if (NavMesh.SamplePosition(randomDirection, out navHit, maxSampleDistance, NavMesh.AllAreas))
            {
                transform.position = navHit.position;
            }
        }
    }


    //Cohesion returns the average position of all boids within a certain perception radius.
    Vector3 Cohesion()
    {
        int closeBoidCount = 0;
        Vector3 sum = Vector3.zero;

        foreach (Rat rat in swarmManager.rats)
        {
            if (rat != this &&
                Vector3.Distance(transform.position, rat.transform.position) < swarmManager.currentBehaviour.perceptionRadius)
            {
                closeBoidCount++;
                sum += rat.transform.position;
            }
        }

        if (closeBoidCount > 0)
            sum /= closeBoidCount;

        return sum;
    }
    //Seperation returns a vector that pushes the boid away from nearby boids to avoid crowding.
    Vector3 Seperation()
    {
        int closeBoidCount = 0;
        Vector3 sum = Vector3.zero;

        foreach (Rat rat in swarmManager.rats)
        {
            //Check if we are not comparing to ourselves and if the rat is within separation distance
            if (rat != this &&
                Vector3.Distance(transform.position, rat.transform.position) < swarmManager.currentBehaviour.seperationDistance)
            {
                //Update the close boid counter and then calculate the difference vector, normalize it and weight it by distance.
                //Example: If we have our boid at (0,0,0) and another at (2,0,0), the difference vector is (-2,0,0).
                //Example: Which normalized is (-1,0,0) and the distance is 2, so we add (-1/2,0,0) to the sum. Akas (-0.5,0,0)
                //The greater the distance the smaller the separation force.
                closeBoidCount++;
                Vector3 diff = transform.position - rat.transform.position;
                sum += diff.normalized / Vector3.Distance(transform.position, rat.transform.position);

            }
        }
        if (closeBoidCount > 0)
        {
            sum /= closeBoidCount;
        }

        return sum;
    }
    //Align returns a vector that represents the average heading of nearby boids based on their velocities.
    Vector3 Align()
    {
        int closeBoidCount = 0;
        Vector3 sum = Vector3.zero;
        foreach (Rat rat in swarmManager.rats)
        {
            if (rat != this &&
                Vector3.Distance(transform.position, rat.transform.position) < swarmManager.currentBehaviour.alignDistance)
            {
                closeBoidCount++;
                //Simply add all the velocities of nearby boids together and then in the end we will average them.
                sum += (rat.velocity);

            }
        }
        if (closeBoidCount > 0)
        {
            sum /= closeBoidCount;
        }
        return sum;
    }

    Vector3 WallAvoidance()
{
    Vector3[] dirs = new Vector3[]
    {
        transform.forward,
        Quaternion.Euler(0, 20, 0) * transform.forward,
        Quaternion.Euler(0, -20, 0) * transform.forward
    };

    foreach (var dir in dirs)
    {
        RaycastHit hit;
        if (Physics.Raycast(transform.position, dir, out hit, wallDetectDistance, wallMask))
        {
            Vector3 away = hit.normal;
            away.y = 0;
            return away.normalized;
        }
    }

    return Vector3.zero;
}


    void OnDrawGizmos()
    {
        Gizmos.color = Color.blue;
        Gizmos.DrawLine(transform.position, transform.position + transform.forward * wallDetectDistance);

    }
}
