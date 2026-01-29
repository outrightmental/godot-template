<a href="https://discord.com/channels/720514857094348840/740983213756907561">![Discord](https://img.shields.io/badge/Comms-Discord-5865f2)</a>
<a href="https://godotengine.org/">![Godot](https://img.shields.io/badge/Godot-4.4.1%2B-478cbf)</a>
[![qc](https://github.com/outrightmental/godot-template/actions/workflows/qc.yml/badge.svg)](https://github.com/outrightmental/godot-template/actions/workflows/qc.yml)
[![Distro](https://github.com/outrightmental/godot-template/actions/workflows/distro.yml/badge.svg)](https://github.com/outrightmental/godot-template/actions/workflows/distro.yml)

# **Godot Template**

by [Outright Mental](https://outrightmental.com)

## Web Deployment

The project includes automated web deployment to AWS S3 with CloudFront CDN integration. The workflow is triggered on pushes to the `main` branch and deploys the web build to S3, then invalidates the CloudFront CDN cache.

### Required Secrets

Configure the following secrets in your GitHub repository settings:

- `AWS_ACCESS_KEY_ID` - AWS access key with permissions for S3 and CloudFront
- `AWS_SECRET_ACCESS_KEY` - AWS secret access key
- `AWS_S3_BUCKET` - S3 bucket name for web hosting
- `AWS_REGION` - AWS region (defaults to `us-east-1` if not set)
- `AWS_CLOUDFRONT_CDN_ID` - CloudFront distribution ID (optional, skips invalidation if not set)

### CloudFront CDN Invalidation

After deploying to S3, the workflow automatically invalidates the CloudFront CDN cache by creating an invalidation for all paths (`/*`). This ensures that users see the latest version of your game immediately after deployment, rather than waiting for the cache to expire.

If the `AWS_CLOUDFRONT_CDN_ID` secret is not configured, the workflow will skip the CloudFront invalidation step and continue successfully.

## Project Structure

This template follows a well-organized structure for Godot projects:

```
godot-template/
├── assets/              # Game assets organized by type
│   ├── fonts/          # Font files
│   ├── sounds/         # Audio files
│   └── sprites/        # Image and sprite files
├── autoload/           # Autoload (singleton) scripts
├── data/               # Game data files (JSON, CSV, etc.)
├── scenes/             # Godot scene files (.tscn)
│   ├── board/          # Board-related scenes
│   ├── run/            # Run/level scenes
│   ├── ui/             # User interface scenes
│   └── main.tscn       # Main scene
├── scripts/            # GDScript files organized by domain
│   ├── model/          # Data models and structures
│   ├── systems/        # Game systems and logic
│   └── ui/             # UI-related scripts
├── tests/              # Unit and integration tests
│   ├── model/          # Tests for data models
│   ├── systems/        # Tests for game systems
│   ├── test_suite.gd   # Base test suite class
│   └── test_runner_scene.tscn # Test runner scene
├── project.godot       # Godot project configuration
├── export_presets.cfg  # Export settings for different platforms
└── icon.svg            # Project icon
```

### Autoload Singletons

The project is configured with the following autoload scripts (defined in `project.godot`):

- **RNG** (`autoload/rng.gd`) - Random number generation utilities
- **TimeManager** (`autoload/time_manager.gd`) - Game time management
- **RunState** (`autoload/run_state.gd`) - Current run state tracking
- **Economy** (`autoload/economy.gd`) - Game economy system

### Directory Conventions

- **scenes/** - Contains `.tscn` scene files with their corresponding `.gd` scripts in the same directory
- **scripts/** - Contains reusable GDScript files organized by domain (model, systems, ui)
- **tests/** - Mirrors the structure of scenes/ and scripts/ for easy test organization
- **assets/** - All non-code resources (fonts, sounds, sprites) organized by type
