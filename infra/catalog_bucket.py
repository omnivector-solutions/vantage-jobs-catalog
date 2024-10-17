"""S3 infrastructure for the job scripts artifacts of the Vantage Jobs Catalog."""

import aws_cdk as cdk
from aws_cdk import (
    App,
    Stack,
)
from aws_cdk import (
    aws_iam as iam,
)
from aws_cdk import (
    aws_s3 as s3,
)


class ArtifactBucket(Stack):
    """Stack for the S3 bucket for the job scripts artifacts."""

    def __init__(self, app: App, id: str, **kwargs):  # noqa: D107
        super().__init__(app, id, **kwargs)

        bucket = s3.Bucket(
            self,
            "ArtifactBucket",
            bucket_name="vantage-jobs-catalog-artifacts",
            removal_policy=cdk.RemovalPolicy.RETAIN,
            block_public_access=s3.BlockPublicAccess(
                block_public_acls=True,
                block_public_policy=False,
                ignore_public_acls=True,
                restrict_public_buckets=False,
            ),
        )

        bucket.add_to_resource_policy(
            iam.PolicyStatement(
                actions=["s3:GetObject"],
                effect=iam.Effect.ALLOW,
                principals=[iam.StarPrincipal()],
                resources=[bucket.arn_for_objects("files/*")],
            )
        )

        cdk.CfnOutput(
            self,
            "BucketName",
            value=bucket.bucket_name,
            description="The name of the S3 bucket for the job scripts artifacts.",
            export_name="VantageJobsCatalogArtifactsBucketName",
        )

        cdk.CfnOutput(
            self,
            "BucketRegion",
            value=self.region,
            description="The region of the S3 bucket for the job scripts artifacts.",
            export_name="VantageJobsCatalogArtifactsBucketRegion",
        )
