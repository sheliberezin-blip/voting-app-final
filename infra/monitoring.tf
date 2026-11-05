resource "aws_sns_topic" "alerts" {
  name = "${local.name}-alerts"
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${local.name}-alb-5xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods   = 1
  metric_name          = "HTTPCode_Target_5XX_Count"
  namespace             = "AWS/ApplicationELB"
  period                = 60
  statistic             = "Sum"
  threshold             = 5
  treat_missing_data     = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}
EOF
cat monitoring.tf

פקודה 2 - outputs.tf:

bash
cat > outputs.tf << 'EOF'
output "vote_url" {
  value = "http://${aws_lb.main.dns_name}"
}

output "result_url" {
  value = "http://${aws_lb.main.dns_name}:8080"
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.main.cache_nodes[0].address
}

output "db_endpoint" {
  value = aws_db_instance.main.address
}