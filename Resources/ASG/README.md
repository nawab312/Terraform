`main.tf`
- Creates an Auto Scaling Group (ASG) in the public subnet.
- Instances get a public IP (because map_public_ip_on_launch = true).
- The ASG automatically scales between 1 and 3 instances.
- Instances run Apache web server, accessible on port 80.

