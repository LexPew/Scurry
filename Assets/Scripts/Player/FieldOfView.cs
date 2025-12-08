using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public class FieldOfView : MonoBehaviour
{

    public struct ViewCastInfo
    {
        public bool hit;
        public Vector3 point;
        public float distance;
        public float angle;

        public ViewCastInfo(bool _hit, Vector3 _point, float _distance, float _angle)
        {
            hit = _hit;
            point = _point;
            distance = _distance;
            angle = _angle;
        }
    }
    public struct EdgeInfo
    {
        public Vector3 pointA;
        public Vector3 pointB;

        public EdgeInfo(Vector3 _pointA, Vector3 _pointB)
        {
            pointA = _pointA;
            pointB = _pointB;
        }
    }
    [SerializeField] private float viewRadius;
    [SerializeField, Range(0, 360)] private float viewAngle;

    [SerializeField] private int resolution = 1;
    [SerializeField] private int edgeResolveResolution = 4;
    [SerializeField] private float edgeDistanceThreshold;
    [SerializeField] private LayerMask wallMask;
    [SerializeField] private MeshFilter meshFilter;
    private Mesh viewMesh;
    public bool run = false;

    // Start is called before the first frame update
    void Start()
    {
        viewMesh = new Mesh();
        viewMesh.name = "View Mesh";
        meshFilter.mesh = viewMesh;

    }

    // Update is called once per frame
    void LateUpdate()
    {
        if (run)
        {
            DrawFieldOfView();
        }


    }
    void DrawFieldOfView()
    {
        int stepCount = (int)viewAngle * resolution;
        float stepAngleSize = viewAngle / stepCount;

        List<Vector3> viewPoints = new List<Vector3>();
        ViewCastInfo oldViewCast = new ViewCastInfo();
        for (int i = 0; i <= stepCount; i++)
        {
            float angle = transform.eulerAngles.y - (viewAngle / 2) + (stepAngleSize * i);
            ViewCastInfo newViewCast = ViewCast(angle);
            if (i > 0)
            {
                bool edgeDistanceThresholdExceeded = Mathf.Abs(oldViewCast.distance - newViewCast.distance) > edgeDistanceThreshold;
                if (oldViewCast.hit != newViewCast.hit || (oldViewCast.hit && newViewCast.hit && edgeDistanceThresholdExceeded))
                {
                    //Find Edge
                    EdgeInfo edge = FindEdge(oldViewCast, newViewCast);
                    if (edge.pointA != Vector3.zero)
                    {
                        viewPoints.Add(edge.pointA);
                    }
                    if (edge.pointB != Vector3.zero)
                    {
                        viewPoints.Add(edge.pointB);
                    }
                }
            }
            viewPoints.Add(newViewCast.point);
            oldViewCast = newViewCast;

            if (newViewCast.hit)
            {
                Debug.DrawLine(transform.position, newViewCast.point, Color.green);
            }
            else
            {
                Debug.DrawLine(transform.position, newViewCast.point, Color.red);
            }

        }

        int vertexCount = viewPoints.Count + 1;
        Vector3[] vertices = new Vector3[vertexCount];
        int[] triangles = new int[(vertexCount - 2) * 3];

        vertices[0] = Vector3.zero;
        //Loop through minux one vertex count as we have already set this
        for (int i = 0; i < vertexCount - 1; i++)
        {
            //Skip over first vertex as already set
            vertices[i + 1] = transform.InverseTransformPoint(viewPoints[i]);
            //Set triangles accordingly with every third being indexed back to origin vertex 0
            //We set tris in pairs of 3
            if (i < vertexCount - 2)
            {
                triangles[i * 3] = 0;
                triangles[i * 3 + 1] = i + 1;
                triangles[i * 3 + 2] = i + 2;
            }

        }

        viewMesh.Clear();
        viewMesh.vertices = vertices;
        viewMesh.triangles = triangles;
        viewMesh.RecalculateNormals();

    }

    ViewCastInfo ViewCast(float angle)
    {
        Vector3 direction = DirectionFromAngle(angle);
        RaycastHit hit;
        if (Physics.Raycast(transform.position, direction, out hit, viewRadius, wallMask))
        {
            return new ViewCastInfo(true, hit.point, hit.distance, angle);
        }
        else
        {
            return new ViewCastInfo(false, transform.position + direction * viewRadius, viewRadius, angle);
        }
    }

    Vector3 DirectionFromAngle(float angleDeg)
    {
        return new Vector3(Mathf.Sin(angleDeg * Mathf.Deg2Rad), 0, Mathf.Cos(angleDeg * Mathf.Deg2Rad));
    }

    EdgeInfo FindEdge(ViewCastInfo minViewCast, ViewCastInfo maxViewCast)
    {
        float minAngle = minViewCast.angle;
        float maxAngle = maxViewCast.angle;
        Vector3 minPoint = Vector3.zero;
        Vector3 maxPoint = Vector3.zero;

        for (int i = 0; i < edgeResolveResolution; i++)
        {
            float angle = (minAngle + maxAngle) / 2;
            ViewCastInfo newViewCast = ViewCast(angle);
             bool edgeDistanceThresholdExceeded = Mathf.Abs(minViewCast.distance - newViewCast.distance) > edgeDistanceThreshold;
            if (newViewCast.hit == minViewCast.hit && !edgeDistanceThresholdExceeded)
            {
                minAngle = angle;
                minPoint = newViewCast.point;
            }
            else
            {
                maxAngle = angle;
                maxPoint = newViewCast.point;
            }
        }
        return new EdgeInfo(minPoint, maxPoint);

    }
    void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, viewRadius);
        float initAngle = transform.rotation.y - (viewAngle / 2);
        initAngle *= Mathf.Deg2Rad;
        float xPos1 = viewRadius * Mathf.Sin(initAngle);
        float yPos1 = viewRadius * Mathf.Cos(initAngle);

        float endAngle = transform.rotation.y + viewAngle / 2;
        endAngle *= Mathf.Deg2Rad;
        float xPos2 = viewRadius * Mathf.Sin(endAngle);
        float yPos2 = viewRadius * Mathf.Cos(endAngle);
        Gizmos.DrawLine(transform.position, new Vector3(xPos1, transform.position.y, yPos1));
        Gizmos.DrawLine(transform.position, new Vector3(xPos2, transform.position.y, yPos2));
    }

}
