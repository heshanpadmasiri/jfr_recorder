# Makefile for jfr_recorder project

# Variables
JAVA_SRC = JfrRecorder.java
JAR_NAME = jfr_recorder.jar
CLASS_NAME = JfrRecorder
JAVA_BUILD_DIR = java_build
BAL_SRC = main.bal
GRAALVM_HOME ?= /Users/heshanp/GraalVM/graalvm-community-openjdk-21.0.2+13.1/Contents/Home

# Default target
.PHONY: all
all: buildJar

# Create Java build directory
$(JAVA_BUILD_DIR):
	mkdir -p $(JAVA_BUILD_DIR)

# Compile Java source to JAR
$(JAR_NAME): $(JAVA_SRC) | $(JAVA_BUILD_DIR)
	javac -d $(JAVA_BUILD_DIR) $(JAVA_SRC)
	cd $(JAVA_BUILD_DIR) && jar cfe ../$(JAR_NAME) $(CLASS_NAME) *.class
	@echo "JAR file created: $(JAR_NAME)"

# Alias for buildJar
.PHONY: buildJar
buildJar: $(JAR_NAME)

# Clean build artifacts
.PHONY: clean
clean:
	rm -rf $(JAVA_BUILD_DIR)
	rm -f $(JAR_NAME)
	rm -rf jfr_records
	rm -f *.jfr
	@echo "Build artifacts and JFR records cleaned"

# Build Ballerina project (depends on *.bal files and JAR)
.PHONY: build
build: $(BAL_SRC) $(JAR_NAME)
	bal build

# Run Ballerina project (depends on *.bal files and JAR)
.PHONY: run
run: $(BAL_SRC) $(JAR_NAME)
	bal run

# Run the JAR file directly
.PHONY: runJar
runJar: $(JAR_NAME)
	java -jar $(JAR_NAME)

# Build Ballerina project with GraalVM native image (depends on *.bal files and JAR)
.PHONY: buildNative
buildNative: $(BAL_SRC) $(JAR_NAME)
	GRAALVM_HOME=$(GRAALVM_HOME) bal build --graalvm

# Run Ballerina project with GraalVM native image (depends on buildNative)
.PHONY: runNative
runNative: buildNative
	./target/bin/jfr_recorder

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  buildJar    - Compile JfrRecorder.java to a JAR file"
	@echo "  build       - Build Ballerina project (depends on buildJar)"
	@echo "  buildNative - Build Ballerina project with GraalVM native image (depends on buildJar)"
	@echo "  run         - Run Ballerina project (depends on buildJar)"
	@echo "  runNative   - Run Ballerina project with GraalVM native image (depends on buildJar)"
	@echo "  runJar      - Run the JAR file directly"
	@echo "  clean       - Remove build artifacts"
	@echo "  help        - Show this help message"
