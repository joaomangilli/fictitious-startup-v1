resource "aws_budgets_budget" "cost" {
  time_unit = "MONTHLY"
  budget_type  = "COST"
  limit_amount = "5"
  limit_unit   = "USD"
}
