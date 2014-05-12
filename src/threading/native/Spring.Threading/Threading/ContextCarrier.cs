using System;
using System.Collections.Generic;
using System.Security.Principal;
using System.Threading;

namespace Spring.Threading
{
    internal class ContextCarrier
    {
        private IDictionary<string, object> _contexts = new Dictionary<string, object>();
        private Thread _creatorThread = Thread.CurrentThread;
        private IPrincipal _principal = Thread.CurrentPrincipal;

        internal ContextCarrier(IEnumerable<string> names)
        {
            foreach (string name in names)
            {
                _contexts[name] = LogicalThreadContext.GetData(name);
            }
        }

        internal void RestoreContext()
        {
            if (Thread.CurrentThread != _creatorThread)
            {
                Thread.CurrentPrincipal = _principal;
                foreach (KeyValuePair<string, object> pair in _contexts)
                {
                    LogicalThreadContext.SetData(pair.Key, pair.Value);
                }
            }

        }
    }
}
