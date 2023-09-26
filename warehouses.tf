resource "snowflake_warehouse" "warehouse" {
  name           = "COMPUTE_ORG"
  warehouse_size = "XSMALL"
  auto_suspend   = 90
  warehouse_type = "STANDARD"
  auto_resume    = true
  initially_suspended = null
  max_concurrency_level = 8 // default
  query_acceleration_max_scale_factor = 8 // default
  statement_queued_timeout_in_seconds = 0 // default
  statement_timeout_in_seconds = 10800 // default is 2 days
}
