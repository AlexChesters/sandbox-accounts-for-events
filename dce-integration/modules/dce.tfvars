namespace = "dce"
namespace_prefix = "dce"
aws_region = "eu-west-1"
allowed_regions = [
  "us-east-1",
  "eu-west-1"
]

check_budget_enabled = true
check_budget_schedule_expression = "rate(1 hour)"
fan_out_update_lease_status_schedule_expression = "rate(1 hour)"
populate_reset_queue_schedule_expression = "rate(1 hour)"
budget_notification_from_email = "dce@cheste.rs"
budget_notification_threshold_percentiles = [75, 100]
principal_budget_period = "WEEKLY"

max_lease_budget_amount = 20
max_lease_period = 86400 # 24 hours

reset_nuke_toggle = "true"
reset_nuke_template_bucket = "atc-aws-nuke-config"
reset_nuke_template_key = "config.yml"

cloudwatch_dashboard_toggle = "false"

accounts_table_rcu = 1
accounts_table_wcu = 1
leases_table_rcu = 1
leases_table_wcu = 1
usage_table_rcu  = 1
usage_table_wcu = 1
