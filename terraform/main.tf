
# --- INFRASTRUCTURE MODULES ---
module "vpc" {
  source               = "./modules/vpc"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security_groups" {
  source       = "./modules/security_groups"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
  my_ip_cidr   = var.baston_ip_cidr
}

module "load_balancers" {
  source                 = "./modules/load_balancers"
  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  public_subnets         = module.vpc.public_subnets
  sg_alb_id              = module.security_groups.sg_alb_id
  private_subnets        = module.vpc.private_subnets
  app_launch_template_id = module.compute.app_launch_template_id

  app_asg_desired = var.app_asg_desired
  app_asg_min     = var.app_asg_min
}

module "compute" {
  source          = "./modules/compute"
  project_name    = var.project_name
  environment     = var.environment
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  ssh_key_name    = var.ssh_key_name

  ami_id_ingestion = var.ami_id_ingestion
  ami_id_query     = var.ami_id_query
  ami_id_storage   = var.ami_id_storage
  bastion_ami_id   = var.bastion_ami_id

  sg_bastion_id   = module.security_groups.sg_bastion_id
  sg_ingestion_id = module.security_groups.sg_ingestion_id
  sg_query_id     = module.security_groups.sg_query_id
  sg_storage_id   = module.security_groups.sg_storage_id

  app_asg_desired = var.app_asg_desired
}

module "route53" {
  source         = "./modules/route53"
  create_route53 = var.create_route53
  domain_name    = var.domain_name
  alb_dns_name   = module.load_balancers.query_alb_dns
  alb_zone_id    = module.load_balancers.alb_zone_id
}

resource "local_file" "ansible_cfg" {
  filename = "${path.module}/../ansible.cfg"
  content  = <<EOT
[defaults]
inventory = aws_ec2.yml
host_key_checking = False
remote_user = ubuntu
private_key_file = sakshi.pem
timeout = 60

[ssh_connection]
ssh_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -i sakshi.pem -o StrictHostKeyChecking=no -W %h:%p -q ubuntu@${module.compute.bastion_public_ip}" -o ConnectionAttempts=5 -o ConnectTimeout=60
retries = 5
pipelining = True
EOT
}

