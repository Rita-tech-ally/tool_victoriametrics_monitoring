resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami_id
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnets[0]
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [var.sg_bastion_id]
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.root}/../sakshi.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${path.root}/../sakshi.pem"
    destination = "/home/ubuntu/sakshi.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/sakshi.pem"
    ]
  }

  tags = {
    Name = "Bastion_Host"
  }
}

resource "aws_instance" "app" {
  ami                         = var.bastion_ami_id
  instance_type               = "t3.micro"
  subnet_id                   = var.private_subnets[0]
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [var.sg_ingestion_id, var.sg_query_id]
  associate_public_ip_address = false

  tags = {
    Name      = "vm-app"
    component = "vm-app"
    Project   = var.project_name
  }
}

# APP LAUNCH TEMPLATE (vminsert + vmselect + vmagent)
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-${var.environment}-app-"
  image_id      = var.ami_id_ingestion
  instance_type = "t3.micro"
  key_name      = var.ssh_key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.sg_ingestion_id, var.sg_query_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name      = "${var.project_name}-${var.environment}-app"
      component = "vm-app"
      Project   = var.project_name
    }
  }
}

# STORAGE INSTANCES (Count based with exact conditional tagging)
resource "aws_instance" "storage" {
  count                  = 3
  ami                    = var.ami_id_storage
  instance_type          = "t3.micro"
  key_name               = var.ssh_key_name
  subnet_id              = var.private_subnets[count.index % length(var.private_subnets)]
  vpc_security_group_ids = [var.sg_storage_id]

  tags = {
    Name      = "vmstorage-${count.index + 1}"
    component = "vmstorage"
    Project   = var.project_name
    extrarole = "vmalert"
  }
}

# GRAFANA INSTANCE (Dedicated grafana node)
resource "aws_instance" "grafana" {
  ami                    = var.ami_id_query
  instance_type          = "t3.micro"
  key_name               = var.ssh_key_name
  subnet_id              = var.private_subnets[2] # ap-south-1c
  vpc_security_group_ids = [var.sg_query_id, var.sg_storage_id]

  tags = {
    Name      = "grafana"
    component = "grafana"
    Project   = var.project_name
  }
}
