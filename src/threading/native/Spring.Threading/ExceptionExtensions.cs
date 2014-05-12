using System;
using System.Reflection;

namespace Spring
{
    /// <summary>
    /// Static class to provide extension methods to <see cref="Exception"/>
    /// objects.
    /// </summary>
    /// <author>Kenneth Xu</author>
    public static class ExceptionExtensions
    {
        /// <summary>
        /// Lock the stack trace information of the given <paramref name="exception"/>
        /// so that it can be rethrow without losing the stack information.
        /// </summary>
        /// <remarks>
        /// <example>
        ///     <code>
        ///     try
        ///     {
        ///         //...
        ///     }
        ///     catch( Exception e )
        ///     {
        ///         //...
        ///         throw e.PreserveStackTrace(); //rethrow the exception - preserving the full call stack trace!
        ///     }
        ///     </code>
        /// </example>
        /// </remarks>
        /// <param name="exception">The exception to lock the statck trace.</param>
        /// <returns>The same <paramref name="exception"/> with stack traced locked.</returns>
        public static Exception PreserveStackTrace(Exception exception)
        {
            _preserveStackTrace(exception);
            return exception;
        }

        private static readonly Action<Exception> _preserveStackTrace = (Action<Exception>)Delegate.CreateDelegate(typeof(Action<Exception>),
            typeof(Exception).GetMethod("InternalPreserveStackTrace", BindingFlags.Instance | BindingFlags.NonPublic));
    }
}