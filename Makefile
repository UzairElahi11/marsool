

# Detect OS and set appropriate commands
ifeq ($(OS),Windows_NT)
    GRADLEW = gradlew.bat
    RM_RF = rmdir /s /q
    MKDIR = mkdir
else
    GRADLEW = ./gradlew
    RM_RF = rm -rf
    MKDIR = mkdir -p
endif

# Color codes for better output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
PURPLE = \033[0;35m
CYAN = \033[0;36m
NC = \033[0m # No Color


## Get all Flutter dependencies
deps:
	@echo "$(BLUE)📦 Getting Flutter dependencies...$(NC)"
	flutter pub get
	@echo "$(GREEN)✅ 📦 Dependencies installed$(NC)"

## Refresh project (includes deps)
refresh: deps
	@echo "$(GREEN)✅ 🔄 Project refreshed$(NC)"

## Build Android App Bundle (.aab)
build-aab: refresh
	@echo "$(BLUE)🔨 Building App Bundle (Gradle)...$(NC)"
	cd android && $(GRADLEW) bundleRelease
	@echo "$(GREEN)✅ 📱 App Bundle built successfully$(NC)"

## Build Android APK (.apk)
build-apk: refresh
	@echo "$(BLUE)🔨 Building APK (Gradle)...$(NC)"
	cd android && $(GRADLEW) assembleRelease
	@echo "$(GREEN)✅ 🤖 APK built successfully$(NC)"

## Build Split APKs (for IS environment)
is-apk:
	@echo "$(YELLOW)⚡ IS build...$(NC)"
	flutter build apk --split-per-abi

## Clear Flutter pub cache
clear-cache:
	@echo "$(BLUE)🗑️  Clearing Flutter cache...$(NC)"
	flutter pub cache clean
	@echo "$(GREEN)✅ 🗑️  Flutter cache cleared$(NC)"

## Clean and reinstall iOS Pods
clean-ios:
	@echo "$(BLUE)🧹 Cleaning iOS pods and reinstalling...$(NC)"
	flutter pub get
	cd ios && $(RM_RF) Podfile.lock Pods
	flutter pub get
	cd ios && pod install
	@echo "$(GREEN)✅ 🍎 iOS cleaned and pods reinstalled$(NC)"

## Rebuild Android Gradle project
rebuild-android: 
	@echo "$(BLUE)🔄 Rebuilding Android project...$(NC)"
	cd android && $(GRADLEW) clean
	@echo "$(GREEN)✅ 🤖 Android project rebuilt$(NC)"


## Run build_runner for code generation
build-runner: refresh
	@echo "$(BLUE)🔧 Running build_runner code generation...$(NC)"
	flutter pub run build_runner build --delete-conflicting-outputs
	@echo "$(GREEN)✅ 🔧 Code generation completed$(NC)"


## Create Android Git Tag
git-android-tag:
	@echo "$(PURPLE)🏷️  Creating Android Git Tag...$(NC)"
	@echo "$(CYAN)📝 Example: git tag -a v1.0.0-android+1 -m 'Release 1.0.0 (Android build 1)'$(NC)"
	git tag -a vMajor.Minor.Path-android+Build_Number -m "Release Major.Minor.Path (Android build Number)"
	@echo "$(GREEN)✅ 🏷️  Android tag created$(NC)"


## Create iOS Git Tag
git-ios-tag:
	@echo "$(PURPLE)🏷️  Creating iOS Git Tag...$(NC)"
	@echo "$(YELLOW)💡 Usage: Replace vMajor.Minor.Path-ios+Build_Number with actual version$(NC)"
	@echo "$(CYAN)📝 Example: git tag -a v1.0.0-ios+1 -m 'Release 1.0.0 (iOS build 1)'$(NC)"
	git tag -a vMajor.Minor.Path-ios+Build_Number -m "Release Major.Minor.Path (iOS build Number)"
	@echo "$(GREEN)✅ 🏷️  iOS tag created$(NC)"



## ================================= GIT ================================
## Safely pull latest code (try rebase first, fallback to merge if needed)
pull:
	@echo "Attempting git pull --rebase..."
	@if git pull --rebase; then \
		echo "✓ Successfully pulled with rebase"; \
	else \
		echo "✗ Rebase failed due to conflicts"; \
		echo "Aborting rebase..."; \
		git rebase --abort; \
		echo "Falling back to regular git pull..."; \
		if git pull; then \
			echo "✓ Successfully pulled with merge"; \
		else \
			echo "✗ Merge also has conflicts - please resolve manually"; \
			exit 1; \
		fi \
	fi


stash:
	@read -p "Enter stash comment: " comment; \
	if [ -z "$$comment" ]; then \
		echo "✗ Stash comment cannot be empty"; \
		exit 1; \
	fi; \
	if git stash push -m "$$comment"; then \
		echo "✓ Successfully stashed changes with comment: $$comment"; \
	else \
		echo "✗ Failed to stash changes"; \
		exit 1; \
	fi

# `.PHONY` marks targets as commands (not files), ensuring they always run
# even if a file or folder with the same name exists.
.PHONY: help setup deps refresh clear-cache clean-ios build-aab build-apk is-apk \
        build-runner rebuild-android git-android-tag git-ios-tag pull stash


