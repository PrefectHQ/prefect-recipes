# Service Account attached to the Prefect Agent
resource "google_service_account" "prefect_agent" {
  project      = var.project_id
  display_name = "prefect-agent"
  account_id   = "prefect-agent"
  description  = "Service account for VM running the Prefect agent. Managed by Terraform."
}
resource "google_project_iam_binding" "prefect_agent_instance_group" {
  for_each = toset(local.prefect_agent_vm_sa_bindings)
  project  = var.project_id
  role     = each.value
  members = [
    "serviceAccount:${google_service_account.prefect_agent.email}",
  ]
}
