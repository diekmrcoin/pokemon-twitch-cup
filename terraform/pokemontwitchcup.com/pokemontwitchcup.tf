locals {
  zone_id          = "Z04743363POZ0MO0D7NLU"
  upload_directory = "../fe/build/"
  mime_types = {
    htm  = "text/html"
    html = "text/html"
    txt  = "text/plain"
    css  = "text/css"
    ttf  = "font/ttf"
    js   = "application/javascript"
    map  = "application/javascript"
    json = "application/json"
    map  = "application/json"
    css  = "text/css"
    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    png  = "image/png"
    ico  = "image/vnd.microsoft.icon"
  }
  s3_origin_id = "PokeTwitchCup UI Bucket"
}

provider "aws" {
  alias  = "cloudfront"
  region = "us-east-1"
  default_tags {
    tags = {
      "Deploy"  = "terraform"
      "Project" = "pokemon twitch cup"
    }
  }
}

# terraform import module.pokemontwitchcup.aws_route53_record.www Z04743363POZ0MO0D7NLU_pokemontwitchcup.com_NS
resource "aws_route53_record" "www" {
  name = "pokemontwitchcup.com"
  records = [
    "ns-1416.awsdns-49.org.",
    "ns-1653.awsdns-14.co.uk.",
    "ns-30.awsdns-03.com.",
    "ns-762.awsdns-31.net.",
  ]
  ttl     = 172800
  type    = "NS"
  zone_id = local.zone_id
}

resource "aws_acm_certificate" "main_cert" {
  domain_name               = aws_route53_record.www.name
  subject_alternative_names = ["www.${aws_route53_record.www.name}"]
  validation_method         = "DNS"
  provider                  = aws.cloudfront
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "main_cert" {
  for_each = { for i, v in aws_acm_certificate.main_cert.domain_validation_options : v.resource_record_name => v }
  name     = each.value.resource_record_name
  records = [
    each.value.resource_record_value
  ]
  ttl     = 172800
  type    = each.value.resource_record_type
  zone_id = local.zone_id
}

resource "aws_route53_record" "cloudfront" {
  name = aws_route53_record.www.name
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
  }
  type    = "A"
  zone_id = local.zone_id
}

resource "aws_route53_record" "www_cloudfront" {
  name           = "www.${aws_route53_record.www.name}"
  type           = "CNAME"
  zone_id        = local.zone_id
  set_identifier = "www"
  records        = [aws_cloudfront_distribution.main.domain_name]
  ttl            = 5
  weighted_routing_policy {
    weight = 100
  }
}

resource "aws_s3_bucket" "ui" {
  bucket = "pokemon-twitch-cup-ui"
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.ui.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.ui.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.main.iam_arn]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.ui.arn,
      "${aws_s3_bucket.ui.arn}/*",
    ]
  }
}

resource "aws_s3_object" "ui_files" {
  for_each     = fileset("${local.upload_directory}", "**/*.*")
  bucket       = aws_s3_bucket.ui.bucket
  key          = replace(each.value, "${local.upload_directory}", "")
  source       = "${local.upload_directory}${each.value}"
  etag         = filemd5("${local.upload_directory}${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}

resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "PokeTwitchCup UI Cloudfront"
}

resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  is_ipv6_enabled = false
  aliases         = [aws_route53_record.www.name, "www.${aws_route53_record.www.name}"]
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.main_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  price_class         = "PriceClass_100"
  default_root_object = "index.html"
  comment             = "Pokemon Twitch Cup Website"

  origin {
    domain_name = aws_s3_bucket.ui.bucket_domain_name
    origin_id   = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    # TODO: security headers
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }
}
