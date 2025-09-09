# JFR Recorder

Helper package for Ballerina to create jfr recordings.

```ballerina

import ballerina/lang.runtime;
import heshanp/jfr_recorder;

public function main() {
    jfr_recorder:continuouslyRecordJfr("jfr_records", [], 10);
    int[] numbers = [];
    while numbers.length() < int:MAX_VALUE {
        numbers.push(numbers.length());
        if numbers.length() % 1000000 == 0 {
            runtime:sleep(10);
        }
    }
}

```

## Native image

When used with native image (`--graalvm`) include corresponding graalvm build options
```toml
[build-options]
graalvmBuildOptions = "--enable-monitoring=jfr,jvmstat"
```
