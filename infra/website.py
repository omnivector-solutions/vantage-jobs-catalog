"""Website infrastructure for the Vantage Jobs Catalog."""

import aws_cdk as cdk
import yaml
from aws_cdk import App, Stack
from aws_cdk import aws_certificatemanager as cm
from aws_cdk import aws_cloudfront as cloudfront
from aws_cdk import aws_route53 as route53
from aws_cdk import aws_route53_targets as targets
from aws_cdk import aws_s3 as s3
from aws_cdk import aws_s3_deployment as s3_deploy


class WebsiteStack(Stack):
    """Stack for the Vantage Jobs Catalog website."""

    def __init__(self, app: App, id: str, **kwargs):  # noqa: D107
        super().__init__(app, id, **kwargs)

        site_domain = "catalog.vantagehpc.io"

        hosted_zone = route53.HostedZone.from_hosted_zone_attributes(
            self,
            "HostedZone",
            hosted_zone_id="Z063993623YJJ3OLAC1Z6",
            zone_name="vantagehpc.io",
        )

        distribution_oai = cloudfront.OriginAccessIdentity(
            self, "CloudFrontOAI", comment=f"OAI for stack {id}"
        )

        bucket = s3.Bucket(
            self,
            "HostBucket",
            bucket_name=site_domain,
            website_index_document="index.html",
            website_error_document="index.html",
            removal_policy=cdk.RemovalPolicy.DESTROY,
            cors=[
                s3.CorsRule(
                    allowed_origins=["*"],
                    allowed_methods=[s3.HttpMethods.GET, s3.HttpMethods.HEAD],
                    allowed_headers=["*"],
                )
            ],
        )

        bucket.grant_read(distribution_oai)

        certificate = cm.Certificate(
            self,
            "Certificate",
            domain_name=site_domain,
            validation=cm.CertificateValidation.from_dns(hosted_zone=hosted_zone),
        )

        distribution = cloudfront.CloudFrontWebDistribution(
            self,
            "Distribution",
            origin_configs=[
                cloudfront.SourceConfiguration(
                    behaviors=[
                        cloudfront.Behavior(
                            is_default_behavior=True,
                            max_ttl=cdk.Duration.seconds(0),
                            min_ttl=cdk.Duration.seconds(0),
                            default_ttl=cdk.Duration.seconds(0),
                        )
                    ],
                    s3_origin_source=cloudfront.S3OriginConfig(
                        s3_bucket_source=bucket,
                        origin_access_identity=distribution_oai,
                    ),
                ),
            ],
            price_class=cloudfront.PriceClass.PRICE_CLASS_ALL,
            viewer_protocol_policy=cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
            viewer_certificate=cloudfront.ViewerCertificate.from_acm_certificate(
                certificate=certificate,
                aliases=[site_domain],
                security_policy=cloudfront.SecurityPolicyProtocol.TLS_V1_2_2021,
                ssl_method=cloudfront.SSLMethod.SNI,
            ),
            error_configurations=[
                cloudfront.CfnDistribution.CustomErrorResponseProperty(
                    error_code=404,
                    error_caching_min_ttl=0,
                    response_code=200,
                    response_page_path="/index.html",
                )
            ],
        )

        route53.ARecord(
            self,
            "ARecord",
            target=route53.RecordTarget.from_alias(targets.CloudFrontTarget(distribution=distribution)),
            zone=hosted_zone,
            record_name=site_domain,
        )

        with open("catalog.yaml", "r") as f:
            catalog_content = yaml.safe_load(f)

        s3_deploy.BucketDeployment(
            self,
            "BucketDeployment",
            sources=[s3_deploy.Source.yaml_data("catalog.yaml", catalog_content)],
            destination_bucket=bucket,
            distribution=distribution,
            memory_limit=128,
            content_type="text/yaml",
        )
