#!/bin/bash
# Script to disable CloudFront distributions for the Glenbridge website

echo "Shutting down Glenbridge IT website CloudFront distributions..."

# Get the current configuration of the first distribution
echo "Getting current configuration for distribution E1M0LVBVUJYM8E..."
aws cloudfront get-distribution-config --id E1M0LVBVUJYM8E > cf_config_1.json
ETAG_1=$(cat cf_config_1.json | jq -r '.ETag')
echo "ETag for distribution E1M0LVBVUJYM8E: $ETAG_1"

# Get the current configuration of the second distribution
echo "Getting current configuration for distribution EB7YJLUKK1801..."
aws cloudfront get-distribution-config --id EB7YJLUKK1801 > cf_config_2.json
ETAG_2=$(cat cf_config_2.json | jq -r '.ETag')
echo "ETag for distribution EB7YJLUKK1801: $ETAG_2"

# Disable the first distribution by setting Enabled to false
echo "Modifying configuration for distribution E1M0LVBVUJYM8E..."
cat cf_config_1.json | jq '.DistributionConfig.Enabled = false' > cf_config_1_disabled.json

# Disable the second distribution by setting Enabled to false
echo "Modifying configuration for distribution EB7YJLUKK1801..."
cat cf_config_2.json | jq '.DistributionConfig.Enabled = false' > cf_config_2_disabled.json

# Update the first distribution with the modified configuration
echo "Updating distribution E1M0LVBVUJYM8E..."
aws cloudfront update-distribution --id E1M0LVBVUJYM8E --distribution-config file://cf_config_1_disabled.json --if-match "$ETAG_1"

# Update the second distribution with the modified configuration
echo "Updating distribution EB7YJLUKK1801..."
aws cloudfront update-distribution --id EB7YJLUKK1801 --distribution-config file://cf_config_2_disabled.json --if-match "$ETAG_2"

echo "CloudFront distributions have been disabled. Website is now shut down."
echo "Note: It may take up to 15 minutes for the changes to fully propagate."

# Clean up temporary files
rm -f cf_config_1.json cf_config_1_disabled.json cf_config_2.json cf_config_2_disabled.json

# Update the command center dashboard
echo "Updating command center dashboard..."
echo '<html><head><title>Glenbridge IT Website Status</title></head><body><h1>Glenbridge IT Website Status</h1><p style="color:red;font-weight:bold;">WEBSITE OFFLINE</p><p>The Glenbridge IT website has been taken offline as requested.</p><p>Maintenance page is active at <a href="https://glenbridge-it.com">https://glenbridge-it.com</a>.</p><p>Last updated: '"$(date)"'</p></body></html>' > /app/fleet/glenbridge-it-main/status.html

# Upload the status report to the command center
aws s3 cp /app/fleet/glenbridge-it-main/status.html s3://glenbridge-command-center-a6e6d9/index.html