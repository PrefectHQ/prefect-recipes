locals {
  # Role bindings for the service account associated with the VM
  # that the agent runs ons
  prefect_agent_vm_sa_bindings = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/compute.imageUser",
  ]
}