# modules/app-helm-chart/main.tf

# Optionally create the Kubernetes namespace if it doesn't exist
resource "kubernetes_namespace" "app_namespace" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.namespace
  }
}

# Deploy the Helm release for the application
resource "helm_release" "app_release" {
  name       = var.name       # Name of the Helm release
  repository = "."            # Points to the local chart path relative to Terraform root
  chart      = var.chart_path # Path to the Helm chart (e.g., "helm-charts/frontend")
  namespace  = var.namespace
  # Do not let Helm create namespace if Terraform manages it via kubernetes_namespace
  create_namespace = false

  # Pass values to the Helm chart from the 'values' variable
  values = [yamlencode(var.values)]

  # Ensure the namespace is created before the Helm release is installed
  depends_on = [kubernetes_namespace.app_namespace]
}
