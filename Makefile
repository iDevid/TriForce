.PHONY: help dev android-install

SWIFT_VERSION := 6.3.0
SWIFT_ANDROID_SDK_ID := swift-6.3-RELEASE_android
SWIFT_ANDROID_ARTIFACT_BUNDLE := swift-6.3-RELEASE_android.artifactbundle
SWIFT_ANDROID_SDK_URL := https://download.swift.org/swift-6.3-release/android-sdk/swift-6.3-RELEASE/swift-6.3-RELEASE_android.artifactbundle.tar.gz
SWIFT_ANDROID_SDK_CHECKSUM := 2f2942c4bcea7965a08665206212c66991dabe23725aeec7c4365fc91acad088
BACKEND_PORT ?= 8080

ANDROID_DIR := /Users/idevid/Git/TriForce/android
ANDROID_INTEROP_DIR := $(ANDROID_DIR)/swift-interop
ANDROID_SDK_ROOT ?= $(HOME)/Library/Android/sdk
ANDROID_NDK_PACKAGE := ndk;27.2.12479018
ANDROID_PLATFORM_PACKAGE := platforms;android-34
ANDROID_BUILD_TOOLS_PACKAGE := build-tools;34.0.0
ANDROID_PLATFORM_TOOLS_PACKAGE := platform-tools
SWIFT_PM_SDKS_DIR := $(HOME)/Library/org.swift.swiftpm/swift-sdks
SWIFT_ANDROID_SETUP_SCRIPT := $(SWIFT_PM_SDKS_DIR)/$(SWIFT_ANDROID_ARTIFACT_BUNDLE)/swift-android/scripts/setup-android-sdk.sh
SDKMANAGER := $(ANDROID_SDK_ROOT)/cmdline-tools/latest/bin/sdkmanager
LOCAL_SWIFT_JAVA_DIR := $(CURDIR)/swift-java

help:
	@echo "Available targets:"
	@echo "  make dev             Run the Vapor backend"
	@echo "  make android-install Install the Android toolchain used by this repo"

dev:
	@set -eu; \
	listener_info="$$(lsof -nP -iTCP:$(BACKEND_PORT) -sTCP:LISTEN -Fpc 2>/dev/null || true)"; \
	pid="$$(printf '%s\n' "$$listener_info" | sed -n 's/^p//p' | head -n 1)"; \
	command_name="$$(printf '%s\n' "$$listener_info" | sed -n 's/^c//p' | head -n 1)"; \
	if [ -n "$$pid" ]; then \
		if [ "$$command_name" = "Run" ]; then \
			echo "Stopping existing backend on port $(BACKEND_PORT) (pid $$pid)..."; \
			kill "$$pid"; \
			while lsof -tiTCP:$(BACKEND_PORT) -sTCP:LISTEN >/dev/null 2>&1; do \
				sleep 1; \
			done; \
		else \
			echo "Port $(BACKEND_PORT) is already in use by '$$command_name' (pid $$pid)."; \
			echo "Stop that process or run with BACKEND_PORT=<port> if you intend to change the backend port."; \
			exit 1; \
		fi; \
	fi; \
	swift run --package-path backend

android-install:
	@set -euo pipefail; \
	if [ ! -f "$(HOME)/.swiftly/env.sh" ]; then \
		echo "swiftly is required. Install it first: https://swiftlang.github.io/swiftly/"; \
		exit 1; \
	fi; \
	if [ ! -x "$(SDKMANAGER)" ]; then \
		echo "Android sdkmanager not found at $(SDKMANAGER). Install Android command-line tools and/or set ANDROID_SDK_ROOT."; \
		exit 1; \
	fi; \
	. "$(HOME)/.swiftly/env.sh"; \
	echo "Installing Swift $(SWIFT_VERSION) with swiftly..."; \
	swiftly install $(SWIFT_VERSION); \
	swiftly use $(SWIFT_VERSION); \
	echo "Installing the official Swift Android SDK..."; \
	if ! swift sdk list | grep -q "$(SWIFT_ANDROID_SDK_ID)"; then \
		swift sdk install "$(SWIFT_ANDROID_SDK_URL)" --checksum "$(SWIFT_ANDROID_SDK_CHECKSUM)"; \
	else \
		echo "Swift Android SDK already installed."; \
	fi; \
	echo "Installing Android SDK components..."; \
	yes | "$(SDKMANAGER)" "$(ANDROID_PLATFORM_TOOLS_PACKAGE)" "$(ANDROID_PLATFORM_PACKAGE)" "$(ANDROID_BUILD_TOOLS_PACKAGE)" "$(ANDROID_NDK_PACKAGE)"; \
	echo "Running the Swift Android SDK setup script..."; \
	"$(SWIFT_ANDROID_SETUP_SCRIPT)"; \
	echo "Resolving Swift interop package dependencies..."; \
	swift package resolve --package-path "$(ANDROID_INTEROP_DIR)"; \
	echo "Publishing swift-java runtime artifacts to Maven Local..."; \
	JAVA_HOME="$${JAVA_HOME:-$$(/usr/libexec/java_home -v 21 2>/dev/null || /usr/libexec/java_home -v 17 2>/dev/null || /usr/libexec/java_home -v 25 2>/dev/null)}"; \
	if [ -z "$$JAVA_HOME" ]; then \
		echo "A JDK is required to publish swift-java artifacts to Maven Local."; \
		exit 1; \
	fi; \
	export JAVA_HOME; \
	export PATH="$$JAVA_HOME/bin:$$PATH"; \
	"$(LOCAL_SWIFT_JAVA_DIR)/gradlew" --project-dir "$(LOCAL_SWIFT_JAVA_DIR)" :SwiftKitCore:publishToMavenLocal; \
	echo "Android toolchain setup complete."
