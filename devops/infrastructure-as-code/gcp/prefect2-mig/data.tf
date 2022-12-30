locals {
  # Role bindings for the service account associated with the VM
  # that the agent runs on and are required for the deployment
  prefect_agent_vm_sa_bindings = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/compute.imageUser",
  ]
}