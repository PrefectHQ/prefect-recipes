resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

data "aws_secretsmanager_secret_version" "prefect_api_key" {
  secret_id = var.prefect_api_secret_id
}

resource "kubernetes_secret" "api_key" {
  metadata {
    name      = "prefect-cloud-api-key"
    namespace = var.namespace
  }

  data = {
    "key" = jsondecode(data.aws_secretsmanager_secret_version.prefect_api_key.secret_string)[var.prefect_api_secret_id]
  }
}

resource "kubernetes_deployment" "deployment" {
  lifecycle {
    create_before_destroy = true
  }

  metadata {
    generate_name = "${var.app}-"
    namespace     = kubernetes_namespace.namespace.id
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
        service_account_name            = kubernetes_service_account.agent.metadata[0].name
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
            value = kubernetes_namespace.namespace.id
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
                name = kubernetes_secret.api_key.metadata[0].name
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