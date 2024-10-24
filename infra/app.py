#!/usr/bin/env python3
"""Core module for setting up the AWS CDK application for the Vantage Jobs Catalog.

It defines the environment, tags, and stacks for the application, including:
- WebsiteStack: The stack for the Vantage Jobs Catalog website.
- ArtifactBucket: The stack for the artifact storage bucket.
"""

import aws_cdk as cdk

from infra.catalog_bucket import ArtifactBucket
from infra.website import WebsiteStack

tags = {"project": "Vantage"}

env = cdk.Environment(region="us-east-1")

app = cdk.App()
WebsiteStack(app, "VantageJobsCatalogWebsite", env=env, tags=tags)
ArtifactBucket(app, "VantageJobsCatalogArtifacts", env=env, tags=tags)
app.synth()
