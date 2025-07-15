.PHONY: help build debug release profile clean

# Default target
help:
	@echo "🚀 DressApp Build Commands"
	@echo "=========================="
	@echo "make build     - Build debug APK"
	@echo "make debug     - Build debug APK"
	@echo "make release   - Build release APK"
	@echo "make profile   - Build profile APK"
	@echo "make clean     - Clean build artifacts"

# Build targets
build:
	@echo "📱 Building Flutter app..."
	flutter build apk --debug

debug: build

release:
	@echo "🚀 Building release APK..."
	flutter build apk --release

profile:
	@echo "📊 Building profile APK..."
	flutter build apk --profile

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	flutter clean
	rm -rf build/

# Development helpers
dev:
	@echo "🚀 Starting development server..."
	flutter run

test:
	@echo "🧪 Running tests..."
	flutter test

# Install dependencies
install:
	@echo "📦 Installing Flutter dependencies..."
	flutter pub get 