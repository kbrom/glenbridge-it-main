#!/bin/bash
# Script to configure S3 website redirection rules

# Define a website configuration with redirection rules
cat << 'EOF' > website_config.json
{
  "IndexDocument": {
    "Suffix": "index.html"
  },
  "ErrorDocument": {
    "Key": "index.html"
  },
  "RoutingRules": [
    {
      "Redirect": {
        "ReplaceKeyWith": "index.html"
      },
      "Condition": {
        "HttpErrorCodeReturnedEquals": "404"
      }
    },
    {
      "Redirect": {
        "ReplaceKeyWith": "index.html"
      },
      "Condition": {
        "HttpErrorCodeReturnedEquals": "403"
      }
    }
  ]
}
EOF

# Apply the website configuration
echo "Configuring S3 bucket website settings..."
aws s3api put-bucket-website --bucket glenbridge-it.com --website-configuration file://website_config.json

echo "Setting all objects to no-cache..."
aws s3 cp s3://glenbridge-it.com/index.html s3://glenbridge-it.com/index.html --metadata-directive REPLACE --cache-control "no-cache, no-store, must-revalidate" --content-type "text/html" --acl public-read

echo "Creating final CloudFront invalidation..."
aws cloudfront create-invalidation --distribution-id E1M0LVBVUJYM8E --paths "/*"
aws cloudfront create-invalidation --distribution-id EB7YJLUKK1801 --paths "/*"

echo "Website shutdown complete with redirection rules in place."