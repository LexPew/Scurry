using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.AI;

[RequireComponent(typeof(NavMeshAgent))]
public class SwarmAgent : MonoBehaviour
{
    public SwarmManager swarmManager;

    private NavMeshAgent navMeshAgent;

    private Vector3 targetPosition;
    [SerializeField]private Transform targetTransform;

    void Awake()
    {
        navMeshAgent = GetComponent<NavMeshAgent>();
    }

    void Start()
    {
        //Initialize target position to current position
        if (targetTransform != null)
            targetPosition = targetTransform.position;
        else
        {

            targetPosition = transform.position;
        }

    }

    void Update()
    {
                if (targetTransform != null)
            targetPosition = targetTransform.position;
    }

    //Sets a new target position for the swarm agent to move towards
    public void SetTargetPosition(Vector3 target)
    {
        targetPosition = target;
        navMeshAgent.SetDestination(targetPosition);
    }

}