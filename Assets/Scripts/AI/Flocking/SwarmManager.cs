
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.AI;
//Manages a swarm of rats, multiple of these will be placed in the scene,
//each managing their own group of rats and will have their own max radius they can go to


//Each swarm will have a target point they will try to move,
//and will use an navmesh to find a path to that point, following
//a swarm agent that moves along the path
public class SwarmManager : MonoBehaviour
{
    public GameObject ratPrefab;
    public List<Rat> rats;

    [SerializeField] private float swarmRoamRadius = 40;   // 100 is very large; 40–70 is more controllable
    [SerializeField] private int ratCount = 60;

    //Swarm Settings
    public SwarmSettings currentBehaviour;
    public SwarmSettings defaultBehaviour;
    public SwarmSettings chaseBehaviour;
    public SwarmSettings fleeBehaviour;

    //Swarm Agent Variables
    public GameObject swarmAgentPrefab;
    public SwarmAgent swarmAgent;
    public Transform swarmTarget;


    // Swarm Agent
    [SerializeField] private float changeTargetInterval = 2.0f;   // Change target slightly more often
    private float timeSinceLastTargetChange = 0.0f;



    void Start()
    {
        //Test
        currentBehaviour = defaultBehaviour;

        //Create swarm agent
        if (swarmAgentPrefab != null)
        {
            GameObject agentObj = Instantiate(swarmAgentPrefab, transform.position, quaternion.identity, transform);
            swarmAgent = agentObj.GetComponent<SwarmAgent>();
        }
        else
        {
            swarmAgent = Instantiate(new GameObject("Swarm Agent"), transform.position, quaternion.identity, transform).AddComponent<SwarmAgent>();
        }



        //Place agent on navmesh
        if (NavMesh.SamplePosition(transform.position, out NavMeshHit hit, 20.0f, NavMesh.AllAreas))
        {
            swarmAgent.transform.position = hit.position;
        }
        swarmAgent.swarmManager = this;

        //Populate rats
        PopulateRats();
    }

    void Update()
    {
        //Update timer
        timeSinceLastTargetChange += Time.deltaTime;
        //If it's time to change target then find a random position within the roam radius and set it as the new target, avoiding the edges of the navmesh
        if (timeSinceLastTargetChange >= changeTargetInterval)
        {
            Vector3 randomDirection = UnityEngine.Random.insideUnitSphere * swarmRoamRadius;
            randomDirection.y = 0f; // keep on ground plane
            randomDirection += transform.position;

            NavMeshHit navHit;
            float maxSampleDistance = 5.0f; // small so we don't snap to far edges

            if (NavMesh.SamplePosition(randomDirection, out navHit, maxSampleDistance, NavMesh.AllAreas))
            {
                swarmAgent.SetTargetPosition(navHit.position);
                timeSinceLastTargetChange = 0.0f;
            }
            else
            {
                // If we failed, just try again next frame; no target change this time
                Debug.Log("Failed to find pos");
            }
        }


    }

    void PopulateRats()
    {
        for (int i = 0; i < ratCount; i++)
        {
            Rat rat = Instantiate(ratPrefab, swarmAgent.transform.position, Quaternion.identity, transform).GetComponent<Rat>();
            rat.swarmManager = this;
            rats.Add(rat);

        }
    }
    void OnDrawGizmosSelected()
    {
        //Draw swarm roam radius
        Gizmos.color = Color.cyan;
        Gizmos.DrawWireSphere(transform.position, swarmRoamRadius);
    }

    [ContextMenu("Flee Swarm")]
    public void FleeSwarm()
    {
        currentBehaviour = fleeBehaviour;
    }
    [ContextMenu("Chase Swarm")]
    public void ChaseSwarm()
    {
        currentBehaviour = chaseBehaviour;
    }
    [ContextMenu("Default Swarm Behaviour")]
    public void DefaultSwarmBehaviour()
    {
        currentBehaviour = defaultBehaviour;
    }
}
