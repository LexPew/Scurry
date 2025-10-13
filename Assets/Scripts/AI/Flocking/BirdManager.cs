using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BirdManager : MonoBehaviour
{
    public List<Bird> birds;
    [SerializeField] private float spawnRadius = 50f;

    [SerializeField] private int birdCount = 20;
    [SerializeField] private Bird birdPrefab;

    [Range(0, 1)] public float cohesionStrength = 0.5f;

    [Range(0, 1)] public float separationStrength = .5f;
    [Range(0, 1)] public float alignStrength = .5f;
    public float perceptionRadius = 10.0f;
    public float seperationDistance = 8.0f;
    public float alignDistance = 8.0f;

    public Vector3 target = new Vector3(0, 0, 0);
    public float targetStrength = 0.8f;

    [SerializeField] Transform targetUI;

    [Range(0, 10)] public float rotationSpeed;

    void Start()
    {
        AddBirds();
    }

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            target = Camera.main.ScreenToWorldPoint(Input.mousePosition);

            target.y = 0;
            targetUI.position = target;
        }
    }
    [ContextMenu("Add Birds")]
    private void AddBirds()
    {
        for (int i = 0; i < birdCount; i++)
        {

            Bird bird = Instantiate(birdPrefab, GetRandomPosition(), Quaternion.identity, transform);
            bird.flockManager = this;
            birds.Add(bird);
        }
    }
    Vector3 GetRandomPosition()
    {
        float randX = Random.Range(transform.position.x - spawnRadius, transform.position.x + spawnRadius);
        float randZ = Random.Range(transform.position.z - spawnRadius, transform.position.z + spawnRadius);
        return new Vector3(randX, transform.position.y, randZ);
    }
    [ContextMenu("Remove Birds")]
    void RemoveBirds()
    {
        foreach (Bird bird in birds)
        {
            Destroy(bird);
        }

    }

}