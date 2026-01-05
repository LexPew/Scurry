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
    private BTNode tree;
    private Player player;
    
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
    


    void Start()
    {
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
    private List<BTNode> children = new List<BTNode>();

    public Sequence(params BTNode[] nodes)
    {
        children.AddRange(nodes);
    }

    public override bool Execute()
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
    private List<BTNode> children = new List<BTNode>();

    public Selector(params BTNode[] nodes)
    {
        children.AddRange(nodes);
    }

    public override bool Execute()
    {
        foreach (var child in children)
        {
            if (child.Execute())
                return true;
        }
        return false;
    }
}

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
        if (player != null && player.HasInteracted)
        {
            Debug.Log(message);
            return true; // Always succeeds
        }
        return false;
    }

}

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
            //m_self.transform.position = Vector3.MoveTowards(m_self.transform.position, position, 5f);
            
           // Debug.Log("Moving to: " + position);

            return true; // When it gets to the position, we need it to move on
        }


        return false;
        //throw new System.NotImplementedException();
    }
}


//has player been seen action


public class PlayerVisibleNode : BTNode
{
    private Player player;
    private Transform selfTransform;
    private float viewRadius;
    private float viewAngle;
    private LayerMask obstacleMask;
    private float eyeHeight;


    public PlayerVisibleNode(Player playerRef, GameObject self, float dist, float angle, LayerMask mask, float eye)
    {
        player = playerRef;
        selfTransform = self != null ? self.transform : null;
        viewRadius = dist;
        viewAngle = angle;
        obstacleMask = mask;
        eyeHeight = eye;
    }

    public override bool Execute()
    {
        Debug.Log("Checking player visibility...");
        if (player == null || selfTransform == null)
            return false;

        // Compute vector to player and squared distance
        Vector3 toPlayer = player.transform.position - selfTransform.position;
        float sqrDist = toPlayer.sqrMagnitude;
        if (sqrDist > viewRadius * viewRadius)
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

        // Line-of-sight check using raycast from eye position
        Vector3 origin = selfTransform.position + Vector3.up * eyeHeight;
        Vector3 dir = (player.transform.position - origin).normalized;
        float distance = Mathf.Sqrt(sqrDist);


        // Use RaycastAll and ignore hits that belong to self (or its children)
        RaycastHit[] hits = Physics.RaycastAll(origin, dir, distance, obstacleMask, QueryTriggerInteraction.Ignore);
        System.Array.Sort(hits, (a, b) => a.distance.CompareTo(b.distance));

        foreach (var hit in hits)
        {
            if (hit.collider == null) continue;

            GameObject hitGo = hit.collider.gameObject;

            // ignore self colliders (root or children)
            if (hitGo == selfTransform.gameObject || hit.collider.transform.IsChildOf(selfTransform))
                continue;

            // if we hit the player first -> visible
            if (hitGo == player.gameObject || hit.collider.transform.IsChildOf(player.transform))
                return true;

            // hit some other obstacle before player -> blocked
            Debug.Log($"LOS blocked by {hitGo.name}");
            return false;
        }

        // no intervening hits -> visible
        return true;
    }
}

//chase player action

public class ChaseActionNode : BTNode
{
    private Player player;
    private Transform selfTransform;
    private NavMeshAgent agent;
    private float chaseSpeed;

    public ChaseActionNode(Player playerRef, GameObject self, float speed)
    {
        player = playerRef;
        selfTransform = self != null ? self.transform : null;
        chaseSpeed = speed;
        if (self != null)
            agent = self.GetComponent<NavMeshAgent>();
    }

    public override bool Execute()
    {
        Debug.Log("Chasing player...");
        if (player == null || selfTransform == null)
            return false;

        if (agent == null)
        {
            agent = selfTransform.GetComponent<NavMeshAgent>();
            if (agent == null)
                return false; // No NavMeshAgent -> can't chase with NavMesh
        }

        agent.speed = chaseSpeed;
        agent.isStopped = false;
        agent.SetDestination(player.transform.position);
        return true;
    }
}






//roam action
public class RoamActionNode : BTNode
{
    private Transform selfTransform;
    private NavMeshAgent agent;
    private float roamRadius;
    private float roamSpeed;
    private float arriveThreshold;
    private Vector3 currentTarget;
    private bool hasTarget = false;

    public RoamActionNode(GameObject self, float radius, float speed, float threshold)
    {
        selfTransform = self != null ? self.transform : null;
        roamRadius = Mathf.Max(0.1f, radius);
        roamSpeed = speed;
        arriveThreshold = Mathf.Max(0.01f, threshold);
        if (self != null)
            agent = self.GetComponent<NavMeshAgent>();
    }

    public override bool Execute()
    {
        Debug.Log("Roaming...");
        if (selfTransform == null)
            return false;

        if (agent == null)
        {
            agent = selfTransform.GetComponent<NavMeshAgent>();
            if (agent == null)
                return false; // No NavMeshAgent -> can't roam with NavMesh
        }

        agent.speed = roamSpeed;
        agent.isStopped = false;

        if (!hasTarget)
            PickNewTargetOnNavMesh();

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
        Vector3 randomPoint = selfTransform.position + Random.insideUnitSphere * roamRadius;
        randomPoint.y = selfTransform.position.y;

        // Sample the NavMesh to find a reachable point near the random point
        if (NavMesh.SamplePosition(randomPoint, out NavMeshHit hit, 10.0f, NavMesh.AllAreas))
        {
            currentTarget = hit.position;
            hasTarget = true;
            agent.SetDestination(currentTarget);
        }
        else
        {
            // If sampling failed, try again next tick
            hasTarget = false;
        }
    }
}