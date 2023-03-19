output "remark42_admin_password" {
  value     = random_password.remark42_admin.result
  sensitive = true
}
