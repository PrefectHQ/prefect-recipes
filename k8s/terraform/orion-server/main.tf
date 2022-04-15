resource "kubernetes_deployment" "orion" {
  metadata {
    name = var.app_name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = merge(
          { app = var.app_name }, var.kubernetes_resources_labels
        )
      }

      spec {
        container {
          name    = "api"
          image   = "prefecthq/prefect:${var.prefect_version}-python3.8"
          command = ["prefect", "orion", "start", "--host", "0.0.0.0", "--log-level", var.logging_level]

          port {
            container_port = var.port
          }

          image_pull_policy = "IfNotPresent"

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

        container {
          name    = "agent"
          image   = "prefecthq/prefect:${var.prefect_version}-python3.8"
          command = ["prefect", "agent", "start", "kubernetes"]

          env {
            name  = "PREFECT_API_URL"
            value = "http://${var.app_name}:${var.port}/api"
          }

          image_pull_policy = "IfNotPresent"
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


resource "kubernetes_service" "orion" {
  metadata {
    name = var.app_name

    labels = merge(
      { app = var.app_name }, var.kubernetes_resources_labels
    )
  }

  spec {
    port {
      protocol = "TCP"
      port     = var.port
    }

    selector = {
      app = var.app_name
    }
  }
}



