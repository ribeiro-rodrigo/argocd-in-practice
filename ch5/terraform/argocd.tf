data "kustomization_build" "argocd" {
  path = "../k8s-bootstrap/bootstrap"
}

resource "kustomization_resource" "argocd" {
  for_each = data.kustomization_build.argocd.ids
  manifest = data.kustomization_build.argocd.manifests[each.value]
}

resource "kubernetes_manifest" "argocd_application" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind" = "Application"
    "metadata" = {
      "name" = "argocd"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "argocd"
        "server" = "https://kubernetes.default.svc"
      }
      "project" = "default"
      "source" = {
        "path" = "ch5/k8s-bootstrap/bootstrap"
        "repoURL" = "https://github.com/ribeiro-rodrigo/argocd-in-practice.git"
      }
    }
  }
}

//>>> import socket
//>>> client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
//>>> client.connect(("172.20.31.223",8081))

//client.connect(("10.0.3.166",8081))
