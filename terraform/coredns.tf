resource "kubernetes_service_account" "coredns" {
  metadata {
    name      = "coredns"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role" "coredns" {
  metadata {
    name = "system:coredns"
    labels = {
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["endpoints", "services", "pods", "namespaces"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["discovery.k8s.io"]
    resources  = ["endpointslices"]
    verbs      = ["list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "coredns" {
  metadata {
    name = "system:coredns"
    labels = {
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = "true"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:coredns"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "coredns"
    namespace = "kube-system"
  }
}

resource "kubernetes_config_map" "coredns" {
  metadata {
    name      = "coredns"
    namespace = "kube-system"
  }

  data = {
    "Corefile" = "${file("${path.module}/Corefile")}"
  }
}

resource "kubernetes_deployment" "coredns" {
  metadata {
    name      = "coredns"
    namespace = "kube-system"
    labels = {
      "k8s-app"            = "kube-dns"
      "kubernetes.io/name" = "CoreDNS"
    }
  }

  spec {
    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = 1
      }
    }

    selector {
      match_labels = {
        "k8s-app"                = "kube-dns"
        "app.kubernetes.io/name" = "coredns"
      }
    }

    template {
      metadata {
        labels = {
          "k8s-app"                = "kube-dns"
          "app.kubernetes.io/name" = "coredns"
        }
      }

      spec {
        priority_class_name  = "system-cluster-critical"
        service_account_name = kubernetes_service_account.coredns.metadata[0].name
        dns_policy           = "Default"

        toleration {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }

        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              topology_key = "kubernetes.io/hostname"

              label_selector {
                match_expressions {
                  key      = "k8s-app"
                  operator = "In"
                  values   = ["kube-dns"]
                }
              }
            }
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        container {
          name              = "coredns"
          image             = "coredns/coredns:1.11.1"
          image_pull_policy = "IfNotPresent"

          resources {
            limits = {
              memory = "170Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "70Mi"
            }
          }

          args = ["-conf", "/etc/coredns/Corefile"]

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/coredns"
            read_only  = true
          }

          port {
            name           = "dns"
            protocol       = "UDP"
            container_port = 53
          }

          port {
            name           = "dns-tcp"
            protocol       = "TCP"
            container_port = 53
          }

          port {
            name           = "metrics"
            protocol       = "TCP"
            container_port = 9153
          }

          security_context {
            allow_privilege_escalation = true
            read_only_root_filesystem  = true

            capabilities {
              add  = ["NET_BIND_SERVICE"]
              drop = ["all"]
            }
          }

          liveness_probe {
            http_get {
              path   = "/health"
              port   = 8080
              scheme = "HTTP"
            }

            initial_delay_seconds = 60
            timeout_seconds       = 5
            success_threshold     = 1
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path   = "/ready"
              port   = 8181
              scheme = "HTTP"
            }
          }
        }

        volume {
          name = "config-volume"

          config_map {
            name = "coredns"

            items {
              key  = "Corefile"
              path = "Corefile"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "coredns" {
  metadata {
    name      = "kube-dns"
    namespace = "kube-system"
    annotations = {
      "prometheus.io/port"   = "9153"
      "prometheus.io/scrape" = "true"
    }
    labels = {
      "k8s-app"                       = "kube-dns"
      "kubernetes.io/cluster-service" = "true"
      "kubernetes.io/name"            = "CoreDNS"
      "app.kubernetes.io/name"        = "coredns"
    }
  }

  spec {
    cluster_ip = "10.32.0.10"

    selector = {
      "k8s-app"                = "kube-dns"
      "app.kubernetes.io/name" = "coredns"
    }

    port {
      name     = "dns"
      port     = 53
      protocol = "UDP"
    }

    port {
      name     = "dns-tcp"
      port     = 53
      protocol = "TCP"
    }

    port {
      name     = "metrics"
      port     = 9153
      protocol = "TCP"
    }
  }
}
