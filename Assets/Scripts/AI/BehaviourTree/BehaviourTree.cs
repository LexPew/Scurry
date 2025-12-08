using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices.WindowsRuntime;
using Unity.VisualScripting;
using UnityEditor.UI;
using UnityEngine;
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

public class BehaviourTree : MonoBehaviour
{
    private BTNode tree;
    private Player player;
    public GameObject self;


    void Start()
    {
        player = FindObjectOfType<Player>();
        tree = new Sequence(
            new MovementAction(new Vector3(10, 0, 10), player, self),
            new PrintAction("Hello",player),
            new PrintAction("World",player)
            
        );
    }

    void Update()
    {
        tree.Execute();
    }
}

public abstract class BTNode // Base Behaviour Tree Node
{
    public abstract bool Execute();
}

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
            
            Debug.Log("Moving to: " + position);
            //player.GetComponent<CharacterController>().Move(position * Time.deltaTime);
            return true;
        }
        
        
        
        throw new System.NotImplementedException();
    }
}
