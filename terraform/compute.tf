variable "instance_type" {
  type        = string
  description = "EC2 instance type for the game server"
  default     = "c7i-flex.large"
}

variable "use_spot" {
  type        = bool
  description = "Run the server on Spot instead of On-Demand"
  default     = false
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_launch_template" "game" {
  name_prefix   = "${var.project}-"
  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.instance.name
  }

  vpc_security_group_ids = [aws_security_group.game.id]

  # Require IMDSv2 (safer instance metadata)
  metadata_options {
    http_tokens = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20
      volume_type = "gp3"
    }
  }

  dynamic "instance_market_options" {
    for_each = var.use_spot ? [1] : []

    content {
      market_type = "spot"

      spot_options {
        spot_instance_type = "one-time"
      }
    }
  }

  user_data = base64encode(replace(
    templatefile("${path.module}/user_data.sh.tpl", {
      bucket = aws_s3_bucket.world.id
      region = var.region
    }),
    "\r\n",
    "\n"
  ))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Project = var.project
      Role    = "game-server"
    }
  }
}

resource "aws_instance" "game" {
  launch_template {
    id      = aws_launch_template.game.id
    version = aws_launch_template.game.latest_version
  }

  tags = {
    Name    = "${var.project}-server"
    Project = var.project
  }
}