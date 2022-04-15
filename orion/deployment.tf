resource "kubernetes_deployment" "orion" {
  metadata {
    name = "orion"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "orion"
      }
    }

    template {
      metadata {
        labels = {
          app = "orion"
        }
      }

      spec {
        container {
          name    = "api"
          image   = "prefecthq/prefect:${var.prefect_version}-python3.8"
          command = ["prefect", "orion", "start", "--host", "0.0.0.0", "--log-level", "WARNING"]

          port {
            container_port = 4200
          }

          image_pull_policy = "IfNotPresent"
        }

        container {
          name    = "agent"
          image   = "prefecthq/prefect:${var.prefect_version}-python3.8"
          command = ["prefect", "agent", "start", "kubernetes"]

          env {
            name  = "PREFECT_API_URL"
            value = "http://orion:4200/api"
          }

          image_pull_policy = "IfNotPresent"
        }
      }
    }
  }
}

resource "kubernetes_service" "orion" {
  metadata {
    name = "orion"

    labels = {
      app = "orion"
    }
  }

  spec {
    port {
      protocol = "TCP"
      port     = 4200
    }

    selector = {
      app = "orion"
    }
  }
}



