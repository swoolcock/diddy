using System;
using System.Collections.Generic;
using System.Security.Principal;
using System.Threading;

namespace Spring.Threading
{
    public class ContextCopyingRunable : IRunnable, IContextCopier
    {
        private ContextCarrier _contextCarrier;
        private Task _task;

        private ContextCopyingRunable(IEnumerable<string> names)
        {
            if (names == null) throw new ArgumentNullException("names");
            _contextCarrier = new ContextCarrier(names);
        }

        public ContextCopyingRunable(Task task, IEnumerable<string> names)
            :this(names)
        {
            if (task==null) throw new ArgumentNullException("task");
            _task = task;
        }


        public ContextCopyingRunable(IRunnable runnable, IEnumerable<string> names)
            :this(names)
        {
            if (runnable == null) throw new ArgumentNullException("runnable");
            _task = runnable.Run;
        }

        public void Run()
        {
            _contextCarrier.RestoreContext();
            _task();
        }
    }
}
