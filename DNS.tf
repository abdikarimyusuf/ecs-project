provider "aws" {
 alias  = "london"
  region = "eu-west-2"  # ACM certs for CloudFront must be in us-east-1
}



# Request the certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = "abdikarim.co.uk"
  validation_method = "DNS"
}

# Create DNS record to validate the cert
resource "aws_route53_record" "cert_validation" {
          name    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
          type    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
          zone_id = data.aws_route53_zone.main.zone_id
          ttl     = 60
          records = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
        }

# to check the DNS record and issue the cert
resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.london
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.ecs-lb.arn 
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-tg.arn
   # fixed_response {
     # content_type = "text/plain"
    #  message_body = "OK"
     # status_code  = "200"
   # }
  }
}
resource "aws_lb_listener" "name" {
  load_balancer_arn = aws_lb.ecs-lb.arn
  port     = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol = "HTTPS"
      port     = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_route53_record" "d_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name = "abdikarim.co.uk"
  type = "A"

  alias {
    name = aws_lb.ecs-lb.dns_name
    zone_id = aws_lb.ecs-lb.zone_id
    evaluate_target_health = true 
    
  }

  
}