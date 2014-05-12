using System;
using System.Threading;

#region License
/*
* Copyright © 2002-2005 the original author or authors.
* 
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* 
*      http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
#endregion
/*
Originally written by Doug Lea and released into the public domain.
This may be used for any purposes whatsoever without acknowledgment.
Thanks for the assistance and support of Sun Microsystems Labs,
and everyone contributing, testing, and using this code.
*/
namespace Spring.Threading
{
	
    /// <summary> Main interface for buffers, queues, pipes, conduits, etc.
    /// <p>
    /// An <see cref="IChannel"/> represents anything that you can put items
    /// into and take them out of. As with the <see cref="ISync"/>
    /// interface, both blocking (<see cref="IPuttable.Put"/>, <see cref="ITakable.Take"/>),
    /// and timeouts (<see cref="IPuttable.Offer"/>, <see cref="ITakable.Poll"/>) policies
    /// are provided. Using a
    /// zero timeout for offer and poll results in a pure balking policy.
    /// </p>
    /// <p>
    /// To aid in efforts to use <see cref="IChannel"/>s in a more typesafe manner,
    /// this interface extends <see cref="IPuttable"/> and <see cref="ITakable"/>. 
    /// You can restrict
    /// arguments of instance variables to this type as a way of
    /// guaranteeing that producers never try to take, or consumers put.
    /// </p>
    /// <p>
    /// A given channel implementation might or might not have bounded
    /// capacity or other insertion constraints, so in general, you cannot tell if
    /// a given put will block. However, channels that are designed to 
    /// have an element capacity (and so always block when full)
    /// should implement the <see cref="IBoundedChannel"/> subinterface.
    /// </p>
    /// <p>
    /// Channels may hold any kind of item. However,
    /// insertion of null is not in general supported. Implementations
    /// may (all currently do) throw <see cref="ArgumentException"/> upon attempts to
    /// insert null. 
    /// </p>
    /// <p>
    /// By design, the <see cref="IChannel"/> interface does not support any methods to determine
    /// the current number of elements being held in the channel.
    /// This decision reflects the fact that in
    /// concurrent programming, such methods are so rarely useful
    /// that including them invites misuse; at best they could 
    /// provide a snapshot of current
    /// state, that could change immediately after being reported.
    /// It is better practice to instead use poll and offer to try
    /// to take and put elements without blocking. For example,
    /// to empty out the current contents of a channel, you could write:
    /// </p>
    /// <example>
    ///  try 
    ///  {
    ///     for (;;) 
    ///     {
    ///         object item = channel.Poll(0);
    ///         if (item != null)
    ///             Process(item);
    ///         else
    ///             break;
    ///     }
    ///  }
    ///  catch(ThreadInterruptedException ex) { ... }
    /// </example>
    /// <p>
    /// However, it is possible to determine whether an item
    /// exists in a <see cref="IChannel"/> via <see cref="IChannel.Peek"/>, which returns
    /// but does NOT remove the next item that can be taken (or null
    /// if there is no such item). The peek operation has a limited
    /// range of applicability, and must be used with care. Unless it
    /// is known that a given thread is the only possible consumer
    /// of a channel, and that no time-out-based <see cref="IPuttable.Offer"/> operations
    /// are ever invoked, there is no guarantee that the item returned
    /// by peek will be available for a subsequent take.
    /// </p>
    /// <p>
    /// When appropriate, you can define an <c>IsEmpty</c> method to
    /// return whether <see cref="IChannel.Peek"/> returns <c>null</c>.
    /// </p>
    /// <p>
    /// Also, as a compromise, even though it does not appear in interface,
    /// implementation classes that can readily compute the number
    /// of elements support a <c>Size</c> property. This allows careful
    /// use, for example in queue length monitors, appropriate to the
    /// particular implementation constraints and properties.</p>
    /// <p>
    /// All channels allow multiple producers and/or consumers.
    /// They do not support any kind of <em>Close</em> method
    /// to shut down operation or indicate completion of particular
    /// producer or consumer threads. 
    /// If you need to signal completion, one way to do it is to
    /// create a class such as
    /// <example>
    /// class EndOfStream { 
    /// // Application-dependent field/methods
    /// }
    /// </example>
    /// And to have producers put an instance of this class into
    /// the channel when they are done. The consumer side can then
    /// check this via
    /// <example>
    /// object x = aChannel.Take();
    /// if (x is EndOfStream) 
    ///     // special actions; perhaps terminate
    /// else
    ///     // process normally
    /// </example>
    /// </p>
    /// <p>
    /// In time-out based methods (<see cref="IPuttable.Offer"/>, <see cref="ITakable.Poll"/>), 
    /// time bounds are interpreted in
    /// a coarse-grained, best-effort fashion. Since there is no
    /// way to escape out of a wait for a synchronized
    /// method/block, time bounds can sometimes be exceeded when
    /// there is a lot contention for the channel. Additionally,
    /// some <see cref="IChannel"/> semantics entail a <em>point of
    /// no return</em> where, once some parts of the operation have completed,
    /// others must follow, regardless of time bound.
    /// </p>
    /// <p>
    /// Interruptions are in general handled as early as possible
    /// in all methods. Normally, <see cref="ThreadInterruptedException"/>s are thrown
    /// in <see cref="IPuttable.Put"/>/<see cref="ITakable.Take"/> and <see cref="IPuttable.Offer"/> 
    /// /<see cref="ITakable.Take"/> if interruption
    /// is detected upon entry to the method, as well as in any
    /// later context surrounding waits. 
    /// </p>
    /// <p>
    /// If a put returns normally, an offer
    /// returns true, or a put or poll returns non-null, the operation
    /// completed successfully. 
    /// In all other cases, the operation fails cleanly: the
    /// element is not put or taken.</p>
    /// </summary>
    /// <seealso cref="ISync">
    /// </seealso>
    /// <seealso cref="IBoundedChannel">
    /// 
    /// </seealso>
	
    public interface IChannel : IPuttable, ITakable
    {						
        /// <summary> Return, but do not remove object at head of <see cref="IChannel"/>,
        /// or null if it is empty.
        /// </summary>			
        System.Object Peek();
    }
}