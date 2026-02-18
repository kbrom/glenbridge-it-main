#!/usr/bin/env python3
"""
Script to create a more comprehensive maintenance page for the Glenbridge IT website.
This script creates additional files to ensure all paths redirect to the maintenance page.
"""

import os
import subprocess
import json

# Create a directory structure to mimic the website sections
directories = [
    'about',
    'services',
    'church',
    'consulting',
    'contact',
    'blog',
    'images'
]

# Create directories
for directory in directories:
    os.makedirs(directory, exist_ok=True)
    print(f"Created directory: {directory}")

# Create maintenance page in each directory
maintenance_html = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="refresh" content="0;url=/">
    <title>Website Temporarily Unavailable | Glenbridge IT</title>
</head>
<body>
    <p>Redirecting to maintenance page...</p>
</body>
</html>"""

for directory in directories:
    with open(f"{directory}/index.html", "w") as f:
        f.write(maintenance_html)
    print(f"Created maintenance page in {directory}/index.html")

# Create a robots.txt file to prevent indexing
robots_txt = """User-agent: *
Disallow: /
"""

with open("robots.txt", "w") as f:
    f.write(robots_txt)
print("Created robots.txt file to prevent search engine indexing")

# Create error documents
error_pages = [400, 403, 404, 500, 501, 502, 503]

error_html = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="refresh" content="0;url=/">
    <title>Website Temporarily Unavailable | Glenbridge IT</title>
</head>
<body>
    <p>Redirecting to maintenance page...</p>
</body>
</html>"""

for error_code in error_pages:
    with open(f"error{error_code}.html", "w") as f:
        f.write(error_html)
    print(f"Created error page for HTTP {error_code}")

# Upload all files to S3
print("\nUploading files to S3...")
subprocess.run(["aws", "s3", "sync", ".", "s3://glenbridge-it.com/", "--cache-control", "no-cache"])

# Create invalidation for CloudFront
print("\nCreating CloudFront invalidation...")
subprocess.run(["aws", "cloudfront", "create-invalidation", "--distribution-id", "E1M0LVBVUJYM8E", "--paths", "/*"])
subprocess.run(["aws", "cloudfront", "create-invalidation", "--distribution-id", "EB7YJLUKK1801", "--paths", "/*"])

print("\nWebsite shutdown complete!")
print("The Glenbridge IT website has been replaced with maintenance pages.")
print("Note: Users may still see cached content for a short time until the CloudFront cache expires.")