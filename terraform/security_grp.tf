# Security Group for the Gateway VM (Public)
resource "aws_security_group" "gateway_sg" {
  name        = "iii-gateway-sg"
  description = "Security group for the iii API Gateway"
  vpc_id      = aws_vpc.main.id

  # Allow inbound HTTP for the API Gateway
  ingress {
    description = "HTTP API"
    from_port   = 3111
    to_port     = 3111
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound WebSocket RPC from within the VPC (for workers)
  ingress {
    description = "WebSocket RPC from VPC"
    from_port   = 49134
    to_port     = 49134
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  # Allow inbound SSH (optional, for debugging)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "iii-gateway-sg"
  }
}

# Security Group for the Worker VMs (Private)
resource "aws_security_group" "worker_sg" {
  name        = "iii-worker-sg"
  description = "Security group for iii workers"
  vpc_id      = aws_vpc.main.id

  # Allow SSH from within the VPC
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }


  # Allow all outbound (workers need to download packages/models via NAT)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "iii-worker-sg"
  }
}
