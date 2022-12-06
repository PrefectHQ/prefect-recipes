module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "7.9.0"

  project_id = var.project_id

  name_prefix  = "prefect-agent"     #var?
  machine_type = "n2d-highcpu-2" #var?
  preemptible  = true

  enable_confidential_vm       = true
  enable_nested_virtualization = false
  enable_shielded_vm           = true

  on_host_maintenance = "MIGRATE"
  # startup_script = "/home/start_agent_service.sh -u https://api.prefect.cloud/api/accounts/${var.prefect_account_id}/workspaces/${var.prefect_workspace_id} -k ${var.prefect_api_key} -q ${var.work_queue} && sudo systemctl daemon-reload"
  subnetwork         = var.subnet
  subnetwork_project = var.project_id
  auto_delete = true
  can_ip_forward = false

  # Use latest stable Ubuntu Image for base
  source_image = "ubuntu-2204-jammy-v20221206"
  source_image_family = "ubuntu-2204-lts"
  disk_type    = "pd-ssd" #var?
  disk_size_gb = "20"
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
    env = "${var.env}"
  }

  labels = {
    app = "prefect-agent"
  }

  tags = [
    "prefect-agent",
  ]
}
