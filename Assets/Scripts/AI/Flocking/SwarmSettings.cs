using UnityEngine;

[CreateAssetMenu(fileName = "Swarm Settings", menuName = "ScriptableObjects/Swarm/SwarmSettings", order = 1)]
public class SwarmSettings : ScriptableObject
{
    //Swarm  Flocking parameters
    public float cohesionStrength = 0.65f;      // Pull toward center of mass
    public float separationStrength = 2.0f;    // Higher to prevent overlap
    public float alignStrength = 0.15f;        // Keep similar heading
    public float targetStrength = 90.0f;       // Lower so target doesn't dominate decisions

    public float perceptionRadius = 14.0f;     // Slight increase for smoother cohesion
    public float seperationDistance = 4.0f;    // Tighter cluster but no overlaps
    public float alignDistance = 12.0f;   
}
