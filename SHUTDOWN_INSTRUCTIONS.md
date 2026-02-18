# Glenbridge IT Website Shutdown Instructions

## Actions Completed
- Created maintenance page (index.html)
- Uploaded maintenance page to S3 bucket (glenbridge-it.com)
- Removed all existing website content from S3
- Invalidated CloudFront cache for both distributions
- Updated Command Center dashboard with status

## Actions Pending (Require Additional Permissions)
The following actions need to be completed by an administrator with proper CloudFront permissions:

1. Disable CloudFront distribution E1M0LVBVUJYM8E (Domain: d1em9qqschc4wp.cloudfront.net)
2. Disable CloudFront distribution EB7YJLUKK1801 (Domain: drjipk52kzvc9.cloudfront.net)

## Instructions for Disabling CloudFront Distributions
Run the following AWS CLI commands:

```bash
# For the first distribution
aws cloudfront get-distribution-config --id E1M0LVBVUJYM8E > cf_config_1.json
ETAG_1=$(cat cf_config_1.json | jq -r '.ETag')
cat cf_config_1.json | jq '.DistributionConfig.Enabled = false' > cf_config_1_disabled.json
aws cloudfront update-distribution --id E1M0LVBVUJYM8E --distribution-config file://cf_config_1_disabled.json --if-match "$ETAG_1"

# For the second distribution
aws cloudfront get-distribution-config --id EB7YJLUKK1801 > cf_config_2.json
ETAG_2=$(cat cf_config_2.json | jq -r '.ETag')
cat cf_config_2.json | jq '.DistributionConfig.Enabled = false' > cf_config_2_disabled.json
aws cloudfront update-distribution --id EB7YJLUKK1801 --distribution-config file://cf_config_2_disabled.json --if-match "$ETAG_2"
```

## Current Status
The website at https://glenbridge-it.com now displays a maintenance page. All original content has been removed from the S3 bucket, but the CloudFront distributions are still active.

## Verification
Once the CloudFront distributions have been disabled, you can verify the shutdown by checking:
1. The CloudFront distribution status in the AWS Console
2. The website availability at https://glenbridge-it.com (should show the maintenance page)
3. The website availability at the direct CloudFront domains (should eventually show as disabled)