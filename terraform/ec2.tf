data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Gateway VM (Public Subnet)
resource "aws_instance" "gateway" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type_gateway
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.gateway_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name != "" ? var.key_name : null

  user_data = templatefile("${path.module}/user_data/gateway.sh", {
    repository_url = var.repository_url
  })

  tags = {
    Name = "iii-gateway"
  }
}

# Caller Worker VM (Private Subnet)
resource "aws_instance" "caller_worker" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type_caller
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.worker_sg.id]
  associate_public_ip_address = false
  key_name                    = var.key_name != "" ? var.key_name : null

  user_data = templatefile("${path.module}/user_data/caller.sh", {
    repository_url = var.repository_url,
    gateway_ip     = aws_instance.gateway.private_ip
  })

  
  depends_on = [aws_nat_gateway.nat]

  tags = {
    Name = "iii-caller-worker"
  }
}

# Inference Worker VM (Private Subnet)
resource "aws_instance" "inference_worker" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type_inference
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.worker_sg.id]
  associate_public_ip_address = false
  key_name                    = var.key_name != "" ? var.key_name : null

  user_data = templatefile("${path.module}/user_data/inference.sh", {
    repository_url = var.repository_url,
    gateway_ip     = aws_instance.gateway.private_ip
  })

  
  depends_on = [aws_nat_gateway.nat]

  tags = {
    Name = "iii-inference-worker"
  }
}
