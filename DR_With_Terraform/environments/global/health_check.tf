resource "aws_route53_health_check" "primary_health" {
  fqdn             = "primary-app.example.com"
  type             = "HTTP"
  port             = 80
  request_interval = 30
  failure_threshold = 3
}

resource "aws_route53_health_check" "secondary_health" {
  fqdn             = "secondary-app.example.com"
  type             = "HTTP"
  port             = 80
  request_interval = 30
  failure_threshold = 3
}
