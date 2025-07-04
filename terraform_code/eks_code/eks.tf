# Jenkins IAM Role
resource "aws_iam_role" "jenkins_assume_role" {
  name = "jenkins-eks-assume-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = "arn:aws:iam::434612646751:user/open-environment-5vzkp-admin"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Purpose = "Allow Jenkins to access EKS"
  }
}

resource "aws_iam_role_policy_attachment" "jenkins_eks_access" {
  role       = aws_iam_role.jenkins_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy" "jenkins_eks_describe_cluster" {
  name = "jenkins-eks-describe-cluster"
  role = aws_iam_role.jenkins_assume_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster"
        ],
        Resource = "arn:aws:eks:eu-west-2:434612646751:cluster/amazon-prime-cluster"
      }
    ]
  })
}

# EKS Cluster Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.1"

  cluster_name                   = "amazon-prime-cluster"
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

  eks_managed_node_groups = {
    panda-node = {
      min_size       = 2
      max_size       = 4
      desired_size   = 2
      instance_types = ["t2.medium"]
      capacity_type  = "SPOT"
      tags = {
        ExtraTag = "Panda_Node"
      }
    }
  }

  access_entries = {
    admin = {
      principal_arn = "arn:aws:iam::434612646751:user/open-environment-5vzkp-admin"
      username      = "open-environment-5vzkp-admin"
      groups        = ["system:masters"]
    }

    jenkins = {
      principal_arn = aws_iam_role.jenkins_assume_role.arn
      username      = "jenkins"
      groups        = ["system:masters"]
    }
  }

  tags = {
    Environment = "dev"
    Project     = "Amazon Prime"
  }
}
