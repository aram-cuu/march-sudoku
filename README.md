# Sudoku Flutter application

A Flutter Sudoku game with solving, generating, and difficulty classification features. Runs on web and Android.

## Prerequisites

Before running this application, ensure you have the following installed:

- Flutter SDK (version 3.24.0 or later)
- Dart SDK (included with Flutter)
- Android Studio or Android SDK (for Android builds)
- Chrome or any modern web browser (for web builds)
- Make
- Terraform CLI with a Terraform Cloud account (for infrastructure provisioning)
- AWS CLI (for deployment)

## Getting started

### Installation

Install Flutter dependencies:

```bash
make setup
```

### Running locally

**Web:**

```bash
cd march_sudoku
flutter run -d chrome
```

**Android:**

```bash
cd march_sudoku
flutter run
```

Make sure you have an Android emulator running or a physical device connected.

### Testing

Run the test suite:

```bash
make test
```

### Linting

Check code quality and style:

```bash
make lint
```

## Building

### Build for web

```bash
make build-web
```

The output goes to `march_sudoku/build/web`.

### Build for Android

```bash
make build-android
```

The APK is generated at `march_sudoku/build/app/outputs/flutter-apk/app-release.apk`.

### Build all platforms

```bash
make build-all
```

## Deployment

### Infrastructure setup

Infrastructure is managed through Terraform Cloud under the `aram-playground` organization in the `march-sudoku-production` workspace. State, locking, and run history are all handled remotely.

Before your first run, authenticate with Terraform Cloud and initialize the backend:

```bash
terraform login
make infra-init
```

Then provision the AWS resources:

```bash
make infra-plan
make infra-apply
```

This creates:

1. An S3 bucket for web hosting, fronted by a CloudFront distribution
2. An S3 bucket for storing versioned Android APK artifacts
3. A dedicated IAM user for GitHub Actions with least-privilege permissions
4. An Origin Access Identity so the web bucket is only reachable through CloudFront

After the first apply, the Terraform outputs provide all the values needed for deployment. You can view them in the Terraform Cloud workspace or locally:

```bash
terraform -chdir=infrastructure output
```

### Deploy web application

```bash
make deploy-web \
  S3_WEB_BUCKET=your-web-bucket-name \
  CLOUDFRONT_DISTRIBUTION_ID=your-distribution-id \
  AWS_REGION=us-east-1
```

### Deploy Android artifacts

```bash
make deploy-android \
  S3_ARTIFACTS_BUCKET=your-artifacts-bucket-name \
  AWS_REGION=us-east-1
```

The APK is stored at `s3://your-artifacts-bucket/android/<version>/march_sudoku.apk`.

### Versioning

The application uses semantic versioning driven by git tags. The Makefile extracts the version from the latest tag and passes it to the Flutter build via `--build-name`.

To create a new release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Pushing a version tag triggers the deploy workflow, which builds both platforms, deploys to AWS, and creates a GitHub Release with the artifacts attached.

## CI/CD

### CI workflow

Defined in `.github/workflows/ci.yml`, runs on every push and pull request to `main`, `master`, or `develop`.

Steps: checkout, install dependencies, lint, test, build web, build Android. Both build artifacts (web bundle and APK) are uploaded to the workflow run and retained for 7 days.

### Deploy workflow

Defined in `.github/workflows/deploy.yml`, runs when a version tag (`v*`) is pushed.

Steps: checkout, install dependencies, build web, build Android APK, deploy web to S3 and invalidate CloudFront, upload APK to the S3 artifacts bucket, create a GitHub Release with the APK attached.

### GitHub secrets

The deploy workflow uses a dedicated IAM user (`march-sudoku-github-deploy`) created by Terraform with least-privilege access limited to the two S3 buckets and CloudFront invalidation.

After the first `terraform apply`, retrieve the deploy credentials from Terraform Cloud outputs or locally:

```bash
terraform -chdir=infrastructure output github_deploy_access_key_id
terraform -chdir=infrastructure output -raw github_deploy_secret_access_key
```

Then in the GitHub repository under **Settings, Secrets and variables, Actions**, add:

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | Output `github_deploy_access_key_id` |
| `AWS_SECRET_ACCESS_KEY` | Output `github_deploy_secret_access_key` |
| `AWS_REGION` | `us-east-1` (optional, defaults to us-east-1) |
| `S3_WEB_BUCKET` | Output `web_bucket_name` |
| `S3_ARTIFACTS_BUCKET` | Output `artifacts_bucket_name` |
| `CLOUDFRONT_DISTRIBUTION_ID` | Output `cloudfront_distribution_id` |

## Project structure

```
march/
├── march_sudoku/              Flutter application
│   ├── lib/
│   │   ├── models/            Data models
│   │   ├── services/          Business logic (solver, generator, classifier, parser)
│   │   ├── providers/         State management
│   │   └── screens/           UI screens
│   ├── assets/puzzles/        Example puzzle files
│   └── test/                  Unit tests
├── infrastructure/            Terraform Cloud infrastructure
│   ├── main.tf                Provider, backend, locals
│   ├── variables.tf           Input variables
│   ├── outputs.tf             Output values
│   ├── s3.tf                  S3 buckets (web + artifacts)
│   ├── cloudfront.tf          CloudFront distribution
│   └── iam.tf                 GitHub Actions deploy IAM user
├── .github/workflows/
│   ├── ci.yml                 CI on push and pull request
│   └── deploy.yml             Deploy on version tag
├── Makefile                   Build, test, and deploy targets
├── docs/
│   ├── architecture.md        Architecture overview with diagrams
│   └── algorithms.md          Algorithm explanations with pseudocode
├── NOTES.md                   Personal notes
└── README.md
```

## Features

**Part 1**: Reads Sudoku puzzles from text files where each file contains 9 lines of 9 characters.

**Part 2**: Solves puzzles using backtracking and verifies solution uniqueness. Classifies difficulty into four levels (easy, medium, hard, samurai) based on clue count and required solving techniques.

**Part 3**: Generates puzzles with unique solutions. Supports rotationally symmetric cell removal and target difficulty levels.

**Part 4**: Provides a UI for playing generated puzzles, solving user-provided puzzles, and viewing solutions alongside the original input.

**Part 5**: Automated deployment via GitHub Actions and Terraform Cloud with S3, CloudFront, and versioned artifact storage.

## Documentation

Additional documentation is available in the `docs/` directory:

- `architecture.md` covers application architecture, screen flow, state management, and deployment topology with Mermaid diagrams
- `algorithms.md` explains each algorithm (solver, generator, classifier, parser) with pseudocode and complexity analysis

## Cleanup

Remove build artifacts:

```bash
make clean
```
