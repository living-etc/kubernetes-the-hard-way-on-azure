provider "kubernetes" {
  config_path = "../kubeconfig/admin.kubeconfig"
  host        = "https://kthw-cw.uksouth.cloudapp.azure.com:6443"
  insecure    = true
}
