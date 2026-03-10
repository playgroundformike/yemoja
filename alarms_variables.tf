# alarms_variables.tf
variable "alert_emails" {
  description = "Emails for DLQ alarm notifications"
  type        = list(string)
}
