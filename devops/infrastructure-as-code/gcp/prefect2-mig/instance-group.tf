module "instance_group" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "7.9.0"
  project_id        = var.project_id # Project to deploy the MIG
  hostname          = "prefect-agent" # Name of the MIG
  instance_template = module.instance_template.self_link # Pull in the Instance Template for deployment
  region            = var.region # Region to deploy the MIG
  autoscaling_enabled = false # Set to true if the requirement is to allow for scaling of the MIG (Requires setting other params found [here](https://registry.terraform.io/modules/terraform-google-modules/vm/google/latest/submodules/mig?tab=inputs#optional-inputs))
  target_size         = var.num_vm # Set default num of VMs (Default to 1)
  wait_for_instances  = true # Wait for instances to come up before success

# Set the rolling update policy for the VMs
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
