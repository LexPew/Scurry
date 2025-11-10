using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using UnityEngine;
using UnityEngine.Rendering;

namespace AI.BehaviourTree
{
    public class Node
{
    public enum State
        {
            Success,
            Failure,
            Running
        };

        public readonly string name;
        public readonly List<Node> children = new List<Node>();
        protected int currentChild;




        public Node(string name = "Node")
        {
            this.name = name;
        }

        public void AddChild(Node child)
        {
            children.Add(child);
        }

        public virtual State Process() => children[currentChild].Process();

        public virtual void Reset()
        {
            currentChild = 0;
            foreach (var child in children)
            {
                child.Reset();
            }
        }



    }






}
