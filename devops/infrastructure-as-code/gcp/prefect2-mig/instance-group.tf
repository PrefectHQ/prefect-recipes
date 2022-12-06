module "instance_group" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "7.9.0"

  project_id        = var.project_id
  hostname          = "prefect-agent"
  instance_template = module.instance_template.self_link
  region            = var.region

  autoscaling_enabled = false
  target_size         = var.num_vm
  wait_for_instances = true

  update_policy = [{
    type                           = "PROACTIVE"
    minimal_action                 = "REFRESH"
    instance_redistribution_type   = null
    most_disruptive_allowed_action = "REPLACE"
    max_surge_fixed                = 3
    max_surge_percent              = null
    max_unavailable_fixed          = 3
    max_unavailable_percent        = null
    min_ready_sec                  = null
    replacement_method             = "SUBSTITUTE"
  }]
}
