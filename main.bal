import ballerina/lang.runtime;

public function main() {
    continuouslyRecordJfr("jfr_records", [], 10);
    int[] numbers = [];
    while numbers.length() < int:MAX_VALUE {
        numbers.push(numbers.length());
        if numbers.length() % 1000000 == 0 {
            runtime:sleep(10);
        }
    }
}
