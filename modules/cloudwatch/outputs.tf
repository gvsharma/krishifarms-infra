output "log_group_names" {
  value = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
}

output "log_group_arns" {
  value = [for lg in aws_cloudwatch_log_group.this : lg.arn]
}

output "dashboard_name" {
  value = aws_cloudwatch_dashboard.main.dashboard_name
}

output "cpu_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.ec2_cpu_high.arn
}
