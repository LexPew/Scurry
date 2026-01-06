using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices.WindowsRuntime;
using Unity.VisualScripting;
using UnityEditor.UI;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.UIElements;


/*
 *  BEHAVIOUR TREE LAYOUT
 *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  top of tree:
 *  
 *  Idle / General movement / patrolling
 *  
 *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  Middle of tree:
 *  
 *  Fed information, has the rat spotted the player?
 *  Actively seeing player, has seen player but lost them?
 *  
 *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  Bottom of tree:
 *  
 *  Chase player / chase player's last known location
 * 
 * 
 */


/*
 *  TO DO
 *  
 *  ADD A LAST KNOWN PLAYER POS NODE
 * 
 * 
 * 
 * 
 * 
 * 
*/



public class BehaviourTree : MonoBehaviour
{
    // Private variables
    private BTNode tree;
    private Player player;
    
    // Public variables
    [Header("Vision")]
    public float viewRadius = 60f;
    public float viewAngle = 180f;
    public LayerMask obstacleMask = ~0;
    public float eyeHeight = 1.5f;

    [Header("Movement")]
    public float speed = 5f;
    public float chaseSpeed = 8f;
    public float roamRange = 60f;
    public float arrivalThreshold = 1.0f;

    [Header("References")]
    public GameObject self; // Self reference
    //public GameObject NavMeshAgent; // NavMeshAgent reference


    void Start()
    {
        // Initialising the Behaviour Tree
        player = FindObjectOfType<Player>();
        tree = new Selector(
            new Sequence(
                new PlayerVisibleNode(player, self, viewRadius, viewAngle, obstacleMask, eyeHeight),
                new ChaseActionNode(player, self, chaseSpeed)
                ),
            new RoamActionNode(self, roamRange, speed, arrivalThreshold)
            );
    }

    void Update()
    {
        tree.Execute();
    }
}

// abstract class for node
public abstract class BTNode // Base Behaviour Tree Node
{
    public abstract bool Execute();
}

// A pathway of the tree
public class Sequence : BTNode // Sequencer Node
{
    private List<BTNode> children = new List<BTNode>(); // Private list that holds our children

    public Sequence(params BTNode[] nodes) // Add nodes to our list of children
    {
        children.AddRange(nodes);
    }

    public override bool Execute() // Loop through children and run their code
    {
        foreach (var child in children)
        {
            if (!child.Execute())
                return false;
        }
        return true;
    }
}

// A branching point in the tree
public class Selector : BTNode // Selector Node
{
    // Private list that holds our children
    private List<BTNode> children = new List<BTNode>();

    public Selector(params BTNode[] nodes) // Add nodes to our list of children
    {
        children.AddRange(nodes);
    }

    public override bool Execute()
    {
        foreach (var child in children) // Loop through children and run their code
        {
            if (child.Execute())
                return true;
        }
        return false;
    }
}

// Not used
// prints to the console
public class PrintAction : BTNode // A leaf node, prints a message
{
    private string message;
    private Player player;

    public PrintAction(string msg, Player playerRef)
    {
        message = msg;
        player = playerRef;
    }

    public override bool Execute()
    {
        
        Debug.Log(message);
        return true; // Always succeeds
    }

}

// Not used currently, very basic starting movement node
// Movement action node
public class MovementAction : BTNode
{
    private Vector3 position;
    private Player player;
    private GameObject m_self;

    public MovementAction(Vector3 pos, Player playerRef, GameObject self)
    {
        position = pos;
        player = playerRef;
        m_self = self;
    }

    public override bool Execute()
    {
        if (player != null)
        {
            m_self.transform.position = Vector3.MoveTowards(m_self.transform.position, position, 5f);

            // Debug.Log("Moving to: " + position);

            return true; // When it gets to the position, we need it to move on
        }
        return false;
    }
}



// Player Visible Node, checks whether the player is currently visible to our AI
public class PlayerVisibleNode : BTNode
{
    // Private references
    private Player player;
    private Transform selfTransform;

    // Vision parameters
    private float viewRadius;
    private float viewAngle;
    private LayerMask obstacleMask;
    private float eyeHeight;

    // Constructor
    public PlayerVisibleNode(Player playerRef, GameObject self, float dist, float angle, LayerMask mask, float eye)
    {
        player = playerRef;
        selfTransform = self.transform;
        viewRadius = dist;
        viewAngle = angle;
        obstacleMask = mask;
        eyeHeight = eye;
    }

    // PlayerVisibleNode implementation
    public override bool Execute()
    {
        //Debug.Log("Checking player visibility..."); // Debug message to denote state

        // Check if we or the player is null
        if (player == null || selfTransform == null)
            return false;

        // Compute vector to player and squared distance
        Vector3 toPlayer = player.transform.position - selfTransform.position; // Distance from us to player
        float sqrDist = toPlayer.sqrMagnitude; // Squared distance for efficiency
        if (sqrDist > viewRadius * viewRadius) // Outside of view radius
            return false;

        // Horizontal checks
        Vector3 toPlayerHoriz = toPlayer;
        toPlayerHoriz.y = 0f;
        if (toPlayerHoriz.sqrMagnitude < 0.0001f)
            return true;

        Vector3 forward = selfTransform.forward;
        forward.y = 0f;
        float angleToPlayer = Vector3.Angle(forward, toPlayerHoriz.normalized);
        if (angleToPlayer > viewAngle * 0.5f)
            return false;

        // Vision check using raycast from eye position (not as necessary now, but will continue to use as it still works)
        Vector3 origin = selfTransform.position + Vector3.up * eyeHeight;
        Vector3 dir = (player.transform.position - origin).normalized;
        float distance = Mathf.Sqrt(sqrDist);


        // Use RaycastAll so can see what is hit first
        RaycastHit[] hits = Physics.RaycastAll(origin, dir, distance, obstacleMask, QueryTriggerInteraction.Ignore);

        // Sort the hits based on distance
        System.Array.Sort(hits, (a, b) => a.distance.CompareTo(b.distance));

        // Loop through hits to denote what is visible first
        foreach (var hit in hits)
        {
            if (hit.collider == null) continue; // Ignore immediately if hit nothing

            GameObject hitObj = hit.collider.gameObject; // Get the hit object

            // Ignore ourselves
            if (hitObj == selfTransform.gameObject || hit.collider.transform.IsChildOf(selfTransform))
                continue;

            // If after ignoring ourselves, we hit the player, then we can see them
            if (hitObj == player.gameObject || hit.collider.transform.IsChildOf(player.transform))
                return true;

            // Debug.Log($"LOS blocked by {hitGo.name}"); // Debug log to show what is blocking vision
            return false;
        }
        return true;
    }
}


// Chase Node, so the AI can chase the player when seen
public class ChaseActionNode : BTNode
{
    // References
    private Player player;
    private GameObject selfGameObj;
    private Transform selfTransform;
    private NavMeshAgent agent;

    // Speed parameters
    private float chaseSpeed;

    // Constructor
    public ChaseActionNode(Player playerRef, GameObject self, float speed)
    {
        selfGameObj = self;
        player = playerRef;
        selfTransform = self.transform;
        chaseSpeed = speed;
        if (self != null)
            agent = self.GetComponent<NavMeshAgent>();

    }

    public override bool Execute()
    {
        //Debug.Log("Chasing player..."); // Debug log to denote state

        if (player == null || selfTransform == null) // Check whether the player or self is null
            return false;

        if (agent == null) // Check for NavMeshAgent
            return false;
        

        // Set the speed to chase speed and ensure the agent is moving
        agent.speed = chaseSpeed;
        agent.isStopped = false;

        // Set the target position to the player's current position
        selfTransform.GetComponent<SwarmAgent>().SetTargetPosition(player.transform.position);

        return true;
    }
}






// Roam action, the AI will do this when it cannot see the player or is not chasing them
public class RoamActionNode : BTNode
{
    // Private references
    private Transform selfTransform;
    private GameObject selfGameObj;
    private NavMeshAgent agent;

    // Roaming parameters
    private float roamRadius;
    private float roamSpeed;
    private float arriveThreshold;

    // Target management
    private Vector3 currentTarget;
    private bool hasTarget = false;

    // Constructor
    public RoamActionNode(GameObject self, float radius, float speed, float threshold)
    {
        selfGameObj = self;
        selfTransform = self.transform;
        roamRadius = Mathf.Max(0.1f, radius);
        roamSpeed = speed;
        arriveThreshold = Mathf.Max(0.01f, threshold);
        agent = self.GetComponent<NavMeshAgent>();
    }

    public override bool Execute()
    {
        //Debug.Log("Roaming..."); // Debug message to indicate state
        if (selfTransform == null) // Check if we are null
            return false;

        if (agent == null) // Check for NavMeshAgent
            return false; // No NavMeshAgent means we cannot roam using this implementation
        

        // Set the speed and ensure the agent is moving
        agent.speed = roamSpeed;
        agent.isStopped = false;

        // If we don't have a target, pick a new one
        if (!hasTarget)
            PickNewTargetOnNavMesh();

        // Check if we've arrived at the target
        if (hasTarget)
        {
            if (!agent.pathPending && agent.remainingDistance <= arriveThreshold)
            {
                hasTarget = false;
            }
        }

        return true;
    }

    private void PickNewTargetOnNavMesh()
    {
        Vector3 randomPoint = selfTransform.position + Random.insideUnitSphere * roamRadius; // Select a random point within the roam radius
        randomPoint.y = selfTransform.position.y; // Ignore Y

        // Sample the NavMesh to find a reachable point near the random point
        if (NavMesh.SamplePosition(randomPoint, out NavMeshHit hit, 10.0f, NavMesh.AllAreas))
        {
            
            currentTarget = hit.position; // Update the current target, so we can feed it to the SwarmAgent
            hasTarget = true; // Set to true so target isn't overwritten
            selfGameObj.GetComponent<SwarmAgent>().SetTargetPosition(currentTarget);
            


        }
        else
        {
            // If sampling failed, try again next tick
            hasTarget = false;
        }
    }
}