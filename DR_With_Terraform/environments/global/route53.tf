# Route 53 failover DNS record
resource "aws_route53_record" "failover" {
  zone_id = aws_route53_zone.example_zone.zone_id
  name    = "app.example.com"
  type    = "A"

  set_identifier = "primary"
  failover_routing_policy {
    type = "PRIMARY"
  }

  alias {
    name                   = aws_instance.primary_instance.public_dns
    zone_id                = aws_instance.primary_instance.availability_zone
    evaluate_target_health = true
  }
}

# Secondary record (optional for failover setup)
resource "aws_route53_record" "secondary_failover" {
  zone_id = aws_route53_zone.example_zone.zone_id
  name    = "app.example.com"
  type    = "A"

  set_identifier = "secondary"
  failover_routing_policy {
    type = "SECONDARY"
  }

  alias {
    name                   = aws_instance.secondary_instance.public_dns
    zone_id                = aws_instance.secondary_instance.availability_zone
    evaluate_target_health = true
  }
}
