module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.26"
  cluster_endpoint_public_access = true
  subnet_ids         = module.vpc.private_subnets

  cluster_addons = {
    coredns = {
        most_recent = true 
    }
    kube-proxy = {
        most_recent = true 
    }
    vpc-cni = {
        most_recent = true 
    }
  }

  eks_managed_node_groups = {
    default_node_group = {
        use_custom_launch_template = false 
        disk_size = 50 
    }

    utilities = {
        min_size = 1
        max_size = 3 
        desired_size = 2 
        capacity_type        = "SPOT"
        instance_types = ["t3.medium"]
    }

    applications = {
        min_size = 1
        max_size = 3 
        desired_size = 2 
        capacity_type        = "SPOT"
        instance_types = ["t3.medium"]
    }
  }
  
  tags = {
    Environment = "test"
  }

  vpc_id = module.vpc.vpc_id

}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [ 
    module.eks
   ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
  depends_on = [ 
    module.eks
  ]
}

locals {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = data.aws_eks_cluster.cluster.id
      cluster = {
        certificate-authority-data = data.aws_eks_cluster.cluster.certificate_authority[0].data
        server                     = data.aws_eks_cluster.cluster.endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = data.aws_eks_cluster.cluster.id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.cluster.token
      }
    }]
  })
}