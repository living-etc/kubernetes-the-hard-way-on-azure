resource "kubernetes_cluster_role" "rbac_defaults" {
  metadata {
    name = "system:kube-apiserver-to-kubelet"
    annotations = {
      "rbac.authorization.kubernetes.io/autoupdate" = "true"
    }
    labels = {
      "kubernetes.io/bootstrapping" = "rbac-defaults"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["nodes/proxy", "nodes/stats", "nodes/log", "nodes/spec", "nodes/metrics"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "example" {
  metadata {
    name = "system:kube-apiserver"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:kube-apiserver-to-kubelet"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = "kubernetes"
  }
}
