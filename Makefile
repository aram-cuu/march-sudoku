.PHONY: setup test lint build-web build-android build-all deploy-web deploy-android infra-init infra-plan infra-apply clean help

FLUTTER_PROJECT = march_sudoku
VERSION = $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
VERSION_CLEAN = $(shell echo $(VERSION) | sed 's/^v//')
BUILD_DIR = build
WEB_BUILD_DIR = $(FLUTTER_PROJECT)/build/web
ANDROID_BUILD_DIR = $(FLUTTER_PROJECT)/build/app/outputs/flutter-apk
AWS_REGION ?= us-east-1
S3_WEB_BUCKET ?= 
S3_ARTIFACTS_BUCKET ?= 
CLOUDFRONT_DISTRIBUTION_ID ?= 

help:
	@echo "Available targets:"
	@echo "  setup           - Install Flutter dependencies"
	@echo "  test            - Run unit and widget tests"
	@echo "  lint            - Run Flutter analyze"
	@echo "  build-web       - Build Flutter web release"
	@echo "  build-android   - Build Android APK"
	@echo "  build-all       - Build both web and Android"
	@echo "  deploy-web      - Sync web build to S3 and invalidate CloudFront"
	@echo "  deploy-android  - Upload APK to S3 artifacts bucket"
	@echo "  infra-init      - Initialize Terraform Cloud backend"
	@echo "  infra-plan      - Run Terraform plan"
	@echo "  infra-apply     - Run Terraform apply"
	@echo "  clean           - Clean build artifacts"

setup:
	cd $(FLUTTER_PROJECT) && flutter pub get

test:
	cd $(FLUTTER_PROJECT) && flutter test

lint:
	cd $(FLUTTER_PROJECT) && flutter analyze

build-web:
	cd $(FLUTTER_PROJECT) && flutter build web --release --build-name=$(VERSION_CLEAN) --build-number=1

build-android:
	cd $(FLUTTER_PROJECT) && flutter build apk --release --build-name=$(VERSION_CLEAN) --build-number=1

build-all: build-web build-android

deploy-web:
	@if [ -z "$(S3_WEB_BUCKET)" ]; then \
		echo "Error: S3_WEB_BUCKET must be set"; \
		exit 1; \
	fi
	@if [ -z "$(CLOUDFRONT_DISTRIBUTION_ID)" ]; then \
		echo "Error: CLOUDFRONT_DISTRIBUTION_ID must be set"; \
		exit 1; \
	fi
	aws s3 sync $(WEB_BUILD_DIR) s3://$(S3_WEB_BUCKET) --region $(AWS_REGION) --delete
	aws cloudfront create-invalidation --distribution-id $(CLOUDFRONT_DISTRIBUTION_ID) --paths "/*" --region $(AWS_REGION)

deploy-android:
	@if [ -z "$(S3_ARTIFACTS_BUCKET)" ]; then \
		echo "Error: S3_ARTIFACTS_BUCKET must be set"; \
		exit 1; \
	fi
	@if [ ! -f "$(ANDROID_BUILD_DIR)/app-release.apk" ]; then \
		echo "Error: APK not found. Run 'make build-android' first"; \
		exit 1; \
	fi
	aws s3 cp $(ANDROID_BUILD_DIR)/app-release.apk \
		s3://$(S3_ARTIFACTS_BUCKET)/android/$(VERSION_CLEAN)/march_sudoku.apk \
		--region $(AWS_REGION)

infra-init:
	cd infrastructure && terraform init

infra-plan:
	cd infrastructure && terraform plan

infra-apply:
	cd infrastructure && terraform apply

clean:
	cd $(FLUTTER_PROJECT) && flutter clean
	rm -rf $(BUILD_DIR)
