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

# Generate an SSH key automatically
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = "iii-auto-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

# Save the private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/iii-auto-key.pem"
  file_permission = "0400"
}

# Fix for Windows: Reset file permissions before destroy so Terraform can successfully delete the file
resource "null_resource" "pem_destroy_fix" {
  depends_on = [local_file.private_key]

  provisioner "local-exec" {
    when       = destroy
    command    = "icacls iii-auto-key.pem /reset"
    on_failure = continue
  }
}

# Gateway VM (Public Subnet)
resource "aws_instance" "gateway" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type_gateway
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.gateway_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated.key_name

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
  key_name                    = aws_key_pair.generated.key_name

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
  key_name                    = aws_key_pair.generated.key_name

  user_data = templatefile("${path.module}/user_data/inference.sh", {
    repository_url = var.repository_url,
    gateway_ip     = aws_instance.gateway.private_ip
  })

  
  depends_on = [aws_nat_gateway.nat]

  tags = {
    Name = "iii-inference-worker"
  }
}
