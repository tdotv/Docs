using System;
using System.Runtime;
using System.Runtime.ConstrainedExecution;
using System.Threading;
using System.Threading.Tasks.Dataflow;

public class GCDebugging
{
    public static void Main()
    {

        // Create a Timer object that knows to call our TimerCallBack
        // method once every 2000ms
        Timer t = new(TimerCallback, null, 0, 2000);

        // Wait for the user to hit Enter
        Console.ReadLine();

        // Refer to t after ReadLine (this gets optimized away)
        // t = null;

        // Refer to t after ReadLine (t will survive GCs until Dispose returns)
        t.Dispose();
    }

    private static void TimerCallback(object o)
    {
        // Display the date/time when this method got called.
        Console.WriteLine("In TimerCallback: " + DateTime.Now);

        // Force a garbage collection to occur for this demo
        GC.Collect();
    }
}


// Вызывает событие всякий раз, когда происходит сборка данных поколения 0 или 2
public static class GCNotification
{
    private static Action<Int32> s_gcDone = null; // The event's field

    public static event Action<Int32> GCDone
    {
        add
        {
            // If there were no registered delegates before, start reporting notifications now
            if (s_gcDone == null)
            {
                new GenObject(0); new GenObject(2);
            }
            s_gcDone += value;
        }
        remove
        {
            s_gcDone -= value;
        }
    }

    private sealed class GenObject
    {
        private Int32 m_generation;
        public GenObject(Int32 generation) { m_generation = generation; }

        ~GenObject()    // This is Finalize method - destructor
        {
            // If the object is in the generation we want (or higher),
            // notify the delegates that a GC just completed
            if (GC.GetGeneration(this) >= m_generation)
            {
                Action<Int32> temp = Volatile.Read(ref s_gcDone);
                if (temp != null) temp(m_generation);
            }

            // Keep reporting notification if there is at least one delegate registered,
            // the AppDomain isn't unloading, and the process isn't shutting down
            if ((s_gcDone != null)
                && !AppDomain.CurrentDomain.IsFinalizingForUnload()
                && !Environment.HasShutdownStarted)
            {
                // For Gen 0, create a new object; for Gen 2, resurrect the object
                // & let the GC call Finalize again the next time Gen 2 is GC'd
                if (m_generation == 0) new GenObject(0);
                else GC.ReRegisterForFinalize(this);
            }
            else { /* Let the objects go away */ }
        }
    }
}

public static class Latency
{
    private static void LowLatencyDemo()
    {
        GCLatencyMode oldMode = GCSettings.LatencyMode;
        System.Runtime.CompilerServices.RuntimeHelpers.PrepareConstrainedRegions();
        try
        {
            GCSettings.LatencyMode = GCLatencyMode.LowLatency;
            // Run your code here
        }
        finally
        {
            GCSettings.LatencyMode = oldMode;
        }
    }
}

public abstract class SafeHandle : CriticalFinalizerObject, IDisposable
{
    // This is the handle to the native resource
    protected IntPtr handle;

    protected SafeHandle(IntPtr invalidHandleValue, Boolean ownsHandle)
    {
        this.handle = invalidHandleValue;
        // If ownsHandle is true, then the native resource is closed when
        // this SafeHandle-derived object is collected
    }

    protected void SetHandle(IntPtr handle)
    {
        this.handle = handle;
    }

    // You can explicitly release the resource by calling Displose
    // This is the IDisposable interface's Dispose method
    public void Dispose() { Dispose(true); }

    // The default Dispose implementation (shown here) is exactly what you want.
    // Overriding this method is strongly discouraged
    protected virtual void Dispose(Boolean disposing)
    {
        // The default implementation ignores the disposing argument
        // If resource alreadt released, return
        // If ownsHandle is false, return
        // Set flag indicating that this resource has been released
        // Call virtual ReleaseHandle method
        // Call GC.SuppessFinalize(this) to prevent Finalize from being called
        // If ReleaseHandle returned true, return
        // If we get here, fire ReleaseHandleFailed Managed Debugging Assistant
    }

    // The default Finalize implementation (shown here) is exactly what you want
    // Overriding this method is very strongly descouraged
    ~SafeHandle() { Dispose(false); }

    // A derived class overrides this method to implement the code that releases the resource
    protected abstract Boolean ReleaseHandle();

    public void SetHandleAsInvalid()
    {
        // Set flag indicating that this resource has been released
        // Call GC.SuppressFinalize(this) to prevent Finalize from being called
    }

    // public Boolean IsClosed {
    //     get { 
    //          // Returns flag indicating whether resource was released
    //     }
    // }

    public abstract Boolean IsInvalid
    {
        // A derived class overrides this property
        // The implementation should return true if the handle's value doesn't
        // represent a resource (this usually means that the handle is 0 or -1)
        get;
    }

    // These three methods have to do with security and reference counting;
    // public void DangerousAddRef(ref Boolean success) { ... }
    // public IntPtr DangerousGetHandle() { ... }
    // public void DangerousRelease() { ... }
}