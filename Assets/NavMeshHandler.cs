using System.Collections;
using System.Collections.Generic;
using Unity.AI.Navigation;
using Unity.Jobs;
using UnityEditor.AI;
using UnityEngine;
using UnityEngine.AI;

public class NavMeshHandler : MonoBehaviour
{
    private GameObject agent;
    void Start()
    {
 
        //Create a test agent at start
        agent = GameObject.CreatePrimitive(PrimitiveType.Capsule);
        agent.AddComponent<NavMeshAgent>();
        //Set it to the start position from levelGen
        LevelGen generator = FindObjectOfType<LevelGen>();
        agent.transform.position = generator.GetStartPosition();
        //Set the agent on the navmesh
        NavMeshAgent navMeshAgent = agent.GetComponent<NavMeshAgent>();
        navMeshAgent.Warp(agent.transform.position);

    }

    void Update()
    {
        //Check clicks for moving the agent
        if (Input.GetMouseButtonDown(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit))
            {
                NavMeshAgent navMeshAgent = agent.GetComponent<NavMeshAgent>();
                navMeshAgent.SetDestination(hit.point);
            }
        }   
    }
}
