using System;
using System.Threading;
using System.Threading.Tasks.Dataflow;

public class GCDebugging {
    public static void Main() {

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

    public static event Action<Int32> GCDone {
        add {
            // If there were no registered delegates before, start reporting notifications now
            if (s_gcDone == null)
            {
                new GenObject(0); new GenObject(2);
            }
            s_gcDone += value;
        }
        remove {
            s_gcDone -= value;
        }
    }

    private sealed class GenObject {
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
                && !Environment.HasShutdownStarted) {
                    // For Gen 0, create a new object; for Gen 2, resurrect the object
                    // & let the GC call Finalize again the next time Gen 2 is GC'd
                    if (m_generation == 0) new GenObject(0);
                    else GC.ReRegisterForFinalize(this);
                } else { /* Let the objects go away */ }
        }
    }
}