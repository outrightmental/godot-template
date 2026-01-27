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
