using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices.WindowsRuntime;
using UnityEngine;

public class BehaviourTree : MonoBehaviour
{
    private BTNode tree;
    private Player player;

    void Start()
    {
        player = FindObjectOfType<Player>();
        tree = new Sequence(
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

