import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Duration;

import jdk.jfr.Recording;
import jdk.jfr.RecordingState;

public class JfrRecorder {

    private static final java.util.UUID MACHINE_ID = java.util.UUID.randomUUID();

    public static void record(String path, String[] events, int duration) {
    Thread thread = new Thread(() -> {
        try {
            recordInner(path, events, duration);
        } catch (Exception e) {
            e.printStackTrace();
        }
    });
    thread.start();
    }

    private static void recordInner(String path, String[] events, int duration) throws IOException, InterruptedException {
        File dir = new File(path);
        if (!dir.exists()) {
            if (dir.mkdirs()) {
                System.out.println("Directory created: " + path);
            } else {
                System.err.println("Failed to create directory: " + path);
                throw new IOException("Could not create directory: " + path);
            }
        }
        Recording recording = new Recording();
        recording.setName("Ballerina JFR Recording");
        recording.setDuration(Duration.ofSeconds(duration));
        if (events.length == 0) {
            // Enable all events when no specific events are provided
            System.out.println("No specific events provided, enabling allocation, GC, exception, and virtual thread events...");
            String[] commonEvents = {
                // Allocation events
                "jdk.ObjectAllocationInNewTLAB",
                "jdk.ObjectAllocationOutsideTLAB",
                "jdk.ObjectAllocationSample",
                // GC events
                "jdk.GCPhaseParallel",
                "jdk.GCPhaseConcurrent",
                "jdk.GCPhasePause",
                "jdk.GCHeapSummary",
                "jdk.GCCollectionSummary",
                "jdk.GCConfiguration",
                "jdk.GCReferenceStatistics",
                // Exception events
                "jdk.JavaExceptionThrown",
                "jdk.JavaErrorThrown",
                // Virtual thread events
                "jdk.VirtualThreadStart",
                "jdk.VirtualThreadEnd",
                "jdk.VirtualThreadPinned",
                "jdk.VirtualThreadSubmitFailed",
                "jdk.VirtualThreadSubmitBlocked"
            };
            for (String event : commonEvents) {
                recording.enable(event);
            }
        } else {
            System.out.println("Enabling specific events: " + java.util.Arrays.toString(events));
            for (String event : events) {
                recording.enable(event);
            }
        }
        Path filePath = Paths.get(path + File.separator + "jfr_recording_" + MACHINE_ID + "_" + System.currentTimeMillis() + ".jfr");
        System.out.println("Dumping recording to " + filePath);
        recording.setDestination(filePath);
        recording.setDumpOnExit(true);
        recording.start();
        System.out.println("Recording started...");
        while (recording.getState() == RecordingState.RUNNING) {
            Thread.sleep(Duration.ofSeconds(duration).toMillis());
        }
        System.out.println("Recording stopped...");
        recording.close();
    }
}
