using System;
using System.Collections.Generic;
using System.Threading;

namespace Spring.Threading.Helpers
{
	/// <summary> 
	/// Simple linked list queue used in FIFOSemaphore.
	/// Methods are not locked; they depend on synch of callers.
	/// Must be public, since it is used by Semaphore (outside this package).
	/// </summary>
	[Serializable]
	internal class FIFOWaitNodeQueue : IWaitNodeQueue
	{

		[NonSerialized] protected WaitNode _head;
		[NonSerialized] protected WaitNode _tail;

		public int Count
		{
			get
			{
				int count = 0;
				WaitNode node = _head;
				while (node != null)
				{
					if (node.IsWaiting) count++;
					node = node.NextWaitNode;
				}
				return count;
			}
		}

		public ICollection<Thread> WaitingThreads
		{
			get
			{
				IList<Thread> list = new List<Thread>();
				WaitNode node = _head;
				while (node != null)
				{
					if (node.IsWaiting) list.Add(node.Owner);
					node = node.NextWaitNode;
				}
				return list;
			}

		}

		public void Enqueue(WaitNode waitNode)
		{
			if (_tail == null)
			    _head = _tail = waitNode;
			else
			{
			    _tail.NextWaitNode = waitNode;
			    _tail = waitNode;
			}
		}

		public WaitNode Dequeue()
		{
			if (_head == null) return null;

		    WaitNode w = _head;
		    _head = w.NextWaitNode;
		    if (_head == null) _tail = null;
		    w.NextWaitNode = null;
		    return w;
		}

		public bool HasNodes
		{
			get
			{
				return _head != null;
			}
		}

		public bool IsWaiting(Thread thread)
		{
			if (thread == null) throw new ArgumentNullException("thread");
			for (WaitNode node = _head; node != null; node = node.NextWaitNode)
			{
				if (node.IsWaiting && node.Owner == thread) return true;
			}
			return false;
		}
	}
}