module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "7.9.0"

  project_id = var.project_id

  name_prefix  = var.name_prefix
  machine_type = var.machine_type
  preemptible  = var.preemptible

  enable_confidential_vm       = true
  enable_nested_virtualization = false
  enable_shielded_vm           = true

  on_host_maintenance = "MIGRATE"
  startup_script = templatefile("${path.module}/prefect-agent.sh.tpl",
    {
      prefect_api_key     = var.prefect_api_key
      prefect_api_address = "https://api.prefect.cloud/api/accounts/${var.prefect_account_id}/workspaces/${var.prefect_workspace_id}"
      work_queue          = var.work_queue
    }
  )
  subnetwork         = var.subnet
  subnetwork_project = var.project_id
  auto_delete        = true
  can_ip_forward     = false

  # Use latest stable Ubuntu Image for base
  source_image         = "ubuntu-2204-jammy-v20221206"
  source_image_family  = "ubuntu-2204-lts"
  source_image_project = "ubuntu-os-cloud"
  disk_type            = var.disk_type
  disk_size_gb         = var.disk_size
  service_account = {
    email = google_service_account.prefect_agent.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  metadata = {
    "google-logging-enabled"     = true
    "google-monitoring-enabled"  = true
    "enable-oslogin"             = true
    "block-project-ssh-keys"     = true
    "serial-port-enable"         = false
    "serial-port-logging-enable" = false
  }

  disk_labels = {
    app = "prefect_agent"
  }

  labels = {
    app = "prefect-agent"
  }

  tags = [
    "prefect-agent",
  ]
}
