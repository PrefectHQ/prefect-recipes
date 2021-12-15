resource "kubernetes_namespace" "namespace" {
  count = var.create_namespace == true ? 1 : 0
  metadata {
    name = var.namespace
  }
}

data "kubernetes_namespace" "namespace" {
  count = var.create_namespace == false ? 1 : 0
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "api_key" {
  count = var.use_existing_secret == false ? 1 : 0
  metadata {
    name      = var.api_key_secret_name
    namespace = var.namespace
  }

  data = {
    "key" = var.api_key
  }
}

locals {
  namespace       = var.create_namespace == false ? data.kubernetes_namespace.namespace[0] : kubernetes_namespace.namespace[0]
  service_account = var.use_existing_role == false ? kubernetes_service_account.agent[0].metadata[0].name : var.service_account_name
}

resource "kubernetes_deployment" "deployment" {
  lifecycle {
    create_before_destroy = true
  }

  metadata {
    generate_name = "${var.app}-"
    namespace     = local.namespace.id
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.app
      }
    }

    template {
      metadata {
        labels = {
          app = var.app
        }
      }

      spec {
        service_account_name            = local.service_account
        automount_service_account_token = var.automount_service_account_token
        dynamic "volume" {
          for_each = var.secret_volumes
          content {
            name = volume.value
            secret {
              secret_name = volume.value
            }
          }
        }
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_labels = {
                    "app" = var.app
                  }
                }
                topology_key = "failure-domain.beta.kubernetes.io/zone"
              }
            }
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_labels = {
                    "app" = var.app
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
          dynamic "node_affinity" {
            for_each = var.node_affinity != null ? [1] : []
            content {
              required_during_scheduling_ignored_during_execution {
                node_selector_term {
                  match_expressions {
                    key      = var.node_affinity.key
                    operator = var.node_affinity.operator
                    values   = var.node_affinity.values
                  }
                }
              }
            }
          }
        }
        container {
          command = ["/bin/sh", "-c"]
          args    = ["prefect agent kubernetes start ${var.start_args}"]

          env {
            name  = "PREFECT__CLOUD__AGENT__LABELS"
            value = var.prefect_labels
          }

          env {
            name  = "PREFECT__CLOUD__AGENT__LEVEL"
            value = var.logging_level
          }

          env {
            name  = "PREFECT__CLOUD__API"
            value = "https://${var.api}"
          }

          env {
            name  = "PREFECT__CLOUD__AGENT__AGENT_ADDRESS"
            value = "http://:8080"
          }

          env {
            name  = "NAMESPACE"
            value = local.namespace.metadata[0].name
          }

          dynamic "volume_mount" {
            for_each = var.volume_mounts
            content {
              name       = volume_mount.key
              mount_path = volume_mount.value
            }
          }

          dynamic "env" {
            for_each = var.env_values
            content {
              name  = env.key
              value = env.value
            }
          }

          dynamic "env" {
            for_each = var.env_secrets
            content {
              name = env.key

              value_from {
                secret_key_ref {
                  name = env.value
                  key  = replace("${env.value}.txt", "-", "_")
                }
              }
            }
          }

          env {
            name = "PREFECT__CLOUD__API_KEY"
            value_from {
              secret_key_ref {
                name = var.use_existing_secret == true ? var.api_key_secret_name : kubernetes_secret.api_key[0].metadata[0].name
                key  = "key"
              }
            }
          }


          image = "prefecthq/prefect:${var.prefect_version}"

          name              = var.app
          image_pull_policy = "Always"

          liveness_probe {
            http_get {
              path = "/api/health"
              port = 8080
            }

            failure_threshold     = 2
            initial_delay_seconds = 40
            period_seconds        = 40
          }

          resources {
            limits = {
              cpu    = var.limit_cpu
              memory = var.limit_mem
            }

            requests = {
              cpu    = var.request_cpu
              memory = var.request_mem
            }
          }
        }
      }
    }
  }
}

