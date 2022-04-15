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
          command = ["prefect", "orion", "start", "--host", "0.0.0.0", "--log-level", "WARNING"]

          port {
            container_port = var.port
          }

          image_pull_policy = "IfNotPresent"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
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
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
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

    labels = {
      app = var.app_name
    }
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



