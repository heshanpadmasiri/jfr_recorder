import ballerina/jballerina.java;
import ballerina/jballerina.java.arrays;
import ballerina/lang.runtime;

isolated function stringArrayToJavaStringArray(string[] events) returns handle {
    handle eventsArray = arrays:newInstance(checkpanic java:getClass("java.lang.String"), events.length());
    foreach int i in 0..<events.length() {
        arrays:set(eventsArray, i, java:fromString(events[i]));
    }
    return eventsArray;
}

# Create a JFR recording.
#
# + path - the directory to create the JFR recording in
# + events - the events to record, if empty will use a common set of events covering gc, allocations, threads and exceptions
# + duration - the duration of the recording in seconds
public isolated function recordJfr(string path, string[] events, int duration) {
    handle eventsArray = stringArrayToJavaStringArray(events);
    recordJfrInner(java:fromString(path), eventsArray, duration);
}

public isolated function continuouslyRecordJfr(string path, string[] events, int duration) {
    handle eventsArray = stringArrayToJavaStringArray(events);
    future<()> _ = start continuouslyRecordJfrInner(java:fromString(path), eventsArray, duration);
}


public isolated function continuouslyRecordJfrInner(handle path, handle events, int duration) {
    while true {
        recordJfrInner(path, events, duration);
        runtime:sleep(<decimal> duration);
    }
}

isolated function recordJfrInner(handle path, handle events, int duration) = @java:Method {
    name: "record",
    'class: "JfrRecorder"
} external;
