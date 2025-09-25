# Developer IAM User
resource "aws_iam_user" "developer" {
  name = "innovatemart-developer"
  path = "/"

  tags = {
    Name        = "InnovateMart Developer"
    Environment = "development"
    Team        = "development"
  }
}

# IAM Policy for EKS Read-Only Access
resource "aws_iam_policy" "eks_developer_policy" {
  name        = "InnovateMart-EKS-Developer-ReadOnly"
  path        = "/"
  description = "Read-only access to EKS cluster for developers"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeUpdate",
          "eks:ListUpdates",
          "eks:AccessKubernetesApi"
        ]
        Resource = aws_eks_cluster.main.arn
      },
      {
        Effect = "Allow"
        Action = [
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the EKS policy to developer user
resource "aws_iam_user_policy_attachment" "developer_eks_policy" {
  user       = aws_iam_user.developer.name
  policy_arn = aws_iam_policy.eks_developer_policy.arn
}

# Create access keys for the developer user
resource "aws_iam_access_key" "developer_access_key" {
  user = aws_iam_user.developer.name
}

# Kubernetes ConfigMap for aws-auth (to map IAM user to Kubernetes RBAC)
resource "kubernetes_config_map" "aws_auth" {
  depends_on = [aws_eks_cluster.main]
  
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.eks_node_group.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes"
        ]
      }
    ])

    mapUsers = yamlencode([
      {
        userarn  = aws_iam_user.developer.arn
        username = "innovatemart-developer"
        groups = [
          "developers"
        ]
      }
    ])
  }
}

# Kubernetes namespace for development
resource "kubernetes_namespace" "development" {
  depends_on = [aws_eks_cluster.main]
  
  metadata {
    name = "development"
  }
}

# Kubernetes ClusterRole for read-only access
resource "kubernetes_cluster_role" "developer_readonly" {
  depends_on = [aws_eks_cluster.main]

  metadata {
    name = "developer-readonly"
  }

  rule {
    api_groups = [""]
    resources = [
      "pods",
      "pods/log",
      "pods/status",
      "services",
      "endpoints",
      "configmaps",
      "secrets",
      "nodes",
      "namespaces",
      "events",
      "persistentvolumes",
      "persistentvolumeclaims"
    ]
    verbs = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources = [
      "deployments",
      "replicasets",
      "daemonsets",
      "statefulsets"
    ]
    verbs = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources = [
      "ingresses"
    ]
    verbs = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources = [
      "jobs",
      "cronjobs"
    ]
    verbs = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["metrics.k8s.io"]
    resources = [
      "pods",
      "nodes"
    ]
    verbs = ["get", "list"]
  }
}

# Kubernetes ClusterRoleBinding for developers group
resource "kubernetes_cluster_role_binding" "developer_readonly_binding" {
  depends_on = [aws_eks_cluster.main]

  metadata {
    name = "developer-readonly-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.developer_readonly.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "developers"
    api_group = "rbac.authorization.k8s.io"
  }
}

# Outputs for developer credentials
output "developer_access_key_id" {
  description = "Access key ID for the developer user"
  value       = aws_iam_access_key.developer_access_key.id
}

output "developer_secret_access_key" {
  description = "Secret access key for the developer user"
  value       = aws_iam_access_key.developer_access_key.secret
  sensitive   = true
}

output "developer_user_arn" {
  description = "ARN of the developer user"
  value       = aws_iam_user.developer.arn
}

output "developer_setup_instructions" {
  description = "Setup instructions for the developer"
  sensitive=true
  value = <<-EOT
    === InnovateMart Developer Access Setup ===
    
    1. Configure AWS CLI with developer credentials:
       aws configure --profile innovatemart-dev
       AWS Access Key ID: ${aws_iam_access_key.developer_access_key.id}
       AWS Secret Access Key: ${aws_iam_access_key.developer_access_key.secret}
       Default region: ${var.aws_region}
       Default output format: json
    
    2. Configure kubectl:
       aws eks --region ${var.aws_region} update-kubeconfig --name ${var.cluster_name} --profile innovatemart-dev
    
    3. Test access:
       kubectl get pods --all-namespaces
       kubectl logs <pod-name>
       kubectl describe pod <pod-name>
       kubectl get services
    
    Note: This user has READ-ONLY access and cannot modify resources.
  EOT
}