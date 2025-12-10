# GitHub Actions Workload Identity Provider

This Terraform module sets up secure authentication between GitHub Actions and Google Cloud Platform using Workload Identity Federation, eliminating the need for service account JSON keys.

## What is Workload Identity?

Workload Identity Federation allows GitHub Actions to authenticate to Google Cloud using OIDC tokens instead of storing permanent service account keys. This provides:

- **Enhanced Security**: No permanent credentials stored in GitHub
- **Short-lived Tokens**: Automatic token expiration
- **Repository Scoping**: Access restricted to specific repositories
- **Audit Trail**: All authentication attempts are logged

## Architecture

```
GitHub Actions Workflow
        ↓ (OIDC Token)
Workload Identity Provider
        ↓ (Validates Token)
Google Cloud Service Account
        ↓ (Impersonation)
Google Cloud Services
```

## Prerequisites

1. **Google Cloud Project** with required APIs enabled:
   - Identity and Access Management (IAM) API
   - Security Token Service (STS) API
   - IAM Service Account Credentials API

2. **GitHub Repository** with Actions enabled

3. **Terraform** >= 1.0



### 1. Configure GitHub Repository Secrets

After deployment, get the required values:

```bash
terraform output github_secrets_instructions
```

Add these secrets to your GitHub repository:
- Go to: `https://github.com/{org}/{repo}/settings/secrets/actions`
- Add the following repository secrets:

| Secret Name | Value |
|-------------|-------|
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | `projects/{project-number}/locations/global/workloadIdentityPools/{pool-id}/providers/{provider-id}` |
| `GCP_SERVICE_ACCOUNT` | `github-actions@{project-id}.iam.gserviceaccount.com` |

## References

- [Google Cloud Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [google-github-actions/auth](https://github.com/google-github-actions/auth)
