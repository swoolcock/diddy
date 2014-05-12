using System;
using System.Collections.Generic;
using Spring.Threading.Collections.Generic;
using Spring.Threading.Future;

namespace Spring.Threading.Execution
{
    public class ContextCopyingThreadPoolExecutor : ThreadPoolExecutor
    {
        public ContextCopyingThreadPoolExecutor(int corePoolSize, int maximumPoolSize, TimeSpan keepAliveTime, IBlockingQueue<IRunnable> workQueue, IThreadFactory threadFactory, IRejectedExecutionHandler handler) 
            : base(corePoolSize, maximumPoolSize, keepAliveTime, workQueue, threadFactory, handler)
        {
        }

        public ContextCopyingThreadPoolExecutor(int corePoolSize, int maximumPoolSize, TimeSpan keepAliveTime, IBlockingQueue<IRunnable> workQueue, IRejectedExecutionHandler handler) 
            : base(corePoolSize, maximumPoolSize, keepAliveTime, workQueue, handler)
        {
        }

        public ContextCopyingThreadPoolExecutor(int corePoolSize, int maximumPoolSize, TimeSpan keepAliveTime, IBlockingQueue<IRunnable> workQueue, IThreadFactory threadFactory) 
            : base(corePoolSize, maximumPoolSize, keepAliveTime, workQueue, threadFactory)
        {
        }

        public ContextCopyingThreadPoolExecutor(int corePoolSize, int maximumPoolSize, TimeSpan keepAliveTime, IBlockingQueue<IRunnable> workQueue)
            : base(corePoolSize, maximumPoolSize, keepAliveTime, workQueue)
        {
        }

        private IEnumerable<string> _contextNames;

        public IEnumerable<string> ContextNames
        {
            get { return _contextNames; }
            set { _contextNames = value;}
        }

        protected internal override IRunnableFuture<T> NewTaskFor<T>(Task task, T result)
        {
            return new ContextCopyingFutureTask<T>(task, result, _contextNames);
        }

        protected internal override IRunnableFuture<T> NewTaskFor<T>(IRunnable runnable, T result)
        {
            return new ContextCopyingFutureTask<T>(runnable, result, _contextNames);
        }

        protected internal override IRunnableFuture<T> NewTaskFor<T>(Call<T> call)
        {
            return new ContextCopyingFutureTask<T>(call, _contextNames);
        }

        protected internal override IRunnableFuture<T> NewTaskFor<T>(ICallable<T> callable)
        {
            return new ContextCopyingFutureTask<T>(callable, _contextNames);
        }

        public override void Execute(IRunnable command)
        {
            if (!(command is IContextCopier))
            {
                command = new ContextCopyingRunable(command, _contextNames);
            }
            base.Execute(command);
        }
    }
}
