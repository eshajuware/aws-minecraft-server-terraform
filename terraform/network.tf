data "aws_vpc" "default" {
  default = true
}

# Only the game port is open. No SSH (port 22): shell access is via SSM.
resource "aws_security_group" "game" {
  name        = "${var.project}-game"
  description = "Minecraft game port only"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Minecraft Java"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.project
  }
}