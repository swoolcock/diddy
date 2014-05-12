using System;
using System.Collections.Generic;

namespace Spring.Threading.Future
{
    public class ContextCopyingFutureTask<T> : FutureTask<T>, IContextCopier
    {
        private ContextCarrier _contextCarrier;


        public ContextCopyingFutureTask(Task task, T result, IEnumerable<string> names) : base(task, result)
        {
            SetRunnable(names);
        }

        public ContextCopyingFutureTask(IRunnable task, T result, IEnumerable<string> names)
            : base(task, result)
        {
            SetRunnable(names);
        }

        public ContextCopyingFutureTask(Call<T> call, IEnumerable<string> names)
            : base(call)
        {
            SetRunnable(names);
        }

        public ContextCopyingFutureTask(ICallable<T> callable, IEnumerable<string> names)
            : base(callable)
        {
            SetRunnable(names);
        }

        private void SetRunnable(IEnumerable<string> names)
        {
            if (names== null) throw new ArgumentNullException("names");
            _contextCarrier = new ContextCarrier(names);
        }

        public override void Run()
        {
            _contextCarrier.RestoreContext();
            base.Run();
        }

    }
}
